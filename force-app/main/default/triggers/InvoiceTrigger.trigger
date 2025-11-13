trigger InvoiceTrigger on Invoice__c (before update, after update) {
    InvoiceTriggerHandler handler = new InvoiceTriggerHandler();
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        handler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
