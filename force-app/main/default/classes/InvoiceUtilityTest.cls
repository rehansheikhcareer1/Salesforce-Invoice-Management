@isTest
private class InvoiceUtilityTest {
    
    @TestSetup
    static void setupTestData() {
        Client__c client = new Client__c(
            Name = 'Utility Test Client',
            Email__c = 'utility@test.com',
            Status__c = 'Active'
        );
        insert client;
        
        Invoice__c invoice = new Invoice__c(
            Client__c = client.Id,
            Invoice_Date__c = Date.today().addDays(-10),
            Due_Date__c = Date.today().addDays(20),
            Tax_Rate__c = 10,
            Status__c = 'Sent'
        );
        insert invoice;
        
        Line_Item__c item = new Line_Item__c(
            Invoice__c = invoice.Id,
            Product_Name__c = 'Test Item',
            Quantity__c = 1,
            Unit_Price__c = 100
        );
        insert item;
    }
    
    @isTest
    static void testCalculateDaysUntilDue() {
        Date futureDate = Date.today().addDays(15);
        Integer days = InvoiceUtility.calculateDaysUntilDue(futureDate);
        System.assertEquals(15, days, 'Should return 15 days');
    }
    
    @isTest
    static void testIsOverdue() {
        Invoice__c invoice = [SELECT Id, Due_Date__c, Balance_Due__c, Status__c FROM Invoice__c LIMIT 1];
        
        // Not overdue yet
        Boolean result = InvoiceUtility.isOverdue(invoice);
        System.assertEquals(false, result, 'Should not be overdue');
        
        // Make it overdue
        invoice.Due_Date__c = Date.today().addDays(-5);
        update invoice;
        
        invoice = [SELECT Id, Due_Date__c, Balance_Due__c, Status__c FROM Invoice__c WHERE Id = :invoice.Id];
        result = InvoiceUtility.isOverdue(invoice);
        System.assertEquals(true, result, 'Should be overdue');
    }
    
    @isTest
    static void testGenerateInvoiceSummary() {
        Invoice__c invoice = [
            SELECT Id, Name, Invoice_Date__c, Due_Date__c, Total_Amount__c, Balance_Due__c
            FROM Invoice__c 
            LIMIT 1
        ];
        
        String summary = InvoiceUtility.generateInvoiceSummary(invoice);
        System.assert(summary.contains('Invoice'), 'Summary should contain Invoice');
        System.assert(summary.contains(invoice.Name), 'Summary should contain invoice number');
    }
    
    @isTest
    static void testMarkOverdueInvoices() {
        Invoice__c invoice = [SELECT Id, Due_Date__c FROM Invoice__c LIMIT 1];
        invoice.Due_Date__c = Date.today().addDays(-5);
        update invoice;
        
        Test.startTest();
        InvoiceUtility.markOverdueInvoices();
        Test.stopTest();
        
        Invoice__c updatedInvoice = [SELECT Status__c FROM Invoice__c WHERE Id = :invoice.Id];
        System.assertEquals('Overdue', updatedInvoice.Status__c, 'Status should be Overdue');
    }
}
