//CREATED BY BP - 29/03/17 
//@Apex notation:
//Class to test BILL_ChangeBillingFrequency 

@isTest (SeeAllData=true)
private class BILL_ChangeBillingFrequency_TEST
{
    private static Date dateOfChange;//=Date.newInstance(2017, 3, 12);

    /******************************************************************************************************/
    /*                                      DATA GENERATOR                                                */
    /******************************************************************************************************/

    @isTest static Map<String, ID> generateData()
    {    
        Map<String, ID> dataMap = new Map<String,ID>();
        /******************************************************************************************************/
        /*                                      ACCOUNTS CREATION                                             */
        /******************************************************************************************************/
        
        c2g__codaTaxCode__c taxCode=[select id,name from c2g__codaTaxCode__c where name='CCONT23'];
        Pricebook2 priceBook = [Select id, Name From Pricebook2 where Name = 'Standard Price Book'];

        //New Account Vendor
        Account vendor  = new Account();
        vendor.Name     = 'Test Account Vendor'; 
        vendor.Type     = 'Channel Partner / Vendor';
        vendor.NIF__c   = '503630311';
        vendor.BillingPostalCode = '1234-123';
        vendor.BillingCountryCode = 'PT';
        vendor.c2g__CODAOutputVATCode__c = taxCode.ID;
        insert vendor;
        dataMap.put('vendorID', vendor.ID);
        
        system.debug('taxCode '+ taxCode);

        system.debug('Vendor '+ Vendor);
        
        //New Account Client
        Account client           = new Account();
        client.Name              = 'Test Account Client'; 
        client.Type              = 'Customer - Channel';
        client.NIF__c            = '504092090';
        client.BillingPostalCode = '2180-213';
        client.BillingCountryCode = 'PT';
		client.BillingCountry = 'Portugal';
        client.c2g__CODAInputVATCode__c=taxCode.id;  

        insert client;
        dataMap.put('clientID', client.ID);
        
        //New Contact
        Contact contact = new contact();
        contact.LastName= 'Doe';
        contact.Email   = 'test@email.com';
        contact.Role__c = 'Binding Power';
        contact.AccountId = vendor.Id;
        insert contact;
        dataMap.put('contactID', contact.ID);
    
        /******************************************************************************************************/
        /*                               app_Monthly2QuarterlyS - MONTHLY TO QUARTERLY                        */
        /******************************************************************************************************/
        //Beggining Of term= 1/12/16
        Application__c app_Monthly2Quarterly                    = new Application__c();
        app_Monthly2Quarterly.AccClient__c                      = client.ID;
        app_Monthly2Quarterly.Vendor__c                         = vendor.ID; 
		app_Monthly2Quarterly.Vendor_Primary__c					= contact.ID;
        app_Monthly2Quarterly.Insurance_Type__c                 = 'Special Risk';
        app_Monthly2Quarterly.Insurance_Movement_value__c       = 5.5;
        app_Monthly2Quarterly.Insurance_Special_Value__c        = 4.65;
        app_Monthly2Quarterly.Issuing_Date_Invoice__c           = Date.newInstance(2016, 11, 17);
        app_Monthly2Quarterly.Payment_Timing__c                 = 'Advanced';  
        app_Monthly2Quarterly.Status__c                         = 'Contract - Running';
        app_Monthly2Quarterly.Contract_Sent__c                  = Date.newInstance(2017, 03, 27);
        app_Monthly2Quarterly.Contract_Signed__c                = Date.newInstance(2017, 03, 27);
        app_Monthly2Quarterly.Delivery_Certificate_Sent__c      = Date.newInstance(2017, 03, 27);
        app_Monthly2Quarterly.Delivery_Certificate_Signed__c    = Date.newInstance(2017, 03, 27);
        app_Monthly2Quarterly.Invoice_Payment_Date__c           = Date.newInstance(2017, 03, 27);
        app_Monthly2Quarterly.TermCalc__c                       = 36;
        app_Monthly2Quarterly.Insurance_Special_Value__c        = 9.31;
        app_Monthly2Quarterly.Insurance_Movement_value__c       = 11.01;
        app_Monthly2Quarterly.Client_BBAN__c                    = '004563904014640899590';
        app_Monthly2Quarterly.Payment_Freq__c                   = 'Monthly';
        app_Monthly2Quarterly.Payment_Amount__c                 = 250.36;
        app_Monthly2Quarterly.Generate_Billing__c               = true;
        app_Monthly2Quarterly.Annual_Interest_Rate__c           = 9.2;
        app_Monthly2Quarterly.Vendor_Diluted_Doc_Fee__c         = true;
        app_Monthly2Quarterly.ATM_Reference__c                  = false;
        app_Monthly2Quarterly.Interim_Fee__c                    = false;
        app_Monthly2Quarterly.ATM_Reference_Costs__c            = 0;
        app_Monthly2Quarterly.eSignature_Contract__c            = true;
        app_Monthly2Quarterly.Paper_Contract__c                 = false;
        app_Monthly2Quarterly.Insurance_Pro_Rata_Checkbox__c    = false;
        app_Monthly2Quarterly.VAT_Tax__c =0.23;
        app_Monthly2Quarterly.Factor__c = 2.5;
         //app_Monthly2Quarterly.Vendor_Invoice_Amount__c = 5000;
        app_Monthly2Quarterly.Equipment_Cost__c = 7975.96;
        app_Monthly2Quarterly.recalculateFormulas();
       // app_Monthly2Quarterly.Vendor_Invoice_Amount__c = 5000;
       // app_Monthly2Quarterly.Equipment_Cost__c = 5000;
        app_Monthly2Quarterly.amortization_interest_rate__c = 8.6314;
        app_Monthly2Quarterly.Price_Book__c = priceBook.id;
        insert app_Monthly2Quarterly;
        
        dataMap.put('app_Monthly2Quarterly', app_Monthly2Quarterly.ID);
        /******************************************************************************************************/
        /*                               app_Monthly2Quarterly - QUARTERLY TO MONTHLY                         */
        /******************************************************************************************************/
        //Beggining Of term= 1/1/17
        Application__c app_Quarterly2Monthly                    = new Application__c();
        app_Quarterly2Monthly.AccClient__c                      = client.ID;
        app_Quarterly2Monthly.Vendor__c                         = vendor.ID;        
        app_Quarterly2Monthly.Insurance_Type__c                 = 'Special Risk';
        app_Quarterly2Monthly.Issuing_Date_Invoice__c           = Date.newInstance(2016, 6, 1);
        app_Quarterly2Monthly.Payment_Timing__c                 = 'Advanced'; 
        app_Quarterly2Monthly.Status__c                         = 'Contract - Running';
        app_Quarterly2Monthly.Contract_Sent__c                  = Date.newInstance(2017, 03, 27);
        app_Quarterly2Monthly.Contract_Signed__c                = Date.newInstance(2017, 03, 27);
        app_Quarterly2Monthly.Delivery_Certificate_Sent__c      = Date.newInstance(2017, 03, 27);
        app_Quarterly2Monthly.Delivery_Certificate_Signed__c    = Date.newInstance(2017, 03, 27);      
        app_Quarterly2Monthly.Invoice_Payment_Date__c           = Date.newInstance(2017, 03, 27);
        app_Quarterly2Monthly.TermCalc__c                       = 24;
        app_Quarterly2Monthly.Factor__c = 2.34;
       // app_Quarterly2Monthly.VAT_Tax__c 						= 0.23;
        app_Quarterly2Monthly.Insurance_Special_Value__c        = 9.31;
        app_Quarterly2Monthly.Insurance_Movement_value__c       = 11.01;
        app_Quarterly2Monthly.Client_BBAN__c                    = '004563904014640899590';
        app_Quarterly2Monthly.Payment_Freq__c                   = 'Quarterly';
        app_Quarterly2Monthly.Payment_Amount__c                 = 168.08;
        app_Quarterly2Monthly.Generate_Billing__c               = true;
        app_Quarterly2Monthly.Annual_Interest_Rate__c           = 9.2;
        app_Quarterly2Monthly.Vendor_Diluted_Doc_Fee__c         = true;
        app_Quarterly2Monthly.ATM_Reference__c                  = false;
        app_Quarterly2Monthly.Interim_Fee__c                    = false;
        app_Quarterly2Monthly.ATM_Reference_Costs__c            = 50;
        app_Quarterly2Monthly.eSignature_Contract__c            = true;
        app_Quarterly2Monthly.Paper_Contract__c                 = true;
        app_Quarterly2Monthly.Insurance_Pro_Rata_Checkbox__c    = false;
        //app_Quarterly2Monthly.Vendor_Invoice_Amount__c          = 5000;
        app_Quarterly2Monthly.Equipment_Cost__c                 = 3500;
        app_Quarterly2Monthly.VAT_Tax__c =0.23;
        app_Quarterly2Monthly.amortization_interest_rate__c = 8.6314;
        app_Quarterly2Monthly.recalculateFormulas();
        app_Quarterly2Monthly.Price_Book__c = priceBook.id;
        
        insert app_Quarterly2Monthly;
        
        dataMap.put('app_Quarterly2Monthly', app_Quarterly2Monthly.ID);
        //new BILL_BillingProcess().createBillingInvoice(app_Monthly2Quarterly.Id);
        //new BILL_BillingProcess().createBillingInvoice(app_Quarterly2Monthly.Id);  
        return dataMap;
    }//end generateData method

    /******************************************************************************************************/
    /*                                      BEHAVIOUR METHODS                                             */
    /******************************************************************************************************/

    @isTest static void validateChangeFrequency_Test()
    {
        Map<String,ID> data          = generateData();
        ID app_Monthly2Quarterly     = data.get('app_Monthly2Quarterly');
        Application__c testingApp    = new Application__c(id=app_Monthly2Quarterly);
        testingApp.Payment_Timing__c = 'Arreas';
        update testingApp;
        
        dateOfChange                 = Date.newInstance(2017,06,01);
        Test.startTest();
        new BILL_BillingProcess().createBillingInvoice(testingApp.Id);
        new BILL_ChangeBillingFrequency().changeBillingInvoice(testingApp.Id,true,dateOfChange);
        Test.stopTest();
    }

    /*****/

    @isTest static void DiscountFactor_Vendor_Test()
    {
        Map<String,ID> data              = generateData();
        Account testClient               = new Account(ID = data.get('clientID'));
        ID app_Monthly2Quarterly         = data.get('app_Monthly2Quarterly');
        ID clientID                      = data.get('vendorID') ;
        Account testingVendor            = new Account(ID=clientID);
        testingVendor.Discount_Factor__c = '0,7%';
        update testingVendor;
        
        dateOfChange                     = Date.newInstance(2017,06,01);    
        Test.startTest();
        new BILL_BillingProcess().createBillingInvoice(app_Monthly2Quarterly);
        new BILL_ChangeBillingFrequency().changeBillingInvoice(app_Monthly2Quarterly,true,dateOfChange);    
        Test.stopTest();
    }

    @isTest static void DiscountFactor_Vendor_Test1()
    {
        Map<String,ID> data              = generateData();
        Account testClient               = new Account(ID = data.get('clientID'));
        ID app_Quarterly2Monthly         = data.get('app_Quarterly2Monthly');
        ID clientID                      = data.get('vendorID') ;
        Account testingVendor            = new Account(ID=clientID);
        testingVendor.Discount_Factor__c = '0,7%';
        update testingVendor;

        dateOfChange                     = Date.newInstance(2017,06,01);  
        Test.startTest();
        new BILL_BillingProcess().createBillingInvoice(app_Quarterly2Monthly);
        new BILL_ChangeBillingFrequency().changeBillingInvoice(app_Quarterly2Monthly,true,dateOfChange);    
        Test.stopTest();
    }
    /*****/

    @isTest static void buttonFalse_Test()
    {
        Map<String,ID> data      = generateData();
        Account testClient       = new Account(ID = data.get('clientID'));
        ID app_Quarterly2Monthly = data.get('app_Quarterly2Monthly');
        /*Application__c app = new Application__c(ID = app_Quarterly2Monthly);
        //app.Vendor_Invoice_Amount__c          = 5000;
        app.Equipment_Cost__c                 = 5000;
        app.VAT_Tax__c =0.23;
        update app;*/

        dateOfChange             = Date.newInstance(2017,09,27);    
        Test.startTest();
        new BILL_BillingProcess().createBillingInvoice(app_Quarterly2Monthly);
        new BILL_ChangeBillingFrequency().changeBillingInvoice(app_Quarterly2Monthly,false,dateOfChange);   
        Test.stopTest();
    }

    @isTest static void buttonFalse_Test1()
    {
        Map<String,ID> data      = generateData();
        Account testClient       = new Account(ID = data.get('clientID'));
        ID app_Monthly2Quarterly = data.get('app_Monthly2Quarterly');
        
        dateOfChange             = Date.newInstance(2017,09,27);  
        Test.startTest();
        new BILL_BillingProcess().createBillingInvoice(app_Monthly2Quarterly);
        new BILL_ChangeBillingFrequency().changeBillingInvoice(app_Monthly2Quarterly,false,dateOfChange);   
        Test.stopTest();    
    }

    /*****/
	
    @isTest static void nullBillingContract_Test()
    {
        Map<String,ID> data      = generateData();
        Account testClient       = new Account(ID = data.get('clientID'));
        ID app_Quarterly2Monthly = data.get('app_Quarterly2Monthly');
        
        dateOfChange             = Date.newInstance(2017,04,17);
        delete[SELECT ID FROM Billing_Contract__c WHERE Application__c=:app_Quarterly2Monthly]; 
        Test.startTest();
        //new BILL_BillingProcess().createBillingInvoice(app_Quarterly2Monthly);
        new BILL_ChangeBillingFrequency().changeBillingInvoice(app_Quarterly2Monthly,false,dateOfChange);   
        Test.stopTest();
    }

    @isTest static void nullBillingContract_Test1()
    {
        Map<String,ID> data      = generateData();
        Account testClient       = new Account(ID = data.get('clientID'));
        ID app_Monthly2Quarterly = data.get('app_Monthly2Quarterly');
        
        dateOfChange             = Date.newInstance(2017,04,17);
        delete[SELECT ID FROM Billing_Contract__c WHERE Application__c=:app_Monthly2Quarterly]; 
        Test.startTest();
        //new BILL_BillingProcess().createBillingInvoice(app_Monthly2Quarterly);
        /*Application__c app = new Application__c(ID = app_Monthly2Quarterly);
        //app.Vendor_Invoice_Amount__c          = 5000;
        app.Equipment_Cost__c                 = 5000;
        update app;*/
        new BILL_ChangeBillingFrequency().changeBillingInvoice(app_Monthly2Quarterly,false,dateOfChange);   
        Test.stopTest();
    }

    /*****/

    @isTest static void withInterimFeeAmount_Test()
    {
        Map<String,ID> data                      = generateData();
        Account testClient                       = new Account(ID = data.get('clientID'));
        ID app_Quarterly2Monthly                 = data.get('app_Quarterly2Monthly');
        Application__c testingApp                = new Application__c(ID=app_Quarterly2Monthly);
        testingApp.Interim_Fee_Amount_Settle__c  = 12;
        testingApp.Original_Insurance_Value__c   = null;
        testingApp.Original_Insurance_ProRata__c = null;
        update testingApp;

        dateOfChange                             = Date.newInstance(2017,07,11); 
        new BILL_BillingProcess().createBillingInvoice(testingApp.Id);
        Test.startTest();        
        new BILL_ChangeBillingFrequency().changeBillingInvoice(testingApp.Id,false,dateOfChange);   
        Test.stopTest();
    }
	
    @isTest static void withInterimFeeAmount_Test1()
    {
        Map<String,ID> data                      = generateData();
        Account testClient                       = new Account(ID = data.get('clientID'));
        ID app_Monthly2Quarterly                 = data.get('app_Monthly2Quarterly');
        Application__c testingApp                = new Application__c(ID=app_Monthly2Quarterly);
        testingApp.Interim_Fee_Amount_Settle__c  = 12;
        testingApp.Original_Insurance_Value__c   = null;
        testingApp.Original_Insurance_ProRata__c = null;
        update testingApp;

        dateOfChange=Date.newInstance(2017,01,07);      
        Test.startTest();
        new BILL_BillingProcess().createBillingInvoice(testingApp.Id);
        new BILL_ChangeBillingFrequency().changeBillingInvoice(testingApp.Id,false,dateOfChange);   
        Test.stopTest();
    }

    @isTest static void coverTest()
    {
        Map<String,ID> data                      = generateData();
        Account testClient                       = new Account(ID = data.get('clientID'));
        ID app_Monthly2Quarterly                 = data.get('app_Monthly2Quarterly');
        Application__c testingApp                = new Application__c(ID=app_Monthly2Quarterly);
        testingApp.ATM_Reference_Costs__c        = 25;
        update testingApp;

        dateOfChange=Date.newInstance(2017,05,12);      
        Test.startTest();
        system.debug('test');
        new BILL_BillingProcess().createBillingInvoice(testingApp.Id);
        new BILL_ChangeBillingFrequency().changeBillingInvoice(testingApp.Id,false,dateOfChange);   
        Test.stopTest();
    }
    
    @isTest static void test2(){
    	
    	
        Date dateOfChange=Date.Today();
    	Id appID = 'a011o00001Ndi4r';
    	
    	new BILL_ChangeBillingFrequency().changeBillingInvoice(appID,false,dateOfChange);   
    	
    }    
}//end class