@isTest  
public class test_PaymentPromise{

    static testMethod void PaymentPromise(){
 
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '5007666313';
        client.BillingCity = 'Lx';
        client.BillingPostalCode = '3000-423';
        client.BillingStreet = 'BillingStreet';
        client.Website = 'webSite';
        client.Phone = '00351964639755';
        client.Fax = '00351964639755';
        client.c2g__CODAAccountTradingCurrency__c = 'AED';
        client.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        insert client;
        
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c = client.id;
        cc.Status__c='Open';
        insert cc;
        
        Payment_Promise__c pp = new Payment_Promise__c(); 
        pp.Collection_Case__c = cc.Id;
        pp.Status__c='Open';
        insert pp;
        
        Payment_Promise__c pp2 = new Payment_Promise__c(); 
        pp2.Collection_Case__c = cc.Id;
        pp2.Status__c='Open';
        insert pp2;     
        
    }
    
}