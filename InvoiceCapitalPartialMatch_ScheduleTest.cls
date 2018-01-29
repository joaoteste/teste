@isTest
public class InvoiceCapitalPartialMatch_ScheduleTest
{	


	@isTest
	public static void test(){
        
        InvoiceCapitalPartialMatch_Schedule InvCapitalPartialMatch = new InvoiceCapitalPartialMatch_Schedule();

        String jobId = System.schedule('CM Expire Job '+ date.today(), '0 0 23 * * ?', InvCapitalPartialMatch);
        CronTrigger ct = fetchCronTrigger(jobId);
        System.assertEquals('0 0 23 * * ?', ct.CronExpression,'Did not get the same Cron Expression back');
        
   
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