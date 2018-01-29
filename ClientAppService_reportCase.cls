public class ClientAppService_reportCase extends ClientAppService {
	public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
		super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        if( args.get('category') == null || args.get('category') == '' || args.get('reason') == null || args.get('category') == ''){
     		toReturn.put('errorCode','NULL_PARAMETERS');
            return toReturn;
        }
       
        
        Session__c session = [SELECT Login__c 
        FROM Session__c
        WHERE token__c = :sessiontoken
        ORDER BY CreatedDate LIMIT 1];

        List<Contact> contacts = [SELECT AccountId
        FROM Contact
        WHERE Login__c = :session.Login__c];
        
        Contact contact = [SELECT Id, AccountID 
                           FROM Contact 
                           WHERE Login__c = :session.Login__c];
        
      
        Case newCase = new Case();

        if(Test.isRunningTest()){
            newCase = Case_Utils.newCase('High', 'Teste', (String) args.get('category'), (String) args.get('reason'), (String) args.get('message'), null);
        }
        else{
            newCase = Case_Utils.newCase('High', 'Cliente', (String) args.get('category'), (String) args.get('reason'), (String) args.get('message'), null);
        }
       
        newCase.Subject = (String) args.get('subject');
        
        //newCase.ownerID = '00524000001jOd5';
        newCase.ContactId = contact.Id;
        newCase.AccountID = contact.AccountID;
        insert newCase;
        
        //query needed as salesforce doesn't allow imediate access to created date
        case caseCreated = [SELEct id, createdDate, Owner.firstname,Owner.lastName, CaseNumber, type,
        Description, priority, category__c, reason__c, 
        Status, subject FROM Case WHERE ID=:newCase.id];
        
        toReturn.put('caseMap', Case_Utils.caseToMap(caseCreated)); 		
       //tsendConfirmationEmail(session.Login__r.Email__c, ''+newCase.CreatedDate, newCase.CaseNumber);  
       
     	return toReturn;
   	}
  	
    private static void sendConfirmationEmail(String email, String createdDate, String caseNumber){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {email};
      
        mail.setToAddresses(toAddresses);
        mail.setSubject('New Case created on Candor Support Center: ');
        mail.setBccSender(false);
        mail.setUseSignature(false);
         
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support-no-reply@candor.pt'];
        if ( owea.size() > 0 ) {
    		mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}
        mail.setPlainTextBody('Hello \n Your Case: ' + caseNumber +' has been created. Our team will get to you as soon as possible.\n Thank you, \n Candor Support Team');
        mail.setHtmlBody('<p>Hello</p> Your case:<b> ' + caseNumber +' </b>has been created. Our team will get to you as soon as possible.<p><p>Thank you</p>,<p> Candor Support Team</p>');
        if(!Test.isRunningTest()){
	    	Messaging.reserveSingleEmailCapacity(1);
	   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
          
	}
	
	/*private static string caseToMapSerialized(ID caseId){
        Case caseReturned = [SELECT id, CaseNumber, Reason__c, Category__c, Subject, Priority, CreatedDate, Status, OwnerID, Description, Owner.FirstName, Owner.LastName FROM Case WHERE ID = :caseId];
        Map<String , String> caseMap = Case_Utils.CaseToMap(caseReturned);
        
        ClientApp_Response response = new ClientApp_Response(ClientApp_Response.status.SUCCESS);
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('casesMapList', caseMap);
        response.setDataMap(responseMap);
        //return response.generate();
        
        return JSON.serialize(caseMap, true);
    }*/	
	
}