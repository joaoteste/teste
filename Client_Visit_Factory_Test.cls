@isTest(SeeAllData=true)
public class Client_Visit_Factory_Test {
    
    static Application__c  testApp;
    
    static String statusRunning = 'Contract - Running';

    static testMethod void shouldCreateClientVisitForRentingApp(){
        //setup
        createTestRentingApp(statusRunning);
        
        //test
        Test.startTest();
        Client_Visit_Factory.createClientVisitForRentingApp(testApp.Id);
        Test.stopTest();
        
        Client_Visit__c visit = [SELECT Id, Type__c FROM Client_Visit__c WHERE Application_Number__c = :testApp.Id];
        system.assert(visit != null, 'Didnt create the client visit');
        system.assertEquals('Underwriting Process', visit.Type__c, 'Didnt create visit with correct Type');
    }
    


    static void createTestRentingApp(String contractStatus){
        //create Client
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
        testApp= new Application__c(AccClient__c = testClient.ID);
        testApp.Vendor__c = vendor.Id;
        testApp.Status__c = contractStatus;
        insert testApp;
    }
    
}