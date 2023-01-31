trigger Count on Task (after insert, after update, after delete) {
  
    
      Set<Id> accIds = new Set<Id>();
        if (trigger.isInsert) {
            for (Task task : Trigger.new){
                if (task.whatId !=null && String.valueOf(task.whatId).startsWith('001')) {
                    accIds.add(task.whatId);
                }
            }
        } else if (trigger.isUpdate) {
            for (Task task : Trigger.new){
                if (task.whatId !=null && String.valueOf(task.whatId).startsWith('001')) {
                    accIds.add(task.whatId);
                }
            }
        } else if (trigger.isDelete) {
            for (Task task : Trigger.old){
                if (task.whatId !=null && String.valueOf(task.whatId).startsWith('001')) {
                    accIds.add(task.whatId);
                }
            }
        }
        
    if (accIds.size() > 0){
    
         Map<Id,Account> accountMap = new Map<Id,Account>();
            
         Id recordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('United_States').getRecordTypeId();
         
         List<Account> accountsList = [Select Id,Name, Open_Tasks_Call__c, Open_Tasks_Email__c, 
                             Open_Tasks_Meeting__c, Open_Tasks_Other__c, RecordTypeId,
							(Select WhatId, Type from Tasks Where isClosed=false)
                             from Account where RecordTypeId=:recordTypeId and Type='Prospect'];
        
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