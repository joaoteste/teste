public class Utils_getDebtInforForClient {
     /* 
     * Returns the in debt of a given accountID.
     */
    public static double debtForClient(ID accountID){
        //gets the collection case of the given ID
        list<Collection_Case__c> ccList = [SELECT Amount_Claimed__c FROM Collection_Case__c WHERE Account__c =: accountID AND Status__c ='Open' ];
        if(ccList.isEmpty() || ccList.size() > 1)
            return null;
        //the system cant have more than one collection case open
        return ccList[0].Amount_Claimed__c;
    }
    /*
     * Given an account it returns the ATM reference details in a Map<String, String>:
     * Key - entity - The entity of the atm reference.
     * Key - atmRef - The atm reference if it exists, if not, it provides MB Reference.
     * Key - debt - Amount in debt.
     */
    public static Map<String, String> getAtmDetailsForAccount(ID accountID){
        Map<String, String> atmDetailsMap = new Map<String, String>();
        
        //Gets the collection case associated with the given account.
        list<Collection_Case__c> ccList = [SELECT ID FROM Collection_Case__c WHERE (Account__c =: accountID AND Status__c ='Open') ];
        System.debug('ccList');
        if(ccList.isEmpty() || ccList.size() > 1)
            return null;
        System.debug('One collection case');
        //Gets the dunning alert associated with the collection case.
        list<Dunning_Alert__c> daList = [SELECT ID FROM Dunning_Alert__c WHERE Collection_Case__c = :ccList[0].ID AND Status__c ='Open' ];
        
        if(daList.isEmpty() || daList.size() > 1)
            return null;
        System.debug('One dunning alert');
        //Gets the reference list associated with the dunning alert.
        
        list<ATM_Reference__c> atmRefList = [SELECT  Entity__c, ATM_Reference__c, MB_Reference__c, Amount__c FROM ATM_Reference__c WHERE Dunning_Alert__c = :daList[0].ID ];
        
        if(atmRefList.isEmpty() || atmRefList.size() > 1)
            return null;
        System.debug('One atm reference');
               
        atmDetailsMap.put('entity',''+atmRefList[0].Entity__c);
        
        if(atmRefList[0].ATM_Reference__c != null){
            atmDetailsMap.put('atmRef',atmRefList[0].ATM_Reference__c);
        }
        else{
            atmDetailsMap.put('atmRef',''+atmRefList[0].MB_Reference__c);
        }
        atmDetailsMap.put('debt',''+atmRefList[0].Amount__c);
        
        System.debug(atmDetailsMap);
        return atmDetailsMap;
     
    }
    
}