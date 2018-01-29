public with sharing class InsuranceInactivation {
    public Billing_Contract__c billingContract;
    public Insurance_Management__c insuranceObj { get; set; }
    public ID billingContractId; // BillingContractId value
    public String apoliceNumber{get;set;} // input text1 value  from vf
    public String seguradora{get;set;} // input text2 value  from vf
    public Date clientePolicyBeginningTerm{get;set;} // input text2 value  from vf
    public transient Blob apolice{get;set;} // input text2 value  from vf
    public String apoliceName{get;set;}
    
    
    public void setApoliceNumber(String apoliceNumb){
        this.apoliceNumber = apoliceNumb;
    }
    
    public void setSeguradora(String insuranceCompany){
        this.insuranceObj.Insurance_Company2__c = insuranceCompany;
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
    
    public InsuranceInactivation (ApexPages.StandardController controller){
        insuranceObj = new Insurance_Management__c();
        billingContract = (Billing_Contract__c) controller.getRecord();
        this.billingContractId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public PageReference Activate() {
        PageReference pageRef = new PageReference('https://candor.my.salesforce.com/'+this.billingContractId);        
        
        Billing_Contract__c billing = [Select Id, Application__c From Billing_Contract__c where id = :this.billingContractId];
        
        List<Insurance_Management__c> insuranceList =  new List<Insurance_Management__c>([Select Id,Name,Renting_Application__c,Insurance_Status__c,Insurance_Policy_Number__c,
                                                                                          Client_Policy_Beginning_Term__c,Insurance_Value2__c,InsuranceType__c,Old_Insurance_Type__c 
                                                                                          From Insurance_Management__c 
                                                                                          where Renting_Application__c = :billing.Application__c
                                                                                          order by CreatedDate Desc 
                                                                                          limit 1]);

 
        if(apolice==null){
            //return msg erro 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please insert the policy document!'));
            return null;
        }
        
        if(insuranceList ==null || insuranceList.size()==0){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is no insurance to activate'));
            String msg = InsuranceManagement.createAndSettleInsurance(billing.Application__r.Name );
            insuranceList =  new List<Insurance_Management__c>([Select Id,Name,Renting_Application__c,Renting_Application__r.Name,Insurance_Status__c,Insurance_Policy_Number__c,Insurance_Percent2__c,
                                                                Client_Policy_Beginning_Term__c,Insurance_Value2__c,Old_Insurance_Type__c,InsuranceType__c 
                                                                From Insurance_Management__c 
                                                                where Renting_Application__c = :billing.Application__c
                                                                order by CreatedDate Desc limit 1]);
        }
        
        if(ApexPages.hasMessages(ApexPages.severity.ERROR) || ApexPages.hasMessages(ApexPages.severity.FATAL)){
            return null;
        }

        //there is only one insurance per app
        Insurance_Management__c insurance = insuranceList.get(0);
        
        if(insurance.Insurance_Status__c == 'Inactive'){

            String result = InsuranceManagement.activationInsurance(insurance.Renting_Application__c,apoliceNumber,insuranceObj.Insurance_Company2__c,clientePolicyBeginningTerm);
            if(result == '' || result == null){
                transient Attachment attach = new Attachment();
                attach.parentId = [Select Id
                                   From Insurance_Management__c 
                                   where Renting_Application__c = :billing.Application__c order by CreatedDate Desc limit 1].id;
                attach.name =  this.apoliceName;    
                attach.body = this.apolice;
                insert attach;
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Insurance has been activated!'));     
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, result));
            }
                  
            return null;

        }else{
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The insurance is already activated!'));       
            return null;
        }
    }
    
    public PageReference Inactivate() {        
        Billing_Contract__c billing = [Select Id, Application__c, Application__r.Name From Billing_Contract__c where id = :this.billingContractId];
        
        List<Insurance_Management__c> insuranceList =  new List<Insurance_Management__c>([Select Id,Name,Renting_Application__c,Renting_Application__r.Name,Insurance_Status__c,Insurance_Policy_Number__c,Insurance_Percent2__c,
                                                                                          Client_Policy_Beginning_Term__c,Insurance_Value2__c,Old_Insurance_Type__c,InsuranceType__c 
                                                                                          From Insurance_Management__c where Renting_Application__c = :billing.Application__c order by CreatedDate Desc limit 1]);
        
        if(apolice==null){
            //return msg erro 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please insert the policy document!'));
            return null;
        }
        
        if(insuranceList ==null || insuranceList.size()==0){
            String msg = InsuranceManagement.createAndSettleInsurance(billing.Application__r.Name );
            insuranceList =  new List<Insurance_Management__c>([Select Id,Name,Renting_Application__c,Renting_Application__r.Name,Insurance_Status__c,Insurance_Policy_Number__c,Insurance_Percent2__c,
                                                                Client_Policy_Beginning_Term__c,Insurance_Value2__c,Old_Insurance_Type__c,InsuranceType__c 
                                                                From Insurance_Management__c where Renting_Application__c = :billing.Application__c order by CreatedDate Desc limit 1]);
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is no insurance activated'));
            //return null;
        }        
        
        //there is only one insurance per app
        Insurance_Management__c insurance = insuranceList.get(0);

        /*
        if(insurance.Insurance_Policy_Number__c !=apoliceNumber) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Policy number Invalid'));
        }*/
        
        //insurance company validation
        /*if(insurance.Insurance_Company__c != seguradora) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insurance Company Invalid'));
        }*/
        
        if(insuranceObj.Insurance_Company2__c.equalsIgnoreCase('Candor')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insurance Company must be diferent from Candor'));
        }
        
        
        if(clientePolicyBeginningTerm == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cliente Insurance Policy Beginning Term Invalid'));
        }
        
        if(ApexPages.hasMessages(ApexPages.severity.ERROR) || ApexPages.hasMessages(ApexPages.severity.FATAL)){
            return null;
        }
        
        if(insurance.Insurance_Status__c == 'Active'){

            String result = InsuranceManagement.cancelInsurance(insurance.Renting_Application__c,apoliceNumber,insuranceObj.Insurance_Company2__c,clientePolicyBeginningTerm);
            if(result==''){
                
                transient Attachment attach = new Attachment();
                attach.parentId = [Select Id
                                   From Insurance_Management__c 
                                   where Renting_Application__c = :billing.Application__c order by CreatedDate Desc limit 1].id;
                
                attach.name =  this.apoliceName;    
                attach.body = this.apolice;
                insert attach;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Insurance has been inactivated!'));                         
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, result));
            }
            return null;
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The insurance is already inactivated!'));       
            return null;
        }
    }


    public PageReference Cancel() {
       PageReference pageRef = new PageReference('https://candor.my.salesforce.com/'+this.billingContractId);

        return pageRef;
    }

    

}