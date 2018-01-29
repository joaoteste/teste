global class CM_CloseCMSAndDoCashMatch_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global CM_CloseCMSAndDoCashMatch_Batch() {
		
	}
	
		
	global Database.QueryLocator start(Database.BatchableContext BC) {
		string today=string.valueOf(System.today());
		query='select id, billing_contract__r.application__r.vendor__r.BillingCountryCode, billing_contract__r.application__r.AccClient__c,Residual_Value_Amount__c, '+ 
         	  'Advanced_Expired_Principals_Amount__c, billing_contract__r.Application__c,billing_contract__r.Application__r.name, Account_Tax_Zone__c, Total_Amount__c, CMS_Status__C, ' + 
         	   'Offer_Notification_Contact_Email__c, Offer_Notification_Contact__c ' +
			   ' from Contract_Management__C where CMS_Status__c =\'Accepted\' and sales_invoice__c in (Select id from c2g__codaInvoice__c where c2g__PaymentStatus__c=\'Paid\') ';
		return Database.getQueryLocator(query);

	}

   	global void execute(Database.BatchableContext BC,  List<Contract_Management__C> CMSList) {
   		CM_ContractManagement CM= New CM_ContractManagement();
   		for (Contract_Management__C CMRec :CMSList){
   			CM.CloseCMSAndDoMatch(CMRec);
   		}
   		
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}