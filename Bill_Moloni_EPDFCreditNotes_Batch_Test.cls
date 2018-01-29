@isTest(SeeAllData=true)
public class Bill_Moloni_EPDFCreditNotes_Batch_Test {
	
    @isTest
    static void testBatch(){
    	
    	RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
		Map<String, String> infoMap = utils.environment5();    		
    	
        Test.startTest();
        
        DataBase.executeBatch(new Bill_Moloni_EPDFCreditNotes_Batch());
        
        Test.stopTest();    	
    } 	
    
}