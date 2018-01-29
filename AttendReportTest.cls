@isTest
public class AttendReportTest {
    
    @isTest 
    static void testEnqueueJob() {
        Account vendor = new Account();
        vendor.Name = '1 Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630330213';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c='';
        insert vendor;     
        
        //New Account Client
        Account client = new Account();
        client.Name = '2 Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '5007666301213';
        client.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        client.c2g__CODAInputVATCode__c = 'a3e24000000HWMt';
        client.c2g__CODAInvoiceEmail__c='teste@email.com';
        client.c2g__CODATaxCalculationMethod__c='Gross';
        client.c2g__CODAAccountsReceivableControl__c='a2l24000000U9vnAAC';
        
        insert client;
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        insert app;
        
        System.enqueueJob(new AttendReports(app.Id, client.NIF__c,client.Id));
    }
}