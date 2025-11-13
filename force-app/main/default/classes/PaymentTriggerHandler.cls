public class PaymentTriggerHandler {
    
    public void afterInsert(List<Payment__c> newPayments) {
        updateInvoiceStatus(newPayments);
    }
    
    public void afterUpdate(List<Payment__c> newPayments, Map<Id, Payment__c> oldMap) {
        List<Payment__c> changedPayments = new List<Payment__c>();
        
        for (Payment__c payment : newPayments) {
            Payment__c oldPayment = oldMap.get(payment.Id);
            if (payment.Amount__c != oldPayment.Amount__c) {
                changedPayments.add(payment);
            }
        }
        
        if (!changedPayments.isEmpty()) {
            updateInvoiceStatus(changedPayments);
        }
    }
    
    public void afterDelete(List<Payment__c> oldPayments) {
        updateInvoiceStatus(oldPayments);
    }
    
    private void updateInvoiceStatus(List<Payment__c> payments) {
        Set<Id> invoiceIds = new Set<Id>();
        
        for (Payment__c payment : payments) {
            invoiceIds.add(payment.Invoice__c);
        }
        
        if (!invoiceIds.isEmpty()) {
            // Query invoices to recalculate
            List<Invoice__c> invoicesToUpdate = [
                SELECT Id, Total_Amount__c, Amount_Paid__c, Balance_Due__c, 
                       Status__c, Due_Date__c
                FROM Invoice__c
                WHERE Id IN :invoiceIds
            ];
            
            // Trigger will handle status update
            update invoicesToUpdate;
        }
    }
}
