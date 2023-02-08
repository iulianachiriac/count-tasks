trigger Count on Task(after insert, after update, after delete) {
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      TaskTriggerHandler.handleAfterInsert(Trigger.new);
    } else if (Trigger.isUpdate) {
      TaskTriggerHandler.handleAfterUpdate(Trigger.old,Trigger.new);
    } else if (Trigger.isDelete) {
      TaskTriggerHandler.handleAfterDelete(Trigger.old);
    }
  }
}