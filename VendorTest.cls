@isTest(SeeAllData=true)

public class VendorTest implements HttpCalloutMock{

    public Account acc2;
    public Contact con2;
    public login__c loginrecord;
    public Client client1;
    public static Map<String, ID> data = getTestData();
    
    //class with the code of HttpCalloutMock
    public HTTPResponse respond(HTTPRequest req){
        String Body;

 // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Autentication
        if(req.getEndpoint().contains('grant/?grant_type=password&client_id=')){
            res.setBody('{"access_token":"2b6fe0fb8829233ef5d3daf90c111ff697b13a7c","expires_in":3600,"token_type":"bearer","scope":null,"refresh_token":"6de8a8043345ac210fab9c775dbc785ee6744162"}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('grant/?grant_type=refresh_token&client_id=')){
	        res.setBody('{"access_token":"2b6fe0fb8829233ef5d3daf90c111ff697b13a7c","expires_in":3600,"token_type":"bearer","scope":null,"refresh_token":"6de8a8043345ac210fab9c775dbc785ee6744162"}');
	        res.setStatusCode(200);
        //Customers
        }else if(req.getEndpoint().contains('customers/insert/?access_token=')){
            res.setBody('{"valid":1,"customer_id":2399428}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('customers/update/?access_token=')){
            res.setBody('{"valid":1,"customer_id":2399428}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('customers/getByVat')){
            res.setBody('{"customer_id":2399428}');
            res.setStatusCode(200);
        //Invoices
        }else if(req.getEndpoint().contains('invoices/insert/?access_token=')){
            res.setBody('{"valid":1,"document_id":189667356, "mb_reference": {"entity": "10611", "reference": "500123123", "value": "10.20"}}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('/invoices/getOne/') && req.getBody().contains('your_reference')){
            res.setBody('{}');  // to simulate that the invoice wasn't already created
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('/invoices/getOne/') && req.getBody().contains('document_id')){
            res.setBody('{"number":23,"document_set_name":"Serie2017"}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('invoices/update/?access_token=')){
            res.setBody('{"valid":1,"document_id":189667356,"status":1}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('invoices/generateMBReference/?access_token=')){
            res.setBody('{"valid":1,"entity":10611,"reference":500004549,"value":0,01}');
            res.setStatusCode(200);   
        }else if(req.getEndpoint().contains('documents/getPDFLink')){
            res.setBody('{"valid":1,"url":"https://www.moloni.com/downloads/?h=3ed61efdf77463fd7f06e8bd1e0680a9&d=189606041"}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('https://www.moloni.com/downloads/index')){
            String myString = 'StringToBlob';
            Blob bodyBlob = Blob.valueof(myString);
            res.setBodyAsBlob(bodyBlob);  //TODO
            res.setStatusCode(200);
        // Credit Note
        }else if(req.getEndpoint().contains('creditNotes/insert')){
            res.setBody('{"valid":1,"document_id":189897721}');  //TODO
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('creditNotes/getOne')){
            res.setBody('{"number":111,"document_set_name":"Serie2017"}');  //TODO
            res.setStatusCode(200);
        }
      
        System.debug('test body: ' + Body);
        return res;        

    }
    
    public VendorTest(){

        this.acc2 = new Account();                                          //cria account
        this.acc2.name = 'nameacc2';
        this.acc2.type='Channel Partner / Vendor';
        this.acc2.nif__c='510329551';
        insert acc2;                                                            //Insere Account       

        this.con2 = new Contact();                                          //cria contacto
        this.con2.LastName = acc2.Name;
        insert con2;                                                            //Insere contacto       
        
        this.loginrecord = new login__c();                                  //Cria registo de Login
        this.loginrecord.idVendor__c = this.acc2.id;                                        //Com idVendor da acc2
        this.loginrecord.Master__c = false;
        this.loginrecord.Vendor_Vendor__c = this.con2.id;
        this.loginrecord.username__c='test@example.com';
        insert loginrecord;                                                     //Insere Login Record
        
        this.client1 = new Client('505241943');
        
    }

    //Testa o getApps() e getApprovedApps do Vendor  33%
    @isTest 
    public static void getAppsTester(){  
        VendorTest dadoscriados = new VendorTest();                                 
        
        Vendor vend2 = new Vendor(dadoscriados.loginrecord.Id);
        Test.startTest();                                       //cria vendor
        List<Application__c> getappslist = vend2.getApps();                                         //Corre o metodo getApps().
        Test.stopTest();
        System.assert(dadoscriados.acc2 != null,'Account não criada com sucesso');                  //Verifica se o construtor trabalha.
        System.assert(getappslist != null,'Devolvida lista nula');                                  //Verifica se getApps() devolve.
        
        List<Application__c> getaprovedappslist = vend2.getApprovedApps(dadoscriados.acc2.id);      //Corre o metodo getAprovedApps().                                                                              
        System.assert(getaprovedappslist != null,'Devolvida lista nula');                             //Verifica se getApps() devolve.

        vend2.getContractApps();                        
    }   
    
    //Testa o getClients() do Vendor  42%
    @isTest
    public static void getClientsTester(){
        VendorTest dadoscriados = new VendorTest();
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '503974943';
        client.Country_Code__c ='PT50';
        insert client;

        Vendor vend2 = new Vendor(data.get('loginID')); 

        Test.startTest();
            List<Account> getclientslist = vend2.getClients();
            Account clt = vend2.getClient(client.Id);
            vend2.getLogin();
        Test.stopTest();

        //verificacao da acc cliente
        /*System.assertEquals(client.ID,                        clt.ID);
        System.assertEquals(client.Name,                      clt.Name);
        System.assertEquals(client.NIF__c,                    clt.NIF__c);
        System.assertEquals(client.Date_Last_Application__c,  clt.Date_Last_Application__c);
        System.assertEquals(client.Available_Credit_Line__c,  clt.Available_Credit_Line__c);
        System.assertEquals(client.Credit_Line_Status__c,     clt.Credit_Line_Status__c);
        System.assertEquals(client.Createddate,               clt.Createddate);*/

        //Verificacao do login do vendor
        Login__c vendorLogin = vend2.getLogin();
        /*System.assertEquals(dadoscriados.loginrecord.idVendor__c,      vendorLogin.IdVendor__c);
        System.assertEquals(dadoscriados.loginrecord.Master__c,        vendorLogin.Master__c);
        System.assertEquals(dadoscriados.loginrecord.Vendor_Vendor__c, vendorLogin.Vendor_NIF__c);
        System.assertEquals(dadoscriados.loginrecord.Username__c,      vendorLogin.Username__c);*/
  
        System.assert(getclientslist != null,'Devolvida lista nula');
        //System.assertEquals(client.Name,clt.Name, 'Wrong client');
    }

    @isTest
    public static void requestApplication_v2Test(){
        String NIFTest = '505241943';
        VendorTest dadoscriados = new VendorTest();
        ID vendorLoginID = data.get('loginID');
        Vendor vend2 = new Vendor(vendorLoginID);
        Test.startTest();
        String AppRequestedID = vend2.requestApplication_v2(NIFTest);
        Test.stopTest(); 
    }
    
    
    //Testa o requestApplication() do Vendor FORCE TO FAIL
    @isTest
    public static void requestApplicationTestForceFail(){
        String NIFTest = '505241943';
        
        VendorTest dadoscriados = new VendorTest();
       
        Vendor vend2 = new Vendor(null);
        Test.startTest();
        String AppRequestedID = vend2.requestApplication_v2(NIFTest);
        Test.stopTest();
        System.assert(AppRequestedID == 'FAILED_VENDOR_LOGIN_NOT_FOUND','Should return FAILED_VENDOR_LOGIN_NOT_FOUND'); 


    }

    @isTest(SeeAllData=true)
    public static void setAccountValues(){
        //ID vendorLoginID = [SELECT ID FROM LOGIN__C WHERE Vendor_Vendor__c =: data.get('vendorContactID')].ID; 
        ID vendorLoginID = data.get('loginID');
        Vendor v = new Vendor(vendorLoginID);

        boolean ibanStatus = v.setVendorIban('PT50003503730000539151280');
        System.assert(ibanStatus,'vendor Iban Not Changed');
        Test.startTest();
        Contact contactToUpdate = [SELECT Name, email, Phone FROM Contact WHERE ID=: data.get('vendorContactID')];
        contactToUpdate.Phone = '+351123654987';
        //TODO: test with session ID when change email to check if the same change is done to login username.
        String statusSaveContact = v.saveVendorContact(contactToUpdate,null); 
        System.assertEquals(statusSaveContact,'OK','Vendor Contact Not Updated'); 
        System.assertEquals( [SELECT Phone FROM Contact WHERE ID=: data.get('vendorContactID')].Phone,contactToUpdate.Phone,'Vendor Contact Not Updated'); 

        Account vendorAcc = [SELECT Name, c2g__CODABankIBANNumber__c FROM Account WHERE ID =: data.get('vendorID')];
        vendorAcc.Name = 'NovoNome';
        String statusAccVendor = v.updateVendorAccountInfo(vendorAcc);
        Test.stopTest(); 
        System.assertEquals(statusAccVendor,'OK','Vendor Account Not Updated');  
        System.assertEquals( [SELECT Name FROM Account WHERE ID =: data.get('vendorID')].Name,vendorAcc.Name,'Vendor Account Not Updated');   
    }

    @isTest
    public static void getVendoInfo(){
        ID vendorLoginID = data.get('loginID');
        Vendor v = new Vendor(vendorLoginID);

        Account vendorAcc = v.getVendorInfo();
        String statusAccVendor = v.updateVendorAccountInfo(vendorAcc); 
        System.assertEquals(vendorAcc.Id,data.get('vendorID'),'Vendor IDs are not the same');  
    }


    @isTest
    public static void testeVendorNotifications(){
        ID vendorLoginID = [SELECT ID FROM LOGIN__C WHERE Vendor_Vendor__c =: data.get('vendorContactID')].ID; 
        
        Vendor v = new Vendor(vendorLoginID);

        Notification__c[] notifList = v.getNotifications();
        Set<Id> notifSetID = (new Map<Id,SObject>(notifList)).keySet();

        ID[] notificationsIDList = new list<ID>();
        for(ID not_id : notifSetID){
            notificationsIDList.add(not_id);
        }

        v.setNotificationsRead(notificationsIDList);      
    }    
    
    @isTest
    public static void InvoiceTest(){
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

        System.assertEquals(vi.Id,vendorInvoiceID,'Error getting Vendor invoice for the right Application');

        String res = v.cancelInvoice(vi.Id);
        System.assertEquals(res,'OK','Error cancelling Vendor invoice');

        String res2 = v.cancelInvoice('0A226000000teste');
        System.assertEquals(res2,'INVOICE_NOT_FOUND','ERROR VENDOR INVOICE SHOULD NOT EXIST');

        vi.Status__c = 'Completed';
        update vi;
        String res3 = v.cancelInvoice(vi.Id);
        System.assertEquals(res3,'INVOICE_STATUS_COMPLETED','ERROR VENDOR INVOICE WAS ALREADY COMPLETED');
    } 

    @isTest
    public static void Logintest(){
        //String email = 'jhonDoeVendor@email.pt';
        //ContactCreation.createLogin(email, data.get('vendorID'), data.get('vendorContactID'));
        Login__c login = [SELECT ID, Username__c, email_psw__c FROM Login__c WHERE id=: data.get('loginID')];

        CandorAuthorization auth = Vendor.login(login.username__c, login.email_psw__c, true, 'userAgent', 'idDevice', 'typeDevice');
        System.assert(auth.isValid(),'Login Failed');

        CandorAuthorization auth2 = Vendor.login(login.username__c, 'wrongPass', true, 'userAgent', 'idDevice', 'typeDevice');
        System.assertEquals(auth2.getErrorMsg(),'Password Incorreta', 'Login should have failed due to wrong password');


        CandorAuthorization auth3 = Vendor.login('wrongUsername', 'wrongPass', true, 'userAgent', 'idDevice', 'typeDevice');
        System.assertEquals(auth3.getErrorMsg(),'Username Incorreto', 'Login should have failed due to wrong username');

        Vendor v = new Vendor(login.Id);
        boolean resInactive = v.eraseORinactivateLogin(login.Id, 'inactivate');
        boolean resDelete = v.eraseORinactivateLogin(login.Id, 'erase');
    }

    @isTest
    public static void saveNewLoginTest(){
        
        Id loginID = data.get('loginID');
        Vendor v = new Vendor(loginID);
        System.debug(data.get('vendorID'));
        Contact new_c = new Contact(LastName='Miles', FirstName='Davis', Email='email@email.pt', AccountId=data.get('vendorID'));
        String newLoginId = v.saveNewLogin(new_c);
        login__c newLogin = [SELECT Email__c, Username__c, Master__c FROM Login__c  WHERE ID=:newLoginId ];
        System.assertEquals(newLogin.Username__c,'email@email.pt', 'Username__c should be email@email.pt and is ' + newLogin.Username__c);
        System.assertEquals(newLogin.Master__c,false, 'Master__c should be false');

        Vendor v_new= new Vendor(newLogin.Id);
        Contact c = new Contact(LastName='Chet', FirstName='Baker', Email='email@email.pt');
        String res = v_new.saveNewLogin(c);
        System.assertEquals(res,'IS_NOT_MASTER', 'Result should be "IS_NOT_MASTER"');
    }



    /*@isTest
    public static void InsuranceTypeByEquipmentsTest(){
        Account v = [SELECT ID, Name, Equipment_Types__c, Available_Insurance_Type__c, Own_Insurance__c FROM Account where Id =: data.get('vendorID')];
        v.Equipment_Types__c = 'Pure IT';
        v.Own_Insurance__c = false;
        Account [] vendorList = new Account[1];
        vendorList[0] = v;

        Account[] vendorWithInsuranceList = Vendor.InsuranceTypeByEquipments(vendorList);
        System.assertEquals(vendorWithInsuranceList[0].Available_Insurance_Type__c,'Static Risk;', 'Available insurances should be "Static Risk;"');

        vendorList[0].Equipment_Types__c = 'Pure IT;Phone Centrals';
        vendorWithInsuranceList = Vendor.InsuranceTypeByEquipments(vendorList);
        System.assertEquals(vendorWithInsuranceList[0].Available_Insurance_Type__c,'Static Risk;Special Risk;', 'Available insurances should be "Static Risk;Special Risk;"');

        //test AccountTrigger
        Account v2 = [SELECT ID, Name, Equipment_Types__c, Available_Insurance_Type__c FROM Account where Id =: data.get('vendorID')];
        v2.Equipment_Types__c = 'Portable Equipments;';
        update v2;
    }*/

    //Create data test
    private static Map<String, ID> getTestData() {

        Map<String, ID> dataMap = new Map<String,ID>();
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630311';
        vendor.Country_Code__c ='PT50';
        //vendor.c2g__CODABankIBANNumber__c ='PT50000700000003253768222';
        insert vendor;
        dataMap.put('vendorID', vendor.ID);

        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendor.Id;
        insert vendorContact;
        dataMap.put('vendorContactID', vendorContact.ID);

        //New Login
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Username__c = 'vendor@email.pt';
        login.Vendor_Vendor__c = vendorContact.Id;
        insert Login;
        CandorAuthorization.resetPassword('vendor@email.pt',false);
        dataMap.put('loginID', login.ID);
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '504092090';
        client.Country_Code__c ='PT50';
        insert client;
        dataMap.put('clientID', client.ID);
    
        
        //FinancialForceDAta
        c2g__codaGeneralLedgerAccount__c generalLedgerAcc = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAcc.Name= '21111 - CLIENTES NACIONAIS';
        generalLedgerAcc.c2g__ReportingCode__c='20000';
        generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
        insert generalLedgerAcc;    
        ID glacc = generalLedgerAcc.id;

        c2g__codaGeneralLedgerAccount__c generalLedgerAccVendor = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAccVendor.Name= '311 - MERCADORIAS';
        generalLedgerAccVendor.c2g__ReportingCode__c='31100';
        generalLedgerAccVendor.c2g__Type__c = 'Balance Sheet';
        insert generalLedgerAccVendor;    
        ID glaccDefaultVendor = generalLedgerAccVendor.id;

        c2g__codaGeneralLedgerAccount__c generalLedgerAccVendorPayableControl = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAccVendorPayableControl.Name= '22114 - FORNECEDORES LEASING';
        generalLedgerAccVendorPayableControl.c2g__ReportingCode__c='22114000';
        generalLedgerAccVendorPayableControl.c2g__Type__c = 'Balance Sheet';
        insert generalLedgerAccVendorPayableControl;    
        ID glaccVendorPayableControl = generalLedgerAccVendorPayableControl.id;

        c2g__codaTaxCode__c taxcode = new c2g__codaTaxCode__c();
        taxcode.Name = 'VCONT23TESTE';
        taxcode.c2g__Description__c='Vendes IVA 23%';
        taxcode.c2g__GeneralLedgerAccount__c=glacc;
        insert taxcode;
        ID vatID = taxcode.id;      
        
        //updateVendor
        c2g__codaTaxCode__c[] taxCodesList = [SELECT ID FROM c2g__codaTaxCode__c WHERE Id='a3e24000000HWMt'];
        if(taxCodesList.size()>0){
            vendor.c2g__CODAOutputVATCode__c = taxCodesList[0].id;
        }else if([SELECT ID FROM c2g__codaTaxCode__c WHERE NAME='VCONT23'].size()>0){
            vendor.c2g__CODAOutputVATCode__c = [SELECT ID FROM c2g__codaTaxCode__c WHERE NAME='VCONT23'].Id;    
        }else{
            vendor.c2g__CODAOutputVATCode__c = vatID;
        }
        
        update vendor;
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        insert contact;
        dataMap.put('contactID', contact.ID);
        
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        // app.Client_Signer_1__c=con.id;
        //app.Vendor_Primary__c=convendor.id;
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
        app.Vendor_Invoice_Amount__c = 2402.63;
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
        insert app;
        dataMap.put('appID', app.ID);

        return dataMap;
    }
}
