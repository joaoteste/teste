global class PP_BH_CollectionReminder implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
	
	global List<ID> smsAuxList = new List<ID>();	
    
	global Database.QueryLocator start(Database.BatchableContext BC){ 

        String query = 'SELECT Id, Payment_Plan__c, Schedule_Number__c, Due_Date__c, Payment_Plan__r.Contact__r.Email, Payment_Plan__r.Contact__r.FirstName, Payment_Plan__r.Contact__r.LastName, Payment_Plan__r.Contact__r.MobilePhone,Payment_Plan__r.Collection_Case__c, Payment_Plan__r.Name, ATM__r.Amount__c, ATM_Entity__c, ATM_Reference__c FROM '+
                          'Payment_Schedule__c where Payment_Plan__r.Status__c = \'Open\' AND Due_Date__c < TODAY AND Payment_Status__c = \'In Payment\'';
		if(Test.isRunningTest()) query+=' LIMIT 1';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Payment_Schedule__c> psList){

		for(Payment_Schedule__c ps : psList){
			if(ps.Due_Date__c.addDays(1) == system.today()){
				//Email
				sendEmail(ps);
				
				if(ps.Payment_Plan__r.Contact__r.MobilePhone != null) smsAuxList.add(ps.ID);
			}else{
				if(ps.Due_Date__c.addDays(5) == system.today() || ps.Due_Date__c.addDays(10) == system.today()){
					sendEmail(ps);
				}
			}
		}
        
    } 
    
    global void finish(Database.BatchableContext BC){ 
        Database.executeBatch(new PP_BH_CollectionCall(smsAuxList),1);
    }
    

    
    public static void sendEmail(Payment_Schedule__c ps){
    	OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@candor.pt'];  
        EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'Payment_Plan_Collection' AND Folder.DeveloperName = 'Collections'];
        
        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;
        
        String name;
        if(ps.Payment_Plan__r.Contact__r.FirstName != null) name = ps.Payment_Plan__r.Contact__r.FirstName + ' ' + ps.Payment_Plan__r.Contact__r.LastName;
        else name = ps.Payment_Plan__r.Contact__r.LastName;
        emailbody = emailbody.replace('{!Contact.Name}', name);
        htmlBody=htmlBody.replace('{!Contact.Name}', name);            
             
        emailbody = emailbody.replace('{!Entidade}', String.valueOf(ps.ATM_Entity__C).left(5));
        htmlBody=htmlBody.replace('{!Entidade}', String.valueOf(ps.ATM_Entity__C).left(5));        
        
        emailbody = emailbody.replace('{!Referencia}', String.valueOf(ps.ATM_Reference__c));
        htmlBody=htmlBody.replace('{!Referencia}', String.valueOf(ps.ATM_Reference__c));   
        
        emailbody = emailbody.replace('{!Montante}', String.valueOf(ps.Atm__r.Amount__c));
        htmlBody=htmlBody.replace('{!Montante}', String.valueOf(ps.Atm__r.Amount__c));              
        
        emailbody = emailbody.replace('{!DueDate}', String.valueOf(String.valueOf(ps.Due_Date__c.addDays(15)).left(10)));
        htmlBody = htmlBody.replace('{!DueDate}', String.valueOf(String.valueOf(ps.Due_Date__c.addDays(15)).left(10)));

        htmlBody=htmlBody.replace(']]>', '');
            
        String[] toAddresses = new List<String>();
        if(!Utilities.runningInASandbox()){  //Production
            toAddresses.add(ps.Payment_Plan__r.Contact__r.Email);
        }

        String[] bccAddresses = new List<String>();
        bccAddresses.add('erodrigues@candor.pt');
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        email.setBccAddresses(bccAddresses);
        email.setPlainTextBody(emailbody);
        email.setHtmlBody(htmlBody);        
        email.setWhatID(ps.Payment_Plan__c);             
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }  
        
        if (!Test.isRunningTest()) {
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }, true);
                system.debug(email);
            }catch(Exception e){
                //if match failed an email is sent after the outbound integration log is created
                Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'CRITICAL',ApplicationID__c = 'PAYMENT PLAN', message__c = 'Emails could not be sent: ' + e.getMessage(), printStackTrace__c = e.getStackTraceString()   );
                system.debug('CRITICAL: '+ record);
                insert record;         
            }
        }  
            	
    }
    
}