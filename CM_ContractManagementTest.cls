@isTest (seeAllData=true)
public class CM_ContractManagementTest
{
	public Billing_Contract__c bc;
	

	public static  Map<String, ID> setupCMS(){
		Map<String, ID> dataMap = new Map<String,ID>();
        Bill_ProductRegion billProdRegion = New Bill_ProductRegion();
        /******************************************************************************************************/
        /*                                      ACCOUNTS CREATION                                             */
        /******************************************************************************************************/
        
        c2g__codaTaxCode__c taxCode=[select id,name from c2g__codaTaxCode__c where name='CCONT23'];

        //New Account Vendor
        Account vendor  = new Account();
        vendor.Name     = 'Vendor'; 
        vendor.Type     = 'Channel Partner / Vendor';
        vendor.NIF__c   = '503630311';
        vendor.BillingPostalCode = '1234-123';
        vendor.BillingCountryCode = 'PT';
        vendor.c2g__CODAOutputVATCode__c = taxCode.ID;
        vendor.Tax_Zone__c='Mainland';
        insert vendor;
        dataMap.put('vendorID', vendor.ID);
        
        system.debug('taxCode '+ taxCode);

        system.debug('Vendor '+ Vendor);
        
        //New Account Client
        Account client           = new Account();
        client.Name              = 'Client'; 
        client.Type              = 'Customer - Channel';
        client.NIF__c            = '504092090';
        client.BillingPostalCode = '2180-213';
        client.BillingCountryCode = 'PT';
        client.Tax_Zone__c='Mainland';

        client.c2g__CODAInputVATCode__c=taxCode.id;  

        insert client;
        dataMap.put('clientID', client.ID);
        dataMap.put('taxcode', taxcode.id);
        
        //New Contact
        Contact contact = new contact();
        contact.LastName= 'Doe';
        contact.Email   = 'test@email.com';
        contact.Role__c = 'Binding Power';
        contact.AccountId = vendor.Id;
        insert contact;
        dataMap.put('contactID', contact.ID);

        // create Renting application
        Application__c app                    = new Application__c();
        app.AccClient__c                      = client.ID;
        app.Vendor__c                         = vendor.ID; 
		app.Vendor_Primary__c					= contact.ID;
        app.Insurance_Type__c                 = 'Special Risk';
        app.Insurance_Movement_value__c       = 5.5;
        app.Insurance_Special_Value__c        = 4.65;
        app.Issuing_Date_Invoice__c           = Date.newInstance(2016, 11, 17);
        app.Payment_Timing__c                 = 'Advanced';  
        app.Status__c                         = 'Contract - Running';
        app.Contract_Sent__c                  = Date.newInstance(2017, 03, 27);
        app.Contract_Signed__c                = Date.newInstance(2017, 03, 27);
        app.Delivery_Certificate_Sent__c      = Date.newInstance(2017, 03, 27);
        app.Delivery_Certificate_Signed__c    = Date.newInstance(2017, 03, 27);
        app.Invoice_Payment_Date__c           = Date.newInstance(2017, 03, 27);
        app.TermCalc__c                       = 36;
        app.Term__c                           = '36';
        app.Insurance_Special_Value__c        = 9.31;
        app.Insurance_Movement_value__c       = 11.01;
        app.Client_BBAN__c                    = '004563904014640899590';
        app.Payment_Freq__c                   = 'Quarterly';
        app.Payment_Amount__c                 = 250.36;
        app.Generate_Billing__c               = true;
        app.Annual_Interest_Rate__c           = 9.2;
        app.Vendor_Diluted_Doc_Fee__c         = true;
        app.ATM_Reference__c                  = false;
        app.Interim_Fee__c                    = false;
        app.ATM_Reference_Costs__c            = 0;
        app.eSignature_Contract__c            = true;
        app.Paper_Contract__c                 = false;
        app.Insurance_Pro_Rata_Checkbox__c    = false;
        app.VAT_Tax__c =0.23;
         //app.Vendor_Invoice_Amount__c = 5000;
        app.Equipment_Cost__c = 7975.96;
       // app.Vendor_Invoice_Amount__c = 5000;
       // app.Equipment_Cost__c = 5000;
        app.amortization_interest_rate__c = 8.6314;
        app.Output_Ins_Manager__c='Pick Insurance Type: Static Risk with Rate 2.55%; Special Risk with Rate 3.85%; Risk of Movement with Rate 5.30%;';
        app.Output_Rate_Manager__c='Pick Contract Term: 12: €884.42; 24: €453.27; 36: €316.58; 48: €244.22; 60: €200.00; 72: €null';
        insert app;
        
        dataMap.put('app', app.ID);


		
		list<id> applist= new List<Id>();
		applist.add(app.ID);

		Billing_Contract__c billContrat = New Billing_Contract__c(Name=app.Name, Account__c=client.ID, Account_Vendor__c=vendor.ID, Equipment_Cost__c=app.Equipment_Cost__c,
                                                               Contract_Start_Date__c= app.Beginning_of_Term__c, Billing_Date_Override__c=app.Beginning_of_Term__c, application__c=app.id  );

        insert billContrat; 
        List<Billing_Contract_Line_Item__c> listBCLI= New List<Billing_Contract_Line_Item__c> ();
        Billing_Contract_Line_Item__c bcli1=new Billing_Contract_Line_Item__c(Billing_Contract__c=billContrat.id, Billing_Frequency__c='Quarterly',
                                                                                     Line_Item_Start_Date__c=date.newInstance(2017,7,1), Line_Item_End_Date__c=(date.newInstance(2017,7,1)).AddDays(15), Active__c=true,
                                                                                     Sales_Price__c=app.Payment_Amount__c, Product__c=billProdRegion.getProduct('PT09', 'Mainland'), Quantity__c=1, invoiced__c=true,
                                                                                     application__c=app.Id, Product_Tax_Code__c = billProdRegion.getTaxCode('PT09', 'Mainland'), interest__c=10, principal__c=150);
        listBCLI.add(bcli1);
        Billing_Contract_Line_Item__c bcli2=new Billing_Contract_Line_Item__c(Billing_Contract__c=billContrat.id, Billing_Frequency__c='Quarterly',
                                                                                      Line_Item_Start_Date__c=date.newInstance(2017,10,1), Line_Item_End_Date__c=(date.newInstance(2017,10,1)).AddDays(15), Active__c=true,
                                                                                     Sales_Price__c=app.Payment_Amount__c, Product__c=billProdRegion.getProduct('PT09', 'Mainland'), Quantity__c=1, 
                                                                                     application__c=app.Id, Product_Tax_Code__c = billProdRegion.getTaxCode('PT09', 'Mainland'), interest__c=10, principal__c=150);
        listBCLI.add(bcli2);
        Billing_Contract_Line_Item__c bcli3=new Billing_Contract_Line_Item__c(Billing_Contract__c=billContrat.id, Billing_Frequency__c='Quarterly',
                                                                                     Line_Item_Start_Date__c= System.today(), Line_Item_End_Date__c=(date.newInstance(2018,1,1)).AddDays(15), Active__c=true,
                                                                                     Sales_Price__c=app.Payment_Amount__c, Product__c=billProdRegion.getProduct('PT09', 'Mainland'), Quantity__c=1, 
                                                                                     application__c=app.Id, Product_Tax_Code__c = billProdRegion.getTaxCode('PT09', 'Mainland'), interest__c=10, principal__c=150);
        listBCLI.add(bcli3);
        Billing_Contract_Line_Item__c bcli4=new Billing_Contract_Line_Item__c(Billing_Contract__c=billContrat.id, Billing_Frequency__c='Quarterly',
                                                                                     Line_Item_Start_Date__c=date.newInstance(2018,4,1), Line_Item_End_Date__c=(date.newInstance(2018,4,1)).AddDays(15), Active__c=true,
                                                                                     Sales_Price__c=app.Payment_Amount__c, Product__c=billProdRegion.getProduct('PT09', 'Mainland'), Quantity__c=1, 
                                                                                     application__c=app.Id, Product_Tax_Code__c = billProdRegion.getTaxCode('PT09', 'Mainland'), interest__c=10, principal__c=150);
        listBCLI.add(bcli4);
        insert listBCLI;
        dataMap.put('BCId',billContrat.id);

		UTIL_CancelAndCreateJournals.createJournalSettleContractAppList(applist);


		Billing_Contract__c billContract  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c from Billing_Contract__c where id= :billContrat.id];
		Bill_BillingProcess BILL= New Bill_BillingProcess ();
		
		BILL.createBillingInvoice(app.ID);
		Contract_management__c cmNewRec = New Contract_management__c(Billing_Contract__c=billContract.id,Account_Client__c=billContract.Account__c,	
			Account_Vendor__c=billContract.Account_Vendor__c,CMS_Status__c ='Open',  Hit_Date__c= (system.today()).addDays(7), Residual_Value__c = 15,
			Termination_Date__c=system.today(),  Offer_Notification_Contact__c= contact.ID, Residual_Value_Amount__c=15/100 * app.Equipment_Cost__c);		
			

		insert cmNewRec;
	
		dataMap.put('CMSId', cmNewRec.id);
		return dataMap;
	}

	

    @isTest
    static void testCheckEligibility_Sucess()
    {
        Map<String, ID> dataMap=setupCMS();
        CM_ContractManagement CM = New CM_ContractManagement();
        Map<String, String> result= New  Map<String, String>();

        Billing_Contract__c billContrat  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c,  Equipment_Cost__c  from Billing_Contract__c where id= :dataMap.get('BCId')];

        result= CM.checkEligibilityforET(billContrat);
        system.assertEquals( 'Success', result.get('Result'));
       
    }
    
    @isTest
    static void testCheckEligibility_Error()
    {
        Map<String, ID> dataMap=setupCMS();
        CM_ContractManagement CM = New CM_ContractManagement();
        Map<String, String> result= New  Map<String, String>();

        Billing_Contract__c billContrat  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c, Equipment_Cost__c from Billing_Contract__c where id= :dataMap.get('BCId')];
        
        Collection_Case__c colcase = New Collection_Case__c(Billing_Contract__c=billContrat.id, Status__c='Open', account__c= dataMap.get('clientID'));
        insert colcase;
    
        

        result= CM.checkEligibilityforET(billContrat);
        system.assertEquals( 'Error',result.get('Result'));
       
    }

	@isTest
	static void testEarlyTerminationSuccess()
	{
		Map<String, ID> dataMap=setupCMS();
		CM_ContractManagement CM = New CM_ContractManagement();
		Map<String, String> result= New  Map<String, String>();

		Billing_Contract__c billContrat  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c, Equipment_Cost__c from Billing_Contract__c where id= :dataMap.get('BCId')];

        result= CM.EarlyTermination(billContrat);
        system.assertEquals('Success',result.get('Result'));

        

	}
	@isTest
	static void testEarlyTerminationError()
	{
		Map<String, ID> dataMap=setupCMS();
		CM_ContractManagement CM = New CM_ContractManagement();
		Map<String, String> result= New  Map<String, String>();

		Billing_Contract__c billContrat  =  [select name from Billing_Contract__c where id= :dataMap.get('BCId')];
	        
        result= CM.EarlyTermination(billContrat);
        system.assertEquals('Error', result.get('Result'));
        


	}

	


	@isTest
	public static void testExpireAndSendAlertEmail(){
		Map<String, ID> dataMap=setupCMS();
		BOReport.CM_sendEmailTemplate('marta.silva@worldit.pt', 'Contract_Early_Termination', dataMap.get('contactID'), dataMap.get('CMSId'),  true);		

	}
	
    @isTest
	public static void testCM_ET_AcceptOffer(){
		Map<String, ID> dataMap=setupCMS();
		Test.startTest();
		BOReport.CM_ET_AcceptOffer( dataMap.get('CMSId'));	
		Test.stopTest();	

	}
	
	@isTest
    public static void testCloseCMSAndDoMatch(){
        Map<String, ID> dataMap=setupCMS();
        Contract_management__c CMS = [select id, billing_contract__r.application__r.vendor__r.BillingCountryCode, billing_contract__r.application__r.AccClient__c,Residual_Value_Amount__c,
         Advanced_Expired_Principals_Amount__c,  billing_contract__r.Application__c,billing_contract__r.Application__r.name, Account_Tax_Zone__c, total_amount__c from Contract_Management__c where id= :dataMap.get('CMSId')];
        CM_ContractManagement CM = New CM_ContractManagement();
        Test.startTest();
        CM.CloseCMSAndDoMatch( CMS);    
        Test.stopTest();    

    } 

    @isTest
    static void testEarlyTermination_buttonSucess()
    {
        Map<String, ID> dataMap=setupCMS();
        CM_ContractManagement CM = New CM_ContractManagement();
        List<String> result= New  List<String> ();

        Billing_Contract__c billContrat  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c, Equipment_Cost__c from Billing_Contract__c where id= :dataMap.get('BCId')];

        result= BoReport.CM_BillContract_EarlyTermination(billContrat);
        system.assertEquals('Success',result[0]);
    }

    @isTest
    static void testEarlyTermination_buttonErrorCollCase()
    {
        Map<String, ID> dataMap=setupCMS();
        CM_ContractManagement CM = New CM_ContractManagement();
        List<String> result= New  List<String> ();

        Billing_Contract__c billContrat  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c, Equipment_Cost__c from Billing_Contract__c where id= :dataMap.get('BCId')];
        Collection_Case__c colcase = New Collection_Case__c(Billing_Contract__c=billContrat.id, Status__c='Open', account__c= dataMap.get('clientID'));
        insert colcase;
    
        result= BoReport.CM_BillContract_EarlyTermination(billContrat);
        system.assertEquals('Error',result[0]);
  
    }

     @isTest
    static void testEarlyTermination_buttonErrorExcep()
    {
        Map<String, ID> dataMap=setupCMS();
        CM_ContractManagement CM = New CM_ContractManagement();
        List<String> result= New  List<String> ();

        Billing_Contract__c billContrat  = New Billing_Contract__c();
    
        result= BoReport.CM_BillContract_EarlyTermination(billContrat);
        system.assertEquals('Error',result[0]);
  
    }

    @isTest
    static void otherTestsforBOreport(){
         Map<String, ID> dataMap=setupCMS();
        BOReport.GetRentCalc( dataMap.get('app'), 25000);
        BOReport.ImportReceipt(dataMap.get('app'),dataMap.get('clientID'));
        BOReport.SettleContract( dataMap.get('app'));
      /*  Test.startTest();
        BOReport.FinalizedInvoiceExpress(testData.get('invoiceID'));
            
        c2g__codainvoice__c inv = [SELECT ID, c2g__ExternalId__c FROM c2g__codainvoice__c WHERE ID=:testData.get('invoiceID')];

        update inv;
            
        BOReport.FinalizedInvoiceExpress(testData.get('invoiceID'));
        Test.stopTest();*/
    }
}