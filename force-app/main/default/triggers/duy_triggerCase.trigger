trigger duy_triggerCase on Case(
  before update,
  before insert,
  after update,
  after insert
) {
//   if (Trigger.isBefore && Trigger.isUpdate) {
//      DUY_caseTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
//   }
  if (Trigger.isAfter && Trigger.isUpdate) {
     DUY_caseTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
  }
//   if (Trigger.isBefore && Trigger.isInsert) {
    
//      DUY_caseTriggerHandler.onBeforeInsert(Trigger.new);
//   }
//   if (Trigger.isAfter && Trigger.isInsert) {
//      DUY_caseTriggerHandler.onAfterInsert(Trigger.new);
//   }
}