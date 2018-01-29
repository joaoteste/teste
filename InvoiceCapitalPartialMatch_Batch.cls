global class InvoiceCapitalPartialMatch_Batch implements Database.Batchable<Id> {
	
	String query;
	public List<Id> ListIds;
	
	global InvoiceCapitalPartialMatch_Batch( List<Id> ListIds) {
		system.debug('***' + ListIds);
		this.ListIds = ListIds;
		
	}
	
	global Iterable<Id> start(Database.BatchableContext BC) {
		
		return New List<Id>(ListIds);
	}

   	global void execute(Database.BatchableContext BC, List<Id> scope) {
   		system.debug(scope);
   		List<Application__C> ListApp = [Select name, AccClient__c from Application__c where id in :scope];
   		UTIL_CashMatch CashMatch = New UTIL_CashMatch();
   		For(application__c app :ListApp){
   			system.debug(integer.valueOf(Limits.getQueries()) + ' ' + integer.valueOf(Limits.getLimitQueries())  );
   			CashMatch.doInvoiceCapitalMatch(app);
   			system.debug(integer.valueOf(Limits.getQueries()) + ' ' + integer.valueOf(Limits.getLimitQueries())  );
   		}
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}