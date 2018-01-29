@isTest
public class ClaimInsuranceViewController_Test {
    
    public static testMethod void validateClaimInsuranceViewController(){
        
        RecordType rt = [Select Id,Name from RecordType Where RecordType.Name = 'Account Customer - Channel'];
        
        //Insert Account
        Account objAcc = new Account();
        objAcc.Name = 'Test Name';
        objAcc.NIF__c = 'Test NIF';
        objAcc.Type = 'Customer - Channel';
        objAcc.RecordTypeId = rt.Id;
        insert objAcc;
        
        //Insert Contact Object
        Contact objCon = new Contact();
        objCon.LastName = 'Test';
        objCon.AccountId = objAcc.Id;
        insert objCon;
        
        //Insert Application Object
        Application__c objApp = new Application__c();
        objApp.AccClient__c = objAcc.Id;
        insert objApp;
      
        //Insert Billing Contract        
        Billing_Contract__c objBillingContract = new Billing_Contract__c();
        objBillingContract.Name = 'Test';
        objBillingContract.Account__c = objAcc.Id;
        objBillingContract.Application__c = objApp.Id;
        insert objBillingContract;
        system.assertEquals(true,objBillingContract.id!=null);      
        
        //Insert Claim Insurance
        Claim_Insurance__c objClaimInsurance = new Claim_Insurance__c();        
        objClaimInsurance.Contact__c = objCon.Id; 
        objClaimInsurance.Billing_Contract__c =  objBillingContract.Id;
        insert objClaimInsurance;
        
        //Insert Equipment Object
        Equipment__c objEquipment = new Equipment__c();
        //objEquipment.Name = 'Test';
        //objEquipment.Claim_Insurance__c = objClaimInsurance.Id;
        objEquipment.Application__c = objApp.Id;
        insert objEquipment;
        
        Damaged_Equipment__c objDamagedEquipment = new Damaged_Equipment__c();
        objDamagedEquipment.Equipment__c = objEquipment.Id;
        objDamagedEquipment.Claim_Insurance__c = objClaimInsurance.Id;
        insert objDamagedEquipment;
        //Insert Attachments
        Attachment objAttach= new Attachment();
        objAttach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        objAttach.body=bodyBlob;
        objAttach.ParentId =objClaimInsurance.Id; 
        insert objAttach;          
        
        apexpages.currentpage().getparameters().put('id' , objClaimInsurance.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(objClaimInsurance);
        ClaimInsuranceViewController objClaimInsuranceViewController = new ClaimInsuranceViewController(sc);
        //ClaimInsuranceViewController.EquipmentWrapper objEquipmentWrapper = new ClaimInsuranceViewController.EquipmentWrapper(objEquipment,true);
        objClaimInsuranceViewController.getClaimType();
        objClaimInsuranceViewController.savePDF();
        
    } 
}