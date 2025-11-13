trigger PaymentTrigger on Payment__c (after insert, after update, after delete) {
    PaymentTriggerHandler handler = new PaymentTriggerHandler();
    
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.new);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isAfter && Trigger.isDelete) {
        handler.afterDelete(Trigger.old);
    }
}
