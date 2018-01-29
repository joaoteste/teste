@isTest
public class PayableInvoiceHandlerTest {
    
    private static Map<String,String> data = new Map<String, String>();
    
    @isTest static void CreateAndPostPayableInvoiceTest() {
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
        
            Test.startTest();
            BILL_Util_Test.setFinancialForce();
            data = getTestData();
            ID vendorLoginID = [SELECT ID FROM LOGIN__C WHERE Vendor_Vendor__c =: data.get('vendorContactID')].ID; 
            Blob body = Blob.valueOf('Some Text');
            
            Vendor v = new Vendor(vendorLoginID);
            String resNotOk = v.uploadInvoice(null, data.get('appID'), null);
            System.assertEquals(resNotOk,'BODY_NULL','Should give an error: BODY_NULL'); 
            
            String bodyString = EncodingUtil.base64Encode(body);
            Id attchID = v.uploadInvoice(bodyString,  data.get('appID'), null);
            
            System.assertEquals([SELECT NAME FROM ATTACHMENT WHERE ID=:attchID].Name,'Fatura Parceiro - ' + data.get('vendorID') + '.pdf','Attch Not created with the correct name.');
            
            Vendor_Invoice__c vi = v.getVendorInvoice(data.get('appID')); 
            ID vendorInvoiceID = [SELECT ID FROM Vendor_Invoice__c WHERE Application__c=:data.get('appID')].ID;
            
            application__c app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                                Equipment_Cost__c, Vendor_invoice_VAT__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                                Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                                ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                                Interest_Amount__c, Insurance_Special_Value__c, Insurance_Movement_value__c, Client_BBAN__c
                                from application__c where id= :data.get('appID') ];   
            
            
            Vendor_invoice__c vendorInvoice = new Vendor_Invoice__c(Submitted_Date__c= Date.today(), Invoice_Total__c=1000,
                                                                    Invoice_Date__c=date.today(), Vendor_Invoice_Number__c='QWERT',
                                                                    Submitted__c = true, Application__c = data.get('appID'), Account__c = data.get('vendorID') );
            insert vendorInvoice;
            
            PayableInvoiceHandler.CreateAndPostPayableInvoice(vendorInvoice.Id, false);	
            
            Vendor_invoice__c vendorInvoiceToGetError = new Vendor_Invoice__c(Submitted__c = true, Application__c = data.get('appID'), Account__c = data.get('vendorID') );
            insert vendorInvoiceToGetError;
            PayableInvoiceHandler.CreateAndPostPayableInvoice(vendorInvoiceToGetError.Id, true);
            
            //run Queueable_ProcPayableInvoices;
            System.enqueueJob(new Queueable_ProcPayableInvoices(data.get('appID')));
        }
    }
    
    @isTest static void createAndPostPinSFE() {
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
        
            Test.startTest();
            BILL_Util_Test.setFinancialForce();
            data = getTestData();
            
            Vendor_invoice__c vendorInvoice = new Vendor_Invoice__c(Submitted_Date__c= Date.today(), Invoice_Total__c=1000,
                                                                    Invoice_Date__c=date.today(), Vendor_Invoice_Number__c='QWERT',
                                                                    Submitted__c = true, Account__c = data.get('sfeID') );
            insert vendorInvoice;
            
            //create attachment
            Attachment attch = new Attachment();
            attch.body=EncodingUtil.base64Decode('body');
            attch.Name='Factura'; 
            attch.ParentID=vendorInvoice.Id;
            insert attch;        
            
            PayableInvoiceHandler.CreateAndPostPayableInvoice(vendorInvoice.Id, false);	
            
            Vendor_invoice__c vendorInvoiceToGetError = new Vendor_Invoice__c(Submitted__c = true, Account__c = data.get('sfeID') );
            insert vendorInvoiceToGetError;
            PayableInvoiceHandler.CreateAndPostPayableInvoice(vendorInvoiceToGetError.Id, true);
            
            //run Queueable_ProcPayableInvoices;
            System.enqueueJob(new Queueable_ProcPayableInvoices(vendorInvoice.Id));
        }
    }
    
    
    @isTest static void CreatePayableInvoiceFromVendorInvoiceTest() {     
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
        
            Test.startTest();
            BILL_Util_Test.setFinancialForce();
            data = getTestData();
        
        	Vendor_invoice__c vendorInvoice = new Vendor_Invoice__c(Submitted_Date__c= Date.today(), Invoice_Total__c=1000,
                                                                Invoice_Date__c=date.today(), Vendor_Invoice_Number__c='QWERT1232',
                                                                Submitted__c = true, Application__c = data.get('appID'), Account__c = data.get('vendorID') );
        
            insert vendorInvoice;
            List<Vendor_Invoice__c> viList = new List<Vendor_Invoice__c>();
            viList.add(vendorInvoice);
            
            /*List<Vendor_Invoice__c> viList = [SELECT ID, NAME, Due_Date__c,Invoice_Date__c,Invoice_Total__c,Status__c,Submitted__c,
    Submitted_Date__c, Vendor_Invoice_Number__c, Application__c, Account__c, Account__r.c2g__CODAAccountsPayableControl__c,
    Account__r.c2g__CODAOutputVATCode__c, Tax_Code__c, Account__r.Name, Account__r.c2g__CODADefaultExpenseAccount__c, Application__r.Name,
    Invoice_Net__c
    FROM Vendor_Invoice__c
    WHERE Application__c =: data.get('appID') AND Submitted__c=true AND Status__c = 'Draft'];*/
            
            Attachment attch = new Attachment();
            attch.body=EncodingUtil.base64Decode('body');
            attch.Name='Factura'; 
            attch.ParentID=viList[0].Id;
            insert attch;
            
            PayableInvoiceHandler pih = new PayableInvoiceHandler();
            pih.createPayableInvoiceFromVendorInvoice(viList);
            Test.stopTest();
        }
        
    }
    
    @isTest static void Queueable_ProcPayableInvoicesTest(){ 
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
        
            Test.startTest();
            BILL_Util_Test.setFinancialForce();
            data = getTestData();
        
            Vendor_invoice__c vendorInvoice = new Vendor_Invoice__c(Submitted_Date__c= Date.today(), Invoice_Total__c=1000,
                                                                    Invoice_Date__c=date.today(), Vendor_Invoice_Number__c='INVNUMBER1234',
                                                                    Submitted__c = true, Application__c = data.get('appID'), Account__c = data.get('vendorID') );
            
            insert vendorInvoice;
            
            Attachment attch = new Attachment();
            attch.body=EncodingUtil.base64Decode('body');
            attch.Name='Factura'; 
            attch.ParentID=vendorInvoice.Id;
            insert attch;        
        	System.enqueueJob(new Queueable_ProcPayableInvoices(data.get('appID'), true));
        }
    }
    
    @isTest static void batchTest() { 
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
        
            Test.startTest();
            BILL_Util_Test.setFinancialForce();
            data = getTestData();
        
            application__c app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                                Equipment_Cost__c, Vendor_invoice_VAT__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                                Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                                ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                                Interest_Amount__c, Insurance_Special_Value__c, Insurance_Movement_value__c, Client_BBAN__c
                                from application__c where id= :data.get('appID') ];   
            
            
            Vendor_invoice__c vendorInvoice = new Vendor_Invoice__c(Submitted_Date__c= Date.today(),Invoice_Total__c=1000,
                                                                    Invoice_Date__c=date.today(), Vendor_Invoice_Number__c='testeInvoice',
                                                                    Submitted__c = true, Application__c = data.get('appID'), Account__c = data.get('vendorID') );
            
            
            insert vendorInvoice;
            
            Attachment attch = new Attachment();
            attch.body=EncodingUtil.base64Decode('body');
            attch.Name='Factura'; 
            attch.ParentID=vendorInvoice.Id;
            insert attch;
            
            String query ='SELECT Name, Invoice_Net__c, Invoice_Total__c, Account__c, Submitted_Date__c, Invoice_Date__c, Vendor_Invoice_Number__c,';
            query +=' Submitted__c, application__c, Account__r.c2g__CODADefaultExpenseAccount__c, Application__r.Name,Account__r.Type, ';
            query +=' Account__r.c2g__CODAAccountsPayableControl__c, Account__r.c2g__CODAOutputVATCode__c,Tax_Code__c, ';
            query +=' Account__r.c2g__CODASalesTaxStatus__c, Account__r.c2g__CODAVATStatus__c, Application__r.Invoice_Payment_Date__c, ';
            query +=' Account__r.c2g__CODATaxCalculationMethod__c,Account__r.BillingPostalCode,Status__c FROM Vendor_Invoice__c LIMIT 1';
            
            PayableInvoiceHandler pih = new PayableInvoiceHandler(query);
            Database.executeBatch(pih,10);
            
            Test.stopTest();
        }
        
    }
    
    @isTest static void batchTestBulkPost() {  
       	User usr = [Select id from User where Id = :UserInfo.getUserId()];
    	List <Vendor_Invoice__c> vendorInvoiceBeforeBatch = new List<Vendor_Invoice__c>();
        System.RunAs(usr){
        	
            Test.startTest();
            BILL_Util_Test.setFinancialForce();
            data = getTestData();

            application__c app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                            Equipment_Cost__c, Vendor_invoice_VAT__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                            Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                            ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                            Interest_Amount__c, Insurance_Special_Value__c, Insurance_Movement_value__c, Client_BBAN__c
                            from application__c where id= :data.get('appID')];  
        
            application__c app2=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                                Equipment_Cost__c, Vendor_invoice_VAT__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                                Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                                ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                                Interest_Amount__c, Insurance_Special_Value__c, Insurance_Movement_value__c, Client_BBAN__c
                                from application__c where id= :data.get('appID2')];
            
            Vendor_invoice__c vendorInvoice = new Vendor_Invoice__c(Submitted_Date__c= Date.today(),Invoice_Total__c=500,
                                                                    Invoice_Date__c=date.today(), Vendor_Invoice_Number__c='testeInvoice', Status__c = 'Draft',
                                                                    Submitted__c = true, Application__c = data.get('appID'), Account__c = data.get('vendorID') );
            
            Vendor_invoice__c vendorInvoice2 = new Vendor_Invoice__c(Submitted_Date__c= Date.today(),Invoice_Total__c=500,
                                                                    Invoice_Date__c=date.today(), Vendor_Invoice_Number__c='testeInvoice234', Status__c = 'Draft',
                                                                    Submitted__c = true, Application__c = data.get('appID2'), Account__c = data.get('vendorID') );
            
            insert vendorInvoice;   
            insert vendorInvoice2;
            
            Attachment attch = new Attachment();
            attch.body=EncodingUtil.base64Decode('body');
            attch.Name='Factura'; 
            attch.ParentID=vendorInvoice.Id;
            insert attch;
            
            Attachment attch2 = new Attachment();
            attch2.body=EncodingUtil.base64Decode('body');
            attch2.Name='Factura'; 
            attch2.ParentID=vendorInvoice2.Id;
            insert attch2;

            vendorInvoiceBeforeBatch = [SELECT ID, Status__c FROM Vendor_Invoice__c WHERE Submitted__c = true AND Status__c = 'Draft'];
            
            String query = 'SELECT ID, NAME,Invoice_Date__c,Due_Date__c,Invoice_Total__c,Status__c, ';
            query += 'Submitted__c,Submitted_Date__c, Vendor_Invoice_Number__c, Application__c, Account__c, ';
            query += 'Account__r.c2g__CODAAccountsPayableControl__c,Account__r.c2g__CODAOutputVATCode__c, Account__r.Type,';
            query += 'Tax_Code__c, Account__r.Name, Account__r.c2g__CODADefaultExpenseAccount__c, Application__r.Invoice_Payment_Date__c, ';
            query += 'Application__r.Name, Invoice_Net__c ';
            query += 'FROM Vendor_Invoice__c ';
            query += 'WHERE Submitted__c=true AND Status__c=\'Draft\' LIMIT 30';
            
            PayableInvoiceHandler pih = new PayableInvoiceHandler(query);
            Id batchJobId = Database.executeBatch(new PayableInvoiceHandler(query, true), 30); 
            
            Test.stopTest();

        }

        List<Vendor_Invoice__c> vendorInvoiceAfterBatch = new List<Vendor_Invoice__c>();
        vendorInvoiceAfterBatch = [SELECT ID, Status__c FROM Vendor_Invoice__c WHERE Submitted__c = true AND Status__c = 'Completed'];
        List<c2g__codaPurchaseInvoice__c> codaInvoiceList= [SELECT ID FROM c2g__CodaPurchaseInvoice__c Where Vendor_Invoice__c IN: vendorInvoiceAfterBatch];
        
        System.assertEquals(2, codaInvoiceList.size(), 'The Coda Purchase Invoices were not found');
        System.assertEquals(vendorInvoiceBeforeBatch.size(), vendorInvoiceAfterBatch.size(), 'The Vendor Invoices did not match');

    }
    
    @isTest static void CreatePayableInvocesFromVendorInvoiceListTest(){
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
        
            Test.startTest();
            BILL_Util_Test.setFinancialForce();
            data = getTestData();
        
        
            Vendor_invoice__c vendorInvoice = new Vendor_Invoice__c(Submitted_Date__c= Date.today(),Invoice_Total__c=1000,
                                                                    Invoice_Date__c=date.today(), Vendor_Invoice_Number__c='testeInvoice2',
                                                                    Submitted__c = true, Application__c = data.get('appID'), Account__c = data.get('vendorID') );
            insert vendorInvoice;
            
            Attachment attch = new Attachment();
            attch.body=EncodingUtil.base64Decode('body');
            attch.Name='Factura'; 
            attch.ParentID=vendorInvoice.Id;
            insert attch;
            
            List<Id> viListID = new List<Id>();
            viListID.add(vendorInvoice.Id);
            String res = PayableInvoiceHandler.CreatePayableInvocesFromVendorInvoiceList(viListID);
            System.debug(res);
            Test.stopTest();
        }
    }
    
    
    public static Map<String, ID> getTestData() {
       
        Map<String, ID> dataMap = new Map<String,ID>();
        List<Account> accList = new List<Account>();
        List<c2g__codaGeneralLedgerAccount__c> generalLedgerAccountList = new List<c2g__codaGeneralLedgerAccount__c>();
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAcc = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAcc.Name= '211113 - CLIENTES NACIONAIS';
        generalLedgerAcc.c2g__ReportingCode__c='211113';
        generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
        generalLedgerAccountList.add(generalLedgerAcc);
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAccVendor = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAccVendor.Name= '311325 - MERCADORIAS';
        generalLedgerAccVendor.c2g__ReportingCode__c='311325';
        generalLedgerAccVendor.c2g__Type__c = 'Balance Sheet';
        generalLedgerAccountList.add(generalLedgerAccVendor);
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAccVendorPayableControl = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAccVendorPayableControl.Name= '221143 - FORNECEDORES LEASING';
        generalLedgerAccVendorPayableControl.c2g__ReportingCode__c='221143';
        generalLedgerAccVendorPayableControl.c2g__Type__c = 'Balance Sheet';
        generalLedgerAccountList.add(generalLedgerAccVendorPayableControl);
        
        insert generalLedgerAccountList;
        
        ID glacc = generalLedgerAccountList[0].id;
        ID glaccDefaultVendor = generalLedgerAccountList[1].id;
        ID glaccVendorPayableControl = generalLedgerAccountList[2].id;
        
        c2g__codaTaxCode__c taxcode = new c2g__codaTaxCode__c();
        taxcode.Name = 'VCONT23TESTE';
        taxcode.c2g__Description__c='Vendes IVA 23%';
        taxcode.c2g__GeneralLedgerAccount__c=glacc;
        insert taxcode;
        ID vatID = taxcode.id;
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630311';
        vendor.c2g__CODATaxCalculationMethod__c = 'Gross';
        vendor.c2g__CODAVATStatus__c ='Home';
        //vendor.c2g__CODABankIBANNumber__c ='PT50000700000003253768222';
        vendor.c2g__CODAOutputVATCode__c = vatID;
        vendor.c2g__CODADefaultExpenseAccount__c = glaccDefaultVendor;
        vendor.c2g__CODAAccountsPayableControl__c = glaccVendorPayableControl;
        //vendor.c2g__CODAAccountsReceivableControl__c = glacc;
        accList.add(vendor);
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '504092090';
        client.c2g__CODATaxCalculationMethod__c = 'Gross';
        client.c2g__CODAVATStatus__c ='Home';
        //client.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        client.c2g__CODAInputVATCode__c = vatID;
        accList.add(client);
        
        //New SFE
        Account sfe = new Account();
        sfe.Name = 'Test Account Service Provider'; 
        sfe.Type = 'Service Provider';
        sfe.NIF__c = '503630311';
        //sfe.c2g__CODABankIBANNumber__c ='PT50000700000003253768222';
        sfe.BillingCity = 'Amora2';
        sfe.BillingStreet = 'Rua lá de fora2';
        sfe.BillingPostalCode = '2048-124';
        accList.add(sfe);
        
        insert accList;
        ID vendorID =  accList[0].ID;
        ID clientID =  accList[1].ID;
        ID sfeID =  accList[2].ID;
        
        dataMap.put('vendorID', accList[0].ID);
        dataMap.put('clientID', accList[1].ID);
        dataMap.put('sfeID',accList[2].id);
        
        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendorID;
        insert vendorContact;
        dataMap.put('vendorContactID', vendorContact.ID);
        
        //New Login
        Login__c login = new Login__c();
        login.IdVendor__c = vendorID;
        login.Username__c = 'vendor@email.pt';
        login.Vendor_Vendor__c = vendorContact.Id;
        insert Login;
        Authenticate.generatorPassword(login.Id, 4);
        dataMap.put('loginID', login.ID);
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId=clientID;
        insert contact;
        dataMap.put('contactID', contact.ID);
        
        dataMap.put('appID', createApp(client.id, vendor.id, vendorContact).id);
        dataMap.put('appID2', createApp(client.id, vendor.id, vendorContact).id);
        
        
        dsfs__DocuSign_Status__c docuSignStatusTest = new dsfs__DocuSign_Status__c(dsfs__subject__c = 'Auto Aceitação', dsfs__Envelope_Status__c = 'Sent'
                                                                                   ,dsfs__DocuSign_Envelope_ID__c = '5FD15451-8568-4E58-A427-5442A3F43970'
                                                                                   ,docusign_application_status__c = dataMap.get('appID'));
        insert docuSignStatusTest;
        dataMap.put('docuSignStatusID', docuSignStatusTest.ID);
        
        dsfs__DocuSign_Status__c docuSignStatusTest2 = new dsfs__DocuSign_Status__c(dsfs__subject__c = 'Auto Aceitação', dsfs__Envelope_Status__c = 'Sent'
                                                                                    ,dsfs__DocuSign_Envelope_ID__c = '5FD15451-8568-4E58-A427-5442A3F43970'
                                                                                    ,docusign_application_status__c = dataMap.get('appID2'));
        insert docuSignStatusTest2;
        dataMap.put('docuSignStatusID2', docuSignStatusTest2.ID);
        
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusTest = new dsfs__DocuSign_Recipient_Status__c(name='Steve Vai',dsfs__Parent_Status_Record__c = docuSignStatusTest.id
                                                                                                                ,dsfs__Recipient_Status__c='Completed',dsfs__Docusign_Recipient_Email__c = 'Vai@worldit.pt'
                                                                                                                ,dsfs__Contact__c = contact.id, dsfs__docusign_recipient_id__c='502C9EE2-3C61-4818-8023-5DE2B9E0B999' 
                                                                                                               );
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusTest2 = new dsfs__DocuSign_Recipient_Status__c(name='Merlyn Monroe',dsfs__Parent_Status_Record__c = docuSignStatusTest2.id
                                                                                                                 ,dsfs__Recipient_Status__c='Sent',dsfs__Docusign_Recipient_Email__c = 'Monroe@worldit.pt'
                                                                                                                 ,dsfs__Contact__c = contact.id, dsfs__docusign_recipient_id__c='502C9EE2-3C61-4818-3333-5DE2B9E0B999' 
                                                                                                                );
        insert docuSignRecipientStatusTest;
        insert docuSignRecipientStatusTest2;
        dataMap.put('docuSignRecipientID', docuSignRecipientStatusTest.ID);
        
        return dataMap;
    }
    
    private static Application__c createApp(ID clientID, ID vendorID, Contact vendorContact){
        Application__c app = new Application__c();
        app.AccClient__c = clientID;
        app.Vendor__c = vendorID;
        // app.Client_Signer_1__c=con.id;
        app.Vendor_Primary__c=vendorContact.id;
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
        //app.Vendor_Invoice_Amount__c = 2402.63;
        app.Equipment_Cost__c =1000;
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
        insert app;
        return app;
    }
    
}