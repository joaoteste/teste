@isTest (SeeAllData = true)
public class ClientAppService_getNextInvoice_Test {
    
    private static Integer KEY_SIZE = 192;
    private static Integer nifCounter = 100000000;
    private static Integer NUMBER_LINE_ITEMS = 4;
    private static Integer NUMBER_CONTRACTS = 1;
    private static String taxZone = 'Mainland';
    private static String testUsername = 'email@mail.com';
    private static String testPass = '12345';
    
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    
    private static Contact testContact;
    
    private static Account testClient;
    private static Account testVendor;
    
    private static Login__c testLogin;
    private static Session__c testSession;
    
    private static Application__c testApp;
    private static List<Billing_Contract__c> testContracts;
    private static List<Billing_Contract_Line_Item__c> testLineItems;
    private static List<c2g__codaInvoice__c> testInvoices;

    //implicit success test for validateSession() because it only returns info if session is valid
    static testMethod void shouldReturnInvoiceDetails(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testContracts = ClientAppService_TestUtils.createContractsForRentingApp(testApp, testClient, testVendor, NUMBER_CONTRACTS);
        testLineItems = ClientAppService_TestUtils.createLineItemsForBillingContract(testContracts.get(0), testApp, NUMBER_LINE_ITEMS);
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getNextInvoiceDetails(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('invoiceDetails'), 'returned JSON doesnt contain invoiceDetails');
        List<Object> lis = (List<Object>) dataMap.get('invoiceDetails');
        system.assertEquals(testContracts.size(), lis.size(), 'returned JSON has incorrect number of invoices');
    }
    
    static testMethod void shouldFailNoContracts(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getNextInvoiceDetails(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('NO_CONTRACTS_FOUND', dataMap.get('errorCode'), 'returned JSON has incorrect status');
    }
}