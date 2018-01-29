@isTest(SeeAllData=true)
public class CreateDueSalesInvoicesTest {
    
    public static CronTrigger fetchCronTrigger(String jobId) {
        return [
            select CronExpression,
            TimesTriggered, 
            NextFireTime
            from CronTrigger
            where Id = :jobId
        ];
    }
    
    static testMethod void testCreateDueSalesInvoices() {
        BILL_ProductRegion billRegion = new BILL_ProductRegion('Input');
        Account vendor = new Account();
        vendor.Name = '1 Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630330213';
        vendor.BillingPostalCode = '1234-123';
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
        client.BillingPostalCode = '1234-123';
        insert client;
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        insert app;
        
        ID prod = billRegion.getProduct('PT01', 'Mainland');
        ID productTaxCode = billRegion.getTaxCode('PT01', 'Mainland');        
        
        list<Billing_Contract__c> ListBillContract = new List<Billing_Contract__c>();
        list<Billing_Contract_Line_Item__c> listBillContractLineItems = new List<Billing_Contract_Line_Item__c>();
        
        for(integer i=0; i<30; i++){
            
            Billing_Contract__c BillCont=New Billing_Contract__c(Name=app.name, Account__c=client.ID, Account_Vendor__c=vendor.ID, 
                                                                  Contract_Start_Date__c= date.today(),
                                                                 Billing_Date_Override__c=date.today(), application__c=app.id );
            ListBillContract.add(BillCont);
        }
        
        insert ListBillContract;
        
        for(Billing_Contract__c BillCont : ListBillContract){   
            
            Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='monthly',
                                                                                         Line_Item_Start_Date__c=date.today(), Line_Item_End_Date__c=date.today()+15, 
                                                                                         Active__c=true, Sales_Price__c=105, Product__C=prod, Quantity__c=1,principal__c= 54.8,
                                                                                         interest__C=50.2, application__c=app.id, Product_Tax_Code__c = productTaxCode);
            
            listBillContractLineItems.add(BillContItem);
        }
        
        insert listBillContractLineItems;
        

        Test.startTest();
        
        //String jobId = System.schedule('_unittest_scheduled_: 001' , '0 0 4 * * ?' , new CreateDueSalesInvoices());
        CreateDueSalesInvoices cdsi = new CreateDueSalesInvoices();
   
        String jobId = System.schedule('Create Due Sales Invoices'+ date.today().addMonths(2).month(), '0 0 4 * * ?', cdsi);
            
        CronTrigger ct = fetchCronTrigger(jobId);
        
        System.assertEquals('0 0 4 * * ?', ct.CronExpression,'Did not get the same Cron Expression back');
        
        Test.stopTest();
    }

    static testMethod void testdummy() {
        BillingProcess.dummy();
    }
}