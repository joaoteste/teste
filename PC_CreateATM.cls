global class PC_CreateATM {
    
    //Creates a new ATM reference directly in Payment Collection
    webservice static String getNewMBReference(String amount, ID externalId, String obs, ID pcID){
      Bill_EasyPayAPI billEasypay = new Bill_EasyPayAPI();
      Payment_Collection__c pc = [SELECT ID, Expiry_Date__c FROM Payment_Collection__c WHERE ID = :pcID];
      ATM_Reference__c atm = billEasypay.getNewMBReference(amount, pc.Expiry_Date__c, externalID, obs);
      atm.Payment_Collection__c = pcID;
      insert atm; 
      sendEmail(atm.ID);
      return 'ATM Created with Sucess and Email Was Sent!'; 
    }
    
    
    @Future(Callout = true)
    public static void sendEmail(ID atmID){
      //get PC
      ATM_Reference__c atm = [SELECT ID, ATM_Reference__c, Entity__c, Amount__c, Payment_Collection__r.Account__c   FROM ATM_Reference__c WHERE ID = :atmID];
      List<Contact> contactsList = [SELECT ID, Email FROM Contact WHERE AccountID = :atm.Payment_Collection__r.Account__c AND Email != null AND Send_Invoice__c = true];
    //get ORG Email
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@candor.pt'];  
        
        //get template
        EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'Payment_Collection_ATM_Reference' AND Folder.DeveloperName = 'System_Emails'];
        
        //create Email Message 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        //make changes
        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;         
        
        htmlBody = htmlBody.replace('MBENTITY', String.valueOf(atm.Entity__c));
        emailbody = emailbody.replace('MBENTITY', String.valueOf(atm.Entity__c));
        
        htmlBody = htmlBody.replace('MBREFERENCE', atm.ATM_Reference__c);
        emailbody = emailbody.replace('MBREFERENCE', atm.ATM_Reference__c);
         
        htmlBody = htmlBody.replace('MBVALUE', String.valueOf(atm.Amount__c));
        emailbody = emailbody.replace('MBVALUE', String.valueOf(atm.Amount__c));                


 
        //htmlbody = htmlbody.replace(']]>','');
        //htmlbody = htmlbody.replace('<![CDATA[','');   
        
        //send email
        email.setSubject(emailSubject);   
        List<String> emailsToSend = new List<String>();
        for(contact c : contactsList){
          emailsToSend.add(c.Email);   
        }
        
        email.setToAddresses(emailsToSend);
        email.setBccAddresses(new String[] {'dev_team@candor.pt', 'erodrigues@candor.pt'}); 
        email.setPlainTextBody(emailbody);
        email.setHtmlBody(htmlBody);  
        email.setWhatId(atm.Payment_Collection__r.Account__c);
        if ( owea.size() > 0 ) {
          email.setOrgWideEmailAddressId(owea.get(0).Id);
        }                      
                            
         
        try{
            if(!Test.isRunningTest())
              Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }catch(Exception e){
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'ERROR',ApplicationID__c = 'PAYMENT PLAN', message__c = 'Emails could not be sent: ' + e.getMessage(), printStackTrace__c = e.getStackTraceString()   );
            system.debug('CRITICAL: '+ record);
            insert record;                
        }
        
        
    }    
        
}