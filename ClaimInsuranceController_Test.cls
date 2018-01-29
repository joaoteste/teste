@isTest
public class ClaimInsuranceController_Test {

    public static testMethod void validateClaimeInsurance(){
        
        RecordType rt = [Select Id,Name from RecordType Where RecordType.Name = 'Account Customer - Channel'];
        
        //Insert Account Object        
        Account objAcc = new Account();
        objAcc.Name = 'Test Name';
        objAcc.NIF__c = 'Test NIF';
        objAcc.Type = 'Customer - Channel';
        objAcc.RecordTypeId = rt.Id;
        insert objAcc;
        system.assertEquals(true,objAcc.id!=null);
        
        //Insert Contact Object
        Contact objCon = new Contact();
        objCon.LastName = 'Test';
        objCon.AccountId = objAcc.Id;
        insert objCon;
        system.assertEquals(true,objCon.id!=null);
        
        //Insert Application Object
        Application__c objApp = new Application__c();
        objApp.AccClient__c = objAcc.Id;
        insert objApp;
        
        //Insert Billing Contract
        Billing_Contract__c  objBillingContract = new Billing_Contract__c();
        objBillingContract.Name = 'Test';   
        objBillingContract.Business_Type__c = 'Net New';
        objBillingContract.Account__c = objAcc.Id;
        objBillingContract.Application__c = objApp.Id;
        
        insert objBillingContract;
        system.assertEquals(true,objBillingContract.id!=null);
        
        //Insert Claim Insurance
        Claim_Insurance__c objClaimInsurance = new Claim_Insurance__c();
        //objClaimInsurance.Hora__c == 06:32;
        objClaimInsurance.Contact__c = objCon.Id;
        insert objClaimInsurance;
        
        //Insert Equipment Object
        Equipment__c objEquipment = new Equipment__c();
        //objEquipment.Claim_Insurance__c = objClaimInsurance.Id;
        objEquipment.Application__c = objApp.Id;
        insert objEquipment;
        
        List<Attachment> attachmentsList = new List<Attachment>();
        //Insert Attachments
        Attachment objAttach= new Attachment();
        objAttach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        objAttach.body = bodyBlob;
        attachmentsList.add(objAttach);
        //insert objAttach;               
        
        
        Apexpages.currentpage().getparameters().put('id' , objBillingContract.Id);
        ClaimInsuranceController objClaimInsuranceStandardController = new ClaimInsuranceController(new ApexPages.StandardController(objClaimInsurance));
        ClaimInsuranceController objClaimInsuranceController = new ClaimInsuranceController();
        objClaimInsuranceController.attachmentList = attachmentsList;
        //ClaimInsuranceController.EquipmentWrapper objEquipmentWrapper = new ClaimInsuranceController.EquipmentWrapper(objEquipment,true);
        objClaimInsuranceController.getContacts();
        objClaimInsuranceController.saveClaim();
        objClaimInsuranceController.getSelectedContact();
        objClaimInsuranceController.getClaimType();
        objClaimInsuranceController.doCancel();
    }
}