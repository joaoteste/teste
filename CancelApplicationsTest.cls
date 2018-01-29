@isTest
public class CancelApplicationsTest {
    
    public static CronTrigger fetchCronTrigger(String jobId) {
        return [
            select CronExpression,
            TimesTriggered,
            NextFireTime
            from CronTrigger
            where Id = :jobId
        ];
    }
    
    static testMethod void scheduleItTest(){

        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '506230732';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        insert vendor;     

        //New Account Client
        Account client = new Account();
        client.Name = '2 Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '507172094';

        insert client;

        datetime cd = datetime.now();
        date d = Date.newInstance(cd.year(),cd.month(),cd.day());

        Application__c app1 = new Application__c();
        app1.AccClient__c = client.ID;
        app1.Vendor__c = vendor.ID;
        app1.Insurance_Type__c = 'Special Risk';
        app1.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app1.Payment_Timing__c='Advanced';
        app1.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app1.TermCalc__c = 48;
        app1.Vendor_Invoice_Amount__c = 2402.63;
        app1.Equipment_Cost__c = 2402.63;
        app1.Insurance_Special_Value__c = 9.31;
        app1.Insurance_Movement_value__c = 11.01;
        app1.Client_BBAN__c = '004563904014640899590';
        app1.Payment_Freq__c ='Quarterly';
        app1.Payment_Amount__c = 2500;
        app1.Invoice_Payment_Date__c =d;
        insert app1;

        String jobId = CancelApplications.scheduleIt('0 0 3 * * ?');
        CronTrigger ct = fetchCronTrigger(jobId);
        System.assertEquals('0 0 3 * * ?', ct.CronExpression,'Did not get the same Cron Expression back');
    }
    
    static testMethod void testCancelApplications() {
        
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '50363033023';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        insert vendor;     

        //New Account Client
        Account client = new Account();
        client.Name = '2 Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '5007666303';
         
        insert client;

        datetime cd = datetime.now();
        date d = Date.newInstance(cd.year(),cd.month(),cd.day());

        Application__c app1 = new Application__c();
        app1.AccClient__c = client.ID;
        app1.Vendor__c = vendor.ID;
        app1.Insurance_Type__c = 'Special Risk';
        app1.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app1.Payment_Timing__c='Advanced';
        app1.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app1.TermCalc__c = 48;
        app1.Vendor_Invoice_Amount__c = 2402.63;
        app1.Equipment_Cost__c = 2402.63;
        app1.Insurance_Special_Value__c = 9.31;
        app1.Insurance_Movement_value__c = 11.01;
        app1.Client_BBAN__c = '004563904014640899590';
        app1.Payment_Freq__c ='Quarterly';
        app1.Payment_Amount__c = 2500;
        app1.Invoice_Payment_Date__c =d;
        insert app1;

        test.setCreatedDate(app1.id, d);

        Test.startTest();
  
        String jobId = System.schedule('_unittest_scheduled_: 001' , '0 0 4 * * ?' , new CancelApplications());
        CronTrigger ct = fetchCronTrigger(jobId);
        
        System.assertEquals('0 0 4 * * ?', ct.CronExpression,'Did not get the same Cron Expression back');
        
        Application__c app = [SELECT Id, cancelled__c from Application__c WHERE ID=:app1.Id];
        Test.stopTest();
    }
}