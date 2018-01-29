global class CM_HitDateExpiration_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global CM_HitDateExpiration_Batch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		string today=string.valueOf(System.today());
		if( !Test.isRunningTest()){
			query='Select name, CMS_Status__c from Contract_Management__C where Hit_Date__c < ' + today + ' and CMS_Status__c !=\'Closed\' ';
		
		}
		else {
			query='Select name, CMS_Status__c from Contract_Management__C where Hit_Date__c = ' + today + ' and CMS_Status__c !=\'Closed\' ';
		}
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Contract_Management__C> CMSList) {
   		CM_ContractManagement CM= New CM_ContractManagement();
   		CM.ExpireAndSendAlertEmail(CMSList);
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}