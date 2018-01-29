@isTest(SeeAllData=true)
public class test_settleContract {
    
    private static ID appID =  getTestAppID();

    public static testMethod void test_settleContract_2(){
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = '1 Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '50363033012';
        vendor.Email__c='';
        //vendor.BillingPostalCode='2685-092';
        insert vendor;     
        
        //New Account Client
        Account client = new Account();
        client.Name = '2 Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '500766630112';
        client.c2g__CODAInvoiceEmail__c= 'teste@email.pt';
      // client.BillingPostalCode='2685-092';
         client.c2g__CODATaxCalculationMethod__c = 'Gross';   
        insert client;
        Application__c appnew = new Application__c();
        appnew.AccClient__c = client.ID;
        appnew.Vendor__c = vendor.ID;
        appnew.Equipment_Cost__c = 2402.63;
        appnew.TermCalc__c = 12;
        appnew.Payment_Amount__c = 230;
        appnew.VAT_Tax__c = 23;
        //appnew.Delivery_Certificate_Signed__c=date.newInstance(2017,06,15);

        insert appnew;

        test.startTest();

        settleContract.validateContract(appnew.id);
        
        test.stopTest();
    }
    
    public static testMethod void test_settleContract_3(){
        
        application__c app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                            Equipment_Cost__c, Vendor_invoice_VAT__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                            Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                            ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                            Interest_Amount__c, Insurance_Special_Value__c, Insurance_Movement_value__c, Client_BBAN__c
                            from application__c where id= :appId ];        
        

        
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 6, 2);
        //app.Vendor_Invoice_Amount__c = 2402.63;
        app.Equipment_Cost__c = 2402.63;
        app.Payment_Freq__c = 'Monthly';
        app.Insurance_Special_Value__c = 9.31;
        app.Insurance_Movement_value__c = 11.01;
        app.TermCalc__c = 12;
        app.Client_BBAN__c = '004563904014640899590';
        app.ATM_Reference_Costs__c = 10;
        app.Paper_Contract__c  = true;
        app.eSignature_Contract__c  = true;
        app.Interim_Fee__c = true;
        app.Payment_Amount__c = 230;
        app.Vendor_Diluted_Doc_Fee__c = true;
        app.Invoice_Payment_Date__c = Date.newInstance(2016, 5, 4);
        app.Insurance_Pro_Rata_Checkbox__c =true;
        app.Insurance_Special_Value__c =50;
        app.Delivery_Certificate_Signed__c= Date.newInstance(2016, 4, 25);
        
        update app;
        
        
        test.startTest();
        
        settleContract.validateContract(appID);
        
        test.stopTest();
        
    }
    
  /* public static testMethod void test_settleContract_4(){
        
        application__c app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                            Equipment_Cost__c, Vendor_invoice_VAT__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                            Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                            ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                            Interest_Amount__c, Insurance_Special_Value__c, Insurance_Movement_value__c, Client_BBAN__c
                            from application__c where id= :appId ];        
        
        test.startTest();
        
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 6, 2);
        //app.Vendor_Invoice_Amount__c = 2402.63;
        app.Equipment_Cost__c = 2402.63;
        app.Insurance_Special_Value__c = 9.31;
        app.Insurance_Movement_value__c = 11.01;
        app.Client_BBAN__c = '004563904014640899590';
        app.Payment_Freq__c ='Monthly';
        app.TermCalc__c =36;
        app.Payment_Amount__c = 2500;
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 3, 20);
        
        update app;
        
        test.stopTest();
        
    }*/

    public static testMethod void tes_SettleContract4_2(){
        Application__c app = new Application__c();
        app.id= appId;
        app.Payment_Timing__c='Arreas';
        app.Insurance_Type__c = 'Special Risk';        
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 11, 20);
        app.TermCalc__c = 48;
        update app;
        
        settleContract.validateContract(appID);
        
    }
    
    /*public static testMethod void test_settleContract_5(){
        
        application__c app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                            Equipment_Cost__c, Vendor_invoice_VAT__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                            Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                            ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                            Interest_Amount__c, Insurance_Special_Value__c, Insurance_Movement_value__c, Client_BBAN__c
                            from application__c where id= :appId ];        
       
       	//insert app;
        
        test.startTest();
        
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 6, 2);
        //app.Vendor_Invoice_Amount__c = 2402.63;
        app.Equipment_Cost__c = 2402.63;
        app.Insurance_Special_Value__c = 9.31;
        app.Insurance_Movement_value__c = 11.01;
        app.Client_BBAN__c = '004563904014640899590';
        app.Payment_Freq__c ='Quarterly';
        app.Payment_Amount__c = 2500;
        app.TermCalc__c = 36;
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 3, 20);
        
        update app;
        
        settleContract.validateContract(appID);
        
    }*/


    public static testMethod void tes_SettleContract5_2(){
        Application__c app = new Application__c();
        app.id= appId;
        app.Payment_Timing__c='Arreas';
        app.Insurance_Type__c = 'Special Risk';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
        update app;
        
        settleContract.validateContract(appID); 
        
    }    
    
    @isTest
    public static void test_settleContract_6(){
        application__c app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                            Equipment_Cost__c, Vendor_invoice_VAT__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                            Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                            ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                            Interest_Amount__c, Insurance_Special_Value__c, Insurance_Movement_value__c, Client_BBAN__c
                            from application__c where id= :appId ];   
        
        
        Vendor_invoice__c vendorInvoice = new Vendor_Invoice__c(Due_date__c=Date.today(), Invoice_Total__c=1000,
                                                               Invoice_Date__c=date.today(), Vendor_Invoice_Number__c='QWERT',
                                                               Submitted__c = true, Application__c = appId, Account__c = app.vendor__C );
        insert vendorInvoice;

        test.startTest();
        
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
       // app.Vendor_Invoice_Amount__c = 2402.63;
        app.Equipment_Cost__c = 2402.63;
        app.Insurance_Special_Value__c = 9.31;
        app.Insurance_Movement_value__c = 11.01;
        app.Client_BBAN__c = '004563904014640899590';
        app.Payment_Freq__c ='Quarterly';
        app.Payment_Amount__c = 2500;
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 3, 20);
        
        
        update app;
        
        
        settleContract.validateContract(appID);
    }
    
    @isTest(SeeAllData = true)
    public static void test_settleContract_7(){
        application__c app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                            Equipment_Cost__c, Vendor_invoice_VAT__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                            Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                            ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                            Interest_Amount__c, Insurance_Special_Value__c, Insurance_Movement_value__c, Client_BBAN__c
                            from application__c where id= :appId ];   
        
        app.TermCalc__c = 36;
        update app;
        
        Vendor_invoice__c vendorInvoice = new Vendor_Invoice__c(Due_date__c=date.newInstance(2016, 11, 01), Invoice_Total__c=1000,
                                                               Invoice_Date__c=date.newInstance(2016, 08, 01), Vendor_Invoice_Number__c='QWERT',
                                                               Submitted__c = true, Application__c = appId, Account__c = app.vendor__C );
        insert vendorInvoice;
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAcc = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAcc.Name= '21111 - CLIENTES NACIONAIS TESTE';
        generalLedgerAcc.c2g__ReportingCode__c='211101';
        generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
        insert generalLedgerAcc;    
        ID glacc = generalLedgerAcc.id;
        
        c2g__codaTaxCode__c taxcode = new c2g__codaTaxCode__c();
        taxcode.Name = 'TAX';
        taxcode.c2g__Description__c='Vendes IVA 23% Teste';
        taxcode.c2g__GeneralLedgerAccount__c=glacc;
        insert taxcode;
        ID vatID = taxcode.id;
	
        Account client = [SELECT ID, NAME, c2g__CODAInputVATCode__c FROM ACCOUNT WHERE ID=:app.AccClient__c ];
        client.c2g__CODAInputVATCode__c = vatID;
        update client;
        
        Account vendor = [SELECT ID, NAME, c2g__CODAOutputVATCode__c FROM ACCOUNT WHERE ID=:app.Vendor__c ];
        vendor.c2g__CODAOutputVATCode__c = vatID;
        vendor.c2g__CODATaxCalculationMethod__c	= 'Gross';
        update vendor;
        
        app.Insurance_Type__c = 'Static Risk';
        app.Insurance_Value__c = 20;
        update app;
        
        test.startTest();  
        settleContract.validateContract(appID);
        Test.stopTest();
        
    } 

    public static testMethod void testGetVendorInputOutputVAT(){
        String PostalCode='1234-123';
        settleContract.GetVendorInputOutputVAT(PostalCode);
    }

    /*private static void setFinancialForceData()
    {
         User usr = [Select id from User where Id = :UserInfo.getUserId()];
     
         System.RunAs(usr)
         {
            Test.startTest();
            BILL_Util_Test.setFinancialForce();
            Test.stopTest();
         }
    }*/
  
    private static ID getTestAppID() {

         /*User usr = [Select id from User where Id = :UserInfo.getUserId()];
     
         System.RunAs(usr)
         {
            BILL_Util_Test.setFinancialForce();
         }*/


        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = '1 Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '5036303302';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        vendor.BillingPostalCode='1000-452';

        insert vendor;     
        
        //New Account Client
        Account client = new Account();
        client.Name = '2 Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '50076663012';
        client.BillingCity = 'Amora';
        client.BillingStreet = 'Rua lá de fora';
        client.BillingPostalCode = '2048-124';
        client.c2g__CODATaxCalculationMethod__c = 'Gross';
        insert client;

        ID glacc;
        c2g__codaGeneralLedgerAccount__c[] generalLedgerAccList = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c='2111'];
        if(generalLedgerAccList.size()==0){
            c2g__codaGeneralLedgerAccount__c generalLedgerAcc = new c2g__codaGeneralLedgerAccount__c();
            generalLedgerAcc.Name= '21111 - CLIENTES NACIONAIS';
            generalLedgerAcc.c2g__ReportingCode__c='2111';
            generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
            insert generalLedgerAcc; 
            glacc = generalLedgerAcc.id;   
        }else{
            glacc =generalLedgerAccList[0].Id;
        }
        
        ID glaccDefaultVendor;
        c2g__codaGeneralLedgerAccount__c[] generalLedgerAccVendorList = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c='311'];
        if(generalLedgerAccVendorList.size()==0){
            c2g__codaGeneralLedgerAccount__c generalLedgerAccVendor = new c2g__codaGeneralLedgerAccount__c();
            generalLedgerAccVendor.Name= '311 - MERCADORIAS';
            generalLedgerAccVendor.c2g__ReportingCode__c='311';
            generalLedgerAccVendor.c2g__Type__c = 'Balance Sheet';
            insert generalLedgerAccVendor; 
            glaccDefaultVendor = generalLedgerAccVendor.id;   
        }else{
            glaccDefaultVendor = generalLedgerAccVendorList[0].Id;
        }
        
        ID glaccVendorPayableControl;
        c2g__codaGeneralLedgerAccount__c[] generalLedgerAccVendorPayableControlList = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c='22114'];
        if(generalLedgerAccVendorPayableControlList.size()==0){
            c2g__codaGeneralLedgerAccount__c generalLedgerAccVendorPayableControl = new c2g__codaGeneralLedgerAccount__c();
            generalLedgerAccVendorPayableControl.Name= '22114 - FORNECEDORES LEASING';
            generalLedgerAccVendorPayableControl.c2g__ReportingCode__c='22114';
            generalLedgerAccVendorPayableControl.c2g__Type__c = 'Balance Sheet';
            insert generalLedgerAccVendorPayableControl; 
            glaccVendorPayableControl = generalLedgerAccVendorPayableControl.id;  
        } else{
            glaccVendorPayableControl = generalLedgerAccVendorPayableControlList[0].id;
        }
        
		c2g__codaTaxCode__c[] taxcodeList = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name='VCONT23'];
        ID vatID;
        if(taxcodeList.size()==0){
        	c2g__codaTaxCode__c taxcode = new c2g__codaTaxCode__c();
        	taxcode.Name = 'VCONT23';
       	 	taxcode.c2g__Description__c='Vendes IVA 23%';
       	 	taxcode.c2g__GeneralLedgerAccount__c=glacc;
        	insert taxcode;
        	vatID = taxcode.id;
        }else{
            vatID = taxcodeList[0].Id;
        }

        //client.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        client.c2g__CODAInputVATCode__c = vatID;
        update client;
        
        vendor.c2g__CODAOutputVATCode__c = vatID;
        vendor.c2g__CODADefaultExpenseAccount__c = glaccDefaultVendor;
        vendor.c2g__CODAAccountsPayableControl__c = glaccVendorPayableControl;
        //vendor.c2g__CODAAccountsReceivableControl__c = glacc;
        update vendor;
        
        // new contact client
        contact con = new contact();
        con.AccountId=client.id;
        con.Email='teste@g.com';
        con.FirstName='a';
        con.LastName='b';
        insert con;
        // new contact vendor
        contact convendor = new contact();
        convendor.accountId=vendor.id;
        convendor.Email='teste2@g.com';
        convendor.FirstName='c';
        convendor.LastName='d';
        insert convendor;
        
        //new Application
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        app.Client_Signer_1__c=con.id;
        app.Vendor_Primary__c=convendor.id;
        app.VAT_Tax__c = 23;
        app.Delivery_Certificate_Signed__c=date.newInstance(2017,06,15);


        
        insert app;
        
        return app.ID;
    }
    
    
}