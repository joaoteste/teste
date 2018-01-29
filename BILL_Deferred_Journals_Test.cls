@isTest(SeeAllData = True)
public class BILL_Deferred_Journals_Test {

    @isTest
    static Map<String, Product2> getProd(){
        Map<String, Product2> prodPerCode =new Map<String, Product2>();
        list<Product2>productList=[SELECT id, Description, ProductCode, c2g__CODAInputTaxCode__c, c2g__CODAInputTaxCode__r.Area__c,  name 
                                   FROM Product2  
                                   WHERE c2g__CODAInputTaxCode__r.Area__c = 'Mainland'];
        
        
        
        //Map<String, Map<String, Product2>> productMap = new Map<String, Map<String, Product2>>();
        for(Product2 prodAux : productList)
        {
            prodPerCode.put(prodAux.ProductCode, prodAux);
        }
        return prodPerCode;
    }
    
    @isTest
    static Map<String, ID> getData(){
        Map<String, ID> dataMap = new Map<String,ID>();
        Map<String, Product2> prodPerCode =new Map<String, Product2>();
        Account vendor                    = new Account();
        vendor.Name                       = '2 Test Account Vendor'; 
        vendor.Type                       = 'Channel Partner / Vendor';
        vendor.NIF__c                     = '245118188';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c                   = '';
        insert vendor; 
        dataMap.put('vendorID', vendor.id);
        
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
        
        c2g__codaTaxCode__c taxv2 =[SELECT ID FROM c2g__codaTaxCode__c WHERE name='VCONT23'];
        //New Account Client
        Account client                          = new Account();
        client.Name                             = '3 Test Account Client'; 
        client.Type                             = 'Customer - Channel';
        client.NIF__c                           = '511414148';
        client.c2g__CODABankIBANNumber__c       = 'PT50004563904014640899590';
        client.c2g__CODAInputVATCode__c         = taxv2.id;//'a3e24000000HWMt';
        client.c2g__CODAInvoiceEmail__c         = 'teste@email.com';
        client.c2g__CODATaxCalculationMethod__c = 'Gross';
        client.BillingPostalCode                = '1234-423';                
        
        client.c2g__CODAAccountsReceivableControl__c=  generalLedgerAccount.id;
        
        insert client;
        dataMap.put('clientID', client.id);
        
        application__c app=new application__c();
        app.AccClient__c   = client.ID;
        app.Vendor__c      = vendor.ID;
        
        insert app;       
        dataMap.put('appID', app.id);
        
        return dataMap;
        
    }
    
    @isTest
    public static Billing_Contract__c createBillingMonthly(){
        Map<String, ID> dataMap = getData();
        Map<String, Product2> prodPerCode=getProd();
        application__c app=new application__c(id=dataMap.get('appID'));
        app.Insurance_Value__c=134;
        app.Insurance_Type__c='Static Risk';
        app.Delivery_Certificate_Signed__c=date.newInstance(2017,04,15);
        app.Payment_Freq__c='Monthly';
        app.First_Beginning_Of_Term__c = Date.newInstance(2017, 04, 14);
        app.Invoice_Payment_Date__c  = Date.newInstance(2017, 04, 10);
        
        update app;
        Billing_Contract__c BillCont=New Billing_Contract__c(Name=app.name, Account__c=dataMap.get('clientID'), Account_Vendor__c=dataMap.get('vendorID'), 
                                                             Contract_Start_Date__c= date.today(),
                                                             Billing_Date_Override__c=date.today(), application__c=app.id );
        
        insert BillCont;
        
        list<Billing_Contract_Line_Item__c> listBillItems=new list<Billing_Contract_Line_Item__c>();
        
        Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='Monthly',
                                                                                     Line_Item_Start_Date__c=date.today(), Line_Item_End_Date__c=date.today()+15, 
                                                                                     Active__c=true, Sales_Price__c=105, Product__C=prodPerCode.get('PT01').Id, Quantity__c=1,
                                                                                     interest__C=50.2, principal__c= 100, application__c=app.id);
        
        listBillItems.add(BillContItem);
        
        Billing_Contract_Line_Item__c propBillingItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='Monthly',
                                                                                        Line_Item_Start_Date__c=date.newInstance(2017,04,15), Line_Item_End_Date__c=date.newInstance(2017,05,01), 
                                                                                        Active__c=true, Sales_Price__c=50, Product__C=prodPerCode.get('PT11').Id, Quantity__c=1,
                                                                                        application__c=app.id);
        listBillItems.add(propBillingItem);
        
        Billing_Contract_Line_Item__c insuranceBillingItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='Monthly',
                                                                                             Line_Item_Start_Date__c=date.newInstance(2017,04,15), Line_Item_End_Date__c=date.newInstance(2017,05,01), 
                                                                                             Active__c=true, Sales_Price__c=20, Product__C=prodPerCode.get('PT02').Id, Quantity__c=1,
                                                                                             application__c=app.id);
        
        listBillItems.add(insuranceBillingItem);
        
        insert listBillItems;
        
        return BillCont;
    }
    
    @isTest
    static Billing_Contract__c createBillingQuarterly(){
        Map<String, ID> dataMap = getData();
        Map<String, Product2> prodPerCode=getProd();
        application__c app=new application__c(id=dataMap.get('appID'));
        app.Insurance_Value__c=134;
        app.Insurance_Type__c='Static Risk';
        app.Delivery_Certificate_Signed__c=date.newInstance(2017,04,15);
        app.Payment_Freq__c='Quarterly';
        app.First_Beginning_Of_Term__c = Date.newInstance(2017, 03, 14);
        app.Invoice_Payment_Date__c  = Date.newInstance(2017, 02, 13);
        
        update app;
        list<Billing_Contract_Line_Item__c> listBillItems=new list<Billing_Contract_Line_Item__c>();
        
        Billing_Contract__c BillCont=New Billing_Contract__c(Name=app.name, Account__c=dataMap.get('clientID'), Account_Vendor__c=dataMap.get('vendorID'), 
                                                             Contract_Start_Date__c= date.today(),
                                                             Billing_Date_Override__c=date.today(), application__c=app.id );
        
        insert BillCont;
        // insert rent line item
        Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='Quarterly',
                                                                                     Line_Item_Start_Date__c=date.newInstance(2017,04,15), Line_Item_End_Date__c=date.newInstance(2017,05,01), 
                                                                                     Active__c=true, Sales_Price__c=450, Product__C=prodPerCode.get('PT09').Id, Quantity__c=1,
                                                                                     interest__C=87.2, principal__c= 362.8, application__c=app.id);
        listBillItems.add(BillContItem);
        
        // insert insurance line item
        Billing_Contract_Line_Item__c propBillingItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='Quarterly',
                                                                                        Line_Item_Start_Date__c=date.newInstance(2017,04,15), Line_Item_End_Date__c=date.newInstance(2017,05,01), 
                                                                                        Active__c=true, Sales_Price__c=50, Product__C=prodPerCode.get('PT11').Id, Quantity__c=1,
                                                                                        application__c=app.id);
        listBillItems.add(propBillingItem);
        
        Billing_Contract_Line_Item__c insuranceBillingItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='Quarterly',
                                                                                             Line_Item_Start_Date__c=date.newInstance(2017,04,15), Line_Item_End_Date__c=date.newInstance(2017,05,01), 
                                                                                             Active__c=true, Sales_Price__c=20, Product__C=prodPerCode.get('PT02').Id, Quantity__c=1,
                                                                                             application__c=app.id);
        listBillItems.add(insuranceBillingItem);
        
        insert listBillItems;
        
        return BillCont;
    }

    @isTest
    public static void TestMonthlyDeferral(){
        Test.startTest();
        Billing_Contract__c BillCont=createBillingMonthly();
        BillingProcess.Create_Due_Sales_invoice(BillCont.ID);
        c2g__codaInvoice__c inv = [SELECT ID, Post_SalesInvoice__c,c2g__Transaction__c, c2g__InvoiceDate__c
                                   FROM c2g__codaInvoice__c ORDER by createddate DESC LIMIT 1];
        inv.Post_SalesInvoice__c = true;
        update inv;
        Test.stopTest();
        
    }
    
    @isTest
    public static void TestQuarterlyDeferral(){
        Test.startTest();
        
        Billing_Contract__c BillCont=createBillingQuarterly();
        BillingProcess.Create_Due_Sales_invoice(BillCont.ID);
        c2g__codaInvoice__c inv = [SELECT ID, Post_SalesInvoice__c,c2g__Transaction__c 
                                   FROM c2g__codaInvoice__c ORDER by createddate DESC LIMIT 1];
        inv.Post_SalesInvoice__c = true;
        update inv;
        Test.stopTest();
        
    }  
    
    @isTest
    public static void TestQuarterlyDeferral2(){
        Test.startTest();
        
        Set<ID> journalSet = new Set<iD>();
        /*journal.add('a310E00000008Yp');
journal.add('a310E00000008Yq');
journal.add('a310E00000008Yr');
journal.add('a310E00000008Ys');
journal.add('a310E00000008Yt');
journal.add('a310E00000008Yu');*/
        
        List<c2g__codaJournal__c> journalList = [Select id From c2g__codaJournal__c 
                                                 where c2g__JournalStatus__c = 'Complete' and c2g__Type__c = 'Manual Journal' and c2g__CanceledJournal__c = false 
                                                 limit 20];
        
        for(c2g__codaJournal__c journal : journalList){
            journal.to_be_deferred__c = true;
            if(journal.Deferred_Type__c == null){
                journal.Deferred_Type__c = 3;
            }
        }
        
        update journalList;
        
        for(c2g__codaJournal__c journal : journalList){
            journalSet.add(journal.id);
        }
        
        BILL_Deferred_Journals billDefered = new BILL_Deferred_Journals();
        billDefered.Create_Deferred_Journals(journalSet);
        
        Test.stopTest();
    } 
/*
    @isTest
    public static void test1(){
        List<ID> billingItensInvoicedList = new List<ID>();
        Set<ID> journalsIDToPost = new Set<ID>();
        journalsIDToPost.add('a31260000005Vw4');
        //CreateDeferredJnl.Create_Deferred_Journals(journalID);
        //journalsIDToPost.addAll(UTIL_CancelAndCreateJournals.createJournalsListBLI(billingItensInvoicedList));
        System.debug(' queries '+  Limits.getQueries() );
        UTIL_CancelAndCreateJournals.postJournal(journalsIDToPost);
        System.debug(' queries '+  Limits.getQueries() );
    }*/

}