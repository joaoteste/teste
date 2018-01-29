public class ClientAppService_getContracts extends ClientAppService{

    
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        
        /*
        //use this when contacts are migrated to MASTER account
        //get accountMaster.NIF from session
        Session__c session = [SELECT Login__r.Vendor_Vendor__r.Account.NIF__c
                              FROM Session__c WHERE token__c =: sessionToken ORDER BY CreatedDate LIMIT 1];
        
        //get accountChild from NIF and then get corresponding contracts
        List<Billing_Contract__c> billingContracts = [SELECT Id, Name, Account_Vendor__r.Name, Account_Vendor__r.NIF__c,
                                                      Account_Vendor__r.BillingStreet, Account_Vendor__r.BillingPostalCode, Account_Vendor__r.BillingCity,
                                                      Application__r.Status__c, Application__r.Payment_Amount__c, Application__r.Payment_Freq__c, Application__r.Term__c,
                                                      Application__r.Payment_Method__c, Application__c
                                                      FROM Billing_Contract__c 
                                                      WHERE Account__c IN
                                                     (SELECT Id
                                                      FROM Account
                                                      WHERE (Type = 'Customer - Channel' OR Type = 'Channel Partner / Vendor') 
                                                      AND NIF__c =: session.Login__r.Vendor_Vendor__r.Account.NIF__c)];*/
        
        Session__c session = [SELECT Login__c
        FROM Session__c
        WHERE token__c = :sessiontoken
        ORDER BY CreatedDate LIMIT 1];
        
        List<Contact> contacts = [SELECT AccountId
        FROM Contact
        WHERE Login__c = :session.Login__c];
        
        Contact contact = contacts.get(0);//temporary
        
        List<Billing_Contract__c> billingContracts = [SELECT Id, Name, Account_Vendor__r.Name, Account_Vendor__r.NIF__c,
                                                      Account_Vendor__r.BillingStreet, Account_Vendor__r.BillingPostalCode, Account_Vendor__r.BillingCity,
                                                      Application__r.Status__c, Application__r.Payment_Amount__c, Application__r.Payment_Freq__c, Application__r.Term__c,
                                                      Application__r.Payment_Method__c, Application__c
                                                      FROM Billing_Contract__c 
                                                      WHERE Account__c = :contact.AccountId];
        
        List<Map<String,Object>> contracts = new List<Map<String,Object>>();
        for(Billing_Contract__c bc : billingContracts){
            Map<String, Object> contractMap = new Map<String,Object>();
            contractMap.put('Id', bc.Id);
            contractMap.put('Name', bc.Name);
            contractMap.put('vendorName', bc.Account_Vendor__r.Name);
            contractMap.put('status', bc.Application__r.Status__c);
            contractMap.put('vendorNif', bc.Account_Vendor__r.NIF__c);
            contractMap.put('vendorStreet', bc.Account_Vendor__r.BillingStreet);
            contractMap.put('vendorPostalCode', bc.Account_Vendor__r.BillingPostalCode);
            contractMap.put('vendorCity', bc.Account_Vendor__r.BillingCity);
            contractMap.put('paymentType', bc.Application__r.Payment_Method__c);
            if(bc.Application__r.Payment_Method__c.equals('Direct Debit')){
                contractMap.put('paymentTypeShort', 'DD');
            }else if(bc.Application__r.Payment_Method__c.equals('ATM Reference')){
                contractMap.put('paymentTypeShort', 'MB');
            }
            contractMap.put('rentingApplicationId', bc.Application__c);
            
            Map<String,Object> rent = new Map<String,Object>();
            rent.put('amount', bc.Application__r.Payment_Amount__c);
            rent.put('period', bc.Application__r.Payment_Freq__c);
            rent.put('duration', bc.Application__r.Term__c);
            
            contractMap.put('rent', rent);
            contracts.add(contractMap);
        }
        
        toReturn.put('contracts',contracts);
        return toReturn;
    }
    
}