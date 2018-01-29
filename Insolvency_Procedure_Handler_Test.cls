@isTest(SeeAllData=true)
public class Insolvency_Procedure_Handler_Test {

    static Account testClient;
    static Account testVendor;
    static Application__c testApp;
    static Collection_Case__c testCollectionCase;
    static Billing_Contract__c testContract;
    
    private static Integer nifCounter = 100000000;
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    
    static String contractStatusArrears = 'Contract - Arrears';
    static String decisionNone = 'None';
    static String injStatusCreated = 'Created';
    static String judicialFeeStatusNone = 'None';
    
    //before insert
    static testMethod void shouldCreateCase(){
    	//setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        String expectedSubject = 'Insolvency Action Against '+testClient.Name;
        
        //test
        Test.startTest();
        Insolvency_Judicial_Procedure__c testAction = new Insolvency_Judicial_Procedure__c();
        testAction.Account_Client__c = testClient.Id;
        insert testAction;
        Test.stopTest();
        
        //assert
        Case aux = [SELECT Id FROM Case WHERE Subject = :expectedSubject];
        system.assert(aux.Id != null,'Didnt create the case for the insolvency action');
    }
    
    //before insert
    static testMethod void shouldSetCollectionCase(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        
        //test
        Test.startTest();
        Insolvency_Judicial_Procedure__c testAction = new Insolvency_Judicial_Procedure__c();
        testAction.Account_Client__c = testClient.Id;
        insert testAction;
        Test.stopTest();
        
        //assert
        Insolvency_Judicial_Procedure__c action = [SELECT Collection_Case__c FROM Insolvency_Judicial_Procedure__c WHERE Id = :testAction.Id];
        
        system.assert(action.Collection_Case__c != null, 'Didnt set the collection case when creating insolvency action');
        system.assertEquals(testCollectionCase.Id, action.Collection_Case__c, 'Didnt set the correct collection case when creating insolvency action');
    }
    
    //before insert
    static testMethod void shouldSetCreditAmountWithCollectionCase(){
    	//setup
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
    	testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
    	testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        testContract = ClientAppService_TestUtils.createBillingContractForCollectionCase(testApp, testCollectionCase);
        
    	//test
    	Test.startTest();
    	Insolvency_Judicial_Procedure__c testAction = new Insolvency_Judicial_Procedure__c();
        testAction.Account_Client__c = testClient.Id;
        testAction.Collection_Case__c = testCollectionCase.Id;
        insert testAction;
    	Test.stopTest();
    	
    	//assert
    	Insolvency_Judicial_Procedure__c auxInsolv = [SELECT Claimed_Amount__c, Payment_Amount_to_The_End_Of_Contract__c, Residual_Value_Amount__c FROM Insolvency_Judicial_Procedure__c WHERE Id = :testAction.Id];
    	Billing_Contract__c auxBilling = [SELECT Payment_Amount_to_The_End_Of_Contract__c, Residual_Value_Amount__c FROM Billing_Contract__c WHERE Id = :testContract.Id];
    	system.assertEquals(testCollectionCase.Amount_Claimed__c, auxInsolv.Claimed_Amount__c,'Didnt set the correct claimed amount');
    	system.assertEquals(auxInsolv.Payment_Amount_to_The_End_Of_Contract__c, auxBilling.Payment_Amount_to_The_End_Of_Contract__c * 1.23,'Didnt set the correct payment amount till end of contract');//Mainland IVA
    	system.assertEquals(auxInsolv.Residual_Value_Amount__c, auxBilling.Residual_Value_Amount__c * 1.23,'Didnt set the correct residual value amount');//Mainland IVA
    }
    
    //before insert
    static testMethod void shouldSetCreditAmountWithoutCollectionCase(){
    	//setup
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
    	testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
    	testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        List<Billing_Contract__c> contracts = ClientAppService_TestUtils.createContractsForRentingApp(testApp, testClient, testVendor, 1);
        testContract = contracts[0];
        
    	//test
    	Test.startTest();
    	Insolvency_Judicial_Procedure__c testAction = new Insolvency_Judicial_Procedure__c();
        testAction.Account_Client__c = testClient.Id;
        insert testAction;
    	Test.stopTest();
    	
    	//assert
    	Insolvency_Judicial_Procedure__c auxInsolv = [SELECT Claimed_Amount__c, Payment_Amount_to_The_End_Of_Contract__c, Residual_Value_Amount__c FROM Insolvency_Judicial_Procedure__c WHERE Id = :testAction.Id];
    	Billing_Contract__c auxBilling = [SELECT Payment_Amount_to_The_End_Of_Contract__c, Residual_Value_Amount__c FROM Billing_Contract__c WHERE Id = :testContract.Id];
    	system.assertEquals(auxInsolv.Payment_Amount_to_The_End_Of_Contract__c, auxBilling.Payment_Amount_to_The_End_Of_Contract__c * 1.23,'Didnt set the correct payment amount till end of contract');//Mainland IVA
    	system.assertEquals(auxInsolv.Residual_Value_Amount__c, auxBilling.Residual_Value_Amount__c * 1.23,'Didnt set the correct residual value amount');//Mainland IVA
    }
    
    //after insert
    static testMethod void shouldSetRentingAppRelatedList(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        
        //test
        Test.startTest();
        Insolvency_Judicial_Procedure__c testAction = new Insolvency_Judicial_Procedure__c();
        testAction.Account_Client__c = testClient.Id;
        insert testAction;
        Test.stopTest();
        
        //assert
        Application__c app = [SELECT Insolvency_Judicial_Procedure__c FROM Application__c WHERE Id = :testApp.Id];
        
        system.assert(app.Insolvency_Judicial_Procedure__c != null, 'Didnt set the insolvency action on renting app');
        system.assertEquals(testAction.Id, app.Insolvency_Judicial_Procedure__c, 'Didnt set the correct insolvency action on renting app');
    }
}