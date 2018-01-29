@isTest(SeeAllData = true)
public class PaymentCollection_Trigger_Test {

    @isTest
    public static void testClosePaymentPlan(){
		RentingApplication_Util_Test rAp = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rAp.environment4();
        ID cc = infoMap.get('ccID');
		ID newAccount = infoMap.get('client');
        ID atm = infoMap.get('atm');
        
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId= newAccount;
        insert contact;
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Status__c = 'Open';
        pp.Collection_Case__c = cc;
        pp.Hit_Date__c = system.today();
		pp.Contact__c = contact.ID;
        insert pp;

        Payment_Collection__c pc = new Payment_Collection__c();
        pc.Status__c = 'In Payment';
        insert pc;
        
        Payment_Schedule__c ps = new Payment_Schedule__c(); 
        ps.Due_Date__c = system.today().addDays(-1);
        ps.Payment_Plan__c = pp.ID;
        ps.ATM__c = atm;
        ps.Payment_Collection__c = pc.ID;
        insert ps;  
        
        Test.startTest();
			pc.Status__c = 'Unpaid';
        	update pc;
		Test.stopTest();      
        
        Payment_Plan__c ppAfter = [SELECT ID, Status__c FROM Payment_Plan__c WHERE ID = :pp.ID];
        System.assertEquals('Closed', ppAfter.Status__c);
        

    }
}