global class InvoiceCapitalPartialMatch_Schedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		List<c2g__codaTransactionLineItem__c> TrsLineItemsAvailable = [select id, c2g__AccountValue__c, name, c2g__Transaction__r.c2g__Journal__r.application__c , c2g__Transaction__r.c2g__Period__r.id from c2g__codaTransactionLineItem__c
				 where c2g__LineType__c='Account' And c2g__MatchingStatus__c='Available' And c2g__Transaction__c in 
				 (select id  from c2g__codaTransaction__c where 	c2g__Journal__r.c2g__JournalStatus__c ='Complete' and c2g__Journal__r.c2g__CanceledJournal__c =false  And 
				 c2g__Journal__r.TypeDescription__c ='Invoice Capital'  )	LIMIT 40];


		 Set<Id> SetIds = New Set<Id>();
		for(c2g__codaTransactionLineItem__c trsLineItem :TrsLineItemsAvailable ){
			SetIds.add(trsLineItem.c2g__Transaction__r.c2g__Journal__r.application__c);

		}
		List<Id> ListIds=New List<Id>(SetIds);
		


		InvoiceCapitalPartialMatch_Batch b = new InvoiceCapitalPartialMatch_Batch(ListIds);
		database.executebatch(b);
	}
}