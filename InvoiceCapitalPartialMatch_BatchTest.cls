@isTest
private class InvoiceCapitalPartialMatch_BatchTest
{
	


	@isTest  (seeAllData=true)
	public static void testBatch()
	{  
		 Map<String, ID> datamap=new Map<String, ID>(CM_ContractManagementTest.setupCMS());
		
	 	application__c app=[select name, accClient__c from application__c where id= :datamap.get('app') ];
		Test.startTest();
		UTIL_CashMatch_Test.createInvoiceJournal(app);
		list<Id> listId=New   list<Id> ();
		ListId.add(app.id);

	 DataBase.executeBatch(new InvoiceCapitalPartialMatch_Batch(ListId));
	 Test.stopTest();
	}
}