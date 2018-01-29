global class Bill_Moloni_EmailAndPdf_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
	
	private OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@candor.pt'];
	private EmailTemplate templateStandard = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'Sales_Invoice_Standard' AND Folder.DeveloperName = 'Invoice_Credit_Note_Email_Template'];
	private EmailTemplate templateMB = 	[SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'Sales_Invoice_Standard_MB' AND Folder.DeveloperName = 'Invoice_Credit_Note_Email_Template'];
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT ID, Invoice_express_Link__c, first_atm__c, first_atm__r.Entity__c, first_atm__r.ATM_Reference__c, first_atm__r.Amount__c, Invoice_Express_Number_text__c,  Name,Invoice_Email_Status__c, c2g__Account__r.name, Application__r.Client_Signer_1__r.name, c2g__Account__r.c2g__CODAInvoiceEmail__c  FROM c2g__codaInvoice__c WHERE Invoice_Email_Status__c = \'To be send\' LIMIT '; 
        Limits_For_Batch__c maxEmailsConfig; 
        Integer maxEmails; 
        if(Test.isRunningTest()) query += '1'; else{ 
            maxEmailsConfig = Limits_For_Batch__c.getInstance('SendInvoiceEmailsMaxPerBatch'); 
            maxEmails = (Integer) maxEmailsConfig.Max__c; 
            query+= +maxEmails; 
        } 
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__codaInvoice__c> salesInvoiceList){
        //JG - 17/11/2017
        Set<Id> AccountsIds = new Set<Id>();	   
        For(c2g__codaInvoice__c invoi: salesInvoiceList){
        	AccountsIds.add(invoi.c2g__Account__c);
        }
        Map<ID, Account> accountMap = new Map<ID, Account>([SELECT ID,(Select Email From Contacts WHERE Send_Invoice__c = true AND Email != null) FROM Account WHERE ID IN: AccountsIds]);
        
        
    	Boolean error = false;
    	Map<c2g__codaInvoice__c,Attachment> attachmentsMap = new Map<c2g__codaInvoice__c,Attachment>();
    	List<Outbound_Integration_Log__c> problems = new List<Outbound_Integration_Log__c>();
    	//get attchment List
    	for(c2g__codaInvoice__c si : salesInvoiceList){
    		String url = si.Invoice_express_Link__c;
    		String fileName = 'Factura ' + si.Name + datetime.now();
    		ID siID = si.ID;
    		Attachment att = Bill_Moloni_Util.getPDF(url, fileName, siID);
    		if(att!=null){
    			attachmentsMap.put(si, att);
    		}else{
	            //if match failed an email is sent after the outbound integration log is created
	            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c();
	            record.Start__c=system.today();
	            record.Code__c = 'CRITICAL';
	            record.ApplicationID__c = 'MOLONI';
	            record.message__c = 'Attchment could be not be reached. SalesInvoice:'+si.ID;
	            system.debug('CRITICAL: '+ record);
	            problems.add(record);
    		}
    	}    	    	
    	
    	insert problems;
    	
    	insert attachmentsMap.values();
    	
    	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    	
    	//create All Emails to Sales Invoice
    	for(c2g__codaInvoice__c si : salesInvoiceList){
    		if(attachmentsMap.containsKey(si)){
    			Attachment attach = attachmentsMap.get(si);
    			String invoiceNumber = si.Invoice_Express_Number_text__c;
    			Messaging.SingleEmailMessage email;
    			if(si.first_atm__c !=null)
    				email = createEmailWithInvoice(si, attach, invoiceNumber, templateMB, accountMap.get(si.c2g__Account__c));
    			else
    				email = createEmailWithInvoice(si, attach, invoiceNumber, templateStandard, accountMap.get(si.c2g__Account__c));
    			emails.add(email);
    		}
    	}
    	
    	if (!Test.isRunningTest()) {
    		try{
    			
		        Messaging.sendEmail(emails, true);
		        system.debug(emails);
    		}catch(Exception e){
	            //if match failed an email is sent after the outbound integration log is created
	            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c();
	            record.Start__c=system.today();
	            record.Code__c = 'CRITICAL';
	            record.ApplicationID__c = 'MOLONI';
            	record.message__c = 'Emails could not be sent: ' + e.getMessage();
            	record.printStackTrace__c = e.getStackTraceString();
	            system.debug('CRITICAL: '+ record);
	            insert record;  
	            error=true; 			
    		}
        }
    	
    	if(!error){
	    	List<c2g__codaInvoice__c> updateSalesInvoiceSatus = new List<c2g__codaInvoice__c>();
	    	for(c2g__codaInvoice__c si : attachmentsMap.keySet()){
	            si.Invoice_Email_Status__c = 'Sent'; 
	            updateSalesInvoiceSatus.add(si);
	        }
	        
	        update updateSalesInvoiceSatus;
    	}

    }
    
    global void finish(Database.BatchableContext BC){
        
    }	
    
    public Messaging.SingleEmailMessage createEmailWithInvoice(c2g__codainvoice__c invoice, Attachment attach, String invoiceNumber){
        Account acc = [SELECT ID,(Select Email From Contacts WHERE Send_Invoice__c = true) FROM Account WHERE ID =:invoice.c2g__Account__c];
        if(invoice.first_atm__c != null)
    		return createEmailWithInvoice(invoice, attach, invoiceNumber, templateMB, acc);
    	else
    		return createEmailWithInvoice(invoice, attach, invoiceNumber, templateStandard, acc);
    }
    
    
    public Messaging.SingleEmailMessage createEmailWithInvoice(c2g__codainvoice__c invoice, Attachment attach, String invoiceNumber, EmailTemplate template, Account Acc){
        system.debug('SendEmailwithInvoice');

        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;

        emailSubject = emailSubject.replace('{!c2g__codaInvoice__c.Invoice_Express_Number_text__c}', invoiceNumber);
        
        emailbody = emailbody.replace('{!c2g__codaInvoice__c.Invoice_Express_Number_text__c}', invoiceNumber);
        htmlBody=htmlBody.replace('{!c2g__codaInvoice__c.Invoice_Express_Number_text__c}', invoiceNumber);
        
        emailbody = emailbody.replace('{!Account.Name}', invoice.c2g__Account__r.name);
        htmlBody=htmlBody.replace('{!Account.Name}', invoice.c2g__Account__r.name);
        
        emailbody = emailbody.replace('{!c2g__codaInvoice__c.Id}', invoice.id);
        htmlBody=htmlBody.replace('{!c2g__codaInvoice__c.Id}', invoice.id);
        
        if(invoice.Application__c == null || invoice.Application__r.Client_Signer_1__r == null){
            emailbody = emailbody.replace('{!Contact.FirstName}', ' ');    
            htmlBody=htmlBody.replace('{!Contact.FirstName}', ' ');

        }else{
            emailbody = emailbody.replace('{!Contact.FirstName}', invoice.Application__r.Client_Signer_1__r.name);    
            htmlBody=htmlBody.replace('{!Contact.FirstName}', invoice.Application__r.Client_Signer_1__r.name);

        }
        
        if(template.DeveloperName == 'Sales_Invoice_Standard_MB'){
        	
        	//FIX ME - soluçao temp - perceber pq e colocado um .0 qdo a invoice vem do batch
        	String entidade = String.valueOf(invoice.first_atm__r.Entity__c).substring(0,5);
	        emailbody = emailbody.replace('ACEntity', entidade);
	        htmlBody=htmlBody.replace('ACEntity', entidade);        	
	        
	        emailbody = emailbody.replace('ACReference', String.valueOf(invoice.first_atm__r.ATM_Reference__c));
	        htmlBody=htmlBody.replace('ACReference', String.valueOf(invoice.first_atm__r.ATM_Reference__c));    
	        
	        emailbody = emailbody.replace('ACAmount', String.valueOf(invoice.first_atm__r.Amount__c));
	        htmlBody=htmlBody.replace('ACAmount', String.valueOf(invoice.first_atm__r.Amount__c));    	        	        
        }
        
        htmlBody=htmlBody.replace(']]>', '');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();    
        String[] toAddresses = new List<String>();
        if(!Utilities.runningInASandbox()){  //Production
            //JG - 17/11/2017
            //The contact queried have the send_invoice__c signaled as true
            For(Contact cont: Acc.Contacts){
                toAddresses.add(cont.email);
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