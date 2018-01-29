@isTest  
public class test_TerminateSale{

    static testMethod void test_TerminateSale(){

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
        insert cc;
        
        ApexPages.StandardController sdc = new ApexPages.StandardController(cc);
        c_TerminateSale m_page = new c_TerminateSale(sdc);
        m_page.RedirectCollectionCase();
    }
}