public class InvoiceUtility {
    
    // Calculate days until due
    public static Integer calculateDaysUntilDue(Date dueDate) {
        if (dueDate == null) {
            return 0;
        }
        return Date.today().daysBetween(dueDate);
    }
    
    // Check if invoice is overdue
    public static Boolean isOverdue(Invoice__c invoice) {
        return invoice.Due_Date__c < Date.today() && 
               invoice.Balance_Due__c > 0 &&
               invoice.Status__c != 'Paid' &&
               invoice.Status__c != 'Cancelled';
    }
    
    // Generate invoice summary
    public static String generateInvoiceSummary(Invoice__c invoice) {
        String summary = 'Invoice ' + invoice.Name + '\n';
        summary += 'Date: ' + invoice.Invoice_Date__c.format() + '\n';
        summary += 'Due: ' + invoice.Due_Date__c.format() + '\n';
        summary += 'Total: $' + invoice.Total_Amount__c + '\n';
        summary += 'Balance: $' + invoice.Balance_Due__c;
        return summary;
    }
    
    // Batch update overdue invoices
    public static void markOverdueInvoices() {
        List<Invoice__c> overdueInvoices = [
            SELECT Id, Status__c
            FROM Invoice__c
            WHERE Due_Date__c < TODAY
            AND Balance_Due__c > 0
            AND Status__c NOT IN ('Paid', 'Cancelled', 'Overdue')
        ];
        
        for (Invoice__c inv : overdueInvoices) {
            inv.Status__c = 'Overdue';
        }
        
        if (!overdueInvoices.isEmpty()) {
            update overdueInvoices;
        }
    }
}
