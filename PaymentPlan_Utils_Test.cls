@isTest(SeeAllData = true)
public class PaymentPlan_Utils_Test {
    
    @isTest
    public static void testContractsAndJournals(){
        RentingApplication_Util_Test rentUtils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rentUtils.environment1();
        
        Test.startTest();
        
        PaymentPlan_Utils.createJournal(infoMap.get('client'), 'PPS-0023', infoMap.get('salesInvoice'), 50, 10);
        PaymentPlan_Utils.deleteOldContract(infoMap.get('ccID'));
        
        Test.stopTest();
    }

}