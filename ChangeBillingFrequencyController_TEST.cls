//CREATED BY BP - 05/04/17
//@Apex notation:
//An apex page controller that exposes the change billing frequency functionality
@IsTest(SeeAllData=true)
public class ChangeBillingFrequencyController_TEST 
{
	public static ApexPages.StandardController standardController;
	
	public static ID getData()
	{
		//-----VENDOR ACCOUNT-----//
		Account vendor = new Account();
        vendor.Name    = 'Test Account Vendor'; 
        vendor.Type    = 'Channel Partner / Vendor';
        vendor.NIF__c  = '503630311';
        upsert vendor;
        
        //-----CLIENT ACCOUNT-----//
        Account client 		= new Account();
        client.Name    		= 'Test Account Client'; 
        client.Type    		= 'Customer - Channel';
        client.NIF__c  		= '504092090';
        client.Risk_Type__c = 'Middle';
        upsert client;
        
        //-----TEST CONTACT-----//
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        upsert contact;
        
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        upsert app;
        return app.ID;
	}

	@IsTest static void ChangeBillingFrequencyControllerTest()
	{
		PageReference testingPage = Page.Change_Billing_Freq;
        test.setCurrentPage(testingPage);

        ID appID = getData();
        ApexPages.currentPage().getParameters().put('id',appID );

        ApexPages.StandardController  	 sc   = new ApexPages.StandardController(new Application__c(ID=appID));
        ChangeBillingFrequencyController cbfc = new ChangeBillingFrequencyController(sc);

        cbfc.checkChangeBillingFrequency();
        cbfc.ChangeBillingFrequencyTrue();
        cbfc.ChangeBillingFrequencyFalse();        
	}    
}//end ChangeBillingFrequencyControllerTest class