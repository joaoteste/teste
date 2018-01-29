@isTest
public class test_CollectionCase {
	
	static Account testClient;
    static Collection_Case__c testCollectionCase;
    
    static String creditLineSuspended = 'Credit Line - Suspended';
    static String creditLineApproved = 'Credit Line - Approved';
    static String ccStatusClosed = 'Closed';
    
    static testMethod void shouldUpdateCreditLineStatusToPendent(){
    	//setup
    	createClient();
    	String previous = testClient.Credit_Line_Status__c;
    	
        //test
        Test.startTest();
        createCollectionCase(testClient);
        Test.stopTest();
        
        //assert
        Account account = [SELECT Credit_Line_Status__c, Credit_Line_Status_Previous__c FROM Account WHERE Id = :testClient.Id];
        
        system.assertEquals(creditLineSuspended, account.Credit_Line_Status__c, 'Didnt update the credit line status correctly');
        system.assertEquals(previous, account.Credit_Line_Status_Previous__c, 'Didnt update the credit line status previous correctly');
    }
    
    static testMethod void shouldUpdateCreditLineStatusToPreviousValue(){
        //setup
        createClient();
        String previous = testClient.Credit_Line_Status__c;
        createCollectionCase(testClient);
        
        //test
        Test.startTest();
        testCollectionCase.Status__c = ccStatusClosed;
        update testCollectionCase;
        Test.stopTest();
        
        
        //assert
        Account account = [SELECT Credit_Line_Status__c FROM Account WHERE Id = :testClient.Id];
        
        system.assertEquals(previous, account.Credit_Line_Status__c, 'Didnt update the credit line status correctly to previous value');
    }
	
	static testMethod void tCollectionCase_Test() {
        
        Test.startTest();
        
        //create test data
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '5007666313';
        client.BillingCity = 'Lx';
        client.BillingPostalCode = '3000-423';
        client.BillingStreet = 'BillingStreet';
        client.Website = 'webSite';
        client.Phone = '00351964639755';
        client.Fax = '00351964639755';
        client.c2g__CODAAccountTradingCurrency__c = 'AED';
        client.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        insert client;
        
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630333';
        vendor.c2g__CODAInvoiceEmail__c = 'jhonDoe@email.com';
        vendor.Moloni_Client_ID__c = '1421';
        vendor.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        insert vendor;
        
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c = client.id;
        cc.Status__c='Open';
        insert cc;  
        
        Contact contact = new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c ='Binding Power';
        contact.AccountId = client.id;
        insert contact;
        
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        insert login;
        
        Application__c app= new Application__c(Vendor__c = vendor.id,AccClient__c = client.ID,IdLoginCreate__c = login.Id, Vendor_Primary__c = contact.id );
        app.Invoice_To__c = contact.ID;
        app.status__c = 'Contract - Running';
        app.Obs_Invoice__c = 'App Notes';
        insert app;
        
        Billing_Contract__c bc = new Billing_Contract__c();
        bc.Application__c = app.id;       
        bc.Collection_Case__c = cc.Id;
        
        insert bc;
        
        cc.Status__c='Closed';
        update cc;
        
        Test.stopTest();
        
    }
    
    /*
     * SETUP HELPERS
     */
    
    static void createClient(){
    	//create test client
        testClient = new Account();
        testClient.Credit_Line_Status__c = creditLineApproved;
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
    }
    
    static void createCollectionCase(Account client){
        //create Collection Case
        testCollectionCase = new Collection_Case__c();
        testCollectionCase.Account__c = client.id;
        testCollectionCase.Status__c='Open';
        testCollectionCase.Amount_Claimed__c = 5000;
        insert testCollectionCase;
    }
}