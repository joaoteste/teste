//Created by BP -18/04/17
@isTest (SeeAllData=true)
public class UpdateAccountUsedCreditLine_TEST 
{    
    /******************************************************************************************************/
    /*                                      BEHAVIOUR METHODS                                             */
    /******************************************************************************************************/            
    @isTest static void updateCreditLine_Test()
    {        
        Account vendor                    = new Account();
        vendor.Name                       = '2 Test Account Vendor'; 
        vendor.Type                       = 'Channel Partner / Vendor';
        vendor.NIF__c                     = '245118188';
        vendor.c2g__CODABankIBANNumber__c = 'PT50001000003290869000185';
        vendor.Email__c                   = '';
        vendor.Tax_Zone__c				  = 'Mainland';
        insert vendor;     
        /*
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAccount.Name                             = '21111 - CLIENTES NACIONAIS';
        generalLedgerAccount.c2g__ReportingCode__c            = '21110';
        generalLedgerAccount.c2g__Type__c                     = 'Profit and Loss';
        upsert generalLedgerAccount;    
        ID glacc = generalLedgerAccount.id;
        */
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = [Select Id FROM c2g__codaGeneralLedgerAccount__c WHERE name = '21111 - CLIENTES NACIONAIS'];
                
        /*
        c2g__codaTaxCode__c taxv2          = new c2g__codaTaxCode__c();
        taxv2.Name                         = 'textTaxv2';
        taxv2.c2g__Description__c          = 'testTaxv2 description';   
        taxv2.c2g__GeneralLedgerAccount__c = generalLedgerAccount.Id;
        insert taxv2;        
        */    
        c2g__codaTaxCode__c taxv2 =[SELECT ID FROM c2g__codaTaxCode__c WHERE name='VCONT23'];
        //New Account Client
        Account client                          = new Account();
        client.Name                             = '3 Test Account Client'; 
        client.Type                             = 'Customer - Channel';
        client.NIF__c                           = '511414148';
        client.c2g__CODABankIBANNumber__c       = 'PT50004563904014640899590';
        client.c2g__CODAInputVATCode__c         = taxv2.id;
        client.c2g__CODAInvoiceEmail__c         = 'teste@email.com';
        client.c2g__CODATaxCalculationMethod__c = 'Gross';
        client.BillingPostalCode                = '1234-423';                
        client.Tax_Zone__c 						= 'Mainland';
        client.c2g__CODAAccountsReceivableControl__c=  generalLedgerAccount.id;
        
        insert client;
        Application__c app = new Application__c();
        app.AccClient__c   = client.ID;
        app.Vendor__c      = vendor.ID;
        insert app;       
        
        Product2 prod=[SELECT id, Description, c2g__CODAInputTaxCode__c, c2g__CODAInputTaxCode__r.Area__c,  name, ProductCode 
                         FROM Product2  
                        WHERE ProductCode = 'PT01' 
                          AND c2g__CODAInputTaxCode__r.Area__c = 'Mainland'];
        
        BILL_ProductRegion billRegion = new BILL_ProductRegion('Input');
        ID prodID = billRegion.getProduct('PT01', 'Mainland');
        ID productTaxCode = billRegion.getTaxCode('PT01', 'Mainland');    
        
        Billing_Contract__c BillCont=New Billing_Contract__c(Name=app.name, Account__c=client.ID, Account_Vendor__c=vendor.ID, 
                                                              Contract_Start_Date__c= date.today(),
                                                             Billing_Date_Override__c=date.today(), application__c=app.id );

        insert BillCont;
        BillCont = [Select Id,Name,Account__c,Account_Vendor__c,Contract_Start_Date__c,Billing_Date_Override__c,application__c 
                    From Billing_Contract__c
                    where id = :BillCont.Id];
        
        Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='monthly',
                                                                                     Line_Item_Start_Date__c=date.today(), Line_Item_End_Date__c=date.today()+15, 
                                                                                     Active__c=true, Sales_Price__c=105, Product__C=prodId, Quantity__c=1,
                                                                                     Product_Tax_Code__c = productTaxCode ,
                                                                                     interest__C=50.2, Principal__c = 20, application__c=app.id);
        insert BillContItem;
        system.debug('BillCont: ' + BillCont);
		
        Id ruleId = [select id 
                 from ffirule__IntegrationRule__c 
                 where name ='Billing Contract to Sales Invoice'].id;

        Set<Id> BillIds = new Set<Id>{BillCont.id};

        // CriaÃ§Ã£o do sales Invoice via click link rule
        //if(!QA)
        List<ID> targetIds = ffirule.RuleService.run(new List<Id>(BillIds), ruleId);
        System.debug('targetIds: ' + targetIds);
        /*BILL_BillingProcess bp =  new BILL_BillingProcess();
        bp.createInvoices(BillCont);
       */
        List<c2g__codaInvoice__c> invList = [SELECT ID, Post_SalesInvoice__c,c2g__Transaction__c 
                                     FROM c2g__codaInvoice__c 
                                    WHERE Billing_Contract__c=:BillCont.Id //added
                                 ORDER BY createddate DESC LIMIT 1];
        
        c2g__codaInvoice__c invFromList = invList.get(0);
        
        c2g.CODAAPICommon.Reference refinv = new c2g.CODAAPICommon.Reference();
        List<c2g.CODAAPICommon.Reference> refsinv = new List<c2g.CODAAPICommon.Reference>();
        refinv.Id = invFromList.Id;
        refsinv.add(refinv);

        c2g.CODAAPISalesInvoice_6_0.BulkPostInvoice(null, refsinv);
        /*inv.Post_SalesInvoice__c = true;
        update inv;*/
         c2g__codaInvoice__c inv = [SELECT ID, Post_SalesInvoice__c,c2g__Transaction__c 
                                     FROM c2g__codaInvoice__c 
                                    WHERE Id=:invFromList.Id //added
                                 ORDER BY createddate DESC LIMIT 1];
        
        c2g__codaTransaction__c testTransaction =[SELECT ID,name,c2g__AccountOutstandingTotal__c FROM c2g__codaTransaction__c where id=:inv.c2g__transaction__c ];
        System.debug('testTransaction: '+testTransaction);
          
        c2g__codaPeriod__c periodDueDate = [SELECT ID FROM c2g__codaPeriod__c WHERE name = '2017/004'];
        
        c2g__codaCashEntry__c testCashEntry     = new c2g__codaCashEntry__c();
        testCashEntry.c2g__BankAccount__c       = [SELECT ID FROM c2g__codaBankAccount__c WHERE name='Banco BPI - Conta 2 - Clientes'].id;
        testCashEntry.c2g__CashEntryCurrency__c = [SELECT ID,c2g__BankAccountCurrency__r.Id FROM c2g__codaBankAccount__c WHERE name='Banco BPI - Conta 2 - Clientes'].c2g__BankAccountCurrency__r.Id;
        testCashEntry.c2g__Period__c            = periodDueDate.id;
        testCashEntry.c2g__Account__c           = client.Id;
        testCashEntry.c2g__Type__c              = 'Receipt';
        testCashEntry.c2g__Date__c              = Date.today();
        testCashEntry.c2g__PaymentMethod__c     = 'Electronic';
        testCashEntry.c2g__ChargesGLA__c        = generalLedgerAccount.Id;
        insert testCashEntry;
        
        c2g__codaCashEntryLineItem__c testCashEntryLineItem = new c2g__codaCashEntryLineItem__c();
        testCashEntryLineItem.c2g__Account__c               = client.id;
        testCashEntryLineItem.c2g__CashEntry__c             = testCashEntry.Id;
        testCashEntryLineItem.c2g__CashEntryValue__c        = [SELECT   c2g__InvoiceTotal__c FROM c2g__codainvoice__c WHERE ID=:inv.id].c2g__InvoiceTotal__c;
        insert testCashEntryLineItem;     
        
        System.debug('ANTES DO POST...');
        Test.startTest();
        //POST CASH ENTRY UTIL PARA REUTILIZAR
        List<c2g.CODAAPICommon.Reference> cashEntryRefs = new List<c2g.CODAAPICommon.Reference>();        
        cashEntryRefs.add(c2g.CODAAPICommon.getRef(testCashEntry.Id, null));
        c2g.CODAAPICashEntry_7_0.BulkPostCashEntry(null, cashEntryRefs);        
        
        System.debug('ANTES DO MATCH...c2g__Status__c: '+[select c2g__Status__c from c2g__codaCashEntry__c where id=:testCashEntry.Id]);
        
        ID aux = [SELECT c2g__Transaction__c FROM c2g__codaInvoice__c WHERE ID = :inv.id].c2g__Transaction__c;
        List<c2g__codaTransactionLineItem__c> testTLIS = [SELECT ID,c2g__AccountValue__c FROM c2g__codaTransactionLineItem__c WHERE c2g__Transaction__c =:aux AND c2g__LineType__c='Account'];
        
        List<c2g__codaTransactionLineItem__c> help =[SELECT Id, c2g__AccountValue__c
                                                       FROM c2g__codaTransactionLineItem__c                                     
                                                      WHERE c2g__Transaction__r.c2g__CashEntry__c = :testCashEntry.Id 
                                                        AND c2g__LineType__c = 'Account' LIMIT 1 //added limit coz when runs for of tlis get repeated
                                                    ];
        testTLIS.addAll(help);
                 
        FF_Utils.doMatch(client.Id, periodDueDate.Id,testTLIS);
        Test.stopTest();         
        System.debug('DEPOIS DO MATCH...');
        System.debug('FINAL: '+[SELECT ID,name,c2g__paymentstatus__c FroM c2g__codainvoice__c WHERE id=:inv.id]);
    }
}//end class