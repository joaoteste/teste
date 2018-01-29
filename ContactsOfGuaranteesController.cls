public class ContactsOfGuaranteesController {
    
    private ApexPages.StandardController standardController;
    public map <integer,Contact> contactsOfGuarantees { get; set; }
    public String today {get;set;}
    
    public ContactsOfGuaranteesController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        
        Application__c app = (Application__c) standardController.getRecord();
        
        //contactsOfGuarantees = [select id, Name, MailingStreet, MailingCity, MailingPostalCode, NIF__c from contact where AccountId=:app.AccClient__c and shown_in_app__c=true];
        contactsOfGuarantees =New map <integer,Contact>();
        list<contact> con=[select id, Name, MailingStreet, MailingCity, MailingPostalCode, NIF__c from contact where Id=:app.Client_Signer_1__c or ( Id=:app.Client_signer_2__c)];
        for(integer i=0; i<con.size(); i++){

            if(con[i].id==app.Client_Signer_1__c){
                contactsOfGuarantees.put(0,con[i]);
            }
            if(con[i].id==app.Client_signer_2__c){
                contactsOfGuarantees.put(1,con[i]);
            }
        }
         this.today = Datetime.now().format('dd MMMMM yyyy');
    }
    
    public String getFiador0Name() {
        return getFiadorName(0);
    }
    
    public String getFiador1Name() {
        return getFiadorName(1);
    }
    
    public String getFiadorName(Integer i) {
        if(contactsOfGuarantees.size() <= i){ return ''; }
        system.debug(contactsOfGuarantees);
        system.debug(contactsOfGuarantees.get(i).Name);
        return contactsOfGuarantees.get(i).Name;//No WriteBack on name
    }
    
    
    public String getFiador0Address() {
        return getFiadorAddress(0);
    }
    
    public String getFiador1Address() {
        return getFiadorAddress(1);
    }
    
    public String getFiadorAddress(Integer i) {
        if(contactsOfGuarantees.size() <= i){ return ''; }
        if(contactsOfGuarantees.get(i).MailingStreet == null){ return '<span id="greyed">\\WriteBackAddressFiador'+(i+1)+'\\</span>'; }
            return contactsOfGuarantees.get(i).MailingStreet;
    }
    
    public String getFiador0City() {
        return gitFiadorCity(0);
    }
    
    public String getFiador1City() {
        return gitFiadorCity(1);
    }
    
    public String gitFiadorCity(Integer i) {
        if(contactsOfGuarantees.size() <= i){ return ''; }
        if(contactsOfGuarantees.get(i).MailingCity == null){ return '<span id="greyed">\\WBCF'+(i+1)+'\\</span>'; }
        return contactsOfGuarantees.get(i).MailingCity;
    }
    
    public String getFiador0PostalCode() {
        return getFiadorPostalCode(0);
    }
    
    public String getFiador1PostalCode() {
        return getFiadorPostalCode(1);
    }
    
    public String getFiadorPostalCode(Integer i) {
        if(contactsOfGuarantees.size() <= i){ return ''; }
        if(contactsOfGuarantees.get(i).MailingPostalCode == null){return '<span id="greyed">\\WBPCF'+(i+1)+'\\</span>';}
        return contactsOfGuarantees.get(i).MailingPostalCode;
    }
    
    public String getFiador0NIF() {
        return getFiadorNIF(0);
    }
    
    public String getFiador1NIF() {
        return getFiadorNIF(1);
    }
    
    public String getFiadorNIF(Integer i) {
        if(contactsOfGuarantees.size() <= i){ return ''; }
        if(contactsOfGuarantees.get(i).NIF__c == null){ return '<span id="greyed">\\WBNIFF'+(i+1)+'\\</span>'; }
        return contactsOfGuarantees.get(i).NIF__c;
    }
        
    public Contact getFiadorContact(Integer i) {
        if(contactsOfGuarantees.size() > i){return contactsOfGuarantees.get(1);}
        return null;
    }
}