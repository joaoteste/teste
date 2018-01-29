@isTest
public class ContractsControllerTests {
    
	private static Application__c testApp =  getTestData();
    
    @isTest
    public static void testeContractController(){
        
        PageReference pageRef1 = Page.contract;
        test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('id', testApp.id);
        ApexPages.StandardController  sc = new ApexPages.StandardController(testApp);
        contractcontroller cc = new ContractController(sc);
        
        
        PageReference pageRef2 = Page.certificate;
		ApexPages.currentPage().getParameters().put('id', testApp.id);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(testApp);
        certificatecontroller cc2 = new certificatecontroller(sc2);
        
        testApp.Payment_Method__c=null;
        update testApp;
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(testApp);
        certificatecontroller cc3 = new certificatecontroller(sc3);
        
    }
    
    //Create data test
    private static Application__c getTestData() {
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630311';
        //vendor.c2g__CODABankIBANNumber__c ='PT50000700000003253768222';
        insert vendor;

        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendor.Id;
        insert vendorContact;

        //New Login
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Username__c = 'vendor@email.pt';
        login.Vendor_Vendor__c = vendorContact.Id;
        insert Login;
        Authenticate.generatorPassword(login.Id, 4);
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '504092090';
        insert client;
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        insert contact;
        
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        // app.Client_Signer_1__c=con.id;
        //app.Vendor_Primary__c=convendor.id;
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
        app.Vendor_Invoice_Amount__c = 2402.63;
        app.Equipment_Cost__c = 2402.63;
        app.Insurance_Special_Value__c = 9.31;
        app.Insurance_Movement_value__c = 11.01;
        app.Client_BBAN__c = '004563904014640899590';
        app.Payment_Method__c='ATM Reference';
        app.Payment_Freq__c ='Monthly';
        app.Payment_Amount__c = 2500;
        app.Invoice_Payment_Date__c =date.today();
        app.Generate_Billing__c=true;
        app.Annual_Interest_Rate__c=9.2;
        app.Vendor_Diluted_Doc_Fee__c=true;
        app.ATM_Reference__c=true;
        app.Interim_Fee__c=true;
        app.ATM_Reference_Costs__c=10;
        app.eSignature_Contract__c=true;
        app.Paper_Contract__c=true;
        app.Insurance_Pro_Rata_Checkbox__c=true;
        insert app;

        return app;
    }
}