/**

Author   |Date  | Comments
Vinod    |11/15/2017 | Initial Creation
Sneha    |12/4/2017  | View functionality for Claim
**/

public class ClaimInsuranceController{

    public Billing_Contract__c objBillingContract{get;set;}
    public Contact objContact{get;set;}
    public Claim_Insurance__c objClaimInsurance{get;set;}
    public List<EquipmentWrapper> equipmentWrapperList{get;set;}
    public List<Attachment> attachmentList{get;set;}
    public String billingContractId;
    public String selectedContactId{get;set;}
    public String claimInsuranceName{get;set;}
    public Map<String,Contact> contactMap;

    //Parameterized Constructor
    public ClaimInsuranceController(ApexPages.StandardController controller) {
    }
    
    //Constructor
    public ClaimInsuranceController(){
        objBillingContract = new Billing_Contract__c();
        objContact = new Contact();
        objClaimInsurance = new Claim_Insurance__c();
        equipmentWrapperList = new List<EquipmentWrapper>();
        contactMap = new Map<String,Contact>();
        attachmentList = new List<Attachment>();
        List<Equipment__c> equipmentList = new List<Equipment__c>();
        claimInsuranceName = '';

        //Dynamically formed query for fetching billing contract and equipments of contract's application
        DescribeSObjectResult describeEquipmentResult = Equipment__c.getSObjectType().getDescribe();
        List<String> equipmentsFields = new List<String>(describeEquipmentResult.fields.getMap().keySet());

        //Get Id of billing contract
        billingContractId = Apexpages.currentPage().getParameters().get('Id');
        objClaimInsurance.Data_de_sinistro__c = System.today();
        List<String> timeParts = System.now().format('HH:mm').split(':');
        Time myTime = Time.newInstance(Integer.valueOf(timeParts[0]), Integer.valueOf(timeParts[1]), 0, 0);

        //objClaimInsurance.Hora__c = myTime;

        List<Billing_Contract__c> billingContractList = new List<Billing_Contract__c>();
        //If contact id exists then fetch 
        if(billingContractId != null){
            billingContractList = [SELECT Id, Name, Collection_Case__c, Collection_Case__r.Name, Account__c, Account__r.BillingAddress, Account__r.BillingCity, Account__r.BillingStreet,Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode, Account__r.NIF__c, Account__r.Phone, Application__c FROM Billing_Contract__c WHERE Id =: billingContractId];
        }
        if(billingContractList.size()>0){
            objBillingContract = billingContractList[0];
        }

        if(objBillingContract.Collection_Case__c == null){
            
            //Query recently created claim insurance to get the Name(AutoNumber) of insurance
            List<Claim_Insurance__c> claimInsuranceList = new List<Claim_Insurance__c>([SELECT Id, Name FROM Claim_Insurance__c ORDER BY CreatedDate DESC limit 1 ALL ROWS]);
            
            //Get Name of insurance and increase the auto number field by 1 and display on page as claim insurance serial else display start serial number
            if(claimInsuranceList.size() > 0){
                List<String> extractNameList = claimInsuranceList[0].Name.split('-');
                System.debug('list ->> '+extractNameList);
                if(extractNameList.size() > 0){
                    claimInsuranceName = 'CI-'+String.valueOf(Integer.valueOf(extractNameList[1]) + 1).leftPad(extractNameList[1].length(),'0');
                }
            }else{
                claimInsuranceName = 'CI-0000001';
            }
            
            //Three attachments to upload
            for(Integer i = 0; i < 3; i++){
                Attachment objAttachment = new Attachment();
                attachmentList.add(objAttachment);
            }
            
            //Fetch contacts of billing contract's account and populate map to select contact on page
            if(objBillingContract.Account__c != null){
                contactMap = new Map<String,Contact>([SELECT Id,Name,Email,MobilePhone FROM Contact WHERE AccountId =: objBillingContract.Account__c ORDER BY CreatedDate DESC]);
            }
            
            //Query all equipments of billing contract's application
            if(objBillingContract.Application__c != null){
                String equipmentQuery = 'SELECT '+String.join(equipmentsFields,',') +' FROM '+describeEquipmentResult.getName()+' WHERE Application__c = \''+objBillingContract.Application__c+'\'';
                equipmentList = Database.query(equipmentQuery);
            }
            
            //Create wrapper class list to select equipment to claim
            for(Equipment__c objEquipment : equipmentList){
                equipmentWrapperList.add(new EquipmentWrapper(objEquipment,false,Integer.valueOf(objEquipment.Equipment_Quantity__c)));
            }
            
            //Assign one recent contact from contacts of billing contract's account
            if(contactMap.values().size() > 0){
                objContact = contactMap.values()[0];
            }
        }

    }
    
    //Method to get options of contacts for account client of billing contract
    public List<SelectOption> getContacts(){
        List<SelectOption> contactOptions = new List<SelectOption>();
        for(Contact objContact : contactMap.values()){
            contactOptions.add( new SelectOption(objContact.Id,objContact.Name));
        }
        return contactOptions;
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
    
    //Method to get details of selected contact from dropdown
    public PageReference getSelectedContact(){
        System.debug('selectedContactId '+selectedContactId);
        if(contactMap.containsKey(selectedContactId)){
            objContact = contactMap.get(selectedContactId);
        }
        return null;
    }
    
    //Method to save Claim Insurance
    public PageReference saveClaim(){
        System.debug('selectedContactId '+selectedContactId);
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            //Insert claim insurance with provided information
            if(objContact != null && objClaimInsurance != null){
                objClaimInsurance.Contact__c = objContact.Id;
            }
            if(objBillingContract != null){
                objClaimInsurance.Billing_Contract__c = objBillingContract.Id;
            }
            if(objClaimInsurance != null){
                insert objClaimInsurance;
            }
            
            //Insert attachments if provided
            List<Attachment> attachList = new List<Attachment>();
            for(Attachment objAttachment : attachmentList){
                if(objAttachment.Name != null && objAttachment.body != null){
                    objAttachment.parentId = objClaimInsurance.Id;
                    attachList.add(objAttachment);
                }
            }
            attachmentList = new List<Attachment>();
            if(attachList.size() > 0){
                insert attachList;
            }
            
            //List to store selected equipments on page
            List<Damaged_Equipment__c> equipmentListToSave = new List<Damaged_Equipment__c>();
            //Iterate wrapper list and update selected equipments
            for(EquipmentWrapper objEquipmentWrapper : equipmentWrapperList){
                if(objEquipmentWrapper.isSelected){
                    //objEquipmentWrapper.objEquipment.Claim_Insurance__c = objClaimInsurance.Id;
                    Damaged_Equipment__c objDamagedEquipment = new Damaged_Equipment__c();
                    objDamagedEquipment.Equipment__c = objEquipmentWrapper.objEquipment.Id;
                    objDamagedEquipment.Claim_Insurance__c = objClaimInsurance.Id;
                    objDamagedEquipment.Quantity__c = objEquipmentWrapper.quantity;
                    equipmentListToSave.add(objDamagedEquipment);
                }
            }
            if(equipmentListToSave.size() > 0){
                insert equipmentListToSave;
            }
            
            System.debug('objClaimInsurance id '+objClaimInsurance.Id);
            
            //Attach pdf of claim insurance created
            PageReference objPageReference = Page.ClaimInsuranceView;
            objPageReference.getParameters().put('id',objClaimInsurance.Id);
            return objPageReference;
            
        }catch(Exception e){
            Database.rollback( sp );
            System.debug('Error message '+e.getMessage());
            System.debug('Stack trace '+e.getStackTraceString());
            return null;
        }
    }
    
    //Cancel method to redirect to billing contract
    public PageReference doCancel(){
        PageReference objPageReference = new PageReference('/'+billingContractId);
        objPageReference.setRedirect(true);
        return objPageReference;
    }
    
    //Wrapper class for list of equipment
    public class EquipmentWrapper{
        public Equipment__c objEquipment{get;set;}
        public boolean isSelected{get;set;}
        public Integer quantity{get;set;}
        public Integer originalQuantity{get;set;}
        
        public EquipmentWrapper(Equipment__c objEquipment, boolean isSelected, Integer quantity){
            this.objEquipment = objEquipment;
            this.isSelected = isSelected;
            this.quantity = quantity;
            originalQuantity = quantity;
        }
    }
}