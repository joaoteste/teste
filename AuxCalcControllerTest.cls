//ALTERACAO - 21/03/17 - reformulacao da classe de testes (BP)

@isTest (SeeAllData = true)
public class AuxCalcControllerTest {

    private static Map<String, ID> generateData()
    {     
        Map<String, ID> dataMap = new Map<String,ID>();
        c2g__codaTaxRate__c taxRate = [Select c2g__Rate__c,c2g__TaxCode__c From c2g__codaTaxRate__c limit 1];
        Id taxID = [Select Id From c2g__codaTaxCode__c where id = :taxRate.c2g__TaxCode__c limit 1].ID;
        Decimal taxRateValue = taxRate.c2g__Rate__c/100;
        /******************************************************************************************************/
        /*										ACCOUNTS CREATION											  */
        /******************************************************************************************************/
        //New Account Vendor
        Account vendor 			  = new Account();
        vendor.Name 			  = 'Test Account Vendor'; 
        vendor.Type 			  = 'Channel Partner / Vendor';
        vendor.NIF__c 			  = '503630311';
        vendor.Diluted_Doc_Fee__c = true;
        vendor.c2g__CODAOutputVATCode__c = taxID;
        vendor.c2g__CODAInputVATCode__c = taxID;
        insert vendor;
        dataMap.put('vendorID', vendor.ID);
        
        //New Account Client
        Account client 					= new Account();
        client.Name 					= 'Test Account Client'; 
        client.Type 					= 'Customer - Channel';
        client.NIF__c 					= '504092090';
        client.Risk_Type__c 			= 'Very Low';
        client.c2g__CODAInvoiceEmail__c = 'test3@email.com';     
        client.c2g__CODAOutputVATCode__c = taxID;
        client.c2g__CODAInputVATCode__c = taxID;
        insert client;
        dataMap.put('clientID', client.ID);

        //New Contact
        Contact contact	= new contact();
        contact.LastName= 'Doe';
        contact.Email 	= 'test@email.com';
        contact.Role__c	= 'Binding Power';
        insert contact;
        dataMap.put('contactID', contact.ID);

        /******************************************************************************************************/
        /*											 TEST APPLICATION									      */
        /******************************************************************************************************/
        Application__c testApplication 					= new Application__c();
        testApplication.AccClient__c 					= client.ID;
        testApplication.Vendor__c 						= vendor.ID;        
        testApplication.Insurance_Type__c 				= 'Special Risk';
        testApplication.Insurance_Movement_value__c		= 5.5;
        testApplication.Issuing_Date_Invoice__c 		= Date.newInstance(2016, 11, 17);
        testApplication.Payment_Timing__c				= 'Advanced';  
        testApplication.Status__c						= 'Contract - Running';
        testApplication.Contract_Sent__c				= Date.newInstance(2016, 11, 15);
        testApplication.Contract_Signed__c  			= Date.newInstance(2016, 11, 15);
        testApplication.Delivery_Certificate_Sent__c	= Date.newInstance(2016, 11, 16);
        testApplication.Delivery_Certificate_Signed__c	= Date.newInstance(2016, 11, 16);
        testApplication.Invoice_Payment_Date__c 		= Date.newInstance(2016, 11, 17);
        testApplication.TermCalc__c 					= 12;
        testApplication.Vendor_Invoice_Amount__c 		= 2402.63;
        testApplication.Equipment_Cost__c 				= 2402.63;
        testApplication.VAT_Tax__c						= taxRateValue;
        testApplication.Insurance_Special_Value__c		= 9.31;
        testApplication.Client_BBAN__c 					= '004563904014640899590';
        testApplication.Payment_Freq__c 				= 'Monthly';
        testApplication.Payment_Amount__c 				= 200;
        testApplication.Generate_Billing__c				= true;
        testApplication.Annual_Interest_Rate__c			= 9.2;
        testApplication.Vendor_Diluted_Doc_Fee__c		= true;
        testApplication.ATM_Reference__c				= true;
        testApplication.Interim_Fee__c					= false;
        testApplication.ATM_Reference_Costs__c			= 10;
        testApplication.eSignature_Contract__c			= true;
        testApplication.Paper_Contract__c				= false;
        testApplication.Insurance_Pro_Rata_Checkbox__c	= true;
        testApplication.Client_Signer_1__c 				= contact.id;
	    testApplication.Issuing_Date_Invoice__c 		= Date.newInstance(2016, 6, 1);   
	    testApplication.Aux_Payment_Amount__c 			= 50; 
	    testApplication.Aux_Equipment_Cost__c 			= 3000;
		testApplication.Aux_Rate_Factor__c 				= 2.3;
	    testApplication.Aux_Discount__c 				= null;
        insert testApplication;
        dataMap.put('testApplicationID', testApplication.ID);
        return dataMap;
    }
    /******************************************************************************************************/
    /*											BEHAVIOUR TESTS										      */
    /******************************************************************************************************/
	@isTest
	public static void coverCalculate1(){	
        Map<String,ID> data0=generateData();
        ID testApplicationID= data0.get('testApplicationID');
        Application__c testApplication= new Application__c(ID=testApplicationID);
		Test.starttest();	
        //for(Integer j = 0; j < appListTest1.size();j++ ){	
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void coverCalculate2(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		Test.starttest();
        //for(Integer j = 0; j < appListTest2.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '');
		    ref.getParameters().put('auxec', '1000');
		    ref.getParameters().put('auxpa', '200');
		    ref.getParameters().put('reqdiscount', '');  
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void coverCalculate3(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		Test.starttest();
        //for(Integer j = 0; j < appListTest2.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '1.0');
		    ref.getParameters().put('auxec', '');
		    ref.getParameters().put('auxpa', '200');
		    ref.getParameters().put('reqdiscount', '');  
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}


	@isTest
	public static void coverCalculate4(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		Test.starttest();
        //for(Integer j = 0; j < appListTest4.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '');
		    ref.getParameters().put('auxec', '');
		    ref.getParameters().put('auxpa', '');
	    	ref.getParameters().put('reqdiscount', '1.0');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();	
		//}
		Test.stopTest();
}

	@isTest
	public static void CalculatePaymentAmount_Quarterly_App(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);
		testApplication.Payment_Freq__c='Quarterly'	;
        Test.starttest();
        update testApplication;
        //for(Integer j = 0; j < appListTest5	.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');
		    ref.getParameters().put('reqdiscount', '');    
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();	
		//}
		Test.stopTest();
	}


	@isTest
	public static void CalculatePaymentAmount_Vendorfee_notpayfee_12months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);

		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='12';
		Test.starttest();
		update testApplication;		
		update vendor;
		update client;
        //for(Integer j = 0; j < appListTest6.size();j++ ){	
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();

	}

	@isTest
	public static void CalculatePaymentAmount_notVendorfee_payfee_12months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='12';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

		@isTest
	public static void CalculatePaymentAmount_Vendorfee_notpayfee_24months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);

		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='24';
		Test.starttest();
		update testApplication;		
		update vendor;
		update client;
        //for(Integer j = 0; j < appListTest6.size();j++ ){	
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();

	}

	@isTest
	public static void CalculatePaymentAmount_notVendorfee_payfee_24months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='24';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

		@isTest
	public static void CalculatePaymentAmount_Vendorfee_notpayfee_36months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);

		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='36';
		Test.starttest();
		update testApplication;		
		update vendor;
		update client;
        //for(Integer j = 0; j < appListTest6.size();j++ ){	
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();

	}

	@isTest
	public static void CalculatePaymentAmount_notVendorfee_payfee_36months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='36';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

		public static void CalculatePaymentAmount_Vendorfee_notpayfee_48months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);

		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='48';
		Test.starttest();
		update testApplication;		
		update vendor;
		update client;
        //for(Integer j = 0; j < appListTest6.size();j++ ){	
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();

	}

	@isTest
	public static void CalculatePaymentAmount_notVendorfee_payfee_48months(){
			Map<String,ID> data0=generateData();
			ID testApplicationID= data0.get('testApplicationID');
			Application__c testApplication= new Application__c(ID=testApplicationID);	
			ID vendorID= data0.get('vendorID');
			Account vendor= new Account(ID=vendorID);
			ID clientID= data0.get('clientID');
			Account client= new Account(ID=clientID);
			client.Risk_Type__c='Middle';
			vendor.Diluted_Doc_Fee__c=false;
			testApplication.Payment_Freq__c='Monthly';
			testApplication.Term__c='48';
			Test.starttest();
				update testApplication;		
				update vendor;
				update client;
	        //for(Integer j = 0; j < appListTest7.size();j++ ){
				PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
			    Test.setCurrentPage(ref);
			    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
			    ref.getParameters().put('auxfactor', '60');
			    ref.getParameters().put('auxec', '100');
			    ref.getParameters().put('auxpa', '');  
			    ref.getParameters().put('reqdiscount', '');
			    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
			    AuxCalcController cc = new AuxCalcController(StandardController);
				cc.Calculate();
			//}
		Test.stopTest();
	}

		public static void CalculatePaymentAmount_Vendorfee_notpayfee_60months(){
			Map<String,ID> data0=generateData();
			ID testApplicationID= data0.get('testApplicationID');
			Application__c testApplication= new Application__c(ID=testApplicationID);	
			ID vendorID= data0.get('vendorID');
			Account vendor= new Account(ID=vendorID);
			ID clientID= data0.get('clientID');
			Account client= new Account(ID=clientID);

			client.Risk_Type__c='Middle';
			vendor.Diluted_Doc_Fee__c=true;
			testApplication.Payment_Freq__c='Quarterly';
			testApplication.Term__c='60';
			Test.starttest();
				update testApplication;		
				update vendor;
				update client;
	        //for(Integer j = 0; j < appListTest6.size();j++ ){	
				PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
			    Test.setCurrentPage(ref);
			    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
			    ref.getParameters().put('auxfactor', '60');
			    ref.getParameters().put('auxec', '100');
			    ref.getParameters().put('auxpa', '');
			    ref.getParameters().put('reqdiscount', '');
			    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
			    AuxCalcController cc = new AuxCalcController(StandardController);
				cc.Calculate();
			//}
			Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notVendorfee_payfee_60months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='60';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

		public static void CalculatePaymentAmount_Vendorfee_notpayfee_72months(){
			Map<String,ID> data0=generateData();
			ID testApplicationID= data0.get('testApplicationID');
			Application__c testApplication= new Application__c(ID=testApplicationID);	
			ID vendorID= data0.get('vendorID');
			Account vendor= new Account(ID=vendorID);
			ID clientID= data0.get('clientID');
			Account client= new Account(ID=clientID);

			client.Risk_Type__c='Middle';
			vendor.Diluted_Doc_Fee__c=true;
			testApplication.Payment_Freq__c='Quarterly';
			testApplication.Term__c='72';
			Test.starttest();
				update testApplication;		
				update vendor;
				update client;
        //for(Integer j = 0; j < appListTest6.size();j++ ){	
				PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
			    Test.setCurrentPage(ref);
			    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
			    ref.getParameters().put('auxfactor', '60');
			    ref.getParameters().put('auxec', '100');
			    ref.getParameters().put('auxpa', '');
			    ref.getParameters().put('reqdiscount', '');
			    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
			    AuxCalcController cc = new AuxCalcController(StandardController);
				cc.Calculate();
		//}
		Test.stopTest();

	}

	@isTest
	public static void CalculatePaymentAmount_notVendorfee_payfee_72months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='72';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

		public static void CalculatePaymentAmount_notpayfee_12months(){
			Map<String,ID> data0=generateData();
			ID testApplicationID= data0.get('testApplicationID');
			Application__c testApplication= new Application__c(ID=testApplicationID);	
			ID vendorID= data0.get('vendorID');
			Account vendor= new Account(ID=vendorID);
			ID clientID= data0.get('clientID');
			Account client= new Account(ID=clientID);

			client.Risk_Type__c='Middle';
			vendor.Diluted_Doc_Fee__c=true;
			testApplication.Payment_Freq__c='Quarterly';
			testApplication.Term__c='12';
			Test.starttest();
				update testApplication;		
				update vendor;
				update client;
        //for(Integer j = 0; j < appListTest6.size();j++ ){	
				PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
			    Test.setCurrentPage(ref);
			    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
			    ref.getParameters().put('auxfactor', '60');
			    ref.getParameters().put('auxec', '100');
			    ref.getParameters().put('auxpa', '');
			    ref.getParameters().put('reqdiscount', '');
			    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
			    AuxCalcController cc = new AuxCalcController(StandardController);
				cc.Calculate();
		//}
		Test.stopTest();

	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_24months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='24';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_36months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='36';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

		@isTest
	public static void CalculatePaymentAmount_notpayfee_48months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='48';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_60months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='60';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_72months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='72';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_notfee_12months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='12';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_notfee_24months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='24';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_notfee_36months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='36';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_notfee_48months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='48';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_notfee_60months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='60';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_notpayfee_notfee_72months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=false;
		testApplication.Payment_Freq__c='Quarterly';
		testApplication.Term__c='72';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_12months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='12';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_24months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='24';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_36months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='36';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_48months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='48';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_60months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='60';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_72months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Middle';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='72';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

		@isTest
	public static void CalculatePaymentAmount_payfee_fee_Low_12months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Low';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='12';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_Low_24months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Low';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='24';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_Low_36months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Low';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='36';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_Low_48months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Low';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='48';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_Low_60months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Low';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='60';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}

	@isTest
	public static void CalculatePaymentAmount_payfee_fee_Low_72months(){
		Map<String,ID> data0=generateData();
		ID testApplicationID= data0.get('testApplicationID');
		Application__c testApplication= new Application__c(ID=testApplicationID);	
		ID vendorID= data0.get('vendorID');
		Account vendor= new Account(ID=vendorID);
		ID clientID= data0.get('clientID');
		Account client= new Account(ID=clientID);
		client.Risk_Type__c='Low';
		vendor.Diluted_Doc_Fee__c=true;
		testApplication.Payment_Freq__c='Monthly';
		testApplication.Term__c='72';
		Test.starttest();
			update testApplication;		
			update vendor;
			update client;
        //for(Integer j = 0; j < appListTest7.size();j++ ){
			PageReference ref = Page.AuxCalculations;                             //new PageReference('apex/AuxCalculations/' + appListTest1[j].Id);
		    Test.setCurrentPage(ref);
		    ApexPages.currentPage().getParameters().put('id', testApplication.Id);
		    ref.getParameters().put('auxfactor', '60');
		    ref.getParameters().put('auxec', '100');
		    ref.getParameters().put('auxpa', '');  
		    ref.getParameters().put('reqdiscount', '');
		    ApexPages.StandardController StandardController = new ApexPages.StandardController(testApplication);
		    AuxCalcController cc = new AuxCalcController(StandardController);
			cc.Calculate();
		//}
		Test.stopTest();
	}
}