@isTest (SeeAllData = true)
public class VendorInvoice_completeInvoice_test {
	static final String CRON_EXP = '0 00 23 * * ?';
	@isTest static void VendorInvoice_completeInvoice_test(){
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
            Test.startTest();
            Map<String, ID> infoMap = PayableInvoiceHandlerTest.getTestData();
            
            Vendor_Invoice__c vendorInvoice = RentingApplication_Util_test.createVendorInvoice(infoMap.get('vendorID'), infoMap.get('appID'));
            
            System.assertEquals(vendorInvoice.status__c , 'Draft', 'The vendor invoices were not processed');
            List<Vendor_Invoice__c > vendorInvoiceListBeggining = [SELECT ID
                                                                   FROM	Vendor_Invoice__c
                                                                   WHERE Submitted__c = true 
                                                                   AND Status__c ='Draft'
                                                                   AND Application__c != null];
            
            
            String jobId = System.schedule('VendorInvoice_completeInvoice',CRON_EXP, new VendorInvoice_completeInvoice());
            
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            // Verify the expressions are the same
            System.assertEquals(CRON_EXP, ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            
            Date dateToday = Date.today();
            String sMonth = String.valueof(dateToday.month());
            String sDay = String.valueof(dateToday.day());
            if(sMonth.length()==1){
                sMonth = '0' + sMonth;
            }
            if(sDay.length()==1){
                sDay = '0' + sDay;
            }
            Test.stopTest();
            
            String sToday = String.valueof(dateToday.year())+'-' + sMonth+'-' + sDay ;

            // Verify the next time the job will run
            System.assertEquals(sToday+' 23:00:00',String.valueOf(ct.NextFireTime));
        }   
       
	}  
}