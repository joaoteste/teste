/*************************************************************************
*Author      : Vinod
*Class       : ClaimInsuranceCalculatorController_Test
*Description   : Test class for ClaimInsuranceCalculatorController class
**************************************************************************/


@isTest
public class ClaimInsuranceCalculatorController_Test {
    static testMethod void validateClaimInsuranceCalculator() {
        
        RecordType rt = [Select Id,Name from RecordType Where RecordType.Name = 'Account Customer - Channel'];
        
        //Insert Account         
        Account objAcc = new Account();
        objAcc.Name = 'Test Name';
        objAcc.NIF__c = 'Test NIF';
        objAcc.Type = 'Customer - Channel';
        objAcc.RecordTypeId = rt.Id;
        insert objAcc;
        system.assertEquals(true,objAcc.id!=null);
        
        //Insert Application
        Application__c objApplication = new Application__c();
        objApplication.AccClient__c = objAcc.Id;
        objApplication.TermCalc__c = 20;
        objApplication.First_Beginning_Of_Term__c = System.today();
        objApplication.Payment_Amount__c = 10000;
        insert objApplication;
        
        //Insert Product2
        Product2 objProduct = new Product2(Name = 'Test', ProductCode = 'PT09');
        insert objProduct;
        
        //Insert Billing Contract
        Billing_Contract__c  objBillingContract = new Billing_Contract__c(Name = 'Test', Equipment_Cost__c = 110.00, Application__c = objApplication.Id);
        insert objBillingContract;
        
        //Insert Claim Insurance
        Claim_Insurance__c objClaimInsurance = new Claim_Insurance__c();
        objClaimInsurance.Billing_Contract__c = objBillingContract.Id;
        insert objClaimInsurance;
        
        //Insert Equipment
        Equipment__c objEquipment = new Equipment__c();
        objEquipment.Equipment_Quantity__c = 2;
        objEquipment.Equipment_Value__c = 50;
        insert objEquipment;
        
        //Insert Damaged Equipment
        Damaged_Equipment__c objDamagedEquipment = new Damaged_Equipment__c();
        objDamagedEquipment.Equipment__c = objEquipment.Id;
        objDamagedEquipment.Claim_Insurance__c = objClaimInsurance.Id;
        objDamagedEquipment.Quantity__c = 3;
        insert objDamagedEquipment;
        
        //Insert Billing Contract Line Item
        Billing_Contract_Line_Item__c objBillingContractLI = new Billing_Contract_Line_Item__c();
        objBillingContractLI.Line_Item_End_Date__c = System.today().addDays(10);
        objBillingContractLI.Line_Item_Start_Date__c = System.today();
        objBillingContractLI.Billing_Frequency__c = 'Monthly';
        objBillingContractLI.Product__c = objProduct.Id;
        objBillingContractLI.Invoiced__c = false;
        objBillingContractLI.Billing_Contract__c = objBillingContract.Id;
        insert objBillingContractLI;
        
        //Set current page id
        ApexPages.currentPage().getParameters().put('id',objClaimInsurance.Id);
        ClaimInsuranceCalculatorController objClaimInsuranceCalculator = new ClaimInsuranceCalculatorController(new ApexPages.StandardController(objClaimInsurance));
        objClaimInsuranceCalculator.saveCalculations();
    }
}