@isTest(SeeAllData=true)
public class INJ_Trigger_Test {
    
    static Integer s_num = 1;//used to fake Ids
    
    static Account testClient;
    static Collection_Case__c testCollectionCase;
    static Application__c testApp;
    static Map<Id,Billing_Contract__c> testBillingContracts;
    static Injunction_Procedure__c testInjunction;
    static Attachment testAttachment;
    
    static String ccStatusLegal = 'Legal';
    
    static String decisionNone = 'None';
    static String decisionEnforcement = 'Appended Enforcement Order';
    static String decisionOpposition = 'Injunction Opposition';
    static String decisionFrustation = 'Frustration By Notice';
    
    static String injStatusCreated = 'Created';
    static String injStatusSubmitted = 'Submitted';
    
    static String statusRunning = 'Contract - Running';
    static String statusArrears = 'Contract - Arrears';
    static String statusLawsuit = 'Contract - Lawsuit';
    
    static String judicialFeeStatusNone = 'None';
    static String judicialFeeStatusPaid = 'Paid';
    static String judicialFeeStatusUnpaid = 'Unpaid';
    
    static String injunctionSubStatus = 'Injunction';
    
    //Success getBillingContractsByCollectionCaseId()
    static testMethod void shouldReturnCorrectBillingContracts(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, statusRunning);
        
        //test
        Test.startTest();
        List<Billing_Contract__c> contractList = INJ_Trigger_Handler.getBillingContractsByCollectionCaseId(testCollectionCase.Id);
        Test.stopTest();
        
        //assert
        system.assertEquals(testBillingContracts.size(), contractList.size(), 'Didnt return the correct amount of Billing Contracts; Expected size'+ testBillingContracts.size() +'; Returned size '+contractList.size());
        for(Billing_Contract__c contract : contractList){
            system.assert(testBillingContracts.containsKey(contract.Id), 'Returned an unexpected Billing Contract; Unexpected BC '+contract.Name);
        }
    }
    
    //Error non existant Collection Case
    static testMethod void shouldReturnEmptyNonExistantCollectionCase(){
        //setup
        Id testId = Id.valueOf(getFakeId(Collection_Case__c.SObjectType));
        
        //test
        Test.startTest();
        List<Billing_Contract__c> contractList = INJ_Trigger_Handler.getBillingContractsByCollectionCaseId(testId);
        Test.stopTest();
        
        //assert
        system.assert(contractList == new List<Billing_Contract__c>(),'Returned a contractList for a non existant Collection Case');
    }
    
    //Error non existant Collection Case
    static testMethod void shouldReturnEmptyNonExistantBillingContracts(){
        //setup
        createCollectionCase();
        
        //test
        Test.startTest();
        List<Billing_Contract__c> contractList = INJ_Trigger_Handler.getBillingContractsByCollectionCaseId(testCollectionCase.Id);
        Test.stopTest();
        
        //assert
        system.assert(contractList == new List<Billing_Contract__c>(),'Returned a contractList when there werent any contracts');
    }
    
    //when creating an injunction auto populate the client account from the billing contract
    static testMethod void shouldSetClientAccount(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        
        //test
        Test.startTest();
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = testCollectionCase.Id;
        insert testInjunction;
        Test.stopTest();
        
        //assert
        Injunction_Procedure__c inj = [SELECT Account_Client__c FROM Injunction_Procedure__c WHERE Id = :testInjunction.Id];
        system.assert(inj.Account_Client__c != null, 'Didnt set a client account when creating the injunction');
        system.assertEquals(testClient.Id, inj.Account_Client__c, 'Didnt set the correct client account when creating the injunction');
    }
    
    //when creating an injunction auto populate the injunction date if it doesnt exist
    static testMethod void shouldSetInjunctionDate(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        
        //test
        Test.startTest();
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = testCollectionCase.Id;
        insert testInjunction;
        Test.stopTest();
        
        //assert
        Injunction_Procedure__c inj = [SELECT Injunction_Date__c FROM Injunction_Procedure__c WHERE Id = :testInjunction.Id];
        system.assert(inj.Injunction_Date__c != null, 'Didnt set the injunction date when creating the injunction');
    }
    
    static testMethod void shouldSetLegalData(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        
        //test
        Test.startTest();
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = testCollectionCase.Id;
        insert testInjunction;
        Test.stopTest();
        
        //assert
        List<Application__c> apps = [SELECT Injunction__c FROM Application__c WHERE Id = :testApp.Id];
        for(Application__c app : apps){
            system.assert(app.Injunction__c != null, 'Didnt set the renting apps related list');
        }
        
        List<Billing_Contract__c> bcs = [SELECT BC_Contract_Inactive__c, Contract_Status__c, Contract_Sub_Status__c, Contract_Inactive_Date__c, Injunction__c FROM Billing_Contract__c WHERE Id IN :testBillingContracts.keySet()];
        for(Billing_Contract__c bc : bcs){
            system.assert(bc.Contract_Inactive_Date__c != null, 'Didnt set the contract inactive date');
            system.assertEquals(true, bc.BC_Contract_Inactive__c, 'Didnt set the billing contract to inactive');
            system.assertEquals(statusLawsuit, bc.Contract_Status__c, 'Didnt set the billing contract status to Lawsuit');
            system.assertEquals(injunctionSubStatus, bc.Contract_Sub_Status__c, 'Didnt set the billing contract substatus to Injunction');
            system.assertEquals(testInjunction.Id, bc.Injunction__c, 'Didnt set the related injunction');
        }
        
        Collection_Case__c cc = [SELECT Status__c FROM Collection_Case__c WHERE Id = :testInjunction.Collection_Case__c];
        system.assertEquals(ccStatusLegal, cc.Status__c, 'Didnt set the collection case status to Legal');
        
        Injunction_Procedure__c inj = [SELECT Collection_Fee_Amount__c, Claimed_Amount__c, Payment_Amount_to_The_End_Of_Contract__c, Residual_Value_Prct__c, Residual_Value_Amount__c, Interest_Charges__c, Tax_Code__c, Tax_Rate__c FROM Injunction_Procedure__c WHERE Id = :testInjunction.Id];
        system.assert(inj.Claimed_Amount__c != null, 'Didnt set the injunction claimed amount');
        system.assert(inj.Payment_Amount_to_The_End_Of_Contract__c != null, 'Didnt set the injunction payment amount till end of contract');
        system.assert(inj.Residual_Value_Amount__c != null, 'Didnt set the residual amount');
        system.assert(inj.Collection_Fee_Amount__c != null, 'Didnt set the collection fee amount');
        system.assert(inj.Residual_Value_Prct__c != null, 'Didnt set the residual value prct');
        system.assert(inj.Tax_Code__c != null, 'Didnt set the injunction tax code');
        system.assert(inj.Tax_Rate__c != null, 'Didnt set the injucntion tax rate');
    }
    
    static testMethod void shouldSetContactRelatedList(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        
        //test
        Test.startTest();
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = testCollectionCase.Id;
        insert testInjunction;
        Test.stopTest();
        
        //assert
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Injunction__c = :testInjunction.Id];
        system.assert(contacts.size() > 0, 'Didnt set the contacts related list');
    }
    
    static testMethod void shouldSetEquipmentRelatedList(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        
        //test
        Test.startTest();
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = testCollectionCase.Id;
        insert testInjunction;
        Test.stopTest();
        
        //assert
        List<Equipment__c> equips = [SELECT Id FROM Equipment__c WHERE Injunction__c = :testInjunction.Id];
        system.assert(equips.size() > 0, 'Didnt set the equipments related list');
    }
    
    static testMethod void shouldSetAttachmentRelatedList(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        createAttachment(testApp.Id);
        
        //test
        Test.startTest();
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = testCollectionCase.Id;
        insert testInjunction;
        Test.stopTest();
        
        //assert
        Attachment att = [SELECT Id FROM Attachment WHERE ParentID = :testInjunction.Id];
        system.assert(att != null, 'Didnt set the auto de aceitacao attachment when creating an injunction');
        
    }
    
    //change judicial fee status and check if judicial fee decision date is updated
    static testMethod void shouldSetJudicialDecisionDate(){
        //setup
        createCollectionCase();
        //createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialFeeStatusNone);
        
        //test
        Test.startTest();
        testInjunction.Judicial_Fee_Status__c = judicialFeeStatusPaid;
        update testInjunction;
        Test.stopTest();
        
        //assert
        Injunction_Procedure__c inj = [SELECT Judicial_Fee_Payment_Date__c
                                      FROM Injunction_Procedure__c
                                      WHERE Id = :testInjunction.Id];
        
        system.assert(inj.Judicial_Fee_Payment_Date__c != null, 'Didnt set the judicial decision date');
    }
    
    static testMethod void shouldResetJudicialDecisionDate(){
        //setup
        createCollectionCase();
        //createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialFeeStatusPaid);
        
        //test
        Test.startTest();
        testInjunction.Judicial_Fee_Status__c = judicialFeeStatusNone;
        update testInjunction;
        Test.stopTest();
        
        //assert
        Injunction_Procedure__c inj = [SELECT Judicial_Fee_Payment_Date__c
                                      FROM Injunction_Procedure__c
                                      WHERE Id = :testInjunction.Id];
        
        system.assert(inj.Judicial_Fee_Payment_Date__c == null, 'Didnt reset the judicial decision date');
    }
    
    //change inj status to submitted and check if submitted date is updated
    static testMethod void shouldSetSubmissionDate(){
        //setup
        createCollectionCase();
        //createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialFeeStatusNone);
        
        //test
        Test.startTest();
        testInjunction.Injuction_Procedure_Status__c = injStatusSubmitted;
        update testInjunction;
        Test.stopTest();
        
        //assert
        Injunction_Procedure__c inj = [SELECT Injunction_Submission_Date__c
                                      FROM Injunction_Procedure__c
                                      WHERE Id = :testInjunction.Id];
        
        system.assert(inj.Injunction_Submission_Date__c != null, 'Didnt set the submission date');
    }
    
    static testMethod void shouldResetSubmissionDate(){
        //setup
        createCollectionCase();
        //createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusSubmitted, judicialFeeStatusPaid);
        
        //test
        Test.startTest();
        testInjunction.Injuction_Procedure_Status__c = injStatusCreated;
        update testInjunction;
        Test.stopTest();
        
        //assert
        Injunction_Procedure__c inj = [SELECT Injunction_Submission_Date__c
                                      FROM Injunction_Procedure__c
                                      WHERE Id = :testInjunction.Id];
        
        system.assert(inj.Injunction_Submission_Date__c == null, 'Didnt reset the submission date');
    }
    
    //change injunction decision and check if decision date is updated
    static testMethod void shouldSetInjunctionDecisionDate(){
        //setup
        createCollectionCase();
        //createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialFeeStatusNone);
        
        //test
        Test.startTest();
        
        testInjunction.Injunction_Decision__c = decisionEnforcement;
        update testInjunction;
        
        Test.stopTest();
        
        
        //assert
        Injunction_Procedure__c inj = [SELECT Injuction_Decison_Date__c
                                      FROM Injunction_Procedure__c
                                      WHERE Id = :testInjunction.Id];
        
        system.assert(inj.Injuction_Decison_Date__c != null, 'Didnt set the decision date');
    }
    
    static testMethod void shouldResetInjunctionDecisionDate(){
        //setup
        createCollectionCase();
        //createBillingContractsForCollectionCase(testClient, testCollectionCase, statusArrears);
        createInjunction(testCollectionCase, decisionEnforcement, injStatusCreated, judicialFeeStatusNone);
        
        //test
        Test.startTest();
        
        testInjunction.Injunction_Decision__c = decisionNone;
        update testInjunction;
        Test.stopTest();
        
        
        //assert
        Injunction_Procedure__c inj = [SELECT Injuction_Decison_Date__c
                                      FROM Injunction_Procedure__c
                                      WHERE Id = :testInjunction.Id];
        
        system.assert(inj.Injuction_Decison_Date__c == null, 'Didnt reset the decision date');
    }

    /*
     * SETUP HELPERS
     */
    
    static String getFakeId(Schema.SObjectType sot){
      String result = String.valueOf(s_num++);
      return sot.getDescribe().getKeyPrefix() + 
         '0'.repeat(12-result.length()) + result;
    }
    
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
        
        //create Contacts for personal guarantees
        Contact guarantee1 = new Contact();
        guarantee1.AccountId = testClient.Id;
        guarantee1.LastName = 'Guarantee1';
        insert guarantee1;
        
        Contact guarantee2 = new Contact();
        guarantee2.AccountId = testClient.Id;
        guarantee2.LastName = 'Guarantee2';
        insert guarantee2;
        
        //create Renting Application
        testApp= new Application__c(AccClient__c = testClient.ID);
        testApp.Vendor__c = vendor.Id;
        testApp.Status__c = contractStatus;
        testApp.Personal_Guarantee__c = true;
        testApp.Personal_Guarantee_Signer_1__c = guarantee1.Id;
        testApp.Personal_Guarantee_Signer_2__c = guarantee2.Id;
        insert testApp;
        
        //create equipments
        Equipment__c equip = new Equipment__c();
        equip.Application__c = testApp.Id;
        equip.Equipment_Quantity__c = 1;
        equip.Equipment_Description__c = 'Equipment Description';
        equip.Equipment_Serial_Number__c = 'çgfklflkjebh';
        equip.Price_Check__c = 5;
        insert equip;
        
        
        //create billing contracts
        testBillingContracts = new Map<Id,Billing_Contract__c>();
        
        Billing_Contract__c bc1 = new Billing_Contract__c();
        bc1.Application__c = testApp.id;       
        bc1.Collection_Case__c = testCollectionCase.Id;
        bc1.Account__c = testClient.Id;
        bc1.Equipment_Cost__c = 1000;
        insert bc1;
        testBillingContracts.put(bc1.Id,bc1);
        
        Billing_Contract__c bc2 = new Billing_Contract__c();
        bc2.Application__c = testApp.id;       
        bc2.Collection_Case__c = testCollectionCase.Id;
        bc2.Account__c = testClient.Id;
        bc2.Equipment_Cost__c = 2000;
        insert bc2;
        testBillingContracts.put(bc2.Id,bc2);
        
        Billing_Contract__c bc3 = new Billing_Contract__c();
        bc3.Application__c = testApp.id;       
        bc3.Collection_Case__c = testCollectionCase.Id;
        bc3.Account__c = testClient.Id;
        bc3.Equipment_Cost__c = 3000;
        insert bc3;
        testBillingContracts.put(bc3.Id,bc3);
    }
    
    static void createInjunction(Collection_Case__c cc, String injDecision, String injStatus, String judicialFeeStatus){
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = cc.Id;
        testInjunction.Injuction_Procedure_Status__c = injStatus;
        testInjunction.Injunction_Decision__c = injDecision;
        testInjunction.Judicial_Fee_Status__c = judicialFeeStatus;
        insert testInjunction;
    }
    
    static void createAttachment(Id rentingAppId){
        testAttachment = new Attachment();
        testAttachment.ParentId = rentingAppId;
        testAttachment.Name = 'Auto de Aceitação';
        testAttachment.ContentType = 'application/pdf';
        testAttachment.Description = 'Attachment Description';
        testAttachment.Body = Blob.valueOf('Attachment Body');
        insert testAttachment;
    }
}