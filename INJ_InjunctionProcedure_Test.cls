@isTest(SeeAllData=true)
public class INJ_InjunctionProcedure_Test {
    
    static Integer s_num = 1;//used to fake Ids
    
    static Account testClient;
    static Collection_Case__c testCollectionCase;
    static Map<Id,Billing_Contract__c> testBillingContracts;
    static Injunction_Procedure__c testInjunction;
    
    static String contractStatusArrears = 'Contract - Arrears';
    
    //Success createInjunctionProceduresForCollectionCase()
    static testMethod void shouldCreateInjunctionProceduresForCollectionCase(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        
        //test
        Test.startTest();
        INJ_InjunctionProcedure.createInjunctionProceduresForCollectionCase(testCollectionCase.Id);
        Test.stopTest();
        
        Injunction_Procedure__c inj = [SELECT Id FROM Injunction_Procedure__c WHERE Collection_Case__c = :testCollectionCase.Id];
        system.assert(inj != null, 'Didnt create the injunction');
    }
    
    static testMethod void shouldCreateInjunctionTextFile(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase.Id);
        
        //test
        Test.startTest();
        INJ_InjunctionProcedure.generateInjunctionTextFile(testInjunction.Id);
        Test.stopTest();
        
        //assert
        Attachment file = [SELECT Id FROM Attachment WHERE ParentId = :testInjunction.Id];
        system.assert(file != null,'Didnt create injunction text file for injunction');
    }

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
        
        Dunning_Alert__c dunning = new Dunning_Alert__c();
        dunning.Collection_Case__c = testCollectionCase.Id;
        dunning.Dunning_Level__c = '4th Reminder';
        dunning.Status__c = 'Open';
        dunning.Sent_Date__c = Date.today();
        insert dunning;
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
        insert vendor;
        
        //create Renting Application
        Application__c app= new Application__c(AccClient__c = testClient.ID);
        app.Vendor__c = vendor.Id;
        app.Status__c = contractStatus;
        app.Delivery_Certificate_Signed__c = Date.today();
        app.Invoice_Payment_Date__c = Date.today();
        app.Insurance_Type__c = 'Static Risk';
        insert app;
        
        //create billing contracts
        testBillingContracts = new Map<Id,Billing_Contract__c>();
        
        Billing_Contract__c bc1 = new Billing_Contract__c();
        bc1.Application__c = app.id;       
        bc1.Collection_Case__c = testCollectionCase.Id;
        bc1.Equipment_Cost__c = 1000;
        insert bc1;
        testBillingContracts.put(bc1.Id,bc1);
        
        Billing_Contract__c bc2 = new Billing_Contract__c();
        bc2.Application__c = app.id;       
        bc2.Collection_Case__c = testCollectionCase.Id;
        bc2.Equipment_Cost__c = 2000;
        insert bc2;
        testBillingContracts.put(bc2.Id,bc2);
        
        Billing_Contract__c bc3 = new Billing_Contract__c();
        bc3.Application__c = app.id;       
        bc3.Collection_Case__c = testCollectionCase.Id;
        bc3.Equipment_Cost__c = 3000;
        insert bc3;
        testBillingContracts.put(bc3.Id,bc3);
    }
    
    static void createInjunction(Id ccId){
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = ccId;
        insert testInjunction;
    }
}