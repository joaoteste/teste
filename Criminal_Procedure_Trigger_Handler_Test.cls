@isTest(SeeAllData=true)
public class Criminal_Procedure_Trigger_Handler_Test {

    static Account testClient;
    static Account testVendor;
    static Application__c testApp;
    static Collection_Case__c testCollectionCase;
    static List<Dunning_Alert__c> testDunnings;
    static List<Billing_Contract__c> testContracts;
    static c2g__codaInvoice__c testInvoice;
    static Vendor_Invoice__c testVendorInvoice;
    static Attachment testContract;
    static Attachment testAuto;
    static Attachment testVendorInvAtt;
    
    private static Integer NUMBER_INVOICES = 4;
    private static Integer nifCounter = 100000000;
    private static String taxZone = 'Mainland';
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    private static String contractName = 'Contrato de Renting';
    private static String autoName = 'Auto de Aceitação';
    private static String vendorInvoiceName = 'Vendor Invoice';
    
    //before insert
    static testMethod void shouldSetClientAccount(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        
        //test
        Test.startTest();
        Criminal_Judicial_Procedure__c testCrim = new Criminal_Judicial_Procedure__c();
        testCrim.Collection_Case__c = testCollectionCase.Id;
        insert testCrim;
        Test.stopTest();
        
        //assert
        Criminal_Judicial_Procedure__c crim = [SELECT Account_Client__c FROM Criminal_Judicial_Procedure__c WHERE Id = :testCrim.Id];
        
        system.assert(crim.Account_Client__c != null, 'Didnt set the client account when creating criminal procedure');
        system.assertEquals(testClient.Id, crim.Account_Client__c, 'Didnt set the correct client account when creating criminal procedure');
    }
    
    //after insert
    static testMethod void shouldSetAttachmentsRelatedList(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient,testVendor);
        testContract = ClientAppService_TestUtils.createAttachment(testApp.Id, contractName);
        testAuto = ClientAppService_TestUtils.createAttachment(testApp.Id, autoName);
        
        
        //test
        Test.startTest();
        Criminal_Judicial_Procedure__c testCrim = new Criminal_Judicial_Procedure__c();
        testCrim.Account_Client__c = testClient.Id;
        insert testCrim;
        Test.stopTest();
        
        //assert
        Attachment attContract = [SELECT Id FROM Attachment WHERE ParentID = :testCrim.Id AND Name = :contractName];
        Attachment attAuto = [SELECT Id FROM Attachment WHERE ParentID = :testCrim.Id AND Name = :autoName];
        system.assert(attContract != null, 'Didnt set the contract attachment when creating a criminal action');
        system.assert(attAuto != null, 'Didnt set the auto de aceitacao attachment when creating a criminal action');
    }
    
    //after insert
    static testMethod void shouldSetVendorInvoice(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient,testVendor);
        testContract = ClientAppService_TestUtils.createAttachment(testApp.Id, contractName);
        testVendorInvoice = ClientAppService_TestUtils.createVendorInvoice(testVendor, testApp);
        testVendorInvAtt = ClientAppService_TestUtils.createAttachment(testVendorInvoice.Id, vendorInvoiceName);
        
        //test
        Test.startTest();
        Criminal_Judicial_Procedure__c testCrim = new Criminal_Judicial_Procedure__c();
        testCrim.Account_Client__c = testClient.Id;
        insert testCrim;
        Test.stopTest();
        
        //assert
        Attachment attContract = [SELECT Id FROM Attachment WHERE ParentID = :testCrim.Id AND Name = :vendorInvoiceName];
        system.assert(attContract != null, 'Didnt set the vendor invoice attachment when creating a criminal action');
    }
    
    //after insert
    static testMethod void shouldSetUnpaidInvoices(){
    	//setup - have to use real data because I cant create UNPAID invoice...
    	//get one UNPAID invoice and then get all invoices (which match the criteria) of that client account
    	testInvoice = ClientAppService_TestUtils.getInvoiceUNPAID();
    	List<c2g__codaInvoice__c> testInvoices = [SELECT Id FROM c2g__codaInvoice__c
    	WHERE Invoice_Email_Status__c = 'Sent' AND Canceled__c = false 
        AND (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid')
        AND Collection_Case__c != null
        AND c2g__Account__c = :testInvoice.c2g__Account__c];
        
    	//test
    	Test.startTest();
        Criminal_Judicial_Procedure__c testCrim = new Criminal_Judicial_Procedure__c();
        testCrim.Account_Client__c = testInvoice.c2g__Account__c;//use the UNPAID invoice Account as our testClient
        insert testCrim;
        Test.stopTest();
    	
    	//assert
    	List<Collection_Sales_Invoice__c> aux = [SELECT Id FROM Collection_Sales_Invoice__c WHERE Criminal_Action__c = :testCrim.Id];
    	system.assertEquals(testInvoices.size(), aux.size(), 'Didnt create the correct amount of collection sales invoices when creating a criminal action');
    }
    
    //after insert
    static testMethod void shouldSetDunnings(){
    	//setup
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testContracts = ClientAppService_TestUtils.createContractsForRentingApp(testApp, testClient, testVendor, 2);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        List<String> levels = new List<String>{'1st Reminder', '2nd Reminder', '3rd Reminder', '4th Reminder'};
        testDunnings = ClientAppService_TestUtils.createDunningAlerts(testCollectionCase,levels);
        
    	//test
    	Test.startTest();
        Criminal_Judicial_Procedure__c testCrim = new Criminal_Judicial_Procedure__c();
        testCrim.Collection_Case__c = testCollectionCase.Id;
        insert testCrim;
        Test.stopTest();
    	
    	
    	//assert
    	List<Dunning_Alert__c> auxDunnings = [SELECT Id FROM Dunning_Alert__c WHERE Criminal_Action__c = :testCrim.Id];
    	system.assert(auxDunnings.size() != 0, 'Didnt set the dunning alerts when creating a criminal invoice');
    	system.assertEquals(testDunnings.size(), auxDunnings.size(), 'Didnt set the correct number of dunning alerts when creating a criminal invoice');
    } 
    
    //after insert
    static testMethod void shouldSetExchangedEmails(){
    	//setup
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        
    	//test
    	Test.startTest();
        Criminal_Judicial_Procedure__c testCrim = new Criminal_Judicial_Procedure__c();
        testCrim.Account_Client__c = testClient.Id;
        insert testCrim;
        Test.stopTest();
    	
    	
    	//assert
    } 
}