@isTest
private class PaymentTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        Client__c client = new Client__c(
            Name = 'Payment Handler Test',
            Email__c = 'handler@test.com',
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
            Product_Name__c = 'Consulting',
            Quantity__c = 10,
            Unit_Price__c = 100
        );
        insert item;
    }
    
    @isTest
    static void testPaymentInsertUpdatesInvoice() {
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];
        
        Test.startTest();
        Payment__c payment = new Payment__c(
            Invoice__c = invoice.Id,
            Amount__c = 550,
            Payment_Date__c = Date.today(),
            Payment_Method__c = 'Check'
        );
        insert payment;
        Test.stopTest();
        
        Invoice__c updatedInvoice = [SELECT Status__c FROM Invoice__c WHERE Id = :invoice.Id];
        System.assertEquals('Partially Paid', updatedInvoice.Status__c, 
                          'Invoice should be partially paid');
    }
    
    @isTest
    static void testPaymentUpdateRecalculates() {
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];
        
        Payment__c payment = new Payment__c(
            Invoice__c = invoice.Id,
            Amount__c = 500,
            Payment_Date__c = Date.today(),
            Payment_Method__c = 'Cash'
        );
        insert payment;
        
        Test.startTest();
        payment.Amount__c = 1100;
        update payment;
        Test.stopTest();
        
        Invoice__c updatedInvoice = [SELECT Status__c FROM Invoice__c WHERE Id = :invoice.Id];
        System.assertEquals('Paid', updatedInvoice.Status__c, 'Invoice should be fully paid');
    }
    
    @isTest
    static void testPaymentDeleteRecalculates() {
        Invoice__c invoice = [SELECT Id, Total_Amount__c FROM Invoice__c LIMIT 1];
        
        Payment__c payment = new Payment__c(
            Invoice__c = invoice.Id,
            Amount__c = invoice.Total_Amount__c,
            Payment_Date__c = Date.today(),
            Payment_Method__c = 'Bank Transfer'
        );
        insert payment;
        
        Test.startTest();
        delete payment;
        Test.stopTest();
        
        Invoice__c updatedInvoice = [SELECT Status__c, Balance_Due__c FROM Invoice__c WHERE Id = :invoice.Id];
        System.assertNotEquals('Paid', updatedInvoice.Status__c, 'Invoice should not be paid');
        System.assertEquals(updatedInvoice.Balance_Due__c, invoice.Total_Amount__c, 
                          'Balance should equal total');
    }
}
