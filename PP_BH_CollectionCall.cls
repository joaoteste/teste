global class PP_BH_CollectionCall implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

	global List<ID> auxPSList = new List<ID>();
	
	global Database.QueryLocator start(Database.BatchableContext BC){ 

        String query = 'SELECT Id, Payment_Plan__c, Schedule_Number__c, Due_Date__c, Payment_Plan__r.Contact__r.Email, Payment_Plan__r.Contact__r.FirstName, Payment_Plan__r.Contact__r.LastName, Payment_Plan__r.Contact__r.MobilePhone,Payment_Plan__r.Collection_Case__c, Payment_Plan__r.Name, ATM__r.Amount__c, ATM_Entity__c, ATM_Reference__c FROM '+
                          'Payment_Schedule__c where ID in:auxPSList';
        
        if(!Test.isRunningTest()) query+= ' LIMIT 1';

        return Database.getQueryLocator(query);
    }
    
    global PP_BH_CollectionCall(List<ID> listAux){
    	this.auxPSList = listAux;
    }
    
    global void execute(Database.BatchableContext BC, List<Payment_Schedule__C> psList){
		for(Payment_Schedule__C ps : psList){
			if(!Test.isrunningTest()) Call.makeCall('+351218961160', ps.Payment_Plan__r.Contact__r.MobilePhone, 'Cobrança PP', 'a82240000008S3U', ps.Payment_Plan__c);					
		} 	
    }
     
    global void finish(Database.BatchableContext BC){
		Database.executeBatch(new PP_BH_CollectionSMS(auxPSList),1);
    }
     
    
}