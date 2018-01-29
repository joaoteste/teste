//Criacao - 21/02/17 - (BP)
//@Apex Notation:
// Test class of ApplicationTrigger
@isTest(SeeAllData=true)
public class TestApplicationTrigger {
    
    /****************************************************************************************************************************************/
    /*															GENERATE DATA																*/
    /****************************************************************************************************************************************/
    
    @isTest static Map<String,ID> generateData()
    {
        Map <String,ID> data= new Map<String,ID>();
        
        Account testVendor=new Account();
        testVendor.Type	  ='Channel Partner / Vendor';
        testVendor.name	  ='testVendor';
        testVendor.NIF__c ='999999999';
        insert testVendor;
        data.put('VendorId', testVendor.Id);
        
        System.assertNotEquals(null,testVendor.Id,'TestApplicationTrigger --> Não inseriu o vendor...');
		        
        Account testClient=new Account();
        testClient.Type	  ='Customer - Channel';
        testClient.name	  ='testClient';
        testClient.NIF__c ='111112222';
        testClient.Account_Status__c='Green';
        testClient.Country_Code__c = 'PT50';
        insert testClient;
        data.put('ClientId', testClient.Id);
        
        Contact testContact= new Contact();
        testContact.LastName='testContact';
        testContact.Email='teste@exemplo.com';
        insert testContact;
        data.put('ContactId', testContact.Id);

        System.assertNotEquals(null,testClient.Id,'TestApplicationTrigger --> Não inseriu o vendor...');
        
        Application__c testApplication				= new Application__c();
        testApplication.Vendor__c					= testVendor.Id;
        testApplication.AccClient__c				= testClient.Id;
        testApplication.Status__c					= 'Application - Approved';
        testApplication.Term__c						= '12';
        testApplication.TermCalc__c					= 12;
        testApplication.Invoice_Payment_Date__c 	= Date.newInstance(2017, 02, 01);
        testApplication.Payment_Timing__c			= 'Advanced';
        testApplication.Payment_Freq__c				= 'Monthly';
        testApplication.Payment_Amount__c			= 120;
        testApplication.Equipment_Cost__c			= 2000;
        testApplication.Insurance_Type__c			= 'Own Insurance';
        testApplication.Client_BBAN__c				= '000000000000000000000';
        testApplication.Annual_Interest_Rate__c 	= 7.42;
        testApplication.Insurance_Special_Value__c  = 1;
        testApplication.Insurance_Movement_value__c = 2; 
        testApplication.Insurance_Value__c 			= 5;
		insert testApplication;
        data.put('ApplicationId', testApplication.Id);
        
        System.assertNotEquals(null, testApplication.id,'TestApplicationTrigger --> Não inseriu a Application...');
       
        return data;
    }// end generateData method
    
    /****************************************************************************************************************************************/
    /*															BEHAVIOUR TESTS																*/
    /****************************************************************************************************************************************/
    @isTest static void TestDeleteBillingLineItems()
    {        
        Map<String,ID> data=generateData(); 
        Test.startTest();  
        Application__c testApplication= [SELECT Insurance_Type__c FROM Application__c where id=:data.get('ApplicationId')];
        testApplication.Insurance_Type__c='Static Risk';
        update testApplication;
        //BillingProcess.Create_Billing_Invoice(testApplication.Id);
        
        List<Billing_Contract_Line_Item__c> currentBCLIS0=[SELECT ID FROM Billing_Contract_Line_Item__c WHERE Application__c=:data.get('ApplicationId')];
        
        //System.assertEquals(24, currentBCLIS0.size(), 'TestApplicationTrigger --> Os BCLIS nao foram criados como desejado...');
                    
        testApplication.Insurance_Type__c='Own Insurance';       
        update testApplication;
        
        Test.stopTest();
    }//end TestDeleteBillingLineItems method
    
    @isTest static void TestAddInsuranceBclis()
    {       
        Map<String,ID> data=generateData();
        Test.startTest();   
        //BillingProcess.Create_Billing_Invoice(data.get('ApplicationId'));
        
        List<Billing_Contract_Line_Item__c> currentBCLIS0=[SELECT ID FROM Billing_Contract_Line_Item__c WHERE Application__c=:data.get('ApplicationId')];
        
        //System.assertEquals(12, currentBCLIS0.size(), 'TestApplicationTrigger --> Os BCLIS nao foram criados como desejado...');
           
        Application__c testApplication=[SELECT ID,Insurance_Type__c from Application__c WHERE id=:data.get('ApplicationId')]; 
        System.debug('testApplication.Insurance_Type__c:'+testApplication.Insurance_Type__c);
        testApplication.Insurance_Type__c='Static Risk';        
        update testApplication;
        Application__c testApplication1=[SELECT ID,Insurance_Type__c from Application__c WHERE id=:testApplication.Id]; 
        System.debug('testApplication.Insurance_Type__c:'+testApplication1.Insurance_Type__c);
        
        Test.stopTest();
    }// end TestAddInsuranceBclis method
    
	@isTest static void TestUpdateIBAN()
    {        
        Map<String,ID> data=generateData();
        Test.startTest();      
        Application__c testApplication=[SELECT ID,Client_BBAN__c,Client_Country_Code__c from Application__c WHERE id=:data.get('ApplicationId')];

        testApplication.Client_BBAN__c='003503730000539151280';        
        update testApplication;
        
        String actualIban=([select c2g__CODABankIBANNumber__c from Account where id =: data.get('ClientId')]).c2g__CODABankIBANNumber__c;
        System.assertEquals('PT50003503730000539151280', actualIban, 'TestApplicationTrigger --> O Iban não foi actualizado correctamente...');
        Test.stopTest();
    }// end TestUpdateIBAN method
    
    @isTest static void TestUpdateCreditLine()
    {	       
        Map<String,ID> data=generateData(); 
        Test.startTest();       
        Application__c testApplication=[SELECT ID,Status__c from Application__c WHERE id=:data.get('ApplicationId')]; 
       	testApplication.Status__c = 'Contract - Running';        
        update testApplication;
        Test.stopTest();
    }// end TestUpdateCreditLine method
    
    @isTest static void TestTrigger_APP_BC_Contract_Inactive()
    {         
        Map<String,ID> data=generateData(); 
        Test.startTest();   
        //BillingProcess.Create_Billing_Invoice(data.get('ApplicationId'));
        
        List<Billing_Contract_Line_Item__c> currentBCLIS0=[SELECT ID FROM Billing_Contract_Line_Item__c WHERE Application__c=:data.get('ApplicationId')];
        
        //System.assertEquals(12, currentBCLIS0.size(), 'TestApplicationTrigger --> Os BCLIS nao foram criados como desejado...');
        
        Application__c testApplication=[SELECT ID,Status__c from Application__c WHERE id=:data.get('ApplicationId')]; 
        testApplication.Status__c= 'Contract - Lawsuit';
        update testApplication;
        List<Billing_Contract__c> listBcToUpdate = [SELECT BC_Contract_Inactive__c FROM Billing_Contract__c WHERE id=: testApplication.Id Limit 1];
        
        if(listBcToUpdate.size()>0)
            System.assertEquals(true,listBcToUpdate[0].BC_Contract_Inactive__c , 'TestApplicationTrigger --> O Billing Contract não foi desactivado correctamente...');
        Test.stopTest();             
    }// end TestTrigger_APP_BC_Contract_Inactive method
	    
    @isTest static void TestCalcAnnualInterestRate()
    {
        Map<String,ID> data=generateData(); 
        Test.startTest();       
        Application__c testApplication=[SELECT ID,Equipment_Cost__c,TermCalc__c,Payment_Amount__c,Annual_Interest_Rate__c from Application__c WHERE id=:data.get('ApplicationId')]; 
        Decimal oldAnnualInterest=testApplication.Annual_Interest_Rate__c;
        testApplication.Equipment_Cost__c=3000;
        testApplication.Payment_Amount__c=95;
        testApplication.TermCalc__c=24;
        update testApplication;
        
        Decimal newAnnualInterest=[SELECT Annual_Interest_Rate__c FROM Application__c WHERE id=:testApplication.Id].Annual_Interest_Rate__c;
        System.assertNotEquals(oldAnnualInterest, newAnnualInterest, 'TestApplicationTrigger --> O Annual Interest Rate não foi actualizado correctamente...'); 
        Test.stopTest();
    }//end TestCalcAnnualInterestRate method
       
   /* @isTest static void TestCandor_Trigger_APP_ACC_Signer1email_to_invoiceEmail()
    {
        Map<String,ID> data=generateData(); 
        Test.startTest();       
        Application__c testApplication=[SELECT ID,Client_Signer_1__c from Application__c WHERE id=:data.get('ApplicationId')]; 
        testApplication.Client_Signer_1__c=data.get('ContactId');	
        update testApplication;
        Account client=[SELECT ID,c2g__CODAInvoiceEmail__c from Account WHERE id=:data.get('ClientId')]; 
        System.assertEquals('teste@exemplo.com', client.c2g__CODAInvoiceEmail__c, 'TestApplicationTrigger --> Não fez update na Account correctamente...');
        Test.stopTest();        
    }//end TestCandor_Trigger_APP_ACC_Signer1email_to_invoiceEmail method*/
   
     @isTest static void TestTranslate()
     {
         Map<String,ID> data=generateData(); 
         Test.startTest();       
         Application__c testApplication=[SELECT ID,status__c,Translated_Status__c from Application__c WHERE id=:data.get('ApplicationId')];
         testApplication.Status__c= 'Application - Approved';
         update testApplication;         
         
         Test.stopTest();  
     }// end TestTranslate method
    
    @isTest static void TestChangeInsuranceBCLIS()
     {
         Map<String,ID> data=generateData(); 
         Test.startTest();       
         Application__c testApplication=[SELECT ID,Insurance_Type__c from Application__c WHERE id=:data.get('ApplicationId')];
         testApplication.Insurance_Type__c= 'Static Risk';
         update testApplication;
         Application__c testApplication1=[SELECT ID,Insurance_Type__c from Application__c WHERE id=:testApplication.Id];
         testApplication1.Insurance_Type__c= 'Special Risk';
         update testApplication;
 
         Test.stopTest();  
     }// end TestChangeInsuranceBCLIS method
}