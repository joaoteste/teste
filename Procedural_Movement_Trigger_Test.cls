@isTest(SeeAllData=true)
public class Procedural_Movement_Trigger_Test{
    
    static Account testClient;
    static Collection_Case__c testCollectionCase;
    static Map<Id,Billing_Contract__c> testBillingContracts;
    static Injunction_Procedure__c testInjunction;
    static Declarative_Action__c testDeclAction;
    static Executive_Action_Procedure__c testExecAction;
    static Criminal_Judicial_Procedure__c testCriminal;
    static Insolvency_Judicial_Procedure__c testInsolvency;
    static Procedural_Movement__c testProceduralMovement;
    
    static String contractStatusArrears = 'Contract - Arrears';
    static String decisionNone = 'None';
    static String injStatusCreated = 'Created';
    static String judicialNumber = '67440/16.9YIPRT';
    
    static String movementStatusPayPlan = 'Payment Plan';
    static String movementStatusAwaitingClearance = 'Awaiting Clearance';
    
    //before insert
    static testMethod void shouldSetMovementDateFromInsolvencyProcedure(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInsolvencyProcedure(testClient.Id, judicialNumber);
        createProceduralMovement(testInsolvency.Id, movementStatusPayPlan, LegalDocType.Insolvency);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Procedural_Movement__c mov = [SELECT Movement_Date__c FROM Procedural_Movement__c WHERE Id = :testProceduralMovement.Id];
        system.assert(mov.Movement_Date__c != null, 'Didnt set the movement date for procedural movement');
     }
    
    //before insert
    static testMethod void shouldSetMovementDateFromCriminalProcedure(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createCriminalProcedure(testCollectionCase.Id, judicialNumber);
        createProceduralMovement(testCriminal.Id, movementStatusPayPlan, LegalDocType.Criminal);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Procedural_Movement__c mov = [SELECT Movement_Date__c FROM Procedural_Movement__c WHERE Id = :testProceduralMovement.Id];
        system.assert(mov.Movement_Date__c != null, 'Didnt set the movement date for procedural movement');
     }
    
    //before insert
    static testMethod void shouldSetMovementDateFromExecAction(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialNumber);
        createExecutiveAction(testInjunction.Id, judicialNumber);
        createProceduralMovement(testExecAction.Id, movementStatusPayPlan, LegalDocType.ExecAction);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Procedural_Movement__c mov = [SELECT Movement_Date__c FROM Procedural_Movement__c WHERE Id = :testProceduralMovement.Id];
        system.assert(mov.Movement_Date__c != null, 'Didnt set the movement date for procedural movement');
     }
    
    //before insert
    static testMethod void shouldSetMovementDateFromDeclAction(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated,judicialNumber);
        createDeclarativeAction(testInjunction.Id, judicialNumber);
        createProceduralMovement(testDeclAction.Id, movementStatusPayPlan, LegalDocType.DeclAction);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Procedural_Movement__c mov = [SELECT Movement_Date__c FROM Procedural_Movement__c WHERE Id = :testProceduralMovement.Id];
        system.assert(mov.Movement_Date__c != null, 'Didnt set the movement date for procedural movement');
     }
    
    //before insert
    static testMethod void shouldSetMovementDateFromInjunction(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialNumber);
        createProceduralMovement(testInjunction.Id, movementStatusPayPlan, LegalDocType.Injunction);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Procedural_Movement__c mov = [SELECT Movement_Date__c FROM Procedural_Movement__c WHERE Id = :testProceduralMovement.Id];
        system.assert(mov.Movement_Date__c != null, 'Didnt set the movement date for procedural movement');
    }
    
    //after insert
    static testMethod void shouldUpdateLastProceduralDateFromInsolvencyProcedureInsert(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInsolvencyProcedure(testClient.Id, judicialNumber);
        createProceduralMovement(testInsolvency.Id, movementStatusPayPlan, LegalDocType.Insolvency);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Insolvency_Judicial_Procedure__c insolv = [SELECT Last_Procedural_Movement_Date__c
                                                FROM Insolvency_Judicial_Procedure__c
                                                WHERE Id = :testInsolvency.Id];
        
        system.assert(insolv.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Insolvency Procedure');
    }
    
    //after update
    static testMethod void shouldUpdateLastProceduralDateFromInsolvencyProcedureUpdate(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInsolvencyProcedure(testClient.Id, judicialNumber);
        createProceduralMovement(testInsolvency.Id, movementStatusPayPlan, LegalDocType.Insolvency);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        testProceduralMovement.Movement_Status__c = movementStatusAwaitingClearance;
        update testProceduralMovement;
        Test.stopTest();
        
        //assert
        Insolvency_Judicial_Procedure__c insolv = [SELECT Last_Procedural_Movement_Date__c
                                                FROM Insolvency_Judicial_Procedure__c
                                                WHERE Id = :testInsolvency.Id];
        
        system.assert(insolv.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Insolvency Procedure');
    }
    
    
    //after insert
    static testMethod void shouldUpdateLastProceduralDateFromCriminalProcedureInsert(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createCriminalProcedure(testCollectionCase.Id, judicialNumber);
        createProceduralMovement(testCriminal.Id, movementStatusPayPlan, LegalDocType.Criminal);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Criminal_Judicial_Procedure__c crim = [SELECT Last_Procedural_Movement_Date__c
                                                FROM Criminal_Judicial_Procedure__c
                                                WHERE Id = :testCriminal.Id];
        
        system.assert(crim.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Criminal Procedure');
    }
    
    //after update
    static testMethod void shouldUpdateLastProceduralDateFromCriminalProcedureUpdate(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createCriminalProcedure(testCollectionCase.Id, judicialNumber);
        createProceduralMovement(testCriminal.Id, movementStatusPayPlan, LegalDocType.Criminal);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        testProceduralMovement.Movement_Status__c = movementStatusAwaitingClearance;
        update testProceduralMovement;
        Test.stopTest();
        
        //assert
        Criminal_Judicial_Procedure__c crim = [SELECT Last_Procedural_Movement_Date__c
                                                FROM Criminal_Judicial_Procedure__c
                                                WHERE Id = :testCriminal.Id];
        
        system.assert(crim.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Criminal Procedure');
    }
    
    //after insert
    static testMethod void shouldUpdateLastProceduralDateFromExecActionInsert(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialNumber);
        createExecutiveAction(testInjunction.Id, judicialNumber);
        createProceduralMovement(testExecAction.Id, movementStatusPayPlan, LegalDocType.ExecAction);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Executive_Action_Procedure__c action = [SELECT Last_Procedural_Movement_Date__c
                                                FROM Executive_Action_Procedure__c
                                                WHERE Id = :testExecAction.Id];
        
        system.assert(action.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Executive Action');
    }
    
    //after update
    static testMethod void shouldUpdateLastProceduralDateFromExecActionUpdate(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialNumber);
        createExecutiveAction(testInjunction.Id, judicialNumber);
        createProceduralMovement(testExecAction.Id, movementStatusPayPlan, LegalDocType.ExecAction);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        testProceduralMovement.Movement_Status__c = movementStatusAwaitingClearance;
        update testProceduralMovement;
        Test.stopTest();
        
        //assert
        Executive_Action_Procedure__c action = [SELECT Last_Procedural_Movement_Date__c
                                                FROM Executive_Action_Procedure__c
                                                WHERE Id = :testExecAction.Id];
        
        system.assert(action.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Executive Action');
    }
    
    //after insert
    static testMethod void shouldUpdateLastProceduralDateStatusFromDeclActionInsert(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialNumber);
        createDeclarativeAction(testInjunction.Id, judicialNumber);
        createProceduralMovement(testDeclAction.Id, movementStatusPayPlan, LegalDocType.DeclAction);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Declarative_Action__c action = [SELECT Last_Procedural_Movement_Date__c,Procedural_Movement_Status__c
                                      FROM Declarative_Action__c
                                      WHERE Id = :testDeclAction.Id];
        
        system.assert(action.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Declarative Action');
        system.assert(action.Procedural_Movement_Status__c != null, 'Didnt set the procedural movement status in Declarative Action');
        system.assertEquals(testProceduralMovement.Movement_Status__c, action.Procedural_Movement_Status__c, 'Didnt set the correct procedural movement status in Declarative Action');
    }
    
    //after update
    static testMethod void shouldUpdateLastProceduralDateStatusFromDeclActionUpdate(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialNumber);
        createDeclarativeAction(testInjunction.Id, judicialNumber);
        createProceduralMovement(testDeclAction.Id, movementStatusPayPlan, LegalDocType.DeclAction);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        testProceduralMovement.Movement_Status__c = movementStatusAwaitingClearance;
        update testProceduralMovement;
        Test.stopTest();
        
        //assert
        Declarative_Action__c action = [SELECT Last_Procedural_Movement_Date__c,Procedural_Movement_Status__c
                                      FROM Declarative_Action__c
                                      WHERE Id = :testDeclAction.Id];
        
        system.assert(action.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Declarative Action');
        system.assert(action.Procedural_Movement_Status__c != null, 'Didnt set the procedural movement status in Declarative Action');
        system.assertEquals(testProceduralMovement.Movement_Status__c, action.Procedural_Movement_Status__c, 'Didnt set the correct procedural movement status in Declarative Action');
    }
    
    //after insert
    static testMethod void shouldUpdateLastProceduralDateStatusFromInjInsert(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialNumber);
        createProceduralMovement(testInjunction.Id, movementStatusPayPlan, LegalDocType.Injunction);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        Test.stopTest();
        
        //assert
        Injunction_Procedure__c inj = [SELECT Last_Procedural_Movement_Date__c,Procedural_Movement_Status__c
                                      FROM Injunction_Procedure__c
                                      WHERE Id = :testInjunction.Id];
        
        system.assert(inj.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Injunction');
        system.assert(inj.Procedural_Movement_Status__c != null, 'Didnt set the procedural movement status in Injunction');
        system.assertEquals(testProceduralMovement.Movement_Status__c, inj.Procedural_Movement_Status__c, 'Didnt set the correct procedural movement status in Injunction');
    }
    
    //after update
    static testMethod void shouldUpdateLastProceduralDateStatusFromInjUpdate(){
        //setup
        createCollectionCase();
        createBillingContractsForCollectionCase(testClient, testCollectionCase, contractStatusArrears);
        createInjunction(testCollectionCase, decisionNone, injStatusCreated, judicialNumber);
        createProceduralMovement(testInjunction.Id, movementStatusPayPlan, LegalDocType.Injunction);
        
        //test
        Test.startTest();
        insert testProceduralMovement;
        testProceduralMovement.Movement_Status__c = movementStatusAwaitingClearance;
        update testProceduralMovement;
        Test.stopTest();
        
        //assert
        Injunction_Procedure__c inj = [SELECT Last_Procedural_Movement_Date__c,Procedural_Movement_Status__c
                                      FROM Injunction_Procedure__c
                                      WHERE Id = :testInjunction.Id];
        
        system.assert(inj.Last_Procedural_Movement_Date__c != null, 'Didnt set the last procedural movement date in Injunction');
        system.assert(inj.Procedural_Movement_Status__c != null, 'Didnt set the procedural movement status in Injunction');
        system.assertEquals(testProceduralMovement.Movement_Status__c, inj.Procedural_Movement_Status__c, 'Didnt set the correct procedural movement status in Injunction');
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
        bc1.Account__c = testClient.Id;
        bc1.Equipment_Cost__c = 1000;
        insert bc1;
        testBillingContracts.put(bc1.Id,bc1);
        
        Billing_Contract__c bc2 = new Billing_Contract__c();
        bc2.Application__c = app.id;       
        bc2.Collection_Case__c = testCollectionCase.Id;
        bc2.Account__c = testClient.Id;
        bc2.Equipment_Cost__c = 2000;
        insert bc2;
        testBillingContracts.put(bc2.Id,bc2);
        
        Billing_Contract__c bc3 = new Billing_Contract__c();
        bc3.Application__c = app.id;       
        bc3.Collection_Case__c = testCollectionCase.Id;
        bc3.Account__c = testClient.Id;
        bc3.Equipment_Cost__c = 3000;
        insert bc3;
        testBillingContracts.put(bc3.Id,bc3);
    }
    
    static void createInjunction(Collection_Case__c cc, String injDecision, String injStatus, String judicialNumber){
        testInjunction = new Injunction_Procedure__c();
        testInjunction.Collection_Case__c = cc.Id;
        testInjunction.Injuction_Procedure_Status__c = injStatus;
        testInjunction.Injunction_Decision__c = injDecision;
        testInjunction.Injunction_Judicial_Number__c = judicialNumber;
        testInjunction.Judicial_Fee_Amount__c = 100;
        insert testInjunction;
    }
    
    static void createDeclarativeAction(Id injunctionId, String judicialNumber){
        testDeclAction = new Declarative_Action__c();
        testDeclAction.Injunction_Procedure__c = injunctionId;
        testDeclAction.Declarative_Judicial_Number__c = judicialNumber;
        insert testDeclAction;
    }
    
    static void createExecutiveAction(Id injunctionId, String judicialNumber){
        testExecAction = new Executive_Action_Procedure__c();
        testExecAction.Injunction__c = injunctionId;
        testExecAction.Executive_Judicial_Number__c = judicialNumber;
        insert testExecAction;
    }
    
    static void createCriminalProcedure(Id ccId, String judicialNumber){
        testCriminal = new Criminal_Judicial_Procedure__c();
        testCriminal.Collection_Case__c = ccId;
        testCriminal.Criminal_Judicial_Number__c = judicialNumber;
        insert testCriminal;
    }
    
    static void createInsolvencyProcedure(Id accId, String judicialNumber){
        testInsolvency = new Insolvency_Judicial_Procedure__c();
        testInsolvency.Account_Client__c = accId;
        testInsolvency.Insolvency_Judicial_Number__c = judicialNumber;
        insert testInsolvency;
    }
    
    static void createProceduralMovement(Id legalDocumentId, String movementStatus, LegalDocType legalType){
        testProceduralMovement = new Procedural_Movement__c();
        testProceduralMovement.Movement_Status__c = movementStatus;
        if(legalType.equals(LegalDocType.Injunction)){
            testProceduralMovement.Injunction_Procedure__c = legalDocumentId;
        }else if(legalType.equals(LegalDocType.DeclAction)){
            testProceduralMovement.Declarative_Action__c = legalDocumentId;
        }else if(legalType.equals(LegalDocType.ExecAction)){
            testProceduralMovement.Executive_Action_Procedure__c = legalDocumentId;
        }else if(legalType.equals(LegalDocType.Criminal)){
            testProceduralMovement.Criminal_Judicial_Procedure__c = legalDocumentId;
        }else if(legalType.equals(LegalDocType.Insolvency)){
            testProceduralMovement.Insolvency_Judicial_Procedure__c = legalDocumentId;
        }
    }
    
    private enum LegalDocType {Injunction, DeclAction, ExecAction, Criminal, Insolvency}
}