@isTest  // TODO change the Test to remove SeeAllData
private class BILL_BillingProcessTest {
    //public static final boolean QA= false; // BP - 05/04/17 - alterar entre ambientes 
    
    @isTest(SeeAllData=true)
    //test trigger on Posting invoice
    public static void test_Create_Interest_trs(){
        BILL_ProductRegion billRegion = new BILL_ProductRegion('Input');
        Account vendor = new Account();
        vendor.Name = '1 Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630330213';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        system.debug('Vendor_Trs '+ vendor);
        vendor.Tax_Zone__c = 'Mainland';
        insert vendor;     
        
        //New Account Client
        Account client = new Account();
        client.Name = '2 Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '5007666301213';
        client.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        c2g__codaTaxCode__c taxCode = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'VCONT23'];
        client.c2g__CODAInputVATCode__c = taxCode.id; //'a3e24000000HWMt';
        client.c2g__CODAInvoiceEmail__c='teste@email.com';
        client.c2g__CODATaxCalculationMethod__c='Gross';
        client.BillingPostalCode = '1234-423';
        client.Tax_Zone__c = 'Mainland';
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
        client.c2g__CODAAccountsReceivableControl__c= generalLedgerAccount.id; //'a2l24000000U9vnAAC';
        system.debug('ClientTRS '+ Client);
        
        insert client;
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        app.Term__c = '36';
        //  app.Client_Signer_1__c=con.id;
        //  app.Vendor_Primary__c=convendor.id;
        insert app;
        Test.startTest(); 
        
        //Product2 prod=[select id, Description, c2g__CODAInputTaxCode__c, c2g__CODAInputTaxCode__r.Area__c,  name, ProductCode 
        //               from Product2  where ProductCode='PT01' and  c2g__CODAInputTaxCode__r.Area__c='Mainland'];
        ID prod = billRegion.getProduct('PT01', 'Mainland');
        ID productTaxCode = billRegion.getTaxCode('PT01', 'Mainland');
        Billing_Contract__c BillCont=New Billing_Contract__c(Name=app.name, Account__c=client.ID, Account_Vendor__c=vendor.ID, 
                                                             Contract_Start_Date__c= date.today(),
                                                             Billing_Date_Override__c=date.today(), application__c=app.id );
        
        insert BillCont;
        Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='monthly',
                                                                                     Line_Item_Start_Date__c=date.today(), Line_Item_End_Date__c=date.today()+15, 
                                                                                     Active__c=true, Sales_Price__c=105, Product__C=prod, Quantity__c=1,
                                                                                     interest__C=50.2, application__c=app.id, Product_Tax_Code__c = productTaxCode);
        system.debug('BillContItemTRS '+ BillContItem);
        BillContItem.Principal__c = 20;
        insert BillContItem;
        Id ruleId = [select id from ffirule__IntegrationRule__c where name ='Billing Contract to Sales Invoice'].id;
        List<Billing_Contract__c> Bills = [SELECT Id FROM Billing_Contract__c WHERE id=: BillCont.id ];
        Set<Id> BillIds = new Map<Id, SObject>(Bills).keySet();
        List<Id> targetIds=new List<Id>();
        
        // Criação do sales Invoice
        //if(!QA)//BP
        targetIds = ffirule.RuleService.run(new List<Id>(BillIds), ruleId);
        
        Test.stopTest(); 
        
    }
    
    @isTest(SeeAllData=true)
    //test trigger on Posting invoice
    public static void test_CreateBilling_1 (){
        System.debug('CreateBilling1');
        Account vendor = new Account();
        vendor.Name = '1 Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '999666333';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        
        c2g__codaTaxCode__c VendortaxCode = new c2g__codaTaxCode__c(Name='VCONT23');
        vendor.c2g__CODAOutputVATCode__c = VendortaxCode.Id;
        System.debug('VendortaxCode '+VendortaxCode);
        System.debug('Vendor1 '+vendor);
        insert vendor;
        
        //New Account Client
        Account client = new Account();
        client.Name = '2 Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '333666999';
        client.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        c2g__codaTaxCode__c taxCode = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'VCONT23'];
        client.c2g__CODAInputVATCode__c = taxCode.id; //'a3e24000000HWMt';
        client.c2g__CODAInvoiceEmail__c='teste@email.com';
        client.c2g__CODATaxCalculationMethod__c='Gross';
        client.BillingPostalCode = '1234-423';
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
        client.c2g__CODAAccountsReceivableControl__c= generalLedgerAccount.id; //'a2l24000000U9vnAAC';
        System.debug('client1 '+client);
        
        upsert client;
        
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId= vendor.Id;
        insert contact;
        system.debug('contact ID: ' + contact.ID);
        
        Contact contactClient =new contact();
        contactClient.LastName = 'Client';
        contactClient.Email = 'test@client.com';
        contactClient.Role__c='Client';
        contactClient.AccountId= client.Id;
        insert contactClient;
        system.debug('contact ID: ' + contactClient.ID);
        
        Test.startTest();  
        
        Application__c app= new Application__c(Vendor__c=vendor.id, AccClient__c=client.ID, Vendor_Primary__c=contact.id );
        app.Invoice_To__c = contact.ID;
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        app.status__c = 'Contract - Running';
        app.Obs_Invoice__c = 'App Notes';
        app.Client_Signer_1__c = contactClient.Id;
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
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
        System.debug('app1 '+app);
        app.recalculateFormulas();        
        app.Vendor_Invoice_Amount__c = 5;
        app.Equipment_Cost__c = 5;
        app.recalculateFormulas();
        
        insert app;
        
        //Id appId = RentingApplication_Util_Test.createApplication(client, vendor);
        
        //System.enqueueJob(new Queueable_ProcBilling(app.Id));
        
        (new BILL_BillingProcess()).createBillingInvoice(app.id);
        Test.stopTest();
        //   delete vendor;
        //   delete client;
    } 
    
    @isTest(SeeAllData=true)
    //test trigger on Posting invoice
    public static void test_CreateBilling_2 (){
        System.debug('CreateBilling2');
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '999666333';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        insert vendor;
        system.debug('Vendor2 '+ vendor);
        
        List<c2g__codaGeneralLedgerAccount__c> generalLedgerAccList = [SELECT ID,Name,c2g__ReportingCode__c,c2g__Type__c 
                                                                       FROM c2g__codaGeneralLedgerAccount__c 
                                                                       WHERE Name = '21110 - CLIENTES NACIONAIS'];
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAcc;
        if(generalLedgerAccList.isEmpty()){
            generalLedgerAcc= new c2g__codaGeneralLedgerAccount__c();
            generalLedgerAcc.Name= '21110 - CLIENTES NACIONAIS';
            generalLedgerAcc.c2g__ReportingCode__c='21110';
            generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
            upsert generalLedgerAcc;    
        }else{
            generalLedgerAcc = generalLedgerAccList.get(0);
        }
        
        c2g__codaTaxCode__c tax = new c2g__codaTaxCode__c();
        tax.Name = 'textTax';
        tax.c2g__Description__c ='testTax description';   
        tax.c2g__GeneralLedgerAccount__c=generalLedgerAcc.ID;   
        System.debug('Tax2 '+tax);
        insert tax;
        
        //New Account Client
        Account client = new Account();
        client.Name = '2 Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '333666999';
        client.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        client.c2g__CODAInputVATCode__c = tax.id; //'a3e24000000HWMt';
        client.c2g__CODAInvoiceEmail__c='teste@email.com';
        client.c2g__CODATaxCalculationMethod__c='Gross';
        client.BillingPostalCode = '1234-423';
        
        List<c2g__codaGeneralLedgerAccount__c> generalLedgerAccountList = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
        
        if(generalLedgerAccountList.isEmpty()){
            return;
        }
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = generalLedgerAccountList.get(0);
        client.c2g__CODAAccountsReceivableControl__c=  generalLedgerAccount.id; //'a2l24000000U9vnAAC';
        system.debug('Client2 '+ Client);
        
        insert client;
        Test.startTest();  
        
        Application__c app1 = new Application__c();
        app1.AccClient__c = client.ID;
        app1.Vendor__c = vendor.ID;
        // app.Client_Signer_1__c=con.id;
        //app.Vendor_Primary__c=convendor.id;
        app1.Insurance_Type__c = 'Special Risk';
        app1.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app1.Payment_Timing__c='Advanced';
        app1.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app1.TermCalc__c = 48;
        app1.Vendor_Invoice_Amount__c = 0;
        app1.Equipment_Cost__c = 2402.63;
        app1.Insurance_Special_Value__c = 9.31;
        app1.Insurance_Movement_value__c = 11.01;
        app1.Client_BBAN__c = '004563904014640899590';
        app1.Payment_Freq__c ='Quarterly';
        app1.Payment_Amount__c = 2500;
        app1.Invoice_Payment_Date__c =date.today();
        insert app1;
        app1.Generate_Billing__c=true;
        app1.Annual_Interest_Rate__c=9.2;
        app1.Amortization_Interest_Rate__c=9.2;
        app1.Vendor_Diluted_Doc_Fee__c=true;
        app1.ATM_Reference__c=true;
        app1.Interim_Fee__c=true;
        app1.ATM_Reference__c=true;
        app1.ATM_Reference_Costs__c=10;
        app1.eSignature_Contract__c=true;
        app1.Paper_Contract__c=true;
        app1.Delivery_Certificate_Signed__c=date.today().addDays(-44);
        system.debug('App2 '+ App1);
        
        update app1;
        
        //System.enqueueJob(new Queueable_ProcBilling(app1.id));
        (new BILL_BillingProcess()).createBillingInvoice(app1.id);
        
        Test.stopTest();
        //delete vendor;
    }
    
    @isTest(SeeAllData=true)
    //test trigger on Posting invoice
    public static void test_GetInputOutputVAT (){
        BillingProcess.GetInputOutputVAT  ('3250');
    }
    
    @isTest(SeeAllData=true)
    public static void test_Create_Due_Sales_invoice(){
        BILL_ProductRegion billRegion = new BILL_ProductRegion('Input');
        Account vendor = new Account();
        vendor.Name = '2 Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '5036303309';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        insert vendor;     
        List<c2g__codaGeneralLedgerAccount__c> generalLedgerAccList = [SELECT ID,Name,c2g__ReportingCode__c,c2g__Type__c 
                                                                       FROM c2g__codaGeneralLedgerAccount__c 
                                                                       WHERE Name = '21110 - CLIENTES NACIONAIS'];
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAcc;
        if(generalLedgerAccList.isEmpty()){
            generalLedgerAcc= new c2g__codaGeneralLedgerAccount__c();
            generalLedgerAcc.Name= '21110 - CLIENTES NACIONAIS';
            generalLedgerAcc.c2g__ReportingCode__c='21110';
            generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
            upsert generalLedgerAcc;    
        }else{
            generalLedgerAcc = generalLedgerAccList.get(0);
        }
        
        List<c2g__codaTaxCode__c> taxv2List = [SELECT ID,c2g__Description__c,c2g__GeneralLedgerAccount__c 
                                               FROM c2g__codaTaxCode__c 
                                               WHERE Name = 'textTaxv2'];
        c2g__codaTaxCode__c taxv2;
        if(taxv2List.isEmpty())
        {
            taxv2 = new c2g__codaTaxCode__c();
            taxv2.Name = 'textTaxv2';
            taxv2.c2g__Description__c ='testTaxv2 description';   
            taxv2.c2g__GeneralLedgerAccount__c=generalLedgerAcc.ID;
            insert taxv2; 
        }else{
            taxv2 = taxv2List.get(0);
        }                             
        
        //New Account Client
        Account client = new Account();
        client.Name = '3 Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '999999999';
        client.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        client.c2g__CODAInputVATCode__c = taxv2.id;//'a3e24000000HWMt';
        client.c2g__CODAInvoiceEmail__c='teste@email.com';
        client.c2g__CODATaxCalculationMethod__c='Gross';
        client.BillingPostalCode = '1234-423';
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
        
        client.c2g__CODAAccountsReceivableControl__c=  generalLedgerAccount.id; //'a2l24000000U9vnAAC';
        
        upsert client;
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        app.Payment_Freq__c ='Monthly';
        app.Term__c = '36';
        //  app.Client_Signer_1__c=con.id;
        //  app.Vendor_Primary__c=convendor.id;
        insert app;
        Test.startTest();  
        
        ID prod = billRegion.getProduct('PT01', 'Mainland');
        ID productTaxCode = billRegion.getTaxCode('PT01', 'Mainland');        
        
        Billing_Contract__c BillCont=New Billing_Contract__c(Name=app.name, Account__c=client.ID, Account_Vendor__c=vendor.ID, 
                                                             Contract_Start_Date__c= date.today(),
                                                             Billing_Date_Override__c=date.today(), application__c=app.id );
        insert BillCont;
        Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='monthly',
                                                                                     Line_Item_Start_Date__c=date.today(), Line_Item_End_Date__c=date.today()+15, 
                                                                                     Active__c=true, Sales_Price__c=105, Product__C=prod, Quantity__c=1,
                                                                                     interest__C=50.2, application__c=app.id, Product_Tax_Code__c = productTaxCode);
        BillContItem.Principal__c = 20;
        BillContItem.Interest__c = 20;
        insert BillContItem;
        BillingProcess.Create_Due_Sales_invoice(BillCont.ID);
        c2g__codaInvoice__c inv = [SELECT ID, Post_SalesInvoice__c FROM c2g__codaInvoice__c order by createddate DESC LIMIT 1];
        inv.Post_SalesInvoice__c = true;
        //if(!QA)
        update inv;
        Test.stopTest();
    }
    
}