public class AC_AssignmentOfContractRender_Controller {
        public List<Equipment__c> equipment{get;set;}
        public AssignmentContract__c  ac ;
        public List<Contact> contactsOfGuarantees { get; set; }        
        
        public AC_AssignmentOfContractRender_Controller(ApexPages.StandardController stdController) {
        ID acID = stdController.getID();
        
        ac = [SELECT ID, Renting_Application__c, numObriga__c, Old_Client_Account__c, New_Client_Account__r.BBAN__c FROM AssignmentContract__c WHERE ID = :acID];
        
        contactsOfGuarantees = [select id, Name, MailingStreet, MailingCity, MailingPostalCode, NIF__c from contact where AccountId= :ac.New_Client_Account__c AND shown_in_app__c=true];        
         
        equipment = [SELECT Id, Equipment_Quantity__c,  Equipment_Description__c, Equipment_Serial_Number__c FROM Equipment__c WHERE Application__c =:ac.Renting_Application__c];
        } 

    public String getFiadorCity(Integer i) { 
        if(contactsOfGuarantees.size() <= i){ return ''; }
        if(contactsOfGuarantees[i].MailingCity == null){ return '<span id="greyed" style="color: #ECECEC;padding-left:3em;">\\WBCF'+(i+1)+'\\</span>'; }
        return contactsOfGuarantees[i].MailingCity; 
    }  
    
    public String getIban(){
        if(ac.New_Client_Account__r.BBAN__c == null){ 
            return '<span id="greyed" style="color: #ECECEC;padding-left:3em;">\\WBIBAN1\\</span>'; 
        }else{
            return '<span id="greyed" style="color: #000000;padding-left:3em;">'+ ac.New_Client_Account__r.BBAN__c +'</span>'; 
        }
    }
     
    public String getFiador0City() {
        return getFiadorCity(0);
    }
    
    public String getFiador1City() {
        return getFiadorCity(1); 
    }    
     
    public String getFiadorAddress(Integer i) {
        if(contactsOfGuarantees.size() <= i){ return ''; }
        if(contactsOfGuarantees[i].MailingStreet == null){ return '<span id="greyed" style="color: #ECECEC;">\\WriteBackAddressFiador'+(i+1)+'\\</span>'; }
            return contactsOfGuarantees[i].MailingStreet;
    }    
    
    public String getFiador0Address() {
        return getFiadorAddress(0);
    }
    
    public String getFiador1Address() {
        return getFiadorAddress(1);
    }     

    public String getFiadorPostalCode(Integer i) {
        if(contactsOfGuarantees.size() <= i){ return ''; }
        if(contactsOfGuarantees[i].MailingPostalCode == null){return '<span id="greyed" style="color: #ECECEC;">\\WBPCF'+(i+1)+'\\</span>';}
        return contactsOfGuarantees[i].MailingPostalCode;
    }  

    public String getFiador0PostalCode() {
        return getFiadorPostalCode(0);
    }
    
    public String getFiador1PostalCode() {
        return getFiadorPostalCode(1);
    }      
    
    public String getFiador0NIF() {
        return getFiadorNIF(0);
    }
    
    public String getFiador1NIF() {
        return getFiadorNIF(1);
    }
    
    public String getFiadorNIF(Integer i) {
        if(contactsOfGuarantees.size() <= i){ return ''; }
        if(contactsOfGuarantees[i].NIF__c == null){ return '<span id="greyed" style="color: #ECECEC;" >\\WBNIFF'+(i+1)+'\\</span>'; }
        return contactsOfGuarantees[i].NIF__c;
    }     
    
                
}