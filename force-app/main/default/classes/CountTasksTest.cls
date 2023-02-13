/**
 * Apex Test Class for all scenarios
 * (insert, update, delete, close tasks,
 * re open tasks, reparenting task)
 */
@isTest
public class CountTasksTest {
  private static final Integer ACCOUNTS_NUMBER = 120;
  private static final Integer TASKS_NUMBER = 15;

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

    insert accounts;

    List<Task> tasks = new List<Task>();
    for (Account acc : accounts) {
      for (Integer i = 0; i < TASKS_NUMBER; i++) {
        Task taskCall = new Task(
          Subject = 'Call',
          Type = 'Call',
          WhatId = acc.Id
        );
        tasks.add(taskCall);
        Task taskEmail = new Task(
          Subject = 'Email',
          Type = 'Email',
          WhatId = acc.Id
        );
        tasks.add(taskEmail);
        Task taskMeeting = new Task(
          Subject = 'Meeting',
          Type = 'Meeting',
          WhatId = acc.Id
        );
        tasks.add(taskMeeting);
        Task taskOther = new Task(
          Subject = 'Other',
          Type = 'Other',
          WhatId = acc.Id
        );
        tasks.add(taskOther);
      }
    }
    insert tasks;
  }

  @isTest
  private static void shouldHaveAccountsAndTasksInDatabase() {
    Assert.areEqual(
      ACCOUNTS_NUMBER,
      [SELECT COUNT() FROM Account],
      'Failed to get expected amount of Accounts'
    );
    Integer numberOfTaskTypes = 4;
    Assert.areEqual(
      (ACCOUNTS_NUMBER * TASKS_NUMBER * numberOfTaskTypes),
      [SELECT COUNT() FROM Task],
      'Failed to get expected amount of tasks'
    );
  }

  //inserting 210 tasks
  @isTest
  public static void insertNewTasks() {
    List<Account> accounts = [SELECT Id FROM Account LIMIT 42];

    List<Task> tasksList = new List<Task>();
    for (Account acc : accounts) {
      Id accId = acc.id;
      for (Integer i = 0; i < 5; i++) {
        Task taskOther = new Task(
          Subject = 'Other',
          Type = 'Other',
          WhatId = accId
        );
        tasksList.add(taskOther);
      }
    }

    insert tasksList;

    Assert.areEqual(
      TASKS_NUMBER + 5,
      [SELECT Open_Tasks_Other__c FROM Account WHERE Id = :accounts LIMIT 1]
      .Open_Tasks_Other__c,
      'Failed to get expected amount of open tasks on Account after insert'
    );
  }

  //updating 210 tasks
  @isTest
  private static void updateTasks() {
    List<Account> accounts = [SELECT Id FROM Account LIMIT 42];

    List<Task> tasksList = [
      SELECT Type, Status
      FROM Task
      WHERE WhatId = :accounts AND Status != 'Completed' AND Type = 'Email'
      LIMIT 5
    ];

    //closing tasks
    for (Task task : tasksList) {
      task.Status = 'Completed';
    }
    update tasksList;

    Assert.areEqual(
      TASKS_NUMBER - 5,
      [SELECT Open_Tasks_Email__c FROM Account WHERE Id = :accounts LIMIT 1]
      .Open_Tasks_Email__c,
      'Failed to get expected amount of open tasks on Account after closing a task'
    );

    //re-opening
    for (Task task : tasksList) {
      task.Status = 'In progress';
    }
    update tasksList;

    Assert.areEqual(
      TASKS_NUMBER,
      [SELECT Open_Tasks_Email__c FROM Account WHERE Id = :accounts LIMIT 1]
      .Open_Tasks_Email__c,
      'Failed to get expected amount of open tasks on Account after re-opening a task'
    );
  }

  //deleting 210 tasks
  @isTest
  private static void deleteTasks() {
    List<Account> accounts = [SELECT Id FROM Account LIMIT 42];

    List<Task> openTasks = [
      SELECT Type, Status
      FROM Task
      WHERE WhatId = :accounts AND Status != 'Completed' AND Type = 'Other'
      LIMIT 5
    ];

    delete openTasks;

    Assert.areEqual(
      TASKS_NUMBER - 5,
      [SELECT Open_Tasks_Other__c FROM Account WHERE Id = :accounts LIMIT 1]
      .Open_Tasks_Other__c,
      'Failed to get expected amount of open tasks on Account after delete'
    );
  }

  //reparenting a task to a new account scenario
  @isTest
  private static void reparentingTask() {
    Account account = [SELECT Id FROM Account LIMIT 1];
    Id accId = account.Id;

    Task openTask = [
      SELECT WhatId
      FROM Task
      WHERE WhatId != :accId AND Status != 'Completed' AND Type = 'Other'
      LIMIT 1
    ];
    Id firstParent = openTask.WhatId;
    openTask.WhatId = accId;

    update openTask;

    //count on first related Account
    Assert.areEqual(
      TASKS_NUMBER - 1,
      [SELECT Open_Tasks_Other__c FROM Account WHERE Id = :firstParent]
      .Open_Tasks_Other__c,
      'Failed to get expected amount of open tasks on first related Account'
    );

    //count on current related Account
    Assert.areEqual(
      TASKS_NUMBER + 1,
      [SELECT Open_Tasks_Other__c FROM Account WHERE Id = :accId]
      .Open_Tasks_Other__c,
      'Failed to get expected amount of open tasks on current related Account'
    );
  }
}
