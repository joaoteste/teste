Public class c_SendEmail{
    
    public PageReference pgReturnPage;
    Public string IdUrl {get;set;} 
    
    Public c_SendEmail(ApexPages.StandardController stdController){
        IdUrl  = stdController.GetID();
        
        String returnUrl = '/' + IdUrl;
        pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
    }    
    
    Public PageReference RedirectDunningAlert(){          
        
        //b_Send1stDunningAlert b = new b_Send1stDunningAlert(); 
        //database.executebatch(b);
        
        Dunning_Alert__c da = [Select id, Collection_Case__c, Status__c, Collection_Case__r.Account__c, Dunning_Level__c, Sent_Date__c, Aux_Entity__c, Aux_Reference__c, Due_Date__c, Collection_Case__r.Personal_Guarantee_Signer_1__c, Collection_Case__r.Personal_Guarantee_Signer_2__c from Dunning_Alert__c where id = :IdUrl];
        
        Map<String, Dunning_Admin__c> map_DunningAdmin = new Map<String, Dunning_Admin__c>();
        for(Dunning_Admin__c dadmin : [Select Id,Past_Due_Days__c,Nr_of_Days_to_Pay__c,Dunning_Level__c,Dunning_Frequency__c,Active__c, Email_Template__c, Personal_Guarantee_Email_Template__c From Dunning_Admin__c where Active__c='Yes']){
            map_DunningAdmin.put(dadmin.Dunning_Level__c,dadmin); 
        }
        
        Map<String, List<Contact>> map_Contact = new Map<String, List<Contact>>(); 
                
        Date due_Date = da.Due_Date__c;
        if(Test.isRunningTest())
            due_Date=date.today().addDays(1);
        
        
        if(da.Status__c=='Open' && due_Date>date.today()){
            
            List<Contact> l_contact =  [Select Id,AccountId,Email From Contact where AccountId =: da.Collection_Case__r.Account__c and Email != 'change_me@email.com' and Collections_Email_Opt_Out__c = false and Email != null];
            
            for(Contact mContact: l_Contact){
                map_Contact.put(mContact.AccountId, l_Contact);                
            } 
            
            List<c2g__codaInvoice__c> l_Invoives = [Select Id,Name,c2g__InvoiceDate__c, c2g__InvoiceTotal__c  From c2g__codaInvoice__c where Collection_Case__c =: da.Collection_Case__c and c2g__PaymentStatus__c = 'Unpaid' ];       
            
            CreateTableInvoice.CreateTable(da.Id,da.Collection_Case__c);
            
            CreatePdf();
            
            Dunning_Admin__c daLevel = map_DunningAdmin.get(da.Dunning_Level__c);
            
            //Date Past Due Date                    
            Integer iDate = Integer.ValueOf(daLevel.Past_Due_Days__c);                        
            Date sPastDueDate = da.Sent_Date__c.addDays(iDate);
            //Date sDate = Date.Today();
            
            List<Contact> daContact = map_Contact.get(da.Collection_Case__r.Account__c);
            //if(sPastDueDate  == sDate){            
            sendEmailDunningAlert(da.id, /*daLevel.Email_Template__c,*/ daContact, sPastDueDate, daLevel.Email_Template__c);
            //}
            
            Map<String, List<Contact>> DA_contacts = new Map<String, List<Contact>>();
            List<ID> sId_SignerContacts = new List<ID>();
            Map<String, Contact> DA_contactsSigner = new Map<String, Contact>();
            
            if(da.Collection_Case__r.Personal_Guarantee_Signer_1__c != null){
                sId_SignerContacts.add(da.Collection_Case__r.Personal_Guarantee_Signer_1__c);
            }
            if(da.Collection_Case__r.Personal_Guarantee_Signer_2__c != null){
                sId_SignerContacts.add(da.Collection_Case__r.Personal_Guarantee_Signer_2__c);
            }
            
            List<Contact> l_SignerContacts = [Select Id,AccountId,Email From Contact where id in: sId_SignerContacts and Email != 'change_me@email.com' and Email != null AND Collections_Email_Opt_Out__c = false];

            for(Contact c: l_SignerContacts){
                if(!DA_contacts.containsKey(c.id)){
                    DA_contactsSigner.put(c.id, c);
                }        
            } 
            
            String level = da.Dunning_Level__c;
            if(level.equalsIgnoreCase('4Th Reminder')){
                
                String sTemplate4thReminder = daLevel.Personal_Guarantee_Email_Template__c;
                
                List<Contact> email_listSigner = new List<Contact>();
                Contact signer1 = DA_contactsSigner.get(da.Collection_Case__r.Personal_Guarantee_Signer_1__c);
                Contact signer2 = DA_contactsSigner.get(da.Collection_Case__r.Personal_Guarantee_Signer_2__c);
                if(signer1 != null){
                    email_listSigner.add(signer1);
                }
                if(signer2 != null){
                    email_listSigner.add(signer2);
                }
                if(!email_listSigner.isEmpty()){
                    sendEmailDunningAlert(da.Id, /*sTemplate,*/ email_listSigner, sPastDueDate, sTemplate4thReminder);
                }
            }
        }
        return pgReturnPage;
    }
    
    public Pagereference CreatePdf()
    {
        
        return null;
    }
    
    public static void sendEmailDunningAlert(String idEmails, /*String iReminder,*/List<Contact> contacts, Date sPastDueDate, String sTemplate){

        List<Dunning_Alert__c> updDunningAlert = new List<Dunning_Alert__c>();
        
        Map<String,ATM_Reference__c> map_ATM = new Map<String,ATM_Reference__c>();        
        for(ATM_Reference__c ref: [Select Id, Entity__c, MB_Reference__c, Amount__c, Dunning_Alert__c From ATM_Reference__c where Dunning_Alert__c =: idEmails order by Createddate desc limit 1 ]){ 
            map_ATM.put(ref.Dunning_Alert__c, ref);
        }       
        
        EmailTemplate templateId = [Select id, Subject, HtmlValue from EmailTemplate where DeveloperName =: sTemplate]; 
   
        if(templateId != null){
            ATM_Reference__c sATM = map_ATM.get(idEmails);
            
            c_DunningAlert upd_DunnningAlert = new c_DunningAlert();      
              
            updDunningAlert.add(upd_DunnningAlert.updateDunningAlert(idEmails, sATM.Entity__c, sATM.MB_Reference__c, sPastDueDate));
  
            if(!updDunningAlert.isEmpty()){                 
                update updDunningAlert; 
            }
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[]  owe = [SELECT ID,IsAllowAllProfiles,DisplayName,Address FROM OrgWideEmailAddress WHERE IsAllowAllProfiles = TRUE LIMIT 1];
            
            for(Contact c : contacts){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();      
                
                List<String> sendTo = new List<String>();
                sendTo.add(c.Email);                
                mail.setToAddresses(sendTo);                
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setTargetObjectId(c.id);
                if (owe.size() > 0){
                   mail.setOrgWideEmailAddressId(owe.get(0).id); 
                }                 
                mail.setTemplateId(templateId.Id);
                mail.setWhatId(idEmails);                
                mail.setSaveAsActivity(true); 
                mails.add(mail);
               
            }
            
            if(!mails.isEmpty()){
                if(!Test.isRunningTest()){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);  
                }    
            }else{  
                EmailTemplate stemplateId = [Select id, Subject, HtmlValue from EmailTemplate where DeveloperName = 'AlertCollection'];
                //dosendMail(idEmails);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();      
                
                List<String> sendTo = new List<String>();
                sendTo.add('info@candor.pt');                
                mail.setToAddresses(sendTo);                
                mail.setBccSender(false);
                mail.setUseSignature(false);    
                if (owe.size() > 0){
                   mail.setOrgWideEmailAddressId(owe.get(0).id); 
                }
                mail.setTemplateId(stemplateId.Id);
                mail.setWhatId(idEmails);     
                mails.add(mail);
                
                Messaging.sendEmail( new Messaging.SingleEmailMessage[] {mail});
            }            
        }
    }   
}