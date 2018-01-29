@isTest(SeeAllData=true)
public class Billing_Contract_Test {
    
    static Billing_Contract__c testContract;
    
    static String contractStatus = 'Contract - Running';

    static testMethod void shouldSetResidualValuePrct(){
        //setup
        createBillingContract(contractStatus);
        
        //test
        Test.startTest();
        insert testContract;
        Test.stopTest();
        
        //assert
        Billing_Contract__c bc = [SELECT Residual_Value_Prct__c FROM Billing_Contract__c WHERE Id = :testContract.Id];
        system.assert(bc.Residual_Value_Prct__c != null, 'Didnt set the residual value % for the billing contract');
    }
    
    /*
     * SETUP
     */ 
    
    static void createBillingContract(String contractStatus){
        //create test client
        Account testClient = new Account();
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
        Application__c testApp= new Application__c(AccClient__c = testClient.ID);
        testApp.Vendor__c = vendor.Id;
        testApp.Status__c = contractStatus;
        insert testApp;
        
        testContract = new Billing_Contract__c();
        testContract.Application__c = testApp.id;
        testContract.Account__c = testClient.Id;
        testContract.Equipment_Cost__c = 1000;
    }
}