@isTest  
private class test_DunningAlert{
    
    static void createDunningAdmin(){
        
        //insert dunning admin
        Dunning_Admin__c dadmin = new Dunning_Admin__c();
        dadmin.Dunning_Level__c = '1st Reminder';
        dadmin.Nr_of_Days_to_Pay__c=1;
        dadmin.Active__c='Yes';
        dadmin.Dunning_Frequency__c=4;
        dadmin.Email_Template__c='Primeiro_Aviso_ou_Interpelacao';
        dadmin.Past_Due_Days__c=7; 
        insert dadmin;
        
        Dunning_Admin__c dadmin2 = new Dunning_Admin__c();
        dadmin2.Dunning_Level__c = '2nd Reminder';
        dadmin2.Nr_of_Days_to_Pay__c=1;
        dadmin2.Active__c='Yes';
        dadmin2.Dunning_Frequency__c=4;
        dadmin2.Email_Template__c='Segundo_Aviso_ou_Interpelacao';
        dadmin2.Past_Due_Days__c=7;
        insert dadmin2;
        
        Dunning_Admin__c dadmin3 = new Dunning_Admin__c();
        dadmin3.Dunning_Level__c = '3rd Reminder';
        dadmin3.Nr_of_Days_to_Pay__c=1;
        dadmin3.Active__c='Yes';
        dadmin3.Dunning_Frequency__c=4;
        dadmin3.Email_Template__c='Terceiro_Aviso_ou_Interpelacao';
        dadmin3.Past_Due_Days__c=7;
        insert dadmin3;
        
        Dunning_Admin__c dadmin4 = new Dunning_Admin__c();
        dadmin4.Dunning_Level__c = '4th Reminder';
        dadmin4.Nr_of_Days_to_Pay__c=1;
        dadmin4.Active__c='Yes';
        dadmin4.Dunning_Frequency__c=4;
        dadmin4.Email_Template__c='Quarto_Aviso_ou_Interpelacao';
        dadmin4.Past_Due_Days__c=7;
        insert dadmin4;
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(name='1.º Aviso ou interpelação',ProductCode = 'PT04');
        insert prod;    
        Product2 prod2 = new Product2(name='2.º Aviso ou interpelação',ProductCode = 'PT04');
        insert prod2;  
        Product2 prod3 = new Product2(name='3.º Aviso ou interpelação',ProductCode = 'PT04');
        insert prod3;  
        Product2 prod4 = new Product2(name='4.º Aviso ou interpelação',ProductCode = 'PT04');
        insert prod4;
        
        PricebookEntry pbe = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod.id, IsActive = true, UseStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod2.id, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        PricebookEntry pbe3 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod3.id, IsActive = true, UseStandardPrice = false);
        insert pbe3;
        PricebookEntry pbe4 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod4.id, IsActive = true, UseStandardPrice = false);
        insert pbe4;
        
        Dunning_Product__c dp = new Dunning_Product__c();
        dp.Dunning_Admin__c=dadmin.id;
        dp.Product__c=prod.id;
        insert dp;
        
        Dunning_Product__c dp2 = new Dunning_Product__c();
        dp2.Dunning_Admin__c=dadmin2.id;
        dp2.Product__c=prod2.id;
        insert dp2;
        
        Dunning_Product__c dp3 = new Dunning_Product__c();
        dp3.Dunning_Admin__c=dadmin3.id;
        dp3.Product__c=prod3.id;
        insert dp3;
        
        Dunning_Product__c dp4 = new Dunning_Product__c();
        dp4.Dunning_Admin__c=dadmin4.id;
        dp4.Product__c=prod4.id;
        insert dp4;
    }
    
    static testMethod void test_DunningAlert(){
        
        Test.startTest();
        
        //DUNNING ADMINS
        //////////
        createDunningAdmin();
        //////////        
        Legal_Fees__c lf = new Legal_Fees__c();
        lf.Name ='Interest Rate';
        lf.Interest_Rate__c = 15;
        insert lf;
        //SALES INVOICE
        //////////
        //////////
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        QueuesObject testQueue ; 
        System.runAs(new User(Id=UserInfo.getUserId())){
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
            GroupMemberObj.UserOrGroupId = UserInfo.getUserId();
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
        credential.name = 'EasyPayX';
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
        //////////
        //////////
        //////////
        
        //create test data
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '5007666313';
        client.BillingCity = 'Lx';
        client.BillingPostalCode = '3000-423';
        client.BillingStreet = 'BillingStreet';
        client.Website = 'webSite';
        client.Phone = '00351964639755';
        client.Fax = '00351964639755';
        client.c2g__CODAAccountTradingCurrency__c = 'AED';
        client.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        insert client;
        //system.debug('Client ID: ' + client.ID);
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630333';
        vendor.c2g__CODAInvoiceEmail__c = 'jhonDoe@email.com';
        vendor.Moloni_Client_ID__c = '1421';
        vendor.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        insert vendor;
        //system.debug('Vendor ID: ' + Vendor.ID);
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId=client.id;
        insert contact;
        //system.debug('contact ID: ' + contact.ID);
        
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        insert login;
        //system.debug('login ID: ' + login.ID);
        
        /*Application__c app= new Application__c(Vendor__c=vendor.id, AccClient__c=client.ID, IdLoginCreate__c=login.Id, Vendor_Primary__c=contact.id );
app.Invoice_To__c = contact.ID;
app.status__c = 'Contract - Running';
app.Obs_Invoice__c = 'App Notes';*/        
        
        Application__c app              = new Application__c();
        app.Vendor__c                   = vendor.Id;
        app.AccClient__c                = client.Id;
        app.Status__c                   = 'Application - Approved';
        app.Term__c                     = '6';
        app.TermCalc__c                 = 6;
        app.Invoice_Payment_Date__c     = Date.newInstance(2017, 02, 01);
        app.Payment_Timing__c           = 'Advanced';
        app.Payment_Freq__c             = 'Monthly';
        app.Payment_Amount__c           = 120;
        app.Equipment_Cost__c           = 2000;
        app.Insurance_Type__c           = 'Own Insurance';
        app.Client_BBAN__c              = '003500007681899000150';
        app.Annual_Interest_Rate__c     = 7.42;
        app.Insurance_Special_Value__c  = 1;
        app.Insurance_Movement_value__c = 2; 
        app.Insurance_Value__c          = 5;
        app.Delivery_Certificate_Signed__c =  Date.newInstance(2017, 02, 01);
        
        app.Insurance_Type__c='Static Risk';
        
        insert app;        
        
        //COLLECTION CASE
        ////////////
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c = client.id;
        cc.Status__c='Open';
        insert cc;
        
        c2g__codainvoice__c invoice = new c2g__codainvoice__c();
        invoice.c2g__account__c = client.Id; 
        invoice.Collection_Case__c = cc.Id;
        invoice.c2g__InvoiceDate__c = date.today();
        invoice.c2g__DueDate__c = date.today();
        invoice.c2g__InvoiceStatus__c='In progress'; 
        invoice.Application__c=app.Id;         
        
        insert invoice;
        
        
        c2g__codainvoice__c invoice2 = new c2g__codainvoice__c();
        invoice2.c2g__account__c = client.Id;
        invoice2.Collection_Case__c = cc.Id;
        invoice2.c2g__InvoiceDate__c = date.today();
        invoice2.c2g__DueDate__c = date.today();
        invoice2.c2g__InvoiceStatus__c='In progress'; 
        invoice2.Application__c=app.Id;
        
        insert invoice2;
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(name='Aluguer',ProductCode = 'PT01');
        insert prod;   
        
        
        PricebookEntry pbe = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod.id, IsActive = true, UseStandardPrice = false);
        insert pbe;
        
        c2g__codaInvoiceLineItem__c invoiceitem = new c2g__codaInvoiceLineItem__c();
        invoiceitem.c2g__Invoice__c = invoice.ID;
        invoiceitem.c2g__Quantity__c = 1;
        invoiceitem.c2g__LineNumber__c =1;
        invoiceitem.c2g__UnitPrice__c=10;
        invoiceitem.c2g__Product__c= prod.ID;
        invoiceitem.c2g__DeriveUnitPriceFromProduct__c=false;
        invoiceitem.c2g__TaxCode1__c= prod.c2g__CODAInputTaxCode__c;
        insert invoiceitem;
        
        List<c2g__codaInvoice__c> m_ci = new List<c2g__codaInvoice__c>();
        m_ci = [Select id From c2g__codaInvoice__c where c2g__Account__c =: client.ID];
        
        /*Dunning_Alert__c da = new Dunning_Alert__c();
da.Dunning_Level__c='3rd Reminder'; 
da.Level__c='3';
da.Status__c='Open';
da.Collection_Case__c=cc.Id;
da.Sent_Date__c=date.today().addDays(-8);
da.Due_Date__c=date.today().addDays(-1);
da.Email_Send_Date__c=date.today().addDays(-8);
da.Flow__c = 'Manual';*/
        
        c_DunningAlert cda = new c_DunningAlert();
        Dunning_Alert__c da = cda.insDunningAlert(cc.Id, '3rd Reminder', '3', date.today().addDays(-8), date.today().addDays(-8), date.today().addDays(-1), 100,'Manual');
        //da.Flow__c = 'Manual';
        insert da;
        
        Dunning_Alert__c da2 = cda.updateDunningAlert(da.Id, 121,11, date.today().addDays(-1));
        update da2; 
        
        cda.Manage1st(cc.Id, da.Id);
        
        cda.Manage2nd(cc.Id, da.Id);
        
        Interest_Charged_Calculation__c icc = new Interest_Charged_Calculation__c();
        icc.Days_Overdue__c =1;
        icc.Invoice_Due_Date__c = date.today();
        icc.Dunning_Alert__c = da.id;
        icc.Interest_Rate__c = 1;
        //icc.Interest_Charged__c = 1; 
        //icc.Invoice_Amount__c =2;
        
        
        insert icc; 
        
        c_DunningAlert dalert = new c_DunningAlert();
        
        Test.stopTest();
    }   
    
}