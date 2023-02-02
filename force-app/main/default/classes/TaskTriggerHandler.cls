public class TaskTriggerHandler {

    public static void updateRelatedAccounts(List<Task> tasks){
        
      Set<Id> accIds = new Set<Id>();
  	  for (Task task : tasks){
          if (task.whatId !=null && String.valueOf(task.whatId).startsWith('001')) {
              accIds.add(task.whatId);
          }
      }
        
      if (accIds.size() > 0){
    
         Map<Id,Account> accountMap = new Map<Id,Account>();
      
         Id recordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('United_States').getRecordTypeId();
         
         List<Account> accountsList = [Select Id, Open_Tasks_Call__c, Open_Tasks_Email__c, 
                             Open_Tasks_Meeting__c, Open_Tasks_Other__c, RecordTypeId,
                            (Select WhatId, Type from Tasks Where isClosed=false)
                             from Account where Id IN :accIds and RecordTypeId=:recordTypeId and Type='Prospect'];
        
         for (Account acc : accountsList) {
                 Decimal callTasks =  0;
                 Decimal emailTasks = 0;
                 Decimal meetingTasks = 0;
                 Decimal otherTasks=0;
               
                for (Task t : acc.Tasks) {
                    if (t.whatId == acc.Id) {
                        if (t.type == 'Call') {
                           callTasks++;
                        } else if (t.type =='Email'){
                            emailTasks++;                   
                        } else if (t.type =='Meeting'){
                            meetingTasks++;
                        } else {
                            otherTasks++;
                        }
                        
                    }
                }
                
                acc.Open_Tasks_Call__c=callTasks;
                acc.Open_Tasks_Email__c=emailTasks;
                acc.Open_Tasks_Meeting__c=meetingTasks;
                acc.Open_Tasks_Other__c=otherTasks;
             
                accountMap.put(acc.Id,acc);

            }
        
        	update accountMap.values();
        
        
    	}
    }
}