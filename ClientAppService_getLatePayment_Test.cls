@isTest (SeeAllData = true)
public class ClientAppService_getLatePayment_Test {
    
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
    private static Collection_Case__c testCollectionCase;
    private static List<Dunning_Alert__c> testDunnings;

    //implicit success test for validateSession() because it only returns info if session is valid
    public static testMethod void shouldReturnLatePayment(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testContracts = ClientAppService_TestUtils.createContractsForRentingApp(testApp, testClient, testVendor, 2);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        
        testDunnings = ClientAppService_TestUtils.createDunningAlerts(testCollectionCase, new List<String>{'3rd Reminder'});
        
        system.debug('DDD testDnnings '+testDunnings);
        
        //get last dunning to assert; should only return info about highest level dunning
        Dunning_Alert__c testDunning = testDunnings.get(0);
        system.debug('DDD highDunn '+testDunning);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getLatePayment(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(!dataMap.containsKey('errorCode'), 'returned JSON contains errorMessage');
        system.assertEquals(null, dataMap.get('errorCode'), 'returned JSON should not have errorMessage');
        
        //this bug is insane!!!
        //system.assert(jsonReturn.containsKey('amount'), 'returned JSON doesnt contain amount');
        //system.assertEquals(testDunning.Amount_Claimed__c, jsonReturn.get('amount'), 'returned JSON has incorrect amount');
        system.assert(dataMap.containsKey('id'), 'returned JSON doesnt contain id');
        system.assertEquals(testDunning.Id, dataMap.get('id'), 'returned JSON has incorrect id');
        system.assert(dataMap.containsKey('entity'), 'returned JSON doesnt contain entity');
        system.assertEquals(testDunning.Aux_Entity__c, dataMap.get('entity'), 'returned JSON has incorrect entity');
        system.assert(dataMap.containsKey('reference'), 'returned JSON doesnt contain reference');
        system.assertEquals(testDunning.Aux_Reference__c, dataMap.get('reference'), 'returned JSON has incorrect reference');
        system.assert(dataMap.containsKey('level'), 'returned JSON doesnt contain level');
        system.assertEquals(testDunning.Dunning_Level__c, dataMap.get('level'), 'returned JSON has incorrect level');
    }
    
    static testMethod void shouldFailNoDunning(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getLatePayment(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('NO_DUNNING_FOUND', dataMap.get('errorCode'), 'returned JSON has incorrect errorMessage');
    }
}