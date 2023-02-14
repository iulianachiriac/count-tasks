/**
 * Apex Test Class for all scenarios
 * (insert, update, delete, close tasks,
 * re open tasks, reparenting tasks)
 */
@isTest
public class CountTasksTest {
  @TestSetup
  private static void makeData() {
    List<Account> accounts = new List<Account>();

    for (Integer i = 0; i < 100; i++) {
      Account acc = new Account(
        Name = 'Test Account ' + i,
        Type = 'Prospect',
        RecordTypeId = TaskTriggerHandler.recordTypeUS
      );
      accounts.add(acc);
    }

    insert accounts;
  }

  //inserting >200 tasks
  @isTest
  public static void insertNewTasks() {
    List<Account> accounts = [
      SELECT Id
      FROM Account
      LIMIT 42
    ];

    List<Task> tasks = new List<Task>();
    for (Account acc : accounts) {
      for (Integer i = 0; i < 5; i++) {
        Task taskOther = new Task(
          Subject = 'Other',
          Type = 'Other',
          WhatId = acc.id
        );
        tasks.add(taskOther);
      }
    }

    insert tasks;

    accounts = [
      SELECT Id, Open_Tasks_Other__c
      FROM Account
      WHERE Id IN :accounts
    ];

    for (Account a : accounts) {
      Assert.areEqual(
        5,
        a.Open_Tasks_Other__c,
        'Failed to get expected amount of open tasks on Account after insert'
      );
    }
  }

  //updating >200 tasks
  @isTest
  private static void updateTasks() {
    List<Account> accounts = [SELECT Id FROM Account LIMIT 42];

    List<Task> tasks = new List<Task>();
    for (Account acc : accounts) {
      for (Integer i = 0; i < 5; i++) {
        Task taskEmail = new Task(
          Subject = 'Email',
          Type = 'Email',
          WhatId = acc.id
        );
        tasks.add(taskEmail);
      }
    }

    insert tasks;

    //closing tasks
    for (Task task : tasks) {
      task.Status = 'Completed';
    }
    update tasks;

    accounts = [
      SELECT Id, Open_Tasks_Email__c
      FROM Account
      WHERE Id IN :accounts
    ];

    for (Account acc : accounts) {
      Assert.areEqual(
        0,
        acc.Open_Tasks_Email__c,
        'Failed to get expected amount of open tasks on Account after closing tasks'
      );
    }

    //re-opening
    for (Task task : tasks) {
      task.Status = 'In progress';
    }
    update tasks;

    accounts = [
      SELECT Id, Open_Tasks_Email__c
      FROM Account
      WHERE Id IN :accounts
    ];

    for (Account acc : accounts) {
      Assert.areEqual(
        5,
        acc.Open_Tasks_Email__c,
        'Failed to get expected amount of open tasks on Account after re-opening tasks'
      );
    }
  }

  //deleting >200 tasks
  @isTest
  private static void deleteTasks() {
    List<Account> accounts = [
      SELECT Id
      FROM Account
      LIMIT 42
    ];

    List<Task> tasks = new List<Task>();
    for (Account acc : accounts) {
      for (Integer i = 0; i < 5; i++) {
        Task taskMeeting = new Task(
          Subject = 'Meeting',
          Type = 'Meeting',
          WhatId = acc.Id
        );
        tasks.add(taskMeeting);
      }
    }

    insert tasks;
    delete tasks;

    accounts = [
      SELECT Id, Open_Tasks_Meeting__c
      FROM Account
      WHERE Id IN :accounts
    ];

    for (Account acc : accounts) {
      Assert.areEqual(
        0,
        acc.Open_Tasks_Meeting__c,
        'Failed to get expected amount of open tasks on Account after delete'
      );
    }
  }

  //reparenting >200 Tasks
  @isTest
  private static void reparentingTasks() {
    Account firstAccount = [SELECT Id FROM Account LIMIT 1];
    Id firstAccId = firstAccount.Id;

    List<Task> openTasks = new List<Task>();
    for (Integer i = 0; i < 210; i++) {
      Task taskCall = new Task(
        Subject = 'Call',
        Type = 'Call',
        WhatId = firstAccId
      );
      openTasks.add(taskCall);
    }
    insert openTasks;

    Account secondAccount = [
      SELECT Id
      FROM Account
      WHERE Id != :firstAccId
      LIMIT 1
    ];
    Id secondAccId = secondAccount.Id;

    for (Task task : openTasks) {
      task.WhatId = secondAccId;
    }
    update openTasks;

    //count on first related Account
    Assert.areEqual(
      0,
      [SELECT Open_Tasks_Call__c FROM Account WHERE Id = :firstAccId]
      .Open_Tasks_Call__c,
      'Failed to get expected amount of open tasks on first related Account'
    );
    //count on current related Account
    Assert.areEqual(
      210,
      [SELECT Open_Tasks_Call__c FROM Account WHERE Id = :secondAccId]
      .Open_Tasks_Call__c,
      'Failed to get expected amount of open tasks on current related Account'
    );
  }
}
