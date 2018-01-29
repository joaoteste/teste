public class ClientAppService_getLatePayment extends ClientAppService{

    
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        
        /*
        //use this when contacts are migrated to MASTER account
        //get acountMaster.NIF from session
        Session__c session = [SELECT Login__r.Vendor_Vendor__r.Account.NIF__c
                              FROM Session__c WHERE token__c =: sessionToken ORDER BY CreatedDate LIMIT 1];
        
        //get child accounts' Ids from masterNIF
        Map<Id,Account> accounts = new Map<Id,Account> ([SELECT Id
                                                         FROM Account
                                                         WHERE (Type = 'Customer - Channel' OR Type = 'Channel Partner / Vendor')
                                                         AND NIF__c =: session.Login__r.Vendor_Vendor__r.Account.NIF__c]);*/
        
        Session__c session = [SELECT Login__c
        FROM Session__c
        WHERE token__c = :sessiontoken
        ORDER BY CreatedDate LIMIT 1];
        
        List<Contact> contacts = [SELECT AccountId
        FROM Contact
        WHERE Login__c = :session.Login__c];
        
        Contact contact = contacts.get(0);//temporary
        
        //get corresponding dunning info from account
        List<Dunning_Alert__c> dunnings = [SELECT Id, Amount_Claimed__c, Aux_Entity__c, Aux_Reference__c, Dunning_Level__c
                                           FROM Dunning_Alert__c
                                           WHERE Status__c = 'Open' AND Collection_Case__r.Status__c = 'Open'
                                           AND Collection_Case__r.Account__c = :contact.AccountId
                                           ORDER BY Dunning_Level__c DESC];
        
        if(dunnings.size() == 0){
            toReturn.put('errorCode','NO_DUNNING_FOUND');
            return toReturn;
        }
        
        //I was told there would only be one Open CollectionCase at a time so....
        Dunning_Alert__c dunning = dunnings.get(0);
        toReturn.put('id',dunning.Id);
        toReturn.put('amount',dunning.Amount_Claimed__c);
        toReturn.put('entity',dunning.Aux_Entity__c);
        toReturn.put('reference',dunning.Aux_Reference__c);
        toReturn.put('level',dunning.Dunning_Level__c);
        return toReturn;
    }
    
}