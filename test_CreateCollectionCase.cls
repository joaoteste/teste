@isTest  
public class test_CreateCollectionCase{

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
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(name='1.º Aviso ou interpelação',ProductCode = 'PT04');
        insert prod;    
        Product2 prod2 = new Product2(name='2.º Aviso ou interpelação',ProductCode = 'PT04');
        insert prod2;  
        Product2 prod3 = new Product2(name='3.º Aviso ou interpelação',ProductCode = 'PT04');
        insert prod3;  
        
        PricebookEntry pbe = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod.id, IsActive = true, UseStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod2.id, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        PricebookEntry pbe3 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod3.id, IsActive = true, UseStandardPrice = false);
        insert pbe3;
        
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
    }
    
    
   static testMethod void pageCreateCollectionCase_Test() {
        
        Test.startTest();
        
        //DUNNING ADMINS
        //////////
        createDunningAdmin();
        //////////        
        
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
        credential.name = 'EasyPay';
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
        system.debug('Client ID: ' + client.ID);
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630333';
        vendor.c2g__CODAInvoiceEmail__c = 'jhonDoe@email.com';
        vendor.Moloni_Client_ID__c = '1421';
        vendor.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        insert vendor;
        system.debug('Vendor ID: ' + Vendor.ID);
        
        //Collection_Case__c cc = new Collection_Case__c();
        //cc.Account__c = client.id;
        //cc.Status__c='Open';
        //insert cc; 
       
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId=client.id;
        insert contact;
        system.debug('contact ID: ' + contact.ID);
        
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        insert login;
        system.debug('login ID: ' + login.ID);
        
        //Application__c app = new Application__c(AccClient__c=client.Id, Vendor__c=vendor.Id,Status__c='Contract - Arrears');
        //insert app;
         
        Application__c app= new Application__c(Vendor__c=vendor.id, AccClient__c=client.ID, IdLoginCreate__c=login.Id, Vendor_Primary__c=contact.id );
        app.Invoice_To__c = contact.ID;
        app.status__c = 'Contract - Arrears';
        app.Obs_Invoice__c = 'App Notes';
        insert app;
       
        /*Billing_Contract__c bc = new Billing_Contract__c();
        bc.Application__c = app.id;       
        bc.Collection_Case__c = cc.Id;
        
        insert bc;*/
        
                       
        c2g__codainvoice__c invoice = new c2g__codainvoice__c();
        invoice.c2g__account__c = client.Id;         
        invoice.c2g__InvoiceDate__c = date.today();
        invoice.c2g__DueDate__c = date.today();
        invoice.c2g__InvoiceStatus__c='In progress'; 
        invoice.Application__c=app.Id;
        insert invoice;
        
        c2g__codainvoice__c invoice2 = new c2g__codainvoice__c();
        invoice2.c2g__account__c = client.Id;       
        invoice2.c2g__InvoiceDate__c = date.today();
        invoice2.c2g__DueDate__c = date.today();
        invoice2.c2g__InvoiceStatus__c='In progress'; 
        invoice2.Application__c=app.Id;         
        insert invoice2;
                
        List<c2g__codainvoice__c> invoices = new List<c2g__codainvoice__c>();
        invoices = [Select id From c2g__codaInvoice__c where c2g__Account__c =: client.ID limit 2];
                   
        ApexPages.StandardSetController sdc2 = new ApexPages.StandardSetController(invoices);
        sdc2.setSelected(invoices);
       
       
        c_CreateCollectionCase m_page2 = new c_CreateCollectionCase(sdc2);
        m_page2.validate();
       
        Test.stopTest();
        
    }
    
     static testMethod void pageCreateElseCollectionCase_Test() {
        
        Test.startTest();
        
        //DUNNING ADMINS
        //////////
        createDunningAdmin();
        //////////        
        
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
        credential.name = 'EasyPay';
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
        system.debug('Client ID: ' + client.ID);
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630333';
        vendor.c2g__CODAInvoiceEmail__c = 'jhonDoe@email.com';
        vendor.Moloni_Client_ID__c = '1421';
        vendor.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        insert vendor;
        system.debug('Vendor ID: ' + Vendor.ID);
        
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c = client.id;
        cc.Status__c='Open';
        insert cc; 
       
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId=client.id;
        insert contact;
        system.debug('contact ID: ' + contact.ID);
        
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        insert login;
        system.debug('login ID: ' + login.ID);
        
        //Application__c app = new Application__c(AccClient__c=client.Id, Vendor__c=vendor.Id,Status__c='Contract - Arrears');
        //insert app;
         
        Application__c app= new Application__c(Vendor__c=vendor.id, AccClient__c=client.ID, IdLoginCreate__c=login.Id, Vendor_Primary__c=contact.id );
        app.Invoice_To__c = contact.ID;
        app.status__c = 'Contract - Arrears';
        app.Obs_Invoice__c = 'App Notes';
        insert app;
       
        Billing_Contract__c bc = new Billing_Contract__c();
        bc.Application__c = app.id;       
        bc.Collection_Case__c = cc.Id;
        
        insert bc;
        
                       
        c2g__codainvoice__c invoice = new c2g__codainvoice__c();
        invoice.c2g__account__c = client.Id;         
        invoice.c2g__InvoiceDate__c = date.today();
        invoice.c2g__DueDate__c = date.today();
        invoice.c2g__InvoiceStatus__c='In progress'; 
        invoice.Application__c=app.Id;
        insert invoice;
        
        c2g__codainvoice__c invoice2 = new c2g__codainvoice__c();
        invoice2.c2g__account__c = client.Id;       
        invoice2.c2g__InvoiceDate__c = date.today();
        invoice2.c2g__DueDate__c = date.today();
        invoice2.c2g__InvoiceStatus__c='In progress'; 
        invoice2.Application__c=app.Id;         
        insert invoice2;
                
        List<c2g__codainvoice__c> invoices = new List<c2g__codainvoice__c>();
        invoices = [Select id From c2g__codaInvoice__c where c2g__Account__c =: client.ID limit 2];
                   
        ApexPages.StandardSetController sdc2 = new ApexPages.StandardSetController(invoices);
        sdc2.setSelected(invoices);
       
       
        c_CreateCollectionCase m_page2 = new c_CreateCollectionCase(sdc2);
        m_page2.validate();
       
        Test.stopTest();
        
    }
       
}