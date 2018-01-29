@isTest(SeeAllData = true)
public class PP_CollectionReminder_Test {
	
	
	@isTest
	public static void testCollectionFullPP(){
		Map<String,String> infoMap = setData();
		
		Test.startTest();
			Database.executebatch(new PP_BH_CollectionReminder(), 1);
		Test.stopTest();
		
		
	}

    public static Map<String,String> setData(){
        Map<String,String> dataMap = new Map<String,String>();
        
        RentingApplication_Util_Test rentUtils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rentUtils.environment1();
        Contact cont = new Contact();
        cont.AccountId = infoMap.get('client');
        cont.Email = 'test@test.pt';
        cont.LastName = 'Test';
        cont.Phone = '+351915229100';
		cont.MobilePhone = '+351915229100';        
        insert cont;       
        dataMap.put('Contact', cont.id);
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Type__c = 'Full';
        pp.Account__c = infoMap.get('client');
        pp.Contact__c = cont.ID;
        pp.Status__c = 'Open';
        pp.Collection_Case__c = infoMap.get('ccID');
        insert pp;
        dataMap.put('Payment_Plan__c', pp.id);
        
        Payment_Collection__c pc = new Payment_Collection__c(); 
        pc.Status__c = 'In Payment';
        insert pc;
        
        ATM_Reference__c atm = new ATM_Reference__c();
        atm.Amount__c = 100;
        atm.ATM_Reference__c = '500200300';
        atm.Entity__c = 11223;
        atm.MB_Reference__c = 500200300;
        atm.Payment_Collection__c = pc.ID;
        insert atm;
        
        Payment_Schedule__c ps = new Payment_Schedule__c();
        ps.Payment_Plan__c = pp.ID;
        ps.Amount__c = 100;
        ps.Fees_Amount__c = 20;
        ps.Amount_W_O_Tax__c = 100;
        ps.Due_Date__c = system.today().addDays(-1);
        ps.Schedule_Number__c = '1';
        ps.Payment_Collection__c = pc.ID;
        ps.ATM__c  =atm.ID;
        insert ps;
        dataMap.put('ps', ps.id);
        
        Payment_Schedule__c ps2 = new Payment_Schedule__c();
        ps2.Payment_Plan__c = pp.ID;
        ps2.Amount__c = 100;
        ps2.Fees_Amount__c = 20;
        ps2.Amount_W_O_Tax__c = 100;
        ps2.Due_Date__c = system.today().addDays(5);
        ps2.Schedule_Number__c = '2';
        ps.Payment_Collection__c = pc.ID;        
        insert ps2;  
        dataMap.put('ps2', ps2.id);
        
        return dataMap;
    }
    
}