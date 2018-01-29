public class ClientAppService_getAccountInfo extends ClientAppService{

    
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        
        /*
        //TODO :: use this when contacts are migrated to MASTER account
        //get accountMaster.NIF from session
        Session__c session = [SELECT Login__r.Vendor_Vendor__r.Account.NIF__c
                              FROM Session__c WHERE token__c =: sessionToken ORDER BY CreatedDate LIMIT 1];
        
        //get child account from masterNif, and then get respective info
        Account account = [SELECT Id, Credit_line__c, Available_Credit_line__c, Used_Credit_line__c
                           FROM Account
                           WHERE (Type = 'Customer - Channel' OR Type = 'Channel Partner / Vendor') 
                           AND NIF__c =: session.Login__r.Vendor_Vendor__r.Account.NIF__c];*/
        
        Session__c session = [SELECT Login__c
        FROM Session__c
        WHERE token__c = :sessiontoken
        ORDER BY CreatedDate LIMIT 1];
        
        List<Contact> contacts = [SELECT AccountId
        FROM Contact
        WHERE Login__c = :session.Login__c];
        
        Contact contact = contacts.get(0);//temporary
        
        Account account = [SELECT Id, Credit_line__c, Available_Credit_line__c, Used_Credit_line__c
                           FROM Account
                           WHERE (Type = 'Customer - Channel' OR Type = 'Channel Partner / Vendor') 
                           AND Id = :contact.AccountId];
        
        toReturn.put('accountId', account.Id);
        toReturn.put('creditLine', account.Credit_line__c);
        toReturn.put('availableCredit', account.Available_Credit_line__c);
        toReturn.put('usedCredit', account.Used_Credit_line__c);
        
        return toReturn;
    }
    
}