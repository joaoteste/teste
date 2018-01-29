@isTest
private class BILL_BillingRenewalScheduleTest {
    
   public static CronTrigger fetchCronTrigger(String jobId) {
        return [
            select CronExpression,
            TimesTriggered,
            NextFireTime
            from CronTrigger
            where Id = :jobId
        ];
    }
    
    @isTest (SeeAllData=True)
    static void scheduleTest1(){
        
        Date startDate = Date.newInstance(2014, 05, 30);

        Test.startTest();
        BILL_BillingRenewalTest.billingRenewalSetupTest();
        
        Application__c app = BILL_BillingRenewalTest.createApplication(startDate);     
        system.debug('App: ' + app);
        BILL_BillingRenewalSchedule brs = new BILL_BillingRenewalSchedule();
   
        String jobId = System.schedule('Bill Billing Renewal Schedule'+ date.today().addMonths(2).month(), '0 0 3 10 * ?', brs);
            
        CronTrigger ct = fetchCronTrigger(jobId);
        
        System.assertEquals('0 0 3 10 * ?', ct.CronExpression,'Did not get the same Cron Expression back');  
        
        Test.stopTest();
        
    }
    
}