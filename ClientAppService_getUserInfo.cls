public class ClientAppService_getUserInfo extends ClientAppService{

    
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
                              
        Session__c session = [SELECT Login__c, Login__r.Username__c
        FROM Session__c
        WHERE token__c = :sessiontoken
        ORDER BY CreatedDate LIMIT 1];
        
        List<Contact> contacts = [SELECT Id, AccountId, Name, Account.Name
        FROM Contact
        WHERE Login__c = :session.Login__c];
        
        Contact contact = contacts.get(0);//temporary
        
        toReturn.put('loginId', session.Login__c);
        toReturn.put('contactId', contact.Id);
        toReturn.put('accountId', contact.AccountId);
        toReturn.put('username', session.Login__r.Username__c);
        toReturn.put('name', contact.Name);
        toReturn.put('accountName', contact.Account.Name);
        
        return toReturn;
    }
    
}