global class PP_SendEmailProposal {

    webservice static String execute(ID ppID){
        //get ORG Email
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@candor.pt'];  
        
        //get pp
        Payment_Plan__c pp = [SELECT ID, Name, Contact__r.Email, Contact__r.Name, Account__c, Payments_Table__c FROM Payment_Plan__c WHERE ID = :ppID];
        
        //get template
        EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'Payment_Plan_Acceptance' AND Folder.DeveloperName = 'Collections'];
        
        //create Email Message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        //make changes
        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;        
        
        emailSubject = emailSubject.replace( '{!Account.Name}', pp.Name);
        
        emailbody = emailbody.replace('{!Contact.Name}', pp.Contact__r.Name);
        htmlBody=htmlBody.replace('{!Contact.Name}', pp.Contact__r.Name);            

        emailbody = emailbody.replace('{!Payment_Plan__c.Payments_Table__c}', pp.Payments_Table__c);
        htmlBody=htmlBody.replace('{!Payment_Plan__c.Payments_Table__c}', pp.Payments_Table__c);    

        htmlbody = htmlbody.replace(']]>','');
        htmlbody = htmlbody.replace('<![CDATA[','');   
        
        //send email
        email.setSubject(emailSubject);
        email.setToAddresses(new String[] {pp.Contact__r.Email});
        email.setBccAddresses(new String[] {'dev_team@candor.pt', 'erodrigues@candor.pt'}); 
        email.setPlainTextBody(emailbody);
        email.setHtmlBody(htmlBody);  
        email.setWhatId(ppID);
        if ( owea.size() > 0 ) {
        	email.setOrgWideEmailAddressId(owea.get(0).Id);
        }                      
                            
        
        try{
            if(!Test.isRunningTest())
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            return 'Email Sent With Success!';
        }catch(Exception e){
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'ERROR',ApplicationID__c = 'PAYMENT PLAN', message__c = 'Emails could not be sent: ' + e.getMessage(), printStackTrace__c = e.getStackTraceString()   );
            system.debug('CRITICAL: '+ record);
            insert record;   
            return 'Email not sent, please contact the support team.';                 
        }
        
        return 'Contact Support Team - Email not Sent.';
        
    }
    
}
