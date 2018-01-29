global class ACT_BH_MoveContacts implements Database.Batchable<sObject>, Database.Stateful{
	List<ID> accountID;
    global List<String> accountsNotUpdated = new List<String>();  
    User fred = [SELECT id FROM User WHERE ID ='00524000003q9KO'];
    User celia = [SELECT ID FROM User WHERE ID = '00524000001jOd5'];
    global ACT_BH_MoveContacts(List<ID> accountID){
        this.accountID = accountID;
    }
    //(SELECT ID, Vendor__c FROM Reports_DB__r), (SELECT ID, AccountId FROM Contacts) 
	global Database.QueryLocator start(Database.BatchableContext BC){ 

        String query = 'SELECT ID, PArentID, (SELECT ID, Owner.IsActive, OwnerID FROM Contacts) FROM Account WHERE ID in :accountID';

        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        
        List<Contact> contactList = new List<Contact>();
        system.debug(Limits.getQueries());
        try{
            for(Account acc : accountList){
                system.debug('Processing account: '+acc.ID);

                for(Contact c : acc.Contacts){
                    system.debug('processing contact: '+c.ID);
                    if(c.Owner.IsActive == false){
                        c.OwnerID = celia.ID;
                    }
                    if(acc.ParentID != null) 
                        c.AccountID = acc.ParentId;
                    system.debug('processing contact: '+c.ID);
                    contactList.add(c);
                }
            }
            system.debug(contactList);
            if(!contactList.isEmpty()) update contactList;
        }catch(Exception e){
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Code__c = 'ACCOUNTS',
                                                                                        message__c = e.getMessage() + ' ' + e.getStackTraceString()
                                                                                        );        
            insert record;            
        }
        system.debug(Limits.getQueries());

    }
    
        
    global void finish(Database.BatchableContext BC){

    }    
    
}