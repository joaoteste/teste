@isTest (SeeAllData = True)
public class Bill_UpdateBillingItemBatchTest {
    
    @isTest (SeeAllData = True)	
    public static void test1(){
        Database.executeBatch(new Bill_UpdateBillingItemBatch(), 10);
    }
    
}