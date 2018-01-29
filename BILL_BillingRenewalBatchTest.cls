@isTest(SeeAllData=true)
public class BILL_BillingRenewalBatchTest {
    
    @isTest
    static void testExecute(){
        
        Test.startTest();
        
        BILL_BillingRenewalBatch billingRenewalBatch = new BILL_BillingRenewalBatch();
        
        ID batchprocessid = Database.executeBatch(billingRenewalBatch, 15);
        
        Test.stopTest();
        
    }
    
}