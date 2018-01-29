@isTest (SeeAllData=True)
public class BILL_BillingRenewalTest{
    
//    @testSetup
    public static void billingRenewalSetupTest(){
        c2g__codaTaxCode__c codaTaxCode = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'VCONT23'];
        Account client = RentingApplication_Util_Test.createAccount('Manuel','Customer - Channel','333333333', codaTaxCode);
        Account vendor = RentingApplication_Util_Test.createAccount('Informatica','Channel Partner / Vendor','333333332', codaTaxCode);
        
//        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = RentingApplication_Util_Test.createGeneralLedgerAccount();
//        c2g__codaTaxCode__c codaTaxCode = RentingApplication_Util_Test.createCodaTaxCode(UTIL_PostCode.getRegionFromPostCode(client.BillingPostalCode),generalLedgerAccount);
        
        Product2 prod18 = RentingApplication_Util_Test.createProductRegion('Product18', 'PT18',codaTaxCode);
        Product2 prod19 = RentingApplication_Util_Test.createProductRegion('Product19', 'PT19',codaTaxCode);
        Product2 prod2 = RentingApplication_Util_Test.createProductRegion('Product2', 'PT02',codaTaxCode);
        Product2 prod3 = RentingApplication_Util_Test.createProductRegion('Product3', 'PT03',codaTaxCode);
        
    }
    
    public static Application__c createApplication(Date startDate){
        
        RentingApplication_Util_Test appTest = new RentingApplication_Util_Test();
        
        Account client = [Select Id From Account Where Name = 'Manuel' and  Type = 'Customer - Channel'];
        Account vendor = [Select Id From Account Where Name = 'Informatica' and  Type = 'Channel Partner / Vendor'];
        
        Application__c app = RentingApplication_Util_Test.createApplicationWithStartDate(client,vendor,startDate); //atribuir monthly frequency
        
        Date billdate;
        if (app.Invoice_Payment_Date__c < date.today()){
            billdate=date.today();
        }
        else{
            billdate=app.Invoice_Payment_Date__c;
        }
        
        
        //cria bill contract
        Billing_Contract__c billCont = New Billing_Contract__c(Name=app.Name, Account__c=client.Id, Account_Vendor__c=vendor.Id, 
                                                                Contract_Start_Date__c= app.Beginning_of_Term__c,
                                                               Billing_Date_Override__c=billdate, application__c=app.id  );
        //     System.debug('billCont: ' + billCont);
        insert billCont;
       
        return app;
    }
    
    
    //não deverá renovar! muito longe
    @isTest
    public static void test1(){
        billingRenewalSetupTest();
        
        Date startDate = Date.newInstance(2016, 12, 16);
        
        Application__c app = createApplication(startDate);
        System.debug('app ' + app);
        
        //Term predefinido = 36 
        Test.startTest();
        
        List<Application__c> app2 = [SELECT Id, End_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, AccClient__c, ATM_Reference__c, ATM_Reference_Costs__c, Chosen_Insurance_value__c, Beginning_of_Term__c , Invoice_Payment_Date__c, Interim_Fee_Amount__c, Insurance_Pro_Rata__c,eSignature_Contract_Fee__c, Paper_Contract_Fee__c, TermCalc__c 
                               FROM Application__c WHERE  Id = :app.Id];
        
        (new BILL_BillingRenewal()).billingRenewal(app2);
        Test.stopTest();
    }
    
    //nao deverá renovar. Só no mês seguinte
    @isTest
    public static void test2(){
    	billingRenewalSetupTest();
    	
        Date startDate = Date.newInstance(2014, 06, 30);
        //Term predefinido = 36 
        Application__c app = createApplication(startDate);
        
        Test.startTest();
        
        List<Application__c> app2 = [SELECT Id, End_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, AccClient__c, ATM_Reference__c, ATM_Reference_Costs__c, Chosen_Insurance_value__c, Beginning_of_Term__c , Invoice_Payment_Date__c, Interim_Fee_Amount__c, Insurance_Pro_Rata__c,eSignature_Contract_Fee__c, Paper_Contract_Fee__c, TermCalc__c 
                               FROM Application__c WHERE  Id = :app.Id];
        
        (new BILL_BillingRenewal()).billingRenewal(app2);
        Test.stopTest();    
    }
    
    //deverá renovar
    @isTest
    public static void test3(){
    	billingRenewalSetupTest();

        Date startDate = Date.newInstance(2014, 05, 30);
        //Term predefinido = 36 
        Application__c app = createApplication(startDate);
        
        Test.startTest();
        
        List<Application__c> app2 = [SELECT Id, End_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, AccClient__c, ATM_Reference__c, ATM_Reference_Costs__c, Chosen_Insurance_value__c, Beginning_of_Term__c , Invoice_Payment_Date__c, Interim_Fee_Amount__c, Insurance_Pro_Rata__c,eSignature_Contract_Fee__c, Paper_Contract_Fee__c, TermCalc__c 
                               FROM Application__c WHERE  Id = :app.Id];
        
        (new BILL_BillingRenewal()).billingRenewal(app2);
        Test.stopTest(); 
    }

    //deverá renovar
    @isTest
    public static void test4(){
    	billingRenewalSetupTest();
    	
        Date startDate = Date.newInstance(2014, 04, 30);
        //Term predefinido = 36 
        Application__c app = createApplication(startDate);
        
        Test.startTest();
        
        List<Application__c> app2 = [SELECT Id, End_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, AccClient__c, ATM_Reference__c, ATM_Reference_Costs__c, Chosen_Insurance_value__c, Beginning_of_Term__c , Invoice_Payment_Date__c, Interim_Fee_Amount__c, Insurance_Pro_Rata__c,eSignature_Contract_Fee__c, Paper_Contract_Fee__c, TermCalc__c 
                               FROM Application__c WHERE  Id = :app.Id];
        
        (new BILL_BillingRenewal()).billingRenewal(app2);
        Test.stopTest(); 
    }
    
    //deverá renovar apenas uma vez.
    @isTest
    public static void test5(){
    	billingRenewalSetupTest();
    	
        Date startDate = Date.newInstance(2014, 05, 30);
        //Term predefinido = 36 
        Application__c app = createApplication(startDate);
        Test.startTest();
        
        List<Application__c> app2 = [SELECT Id, End_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, AccClient__c, ATM_Reference__c, ATM_Reference_Costs__c, Chosen_Insurance_value__c, Beginning_of_Term__c , Invoice_Payment_Date__c, Interim_Fee_Amount__c, Insurance_Pro_Rata__c,eSignature_Contract_Fee__c, Paper_Contract_Fee__c, TermCalc__c 
                               FROM Application__c WHERE  Id = :app.Id];
        
       // BILL_BillingRenewal billRenewal = (new BILL_BillingRenewal());
        (new BILL_BillingRenewal()).billingRenewal(app2);
        (new BILL_BillingRenewal()).billingRenewal(app2);

        Test.stopTest(); 
    }
    
    //deverá renovar. Encontramos muito à frente do end of term
    @isTest
    public static void test6(){
    	billingRenewalSetupTest();
    	
        Date startDate = Date.newInstance(2010, 05, 30);
        //Term predefinido = 36 
        Application__c app = createApplication(startDate);
        
        Test.startTest();
        
        List<Application__c> app2 = [SELECT Id, End_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, AccClient__c, ATM_Reference__c, ATM_Reference_Costs__c, Chosen_Insurance_value__c, Beginning_of_Term__c , Invoice_Payment_Date__c, Interim_Fee_Amount__c, Insurance_Pro_Rata__c,eSignature_Contract_Fee__c, Paper_Contract_Fee__c, TermCalc__c 
                               FROM Application__c WHERE  Id = :app.Id];
        
        (new BILL_BillingRenewal()).billingRenewal(app2);
        Test.stopTest(); 
    }
    
    //deverá renovar. Igual ao teste 5 mas montlhy
    @isTest
    public static void test7(){
    	billingRenewalSetupTest();
    	
        Date startDate = Date.newInstance(2010, 05, 30);
        //Term predefinido = 36 
        Application__c app = createApplication(startDate);
       
        app.Payment_Freq__c = 'Monthly';
        update app;
        
        Test.startTest();
        
        List<Application__c> app2 = [SELECT Id, End_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, AccClient__c, ATM_Reference__c, ATM_Reference_Costs__c, Chosen_Insurance_value__c, Beginning_of_Term__c , Invoice_Payment_Date__c, Interim_Fee_Amount__c, Insurance_Pro_Rata__c,eSignature_Contract_Fee__c, Paper_Contract_Fee__c, TermCalc__c 
                               FROM Application__c WHERE  Id = :app.Id];
         
        (new BILL_BillingRenewal()).billingRenewal(app2);
        Test.stopTest(); 
    }
}