@isTest(SeeAllData=true)
private class Receipt_Line_ItemTriggerHandlerTest {

    static testMethod void deleteRLITest() {
       RentingApplication_Util_Test rAp = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rAp.environment7();
        
        Id rliId = infoMap.get('rli');
        
        List<Receipt_Line_Item__c> aux = new List<Receipt_Line_Item__c>();
        aux = [SELECT Id FROM Receipt_Line_Item__c WHERE ID = :rliId];
        
        Test.startTest();
        
        delete aux;
        
        Test.stopTest();

    }
    
}