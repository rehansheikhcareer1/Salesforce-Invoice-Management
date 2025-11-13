public with sharing class PaymentController {
    
    @AuraEnabled(cacheable=true)
    public static List<Payment__c> getInvoicePayments(Id invoiceId) {
        try {
            return [
                SELECT Id, Name, Amount__c, Payment_Date__c, 
                       Payment_Method__c, Notes__c
                FROM Payment__c
                WHERE Invoice__c = :invoiceId
                ORDER BY Payment_Date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching payments: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id recordPayment(Id invoiceId, Decimal amount, 
                                    Date paymentDate, String paymentMethod, 
                                    String notes) {
        try {
            // Validate payment amount
            Invoice__c invoice = [
                SELECT Balance_Due__c 
                FROM Invoice__c 
                WHERE Id = :invoiceId 
                LIMIT 1
            ];
            
            if (amount > invoice.Balance_Due__c) {
                throw new AuraHandledException('Payment amount cannot exceed balance due');
            }
            
            // Create payment record
            Payment__c payment = new Payment__c(
                Invoice__c = invoiceId,
                Amount__c = amount,
                Payment_Date__c = paymentDate,
                Payment_Method__c = paymentMethod,
                Notes__c = notes
            );
            insert payment;
            
            return payment.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error recording payment: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getPaymentSummary(Id clientId) {
        try {
            List<Invoice__c> invoices = [
                SELECT Total_Amount__c, Amount_Paid__c, Balance_Due__c
                FROM Invoice__c
                WHERE Client__c = :clientId
            ];
            
            Decimal totalBilled = 0;
            Decimal totalPaid = 0;
            Decimal totalOutstanding = 0;
            
            for (Invoice__c inv : invoices) {
                totalBilled += inv.Total_Amount__c != null ? inv.Total_Amount__c : 0;
                totalPaid += inv.Amount_Paid__c != null ? inv.Amount_Paid__c : 0;
                totalOutstanding += inv.Balance_Due__c != null ? inv.Balance_Due__c : 0;
            }
            
            return new Map<String, Decimal>{
                'totalBilled' => totalBilled,
                'totalPaid' => totalPaid,
                'totalOutstanding' => totalOutstanding
            };
        } catch (Exception e) {
            throw new AuraHandledException('Error calculating payment summary: ' + e.getMessage());
        }
    }
}
