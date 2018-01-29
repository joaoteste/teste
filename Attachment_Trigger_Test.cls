@isTest(SeeAllData=true)
public class Attachment_Trigger_Test {
    
    static Account testClient;
    static Account testVendor;
    static Application__c testApp;
    static Collection_Case__c testCollectionCase;
    static Map<Id,Billing_Contract__c> testBillingContracts;
    static Injunction_Procedure__c testInjunction;
    static Attachment testAttachment;
    static CR_Sepa_File__c testSepaFile;
    static Client_Visit__c testVisit;
    
    private static Integer nifCounter = 100000000;    
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    
    static String contractStatusArrears = 'Contract - Arrears';
    static String decisionNone = 'None';
    static String judicialFeeStatusNone = 'None';
    static String sepaMovementType = 'RCUR';
    
    static String injStatusCreated = 'Created';
    static String injStatusSubmitted = 'Submitted';
    
    static String reportName = '64-2018 - Relatório';
    

    //when an injunction file is uploaded, change the status to SUBMITTED and set date
    static testMethod void shouldUpdateInjunctionStatusAndSubmissionDate(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated);
        createAttachment(testInjunction.Id);
        
        //test
        Test.startTest();
        insert testAttachment;
        Test.stopTest();
        
        //assert
        Injunction_Procedure__c inj = [SELECT Injunction_Submission_Date__c, Injuction_Procedure_Status__c
                                       FROM Injunction_Procedure__c
                                       WHERE Id = :testInjunction.Id];
        
        system.assert(inj.Injunction_Submission_Date__c != null, 'Didnt set the injunction submission date');
        system.assertEquals(injStatusSubmitted, inj.Injuction_Procedure_Status__c, 'Didnt update the injunction status to SUBMITTED');
    }
    
    //oh well.....
    static testMethod void shouldCallReadReturnXMLforSepaFile(){
        //setup
        createSepaRecord(sepaMovementType);
        createAttachment(testSepaFile.Id);
        
        //test
        Test.startTest();
        insert testAttachment;
        Test.stopTest();
        //what to assert??
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
    
    static void createInjunction(Collection_Case__c cc, String injDecision, String injStatus){
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = cc.Id;
        testInjunction.Injuction_Procedure_Status__c = injStatus;
        testInjunction.Injunction_Decision__c = injDecision;
        insert testInjunction;
    }
    
    static void createAttachment(Id parentId){
        testAttachment = new Attachment();
        testAttachment.ParentId = parentId;
        testAttachment.Name = 'Attachment Name';
        testAttachment.Body = Blob.valueOf('Attachment Body');
    }
    
    static void createSepaRecord(String movementType){
        testSepaFile = [SELECT id
                        FROM CR_Sepa_File__c
                        WHERE Request_Records_Count__c >= 2 AND Return_DateTime__c = null AND SEPA_Movement_Type__c = :movementType
                        ORDER BY Request_Records_Count__c ASC
                        LIMIT 1];
    }
}