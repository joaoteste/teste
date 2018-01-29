@isTest
public class Invocable_UpdateFirstApplicationTest {
    
    @isTest
    public static void testUpdateFirstApplication(){
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630330';
        insert vendor;
        
        //new Application
        Application__c app = new Application__c(Status__c = 'Application - Approved', Vendor__c = vendor.Id);
        List<Application__c> appList = new List<Application__c>();
        appList.add(app);
        
        Test.startTest();        
        Invocable_UpdateFirstApplication.UpdateFirstApplication(appList);
        Test.stopTest();
    }
}