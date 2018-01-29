public class Contact_Trigger_Handler {
	
	public static void handleUpdateSet(Map<Id,Contact> oldMap, List<Contact> triggerNewList){
		system.debug('handleUpdateSet oldMap' + oldMap);
		system.debug('handleUpdateSet triggerNewList' + triggerNewList);
		
		for(Contact cont : triggerNewList){
			if(cont.Id == null || oldMap.get(cont.Id).Role__c != cont.Role__c){
				if(cont.Role__c == 'Master' || cont.Role__c == 'Binding Power'){
					cont.Send_Invoice__c = true;
				}
			}
		}
	}
	 
	public static void handleUpdateLoginEmail(Map<Id,Contact> oldMap, Map<Id,Contact> newMap){
		//get contacts that have login and changed email
		Map<String,List<Contact>> emailToContacts = new Map<String,List<Contact>>();
		for(Id newId : newMap.keySet()){
			Contact oldContact = oldMap.get(newId);
			Contact newContact = newMap.get(newId);
			if(newContact.Login__c != null && newContact.Email != null && newContact.Email != oldContact.Email){
				List<Contact> aux;
				if(emailToContacts.containsKey(newcontact.Email)){
					aux = emailToContacts.get(newContact.Email);
				}
				else{
					aux = new List<Contact>();
				}
				aux.add(newContact);
				emailToContacts.put(newContact.Email, aux);
			}
		}
		
		//get logins by email
		List<Login__c> logins = [SELECT Id, Username__c FROM Login__c WHERE Username__c IN :emailToContacts.keySet()];
		
		//if contact changed email to an email that already has a login, associate the contact to that login
		//otherwise create new login
		List<Contact> toUpdate = new List<Contact>();
		
		//associate with existing logins
		for(Login__c login : logins){
			List<Contact> aux = emailToContacts.get(login.Username__c);//contacts that changed to the same email
			for(Contact c : aux){
				Contact copy = new Contact();
				copy.Id = c.Id;
				copy.Login__c = login.Id;
				toUpdate.add(copy);
				emailToContacts.remove(login.Username__c);//remove email so that later we dont try to create a login for it
			}
		}
		
		//create new logins
		List<Login__c> createdLogins = ClientAppService_TestUtils.createLoginsForEmails(emailToContacts.keySet());
		List<Login__c> createdLoginsAux = [SELECT Id, Username__c FROM Login__c WHERE Id IN :createdLogins];
		for(Login__c created : createdLoginsAux){
			List<Contact> aux = emailToContacts.get(created.Username__c);
			for(Contact c : aux){
				Contact copy = new Contact();
				copy.Id = c.Id;
				copy.Login__c = created.Id;
				toUpdate.add(copy);
			}
		}
		
		update toUpdate;
	}
	
	public static void verifyContactLogin(Map<Id,Contact> oldMap, Map<Id,Contact> newMap){
		//can only change contact login to a login which has the contact's email
		
		Map<Id, List<Contact>> loginToContacts = new Map<Id, List<Contact>>();
		for(Id newId : newMap.keySet()){
			Contact oldContact = oldMap.get(newId);
			Contact newContact = newMap.get(newId);
			if(newContact.Login__c != null && newContact.Login__c != oldContact.Login__c){
				List<Contact> aux;
				if(loginToContacts.containsKey(newContact.Login__c)){
					aux = loginToContacts.get(newContact.Login__c);
				}
				else{
					aux = new List<Contact>();
				}
				aux.add(newContact);
				loginToContacts.put(newContact.Login__c, aux);
			}
		}
		
		List<Login__c> logins = [SELECT Id, Username__c FROM Login__c WHERE Id IN :loginToContacts.keySet()];
		for(Login__c l : logins){
			List<Contact> contacts = loginToContacts.get(l.Id);//contacts that changed to this login
			for(Contact c : contacts){
				if(c.Email != l.Username__c){
					c.addError('The contact email does not match the login email');
				}
			}
		}
	}
    
    public static void handleInvoiceableEmail(Map<Id,Contact> oldMap, Map<Id,Contact> newMap){
    	boolean changesInSendInvoice = false;
    	List<Contact> contactOld = oldMap.values();
    	
    	for(Id newId : newMap.keySet()){
    		Contact oldContact = oldMap.get(newId);
    		if(newMap.get(newId).Send_Invoice__c != oldContact.Send_Invoice__c){
    			changesInSendInvoice = true;
    		}
    	}
    	if(changesInSendInvoice){
                List<Contact> contactUpdateInfo = [SELECT ID, AccountID FROM Contact WHERE ID IN: contactOld];
                List<ID> accountsID = new List<ID>();
                for(Contact conts: contactUpdateInfo){
                    System.debug('contacts found: ' + conts.AccountID);
                    accountsID.add(conts.AccountID);
                }
                List<Account> Accounts = [SELECT ID FROM Account WHERE ID IN: accountsID];
                //gets all the contacts associated with the account, not only the ones that were changed
                List<Contact> contactsAssociatedWithAccountList = [SELECT ID, Send_Invoice__c, AccountID FROM Contact WHERE AccountID IN:Accounts];
                for(Account accs : Accounts){
                    Boolean invoiceContactActive = false;
                    for(Contact conts : contactsAssociatedWithAccountList){
                        System.debug('contact: ' + conts.id );
                        if(conts.AccountID == accs.ID && conts.Send_Invoice__c){
                            invoiceContactActive = true;            
                        }
                    }
                    if(!invoiceContactActive){
                        System.debug('Erro');
                        for(Contact contacts : newMap.values()){
                            contacts.addError('This account has no invoiceable email active, please ensure there is at least one email with \'Send Invoice\' active before applying these changes');      
                        }
                    }  
                }    
            }
    }
    
    public static void handleCreateVendorLogin(List<Contact> newValues, Map<Id,Contact> oldMap, String action){
    	for (Contact a: newValues){
    		if(action.equalsIgnoreCase('update')){
    			if( a.accountId!=null && ( a.Role__c =='Master' && (oldMap.get(a.ID).Role__c== null || oldMap.get(a.ID).Role__c==''))){
    				ContactCreation.CreateLogin( a.email, a.accountId, a.id);
    			}
    		}
    		else if(action.equalsIgnoreCase('insert')){
    			if(a.accountId!=null &&  a.Role__c =='Master'){
    				ContactCreation.CreateLogin( a.email, a.accountId, a.id);
    			}
    		}
    	}
    }
    
    
    public static void handleInsertContactPhone(List<Contact> newValues){
    	//get all accounts for contact
    	Set<ID> accountIDs = new Set<ID>();
    	for(Contact newContact : newValues){
    		if(newContact.AccountID != null)
    			accountIDs.add(newContact.AccountID);
    	}
    	
    	if(!accountIDs.isEmpty()){
	    	Map<ID, Account> accountsMap = new Map<ID, Account>([SELECT ID, BillingCountryCode FROM Account Where ID in : accountIDs]);
	    	
	    	//add dialing code
	    	for ( Contact newContact: newValues){
                if(accountsMap.containsKey(newContact.AccountID)){
                    if(newContact.MobilePhone!=null)
                        validateMobileContact(newContact, accountsMap.get(newContact.AccountID));
                     
                    if(newContact.Phone!=null)
                        validateFixContact(newContact, accountsMap.get(newContact.AccountID));
                }else{
                    insertError('AccountID: '+newContact.AccountID + '  Name: '+ newContact.Name +' - Insert Contact without Account');
                }
	    	}
    	}
    }    
    
    public static void handleUpdateContactPhone(List<Contact> oldValues, List<Contact> newValues){
    	
    	Boolean hasChanged = false;
    	
    	for(Integer i = 0; i < oldValues.size(); i++){
    		if(oldValues[i].MobilePhone != newValues[i].MobilePhone || oldValues[i].Phone != newValues[i].Phone || oldValues[i].AccountID != newValues[i].AccountID)
    			hasChanged = true;
    	}
    	
	    if(hasChanged){
	    	//get all accounts for contact
	    	Set<ID> accountIDs = new Set<ID>();
	    	for(Contact newContact : newValues)
	    		accountIDs.add(newContact.AccountID);
	    		
	    	Map<ID, Account> accountsMap = new Map<ID, Account>([SELECT ID, BillingCountryCode FROM Account Where ID in : accountIDs]);
	    	
	    	//add dialing code
	    	for ( Contact newContact: newValues){
                if(accountsMap.containsKey(newContact.AccountID)){
                    if(newContact.MobilePhone!=null)
                        validateMobileContact(newContact, accountsMap.get(newContact.AccountID));
                     
                    if(newContact.Phone!=null)
                        validateFixContact(newContact, accountsMap.get(newContact.AccountID));
                }else{
                    insertError(newContact.ID + ' - Update Contact without Account');
                }
	    	}
    	}
    }       
    
    public static void validateMobileContact(Contact c, Account acc){
    	try{
	    	Phone_Settings__mdt	phoneSizeRec = [SELECT ID, Number__c FROM Phone_Settings__mdt WHERE Country_Code__c = :acc.BillingCountryCode AND Type__c = 'Phone Size' LIMIT 1];
			Integer phoneSize = Integer.valueOf(phoneSizeRec.Number__c);
			Phone_Settings__mdt	dialingCodeRec = [SELECT ID, Number__c FROM Phone_Settings__mdt WHERE Country_Code__c = :acc.BillingCountryCode AND Type__c = 'Dialing Code' LIMIT 1];
			String dialingCode = dialingCodeRec.Number__c;	
			Integer dialingCodeSize = dialingCode.length();		
			c.MobilePhone = c.MobilePhone.replaceAll(' ','');
			if(c.MobilePhone.length() == phoneSize || c.MobilePhone.length() == (phoneSize+dialingCodeSize)){
				if(c.MobilePhone.left(dialingCodeSize) != dialingCode && c.MobilePhone.length() == phoneSize){
					c.MobilePhone = dialingCode + c.MobilePhone;
				}else if(c.MobilePhone.left(dialingCodeSize) != dialingCode){
                    insertError('AccountID: '+c.AccountID + '  Name: '+ c.LastName + ' '+ c.FirstName +'  ID:' + c.ID + ' - Contact with unknown dialing code.');
				}					
			}else{
                insertError('AccountID: '+c.AccountID + '  Name: '+ c.LastName + ' '+ c.FirstName +'  ID:' + c.ID + ' - Contact with unknown size.');                
			}
    	}catch(Exception e){
    		insertError(e.getMessage());
    	}

    }
    
    public static void insertError(String msg){
    		Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'CONTACTS',
		            																	message__c = msg);
			insert record; 	
    }
    
   
    
    public static void validateFixContact(Contact c, Account acc){
    	try{
	    	Phone_Settings__mdt	phoneSizeRec = [SELECT ID, Number__c FROM Phone_Settings__mdt WHERE Country_Code__c = :acc.BillingCountryCode AND Type__c = 'Phone Size' LIMIT 1];
			Integer phoneSize = Integer.valueOf(phoneSizeRec.Number__c);
			Phone_Settings__mdt	dialingCodeRec = [SELECT ID, Number__c FROM Phone_Settings__mdt WHERE Country_Code__c = :acc.BillingCountryCode AND Type__c = 'Dialing Code' LIMIT 1];
			String dialingCode = dialingCodeRec.Number__c;	
			Integer dialingCodeSize = dialingCode.length();		
			c.Phone = c.Phone.replaceAll(' ','');
			if(c.Phone.length() == phoneSize || c.Phone.length() == (phoneSize+dialingCodeSize)){
				if(c.Phone.left(dialingCodeSize) != dialingCode && c.Phone.length() == phoneSize){
					c.Phone = dialingCode + c.Phone;
				}else if(c.Phone.left(dialingCodeSize) != dialingCode){
                    insertError('AccountID: '+c.AccountID + '  Name: '+ c.LastName + ' '+ c.FirstName +'  ID:' + c.ID + ' - Contact with unknown dialing code.');
				}					
			}else{
                insertError('AccountID: '+c.AccountID + '  Name: '+ c.LastName + ' '+ c.FirstName +'  ID:' + c.ID + ' - Contact with unknown size.');                
			}
    	}catch(Exception e){
    		insertError(e.getMessage()+'\n'+e.getStackTraceString());
    	}

    }  

}
