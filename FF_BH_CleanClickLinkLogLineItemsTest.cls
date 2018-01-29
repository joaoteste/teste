@isTest(SeeAllData=true)
private class FF_BH_CleanClickLinkLogLineItemsTest{
    
    static testmethod void test() {
       //TODO insert data to remove (SeeAllData=true)
       Test.startTest();
       FF_BH_CleanClickLinkLogLineItems batch = new FF_BH_CleanClickLinkLogLineItems();
       Database.executeBatch(batch, 10);
       Test.stopTest();

       // Verify if items got deleted  
       // Integer i = [SELECT COUNT() FROM ffirule__IntegrationRuleLogLineItem__c where CreatedDate < LAST_WEEK];
       // System.assertEquals(i, 0);
    }
}