@isTest(SeeAllData=true)
public class Bill_EasypayDeleteATM_Test {
	
	@isTest
	public static void test(){
		RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
		Map<String,String> infoMap = utils.environment1();
		ID atmID = infoMap.get('atm');
		ATM_Reference__c atm = [SELECT ID, MB_Payment_Status__c, Amount__c, MB_Reference__c, Payment_Collection__c  FROM ATM_Reference__c WHERE ID = :atmID];
		Atm_Reference__c atmAfter;
		Test.startTest();
		try{
			Bill_EasypayDeleteATM.deleteReference(atmID);
			delete atm;
		}catch(Exception e){
			atmAfter = [SELECT ID, MB_Payment_Status__c, Amount__c, MB_Reference__c, Payment_Collection__c  FROM ATM_Reference__c WHERE ID = :atmID];
		}
		Test.stopTest();
		
		System.assertEquals('Canceled', atmAfter.MB_Payment_Status__c);
	}
    
}