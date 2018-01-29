@isTest(SeeAllData=true)
public class CreatePPIandSIBatch_Test {
    private static Map<String,String> data = getData();
    
    @isTest
    public static void testCreatePPIandSIBatch() {    
        
        Test.startTest();
        Database.executeBatch(new CreatePPIandSIBatch(),1);
        Test.stopTest();
        
    }
    
    //PC 2017-12-05
    //test method to solve: No more than one executeBatch can be called from within a test method
    //the CreatePPIandSIBatch calls another batch on the finish method so it occurs one error when testing.
    //Solve: on CreatePPIandSIBatch finish method the batch isn't call when is running test
    //Create one test method to test that batch
    @isTest
    public static void testATMBatch(){
        
        List<Payment_Schedule__c> objPayList = [SELECT Id, Payment_Plan__c, Schedule_Number__c 
                                                FROM Payment_Schedule__c 
                                                where (id = :data.get('ps') or id = :data.get('ps2')) AND Schedule_Number__c != '1' AND Payment_Plan__r.Status__c = 'Open'];
        
        System.debug('objPayList '+objPayList);
        
        //method call on CreatePPIandSIBatch
        for(Payment_Schedule__c objPay : objPayList){
            PaymentPlan_Utils.startSchedule(objPay.Payment_Plan__c, objPay.Schedule_Number__c);
        }
        
        Test.startTest();
        Database.executeBatch(new CreateAtmBatch(),1);
        Test.stopTest();
    }
    
    @isTest
    public static void testSchedule(){
        
        CreatePPIandSIBatchScheduler billPP = new CreatePPIandSIBatchScheduler();
        
        String jobId = System.schedule('Create PP '+ date.today(), '0 0 14 * * ?', billPP);
        
        CronTrigger ct = fetchCronTrigger(jobId);
        
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
    
    public static Map<String,String> getData(){
        Map<String,String> dataMap = new Map<String,String>();
        
        RentingApplication_Util_Test rentUtils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rentUtils.environment1();
        Contact cont = new Contact();
        cont.AccountId = infoMap.get('client');
        cont.Email = 'test@test.pt';
        cont.LastName = 'Test';
        cont.Phone = '915229100';
        insert cont;       
        dataMap.put('Contact', cont.id);
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Type__c = 'Partial';
        pp.Account__c = infoMap.get('client');
        pp.Contact__c = cont.ID;
        pp.Frequency__c = 'Every 15 Days';
        pp.Status__c = 'Open';
        pp.Number_of_Payments__c = '2';
        pp.Collection_Case__c = infoMap.get('ccID');
        insert pp;
        dataMap.put('Payment_Plan__c', pp.id);
        
        Payment_Schedule__c ps = new Payment_Schedule__c();
        ps.Payment_Plan__c = pp.ID;
        ps.Amount__c = 100;
        ps.Fees_Amount__c = 20;
        ps.Amount_W_O_Tax__c = 100;
        ps.Due_Date__c = system.today().addDays(3);
        ps.Schedule_Number__c = '1';
        insert ps;
        dataMap.put('ps', ps.id);
        
        Payment_Schedule__c ps2 = new Payment_Schedule__c();
        ps2.Payment_Plan__c = pp.ID;
        ps2.Amount__c = 100;
        ps2.Fees_Amount__c = 20;
        ps2.Amount_W_O_Tax__c = 100;
        ps2.Due_Date__c = system.today().addDays(5);
        ps2.Schedule_Number__c = '2';
        insert ps2;  
        dataMap.put('ps2', ps2.id);
        
        return dataMap;
    }
}