@isTest(SeeAllData=true)
public class Executive_Action_Factory_Test {

    static Account testClient;
    static Collection_Case__c testCollectionCase;
    
    static testMethod void shouldCreateExecutiveActionForCollectionCase(){
        //setup
        createCollectionCase();
        
        //test
        Test.startTest();
        Executive_Action_Factory.createExecutiveActionForCollectionCase(testCollectionCase.Id);
        Test.stopTest();
        
        Executive_Action_Procedure__c action = [SELECT Id FROM Executive_Action_Procedure__c WHERE Collection_Case__c = :testCollectionCase.Id];
        system.assert(action != null, 'Didnt create the executive action');
    }
    
    /*
     * SETUP
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
    
    
}