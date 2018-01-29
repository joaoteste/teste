@isTest(SeeAllData=true)
public class OIL_DeleteBatch_Test{
	
    @isTest
    static void test() {
       Test.startTest();
       OIL_Delete_Batch batch = new OIL_Delete_Batch();
       Database.executeBatch(batch, 10);
       Test.stopTest();
    }
}