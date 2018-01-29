global class Login_Factory implements Database.Batchable<sObject>{
	
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator('SELECT Id, Email FROM Contact '+
		'WHERE Login__c = null AND Email != null AND Id IN '+
		'(SELECT Client_Signer_1__c '+
		'FROM Application__c '+
		'WHERE Client_Signer_1__c != null '+
		'AND Status__c Like \'Contract - %\' AND Cancelled__c = false)');
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
    	generateLoginsForSigners1(scope);
    }

    global void finish(Database.BatchableContext bc) {

    }
	
	webservice static String generateLoginForContact(Id contactId){
		List<Contact> aux = [SELECT Id, Email FROM Contact WHERE Id = :contactId];
		generateLoginsForSigners1(aux);
		return 'Success';
	}
	
	public static void generateLoginsForSigners1(List<Contact> contactList){		
		//get all emails from signer
		Map<String, List<Contact>> emailToContacts = new Map<String, List<Contact>>();
		for(Contact c : contactList){
			List<Contact> aux;
			if(emailToContacts.containsKey(c.Email)){
				aux = emailToContacts.get(c.Email);
			}
			else{
				aux = new List<Contact>();
			}
			aux.add(c);
			emailToContacts.put(c.Email, aux);
		}
		
		system.debug('ZZZZZ unique emails '+emailToContacts.size());
		
		//get all logins from signers' email
		List<Login__c> logins = [SELECT Id, Username__c FROM Login__c WHERE Inactive__c = false AND Username__c IN :emailToContacts.keySet()];
		
		system.debug('ZZZZZ existing logins for those emails '+logins.size());
		
		Map<String, Id> emailToLogin = new Map<String,Id>();
		for(Login__c l : logins){
			emailToLogin.put(l.Username__c, l.Id);
		}
		
		//if exists login for contact email, associate contact with that login
		//else create a new login obj
		Set<String> toCreate = new Set<String>();
		List<Contact> toUpdate = new List<Contact>();		
		for(String email : emailToContacts.keySet()){
			List<Contact> contacts = emailToContacts.get(email);
			if(emailToLogin.containsKey(email)){
				Id loginId = emailToLogin.get(email);
				for(Contact c : contacts){
					c.Login__c = loginId;
					toUpdate.add(c);
				}
			}
			else{
				toCreate.add(email);
			}
		}
		
		system.debug('ZZZZZ to update antes criar '+toUpdate.size());
		system.debug('ZZZZZ to create '+toCreate.size());
		
		//create new logins
		List<Login__c> createdLogins = ClientAppService_TestUtils.createLoginsForEmails(toCreate);
		List<Login__c> createdLoginsAux = [SELECT Id, Username__c FROM Login__c WHERE Id IN :createdLogins];
		for(Login__c l : createdLoginsAux){
			
			List<Contact> aux = emailToContacts.get(l.Username__c);
			for(Contact c : aux){
				c.Login__c = l.Id;
				toUpdate.add(c);
			}
		}
		
		system.debug('ZZZZZ to update depois criar '+toUpdate.size());
		update toUpdate;
	}
    
}