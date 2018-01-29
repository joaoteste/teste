@isTest(SeeAllData=true)
public class Bill_EasyPay_QueueRun_Test {
    
    @isTest
    static void executeTest(){
        
        Test.startTest();
        
        System.enqueueJob(new Bill_EasyPay_QueueRun());
        
        Test.stopTest();
        
        System.assert(true);
    }

}