global class ACT_BH_CreateParentAccount implements Database.Batchable<sObject>{
	List<ID> accountID;
    List<String> accountsNotUpdated = new List<String>();  
    
    global ACT_BH_CreateParentAccount(List<ID> accountID){
        this.accountID = accountID;
    }
    //(SELECT ID, Vendor__c FROM Reports_DB__r), (SELECT ID, AccountId FROM Contacts) 
	global Database.QueryLocator start(Database.BatchableContext BC){ 

        String query = 'SELECT ID, NIF__c, Name, Phone, Type, BillingCountryCode, PArentID, Email__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Website FROM Account WHERE ID in :accountID';

        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        
        List<Account> newAccountsList = new List<Account>();
        system.debug(Limits.getQueries());
        try{
            for(Account acc : accountList){
                if(acc.ParentID == null && acc.Type != 'Account Master'){
                    //verificar se já existe conta para este NIF
                    String finalNIF;
                    if(acc.NIF__c.length() == 9){
                        finalNIF = acc.NIF__c;
                    }else{
                        finalNIF = acc.NIF__c.right(9);
                    }
                    
                    List<Account> masterAccountList = new List<Account>([SELECT ID FROM Account WHERE NIF__c = :finalNIF AND Type = 'Account Master']);
                    Account masterAccount;
                    
                    if(masterAccountList.size() == 0){
                        masterAccount = new Account();
                        masterAccount.Type = 'Account Master';
                        masterAccount.BillingStreet = acc.BillingStreet;                
                        masterAccount.BillingCity = acc.BillingCity;
                        masterAccount.BillingState = acc.BillingState;                
                        masterAccount.BillingPostalCode = acc.BillingPostalCode;
                        masterAccount.BillingCountry = acc.BillingCountry;
                        masterAccount.BillingCountryCode = acc.BillingCountryCode;
                        masterAccount.Website = acc.Website;
                        masterAccount.Phone = acc.Phone;
                        masterAccount.Email__c = acc.Email__c;
                        masterAccount.Name = acc.Name;                
                        masterAccount.NIF__c = finalNIF;     
                        
                        insert masterAccount;                
                    }else if(masterAccountList.size() == 1){
                        masterAccount = masterAccountList[0];
                    }
                    
                    if(masterAccount != null){
        
                        acc.NIF__c = finalNIF;
                        acc.ParentId = masterAccount.ID;
                        
                        if(acc.Type == 'Channel Partner / Vendor'){
                            if(acc.BillingStreet != null)
                                masterAccount.BillingStreet = acc.BillingStreet;    
                            if(acc.BillingCity != null)
                                masterAccount.BillingCity = acc.BillingCity;
                            if(acc.BillingState != null)
                                masterAccount.BillingState = acc.BillingState;                
                            if(acc.BillingPostalCode != null)
                                masterAccount.BillingPostalCode = acc.BillingPostalCode;
                            if(acc.BillingCountry != null)
                                masterAccount.BillingCountry = acc.BillingCountry;
                            if(acc.BillingCountryCode != null)
                                masterAccount.BillingCountryCode = acc.BillingCountryCode;
                            if(acc.Website != null)
                                masterAccount.Website = acc.Website;
                            if(acc.Phone != null)
                                masterAccount.Phone = acc.Phone;
                            if(acc.Email__c != null)
                                masterAccount.Email__c = acc.Email__c;
                            if(acc.Name != null)
                                masterAccount.Name = acc.Name;
                            update masterAccount;
                        }
                                                                         
                    }else{
                        accountsNotUpdated.add(acc.ID);
                    } 
                    update acc;
                }
            }
        }catch(Exception e){
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Code__c = 'ACCOUNTS',
                                                                                        message__c = e.getMessage() + ' ' + e.getStackTraceString()
                                                                                        );        
            insert record;            
        }
        system.debug(Limits.getQueries());

    }
    
        
    global void finish(Database.BatchableContext BC){
		Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Code__c = 'ACCOUNTS',
                                                                                    message__c = 'NotCompleted '+String.valueOf(accountsNotUpdated)
                                                                                    );        
        insert record;
    }    
    
}