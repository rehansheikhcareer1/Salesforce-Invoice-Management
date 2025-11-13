@isTest
private class InvoiceControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test client
        Client__c client = new Client__c(
            Name = 'Test Client',
            Email__c = 'test@example.com',
            Phone__c = '1234567890',
            Company__c = 'Test Company',
            Status__c = 'Active'
        );
        insert client;
        
        // Create test invoice
        Invoice__c invoice = new Invoice__c(
            Client__c = client.Id,
            Invoice_Date__c = Date.today(),
            Due_Date__c = Date.today().addDays(30),
            Tax_Rate__c = 10,
            Status__c = 'Draft'
        );
        insert invoice;
        
        // Create test line items
        List<Line_Item__c> items = new List<Line_Item__c>();
        items.add(new Line_Item__c(
            Invoice__c = invoice.Id,
            Product_Name__c = 'Product 1',
            Description__c = 'Test product',
            Quantity__c = 2,
            Unit_Price__c = 100
        ));
        items.add(new Line_Item__c(
            Invoice__c = invoice.Id,
            Product_Name__c = 'Product 2',
            Quantity__c = 1,
            Unit_Price__c = 50
        ));
        insert items;
    }
    
    @isTest
    static void testGetClientInvoices() {
        Client__c client = [SELECT Id FROM Client__c LIMIT 1];
        
        Test.startTest();
        List<Invoice__c> invoices = InvoiceController.getClientInvoices(client.Id);
        Test.stopTest();
        
        System.assertEquals(1, invoices.size(), 'Should return one invoice');
        System.assertNotEquals(null, invoices[0].Total_Amount__c, 'Total amount should be calculated');
    }
    
    @isTest
    static void testGetInvoiceDetails() {
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];
        
        Test.startTest();
        Invoice__c result = InvoiceController.getInvoiceDetails(invoice.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Invoice should be returned');
        System.assertEquals(2, result.Line_Items__r.size(), 'Should have 2 line items');
    }
    
    @isTest
    static void testCreateInvoiceWithLineItems() {
        Client__c client = [SELECT Id FROM Client__c LIMIT 1];
        
        List<Map<String, Object>> lineItems = new List<Map<String, Object>>();
        Map<String, Object> item1 = new Map<String, Object>{
            'productName' => 'New Product',
            'description' => 'Test description',
            'quantity' => 3,
            'unitPrice' => 75.50
        };
        lineItems.add(item1);
        
        Test.startTest();
        Id invoiceId = InvoiceController.createInvoiceWithLineItems(
            client.Id, 
            Date.today().addDays(15), 
            8.5, 
            lineItems
        );
        Test.stopTest();
        
        System.assertNotEquals(null, invoiceId, 'Invoice should be created');
        
        Invoice__c createdInvoice = [
            SELECT Id, Tax_Rate__c, (SELECT Id FROM Line_Items__r)
            FROM Invoice__c 
            WHERE Id = :invoiceId
        ];
        System.assertEquals(8.5, createdInvoice.Tax_Rate__c, 'Tax rate should match');
        System.assertEquals(1, createdInvoice.Line_Items__r.size(), 'Should have 1 line item');
    }
    
    @isTest
    static void testUpdateInvoiceStatus() {
        Invoice__c invoice = [SELECT Id, Status__c FROM Invoice__c LIMIT 1];
        
        Test.startTest();
        InvoiceController.updateInvoiceStatus(invoice.Id, 'Sent');
        Test.stopTest();
        
        Invoice__c updatedInvoice = [SELECT Status__c FROM Invoice__c WHERE Id = :invoice.Id];
        System.assertEquals('Sent', updatedInvoice.Status__c, 'Status should be updated');
    }
    
    @isTest
    static void testErrorHandling() {
        Test.startTest();
        try {
            InvoiceController.getInvoiceDetails(null);
            System.assert(false, 'Should throw exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error'), 'Should contain error message');
        }
        Test.stopTest();
    }
}
