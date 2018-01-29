@isTest 
public class test_ContactsOfGuaranteesController {
    
    private static Application__c testApp =  getTestData();
    
    public static testMethod void testMyController() {
        
        PageReference pageRef = Page.ContractWithGuarantee;
        Test.setCurrentPage(pageRef); 
        //ApexPages.currentPage().getParameters().put('id', 'a012400000hGhqa');//6013
        //ApexPages.currentPage().getParameters().put('id', 'a019E000000PXg4');//sandbox
        ApexPages.currentPage().getParameters().put('id', 'a012400000WTrbKAAT');//lawsuit
        ApexPages.StandardController  sc = new ApexPages.StandardController(testApp);
        ContactsOfGuaranteesController controller = new ContactsOfGuaranteesController(sc);
		CallMethods(controller);
    }
    
    private static void CallMethods(ContactsOfGuaranteesController controller) {
        controller.getFiador0Address();
        controller.getFiador0City();
        controller.getFiador0Name();
        controller.getFiador0NIF();
        controller.getFiador0PostalCode();
        controller.getFiador1Address();
        controller.getFiador1City();
        controller.getFiador1Name();
        controller.getFiador1NIF();
        controller.getFiador1PostalCode();
        
        controller.getFiadorContact(0);
        
        controller.getFiadorAddress(9);
        controller.getFiadorContact(9);
        controller.getFiadorName(9);
        controller.getFiadorNIF(9);
        controller.getFiadorPostalCode(9);
        controller.getFiadorContact(9);
    }
    
    private static Application__c getTestData(){
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630330';
        insert vendor;
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '500766630';
        //client.NIF__c = '501255176';//sandbox
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