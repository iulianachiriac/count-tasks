public without sharing class TaskTriggerHandler {
  public static void updateRelatedAccounts(List<Task> tasks) {
    Set<Id> whatIdsRelatedToAccounts = new Set<Id>();
    for (Task task : tasks) {
      if (
        task.WhatId <> null &&
        task.WhatId.getSobjectType() == Account.getSObjectType()
      ) {
        whatIdsRelatedToAccounts.add(task.WhatId);
      } else {
        return;
      }
    }
    List<Account> accounts = countSpecificTasks(
      getUnitedStatesProspectAccounts(whatIdsRelatedToAccounts)
    );
    update accounts;
  }

  public static List<Account> getUnitedStatesProspectAccounts(Set<Id> whatIds) {
    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('United_States')
      .getRecordTypeId();

    List<Account> accountsList = [
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
        AND RecordTypeId = :recordTypeId
        AND Type = 'Prospect'
    ];

    return accountsList;
  }

  public static List<Account> countSpecificTasks(List<Account> accounts) {
    List<Account> accountsList = new List<Account>();
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

      accountsList.add(acc);
    }
    return accountsList;
  }
}