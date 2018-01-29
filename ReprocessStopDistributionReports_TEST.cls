//created BY BP
@isTest (seeAllData =true)
private class ReprocessStopDistributionReports_TEST
{	
	@isTest static void schedule_TEST() 
	{
		Test.startTest();
			Map<String, ID> data = getTestData();
			System.schedule('ReprocessStopDistributionReports_TEST' , '0 0 * ? * 1,2,3,4,5,6,7', new ReprocessStopDistributionReports());
		Test.stopTest();
	}

    private static Map<String, ID> getTestData()
    {
        Map<String, ID> dataMap = new Map<String,ID>();
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630311';
        vendor.Country_Code__c ='PT50';
        //vendor.c2g__CODABankIBANNumber__c ='PT50000700000003253768222';
        insert vendor;
        dataMap.put('vendorID', vendor.ID);
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '504092090';
        client.Country_Code__c ='PT50';
        client.Updating_Report__c = true;
        insert client;
        dataMap.put('clientID', client.ID);
        
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        insert app;
        dataMap.put('appID', app.ID);

        return dataMap;
    }
}