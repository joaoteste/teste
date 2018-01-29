@isTest
public class BillingPeriodBatchTest {
    
    @isTest
    public static void batchTest(){
        Test.startTest();
        
        BillingPeriodBatch batch = new BillingPeriodBatch();
        Database.executeBatch(batch,10);
        
        
        Test.stopTest();
    }

}