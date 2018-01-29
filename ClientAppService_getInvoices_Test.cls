@isTest (SeeAllData = true)
public class ClientAppService_getInvoices_Test {
    
    private static Integer KEY_SIZE = 192;
    private static Integer NUMBER_INVOICES = 4;
    private static Integer nifCounter = 100000000;
    private static String taxZone = 'Mainland';
    private static String testUsername = 'email@mail.com';
    private static String testPass = '12345';
    
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    private static String typeOther = 'Other';
    
    private static Contact testContact;
    
    private static Account testClient;
    private static Account testVendor;
    
    private static Login__c testLogin;
    private static Session__c testSession;
    
    private static Application__c testApp;
    private static List<Billing_Contract__c> testContracts;
    private static Collection_Case__c testCollectionCase;
    private static List<c2g__codaInvoice__c> testInvoices;

    //implicit success test for validateSession() because it only returns info if session is valid
    static testMethod void shouldReturnInvoices(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testContracts = ClientAppService_TestUtils.createContractsForRentingApp(testApp, testClient, testVendor, 2);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        
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
        
        testInvoices = new List<c2g__codaInvoice__c>();
        for(Integer i=0; i<NUMBER_INVOICES; i++){
            testInvoices.add(ClientAppService_TestUtils.createInvoice(testApp, testClient, testCollectionCase, taxZone, InvoiceLineItems, null));
        }
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getInvoices(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('invoices'), 'returned JSON doesnt contain invoices');
        
        List<Object> invoices = (List<Object>) dataMap.get('invoices');
        system.assertEquals(testInvoices.size(), invoices.size(), 'returned JSON has incorrect number of invoices');
    }
    
    static testMethod void shouldReturnInvoicesByContract(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testContracts = ClientAppService_TestUtils.createContractsForRentingApp(testApp, testClient, testVendor, 2);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        
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
        
        testInvoices = new List<c2g__codaInvoice__c>();
        for(Integer i=0; i<NUMBER_INVOICES; i++){
            testInvoices.add(ClientAppService_TestUtils.createInvoice(testApp, testClient, testCollectionCase, taxZone, InvoiceLineItems, testContracts.get(0)));
        }
        
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        args.put('contractId', testContracts.get(0).Id);
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getInvoices(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('invoices'), 'returned JSON doesnt contain invoices');
        
        List<Object> invoices = (List<Object>) dataMap.get('invoices');
        system.assertEquals(testInvoices.size(), invoices.size(), 'returned JSON has incorrect number of invoices');
    }
    
}