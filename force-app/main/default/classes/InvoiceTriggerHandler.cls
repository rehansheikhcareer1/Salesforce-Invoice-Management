public class InvoiceTriggerHandler {
    
    public void beforeUpdate(List<Invoice__c> newInvoices, Map<Id, Invoice__c> oldMap) {
        // Auto-update status based on payment
        for (Invoice__c invoice : newInvoices) {
            Invoice__c oldInvoice = oldMap.get(invoice.Id);
            
            // Skip if status manually changed
            if (invoice.Status__c != oldInvoice.Status__c) {
                continue;
            }
            
            // Update status based on balance
            if (invoice.Balance_Due__c == 0 && invoice.Total_Amount__c > 0) {
                invoice.Status__c = 'Paid';
            } else if (invoice.Balance_Due__c > 0 && invoice.Amount_Paid__c > 0) {
                invoice.Status__c = 'Partially Paid';
            } else if (invoice.Due_Date__c < Date.today() && invoice.Balance_Due__c > 0) {
                invoice.Status__c = 'Overdue';
            }
        }
    }
    
    public void afterUpdate(List<Invoice__c> newInvoices, Map<Id, Invoice__c> oldMap) {
        // Can add logic for notifications or other post-update actions
        Set<Id> paidInvoiceIds = new Set<Id>();
        
        for (Invoice__c invoice : newInvoices) {
            Invoice__c oldInvoice = oldMap.get(invoice.Id);
            
            // Track newly paid invoices
            if (invoice.Status__c == 'Paid' && oldInvoice.Status__c != 'Paid') {
                paidInvoiceIds.add(invoice.Id);
            }
        }
        
        // Future enhancement: Send thank you emails for paid invoices
        if (!paidInvoiceIds.isEmpty()) {
            System.debug('Invoices marked as paid: ' + paidInvoiceIds);
        }
    }
}
