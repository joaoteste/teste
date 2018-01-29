/**

Author   |Date  	 | Comments
Vinod    |09/13/2017 | Initial Creation

**/
global class CreatePPIandSIBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.stateful
{
    // Getting invoices to whom reminder email should be sent
    public string query = 'SELECT Id, Payment_Plan__c, Schedule_Number__c FROM Payment_Schedule__c where Reminder_Date__c <=TODAY AND Schedule_Number__c != \'1\' AND Sales_Invoice__c = Null AND Payment_Collection__c = Null AND Payment_Plan__r.Status__c = \'Open\''; 
    
    public string scheduleId;
    
    global database.querylocator start(Database.BatchableContext BC)
    {
        System.debug('Query -->> '+query);
        if(Test.isRunningTest()){
            query += ' limit 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,  List<Payment_Schedule__c> paymentScheduleScope)
    {
        
        for(Payment_Schedule__c objPay : paymentScheduleScope){
            PaymentPlan_Utils.startSchedule(objPay.Payment_Plan__c, objPay.Schedule_Number__c);
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        if(!Test.isRunningTest()){
            Database.executeBatch(new CreateAtmBatch(),1);
        }
    }
}