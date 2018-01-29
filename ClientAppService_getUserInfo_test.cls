@isTest (SeeAllData = true)
public class ClientAppService_getUserInfo_test {
    
    private static Integer KEY_SIZE = 192;
    private static Integer nifCounter = 100000000;
    private static String testUsername = 'email@mail.com';
    private static String testPass = '12345';
    
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    private static String typeOther = 'Other';
    
    private static Contact testContact;
    private static Account testClient;
    private static Login__c testLogin;
    private static Session__c testSession;

    //implicit success test for validateSession() because it only returns info if session is valid
    static testMethod void shouldReturnUserInfo(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getCurrentUserInfo(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('loginId'), 'returned JSON doesnt contain loginId');
        system.assertEquals(testLogin.Id, dataMap.get('loginId'), 'returned JSON has incorrect loginId');
        system.assert(dataMap.containsKey('contactId'), 'returned JSON doesnt contain contactId');
        system.assertEquals(testContact.Id, dataMap.get('contactId'), 'returned JSON has incorrect contactId');
        system.assert(dataMap.containsKey('accountId'), 'returned JSON doesnt contain accountId');
        system.assertEquals(testClient.Id, dataMap.get('accountId'), 'returned JSON has incorrect accountId');
        system.assert(dataMap.containsKey('username'), 'returned JSON doesnt contain username');
        system.assertEquals(testLogin.Username__c, dataMap.get('username'), 'returned JSON has incorrect username');
        system.assert(dataMap.containsKey('name'), 'returned JSON doesnt contain name');
        //just salesforce things....
        Contact aux = [SELECT Name FROM Contact WHERE Id =:testContact.Id];
        system.assertEquals(aux.Name, dataMap.get('name'), 'returned JSON has incorrect name');
        system.assert(dataMap.containsKey('accountName'), 'returned JSON doesnt contain accountName');
        system.assertEquals(testClient.Name, dataMap.get('accountName'), 'returned JSON has incorrect accountName');
    }
}