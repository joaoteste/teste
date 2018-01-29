@isTest(SeeAllData=true)
public class ScheduleReprocInfoDBTest {
    public static CronTrigger fetchCronTrigger(String jobId) {
        return [
            select CronExpression,
            TimesTriggered,
            NextFireTime
            from CronTrigger
            where Id = :jobId
        ];
    }
    
    static testMethod void testScheduleReprocInfoDB() {
        Test.startTest();
        
        String jobId = System.schedule('_unittest_scheduled_: 001' , '0 0 4 * * ?' , new ScheduleReprocInfoDB());
        CronTrigger ct = fetchCronTrigger(jobId);
        
        System.assertEquals('0 0 4 * * ?', ct.CronExpression,'Did not get the same Cron Expression back');
        
        Test.stopTest();
    }

}