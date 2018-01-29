@isTest(SeeAllData=true)
public class Client_Visit_Handler_Test {

    static Account testClient;
    static Account testVendor;
    static Application__c testApp;
    static List<Equipment__c> testEquipments;
    static List<Contact> testContacts;
    static Attachment testAttachment;
    
    static String contractStatusRunning = 'Contract - Running';
    static String expertCompany = 'Perigest';
    
    static testMethod void shouldSetCreatedDate(){
        //setup
        createRentingApplication(contractStatusRunning);
        
        //test
        Test.startTest();
        Client_Visit__c testVisit = new Client_Visit__c();
        testVisit.Application_Number__c = testApp.Id;
        testVisit.Visit_Status__c = 'Processing';
        insert testVisit;
        Test.stopTest();
        
        //assert
        Client_Visit__c visit = [SELECT Created_Date__c FROM Client_Visit__c WHERE Id = :testVisit.Id];
        system.assert(visit.Created_Date__c != null, 'Didnt set the created date when creating a client visit');
    }
    
    static testMethod void shouldSetExpertCompanyData(){
        //setup
        createRentingApplication(contractStatusRunning);
        
        //test
        Test.startTest();
        Client_Visit__c testVisit = new Client_Visit__c();
        testVisit.Application_Number__c = testApp.Id;
        testVisit.Visit_Status__c = 'Processing';
        insert testVisit;
        Test.stopTest();
        
        //assert
        Client_Visit__c visit = [SELECT Expert_Company__c, Expert_Company_Contact__c FROM Client_Visit__c WHERE Id = :testVisit.Id];
        Client_Visits_Settings__mdt metaData = [SELECT Expert_Company__c, Expert_Company_Contact__c FROM Client_Visits_Settings__mdt];
        system.assert(visit.Expert_Company__c != null, 'Didnt set the expert company when creating a client visit');
        system.assert(visit.Expert_Company_Contact__c != null, 'Didnt set the expert company contact when creating a client visit');
        system.assertEquals(visit.Expert_Company__c, metadata.Expert_Company__c , 'Didnt set the correct expert company when creating a client visit');
        system.assertEquals(visit.Expert_Company_Contact__c, metadata.Expert_Company_Contact__c , 'Didnt set the correct expert company contact when creating a client visit');
    }
    
    static testMethod void shouldSetClientAndVendorData(){
        //setup
        createRentingApplication(contractStatusRunning);
        
        //test
        Test.startTest();
        Client_Visit__c testVisit = new Client_Visit__c();
        testVisit.Application_Number__c = testApp.Id;
        testVisit.Visit_Status__c = 'Processing';
        insert testVisit;
        Test.stopTest();
        
        //assert
        Client_Visit__c visit = [SELECT Account_Client__c, Account_Vendor__c FROM Client_Visit__c WHERE Id = :testVisit.Id];
        system.assertEquals(visit.Account_Client__c, testClient.Id , 'Didnt set the correct client account when creating a client visit');
        system.assertEquals(visit.Account_Vendor__c, testVendor.Id, 'Didnt set the correct vendor account when creating a client visit');    }
    
    /*
    static testMethod void shouldSetEquipmentLocationData(){
        //setup
        createRentingApplication(contractStatusRunning);
        
        //test
        Test.startTest();
        Client_Visit__c testVisit = new Client_Visit__c();
        testVisit.Application_Number__c = testApp.Id;
        testVisit.Visit_Status__c = 'Processing';
        insert testVisit;
        Test.stopTest();
        
        //assert
        Client_Visit__c visit = [SELECT City__c, Street_Address__c, ZIP_Postal_Code__c FROM Client_Visit__c WHERE Id = :testVisit.Id];
        system.assertEquals(visit.City__c, testApp.City__c , 'Didnt set the correct equipment city when creating a client visit');
        system.assertEquals(visit.Street_Address__c, testApp.Street_Address__c, 'Didnt set the correct equipment street when creating a client visit');
        system.assertEquals(visit.ZIP_Postal_Code__c, testApp.ZIP_Postal_Code__c, 'Didnt set the correct equipment postal code when creating the client visit');
    }*/
    
    static testMethod void shouldSetEquipmentRelatedList(){
        //setup
        createRentingApplication(contractStatusRunning);
        Integer numEquipments = 3;
        createEquipments(testApp.Id,numEquipments);
        
        //test
        Test.startTest();
        Client_Visit__c testVisit = new Client_Visit__c();
        testVisit.Application_Number__c = testApp.Id;
        testVisit.Visit_Status__c = 'Processing';
        insert testVisit;
        Test.stopTest();
        
        //assert
        List<Equipment__c> equips = [SELECT Id FROM Equipment__c WHERE Application__c = :testApp.Id];
        system.assertEquals(numEquipments, equips.size(), 'Didnt set the correct amount of related equipments');
    }
    
    static testMethod void shouldSetContactRelatedList(){
        //setup
        createRentingApplication(contractStatusRunning);
        Integer numContacts = 3;
        createContacts(testClient.Id, numContacts);
        
        //test
        Test.startTest();
        Client_Visit__c testVisit = new Client_Visit__c();
        testVisit.Application_Number__c = testApp.Id;
        testVisit.Visit_Status__c = 'Processing';
        insert testVisit;
        Test.stopTest();
        
        //assert
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :testClient.Id];
        system.assertEquals(numContacts, contacts.size(), 'Didnt set the correct amount of related contacts');
    }
    
    static testMethod void shouldSetAttachmentRelatedList(){
        //setup
        createRentingApplication(contractStatusRunning);
        createAttachment(testApp.Id);
        
        //test
        Test.startTest();
        Client_Visit__c testVisit = new Client_Visit__c();
        testVisit.Application_Number__c = testApp.Id;
        testVisit.Visit_Status__c = 'Processing';
        insert testVisit;
        Test.stopTest();
        
        //assert
        Attachment att = [SELECT Id FROM Attachment WHERE ParentID = :testVisit.Id];
        system.assert(att != null, 'Didnt set the auto de aceitacao attachment when creating a client visit');
        
    }
    
    
    static testMethod void shouldSetRentingAppVisitData(){
        //setup
        createRentingApplication(contractStatusRunning);
        
        //test
        Test.startTest();
        Client_Visit__c testVisit = new Client_Visit__c();
        testVisit.Application_Number__c = testApp.Id;
        testVisit.Expert_Company__c = expertCompany;
        testVisit.Visit_Status__c = 'Processing';
        insert testVisit;
        Test.stopTest();
        
        //assert
        Application__c app = [SELECT Expert_Company__c, Request_Visit_Date__c FROM Application__c WHERE Id = :testApp.Id];
        system.assert(app.Request_Visit_Date__c != null, 'Didnt set the request visit date in RentingApp, when creating the client visit');
        system.assertEquals(testVisit.Expert_Company__c, app.Expert_Company__c, 'Didnt set the correct expert company in RentingApp, when creating the client visit');
    }
    
    static testMethod void shouldUpdateRentingAppVisitData(){
        //setup
        createRentingApplication(contractStatusRunning);
        
        //test
        Test.startTest();
        Client_Visit__c testVisit = new Client_Visit__c();
        testVisit.Application_Number__c = testApp.Id;
        testVisit.Visit_Status__c = 'Processing';
        insert testVisit;
        testVisit.Visit_Date__c = Date.today();
        testVisit.Visit_Status__c = 'Completed';
        testVisit.Equipment_Status__c = 'Installed';
        testVisit.Equipment_Suitable_for_Business__c = 'Yes';
        testVisit.Serial_Number_Visible__c = 'Yes';
        testVisit.Visit_Assigned_To__c = 'Mr John Doe';
        testVisit.Visit_Summary__c = 'Amazing Visit';
        update testVisit;
        Test.stopTest();
        
        //assert
        Application__c app = [SELECT Visit_Status__c, Visit_Report_Date__c FROM Application__c WHERE Id = :testApp.Id];
        system.assert(app.Visit_Report_Date__c != null, 'Didnt set the visit report date in RentingApp, when updating the client visit');
        system.assertEquals(testVisit.Visit_Status__c, app.Visit_Status__c, 'Didnt set the correct visit status in RentingApp, when updating the client visit');
    }
    
    /*
     * SETUP helpers
     */
    

    static void createRentingApplication(String contractStatus){
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
        
        //create Vendor
        testVendor = new Account();
        testVendor.Name = 'Test Account Vendor'; 
        testVendor.Type = 'Channel Partner / Vendor';
        testVendor.NIF__c = '503630333';
        testVendor.c2g__CODAInvoiceEmail__c = 'jhonDoe@email.com';
        testVendor.Moloni_Client_ID__c = '1421';
        testVendor.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        testVendor.BillingPostalCode = '1700-178';
        insert testVendor;
        
        //create Renting Application
        testApp= new Application__c(AccClient__c = testClient.ID);
        testApp.Vendor__c = testVendor.Id;
        testApp.Status__c = contractStatus;
        testApp.Street_Address__c = 'Street 3';
        testApp.City__c = 'New York';
        testApp.Zip_Postal_Code__c = '3000-423';
        insert testApp;
    }
    
    static void createEquipments(Id appId, Integer numEquipments){
        testEquipments = new List<Equipment__c>();
        
        for(Integer i = 0; i<numEquipments; i++){
            Equipment__c e = new Equipment__c();
        	e.Application__c = appId;
        	e.Equipment_Quantity__c = 1;
        	e.Equipment_Description__c = 'amazing equipment';
        	e.Equipment_Serial_Number__c = '09723907589';
        	e.Price_Check__c = 100;
            testEquipments.add(e);
        }
        insert testEquipments;
    }
    
    static void createContacts(Id clientId, Integer numContacts){
        testContacts = new List<Contact>();
        for(Integer i = 0; i< numContacts; i++){
            Contact c = new Contact();
            c.AccountId = clientId;
            c.LastName = 'Abreu';
            c.Send_Invoice__c = true;
            testContacts.add(c);
        }
        insert testContacts;
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