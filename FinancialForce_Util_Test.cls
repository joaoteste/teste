@isTest(SeeAllData=true)
public class FinancialForce_Util_Test {  
    
    private static c2g__codaGeneralLedgerAccount__c clientesNacionais = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name = '21111 - CLIENTES NACIONAIS' LIMIT 1];  
    
    static c2g__codaGeneralLedgerAccount__c generalLedgerAccount = new c2g__codaGeneralLedgerAccount__c();
    //static c2g__codaTaxCode__c tax = new c2g__codaTaxCode__c(Tax_Zone__c = 'Mainland', c2g__GeneralLedgerAccount__c = clientesNacionais.ID);
    //static c2g__codaTaxRate__c taxesRate = new c2g__codaTaxRate__c(c2g__TaxCode__c = tax.ID, c2g__StartDate__c = Date.newInstance(2014, 1, 1));
    static BILL_ProductRegion billRegion = new BILL_ProductRegion('Input');

    
    static public c2g__codainvoice__c createInvoice(String cc, String clientId, String appId){
    	return createInvoice(cc,clientID,appID,true,'Sent');
    }   
    
    
    static public c2g__codaCreditNote__c createCreditNote(String cc, ID clientId, String appId, Boolean toPost, String statusEmail){
    	
        
        c2g__codainvoice__c si = createInvoice(cc, clientId, appId, false, statusEmail);
    	
        
    	Product2 prod = new Product2();
        prod.Name = 'TESTE112';
        prod.ProductCode =  'TESTE112';
        prod.Description='Aluguer Trimestral Proporcional Equipamento CANDOR RENTING S.A. TESTE112';
        prod.Moloni_Product_ID__c = 11112;
        prod.c2g__CODASalesRevenueAccount__c = clientesNacionais.Id;
        insert prod;
    	
    	c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
        creditNote.c2g__CreditNoteDate__c = date.today();
        creditNote.c2g__Account__c = clientID;
        creditNote.Credit_Note_Link__c = 'https://www.moloni.com/downloads/?h=90bcea1dab865378ff4212ffbf583400&d=191957160';
        creditNote.External_Credit_Note_Number_text__c = '45627';
        creditNote.CreditNote_Email_Status__c = statusEmail;
        creditNote.Renting_Application__c = appID;
        creditNote.c2g__Invoice__c = si.ID;
        insert creditNote;

        c2g__codaCreditNoteLineItem__c creditNotesLI = new c2g__codaCreditNoteLineItem__c();
        creditNotesLI.c2g__Product__c = billRegion.getProduct('PT01', 'Mainland');//tax.ID;
        creditNotesLI.C2g__TaxCode1__c = billRegion.getTaxCode('PT01', 'Mainland'); //prod.id;
        creditNotesLI.c2g__CreditNote__c = creditNote.id;
        creditNotesLI.c2g__DeriveUnitPriceFromProduct__c = false;
        insert creditNotesLI;
        
        if(toPost){
	        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
	        ref.Id = creditNote.Id;
	        c2g.CODAAPISalesCreditNote_6_0.PostCreditNote(null,ref);
	        system.debug('Posted');
        }
        
        return creditNote;
        
    } 
    
    static public c2g__codainvoice__c createInvoice(String cc, String clientId, String appId, Boolean toPost, String statusEmail){    

    	//insert tax;
        //insert taxesRate;        
        
        c2g__codainvoice__c invoice = new c2g__codainvoice__c();
        invoice.c2g__account__c = clientId;
        invoice.Collection_Case__c = cc;
        invoice.c2g__InvoiceDate__c = date.today();
        invoice.c2g__DueDate__c = date.today();
        invoice.c2g__InvoiceStatus__c='In progress';
        invoice.Invoice_express_Link__c = 'https://www.moloni.com/downloads/?h=90bcea1dab865378ff4212ffbf583400&d=191957160';
        invoice.Invoice_Express_Number_text__c = '11111';
        invoice.Invoice_Email_Status__c = statusEmail;
        
        
        invoice.Application__c=appId;
        insert invoice;
        
        Product2 prod = new Product2();
        prod.Name = 'TESTE11';
        prod.ProductCode =  'TESTE11';
        prod.Description='Aluguer Trimestral Proporcional Equipamento CANDOR RENTING S.A. TESTE11';
        prod.Moloni_Product_ID__c = 11111;
        prod.c2g__CODASalesRevenueAccount__c = clientesNacionais.Id;
        insert prod;
        

        
        c2g__codaInvoiceLineItem__c invoiceitem = new c2g__codaInvoiceLineItem__c();
        invoiceitem.c2g__Invoice__c = invoice.ID;
        invoiceitem.c2g__Quantity__c = 1;
        invoiceitem.c2g__LineNumber__c =1;
        invoiceitem.c2g__UnitPrice__c=10;
        invoiceitem.c2g__Product__c= billRegion.getProduct('PT01', 'Mainland'); //prod.id;
        invoiceitem.c2g__DeriveUnitPriceFromProduct__c=false;
        invoiceitem.c2g__TaxCode1__c= billRegion.getTaxCode('PT01', 'Mainland'); //tax.ID;
        insert invoiceitem;
        system.debug('invoice ID: ' + invoice.ID);  
        
        if(toPost){
	        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
	        ref.Id = invoice.Id;
	        c2g.CODAAPISalesInvoice_9_0.PostInvoice(null,ref);
        }
        
        return invoice;    
        

    }       
    
    static public void setFinancialForceConfiguration(){
		Group testGroup = new Group(Name='test group', Type='Queue');
		insert testGroup;
		QueuesObject testQueue ; 
		System.runAs(new User(Id=UserInfo.getUserId())){
		    List<queuesobject >  listQueue = new List<queuesobject >();
		    queuesobject q1 = new queuesobject (queueid=testGroup.id, sobjecttype='Case'); 
		    listQueue.add(q1);
		    queuesobject q2 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaAccountingCurrency__c'); 
		    listQueue.add(q2);
		    queuesobject q3 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaPurchaseInvoice__c'); 
		    listQueue.add(q3);
		    queuesobject q4 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCompany__c'); 
		    listQueue.add(q4);
		    queuesobject q5 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaYear__c'); 
		    listQueue.add(q5);
		    queuesobject q6 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaInvoice__c'); 
		    listQueue.add(q6);
		    queuesobject q7 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCreditNote__c'); 
		    listQueue.add(q7);
		    insert  listQueue;
		
		    GroupMember GroupMemberObj = new GroupMember();
		    GroupMemberObj.GroupId = testGroup.id;
		    GroupMemberObj.UserOrGroupId = UserInfo.getUserId();
		    insert GroupMemberObj;
		}        
	
		c2g__codaCompany__c company = new c2g__codaCompany__c();
		company.Name = 'Test Record';
		company.c2g__CashMatchingCurrencyMode__c = 'Test Account';
		company.c2g__YearEndMode__c = 'Test Code';
		company.c2g__ExternalId__c = 'ABCDE1234567876';
		company.c2g__LogoURL__c ='ww.XYZ.com';
		company.c2g__ECCountryCode__c = 'AE' ;
		company.c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA' ;
		company.c2g__Website__c = 'ww.xyz.com';
		company.c2g__Country__c ='US';
		company.ownerid = testGroup.Id;
		company.c2g__CashMatchingCurrencyMode__c = 'Account';
		insert company;
		
		c2g__codaYear__c yr= new c2g__codaYear__c();
		yr.Name ='2017';
		yr.c2g__AutomaticPeriodList__c =  true;
		yr.c2g__OwnerCompany__c = company.id;
		yr.c2g__ExternalId__c = 'yzsd1234';
		yr.c2g__NumberOfPeriods__c =11;
		yr.c2g__StartDate__c =  system.today() - 10;
		yr.c2g__Status__c = 'Open';
		yr.c2g__PeriodCalculationBasis__c = '445';
		yr.c2g__YearEndMode__c = 'Full Accounting Code' ; 
		yr.c2g__UnitOfWork__c = 12;
		yr.ownerid = testGroup.Id;
		insert yr;
		
		c2g__codaPeriod__c prd = new c2g__codaPeriod__c();
		prd.Name ='Test2017';
		prd.c2g__ExternalId__c ='abdc12345';
		prd.c2g__StartDate__c = System.today()-10;
		prd.c2g__EndDate__c= System.today()+10;
		prd.c2g__OwnerCompany__c = company.id;
		prd.c2g__PeriodNumber__c ='123';
		prd.c2g__Description__c ='test Desc';
		prd.c2g__PeriodGroup__c = 'Q1';
		prd.c2g__PeriodNumber__c = '1';
		prd.c2g__YearName__c = yr.id;
		insert prd;
		
		c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
		userCompany.c2g__Company__c =company.id;
		userCompany.c2g__User__c = userInfo.getUserId();
		userCompany.c2g__ExternalId__c = 'ABCDE1234567876';
		userCompany.c2g__UnitOfWork__c = 111 ;
		insert  userCompany;
		
		c2g__codaAccountingCurrency__c accCurrency = new c2g__codaAccountingCurrency__c();
		accCurrency.c2g__OwnerCompany__c = company.id;
		accCurrency.c2g__DecimalPlaces__c = 2;
		accCurrency.Name = 'USD';
		accCurrency.c2g__Dual__c = true ;
		accCurrency.c2g__Home__c = true ;
		//accCurrency.ownerid = testGroup.Id;
		insert accCurrency;
	
		c2g__codaGeneralLedgerAccount__c GLAcc = new c2g__codaGeneralLedgerAccount__c();
		GLAcc.Name = 'Retained Earnings';
		GLAcc.c2g__BalanceSheet1__c ='Balance Sheet'; 
		GLAcc.c2g__ExternalId__c ='testID';
		GLAcc.c2g__ReportingCode__c = '1234567543333';
		GLAcc.c2g__UnitOfWork__c =123;
		GLAcc.c2g__TrialBalance1__c = 'Balance Sheet' ;
		GLAcc.c2g__Type__c = 'Balance Sheet' ;
		insert GLAcc;
     }
    

}