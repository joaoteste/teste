@isTest(SeeAllData=true)
public class PaymentCollection_Utils_Test {

	

	@isTest
    public static void createPaymentCollectionWithATM_Test(){
    	
    	RentingApplication_Util_Test renting = new RentingApplication_Util_Test();
    	PaymentCollection_Utils pcUtils = new PaymentCollection_Utils();
    	Map<String,String> dataMap = renting.environment1();
    	
    	ID act = dataMap.get('client');
    	ID per = renting.getPeriod();
    	ID app = dataMap.get('appID');
    	ID si = dataMap.get('salesInvoice');
    	
    	Test.startTest();
    	Map<String, String> infoMap = pcUtils.createPaymentCollectionWithATM(12.30, act, per, Date.today(), 606250321, si, app);
    	Test.stopTest();
    	
    	//test parameters creation
    	System.assert(infoMap.get('pc')!=null);
    	System.assert(infoMap.get('atm')!=null);
    	System.assert(infoMap.get('rli')!=null);
    }
    
	@isTest
    public static void createPaymentCollectionWithATM2_Test(){
    	
    	RentingApplication_Util_Test renting = new RentingApplication_Util_Test();
    	PaymentCollection_Utils pcUtils = new PaymentCollection_Utils();
    	Map<String,String> dataMap = renting.environment1();
    	
    	Test.startTest();
    	
    	ID dAlert = dataMap.get('dAlert');   	
    	
    	Map<String, String> infoMap = pcUtils.createPaymentCollectionWithATM(12.30, Date.today(), dAlert, 'Test');
    	
    	Test.stopTest();
    	
    	
    	//test parameters creation
    	System.assert(infoMap.get('pc')!=null);
    	System.assert(infoMap.get('atm')!=null);
    }
    
	@isTest
    public static void createPaymentCollectionWithATM3_Test(){
    	
    	RentingApplication_Util_Test renting = new RentingApplication_Util_Test();
    	PaymentCollection_Utils pcUtils = new PaymentCollection_Utils();
    	Map<String,String> dataMap = renting.environment1();
    	List<ATM_Reference__c> atmList = new List<ATM_Reference__c>();
        ATM_Reference__c atm = [SELECT ID, Amount__c, Expiry_date__c, Dunning_Alert__c FROM ATM_Reference__c WHERE ID = :dataMap.get('atm')];
        atmList.add(atm);
        
    	Test.startTest();
    	
    	ID dAlert = dataMap.get('dAlert');   	
    	
    	Map<String, String> infoMap = pcUtils.createPaymentCollectionWithATM(atmList);
    	
    	Test.stopTest();
    	
    	
    	//test parameters creation
    	System.assert(infoMap.get('pc')!=null);
    	System.assert(infoMap.get('atm')!=null);
    }    

}