public without sharing class TaskTriggerHandler {
  @testvisible
  private static final Id recordTypeUS = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('United_States')
    .getRecordTypeId();

  public static void handleAfterInsert(List<Task> newTasks) {
    Set<Id> whatIds = filterTasks(newTasks);
    if (whatIds.isEmpty()) {
      return;
    }
    List<Account> accountsToUpdate = setTaskCountValues(
      getRelatedAccountsWithOpenTasks(whatIds)
    );
    update accountsToUpdate;
  }

  public static void handleAfterUpdate(
    List<Task> oldTasks,
    List<Task> newTasks
  ) {
    Set<Id> whatIds = filterTasks(newTasks);
    whatIds.addAll(filterTasks(oldTasks));
    if (whatIds.isEmpty()) {
      return;
    }
    List<Account> accountsToUpdate = setTaskCountValues(
      getRelatedAccountsWithOpenTasks(whatIds)
    );
    update accountsToUpdate;
  }

  public static void handleAfterDelete(List<Task> oldTasks) {
    Set<Id> whatIds = filterTasks(oldTasks);
    if (whatIds.isEmpty()) {
      return;
    }
    List<Account> accountsToUpdate = setTaskCountValues(
      getRelatedAccountsWithOpenTasks(whatIds)
    );
    update accountsToUpdate;
  }

  public static Set<Id> filterTasks(List<Task> tasks) {
    Set<Id> whatIds = new Set<Id>();
    for (Task task : tasks) {
      if (task.WhatId?.getSobjectType() == Account.SObjectType) {
        whatIds.add(task.WhatId);
      }
    }
    return whatIds;
  }

  public static List<Account> getRelatedAccountsWithOpenTasks(Set<Id> whatIds) {
    List<Account> accounts = [
      SELECT
        Id,
        Open_Tasks_Call__c,
        Open_Tasks_Email__c,
        Open_Tasks_Meeting__c,
        Open_Tasks_Other__c,
        (SELECT WhatId, Type FROM Tasks WHERE isClosed = FALSE)
      FROM Account
      WHERE
        Id IN :whatIds
        AND RecordTypeId = :recordTypeUS
        AND Type = 'Prospect'
    ];

    return accounts;
  }

  public static List<Account> setTaskCountValues(List<Account> accounts) {
    List<Account> accountsToUpdate = new List<Account>();
    for (Account acc : accounts) {
      Decimal callTasks = 0;
      Decimal emailTasks = 0;
      Decimal meetingTasks = 0;
      Decimal otherTasks = 0;

      for (Task t : acc.Tasks) {
        if (t.whatId == acc.Id) {
          if (t.type == 'Call') {
            callTasks++;
          } else if (t.type == 'Email') {
            emailTasks++;
          } else if (t.type == 'Meeting') {
            meetingTasks++;
          } else {
            otherTasks++;
          }
        }
      }

      acc.Open_Tasks_Call__c = callTasks;
      acc.Open_Tasks_Email__c = emailTasks;
      acc.Open_Tasks_Meeting__c = meetingTasks;
      acc.Open_Tasks_Other__c = otherTasks;

      accountsToUpdate.add(acc);
    }
    return accountsToUpdate;
  }
}
