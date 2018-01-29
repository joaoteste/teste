public with sharing class CertificateController {

    public List<Equipment__c> equipment{get;set;}
    private final Application__c application;
    public String today {get;set;}
    public String IBAN {get;set;}
    public String textColor {get;set;}

    public CertificateController(ApexPages.StandardController stdController) {
        this.application = (Application__c)stdController.getRecord();
        this.equipment = [SELECT Id, Equipment_Quantity__c,  Equipment_Description__c, Equipment_Serial_Number__c FROM Equipment__c WHERE Application__c =:application.Id];
        this.today = Datetime.now().format('dd MMMMM yyyy');
        Application__c app = [SELECT Payment_Method__c, AccClient__r.c2g__CODABankIBANNumber__c FROM Application__c WHERE ID=:application.Id];

        if(app.Payment_Method__c=='ATM Reference'){
                this.IBAN = 'empty';
                this.textColor = ' #ECECEC';
        }else if(app.Payment_Method__c=='Direct Debit'){
            if(app.AccClient__r.c2g__CODABankIBANNumber__c!=null){
                this.IBAN = app.AccClient__r.c2g__CODABankIBANNumber__c;
            }else{
                this.IBAN = 'empty';
                this.textColor = '#ECECEC';
            }
        }else{ 
                this.IBAN = '\\' +'WBIBAN' + '\\';
                this.textColor = '#ECECEC';
                //this.textColor = 'black';
        }
    }
}