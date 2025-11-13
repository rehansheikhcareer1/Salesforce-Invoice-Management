public with sharing class InvoiceController {
    
    @AuraEnabled(cacheable=true)
    public static List<Invoice__c> getClientInvoices(Id clientId) {
        try {
            return [
                SELECT Id, Name, Invoice_Date__c, Due_Date__c, Status__c,
                       Subtotal__c, Tax_Amount__c, Total_Amount__c, 
                       Amount_Paid__c, Balance_Due__c
                FROM Invoice__c
                WHERE Client__c = :clientId
                ORDER BY Invoice_Date__c DESC
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching invoices: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Invoice__c getInvoiceDetails(Id invoiceId) {
        try {
            return [
                SELECT Id, Name, Invoice_Date__c, Due_Date__c, Status__c,
                       Subtotal__c, Tax_Rate__c, Tax_Amount__c, Total_Amount__c,
                       Amount_Paid__c, Balance_Due__c, Client__c, Client__r.Name,
                       Client__r.Email__c, Client__r.Phone__c, Client__r.Billing_Address__c,
                       (SELECT Id, Product_Name__c, Description__c, Quantity__c, 
                               Unit_Price__c, Total_Price__c 
                        FROM Line_Items__r)
                FROM Invoice__c
                WHERE Id = :invoiceId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching invoice details: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id createInvoiceWithLineItems(Id clientId, Date dueDate, 
                                                 Decimal taxRate, 
                                                 List<Map<String, Object>> lineItems) {
        Savepoint sp = Database.setSavepoint();
        try {
            // Create invoice
            Invoice__c invoice = new Invoice__c(
                Client__c = clientId,
                Invoice_Date__c = Date.today(),
                Due_Date__c = dueDate,
                Tax_Rate__c = taxRate,
                Status__c = 'Draft'
            );
            insert invoice;
            
            // Create line items
            List<Line_Item__c> items = new List<Line_Item__c>();
            for (Map<String, Object> item : lineItems) {
                items.add(new Line_Item__c(
                    Invoice__c = invoice.Id,
                    Product_Name__c = (String)item.get('productName'),
                    Description__c = (String)item.get('description'),
                    Quantity__c = (Decimal)item.get('quantity'),
                    Unit_Price__c = (Decimal)item.get('unitPrice')
                ));
            }
            
            if (!items.isEmpty()) {
                insert items;
            }
            
            return invoice.Id;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('Error creating invoice: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateInvoiceStatus(Id invoiceId, String newStatus) {
        try {
            Invoice__c invoice = new Invoice__c(
                Id = invoiceId,
                Status__c = newStatus
            );
            update invoice;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating invoice status: ' + e.getMessage());
        }
    }
}
