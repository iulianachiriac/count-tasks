/**
 * Apex Test Class for all scenarios
 * (insert, update, delete, close tasks,
 * re open tasks, reparenting tasks)
 */
@isTest
public class TaskTriggerTest {
  private static final Integer ACCOUNTS_NUMBER = 100;
  private static final Integer TASKS_NUMBER = 3;

  @TestSetup
  private static void makeData() {
    List<Account> accounts = new List<Account>();

    for (Integer i = 0; i < ACCOUNTS_NUMBER; i++) {
      Account acc = new Account(
        Name = 'Test Account ' + i,
        Type = 'Prospect',
        RecordTypeId = TaskTriggerHandler.recordTypeUS
      );
      accounts.add(acc);
    }
    Test.startTest();
    insert accounts;
    Test.stopTest();
  }

  //inserting >200 tasks
  @isTest
  private static void insertNewTasks() {
    List<Account> accounts = [
      SELECT Id
      FROM Account
      LIMIT :ACCOUNTS_NUMBER
    ];

    List<Task> tasks = TaskTriggerHelperTest.createTasks(
      accounts,
      'Other',
      TASKS_NUMBER
    );

    accounts = [
      SELECT Id, Open_Tasks_Other__c
      FROM Account
      WHERE Id IN :accounts
    ];

    for (Account a : accounts) {
      Assert.areEqual(
        TASKS_NUMBER,
        a.Open_Tasks_Other__c,
        'Failed to get expected amount of open tasks on Account after insert'
      );
    }
  }

  //updating >200 tasks
  @isTest
  private static void updateTasks() {
    List<Account> accounts = [SELECT Id FROM Account LIMIT :ACCOUNTS_NUMBER];

    List<Task> tasks = TaskTriggerHelperTest.createTasks(
      accounts,
      'Email',
      TASKS_NUMBER
    );

    //closing tasks
    for (Task task : tasks) {
      task.Status = 'Completed';
    }

    Test.startTest();
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
    Test.stopTest();

    accounts = [
      SELECT Id, Open_Tasks_Email__c
      FROM Account
      WHERE Id IN :accounts
    ];

    for (Account acc : accounts) {
      Assert.areEqual(
        TASKS_NUMBER,
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
      LIMIT :ACCOUNTS_NUMBER
    ];

    List<Task> tasks = TaskTriggerHelperTest.createTasks(
      accounts,
      'Meeting',
      TASKS_NUMBER
    );

    Test.startTest();
    delete tasks;
    Test.stopTest();

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

    List<Task> tasks = TaskTriggerHelperTest.createTasksOnSingleAccount(
      firstAccount,
      'Call',
      (ACCOUNTS_NUMBER * TASKS_NUMBER)
    );

    Account secondAccount = [
      SELECT Id
      FROM Account
      WHERE Id != :firstAccId
      LIMIT 1
    ];
    Id secondAccId = secondAccount.Id;

    for (Task task : tasks) {
      task.WhatId = secondAccId;
    }

    Test.startTest();
    update tasks;
    Test.stopTest();

    //count on first related Account
    Assert.areEqual(
      0,
      [SELECT Open_Tasks_Call__c FROM Account WHERE Id = :firstAccId]
      .Open_Tasks_Call__c,
      'Failed to get expected amount of open tasks on first related Account'
    );
    //count on current related Account
    Assert.areEqual(
      ACCOUNTS_NUMBER * TASKS_NUMBER,
      [SELECT Open_Tasks_Call__c FROM Account WHERE Id = :secondAccId]
      .Open_Tasks_Call__c,
      'Failed to get expected amount of open tasks on current related Account'
    );
  }
}
