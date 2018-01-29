/**

Author   |Date  | Comments
Vinod    |12/05/2017 | Initial Creation
**/

public class ClaimInsuranceViewController{

    public Billing_Contract__c objBillingContract{get;set;}
    public Contact objContact{get;set;}
    public Claim_Insurance__c objClaimInsurance{get;set;}
    public List<EquipmentWrapper> equipmentWrapperList{get;set;}
    public List<Attachment> attachmentList{get;set;}
    public List<Contact> contactList;
    public Id recordId;
    
    public ClaimInsuranceViewController(ApexPages.StandardController controller) {

        objBillingContract = new Billing_Contract__c();
        objContact = new Contact();
        objClaimInsurance = new Claim_Insurance__c();
        equipmentWrapperList = new List<EquipmentWrapper>();
        attachmentList = new List<Attachment>();
        List<Equipment__c> equipmentList = new List<Equipment__c>();
        List<Billing_Contract__c> billingContractList = new List<Billing_Contract__c>();
        
        //Dynamically formed query for fetching claim insurance and it's equipment
        DescribesObjectResult describeResult = Claim_Insurance__c.getsObjectType().getDescribe();
        DescribeSObjectResult describeEquipmentResult = Equipment__c.getSObjectType().getDescribe();

        //Get Claim ID
        recordId = Apexpages.currentPage().getParameters().get('id');
        if(recordId != null){
            System.debug('recordId -->> '+recordId);
            
            List<String> claimInsuranceFields = new List<String>(describeResult.fields.getMap().keySet());
            List<String> equipmentsFields = new List<String>(describeEquipmentResult.fields.getMap().keySet());
            

            String query = 'SELECT '+String.join(claimInsuranceFields,',');
            query   += ', Contact__r.Name, Contact__r.Email, Contact__r.MobilePhone, Billing_Contract__r.Account__c, Billing_Contract__r.Name ,Billing_Contract__r.Account__r.BillingStreet, Billing_Contract__r.Account__r.BillingCity, Billing_Contract__r.Account__r.BillingState, Billing_Contract__r.Account__r.BillingCountry, Billing_Contract__r.Account__r.BillingPostalCode, Billing_Contract__r.Application__c, Billing_Contract__r.Account__r.Phone,Billing_Contract__r.Account__r.NIF__c';
            query += ' FROM '+describeResult.getName()+' WHERE Id = \''+recordId+'\'';
            
            
            System.debug('query -->> '+query);
            
            List<Claim_Insurance__c> claimInsuranceList = new List<Claim_Insurance__c>();
            
            claimInsuranceList = Database.query(query);
            
            System.debug('claimInsuranceList -->>'+claimInsuranceList);
            
            if(claimInsuranceList.size()>0){
                objClaimInsurance = claimInsuranceList[0];
            }
            if(objClaimInsurance.Billing_Contract__r.Application__c != null){
                String equipmentQuery = 'SELECT '+String.join(equipmentsFields,',') +' FROM '+describeEquipmentResult.getName()+' WHERE Application__c = \''+objClaimInsurance.Billing_Contract__r.Application__c+'\'';
                equipmentList = Database.query(equipmentQuery);
            }
            Set<Id> equipmentIds = new Set<Id>();
            Map<Id,Damaged_Equipment__c> damagedEquipmentMap = new Map<Id,Damaged_Equipment__c>();
            for(Damaged_Equipment__c objDamagedEquipment : [SELECT Id, Equipment__c, Claim_Insurance__c, Quantity__c FROM Damaged_Equipment__c WHERE Claim_Insurance__c =: recordId]){
                equipmentIds.add(objDamagedEquipment.Equipment__c);
                damagedEquipmentMap.put(objDamagedEquipment.Equipment__c,objDamagedEquipment);
            }
            /*Map<Id,Equipment__c> equipmentMap = new Map<Id,Equipment__c>([SELECT Id, Equipment_Description__c, Equipment_Quantity__c, Equipment_Serial_Number__c FROM Equipment__c WHERE Id IN: equipmentIds ]);*/
            
            for(Equipment__c objEquipment : equipmentList){
                if(damagedEquipmentMap.containsKey(objEquipment.Id) && damagedEquipmentMap.get(objEquipment.Id) != null && damagedEquipmentMap.get(objEquipment.Id).Quantity__c != null && equipmentIds.contains(objEquipment.Id)){
                    equipmentWrapperList.add(new EquipmentWrapper(objEquipment, equipmentIds.contains(objEquipment.Id), Integer.valueOf(damagedEquipmentMap.get(objEquipment.Id).Quantity__c)));
                }/*else{
                    equipmentWrapperList.add(new EquipmentWrapper(objEquipment, equipmentIds.contains(objEquipment.Id), Integer.valueOf(objEquipment.Equipment_Quantity__c)));
                }*/
            }
            
            for(Attachment objAttachment : [SELECT Id,Name FROM Attachment WHERE parentId =: objClaimInsurance.Id ORDER BY CreatedDate DESC]){
                if(!objAttachment.Name.contains('CI-')){
                    attachmentList.add(objAttachment);
                }
            }
            for(Integer i = 3; attachmentList.size() > i; i++){
                attachmentList.remove(i);
            }
        }
    }

    
    //Method to get options of contacts for account client of billing contract
    public List<SelectOption> getClaimType(){
        Schema.sObjectType sobject_type = Claim_Insurance__c.getSObjectType();

        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();

        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
      
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Insurance_Claim_Type__c').getDescribe().getPickListValues();

        List<selectOption> options = new List<selectOption>();

        for (Schema.PicklistEntry a : pick_list_values) {
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public class EquipmentWrapper{
        public Equipment__c objEquipment{get;set;}
        public boolean isSelected{get;set;}
        public Integer quantity{get;set;}
        
        public EquipmentWrapper(Equipment__c objEquipment, boolean isSelected, Integer quantity){
            this.objEquipment = objEquipment;
            this.isSelected = isSelected;
            this.quantity = quantity;
        }
    }
    
    public PageReference savePDF(){
        PageReference objSavePDFPage = Page.ClaimInsuranceView;
        // add parent id to the parameters for standardcontroller
        objSavePDFPage.getParameters().put('id',objClaimInsurance.Id);
        
        Attachment objAttachmentView = new Attachment();
        Blob body;
        if(!test.isRunningTest()){
            body = objSavePDFPage.getContentasPDF();    
        }else{
            body = blob.valueOf('Test');
        }
        
        System.debug('Merged body '+body);
        
        objAttachmentView.Body = body;
        // add the user entered name
        objAttachmentView.Name = objClaimInsurance.Name+'.pdf';
        // attach the pdf to the account
        objAttachmentView.parentid = recordId;
        objAttachmentView.ContentType = 'application/pdf';
        insert objAttachmentView;       
        
        //Redirect to created claim insurance
        PageReference objPageRef = new PageReference('/'+objClaimInsurance.Id);
        objPageRef.setRedirect(true);
        return objPageRef;
    }
}