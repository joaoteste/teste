global class Bill_Moloni_EPDFCreditNotes_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
	
	private OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@candor.pt'];
	private EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'Sales_Credit_Note_Standard' AND Folder.DeveloperName = 'Invoice_Credit_Note_Email_Template'];

	global Database.QueryLocator start(Database.BatchableContext BC){
   	 	    
   	    String query = 'SELECT ID, Credit_Note_Link__c, External_Credit_Note_Number_text__c,  Name, CreditNote_Email_Status__c, c2g__Account__r.name, c2g__Invoice__r.Application__r.Client_Signer_1__r.name, c2g__Account__r.c2g__CODAInvoiceEmail__c, c2g__Invoice__r.Invoice_Express_Number_text__c  FROM c2g__codaCreditNote__c WHERE CreditNote_Email_Status__c = \'To be send\' ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__codaCreditNote__c> creditNotesList){
		//JG - 17/11/2017
        Set<Id> AccountsIds = new Set<Id>();	   
        For(c2g__codaCreditNote__c invoi: creditNotesList){
        	AccountsIds.add(invoi.c2g__Account__c);
        }
        Map<ID, Account> accountMap = new Map<ID, Account>([SELECT ID,(Select Email From Contacts WHERE Send_Invoice__c = true AND Email != null) FROM Account WHERE ID IN: AccountsIds]);
		//end
        
        Map<c2g__codaCreditNote__c,Attachment> attachmentsMap = new Map<c2g__codaCreditNote__c,Attachment>();
        List<Outbound_Integration_Log__c> problems = new List<Outbound_Integration_Log__c>();        
        try{
            //get attchment List
            for(c2g__codaCreditNote__c cn : creditNotesList){
                String url = cn.Credit_Note_Link__c;
                String fileName = 'Factura ' + cn.Name + datetime.now();
                ID cnID = cn.ID;
                Attachment att = Bill_Moloni_Util.getPDF(url, fileName, cnID);
                if(att!=null){
                    attachmentsMap.put(cn, att);
                }else{
                    //if match failed an email is sent after the outbound integration log is created
                    Outbound_Integration_Log__c record = new Outbound_Integration_Log__c();
                    record.Start__c=system.today();
                    record.Code__c = 'CRITICAL';
                    record.ApplicationID__c = 'MOLONI';
                    record.message__c = 'Attchment could be not be reached. CreditNote:'+cn.ID;
                    system.debug('CRITICAL: '+ record);
                    problems.add(record);
                }
            }    	    	
            
            insert problems;
            
            insert attachmentsMap.values();
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            //create All Emails to Sales Invoice
            for(c2g__codaCreditNote__c cn : creditNotesList){
                if(attachmentsMap.containsKey(cn)){
                    Attachment attach = attachmentsMap.get(cn);
                    String invoiceNumber = cn.External_Credit_Note_Number_text__c;
                    Messaging.SingleEmailMessage email = createEmailWithCreditNote(cn, attach, invoiceNumber, accountMap.get(cn.c2g__Account__c));
                    emails.add(email);
                }
            }
            
            if (!Test.isRunningTest()) {    			
                    Messaging.sendEmail(emails, true);
                    system.debug(emails);
            }
    	}catch(Exception e){
	            //if match failed an email is sent after the outbound integration log is created
	            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c();
	            record.Start__c=system.today();
	            record.Code__c = 'CRITICAL';
	            record.ApplicationID__c = 'MOLONI';
            	record.message__c = 'Credit Notes Emails could not be sent: ' + e.getMessage();
            	record.printStackTrace__c = e.getStackTraceString();
	            system.debug('CRITICAL: '+ record);
	            insert record; 
            	return;
    	}
    	
    	//set invoice updated - should be checked if the emails were sent?
    	List<c2g__codaCreditNote__c> updateCreditNotesStatus = new List<c2g__codaCreditNote__c>();
    	for(c2g__codaCreditNote__c cn : attachmentsMap.keySet()){
            cn.CreditNote_Email_Status__c = 'Sent'; 
            updateCreditNotesStatus.add(cn);
        }
        
        update updateCreditNotesStatus;

    }
    
    global void finish(Database.BatchableContext BC){
        
    }	
    
    private Messaging.SingleEmailMessage createEmailWithCreditNote(c2g__codaCreditNote__c creditNote, Attachment attach, String creditNoteNumber, Account Acc){
        system.debug('SendEmailwithCreditNote');

        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;

        emailSubject = emailSubject.replace('{!c2g__codaCreditNote__c.Name}', creditNoteNumber);
        
        if(creditNote.c2g__Invoice__r.Application__r == null || creditNote.c2g__Invoice__r.Application__r.Client_Signer_1__r == null){
            emailbody = emailbody.replace('{!Contact.Name}', ' ');      
            htmlBody=htmlBody.replace('{!Contact.Name}', ' ');
        }else{
            emailbody = emailbody.replace('{!Contact.Name}', creditNote.c2g__Invoice__r.Application__r.Client_Signer_1__r.name);      
            htmlBody=htmlBody.replace('{!Contact.Name}', creditNote.c2g__Invoice__r.Application__r.Client_Signer_1__r.name);
        }
        
        htmlBody=htmlBody.replace('--Invoice Number--', creditNote.c2g__Invoice__r.Invoice_Express_Number_text__c);
        htmlBody=htmlBody.replace(']]>', '');

        String[] toAddresses = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        if(!Utilities.runningInASandbox()){  //Production
            //The contact queried has the send_invoice__c signaled as true
            For(Contact cont: Acc.Contacts){
                toAddresses.add(cont.email);
                //setTargetObjcectId insures that the emails sent does not count for email limit
                email.setTargetObjectId(cont.id);
            }
        }

		String[] bccAddresses = new List<String>();
        bccAddresses.add('dev_team@candor.pt');

        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        email.setBccAddresses(bccAddresses);
        email.setPlainTextBody(emailbody);
        email.setHtmlBody(htmlBody);
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
       
        Bill_Moloni_Util.addAttchment(email, attach);

        return email;
    }    
}