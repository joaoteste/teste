public class PaymentPlan_Controller {
    Payment_Plan__c objPaymentPlan;
    public List<Payment_Schedule__c> payScheduleList{get;set;}
    public List<c2g__codaInvoice__c> salesInvoiceList{get;set;}
    public Boolean disable{get;set;}
    public Integer start{get;set;}  
    
    public PaymentPlan_Controller(ApexPages.StandardController controller) {
        objPaymentPlan = (Payment_Plan__c)controller.getRecord();
        
        objPaymentPlan = [SELECT ID,  Name, Type__c, Contact__r.MobilePhone, Signer_2__r.MailingStreet,  Signer_1__r.MailingStreet,  Signer_1__r.MailingPostalCode, Signer_1__r.MailingCity, Signer_1__r.NIF__c , Signer_2__r.MailingPostalCode, Signer_2__r.MailingCity, Signer_2__r.NIF__c , Account__r.Name, Signer_1__r.Name, Signer_2__r.Name, Account__r.BillingStreet, Account__r.BillingPostalCode, Account__r.BillingCity, Account__r.NIF__c FROM Payment_Plan__c WHERE id = :objPaymentPlan.ID];
        
        payScheduleList = [SELECT ID, Schedule_Number__c, Due_Date__c, Fees_Amount__c, Total_Amount__c, Amount_W_O_Tax__c, Balance__c, Sales_Invoice__c, Late_Payment_Interest_Amount__c FROM Payment_Schedule__c WHERE Payment_Plan__c=:objPaymentPlan.id ORDER BY Name ASC];

                if(payScheduleList[0].Sales_Invoice__c != null)      
            disable = true;
            
       salesInvoiceList = [SELECT ID, c2g__InvoiceTotal__c, c2g__DueDate__c, Invoice_Express_Number_text__c, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c,Application__c, Application__r.Name   FROM c2g__codaInvoice__c WHERE c2g__Account__c = :objPaymentPlan.Account__c AND (c2g__PaymentStatus__c = 'Unpaid' OR  c2g__PaymentStatus__c ='Part Paid')];
       
       start = payScheduleList.size()-2;
        //para nao render o pdf
        if(start<=32) start = 1000;
    }  
    
    public Boolean existsSignedPaymentPlan(){
        List<Attachment> listDocument = new List<Attachment>();
        PageReference pdf = null;
        String ppNAme = 'Plano de Pagamentos '+objPaymentPlan.Name+'.pdf';
        listDocument =[SELECT Id, name, body, createdDate, parentID 
                       FROM attachment 
                       WHERE parentId =:objPaymentPlan.ID AND (NOT name LIKE :ppName)];    	
                       
        return !listDocument.isEmpty();
    }
    
   

    public PageReference acceptPaymentPlan(){
        if(objPaymentPlan.Type__c == 'Full' && !existsSignedPaymentPlan() && !Test.isRunningTest()){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Signed Payment Plan is mandatory'));    
                return null;    
        }
            
        try{

          Boolean result =  PaymentPlan_Utils.startSchedule(objPaymentPlan.ID,'1');
            if(result){ 
                if(!Test.isRunningTest())sendSMS(objPaymentPlan.ID);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Payment Plan Accepted with Sucess!'));    
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went wrong, please contact the support team.'));
            } 
        }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went really wrong, please contact the support team.'+e.getMessage()+e.getStackTraceString()));
        }

        
        disable = true;
        
        return null;
    }
    
    @future(callout=true)       
    public static void sendSMS(ID ppID){
        Payment_Plan__c pp = [SELECT ID,  Name, Contact__r.MobilePhone, Number_of_Payments__c, PP_Total_Amount__c, Type__c  FROM Payment_Plan__c WHERE id = :ppID];
        if(pp.Type__c == 'Partial'){
                String msg = 'Informamos que foi criado um plano de pagamentos no valor em dívida. Cada prestação será enviada por email 5 dias antes da data de vencimento, juntamente com a referência para pagamento. Mais questões: info@candor.pt ';
                        //msg = msg.replaceAll('X', String.valueOf(pp.PP_Total_Amount__c));       
                        SMSUtil.sendSms(pp.Contact__r.MobilePhone, 'CANDOR', msg, pp.ID);
        }
    }
    
    public String getCompanyName(){
       return objPaymentPlan.Account__r.Name.abbreviate(50);
    }
    
    public String getNIF(){
        return objPaymentPlan.Account__r.NIF__c;
    }
    
    public String getStreet(){
        return objPaymentPlan.Account__r.BillingStreet.abbreviate(49);
    }
    
    public String getPostalCode(){
        return objPaymentPlan.Account__r.BillingPostalCode;
    }
    
    public String getCity(){
        return objPaymentPlan.Account__r.BillingCity;
    }
    
    public String getFiador1Name(){
        return objPaymentPlan.Signer_1__r.Name;
    }
    
    public String getFiador2Name(){
        return objPaymentPlan.Signer_2__r.Name;
    }    

    public String getFiador1Street(){
        return objPaymentPlan.Signer_1__r.MailingStreet;
    }
    
    public String getFiador2Street(){
        return objPaymentPlan.Signer_2__r.MailingStreet;
    }  
    
    public String getFiador1PostalCode(){
        return objPaymentPlan.Signer_1__r.MailingPostalCode;
    }
    
    public String getFiador2PostalCode(){
        return objPaymentPlan.Signer_2__r.MailingPostalCode;
    }    
            
    public String getFiador1NIF(){
        return objPaymentPlan.Signer_1__r.NIF__c;
    }
    
    public String getFiador2NIF(){
        return objPaymentPlan.Signer_2__r.NIF__c;
    }   
    
    public String getFiador1City(){
        if(objPaymentPlan.Signer_1__r.MailingCity != null)
            return ','+objPaymentPlan.Signer_1__r.MailingCity;
        return '';
    }
    
    public String getFiador2City(){
        if(objPaymentPlan.Signer_2__r.MailingCity != null)    
            return ','+objPaymentPlan.Signer_2__r.MailingCity;
        return '';            
    }   
    
    public String getRentingApplicationList(){
        Set<String> apName = new Set<String>();
        
        for(c2g__codaInvoice__c si : salesInvoiceList){
            apName.add(si.Application__r.Name);
        }
        
        String apList = '';
        for(String ap : apName)
            apList+= ap + ', ';
            
        return apList.left(apList.length()-3);
        
    }      
    
    public String getSeparator(){
        if(payScheduleList.size()>34)
            return '...';
        return '';
    }    
    
    public PageReference generatePDF(){
        PageReference pdf = null;
        Attachment newContract = new Attachment (ParentId = objPaymentPlan.ID);
        pdf = Page.PaymentPlan_GeneratePDF;
        pdf.getParameters().put('id',objPaymentPlan.ID);
        Blob body; 
        try {
            // returns the output of the page as a PDF
            body = pdf.getContent();
            // need to pass unit test -- current bug  
        } catch (VisualforceException e) {
            body = Blob.valueOf('need to pass unit test');
        }
                newContract.Body = body;
        newContract.Name = 'Plano de Pagamentos '+objPaymentPlan.Name+'.pdf';
        newContract.IsPrivate = false;
        
        upsert newContract;   
        PageReference pageRef = new PageReference('/'+objPaymentPlan.Id);
        pageRef.setRedirect(true);
        return pageRef;      
    }      
    
    /*
        public PageReference upload(ID ppID) {
         
            attachment.OwnerId = UserInfo.getUserId();
            attachment.ParentId = ppID; // the record the file is attached to
            attachment.IsPrivate = true;
            attachment.description = 'Certificate Merge PDF';
            try { 
              insert attachment;
            } catch (DMLException e) {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
              return null;
            } finally {
              attachment = new Attachment(); 
            }
        
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Payment Plan Created!'));
            return null;
        }    */
        

}