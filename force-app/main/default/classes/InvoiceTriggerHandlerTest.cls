@isTest
private class InvoiceTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        Client__c client = new Client__c(
            Name = 'Trigger Test Client',
            Email__c = 'trigger@test.com',
            Status__c = 'Active'
        );
        insert client;
        
        Invoice__c invoice = new Invoice__c(
            Client__c = client.Id,
            Invoice_Date__c = Date.today(),
            Due_Date__c = Date.today().addDays(30),
            Tax_Rate__c = 10,
            Status__c = 'Sent'
        );
        insert invoice;
        
        Line_Item__c item = new Line_Item__c(
            Invoice__c = invoice.Id,
            Product_Name__c = 'Test Service',
            Quantity__c = 1,
            Unit_Price__c = 1000
        );
        insert item;
    }
    
    @isTest
    static void testStatusUpdateToPartiallyPaid() {
        Invoice__c invoice = [SELECT Id, Total_Amount__c FROM Invoice__c LIMIT 1];
        
        Test.startTest();
        Payment__c payment = new Payment__c(
            Invoice__c = invoice.Id,
            Amount__c = 500,
            Payment_Date__c = Date.today(),
            Payment_Method__c = 'Cash'
        );
        insert payment;
        Test.stopTest();
        
        Invoice__c updatedInvoice = [SELECT Status__c FROM Invoice__c WHERE Id = :invoice.Id];
        System.assertEquals('Partially Paid', updatedInvoice.Status__c, 
                          'Status should be Partially Paid');
    }
    
    @isTest
    static void testStatusUpdateToPaid() {
        Invoice__c invoice = [SELECT Id, Total_Amount__c FROM Invoice__c LIMIT 1];
        
        Test.startTest();
        Payment__c payment = new Payment__c(
            Invoice__c = invoice.Id,
            Amount__c = invoice.Total_Amount__c,
            Payment_Date__c = Date.today(),
            Payment_Method__c = 'Bank Transfer'
        );
        insert payment;
        Test.stopTest();
        
        Invoice__c updatedInvoice = [SELECT Status__c, Balance_Due__c FROM Invoice__c WHERE Id = :invoice.Id];
        System.assertEquals('Paid', updatedInvoice.Status__c, 'Status should be Paid');
        System.assertEquals(0, updatedInvoice.Balance_Due__c, 'Balance should be zero');
    }
    
    @isTest
    static void testOverdueStatus() {
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];
        
        // Update due date to past
        invoice.Due_Date__c = Date.today().addDays(-5);
        
        Test.startTest();
        update invoice;
        Test.stopTest();
        
        Invoice__c updatedInvoice = [SELECT Status__c FROM Invoice__c WHERE Id = :invoice.Id];
        System.assertEquals('Overdue', updatedInvoice.Status__c, 'Status should be Overdue');
    }
}
