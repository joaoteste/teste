global class CM_UpdPaymentCollection_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global CM_UpdPaymentCollection_Batch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query='Select id, sales_invoice__r.first_atm__c, sales_invoice__c  from Contract_Management__c where CMS_Status__c=\'Accepted\' And Payment_collection__c = null and sales_invoice__r.first_atm__c != null';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Contract_Management__c> CMSList) {
   		
   			Set<Id> ATMsIds = New Set<Id>();
   			for(Contract_Management__c CMRec :CMSList){
   				ATMsIds.add(CMRec.sales_invoice__r.first_atm__c);
   			}
   			CM_ContractManagement CM = New CM_ContractManagement();
   			CM.updatePaymntCollct( ATMsIds, CMSList);
   
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}