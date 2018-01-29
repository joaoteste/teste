/***
Author   |Date  | Comments
Vinod    |09/19/2017 | Initial Creation
***/

global class CreateAtmBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
   
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id FROM Payment_Schedule__c where Reminder_Date__c <= TODAY AND ATM__c = Null AND Payment_Plan__r.Status__c = \'Open\'';
        if(Test.isRunningTest()) query += ' Limit 1';
        return Database.getQueryLocator(query); 
    }
     
    global void execute(Database.BatchableContext BC, List<Payment_Schedule__c > payList) {
		for(Payment_Schedule__c ps : payList)
            PaymentPlan_Utils.createATMNotFuture(ps.ID);
    }   
     
    global void finish(Database.BatchableContext BC) {
       
    }
}
