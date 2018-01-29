@isTest(SeeAllData=true)
public class Bill_EasyPay_Schedulable_Test{
    
    @isTest
    static void billEasyPaySchedulableTest(){
        
        
        Test.startTest();
        
        Bill_EasyPay_Schedulable easyPay = new Bill_EasyPay_Schedulable();

        String jobId = System.schedule('Create Bill EasyPay Schedulable '+ date.today(), '0 0 14 * * ?', easyPay);

    
            
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