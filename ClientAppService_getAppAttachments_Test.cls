@isTest (SeeAllData = true)
public class ClientAppService_getAppAttachments_Test {
    
    private static Integer KEY_SIZE = 192;
    private static Integer nifCounter = 100000000;
    private static String testUsername = 'email@mail.com';
    private static String testPass = '12345';
    
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    private static String typeOther = 'Other';
    
    private static String contractName = 'Contrato de Renting';
    private static String autoName = 'Auto de Aceitação';
    
    private static Contact testContact;
    
    private static Account testClient;
    private static Account testVendor;
    
    private static Login__c testLogin;
    private static Session__c testSession;
    
    private static Application__c testApp;
    private static Attachment testContractAtt;
    private static Attachment testAutoAtt;

    static void assertAttachmentMap(Map<String,Object> expected, Map<String,Object> returned){
        system.assert(returned.containsKey('Id'), 'Returned attachment doesnt contain Id');
        system.assertEquals(expected.get('Id'), returned.get('Id'), 'Returned attachment has incorrect Id');
        system.assert(returned.containsKey('Name'), 'Returned attachment doesnt contain Name');
        system.assertEquals(expected.get('Name'), returned.get('Name'), 'Returned attachment has incorrect Name');
        //system.assert(returned.containsKey('Body'), 'Returned attachment doesnt contain Body');
        //system.assertEquals(expected.get('Body'), returned.get('Body'), 'Returned attachment has incorrect Body');
        //system.assert(returned.containsKey('ContentType'), 'Returned attachment doesnt contain ContentType');
        //system.assertEquals(expected.get('ContentType'), returned.get('ContentType'), 'Returned attachment has incorrect ContentType');
        //system.assert(returned.containsKey('Description'), 'Returned attachment doesnt contain Description');
        //system.assertEquals(expected.get('Description'), returned.get('Description'), 'Returned attachment has incorrect Description');
    }
    
    //implicit success test for validateSession() because it only returns info if session is valid
    static testMethod void shouldReturnAppAttachments(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testContractAtt = ClientAppService_TestUtils.createAttachment(testApp.Id, contractName);
        testAutoAtt = ClientAppService_TestUtils.createAttachment(testApp.Id, autoName);
        Map<String,Object> contractAttMap = ClientAppService_TestUtils.convertAttachmentToMap(testContractAtt);
        Map<String,Object> autoAttMap = ClientAppService_TestUtils.convertAttachmentToMap(testAutoAtt);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getAppAttachments(testSession.token__c, testApp.Id));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('contractAttachment'), 'returned JSON doesnt contain contractAttachment');
        system.assert(dataMap.containsKey('autoAttachment'), 'returned JSON doesnt contain autoAttachment');
        assertAttachmentMap(contractAttMap,(Map<String, Object>)dataMap.get('contractAttachment'));
        assertAttachmentMap(autoAttMap,(Map<String, Object>)dataMap.get('autoAttachment'));
    }
    
    static testMethod void shouldFailOnlyAutoAtt(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testAutoAtt = ClientAppService_TestUtils.createAttachment(testApp.Id, autoName);
        Map<String,Object> autoAttMap = ClientAppService_TestUtils.convertAttachmentToMap(testAutoAtt);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getAppAttachments(testSession.token__c, testApp.Id));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(!dataMap.containsKey('contractAttachment'), 'returned JSON containS contractAttachment');
        system.assert(dataMap.containsKey('autoAttachment'), 'returned JSON doesnt contain autoAttachment');
        assertAttachmentMap(autoAttMap,(Map<String, Object>)dataMap.get('autoAttachment'));
    }
    
    static testMethod void shouldFailOnlyContractAtt(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testContractAtt = ClientAppService_TestUtils.createAttachment(testApp.Id, contractName);
        Map<String,Object> contractAttMap = ClientAppService_TestUtils.convertAttachmentToMap(testContractAtt);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getAppAttachments(testSession.token__c, testApp.Id));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(!dataMap.containsKey('autoAttachment'), 'returned JSON containS autoAttachment');
        system.assert(dataMap.containsKey('contractAttachment'), 'returned JSON doesnt contain contractAttachment');
        assertAttachmentMap(contractAttMap,(Map<String, Object>)dataMap.get('contractAttachment'));
    }
    
    static testMethod void shouldFailNoAtts(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getAppAttachments(testSession.token__c, testApp.Id));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('ERROR', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('errorCode'), 'returned JSON doesnt contain errorMessage');
        system.assertEquals('NO_ATTS_FOUND', dataMap.get('errorCode'), 'returned JSON has incorrect status');
    } 
}