@isTest (SeeAllData = true)
public class ClientAppService_getAccountInfo_Test {
    
    private static Integer KEY_SIZE = 192;
    private static Integer nifCounter = 100000000;
    private static String testUsername = 'email@mail.com';
    private static String testPass = '12345';
    
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    private static String typeOther = 'Other';
    
    private static Contact testContact;
    private static Account testParent;
    private static Account testClient;
    private static Login__c testLogin;
    private static Session__c testSession;

    //implicit success test for validateSession() because it only returns info if session is valid
    static testMethod void shouldReturnAccountInfo(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testParent = ClientAppService_TestUtils.getParentAccount(testClient);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getCurrentAccountInfo(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('accountId'), 'returned JSON doesnt contain accountId');
        system.assertEquals(testClient.Id, dataMap.get('accountId'), 'returned JSON has incorrect accountId');
        system.assert(dataMap.containsKey('creditLine'), 'returned JSON doesnt contain creditLine');
        system.assertEquals(testClient.Credit_line__c, dataMap.get('creditLine'), 'returned JSON has incorrect creditLine');
        system.assert(dataMap.containsKey('availableCredit'), 'returned JSON doesnt contain availableCredit');
        system.assertEquals(testClient.Available_Credit_Line__c, dataMap.get('availableCredit'), 'returned JSON has incorrect availableCredit');
        system.assert(dataMap.containsKey('usedCredit'), 'returned JSON doesnt contain usedCredit');
        system.assertEquals(testClient.Used_credit_line__c, dataMap.get('usedCredit'), 'returned JSON has incorrect usedCredit');
    }
}