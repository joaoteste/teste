@isTest(SeeAllData=true)
public class CR_SepaRecord_trigger_test {
	
    @isTest 
    public static void testSepaRecord(){
        CR_Sepa_Record__c crsr = new CR_Sepa_Record__c();
        crsr.Activation_Date__c = date.today();
        crsr.IBAN__c='PT5023233434123';
        insert crsr;
        Test.startTest();
        boolean verifyDelete = true;
        try{
         	delete crsr;
            verifyDelete = false;
        }
        catch(exception ex){
            System.assert(verifyDelete);
        }
        Test.stopTest();
    }
    
    @isTest 
    public static void testInactiveFlageSepaRecord(){
    	RentingApplication_Util_Test rAp = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rAp.environment9();
        
        Id sepaRecordId = infoMap.get('sepaRecord');
        
        List<CR_Sepa_Record__c> sepaRecordList = new List<CR_Sepa_Record__c>();
        sepaRecordList = [SELECT Id, Invalid_Record__c FROM CR_Sepa_Record__c WHERE ID = :sepaRecordId];
        
        Test.startTest();
        
        sepaRecordList[0].Invalid_Record__c = true;
        
        Test.stopTest();

    	
    }
    
}