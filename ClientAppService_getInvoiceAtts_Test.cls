@isTest (SeeAllData = true)
public class ClientAppService_getInvoiceAtts_Test {
    
    private static Integer KEY_SIZE = 192;
    private static Integer nifCounter = 100000000;
    private static String taxZone = 'Mainland';
    private static String testUsername = 'email@mail.com';
    private static String testPass = '12345';
    
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    private static String typeOther = 'Other';
    
    private static String attachName = 'Amazing Attachment';
    
    private static Contact testContact;
    
    private static Account testClient;
    private static Account testVendor;
    
    private static Login__c testLogin;
    private static Session__c testSession;
    
    private static Application__c testApp;
    private static c2g__codaInvoice__c testInvoice;
    private static Attachment testAtt;

    //implicit success test for validateSession() because it only returns info if session is valid
    static testMethod void shouldReturnInvoiceAttachments(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        
        List<Product2> InvoiceLineItems = new List<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'Pagamento por Multibanco';
        p1.ProductCode = 'PT03';
        Product2 p2 = new Product2();
        p2.Name = 'Despesas Relacionadas com Alterações ao Contrato';
        p2.ProductCode = 'PT16';
        InvoiceLineItems.add(p1);
        InvoiceLineItems.add(p2);
        insert InvoiceLineItems;
        
        testInvoice = ClientAppService_TestUtils.createInvoice(testApp, testClient, null, taxZone, InvoiceLineItems, null);
        testAtt = ClientAppService_TestUtils.createAttachment(testInvoice.Id, attachName);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getInvoiceAttachments(testSession.token__c, testInvoice.Id));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('invoiceAttachments'), 'returned JSON doesnt contain invoiceAttachments');
        
        List<Object> invoices = (List<Object>) dataMap.get('invoiceAttachments');
        system.assertEquals(1, invoices.size(), 'returned JSON has incorrect number of invoiceAttachments');
    }
    
    static testMethod void shouldFailNoInvoiceAttachment(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        
        List<Product2> InvoiceLineItems = new List<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'Pagamento por Multibanco';
        p1.ProductCode = 'PT03';
        Product2 p2 = new Product2();
        p2.Name = 'Despesas Relacionadas com Alterações ao Contrato';
        p2.ProductCode = 'PT16';
        InvoiceLineItems.add(p1);
        InvoiceLineItems.add(p2);
        insert InvoiceLineItems;
        
        testInvoice = ClientAppService_TestUtils.createInvoice(testApp, testClient, null, taxZone, InvoiceLineItems, null);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getInvoiceAttachments(testSession.token__c, testInvoice.Id));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('NO_INVOICE_ATT_FOUND', dataMap.get('errorCode'), 'returned JSON has incorrect errorMessage');
    }
}