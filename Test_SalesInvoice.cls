@isTest(SeeAllData=true)
private class Test_SalesInvoice {
	
	private static Integer nifCounter = 100000000;
	private static String taxZone = 'Mainland';
	private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    
    private static Account testClient;
    private static Account testVendor;
    private static Application__c testApp;
    private static Collection_Case__c testCollectionCase;
    private static c2g__codaInvoice__c testInvoice;
	
	
    static testMethod void test_salesinvoice(){
        
         //SALES INVOICE
        //////////
        //////////
/*        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        QueuesObject testQueue ;
        User u = new User(Id=UserInfo.getUserId()); 
        System.runAs(u){
            List<queuesobject >  listQueue = new List<queuesobject >();
            queuesobject q1 = new queuesobject (queueid=testGroup.id, sobjecttype='Case'); 
            listQueue.add(q1);
            queuesobject q2 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaAccountingCurrency__c'); 
            listQueue.add(q2);
            queuesobject q3 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaPurchaseInvoice__c'); 
            listQueue.add(q3);
            queuesobject q4 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCompany__c'); 
            listQueue.add(q4);
            queuesobject q5 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaYear__c'); 
            listQueue.add(q5);
            queuesobject q6 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaInvoice__c'); 
            listQueue.add(q6);
            queuesobject q7 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCreditNote__c'); 
            listQueue.add(q7);
            insert  listQueue;
        
            GroupMember GroupMemberObj = new GroupMember();
            GroupMemberObj.GroupId = testGroup.id;
            GroupMemberObj.UserOrGroupId = u.Id;
            insert GroupMemberObj;
        }  
        
        c2g__codaCompany__c company = new c2g__codaCompany__c();
        company.Name = 'Test Record';
        company.c2g__CashMatchingCurrencyMode__c = 'Test Account';
        company.c2g__YearEndMode__c = 'Test Code';
        company.c2g__ExternalId__c = 'ABCDE1234567876';
        company.c2g__LogoURL__c ='ww.XYZ.com';
        company.c2g__ECCountryCode__c = 'AE' ;
        company.c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA' ;
        company.c2g__Website__c = 'ww.xyz.com';
        company.c2g__Country__c ='US';
        company.ownerid = testGroup.Id;
        company.c2g__CashMatchingCurrencyMode__c = 'Account';
        insert company;
        
        Credentials__c credential = new Credentials__c();
        credential.name = 'EasyPay2';
        //credential.client_secret_code__c = 'dfaofjoais'; 
        credential.client_secret_code__c = '2c1e6194bbf7d88fc1ccc9fe511fa2b2'; 
        credential.Web_Service_Url__c = 'http://test.easypay.pt/';
        credential.Web_Service_Url_TEST_ENVIRONMENT__c = 'http://test.easypay.pt/';
        insert credential;
        
        c2g__codaYear__c yr= new c2g__codaYear__c();
        yr.Name ='2017';
        yr.c2g__AutomaticPeriodList__c =  true;
        yr.c2g__OwnerCompany__c = company.id;
        yr.c2g__ExternalId__c = 'yzsd1234';
        yr.c2g__NumberOfPeriods__c =11;
        yr.c2g__StartDate__c =  system.today() - 10;
        yr.c2g__Status__c = 'Open';
        yr.c2g__PeriodCalculationBasis__c = '445';
        yr.c2g__YearEndMode__c = 'Full Accounting Code' ; 
        yr.c2g__UnitOfWork__c = 12;
        yr.ownerid = testGroup.Id;
        insert yr;
        
        c2g__codaPeriod__c prd = new c2g__codaPeriod__c();
        prd.Name ='Test2017';
        prd.c2g__ExternalId__c ='abdc12345';
        prd.c2g__StartDate__c = System.today()-10;
        prd.c2g__EndDate__c= System.today()+10;
        prd.c2g__OwnerCompany__c = company.id;
        prd.c2g__PeriodNumber__c ='123';
        prd.c2g__Description__c ='test Desc';
        prd.c2g__PeriodGroup__c = 'Q1';
        prd.c2g__PeriodNumber__c = '1';
        prd.c2g__YearName__c = yr.id;
        insert prd;
        
        c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
        userCompany.c2g__Company__c =company.id;
        userCompany.c2g__User__c = userInfo.getUserId();
        userCompany.c2g__ExternalId__c = 'ABCDE1234567876';
        userCompany.c2g__UnitOfWork__c = 111 ;
        insert  userCompany;
        
        c2g__codaAccountingCurrency__c accCurrency = new c2g__codaAccountingCurrency__c();
        accCurrency.c2g__OwnerCompany__c = company.id;
        accCurrency.c2g__DecimalPlaces__c = 2;
        accCurrency.Name = 'USD';
        accCurrency.c2g__Dual__c = true ;
        accCurrency.c2g__Home__c = true ;
        //accCurrency.ownerid = testGroup.Id;
        insert accCurrency;
*/        //////////
        //////////
        //////////
/*        
        List<Dunning_Admin__c > dunnings = new List<Dunning_Admin__c >();
        
        Dunning_Admin__c dadmin = new Dunning_Admin__c();
        dadmin.Dunning_Level__c = '1st Reminder';
        dadmin.Nr_of_Days_to_Pay__c=1;
        dadmin.Active__c='Yes';
        dadmin.Dunning_Frequency__c=4;
        dadmin.Email_Template__c='Primeiro_Aviso_ou_Interpelacao';
        dadmin.Past_Due_Days__c=7; 
        dunnings.add(dadmin);
        
        Dunning_Admin__c dadmin2 = new Dunning_Admin__c();
        dadmin2.Dunning_Level__c = '2nd Reminder';
        dadmin2.Nr_of_Days_to_Pay__c=1;
        dadmin2.Active__c='Yes';
        dadmin2.Dunning_Frequency__c=4;
        dadmin2.Email_Template__c='Segundo_Aviso_ou_Interpelacao';
        dadmin2.Past_Due_Days__c=7;
        dunnings.add(dadmin2);
        
        Dunning_Admin__c dadmin3 = new Dunning_Admin__c();
        dadmin3.Dunning_Level__c = '3rd Reminder';
        dadmin3.Nr_of_Days_to_Pay__c=1;
        dadmin3.Active__c='Yes';
        dadmin3.Dunning_Frequency__c=4;
        dadmin3.Email_Template__c='Terceiro_Aviso_ou_Interpelacao';
        dadmin3.Past_Due_Days__c=7;
        dunnings.add(dadmin3);
        
        insert dunnings;
*/      
        Dunning_Admin__c dadmin = [SELECT Id, Dunning_Level__c, Nr_of_Days_to_Pay__c, Active__c, Dunning_Frequency__c, Email_Template__c, Past_Due_Days__c FROM Dunning_Admin__c WHERE Dunning_Level__c = '1st Reminder'];
        Dunning_Admin__c dadmin2 = [SELECT Id, Dunning_Level__c, Nr_of_Days_to_Pay__c, Active__c, Dunning_Frequency__c, Email_Template__c, Past_Due_Days__c FROM Dunning_Admin__c WHERE Dunning_Level__c = '2nd Reminder'];
        Dunning_Admin__c dadmin3 = [SELECT Id, Dunning_Level__c, Nr_of_Days_to_Pay__c, Active__c, Dunning_Frequency__c, Email_Template__c, Past_Due_Days__c FROM Dunning_Admin__c WHERE Dunning_Level__c = '3rd Reminder'];
/*        
        c2g__codaGeneralLedgerAccount__c generalLedgerAcc = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAcc.Name = '21110 - CLIENTES NACIONAIS';
        generalLedgerAcc.c2g__ReportingCode__c = '21110';
        generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
        insert generalLedgerAcc;
                
        c2g__codaTaxCode__c taxv2 = new c2g__codaTaxCode__c();
        taxv2.Name = 'textTaxv2';
        taxv2.c2g__Description__c ='testTaxv2 description';   
        taxv2.c2g__GeneralLedgerAccount__c = generalLedgerAcc.id;
        insert taxv2;
*/
/*        
        List<Product2 > prodts= new List<Product2 >();
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(name='1.º Aviso ou interpelação',ProductCode = 'PT04');
        prodts.add(prod);    
        Product2 prod2 = new Product2(name='2.º Aviso ou interpelação',ProductCode = 'PT04');
        prodts.add(prod2);  
        Product2 prod3 = new Product2(name='3.º Aviso ou interpelação',ProductCode = 'PT04');
        prodts.add(prod3);
        Product2 prod4 = new Product2(name='Aluguer',ProductCode = 'PT01');  //,c2g__CODAInputTaxCode__c = taxv2.Id
        prodts.add(prod4);  
         
        insert prodts;
*/        
        Product2 prod = [SELECT Id, name, ProductCode, c2g__CODAInputTaxCode__c FROM Product2 WHERE name='1.º Aviso ou interpelação' AND ProductCode = 'PT04' Limit 1];
        Product2 prod2 = [SELECT Id, name, ProductCode, c2g__CODAInputTaxCode__c FROM Product2 WHERE name='2º. Aviso ou interpelação' AND ProductCode = 'PT05' Limit 1];
        Product2 prod3 = [SELECT Id, name, ProductCode, c2g__CODAInputTaxCode__c FROM Product2 WHERE name='3º. Aviso ou interpelação' AND ProductCode = 'PT13' Limit 1];
        Product2 prod4 = [SELECT Id, name, ProductCode, c2g__CODAInputTaxCode__c FROM Product2 WHERE ProductCode = 'PT01'  Limit 1];
        
/*        
        List<PricebookEntry> prices = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod.id, IsActive = true, UseStandardPrice = false);
        prices.add(pbe);
        PricebookEntry pbe2 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod2.id, IsActive = true, UseStandardPrice = false);
        prices.add(pbe2);
        PricebookEntry pbe3 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod3.id, IsActive = true, UseStandardPrice = false);
        prices.add(pbe3);
        PricebookEntry pbe4 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod4.id, IsActive = true, UseStandardPrice = false);
        prices.add(pbe4);
        insert prices;
*/        
        List<Dunning_Product__c> dunningprodts = new List<Dunning_Product__c>();
        Dunning_Product__c dp = new Dunning_Product__c();
        dp.Dunning_Admin__c = dadmin.id;
        dp.Product__c = prod.id;
        dunningprodts.add(dp);
        
        Dunning_Product__c dp2 = new Dunning_Product__c();
        dp2.Dunning_Admin__c = dadmin2.id;
        dp2.Product__c = prod2.id;
        dunningprodts.add(dp2);
        
        Dunning_Product__c dp3 = new Dunning_Product__c();
        dp3.Dunning_Admin__c = dadmin3.id;
        dp3.Product__c = prod3.id;
        dunningprodts.add(dp3);
        
        insert dunningprodts;
 /*       
        List<Account> listacc = new List<Account>();
        Account client = new Account();
        client.Name = 'EasyPay2'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '5007666313';
        client.BillingCity = 'Lx';
        client.BillingPostalCode = '3000-423';
        client.BillingStreet = 'BillingStreet';
        client.Website = 'webSite';
        client.Phone = '00351964639755';
        client.Fax = '00351964639755';
        client.c2g__CODAAccountTradingCurrency__c = 'USD';
        client.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';

        c2g__codaGeneralLedgerAccount__c generalLedgerAccountClient = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
        client.c2g__CODAAccountsReceivableControl__c= generalLedgerAccountClient.id;

        listacc.add(client);
   
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630333';
        vendor.c2g__CODAInvoiceEmail__c = 'jhonDoe@email.com';
        vendor.Moloni_Client_ID__c = '1421';
        vendor.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        listacc.add(vendor);
        
        insert listacc; 
*/      
        Account vendor = new Account();
        vendor.Name = '1 Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630330213';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        vendor.BillingPostalCode = '1234-423';  
        vendor.BillingCountryCode = 'PT';
        system.debug('Vendor_Trs '+ vendor);
        
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
        client.BillingCountryCode  = 'PT';
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
        client.c2g__CODAAccountsReceivableControl__c= generalLedgerAccount.id; //'a2l24000000U9vnAAC';
        system.debug('ClientTRS '+ Client);
        
        insert client;
        
        List<Collection_Case__c> listccs = new List<Collection_Case__c>(); 
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c = client.id;
        listccs.add(cc);
        
        Collection_Case__c cc1 = new Collection_Case__c();
        cc1.Account__c = client.id;
        listccs.add(cc1);
        
        insert listccs;
        
        List<Dunning_Alert__c> listdalerts = new List<Dunning_Alert__c>();
        Dunning_Alert__c da1 = new Dunning_Alert__c();
        da1.Dunning_Level__c = '1st Reminder';
        da1.Level__c = '1';
        da1.Status__c= 'Open';
        da1.Collection_Case__c = cc.Id;
        da1.Sent_Date__c = date.today().addDays(-8);
        da1.Due_Date__c = date.today().addDays(-1);
        da1.Email_Send_Date__c = date.today().addDays(-8);
        listdalerts.add(da1);
/*        
        Dunning_Alert__c da2 = new Dunning_Alert__c();
        da2.Dunning_Level__c = '2nd Reminder';
        da2.Level__c = '2';
        da2.Status__c= 'Open';
        da2.Collection_Case__c = cc.Id;
        da2.Sent_Date__c = date.today().addDays(-8);
        da2.Due_Date__c = date.today().addDays(-1);
        da2.Email_Send_Date__c = date.today().addDays(-8);
        listdalerts.add(da2);
        
        Dunning_Alert__c da3 = new Dunning_Alert__c();
        da3.Dunning_Level__c = '3rd Reminder';
        da3.Level__c = '3';
        da3.Status__c= 'Open';
        da3.Collection_Case__c = cc.Id;
        da3.Sent_Date__c = date.today().addDays(-8);
        da3.Due_Date__c = date.today().addDays(-1);
        da3.Email_Send_Date__c = date.today().addDays(-8);
        listdalerts.add(da3);
*/        
        insert listdalerts;
                
        Contact contact = new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c ='Binding Power';
        contact.AccountId = client.id;
        insert contact;
        
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        insert login;
        
        Application__c app= new Application__c(Vendor__c = vendor.id,AccClient__c = client.ID,IdLoginCreate__c = login.Id, Vendor_Primary__c = contact.id );
        app.Invoice_To__c = contact.ID;
        app.status__c = 'Contract - Running';
        app.Obs_Invoice__c = 'App Notes';
        insert app;
        
        c2g__codainvoice__c invoice = new c2g__codainvoice__c();
        invoice.c2g__account__c = client.Id;
        invoice.Collection_Case__c = cc.Id;
        invoice.c2g__InvoiceDate__c = date.today();
        invoice.c2g__DueDate__c = date.today();
        invoice.c2g__InvoiceStatus__c='In progress'; 
        invoice.Application__c = app.Id;
        insert invoice;
                
        c2g__codaInvoiceLineItem__c invoiceitem = new c2g__codaInvoiceLineItem__c();
        invoiceitem.c2g__Invoice__c = invoice.Id;
        invoiceitem.c2g__Quantity__c = 1;
        invoiceitem.c2g__LineNumber__c = 1;
        invoiceitem.c2g__UnitPrice__c = 10;
        invoiceitem.c2g__Product__c = prod4.Id;
        invoiceitem.c2g__DeriveUnitPriceFromProduct__c = false;
        invoiceitem.c2g__TaxCode1__c = prod4.c2g__CODAInputTaxCode__c;
        insert invoiceitem;
        
        Test.startTest();
        
        SalesInvoce.create(new List<Id>{cc.Id}, '1st Reminder');
        
//        SalesInvoce.create(new List<Id>{cc.Id}, '2nd Reminder');
        
        //SalesInvoce.create(new List<Id>{cc.Id}, '3rd Reminder');
        
        
        Test.stopTest();
    } 
    
        static testMethod void test_salesinvoice3(){
        
         //SALES INVOICE
        //////////
        //////////
/*        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        QueuesObject testQueue ;
        User u = new User(Id=UserInfo.getUserId()); 
        System.runAs(u){
            List<queuesobject >  listQueue = new List<queuesobject >();
            queuesobject q1 = new queuesobject (queueid=testGroup.id, sobjecttype='Case'); 
            listQueue.add(q1);
            queuesobject q2 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaAccountingCurrency__c'); 
            listQueue.add(q2);
            queuesobject q3 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaPurchaseInvoice__c'); 
            listQueue.add(q3);
            queuesobject q4 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCompany__c'); 
            listQueue.add(q4);
            queuesobject q5 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaYear__c'); 
            listQueue.add(q5);
            queuesobject q6 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaInvoice__c'); 
            listQueue.add(q6);
            queuesobject q7 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCreditNote__c'); 
            listQueue.add(q7);
            insert  listQueue;
        
            GroupMember GroupMemberObj = new GroupMember();
            GroupMemberObj.GroupId = testGroup.id;
            GroupMemberObj.UserOrGroupId = u.Id;
            insert GroupMemberObj;
        }  
        
        c2g__codaCompany__c company = new c2g__codaCompany__c();
        company.Name = 'Test Record';
        company.c2g__CashMatchingCurrencyMode__c = 'Test Account';
        company.c2g__YearEndMode__c = 'Test Code';
        company.c2g__ExternalId__c = 'ABCDE1234567876';
        company.c2g__LogoURL__c ='ww.XYZ.com';
        company.c2g__ECCountryCode__c = 'AE' ;
        company.c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA' ;
        company.c2g__Website__c = 'ww.xyz.com';
        company.c2g__Country__c ='US';
        company.ownerid = testGroup.Id;
        company.c2g__CashMatchingCurrencyMode__c = 'Account';
        insert company;
        
        Credentials__c credential = new Credentials__c();
        credential.name = 'EasyPay2';
        //credential.client_secret_code__c = 'dfaofjoais'; 
        credential.client_secret_code__c = '2c1e6194bbf7d88fc1ccc9fe511fa2b2'; 
        credential.Web_Service_Url__c = 'http://test.easypay.pt/';
        credential.Web_Service_Url_TEST_ENVIRONMENT__c = 'http://test.easypay.pt/';
        insert credential;
        
        c2g__codaYear__c yr= new c2g__codaYear__c();
        yr.Name ='2017';
        yr.c2g__AutomaticPeriodList__c =  true;
        yr.c2g__OwnerCompany__c = company.id;
        yr.c2g__ExternalId__c = 'yzsd1234';
        yr.c2g__NumberOfPeriods__c =11;
        yr.c2g__StartDate__c =  system.today() - 10;
        yr.c2g__Status__c = 'Open';
        yr.c2g__PeriodCalculationBasis__c = '445';
        yr.c2g__YearEndMode__c = 'Full Accounting Code' ; 
        yr.c2g__UnitOfWork__c = 12;
        yr.ownerid = testGroup.Id;
        insert yr;
        
        c2g__codaPeriod__c prd = new c2g__codaPeriod__c();
        prd.Name ='Test2017';
        prd.c2g__ExternalId__c ='abdc12345';
        prd.c2g__StartDate__c = System.today()-10;
        prd.c2g__EndDate__c= System.today()+10;
        prd.c2g__OwnerCompany__c = company.id;
        prd.c2g__PeriodNumber__c ='123';
        prd.c2g__Description__c ='test Desc';
        prd.c2g__PeriodGroup__c = 'Q1';
        prd.c2g__PeriodNumber__c = '1';
        prd.c2g__YearName__c = yr.id;
        insert prd;
        
        c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
        userCompany.c2g__Company__c =company.id;
        userCompany.c2g__User__c = userInfo.getUserId();
        userCompany.c2g__ExternalId__c = 'ABCDE1234567876';
        userCompany.c2g__UnitOfWork__c = 111 ;
        insert  userCompany;
        
        c2g__codaAccountingCurrency__c accCurrency = new c2g__codaAccountingCurrency__c();
        accCurrency.c2g__OwnerCompany__c = company.id;
        accCurrency.c2g__DecimalPlaces__c = 2;
        accCurrency.Name = 'USD';
        accCurrency.c2g__Dual__c = true ;
        accCurrency.c2g__Home__c = true ;
        //accCurrency.ownerid = testGroup.Id;
        insert accCurrency;
*/        //////////
        //////////
        //////////
/*        
        List<Dunning_Admin__c > dunnings = new List<Dunning_Admin__c >();
        
        Dunning_Admin__c dadmin = new Dunning_Admin__c();
        dadmin.Dunning_Level__c = '1st Reminder';
        dadmin.Nr_of_Days_to_Pay__c=1;
        dadmin.Active__c='Yes';
        dadmin.Dunning_Frequency__c=4;
        dadmin.Email_Template__c='Primeiro_Aviso_ou_Interpelacao';
        dadmin.Past_Due_Days__c=7; 
        dunnings.add(dadmin);
        
        Dunning_Admin__c dadmin2 = new Dunning_Admin__c();
        dadmin2.Dunning_Level__c = '2nd Reminder';
        dadmin2.Nr_of_Days_to_Pay__c=1;
        dadmin2.Active__c='Yes';
        dadmin2.Dunning_Frequency__c=4;
        dadmin2.Email_Template__c='Segundo_Aviso_ou_Interpelacao';
        dadmin2.Past_Due_Days__c=7;
        dunnings.add(dadmin2);
        
        Dunning_Admin__c dadmin3 = new Dunning_Admin__c();
        dadmin3.Dunning_Level__c = '3rd Reminder';
        dadmin3.Nr_of_Days_to_Pay__c=1;
        dadmin3.Active__c='Yes';
        dadmin3.Dunning_Frequency__c=4;
        dadmin3.Email_Template__c='Terceiro_Aviso_ou_Interpelacao';
        dadmin3.Past_Due_Days__c=7;
        dunnings.add(dadmin3);
        
        insert dunnings;
*/      
        Dunning_Admin__c dadmin = [SELECT Id, Dunning_Level__c, Nr_of_Days_to_Pay__c, Active__c, Dunning_Frequency__c, Email_Template__c, Past_Due_Days__c FROM Dunning_Admin__c WHERE Dunning_Level__c = '1st Reminder'];
        Dunning_Admin__c dadmin2 = [SELECT Id, Dunning_Level__c, Nr_of_Days_to_Pay__c, Active__c, Dunning_Frequency__c, Email_Template__c, Past_Due_Days__c FROM Dunning_Admin__c WHERE Dunning_Level__c = '2nd Reminder'];
        Dunning_Admin__c dadmin3 = [SELECT Id, Dunning_Level__c, Nr_of_Days_to_Pay__c, Active__c, Dunning_Frequency__c, Email_Template__c, Past_Due_Days__c FROM Dunning_Admin__c WHERE Dunning_Level__c = '3rd Reminder'];
/*        
        c2g__codaGeneralLedgerAccount__c generalLedgerAcc = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAcc.Name = '21110 - CLIENTES NACIONAIS';
        generalLedgerAcc.c2g__ReportingCode__c = '21110';
        generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
        insert generalLedgerAcc;
                
        c2g__codaTaxCode__c taxv2 = new c2g__codaTaxCode__c();
        taxv2.Name = 'textTaxv2';
        taxv2.c2g__Description__c ='testTaxv2 description';   
        taxv2.c2g__GeneralLedgerAccount__c = generalLedgerAcc.id;
        insert taxv2;
*/
/*        
        List<Product2 > prodts= new List<Product2 >();
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(name='1.º Aviso ou interpelação',ProductCode = 'PT04');
        prodts.add(prod);    
        Product2 prod2 = new Product2(name='2.º Aviso ou interpelação',ProductCode = 'PT04');
        prodts.add(prod2);  
        Product2 prod3 = new Product2(name='3.º Aviso ou interpelação',ProductCode = 'PT04');
        prodts.add(prod3);
        Product2 prod4 = new Product2(name='Aluguer',ProductCode = 'PT01');  //,c2g__CODAInputTaxCode__c = taxv2.Id
        prodts.add(prod4);  
         
        insert prodts;
*/        
        Product2 prod = [SELECT Id, name, ProductCode, c2g__CODAInputTaxCode__c FROM Product2 WHERE name='1.º Aviso ou interpelação' AND ProductCode = 'PT04' Limit 1];
        Product2 prod2 = [SELECT Id, name, ProductCode, c2g__CODAInputTaxCode__c FROM Product2 WHERE name='2º. Aviso ou interpelação' AND ProductCode = 'PT05' Limit 1];
        Product2 prod3 = [SELECT Id, name, ProductCode, c2g__CODAInputTaxCode__c FROM Product2 WHERE name='3º. Aviso ou interpelação' AND ProductCode = 'PT13' Limit 1];
        Product2 prod4 = [SELECT Id, name, ProductCode, c2g__CODAInputTaxCode__c FROM Product2 WHERE ProductCode = 'PT01'  Limit 1];
        
/*        
        List<PricebookEntry> prices = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod.id, IsActive = true, UseStandardPrice = false);
        prices.add(pbe);
        PricebookEntry pbe2 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod2.id, IsActive = true, UseStandardPrice = false);
        prices.add(pbe2);
        PricebookEntry pbe3 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod3.id, IsActive = true, UseStandardPrice = false);
        prices.add(pbe3);
        PricebookEntry pbe4 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod4.id, IsActive = true, UseStandardPrice = false);
        prices.add(pbe4);
        insert prices;
*/        
        List<Dunning_Product__c> dunningprodts = new List<Dunning_Product__c>();
        Dunning_Product__c dp = new Dunning_Product__c();
        dp.Dunning_Admin__c = dadmin.id;
        dp.Product__c = prod.id;
        dunningprodts.add(dp);
        
        Dunning_Product__c dp2 = new Dunning_Product__c();
        dp2.Dunning_Admin__c = dadmin2.id;
        dp2.Product__c = prod2.id;
        dunningprodts.add(dp2);
        
        Dunning_Product__c dp3 = new Dunning_Product__c();
        dp3.Dunning_Admin__c = dadmin3.id;
        dp3.Product__c = prod3.id;
        dunningprodts.add(dp3);
        
        insert dunningprodts;
 /*       
        List<Account> listacc = new List<Account>();
        Account client = new Account();
        client.Name = 'EasyPay2'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '5007666313';
        client.BillingCity = 'Lx';
        client.BillingPostalCode = '3000-423';
        client.BillingStreet = 'BillingStreet';
        client.Website = 'webSite';
        client.Phone = '00351964639755';
        client.Fax = '00351964639755';
        client.c2g__CODAAccountTradingCurrency__c = 'USD';
        client.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';

        c2g__codaGeneralLedgerAccount__c generalLedgerAccountClient = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
        client.c2g__CODAAccountsReceivableControl__c= generalLedgerAccountClient.id;

        listacc.add(client);
   
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630333';
        vendor.c2g__CODAInvoiceEmail__c = 'jhonDoe@email.com';
        vendor.Moloni_Client_ID__c = '1421';
        vendor.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        listacc.add(vendor);
        
        insert listacc; 
*/      
        Account vendor = new Account();
        vendor.Name = '1 Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630330213';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        system.debug('Vendor_Trs '+ vendor);
        
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
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
        client.c2g__CODAAccountsReceivableControl__c= generalLedgerAccount.id; //'a2l24000000U9vnAAC';
        system.debug('ClientTRS '+ Client);
        
        insert client;
        
        List<Collection_Case__c> listccs = new List<Collection_Case__c>(); 
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c = client.id;
        listccs.add(cc);
        
        Collection_Case__c cc1 = new Collection_Case__c();
        cc1.Account__c = client.id;
        listccs.add(cc1);
        
        insert listccs;
        
        List<Dunning_Alert__c> listdalerts = new List<Dunning_Alert__c>();
        Dunning_Alert__c da1 = new Dunning_Alert__c();
        da1.Dunning_Level__c = '1st Reminder';
        da1.Level__c = '1';
        da1.Status__c= 'Open';
        da1.Collection_Case__c = cc.Id;
        da1.Sent_Date__c = date.today().addDays(-8);
        da1.Due_Date__c = date.today().addDays(-1);
        da1.Email_Send_Date__c = date.today().addDays(-8);
        listdalerts.add(da1);
        
        Dunning_Alert__c da2 = new Dunning_Alert__c();
        da2.Dunning_Level__c = '2nd Reminder';
        da2.Level__c = '2';
        da2.Status__c= 'Open';
        da2.Collection_Case__c = cc.Id;
        da2.Sent_Date__c = date.today().addDays(-8);
        da2.Due_Date__c = date.today().addDays(-1);
        da2.Email_Send_Date__c = date.today().addDays(-8);
        listdalerts.add(da2);
        
        Dunning_Alert__c da3 = new Dunning_Alert__c();
        da3.Dunning_Level__c = '3rd Reminder';
        da3.Level__c = '3';
        da3.Status__c= 'Open';
        da3.Collection_Case__c = cc.Id;
        da3.Sent_Date__c = date.today().addDays(-8);
        da3.Due_Date__c = date.today().addDays(-1);
        da3.Email_Send_Date__c = date.today().addDays(-8);
        listdalerts.add(da3);
        
        insert listdalerts;
                
        Contact contact = new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c ='Binding Power';
        contact.AccountId = client.id;
        insert contact;
        
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        insert login;
        
        Application__c app= new Application__c(Vendor__c = vendor.id,AccClient__c = client.ID,IdLoginCreate__c = login.Id, Vendor_Primary__c = contact.id );
        app.Invoice_To__c = contact.ID;
        app.status__c = 'Contract - Running';
        app.Obs_Invoice__c = 'App Notes';
        insert app;
        
        c2g__codainvoice__c invoice = new c2g__codainvoice__c();
        invoice.c2g__account__c = client.Id;
        invoice.Collection_Case__c = cc.Id;
        invoice.c2g__InvoiceDate__c = date.today();
        invoice.c2g__DueDate__c = date.today();
        invoice.c2g__InvoiceStatus__c='In progress'; 
        invoice.Application__c = app.Id;
        insert invoice;
                
        c2g__codaInvoiceLineItem__c invoiceitem = new c2g__codaInvoiceLineItem__c();
        invoiceitem.c2g__Invoice__c = invoice.Id;
        invoiceitem.c2g__Quantity__c = 1;
        invoiceitem.c2g__LineNumber__c = 1;
        invoiceitem.c2g__UnitPrice__c = 10;
        invoiceitem.c2g__Product__c = prod4.Id;
        invoiceitem.c2g__DeriveUnitPriceFromProduct__c = false;
        invoiceitem.c2g__TaxCode1__c = prod4.c2g__CODAInputTaxCode__c;
        insert invoiceitem;
        
        
        //SalesInvoce.create(new List<Id>{cc.Id}, '1st Reminder');
        
//        SalesInvoce.create(new List<Id>{cc.Id}, '2nd Reminder');
        Test.startTest();
        SalesInvoce.create(new List<Id>{cc.Id}, '3rd Reminder');
        
        
        Test.stopTest();
    }
    
    //create sin, Payment Collection and Sepa Reference
    public static testmethod void createSIN(){
    	RentingApplication_Util_Test rentApp = new RentingApplication_Util_Test();
    	rentApp.environment9();
    } 
    
    //SIN is created for a CC
    public static testMethod void shouldCreateCollectionSalesInvoiceWhenInserting(){
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        
        List<Product2> InvoiceLineItems = new List<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'Pagamento por Multibanco';
        p1.ProductCode = 'PT03';
        Product2 p2 = new Product2();
        p2.Name = 'Despesas Relacionadas com Alterações ao Contrato';
        p2.ProductCode = 'PT16';
        InvoiceLineItems.add(p1);
        InvoiceLineItems.add(p2);
        insert InvoiceLineItems;
        
        Test.startTest();
        testInvoice = ClientAppService_TestUtils.createInvoice(testApp, testClient, testCollectionCase, taxZone, InvoiceLineItems, null);
        Test.stopTest();
        
        List<Collection_Sales_Invoice__c> aux = [SELECT Id FROM Collection_Sales_Invoice__c WHERE Sales_Invoice__c = :testInvoice.Id];
        system.assert(aux.size() > 0, 'Didnt create the collection sales invoice when inserting a SIN with a Collection Case');
    }
    
    //SIN is added to a CC
    public static testMethod void shouldCreateCollectionSalesInvoiceWhenUpdating(){
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        
        List<Product2> InvoiceLineItems = new List<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'Pagamento por Multibanco';
        p1.ProductCode = 'PT03';
        Product2 p2 = new Product2();
        p2.Name = 'Despesas Relacionadas com Alterações ao Contrato';
        p2.ProductCode = 'PT16';
        InvoiceLineItems.add(p1);
        InvoiceLineItems.add(p2);
        insert InvoiceLineItems;
        
        Test.startTest();
        //create with no CC
        testInvoice = ClientAppService_TestUtils.createInvoice(testApp, testClient, null, taxZone, InvoiceLineItems, null);
        
        List<Collection_Sales_Invoice__c> aux = [SELECT Id FROM Collection_Sales_Invoice__c WHERE Sales_Invoice__c = :testInvoice.Id];
        system.assert(aux.size() == 0, 'Created a collection sales invoice when SIN didnt have a Collection Case');
        
        //update to have CC
        testInvoice.Collection_Case__c = testCollectionCase.Id;
        update testInvoice;
        
        aux = [SELECT Id FROM Collection_Sales_Invoice__c WHERE Sales_Invoice__c = :testInvoice.Id];
        system.assert(aux.size() > 0, 'Didnt create the collection sales invoice when updating a SIN to have a Collection Case');
        
        Test.stopTest();
    }
    
    //SIN is removed from a CC
    public static testMethod void shouldDeleteCollectionSalesInvoiceWhenUpdating(){
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        
        List<Product2> InvoiceLineItems = new List<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'Pagamento por Multibanco';
        p1.ProductCode = 'PT03';
        Product2 p2 = new Product2();
        p2.Name = 'Despesas Relacionadas com Alterações ao Contrato';
        p2.ProductCode = 'PT16';
        InvoiceLineItems.add(p1);
        InvoiceLineItems.add(p2);
        insert InvoiceLineItems;
        
        Test.startTest();
        //create with CC
        testInvoice = ClientAppService_TestUtils.createInvoice(testApp, testClient, testCollectionCase, taxZone, InvoiceLineItems, null);
        
        //update to remove from CC
        testInvoice.Collection_Case__c = null;
        update testInvoice;
        
        List<Collection_Sales_Invoice__c> aux = [SELECT Id FROM Collection_Sales_Invoice__c WHERE Sales_Invoice__c = :testInvoice.Id];
        system.assert(aux.size() == 0, 'Didnt delete the collection sales invoice when updating a SIN to be removed from a Collection Case');
        
        Test.stopTest();
    }
}