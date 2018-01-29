@isTest (SeeAllData = true)
public class ClientAppController_Authentication_Test {
    /*
     * NEW STUFF Tests
     */
    
    private static Integer KEY_SIZE = 192;
    private static Integer nifCounter = 100000000;
    private static String testUsername = 'email@mail.com';
    private static String testPass = '12345';
    
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    private static String typeOther = 'Other';
    
    private static Contact testContact;
    private static Account testClientParent;
    private static Account testClient;
    private static Login__c testLogin;
    private static Session__c testSession;
    
    static testMethod void shouldLogin(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);

        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.login(testUsername, testPass));
        Test.stopTest();
        
        //assert        
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('sessionToken'), 'returned JSON doesnt contain sessionToken');
        system.assert(dataMap.containsKey('accountTypes'), 'returned JSON doesnt contain accountTypes');
        
        Map<String,Object> types = (Map<String,Object>)dataMap.get('accountTypes');
        system.assertEquals(1, types.size(), 'Didnt return the correct number of account types');
    }
    
    static testMethod void shouldFailNoLogin(){
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.login('nobody', '12345'));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('LOGIN_NOT_FOUND', dataMap.get('errorCode'), 'returned JSON has incorrect error message');
    }
    
    static testMethod void shouldFailInactiveLogin(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, true);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.login(testUsername, testPass));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('LOGIN_INACTIVE', dataMap.get('errorCode'), 'returned JSON has incorrect error message');
    }
    
    static testMethod void shouldFailIncorrectPassword(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.login(testUsername, 'wrongPass'));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('INCORRECT_PASSWORD', dataMap.get('errorCode'), 'returned JSON has incorrect error message');
    }
    
    static testMethod void shouldFailNoSessionToken(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getCurrentUserInfo(''));
        
        //assert jsonReturn1
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('NO_SESSION_TOKEN', dataMap.get('errorCode'), 'returned JSON has incorrect error message');
    }
    
    static testMethod void shouldFailInvalidSessionToken(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getCurrentUserInfo('someToken'));
        Test.stopTest();
        
        //assert jsonReturn
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('NO_SESSION_FOR_TOKEN', dataMap.get('errorCode'), 'returned JSON has incorrect error message');
    }
    
    static testMethod void shouldFailMoreThan1SessionSameToken(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        //create another session with same token
        Session__c dummy = new Session__c();
        dummy.Login__c = testLogin.Id;
        dummy.token__c = testSession.token__c;
        dummy.LastLogin__c = Date.today();
        dummy.PasswordS__c = ClientAppService_TestUtils.generateCryptoKeyString(192);
        insert dummy;
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getCurrentUserInfo(testSession.token__c));
        Test.stopTest();
        
        //assert jsonReturn
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('MORE_THAN_ONE_SESSION', dataMap.get('errorCode'), 'returned JSON has incorrect error message');
    }
    
    static testMethod void shouldFailPasswordHasChanged(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, true);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getCurrentUserInfo(testSession.token__c));
        Test.stopTest();
        
        //assert jsonReturn
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('PASSWORD_HAS_CHANGED', dataMap.get('errorCode'), 'returned JSON has incorrect error message');
    }
    
    //sends email + changes the user pass
    static testMethod void shouldRecoverPassword(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, true);
        String beforePass = testLogin.Password__c;
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.recoverPassword(testUsername));
        Test.stopTest();
        
        //assert jsonReturn
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Login__c aux = [SELECT Password__c FROM Login__c WHERE Id =: testLogin.Id];
        system.assertNotEquals(beforePass, aux.Password__c, 'Didnt change the user\'s password');
    }
    
    static testMethod void shouldFailRecoverPasswordNoLogin(){
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.recoverPassword('nobody'));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('LOGIN_NOT_FOUND', dataMap.get('errorCode'), 'returned JSON has incorrect error message');
    }
    
    static testMethod void shouldFailRecoverPasswordInactiveLogin(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, true);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.recoverPassword(testUsername));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('LOGIN_INACTIVE', dataMap.get('errorCode'), 'returned JSON has incorrect error message');
    }
}