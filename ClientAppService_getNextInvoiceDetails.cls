public class ClientAppService_getNextInvoiceDetails extends ClientAppService{
    
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
        Account account = [SELECT Id
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
        
        List<Map<String,Object>> invoiceDetailsList = Utils_GetInvoiceDetails.getInvoiceDetails(contact.AccountId);
        if(invoiceDetailsList == null){
            toReturn.put('errorCode','NO_CONTRACTS_FOUND');
            return toReturn;
        }
        invoiceDetailsList = ClientAppService_Utils.orderByDateField(invoiceDetailsList, 'endDate');
        toReturn.put('invoiceDetails',invoiceDetailsList);
        
        return toReturn;
    }
}