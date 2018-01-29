@isTest 
public class test_SettleContractController {
    
    private static Application__c testApp =  getTestData();
    
    public static testMethod void testMyController() {
        
        PageReference pageRef = Page.SettleContract;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getParameters().put('id', 'a012400000WTrbKAAT');
        ApexPages.StandardController  sc = new ApexPages.StandardController(testApp);
      
        SettleContractController controller = new SettleContractController(sc);
        controller.settleContract();
        controller.checkBillingContract();
    }
    
    private static Application__c getTestData(){
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630330';
        vendor.c2g__CODABankIBANNumber__c='34413434234324';
        
        insert vendor;
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '500766630';
        client.c2g__CODABankIBANNumber__c='42342423423';
        client.c2g__CODAInputVATCode__c='a3e24000000HWMt';
        insert client;
        
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        insert contact;
        
        Login__c login = new Login__c();
        login.IdVendor__c = Vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        insert login;
        
        Application__c app= new Application__c();
        app.Vendor__c = vendor.id; 
        app.AccClient__c=client.id; 
        app.IdLoginCreate__c=login.Id;
        insert app;   
        
        return App;
    }
}