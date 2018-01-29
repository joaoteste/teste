@isTest (SeeAllData = true)
public class ClientAppService_getContracts_Test {
    
    private static Integer KEY_SIZE = 192;
    private static Integer nifCounter = 100000000;
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

    //implicit success test for validateSession() because it only returns info if session is valid
    static testMethod void shouldReturnContractsInfo(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testContracts = ClientAppService_TestUtils.createContractsForRentingApp(testApp, testClient, testVendor, 2);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getContractsInfo(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('contracts'), 'returned JSON doesnt contain contracts');
        
        List<Object> contracts = (List<Object>) dataMap.get('contracts');
        system.assertEquals(testContracts.size(), contracts.size(), 'returned JSON has incorrect number of contracts');
    }
}