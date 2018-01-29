@isTest
public class Bill_Moloni_EPDFCreditNotes_Sch_Test {
	
	@isTest
	public static void test(){
        Test.startTest();
        
        Bill_Moloni_EPDFCreditNotes_Schedule easyPay = new Bill_Moloni_EPDFCreditNotes_Schedule();

        String jobId = System.schedule('Bill Moloni Schedulable '+ date.today(), '0 0 14 * * ?', easyPay);

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