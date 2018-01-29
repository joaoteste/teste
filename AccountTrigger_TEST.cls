//CREATED BY BP - 11/08/17 
@isTest (SeeAllData =true)
private class AccountTrigger_TEST
{
	
	@isTest static void FASTCOVER()
	{
        System.debug(Limits.getQueries());
		Account testAcc = new Account();
		testAcc.Name = 'Big BadumTss';
		testAcc.Nif__c = '501783450';
		testAcc.type = 'Customer - Channel';
		insert testAcc;
        
		System.debug(Limits.getQueries());    
		testAcc.BBAN__c ='001000005012556000150';
		testAcc.billingPostalCode = '2300-999';
		update testAcc;
        
		Account testAcc2 = new Account();
		testAcc2.Name = 'Big BadumTss';
		testAcc2.Nif__c = '501783450';
		testAcc2.type = 'Channel Partner / Vendor';
		insert testAcc2;        
		System.debug(Limits.getQueries());        
	}
}