@isTest
private class CandorDocumentsTest {

	private static Map<String, sObject> getTestData(){
		
		Map<String, sObject> dataMap = new Map<String, sObject>();

		//New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630311';        
        //dataMap.put('vendor', vendor);
        insert vendor;

        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendor.Id;
        //dataMap.put('vendorContact', vendorContact);
        insert vendorContact;
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '504092090';
        Client.Date_Of_Establishment__c = Date.newInstance(2015, 01, 01);
        client.BillingCountry = 'Portugal';
        //dataMap.put('client', client);
        insert client;
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId=client.ID;
        //dataMap.put('contact', contact);   
        insert contact;
        
        //Application__c
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        app.Vendor_Primary__c=vendorContact.id;
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
        app.Equipment_Cost__c = 2402.63;
        app.Insurance_Special_Value__c = 9.31;
        app.Insurance_Movement_value__c = 11.01;
        app.Client_BBAN__c = '004563904014640899590';
        app.Payment_Freq__c ='Monthly';
        app.Payment_Amount__c = 2500;
        app.Invoice_Payment_Date__c =date.today();
        app.Generate_Billing__c=true;
        app.Annual_Interest_Rate__c=9.2;
        app.Vendor_Diluted_Doc_Fee__c=true;
        app.ATM_Reference__c=true;
        app.Interim_Fee__c=true;
        app.ATM_Reference_Costs__c=10;
        app.eSignature_Contract__c=true;
        app.Paper_Contract__c=true;
        app.Insurance_Pro_Rata_Checkbox__c=true;
        dataMap.put('app', app);

        //Docusign data
        dsfs__DocuSign_Status__c docuSignStatusTest = new dsfs__DocuSign_Status__c();
    	docuSignStatusTest.dsfs__subject__c = 'Auto Aceitação';
    	docuSignStatusTest.dsfs__Envelope_Status__c = 'Sent';
    	docuSignStatusTest.dsfs__DocuSign_Envelope_ID__c = '5FD15451-8568-4E58-A427-5442A3F43970';
    	docuSignStatusTest.docusign_application_status__c = app.id;

        dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusTest = new dsfs__DocuSign_Recipient_Status__c();
    	docuSignRecipientStatusTest.name='Steve Vai';
    	docuSignRecipientStatusTest.dsfs__Parent_Status_Record__c = docuSignStatusTest.id;
    	docuSignRecipientStatusTest.dsfs__Recipient_Status__c='Completed';
    	docuSignRecipientStatusTest.dsfs__Docusign_Recipient_Email__c = 'Vai@worldit.pt';
		docuSignRecipientStatusTest.dsfs__Contact__c = contact.id;
		docuSignRecipientStatusTest.dsfs__docusign_recipient_id__c='502C9EE2-3C61-4818-8023-5DE2B9E0B999'; 

        dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusTest2 = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipientStatusTest2.name='Merlyn Monroe';
        docuSignRecipientStatusTest2.dsfs__Parent_Status_Record__c = docuSignStatusTest.id;
		docuSignRecipientStatusTest2.dsfs__Recipient_Status__c='Sent';
		docuSignRecipientStatusTest2.dsfs__Docusign_Recipient_Email__c = 'Monroe@worldit.pt';
		docuSignRecipientStatusTest2.dsfs__Contact__c = contact.id;
		docuSignRecipientStatusTest2.dsfs__docusign_recipient_id__c='502C9EE2-3C61-4818-3333-5DE2B9E0B999'; 

        dataMap.put('docuSignStatus', docuSignStatusTest);
        dataMap.put('docuSignRecipient', docuSignRecipientStatusTest);
        dataMap.put('docuSignRecipient2', docuSignRecipientStatusTest2);

        return dataMap;
	}
	
	@isTest static void buildDocumentsTest() {
		Map<String, sObject> data =  getTestData();
		Application__c app = (Application__c )data.get('app');
		insert app;

		Test.startTest();
		CandorDocuments cd_auto = new CandorDocuments('AUTO');
		Id attachAutoId = cd_auto.buildDocument(app.Id, 'Auto de Aceitação');
		CandorDocuments cd_renting = new CandorDocuments('RENTING');
		Id attachContractId = cd_renting.buildDocument(app.Id, 'Contract');

		Attachment AutoAttach = [SELECT ID, NAME, ParentId FROM ATTACHMENT WHERE ID=:attachAutoId];
		Attachment ContractAttach = [SELECT ID, NAME, ParentId FROM ATTACHMENT WHERE ID=:attachContractId];

		System.assertEquals('Auto de Aceitação', AutoAttach.Name, 'Name of auto should be Auto de Aceitação');
		System.assertEquals('Contract', ContractAttach.Name, 'Name of Renting Contract should be Contract');

		System.assertEquals(app.Id, AutoAttach.ParentId, 'Auto parentID should be ' + app.Id );
		System.assertEquals(app.Id, ContractAttach.ParentId, 'Contract parentID should be ' + app.Id);
		Test.stopTest();
	}
	
	@isTest (SeeAllData=true) static void DocuSignMethodsTest() {
        Map<String, sObject> data =  getTestData();
        Application__c app = (Application__c )data.get('app');
        insert app;

        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
		CandorDocuments.sendDocumentThroughDocuSign(envelope);

        DocuSignAPI.Correction corrections = new DocuSignAPI.Correction();
        CandorDocuments.CorrectAndResendContractDocuSign(corrections);

        CandorDocuments.voidDocumentDocuSign('DOCUSIGNID_TESTE', 'reason');

        CandorDocuments.getautolink(app.Id);
        CandorDocuments.getContractlink(app.Id);

        String[] DocuSignEnvelopeID = new String[2];
        DocuSignEnvelopeID[0] = 'ENVELOPE_ID_TESTE';
        DocuSignEnvelopeID[1] = 'ENVELOPE_ID_TESTE_2';
        CandorDocuments.deleteEnvelopeThroughDocuSign(DocuSignEnvelopeID);
	}

    @isTest (SeeAllData=true) static void DocuSignAPITest() {
        DocuSignAPI.APIServiceSoap dsAPISend = new DocuSignAPI.APIServiceSoap();
        try{
            DocuSignAPI.DeleteEnvelopesArg Arg = new DocuSignAPI.DeleteEnvelopesArg();
            dsAPISend.DeleteEnvelopes(Arg);
        }catch(Exception e){
            System.debug('[CandorDocuments] - TESTE DocuSignAPI ' + e);
        }
        try{
            DocuSignAPI.FolderFilter filter2 = new DocuSignAPI.FolderFilter();
            dsAPISend.GetFolderItems(filter2);
        }catch(Exception e){
            System.debug('[CandorDocuments] - TESTE DocuSignAPI ' + e);
        }
        try{
            DocuSignAPI.FoldersFilter filter = new DocuSignAPI.FoldersFilter();
            dsAPISend.GetFolderList(filter);
        }catch(Exception e){
            System.debug('[CandorDocuments] - TESTE DocuSignAPI ' + e);
        }
        try{
            DocuSignAPI.EnvelopeStatus es = dsAPISend.RequestStatusEx('2F528A76-TESTE-4F8A-8DFC-4A56F14D0871');            
        }catch(Exception e){
            System.debug('[CandorDocuments] - TESTE DocuSignAPI ' + e);
        }
    }

    //HP - 2017/06/05
    @isTest static void createDocuSignSFObjectsTest(){

        //Create Data for testing      

        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '502617896';        
        insert vendor;
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '510371787';
        Client.Date_Of_Establishment__c = Date.newInstance(2015, 01, 01);
        insert client;
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId=client.ID;
        insert contact;
        
        DocuSignAPI.EnvelopeStatus EnvelopeStatus = new DocuSignAPI.EnvelopeStatus();
        EnvelopeStatus.EnvelopeID = 'EnvelopeIDTest';
        EnvelopeStatus.Status = 'Sent';
        EnvelopeStatus.Subject = 'This is a DocuSign Envelope Test Subject';
        EnvelopeStatus.UserName = 'Charlie Parker, The Bird';
        EnvelopeStatus.Email = 'sax_bird@jazz.test';

        Application__c testApp = new Application__c();
        testApp.Vendor__c = vendor.Id;
        testApp.AccClient__c = client.Id;
        insert testApp;

        String APP_ID               = testApp.Id;
        String VENDOR_ID            = vendor.ID;
        String CLIENT_ID            = client.ID;
        String RECIPIENT_CONTACT_ID = contact.ID;
        String RECIPIENT_ACC_ID     = client.ID;

        List<DocuSignAPI.CustomField> customFieldList = new List<DocuSignAPI.CustomField>();      
        DocuSignAPI.CustomField field = CandorDocuments.createDocuSignCostumFields('DSFSSourceObjectId', APP_ID, true); 
        customFieldList.add(field);
        DocuSignAPI.CustomField fieldAcc = CandorDocuments.createDocuSignCostumFields('##SFAccount', VENDOR_ID, true);
        customFieldList.add(fieldAcc);        
        DocuSignAPI.CustomField fieldClientAcc = CandorDocuments.createDocuSignCostumFields('Client', CLIENT_ID, true);
        customFieldList.add(fieldClientAcc);
        DocuSignAPI.ArrayOfCustomField arrayOfCustomField = new DocuSignAPI.ArrayOfCustomField();
        arrayOfCustomField.CustomField  = new DocuSignAPI.CustomField[customFieldList.size()];
        arrayOfCustomField.CustomField = customFieldList;
        EnvelopeStatus.CustomFields = arrayOfCustomField;

        DocuSignAPI.RecipientStatus[] dsAPI_rs_list = new DocuSignAPI.RecipientStatus[1];
        dsAPI_rs_list[0] = new DocuSignAPI.RecipientStatus();
        dsAPI_rs_list[0].UserName = 'Stan Getz';
        dsAPI_rs_list[0].Email = 'getz_the_man@ipanemagirl.email';
        dsAPI_rs_list[0].Status = 'Delivered';
        dsAPI_rs_list[0].RoutingOrder = 1;
        dsAPI_rs_list[0].RecipientId = '1';
        dsAPI_rs_list[0].CustomFields = new DocuSignAPI.ArrayOfString1();
        dsAPI_rs_list[0].CustomFields.CustomField = new String[2];
        dsAPI_rs_list[0].CustomFields.CustomField[0] = RECIPIENT_ACC_ID;
        dsAPI_rs_list[0].CustomFields.CustomField[1] = RECIPIENT_CONTACT_ID;

        EnvelopeStatus.RecipientStatuses = new DocuSignAPI.ArrayOfRecipientStatus();
        EnvelopeStatus.RecipientStatuses.RecipientStatus = dsAPI_rs_list;

        Test.startTest();

        //Run functions to test
        Dsfs__docusign_Status__c dsStatus = CandorDocuments.createDocuSignEnvelopeStatusSFObject(EnvelopeStatus);
        insert dsStatus;
        List<dsfs__DocuSign_Recipient_Status__c> dsRecipientStatusList = CandorDocuments.createDocuSignRecipientStatusSFObject(EnvelopeStatus, dsStatus.Id);
        
        //Verify asserts
        //Dsfs__docusign_Status__c
        System.assertEquals(dsStatus.dsfs__DocuSign_Envelope_ID__c, EnvelopeStatus.EnvelopeID);
        System.assertEquals(dsStatus.dsfs__Envelope_Status__c, EnvelopeStatus.Status);
        System.assertEquals(dsStatus.dsfs__Subject__c, EnvelopeStatus.Subject);
        System.assertEquals(dsStatus.dsfs__Sender__c, EnvelopeStatus.UserName);
        System.assertEquals(dsStatus.dsfs__Sender_Email__c, EnvelopeStatus.Email);
        System.assertEquals(dsStatus.docusign_Application_Status__c, APP_ID);
        System.assertEquals(dsStatus.dsfs__Company__c, VENDOR_ID);
        System.assertEquals(dsStatus.client_Account__c, CLIENT_ID);

        //dsfs__DocuSign_Recipient_Status__c
        for(dsfs__DocuSign_Recipient_Status__c dsRecipientStatus : dsRecipientStatusList){
            System.assertEquals(dsRecipientStatus.Name,  dsAPI_rs_list[0].UserName);
            System.assertEquals(dsRecipientStatus.dsfs__DocuSign_Recipient_Email__c, dsAPI_rs_list[0].Email);
            System.assertEquals(dsRecipientStatus.dsfs__Recipient_Status__c, dsAPI_rs_list[0].Status);
            System.assertEquals(dsRecipientStatus.dsfs__DocuSign_Routing_Order__c, dsAPI_rs_list[0].RoutingOrder);
            System.assertEquals(dsRecipientStatus.dsfs__DocuSign_Recipient_Id__c, dsAPI_rs_list[0].RecipientId);
            System.assertEquals(dsRecipientStatus.dsfs__Parent_Status_Record__c, dsStatus.Id);
            System.assertEquals(dsRecipientStatus.dsfs__Account__c, RECIPIENT_ACC_ID);
            System.assertEquals(dsRecipientStatus.dsfs__Contact__c, RECIPIENT_CONTACT_ID);            
        }

        Test.stopTest();
    } 

    @isTest static void createDocuSignRecipientAndTabTest(){

        //New Account Client
        Account client = new Account();
        client.Name    = 'Head Hunters'; 
        client.Type    = 'Customer - Channel';
        client.NIF__c  = '509143458';
        Client.Date_Of_Establishment__c = Date.newInstance(2015, 01, 01);
        insert client;

        //New Contact
        Contact contact   = new contact();
        contact.FirstName = 'Herbie';
        contact.LastName  = 'Hancock';
        contact.Email     = 'herbie_hancock@headhunters.test';
        contact.Role__c   = 'Binding Power';
        contact.AccountId = client.ID;
        insert contact;

        Integer RECIPIENT_ID   = 1;
        String TYPE_X          = 'Carbon Copy';
        Integer ROUTING_ORDER  = 1;
        String ROLE_NAME       = 'Signer x';
        String EMAIL           = contact.Email;
        String USER_NAME       = contact.LastName;
        String ACCOUNT_ID      = client.Id;
        String CONTACT_ID      = contact.Id;
        Integer DOCUMENT_ID    = 1;
        String ACHORTAB_STRING = '\\sX\\';

        Test.startTest();

        DocuSignAPI.Recipient dr = CandorDocuments.createDocuSignRecipient(RECIPIENT_ID, TYPE_X, ROUTING_ORDER, ROLE_NAME, EMAIL, USER_NAME, ACCOUNT_ID, CONTACT_ID);
        DocuSignAPI.Tab dt = CandorDocuments.createDocuSignTab(RECIPIENT_ID, DOCUMENT_ID, TYPE_X, ACHORTAB_STRING);

        //Recipient
        System.assertEquals(dr.ID,  RECIPIENT_ID);
        System.assertEquals(dr.Type_x, TYPE_X);
        System.assertEquals(dr.RoutingOrder, ROUTING_ORDER);
        System.assertEquals(dr.RoleName, ROLE_NAME);
        System.assertEquals(dr.Email, EMAIL);
        System.assertEquals(dr.UserName, USER_NAME);
        System.assertEquals(dr.RequireIDLookup, false);
        System.assertEquals(dr.CustomFields.CustomField[0], ACCOUNT_ID);
        System.assertEquals(dr.CustomFields.CustomField[1], CONTACT_ID);

        //TAB
        System.assertEquals(dt.Type_x, TYPE_X);
        System.assertEquals(dt.DocumentID, DOCUMENT_ID);
        System.assertEquals(dt.AnchorTabItem.AnchorTabString, ACHORTAB_STRING);

        Test.stopTest();
    }
}