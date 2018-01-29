@isTest 
public class processingInfoDBQueueableTest {
    
    static testmethod void teste1(){

        //string clientNif = '500766630';        
        Account Client = new Account();
        Client.name = Client.NIF__c = '500766630';
        Client.Type = 'Customer - Channel';
        insert Client;

        System.debug('Client: '+Client);
        System.assertNotEquals(null,Client,'Não inseriu client.');

        Account Vendor = new Account();
        Vendor.Name    = 'Test Account Vendor'; 
        Vendor.Type    = 'Channel Partner / Vendor';
        Vendor.NIF__c  = '503630330';
        Vendor.Product_Type__c  = 'Pure IT';
        insert Vendor;

        System.debug('Vendor: '+Vendor);        
        System.assertNotEquals(null,Vendor,'Não inseriu Vendor.');

        Contact contact  = new contact();
        contact.LastName = 'Doe';
        contact.Email    = 'test@email.com';
        contact.Role__c  = 'Binding Power';
        insert contact;

        System.debug('Contact: '+contact);
        System.assertNotEquals(null,contact,'Não inseriu Contacto.');
        
        
        Login__c TestVendorLogin         = new Login__c();
        TestVendorLogin.IdVendor__c      = Vendor.Id;
        TestVendorLogin.Vendor_Vendor__c = contact.Id;
        insert testVendorLogin;
        
        Application__c app0 = new Application__c();
        app0.accClient__c = Client.id;
        app0.Vendor__c    = Vendor.id;
        insert app0;
        System.assertNotEquals(null,app0.Id,'Não inseriu APP.');
        //String appId = VendorHomePage.RequestApplication(Vendor.Id, clientNif, TestVendorLogin.Id);

        Application__c app = [SELECT id, name, status__c, accClient__c,accClient__r.nif__c, accClient__r.name, 
                                reject_reason__c, accClient__r.id, CreatedDate FROM Application__c Where id=:app0.id];

        System.debug('App: '+App);
        /*
        ScoreCard_Config__c testsc = new scorecard_config__c();
        testsc.recordtype.Name = 'Score Card';
        testsc.FieldName__c = 'InformaDB Status OK?(YES/NO)';
        testsc.Matching_Value__c = 'YES';
        insert testsc;
        */
        Test.setCreatedDate(app.Id, app.CreatedDate.addMinutes(-15));
        Test.setCreatedDate(app.Id, app.CreatedDate.addHours(-1));    
        
        Test.startTest();  
        System.enqueueJob(new processingInfoDBQueueable());
        Test.stopTest();

    }
}