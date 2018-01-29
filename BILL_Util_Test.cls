//Generic class to be used in test class of BILL Model
@isTest
public class BILL_Util_Test{
    static public Id invoiceId = null;
    static public Id creditNoteId = null;

    static public void setFinancialForce(){
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
		
		Control_Flags__c flags = new Control_Flags__c(Name = 'SCN');
		flags.SCN_Post_Moloni__c = true;
		insert flags;
	
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
		
		c2g__codaYear__c yr= new c2g__codaYear__c();
		yr.Name ='2015';
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
		prd.Name ='Test2015';
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
	
		c2g__codaGeneralLedgerAccount__c GLAcc = new c2g__codaGeneralLedgerAccount__c();
		GLAcc.Name = 'Retained Earnings';
		GLAcc.c2g__BalanceSheet1__c ='Balance Sheet'; 
		GLAcc.c2g__ExternalId__c ='testID';
		GLAcc.c2g__ReportingCode__c = '1234567543333';
		GLAcc.c2g__UnitOfWork__c =123;
		GLAcc.c2g__TrialBalance1__c = 'Balance Sheet' ;
		GLAcc.c2g__Type__c = 'Balance Sheet' ;
		insert GLAcc;
        ///////
      
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
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        insert contact;
        system.debug('contact ID: ' + contact.ID);
        
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        insert login;
        system.debug('login ID: ' + login.ID);
        
        Application__c app= new Application__c(Vendor__c=vendor.id, AccClient__c=client.ID, IdLoginCreate__c=login.Id, Vendor_Primary__c=contact.id );
        app.Invoice_To__c = contact.ID;
        app.status__c = 'Contract - Running';
        app.Obs_Invoice__c = 'App Notes';
        insert app;
        
        c2g__codainvoice__c invoice = new c2g__codainvoice__c();
        invoice.c2g__account__c = client.ID;
        invoice.c2g__InvoiceDate__c = date.today();
        invoice.c2g__DueDate__c = date.today();
        invoice.c2g__InvoiceStatus__c='In progress';
        invoice.Application__c=app.ID;
        insert invoice;
        
        Product2 prod = new Product2();
        prod.Name = 'TESTE11';
        prod.ProductCode =  'TESTE11';
        prod.Description='Aluguer Trimestral Proporcional Equipamento CANDOR RENTING S.A. TESTE11';
        prod.Moloni_Product_ID__c = 11111;
        insert prod;
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAccount.Name = 'geneLeAccountName';
        generalLedgerAccount.c2g__ReportingCode__c = 'code';
        generalLedgerAccount.c2g__Type__c = 'Balance Sheet';
        insert generalLedgerAccount;
    
        c2g__codaTaxCode__c tax = new c2g__codaTaxCode__c();
        tax.Name = 'TaxName';
        tax.c2g__Description__c = 'Description taxes';
        tax.Moloni_TAX_ID__c = '213';
        tax.c2g__GeneralLedgerAccount__c = generalLedgerAccount.id;
        insert tax;
        
        c2g__codaTaxRate__c taxesRate = new c2g__codaTaxRate__c();
        taxesRate.c2g__StartDate__c = System.Today();
        taxesRate.c2g__Rate__c = 2;
        taxesRate.c2g__TaxCode__c = tax.id;
        insert taxesRate;
        
        c2g__codaInvoiceLineItem__c invoiceitem = new c2g__codaInvoiceLineItem__c();
        invoiceitem.c2g__Invoice__c = invoice.ID;
        invoiceitem.c2g__Quantity__c = 1;
        invoiceitem.c2g__LineNumber__c =1;
        invoiceitem.c2g__UnitPrice__c=10;
        invoiceitem.c2g__Product__c=prod.id;
        invoiceitem.c2g__DeriveUnitPriceFromProduct__c=false;
        invoiceitem.c2g__TaxCode1__c=tax.ID;
        insert invoiceitem;
        system.debug('invoice ID: ' + invoice.ID);
        invoiceId = invoice.ID;    

//        c2g.CODAAPICommon.Reference refInvoice = new c2g.CODAAPICommon.Reference();
//        refInvoice.Id = invoiceId;
//        c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, refInvoice);
        //Credit Note
      
        c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
        creditNote.c2g__CreditNoteDate__c = date.today();
        creditNote.c2g__Period__c = prd.id; 
        creditNote.c2g__CreditNoteCurrency__c = accCurrency.id; 
        creditNote.c2g__Account__c = vendor.id;
        insert creditNote;

        c2g__codaCreditNoteLineItem__c creditNotesLI = new c2g__codaCreditNoteLineItem__c();
        creditNotesLI.c2g__TaxCode1__c = tax.ID;
        creditNotesLI.c2g__Product__c = prod.id;
        creditNotesLI.c2g__CreditNote__c = creditNote.id;
        creditNotesLI.c2g__DeriveUnitPriceFromProduct__c = false;
        insert creditNotesLI;
        
        creditNoteId = creditNote.ID;
        
//        c2g.CODAAPICommon.Reference refCreditNote = new c2g.CODAAPICommon.Reference();
//        refCreditNote.Id = creditNoteId;
//        c2g.CODAAPISalesCreditNote_7_0.PostCreditNote(null, refCreditNote);
    }  
    
    static public void setMoloniData(){   
    	//values of the custom setting
        List<BILL_CS_Moloni__c> moloniCSValueList = new List<BILL_CS_Moloni__c>();
        BILL_CS_Moloni__c moloniCSValue = new BILL_CS_Moloni__c();
        moloniCSValue.Name = '1';
        moloniCSValue.Moloni_Id__c = '87199';
        moloniCSValueList.add(moloniCSValue);
        
        moloniCSValue = new BILL_CS_Moloni__c();
        moloniCSValue.Name = '2';
        moloniCSValue.Moloni_Id__c = '86229';
        moloniCSValueList.add(moloniCSValue);
        
        moloniCSValue = new BILL_CS_Moloni__c();
        moloniCSValue.Name = '3';
        moloniCSValue.Moloni_Id__c = '32939';
        moloniCSValueList.add(moloniCSValue);
        
        moloniCSValue = new BILL_CS_Moloni__c();
        moloniCSValue.Name = '4';
        moloniCSValue.Moloni_Id__c = '86230';
        moloniCSValueList.add(moloniCSValue);
        
        moloniCSValue = new BILL_CS_Moloni__c();
        moloniCSValue.Name = '5';
        moloniCSValue.Moloni_Id__c = '167175';
        moloniCSValueList.add(moloniCSValue);
        
        moloniCSValue = new BILL_CS_Moloni__c();
        moloniCSValue.Name = '6';
        moloniCSValue.Moloni_Id__c = '1400';
        moloniCSValueList.add(moloniCSValue);

        insert moloniCSValueList;
        
        Credentials__c credential = new Credentials__c();
        credential.Name = 'Moloni';
        credential.Username__c = 'yy';
        credential.Password__c = 'yy';
        credential.developer_id__c = 'yy';
        credential.client_secret_code__c = 'yy';
        credential.Web_Service_Url__c = 'https://api.moloni.com/sandbox/';
        credential.AccountID__c = '0';
        credential.Web_Service_Url_TEST_ENVIRONMENT__c = 'https://api.moloni.com/sandbox/';
        
        insert credential;
    }
    
}