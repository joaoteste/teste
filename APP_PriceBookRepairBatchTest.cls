@isTest(SeeAllData = True)	
public class APP_PriceBookRepairBatchTest {

    @isTest (SeeAllData = True)	
    public static void test1(){
        Database.executeBatch(new APP_PriceBookRepairBatch(), 10);
    }
        
}