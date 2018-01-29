public with sharing class InsuranceRentingInactivation {
    public Application__c application;
    public ID applicationID; // BillingContractId value
    public String apoliceNumber{get;set;} // input text1 value  from vf
    public String seguradora{get;set;} // input text2 value  from vf
    public Date clientePolicyBeginningTerm{get;set;} // input text2 value  from vf
    public transient Blob apolice{get;set;} // input text2 value  from vf
    public String apoliceName{get;set;}
    public Insurance_Management__c insuranceObj {get;set;}

    public void setApoliceNumber(String apoliceNumb){
        this.apoliceNumber = apoliceNumb;
    }
    
    public void setSeguradora(String insuranceCompany){
        this.seguradora = insuranceCompany;
    }
    
    public void setClientePolicyBeginningTerm(Date policyBeginningDate){
        this.clientePolicyBeginningTerm = policyBeginningDate;
    }
    
    public void setApolice(Blob apoliceField){
        this.apolice = apoliceField;
    }
    
    public void setApoliceFileName(String apoliceFileName){
        this.apoliceName = apoliceFileName;
    }
    
    public InsuranceRentingInactivation(ApexPages.StandardController controller) {
        insuranceObj = new Insurance_Management__c();
        application = (Application__c) controller.getRecord();
        this.applicationID = ApexPages.currentPage().getParameters().get('id');
    }
    
     public PageReference Inactivate() {
        PageReference pageRef = new PageReference('https://candor.my.salesforce.com/'+this.applicationID);        
        
        Application__c app = [Select Id,Name From Application__c where id = :this.applicationID];
        
         List<Insurance_Management__c> insuranceList =  new List<Insurance_Management__c>([Select Id,Renting_Application__c,Insurance_Status__c,Insurance_Policy_Number__c,
                                                                                           Client_Policy_Beginning_Term__c,Insurance_Value2__c,Old_Insurance_Type__c,InsuranceType__c 
                                                                                           From Insurance_Management__c 
                                                                                           where Renting_Application__c = :app.ID
                                                                                           order by CreatedDate Desc 
                                                                                           limit 1]);
         
         if(apolice==null){
             //return msg erro 
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please insert the policy document!'));
             
             return null;
         }
         
         
         if(insuranceList ==null || insuranceList.size()==0){
             /*ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is no insurance activated'));
			return null;*/	
             String msg = InsuranceManagement.createAndSettleInsurance(app.Name );
             insuranceList =  new List<Insurance_Management__c>([Select Id,Renting_Application__c,Insurance_Status__c,Insurance_Policy_Number__c,
                                                                                               Client_Policy_Beginning_Term__c,Insurance_Value2__c,Old_Insurance_Type__c,InsuranceType__c 
                                                                                               From Insurance_Management__c 
                                                                                               where Renting_Application__c = :app.ID
                                                                                               order by CreatedDate Desc 
                                                                                               limit 1]);
         }
         
        //there is only one insurance per app
        Insurance_Management__c insurance = insuranceList.get(0);
        /*
        if(insurance.Insurance_Policy_Number__c !=apoliceNumber) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Policy number Invalid'));
        }
        */
        /*if(insurance.Insurance_Company__c != seguradora) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insurance Company Invalid'));
        }*/
        /*
        if(insurance.Client_Policy_Beginning_Term__c != clientePolicyBeginningTerm){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cliente Insurance Policy Beginning Term Invalid'));
        }*/
        
        if(ApexPages.hasMessages()){
            return null;
        }
        
        if(insurance.Insurance_Status__c == 'Active'){
            String result = InsuranceManagement.insuranceInactivationRenting(app.id,apoliceNumber,insuranceObj.Insurance_Company2__c,clientePolicyBeginningTerm);
            if(result != ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,result));
                return null;
            }
            
            transient Attachment attach = new Attachment();
            attach.parentId = insurance.id;
            attach.name =  this.apoliceName;    
            attach.body = this.apolice;
            insert attach;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Insurance has been inactivated!'));           
            return pageRef;
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The insurance is already inactivated!'));       
            return null;
        }
               
        return pageRef;
    }
    
    public PageReference Cancel() {
       PageReference pageRef = new PageReference('https://candor.my.salesforce.com/'+this.applicationID);

        return pageRef;
    }

}