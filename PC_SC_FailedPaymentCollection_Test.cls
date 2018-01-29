@isTest
public class PC_SC_FailedPaymentCollection_Test {
	
	@isTest
	public static void test(){

		Test.startTest();
		
        PC_SC_FailedPaymentCollection pcExpired = new PC_SC_FailedPaymentCollection();

        String jobId = System.schedule('Create Bill EasyPay Schedulable '+ date.today(), '0 0 14 * * ?', pcExpired);
            
        CronTrigger ct = fetchCronTrigger(jobId);
        
        System.assertEquals('0 0 14 * * ?', ct.CronExpression,'Did not get the same Cron Expression back');
        
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