@isTest
private class CM_CloseCMSAndDoCashMatch_ScheduleTest
{
	@isTest
	public static void test(){
        Test.startTest();
        
        CM_CloseCMSAndDoCashMatch_Schedule CMDoMatch = new CM_CloseCMSAndDoCashMatch_Schedule();

        String jobId = System.schedule('CM Do Match Job '+ date.today(), '0 0 23 * * ?', CMDoMatch);

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