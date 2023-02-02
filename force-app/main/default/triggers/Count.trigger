trigger Count on Task (after insert, after update, after delete) {
     
    if (trigger.isAfter){
		if( trigger.isInsert || trigger.isUpdate) 
		{
		 	TaskTriggerHandler.updateRelatedAccounts(Trigger.new);
        } else if (trigger.isDelete) {
            TaskTriggerHandler.updateRelatedAccounts(Trigger.old);
        }
	}
}