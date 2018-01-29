@isTest(SeeAllData=true)
private class VendorInvoiceTriggerHandlerTest  {
    
    private static Map<String,String >data = getTestData();
    
    @isTest 
    static void setVendorInvoiceTaxInformationTest() {
        Vendor_Invoice__c vi = new Vendor_Invoice__c(Application__c=data.get('appID'), Account__c = data.get('vendorID'), Invoice_Total__c =1000, Tax_Rate__c=23 );
        insert vi; 
        
        vi = [SELECT ID, Tax_Code__r.Name, Tax_Rate__c FROM Vendor_Invoice__c WHERE ID=: vi.Id ];
        
        //TODO
        //  System.assertEquals('VCONT23TESTE',vi.Tax_Code__r.Name, 'Tax Code should be CCONT23'); 
    }
    
    @isTest
    private static void createVinvByAccount(){
        Vendor_Invoice__c vinv = new Vendor_Invoice__c();
        vinv.Account__c =  data.get('vendorID') ;
        
        insert vinv;
    }

    @isTest
    private static void createVinvByTaxpayerNumber(){
        Vendor_Invoice__c vinv = new Vendor_Invoice__c();
        vinv.Taxpayer_Number__c =  [Select ID,NIF__c
                                    From Account 
                                    where NIF__c != null and (not NIF__C LIKE '0%') and id != :vinv.Account__c and id != :data.get('vendorID') 
                                    and (Type = 'Service Provider' or Type = 'Channel Partner / Vendor') limit 1].NIF__c;
        insert vinv;
    }    
    
    @isTest
    private static void changeAccAndNIFVinv(){
        
        Vendor_Invoice__c vinv = [Select ID,Taxpayer_Number__c,Account__c FROM Vendor_Invoice__c where Account__c != null and (Account__r.Type = 'Service Provider' or Account__r.Type = 'Channel Partner / Vendor') limit 1]; 
        String newNIF = [Select ID,NIF__c
                         From Account 
                         where NIF__c != null and id != :vinv.Account__c and id != :data.get('vendorID') 
                         and Type = 'Service Provider' limit 1].NIF__c;
        
        vinv.Taxpayer_Number__c = newNIF;
        
        update vinv;
        vinv.Account__c = data.get('vendorID');
        update vinv;
        vinv.Taxpayer_Number__c = newNIF;
        vinv.Account__c = null;
        update vinv;
    }
    
    @isTest
    private static void dummyVinvTest(){
        VendorInvoiceTriggerHandler.dummyMethod();
    }
    
    private static Map<String, ID> getTestData() {

        Map<String, ID> dataMap = new Map<String,ID>();
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        ID glacc;

        List <c2g__codaGeneralLedgerAccount__c> generalLedgerAccList = [Select ID From c2g__codaGeneralLedgerAccount__c Where NAME=:'21111 - CLIENTES NACIONAIS'];
        
        if (generalLedgerAccList.size()>0){
            glacc = generalLedgerAccList.get(0).id; 
        }else{
            c2g__codaGeneralLedgerAccount__c generalLedgerAcc = new c2g__codaGeneralLedgerAccount__c();
            
            generalLedgerAcc.Name= '21111 - CLIENTES NACIONAIS';
            generalLedgerAcc.c2g__ReportingCode__c='21110';
            generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
            insert generalLedgerAcc;    
            glacc = generalLedgerAcc.id;
        }
        
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
        //vendor.c2g__CODABankIBANNumber__c ='PT50000700000003253768222';
        vendor.BillingCity = 'Amora2';
        vendor.BillingStreet = 'Rua lá de fora2';
        vendor.BillingPostalCode = '2048-124';
        accountList.add(vendor);
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '504092090';
        client.BillingCity = 'Amora';
        client.BillingStreet = 'Rua lá de fora';
        client.BillingPostalCode = '2048-124';
        //client.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        client.c2g__CODAInputVATCode__c = vatID;
        accountList.add(client);
        
        insert accountList;
        dataMap.put('vendorID', accountList[0].ID);
        dataMap.put('clientID', accountList[1].ID);
        
        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendor.Id;
        contactList.add(vendorContact);
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId=client.ID;
        contactList.add(contact);
        
        insert contactList;
        dataMap.put('vendorContactID', contactList[0].ID);
        dataMap.put('contactID', contactList[1].ID);
        
        //New Login
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Username__c = 'vendor@email.pt';
        login.Vendor_Vendor__c = vendorContact.Id;
        insert Login;
        Authenticate.generatorPassword(login.Id, 4);
        dataMap.put('loginID', login.ID);

        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        // app.Client_Signer_1__c=con.id;
        app.Vendor_Primary__c=vendorContact.id;
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
        app.Equipment_Cost__c = 1000;
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