@isTest(SeeAllData=true)
public class Declarative_Action_Trigger_Test {
    
    static Account testClient;
    static Collection_Case__c testCollectionCase;
    static Map<Id,Billing_Contract__c> testBillingContracts;
    static Injunction_Procedure__c testInjunction;

    static String contractStatusArrears = 'Contract - Arrears';
    static String decisionNone = 'None';
    static String injStatusCreated = 'Created';
    
    static Decimal expectedClaimedAmount = 5900; //= (Inj.amountClaimed + Inj.advancedExpired + Inj.FairMarket) - Inj.judicialFee = (2000 + 3000 + 1000) - 100; values set in createInjunctionProcedure()
    
    static testMethod void shouldSetClientAccount(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated);
        
        //test
        Test.startTest();
        Declarative_Action__c testAction = new Declarative_Action__c();
        testAction.Injunction_Procedure__c = testInjunction.Id;
        insert testAction;
        Test.stopTest();
        
        //assert
        Declarative_Action__c action = [SELECT Account_Client__c FROM Declarative_Action__c WHERE Id = :testAction.Id];
        
        system.assert(action.Account_Client__c != null, 'Didnt set the client account when creating declarative action');
        system.assertEquals(testClient.Id, action.Account_Client__c, 'Didnt set the correct client account when creating declarative action');
    }
    
    /*
    static testMethod void shouldSetClaimedAmount(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testBillingContracts.values().get(0), testCollectionCase, decisionNone, injStatusCreated, judicialFeeStatusNone);
        
        //test
        Test.startTest();
        Declarative_Action__c testAction = new Declarative_Action__c();
        testAction.Billing_Contract__c = testBillingContracts.values().get(0).Id;
        testAction.Injunction_Procedure__c = testInjunction.Id;
        insert testAction;
        Test.stopTest();
        
        //assert
        Declarative_Action__c action = [SELECT Declarative_Claimed_Amount__c FROM Declarative_Action__c WHERE Id = :testAction.Id];
        
        system.assert(action.Declarative_Claimed_Amount__c != null, 'Didnt set the claimed amount when creating declarative action');
        system.assertEquals(expectedClaimedAmount, action.Declarative_Claimed_Amount__c, 'Didnt set the correct claimed amount when creating declarative action');
    }*/
    
    /*
     * SETUP HELPERS
     */
    
    static void createCollectionCase(){
        //create test client
        testClient = new Account();
        testClient.Name = 'Test Account Client'; 
        testClient.Type = 'Customer - Channel';
        testClient.NIF__c = '5007666313';
        testClient.BillingCity = 'Lx';
        testClient.BillingPostalCode = '3000-423';
        testClient.BillingStreet = 'BillingStreet';
        testClient.Website = 'webSite';
        testClient.Phone = '00351964639755';
        testClient.Fax = '00351964639755';
        testClient.c2g__CODAAccountTradingCurrency__c = 'AED';
        testClient.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        insert testClient;
        
        //create Collection Case
        testCollectionCase = new Collection_Case__c();
        testCollectionCase.Account__c = testClient.id;
        testCollectionCase.Status__c='Open';
        testCollectionCase.Amount_Claimed__c = 5000;
        insert testCollectionCase;
    }
    
    static void createBillingContractsForCollectionCase(Account testClient, Collection_Case__c testCollectionCase, String contractStatus){
        //create Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630333';
        vendor.c2g__CODAInvoiceEmail__c = 'jhonDoe@email.com';
        vendor.Moloni_Client_ID__c = '1421';
        vendor.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        vendor.BillingPostalCode = '1700-178';
        insert vendor;
        
        //create Renting Application
        Application__c app= new Application__c(AccClient__c = testClient.ID);
        app.Vendor__c = vendor.Id;
        app.Status__c = contractStatus;
        insert app;
        
        //create billing contracts
        testBillingContracts = new Map<Id,Billing_Contract__c>();
        
        Billing_Contract__c bc1 = new Billing_Contract__c();
        bc1.Application__c = app.id;       
        bc1.Collection_Case__c = testCollectionCase.Id;
        bc1.Account__c = testClient.Id;
        bc1.Equipment_Cost__c = 1000;
        insert bc1;
        testBillingContracts.put(bc1.Id,bc1);
        
        Billing_Contract__c bc2 = new Billing_Contract__c();
        bc2.Application__c = app.id;       
        bc2.Collection_Case__c = testCollectionCase.Id;
        bc2.Account__c = testClient.Id;
        bc2.Equipment_Cost__c = 2000;
        insert bc2;
        testBillingContracts.put(bc2.Id,bc2);
        
        Billing_Contract__c bc3 = new Billing_Contract__c();
        bc3.Application__c = app.id;       
        bc3.Collection_Case__c = testCollectionCase.Id;
        bc3.Account__c = testClient.Id;
        bc3.Equipment_Cost__c = 3000;
        insert bc3;
        testBillingContracts.put(bc3.Id,bc3);
    }
    
    static void createInjunction(Collection_Case__c cc, String injDecision, String injStatus){
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = cc.Id;
        testInjunction.Injuction_Procedure_Status__c = injStatus;
        testInjunction.Injunction_Decision__c = injDecision;
        testInjunction.Judicial_Fee_Amount__c = 100;
        insert testInjunction;
    }
}