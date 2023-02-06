trigger Count on Task(after insert, after update, after delete) {
  if (Trigger.isAfter) {
    if (Trigger.isInsert || Trigger.isUpdate) {
      TaskTriggerHandler.updateRelatedAccounts(Trigger.new);
    } else if (Trigger.isDelete) {
      TaskTriggerHandler.updateRelatedAccounts(Trigger.old);
    }
  }
}
