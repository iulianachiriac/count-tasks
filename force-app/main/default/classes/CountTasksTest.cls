@isTest
public class CountTasksTest {
    /*Apex Test Class for all scenarios(insert, update, delete, close task, re open task)*/

    private static final Integer numberOfAccounts = 5;
    private static final Integer numberOfTasks = 5;

  	@TestSetup
    private static void makeData(){
            
        List<Account> accounts = new List<Account>();
        
        Id recordTypeIdUS= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('United_States').getRecordTypeId();
        
        for(Integer i=0; i<numberOfAccounts; i++) {
            Account acc = new Account(Name = 'Test Account '+i, Type='Prospect', RecordTypeId=recordTypeIdUS);
            accounts.add(acc);    	
    	}
        
        insert accounts;
        
        
        List<Task> tasks = new List<Task>();
        for (Account acc : accounts) {
           for (Integer i = 0; i < numberOfTasks; i++) { 
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
        Assert.areEqual([SELECT count() FROM Account], numberOfAccounts, 'Failed to get expected amount of Accounts');
        Integer numberOfTaskTypes = 4;
        Assert.areEqual([SELECT count() FROM Task], numberOfAccounts*numberofTasks*numberOfTaskTypes, 'Failed to get expected amount of tasks');
    }
    
    //insert scenario
    @isTest
    public static void insertNewTaskAccount() {
       Account account = [Select Id from Account where Name='Test Account 0' LIMIT 1];
       Id accId = account.Id;
        
       Task tskOther= new Task(Subject='Other', Type='Other', WhatId=accId);
       insert tskOther;
        
       Decimal openOtherTasksOnAccount = [Select Open_Tasks_Other__c from Account where Id=:accId].Open_Tasks_Other__c;
       System.assertEquals(6, openOtherTasksOnAccount, 'Number of open OTHER tasks should be: ' + 6);
      
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
        
        Decimal openEmailTasksOnAccount = [Select Open_Tasks_Email__c from Account where Id=:accId].Open_Tasks_Email__c;
   
        System.assertEquals(4, openEmailTasksOnAccount, 'Number of open EMAIL tasks should be: ' + 4);
        
        //re-opening
        openTsk.Status='In progress';
        update openTsk;
        
        openEmailTasksOnAccount = [Select Open_Tasks_Email__c from Account where Id=:accId].Open_Tasks_Email__c;
        System.assertEquals(5, openEmailTasksOnAccount, 'Number of open EMAIL tasks should be: ' + 5);
        
    }
    
    //delete scenario
    @isTest
    private static void deleteTask() {
        Account account = [Select Id from Account where Name='Test Account 2' LIMIT 1];
        Id accId = account.Id;
        
        Task openTsk = [Select Type, Status From Task where WhatId=:accId and Status != 'Completed' and Type='Other' Limit 1];
         
		Decimal openOtherTasksOnAccount = [Select Open_Tasks_Other__c from Account where Id=:accId].Open_Tasks_Other__c;
   		System.assertEquals(5, openOtherTasksOnAccount, 'Number of open Other tasks before delete should be: ' + 5);
        
        delete openTsk;
                
        openOtherTasksOnAccount = [Select Open_Tasks_Other__c from Account where Id=:accId].Open_Tasks_Other__c;
        System.assertEquals(4, openOtherTasksOnAccount, 'Number of open Other Tasks after delete should be: ' + 4);
        
    }
   
   
    
}