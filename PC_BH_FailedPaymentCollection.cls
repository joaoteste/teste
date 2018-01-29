global class PC_BH_FailedPaymentCollection implements Database.Batchable<sObject>, Database.Stateful{

	global List<Payment_Collection__c> paymentCollectionAuxList = new List<Payment_Collection__c>();
	
	global Database.QueryLocator start(Database.BatchableContext BC){ 

        String query = 'SELECT ID, Status__c,Expiry_Date__c FROM Payment_Collection__c WHERE Expiry_date__c < TODAY AND Status__c = \'In Payment\' AND Payment_Method__c = \'ATM Reference\'';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Payment_Collection__c> paymentCollectionList){
     	for(Payment_Collection__c pc : paymentCollectionList){
     		pc.Status__c='Unpaid';
			paymentCollectionAuxList.add(pc);
     	}
     	
    }
     
    global void finish(Database.BatchableContext BC){
        if(!paymentCollectionAuxList.isEmpty())
            update paymentCollectionAuxList;        
    }
     
    
}
