@isTest (SeeAllData = true)
public class ClientAppService_changePassword_Test {
    
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

    //implicit success test for validateSession() because it only returns info if session is valid
    static testMethod void shouldChangePassword(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        String newPass = 'amazingNewPass';
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.changePassword(testSession.token__c, newPass));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        Login__c aux = [SELECT email_psw__c FROM Login__c WHERE Id=:testLogin.Id];
        system.assertEquals(newPass, aux.email_psw__c, 'Didnt update the login to the correct password');
    }
}