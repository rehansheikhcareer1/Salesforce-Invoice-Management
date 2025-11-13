@isTest
private class PaymentControllerTest {
    
    @TestSetup
    static void setupTestData() {
        Client__c client = new Client__c(
            Name = 'Payment Test Client',
            Email__c = 'payment@test.com',
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
            Product_Name__c = 'Service',
            Quantity__c = 1,
            Unit_Price__c = 1000
        );
        insert item;
        
        Payment__c payment = new Payment__c(
            Invoice__c = invoice.Id,
            Amount__c = 500,
            Payment_Date__c = Date.today(),
            Payment_Method__c = 'Bank Transfer'
        );
        insert payment;
    }
    
    @isTest
    static void testGetInvoicePayments() {
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];
        
        Test.startTest();
        List<Payment__c> payments = PaymentController.getInvoicePayments(invoice.Id);
        Test.stopTest();
        
        System.assertEquals(1, payments.size(), 'Should return one payment');
        System.assertEquals(500, payments[0].Amount__c, 'Payment amount should be 500');
    }
    
    @isTest
    static void testRecordPayment() {
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];
        
        Test.startTest();
        Id paymentId = PaymentController.recordPayment(
            invoice.Id,
            300,
            Date.today(),
            'Credit Card',
            'Partial payment'
        );
        Test.stopTest();
        
        System.assertNotEquals(null, paymentId, 'Payment should be created');
        
        Payment__c payment = [SELECT Amount__c, Payment_Method__c FROM Payment__c WHERE Id = :paymentId];
        System.assertEquals(300, payment.Amount__c, 'Amount should match');
        System.assertEquals('Credit Card', payment.Payment_Method__c, 'Method should match');
    }
    
    @isTest
    static void testRecordPaymentExceedsBalance() {
        Invoice__c invoice = [SELECT Id, Balance_Due__c FROM Invoice__c LIMIT 1];
        
        Test.startTest();
        try {
            PaymentController.recordPayment(
                invoice.Id,
                invoice.Balance_Due__c + 100,
                Date.today(),
                'Cash',
                'Overpayment attempt'
            );
            System.assert(false, 'Should throw exception for overpayment');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('exceed'), 'Should contain exceed message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetPaymentSummary() {
        Client__c client = [SELECT Id FROM Client__c LIMIT 1];
        
        Test.startTest();
        Map<String, Decimal> summary = PaymentController.getPaymentSummary(client.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, summary, 'Summary should be returned');
        System.assert(summary.containsKey('totalBilled'), 'Should contain totalBilled');
        System.assert(summary.containsKey('totalPaid'), 'Should contain totalPaid');
        System.assert(summary.containsKey('totalOutstanding'), 'Should contain totalOutstanding');
        System.assertEquals(500, summary.get('totalPaid'), 'Total paid should be 500');
    }
}
