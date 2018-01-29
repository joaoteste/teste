@isTest
private class CM_UpdPaymentCollection_ScheduleTest
{
	@isTest
	public static void test(){
        Test.startTest();
        
        CM_UpdPaymentCollection_Schedule CMETUpdPayCol = new CM_UpdPaymentCollection_Schedule();

        String jobId = System.schedule('CM Update PayCol Job '+ date.today(), '0 0 23 * * ?', CMETUpdPayCol	);
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