@isTest(SeeAllData=true)
public class Bill_Moloni_EmailAndPdf_Batch_Test {
		
    @isTest
    static void testBatch(){
    	
    	RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
		Map<String, String> infoMap = utils.environment4();    
    	
        Test.startTest();
        
        DataBase.executeBatch(new Bill_Moloni_EmailAndPdf_Batch());
        
        Test.stopTest();    	
    } 
    
    @isTest
    static void testBatchATM(){
    	
    	RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
		Map<String, String> infoMap = utils.environment4();    
		c2g__codainvoice__c si = [SELECT ID FROM c2g__codainvoice__c WHERE ID = :infoMap.get('salesInvoice')];
		si.first_atm__c = infoMap.get('atm');
		update si;
    	
        Test.startTest();
        
        DataBase.executeBatch(new Bill_Moloni_EmailAndPdf_Batch());
        
        Test.stopTest();    	
    }     

    
}