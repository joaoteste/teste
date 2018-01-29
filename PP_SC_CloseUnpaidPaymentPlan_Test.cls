@isTest(SeeAllData=true)
public class PP_SC_CloseUnpaidPaymentPlan_Test {

    
    @isTest
    public static void testCloseUnpaid(){
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
        
        Payment_Schedule__c ps = new Payment_Schedule__c(); 
        ps.Due_Date__c = system.today().addDays(-1);
        ps.Payment_Plan__c = pp.ID;
        ps.ATM__c = atm;
        insert ps;
        
 		PP_SC_CloseUnpaidPaymentPlan ppSchedule = new PP_SC_CloseUnpaidPaymentPlan();
		Test.startTest();
        String jobId = System.schedule('Create PP Schedulable '+ date.today(), '0 0 14 * * ?', ppSchedule);

    
            
        CronTrigger ct = fetchCronTrigger(jobId);
        Test.stopTest();
        System.assertEquals('0 0 14 * * ?', ct.CronExpression,'Did not get the same Cron Expression back');
        
    }
    

    public static CronTrigger fetchCronTrigger(String jobId) {
        return [
            select CronExpression,
            TimesTriggered,
            NextFireTime
            from CronTrigger
            where Id = :jobId
        ];
    }

}