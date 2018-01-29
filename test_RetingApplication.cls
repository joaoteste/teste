@isTest(SeeAllData = true)
public class test_RetingApplication {
	
	private static Integer nifCounter = 100000000;
	private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    
    private static Account testClient;
    private static Account testVendor;
    private static Contact testContact;
    private static Application__c testApp;
	
	static testMethod void tRetingApplication_Test(){
        
        Test.startTest();

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
        System.debug('bc ' + bc);
        
        app.Status__c = 'Contract - Lawsuit';
        update app;
        
        Test.stopTest();
        
    }
    
    
    static testMethod void shouldCreateLogin(){
    	//setup
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testContact = ClientAppService_TestUtils.createContact(testClient, null);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor, testContact);
        
        //test
        Test.startTest();
        Application__c aux = [SELECT Invoice_Payment_Date__c, Client_Signer_1__c FROM Application__c WHERE ID = :testApp.Id];
        aux.Invoice_Payment_Date__c = Date.today();
        aux.Insurance_Type__c = 'Static Risk';
        update aux;
        Test.stopTest();
        
        //assert
        Contact contact = [SELECT Login__c FROM Contact WHERE Id = :aux.Client_Signer_1__c];
        system.assert(contact.Login__c != null, 'Didnt create the login for signer1');
    }
    
    static testMethod void shouldAssociateLogin(){
    	//setup
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testContact = ClientAppService_TestUtils.createContact(testClient, null);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor, testContact);
        //create login with same email as testContact
        Login__c testLogin = ClientAppService_TestUtils.createLogin('someone@email.com', 'somePass', false);
        
        //test
        Test.startTest();
        Application__c aux = [SELECT Invoice_Payment_Date__c, Client_Signer_1__c FROM Application__c WHERE ID = :testApp.Id];
        aux.Invoice_Payment_Date__c = Date.today();
        aux.Insurance_Type__c = 'Static Risk';
        update aux;
        Test.stopTest();
        
        //assert
        Contact contact = [SELECT Login__c FROM Contact WHERE Id = :aux.Client_Signer_1__c];
        system.assert(contact.Login__c != null, 'Didnt associate the login for signer1');
        system.assertEquals(contact.Login__c, testLogin.Id, 'Didnt associate the correct login for signer1');
    }
}