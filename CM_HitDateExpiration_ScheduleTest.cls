@isTest
private class CM_HitDateExpiration_ScheduleTest
{
	
	@isTest
	public static void test(){
        Test.startTest();
        
        CM_HitDateExpiration_Schedule CMETExpire = new CM_HitDateExpiration_Schedule();

        String jobId = System.schedule('CM Expire Job '+ date.today(), '0 0 23 * * ?', CMETExpire);

        CronTrigger ct = fetchCronTrigger(jobId);
        
        System.assertEquals('0 0 23 * * ?', ct.CronExpression,'Did not get the same Cron Expression back');
        
        Test.stopTest();
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