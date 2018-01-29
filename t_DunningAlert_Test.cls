@isTest(SeeAllData=true)
public class t_DunningAlert_Test {
    
    static Account testClient;
    static Collection_Case__c testCollectionCase;
    static Map<Id,Billing_Contract__c> testBillingContracts;
    static Dunning_Alert__c testDunningAlert;
    
    static String contractStatusArrears = 'Contract - Arrears';
    
    static String dunningLevel1 = '1st Reminder';
    static String dunningLevel2 = '2nd Reminder';
    static String dunningLevel3 = '3rd Reminder';
    static String dunningLevel4 = '4th Reminder';
    static String dunningLevel5 = 'Injunction';

    static testMethod void shouldUpdateBillingContractsSubStatus(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        
        //test and assert
        Test.startTest();
        
        createDunningAlert(testCollectionCase, dunningLevel1);
        insert testDunningAlert;
        assertBillingcontractSubStatus(dunningLevel1);
        
        createDunningAlert(testCollectionCase, dunningLevel2);
        insert testDunningAlert;
        assertBillingcontractSubStatus(dunningLevel2);
        
        createDunningAlert(testCollectionCase, dunningLevel3);
        insert testDunningAlert;
        assertBillingcontractSubStatus(dunningLevel3);
        
        createDunningAlert(testCollectionCase, dunningLevel4);
        insert testDunningAlert;
        assertBillingcontractSubStatus(dunningLevel4);
        
        createDunningAlert(testCollectionCase, dunningLevel5);
        insert testDunningAlert;
        assertBillingcontractSubStatus(dunningLevel5);
        
        Test.stopTest();
    }
    
    private static void assertBillingcontractSubStatus(String expectedSubStatus){
        //assert
        Collection_Case__c ccBcs = [SELECT Name,
                                     (SELECT Contract_Sub_Status__c
                                      FROM Billing_Contracts__r
                                     )
                                    FROM Collection_Case__c
                                    WHERE Id = :testCollectionCase.Id];
        
        for(Billing_Contract__c bc : ccBcs.Billing_Contracts__r){
            system.assertEquals(expectedSubStatus, bc.Contract_Sub_Status__c, 'Didnt set the correct billingContract substatus');
        }
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
    
    static void createDunningAlert(Collection_Case__c testCollectionCase, String level){
        testDunningAlert = new Dunning_Alert__c();
        testDunningAlert.Collection_Case__c = testCollectionCase.Id;
        testDunningAlert.Dunning_Level__c = level;
        testDunningAlert.Status__c = 'Open';
        testDunningAlert.Amount_Claimed__c = testCollectionCase.Amount_Claimed__c;
    }
    
}