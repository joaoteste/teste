@isTest(SeeAllData=true)
public class Insolvency_Action_Factory_Test {

    static Account testClient;
    static Account testVendor;
    static Application__c testApp;
    
    private static Integer nifCounter = 100000000;
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    
    private static String statusDeclared = 'Insolvency Declared';
    
    private static String resultSuccess = 'Created Insolvency Action Successfully';
    private static String resultCantFind = 'Couldnt find Renting Application with Name: ';
    private static String resultAlreadyExists = 'There is already an Insolvency Action for this Billing Contract/Renting Application: ';
    private static String resultInvalidId = 'Invalid Renting Application Name: ';
    
    static testMethod void shouldCreateInsolvencyAction(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        
        //test
        Test.startTest();
        //just salesforce things
        Application__c aux = [SELECT Name FROM Application__c WHERE ID = :testApp.Id];
        String result = Insolvency_Action_Factory.createInsolvencyAction(aux.Name);
        Test.stopTest();
        
        system.assertEquals(resultSuccess, result,'Didnt return the correct message');
        
        Application__c app = [SELECT Insolvency_Judicial_Procedure__c FROM Application__c WHERE Id = :testApp.Id];
        Insolvency_Judicial_Procedure__c insolv = [SELECT Insolvency_Procedure_Status__c FROM Insolvency_Judicial_Procedure__c WHERE Account_Client__c = :testClient.Id];
        system.assert(app.Insolvency_Judicial_Procedure__c != null, 'Didnt create the insolvency action for the renting application');
        system.assertEquals(statusDeclared, insolv.Insolvency_Procedure_Status__c, 'Didnt create the insolvency action with the correct status');
    }
    
    static testMethod void shouldFailInvalidId(){
    	String invalidId = '';
        //test
        Test.startTest();
        String result = Insolvency_Action_Factory.createInsolvencyAction(invalidId);
        Test.stopTest();
        
        system.assertEquals(resultInvalidId+invalidId, result,'Didnt return the correct message');
    }
    
    static testMethod void shouldFailCantFind(){
    	String inexistentName = 'AP-yfykkjgk';
        //test
        Test.startTest();
        String result = Insolvency_Action_Factory.createInsolvencyAction(inexistentName);
        Test.stopTest();
        
        system.assertEquals(resultCantFind+inexistentName, result,'Didnt return the correct message');
    }
    
    static testMethod void shouldFailAlreadyExists(){
    	//setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        
        //test
        Test.startTest();
        //just salesforce things
        Application__c aux = [SELECT Name FROM Application__c WHERE ID = :testApp.Id];
        Insolvency_Action_Factory.createInsolvencyAction(aux.Name);
        Application__c insolv = [SELECT Insolvency_Judicial_Procedure__r.Name
        						FROM Application__c WHERE Name = :aux.Name];
        String result = Insolvency_Action_Factory.createInsolvencyAction(aux.Name);
        Test.stopTest();
        
        system.assertEquals(resultAlreadyExists+insolv.Insolvency_Judicial_Procedure__r.Name, result,'Didnt return the correct message');
    }
}