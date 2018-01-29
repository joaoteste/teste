@isTest (SeeAllData = true)
public class Utils_getDebtInforForClient_Test {
    @isTest
    static void testDebtForClient(){
        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = utils.environment1();    
        String clientID = infoMap.get('client');
        double debtClient;
        Collection_Case__c cc = [SELECT ID, Amount_Claimed__c  FROM Collection_Case__c WHERE ID = :infoMap.get('ccID')];
        Test.startTest();
        
            debtClient = Utils_getDebtInforForClient.debtForClient(clientID);
        
        Test.stopTest();
        system.assertEquals(cc.Amount_Claimed__c,debtClient);
    }
    @isTest
    static void testGetAtmDetailsForAccount(){
        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = utils.environment1();    
        
        ATM_Reference__c atmRefList_Test = [SELECT Entity__c,MB_Reference__c, ATM_Reference__c, Amount__c  FROM ATM_Reference__c WHERE ID = :infoMap.get('atm')];
        Map<String, String> atmDetailsMap;
        
        Test.startTest();
        
            atmDetailsMap = Utils_getDebtInforForClient.getAtmDetailsForAccount(infoMap.get('client'));
        
        Test.stopTest();
            system.assert(atmRefList_Test != null);
            system.assert(atmDetailsMap != null);
            system.debug(atmRefList_Test);
            system.debug(atmDetailsMap);
            system.assertEquals(atmDetailsMap.get('entity'), (''+atmRefList_Test.Entity__c));
            if(atmRefList_Test.ATM_Reference__c != null){
                system.assertEquals(atmDetailsMap.get('atmRef'), atmRefList_Test.ATM_Reference__c);
            }
            else {
                system.assertEquals(atmDetailsMap.get('atmRef'), (''+atmRefList_Test.MB_Reference__c));
            }
            
            system.assertEquals(atmDetailsMap.get('debt'), (''+atmRefList_Test.Amount__c));
    
    }
    
}