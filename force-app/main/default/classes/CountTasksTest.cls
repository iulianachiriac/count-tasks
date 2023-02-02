/**
 * Apex Test Class for all scenarios
 * (insert, update, delete, close task, re open task)
 */
@isTest
public class CountTasksTest {

    private static final Integer ACCOUNTS_NUMBER = 5;
    private static final Integer TASKS_NUMBER= 5;

  	@TestSetup
    private static void makeData(){
            
        List<Account> accounts = new List<Account>();
        
        Id recordTypeIdUS= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('United_States').getRecordTypeId();
        
        for(Integer i=0; i<ACCOUNTS_NUMBER; i++) {
            Account acc = new Account(Name = 'Test Account '+i, Type='Prospect', RecordTypeId=recordTypeIdUS);
            accounts.add(acc);    	
    	}
        
        insert accounts;
                
        List<Task> tasks = new List<Task>();
        for (Account acc : accounts) {
           for (Integer i = 0; i < TASKS_NUMBER; i++) { 
            Task tskCall = new Task(Subject='Call', Type='Call', WhatId=acc.Id);
            tasks.add(tskCall);
            Task tskEmail= new Task(Subject='Email', Type='Email', WhatId=acc.Id);
            tasks.add(tskEmail);
            Task tskMeeting= new Task(Subject='Meeting', Type='Meeting', WhatId=acc.Id);
            tasks.add(tskMeeting);
            Task tskOther= new Task(Subject='Other', Type='Other', WhatId=acc.Id);
            tasks.add(tskOther);

           }     
        }
        insert tasks;
        
    }
    
         
    @isTest
    private static void shouldHaveAccountsAndTasksInDatabase(){
        Assert.areEqual([SELECT count() FROM Account], ACCOUNTS_NUMBER, 'Failed to get expected amount of Accounts');
        Integer numberOfTaskTypes = 4;
        Assert.areEqual([SELECT count() FROM Task], (ACCOUNTS_NUMBER*TASKS_NUMBER*numberOfTaskTypes), 'Failed to get expected amount of tasks');
    }
    
    //insert scenario
    @isTest
    public static void insertNewTaskAccount() {
       Account account = [Select Id from Account where Name='Test Account 0' LIMIT 1];
       Id accId = account.Id;
        
       Task tskOther= new Task(Subject='Other', Type='Other', WhatId=accId);
       insert tskOther;
        
       Assert.areEqual([Select Open_Tasks_Other__c from Account where Id=:accId].Open_Tasks_Other__c, TASKS_NUMBER+1, 'Failed to get expected amount of open tasks on Account after insert');  
    }
    
    //close a task & re-open it scenario
    @isTest
    private static void closeTaskAndReopen() {
        //closing
        Account account = [Select Id from Account where Name='Test Account 3' LIMIT 1];
        Id accId = account.Id;
        
        Task openTsk = [Select Type, Status From Task where WhatId=:accId and Status != 'Completed' and Type='Email' Limit 1];
        openTsk.Status='Completed';
        update openTsk;
        
        Assert.areEqual([Select Open_Tasks_Email__c from Account where Id=:accId].Open_Tasks_Email__c, TASKS_NUMBER-1, 'Failed to get expected amount of open tasks on Account after closing a task');
        
        //re-opening
        openTsk.Status='In progress';
        update openTsk;
        
        Assert.areEqual([Select Open_Tasks_Email__c from Account where Id=:accId].Open_Tasks_Email__c, TASKS_NUMBER, 'Failed to get expected amount of open tasks on Account after re-opening a task');
        
        
    }
    
    //delete scenario
    @isTest
    private static void deleteTask() {
        Account account = [Select Id from Account where Name='Test Account 2' LIMIT 1];
        Id accId = account.Id;
        
        Task openTsk = [Select Type, Status From Task where WhatId=:accId and Status != 'Completed' and Type='Other' Limit 1];
         
   		Assert.areEqual([Select Open_Tasks_Other__c from Account where Id=:accId].Open_Tasks_Other__c, TASKS_NUMBER, 'Failed to get expected amount of open tasks on Account before delete');

        delete openTsk;
        
        Assert.areEqual([Select Open_Tasks_Other__c from Account where Id=:accId].Open_Tasks_Other__c, TASKS_NUMBER-1, 'Failed to get expected amount of open tasks on Account after delete');

    }
   
}