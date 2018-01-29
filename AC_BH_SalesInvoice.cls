//Tests:AC_AssignmentContractAPI_Test
global class AC_BH_SalesInvoice implements Database.Batchable<sObject>, Database.Stateful{

    ID newAcc;
    List<ID> salesInvoiceInputList;
    
    global AC_BH_SalesInvoice(ID newAcc, List<ID> salesInvoiceInputList){
    	this.newAcc = newAcc;
    	this.salesInvoiceInputList = salesInvoiceInputList;
    }
  
    global Database.QueryLocator start(Database.BatchableContext BC){
   	 	    
   	    String query = 'SELECT ID, c2g__Account__c, Application__c, c2g__CopyAccountValues__c, c2g__CopyDefaultPrintedTextDefinitions__c, c2g__InvoiceCurrency__c,'+
   	    				'c2g__InvoiceRate__c, c2g__CustomerReference__c, c2g__DeriveCurrency__c, c2g__DeriveDueDate__c, c2g__DerivePeriod__c, c2g__Dimension1__c,'+
   	    				'c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, c2g__DiscardReason__c, c2g__DualRate__c, c2g__ExternalId__c, c2g__IntercompanyTransfer__c,'+
   	    				'c2g__InvoiceDate__c, c2g__Opportunity__c, c2g__OwnerCompany__c, c2g__PrintedText1AllowEdit__c, c2g__PrintedText1Heading__c, c2g__PrintedText1Text__c,'+
   	    				'c2g__PrintedText1TextDefinitionName__c, c2g__PrintedText2AllowEdit__c, c2g__PrintedText2Heading__c, c2g__PrintedText2Text__c, c2g__PrintedText2TextDefinitionName__c,'+
   	    				'c2g__PrintedText3AllowEdit__c, c2g__PrintedText3Heading__c, c2g__PrintedText3Text__c, c2g__PrintedText3TextDefinitionName__c, c2g__PrintedText4AllowEdit__c,'+
   	    				'c2g__PrintedText4Heading__c, c2g__PrintedText4Text__c, c2g__PrintedText4TextDefinitionName__c, c2g__PrintedText5AllowEdit__c, c2g__PrintedText5Heading__c,'+
   	    				'c2g__PrintedText5Text__c, c2g__PrintedText5TextDefinitionName__c, c2g__PrintStatus__c, c2g__SalesTaxDocumentCode__c, c2g__SalesTaxStatus__c, c2g__UnitOfWork__c,'+
   	    				'CR_Sepa_Record__c, ffbext__Approved__c '+
   	    				'FROM c2g__codaInvoice__c '+
                        'WHERE ID in :salesInvoiceInputList';
                        
         return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__codaInvoice__c> salesInvoiceList){
    	
    	c2g__codaInvoice__c newSalesInvoice = new c2g__codaInvoice__c();
    	c2g__codaInvoice__c siToChange = salesInvoiceList[0];
    	
    	Application__c app = [SELECT ID, Payment_Timing__c FROM Application__c WHERE ID = :siToChange.Application__c];
    	newSalesInvoice = createInvoiceForAccount(siToChange, newAcc, app);
    	
    	insert newSalesInvoice;
    	
    	List<c2g__codaInvoiceLineItem__c> oldInvoiceLineItemsList = [SELECT ID, c2g__Product__c FROM c2g__codaInvoiceLineItem__c WHERE c2g__Invoice__c =:siToChange.ID];
    	
    	List<c2g__codaInvoiceLineItem__c> newInvoiceLineItemsList = new List<c2g__codaInvoiceLineItem__c>();
    	
    	for(c2g__codaInvoiceLineItem__c ili : oldInvoiceLineItemsList){
    		system.debug(ili);
    		c2g__codaInvoiceLineItem__c newInvoiceLineItem = ili.clone(false, true, false, false);
    		newInvoiceLineItem.c2g__Invoice__c = newSalesInvoice.ID;
    		newInvoiceLineItem.c2g__Product__c = ili.c2g__Product__c;
    		newInvoiceLineItemsList.add(newInvoiceLineItem);
    		system.debug(newInvoiceLineItem);
    		
    	}
    	
    	insert newInvoiceLineItemsList;
    	
    	if(!Test.isRunningTest())
          newSalesInvoice.Posted_InvoiceXpress__c = true;
          
        newSalesInvoice.Post_SalesInvoice__c = true;      
    	
    	update newSalesInvoice;
    	
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    
    public static c2g__codaInvoice__c createInvoiceForAccount(c2g__codaInvoice__c salesInvoice, ID acc, Application__c app){
		
		c2g__codaInvoice__c newSalesInvoice = new c2g__codaInvoice__c();

        newSalesInvoice.c2g__Account__c = acc;
        newSalesInvoice.c2g__CopyAccountValues__c = salesInvoice.c2g__CopyAccountValues__c;
        newSalesInvoice.c2g__CopyDefaultPrintedTextDefinitions__c = salesInvoice.c2g__CopyDefaultPrintedTextDefinitions__c;
        newSalesInvoice.c2g__InvoiceCurrency__c = salesInvoice.c2g__InvoiceCurrency__c;
        //      newSalesInvoice.c2g__newSalesInvoiceDate__c = DAte.today();
       // newSalesInvoice.c2g__newSalesInvoiceDescription__c = null;
        newSalesInvoice.c2g__InvoiceRate__c = salesInvoice.c2g__InvoiceRate__c;
       // newSalesInvoice.c2g__newSalesInvoiceReason__c = null ;
       // newSalesInvoice.c2g__newSalesInvoiceStatus__c = salesInvoice.c2g__InvoiceStatus__c;
        newSalesInvoice.c2g__CustomerReference__c = salesInvoice.c2g__CustomerReference__c;
        newSalesInvoice.c2g__DeriveCurrency__c = salesInvoice.c2g__DeriveCurrency__c;
        newSalesInvoice.c2g__DeriveDueDate__c = salesInvoice.c2g__DeriveDueDate__c;
        newSalesInvoice.c2g__DerivePeriod__c = salesInvoice.c2g__DerivePeriod__c;
        newSalesInvoice.c2g__Dimension1__c = salesInvoice.c2g__Dimension1__c;
        newSalesInvoice.c2g__Dimension2__c = salesInvoice.c2g__Dimension2__c;
        newSalesInvoice.c2g__Dimension3__c = salesInvoice.c2g__Dimension3__c;
        newSalesInvoice.c2g__Dimension4__c = salesInvoice.c2g__Dimension4__c;
        newSalesInvoice.c2g__DiscardReason__c = salesInvoice.c2g__DiscardReason__c;
        newSalesInvoice.c2g__DualRate__c = salesInvoice.c2g__DualRate__c;
        if(app.Payment_Timing__c == 'Advanced'){
            newSalesInvoice.c2g__DueDate__c = Bill_BillingProcess.getLineItemEndDateAdvanced(Date.today());
        }else if(app.Payment_Timing__c == 'Arreas'){
            newSalesInvoice.c2g__DueDate__c = Bill_BillingProcess.getLineItemEndDateArreas(Date.today());
        }
        newSalesInvoice.c2g__ExternalId__c = salesInvoice.c2g__ExternalId__c;
        newSalesInvoice.c2g__IntercompanyTransfer__c = salesInvoice.c2g__IntercompanyTransfer__c;
        newSalesInvoice.c2g__InvoiceDate__c = salesInvoice.c2g__InvoiceDate__c;
        // newSalesInvoice.c2g__MatchType__c = salesInvoice.c2g__MatchType__c;
        // newSalesInvoice.c2g__NetTotal__c = salesInvoice.c2g__NetTotal__c;
        newSalesInvoice.c2g__Opportunity__c = salesInvoice.c2g__Opportunity__c;
        // newSalesInvoice.c2g__OutstandingValue__c = salesInvoice.c2g__OutstandingValue__c;
        newSalesInvoice.c2g__OwnerCompany__c = salesInvoice.c2g__OwnerCompany__c;
        Date periodStartDate = Date.newInstance(newSalesInvoice.c2g__DueDate__c.year(), newSalesInvoice.c2g__DueDate__c.Month(), 1);
        Date periodEndDate = periodStartDate.addMonths(1).addDays(-1);
        c2g__codaPeriod__c period = [Select Id From c2g__codaPeriod__c Where c2g__StartDate__c = :periodStartDate and c2g__EndDate__c = :periodEndDate];
        newSalesInvoice.c2g__Period__c = period.id;
        // newSalesInvoice.c2g__PaymentStatus__c = salesInvoice.c2g__PaymentStatus__c;
        
        newSalesInvoice.c2g__PrintedText1AllowEdit__c = salesInvoice.c2g__PrintedText1AllowEdit__c;
        newSalesInvoice.c2g__PrintedText1Heading__c = salesInvoice.c2g__PrintedText1Heading__c;
        newSalesInvoice.c2g__PrintedText1Text__c = salesInvoice.c2g__PrintedText1Text__c;
        newSalesInvoice.c2g__PrintedText1TextDefinitionName__c = salesInvoice.c2g__PrintedText1TextDefinitionName__c;
        
        newSalesInvoice.c2g__PrintedText2AllowEdit__c = salesInvoice.c2g__PrintedText2AllowEdit__c;
        newSalesInvoice.c2g__PrintedText2Heading__c = salesInvoice.c2g__PrintedText2Heading__c;
        newSalesInvoice.c2g__PrintedText2Text__c = salesInvoice.c2g__PrintedText2Text__c;
        newSalesInvoice.c2g__PrintedText2TextDefinitionName__c = salesInvoice.c2g__PrintedText2TextDefinitionName__c;
        
        newSalesInvoice.c2g__PrintedText3AllowEdit__c = salesInvoice.c2g__PrintedText3AllowEdit__c;
        newSalesInvoice.c2g__PrintedText3Heading__c = salesInvoice.c2g__PrintedText3Heading__c;
        newSalesInvoice.c2g__PrintedText3Text__c = salesInvoice.c2g__PrintedText3Text__c;
        newSalesInvoice.c2g__PrintedText3TextDefinitionName__c = salesInvoice.c2g__PrintedText3TextDefinitionName__c;
        
        newSalesInvoice.c2g__PrintedText4AllowEdit__c = salesInvoice.c2g__PrintedText4AllowEdit__c;
        newSalesInvoice.c2g__PrintedText4Heading__c = salesInvoice.c2g__PrintedText4Heading__c;
        newSalesInvoice.c2g__PrintedText4Text__c = salesInvoice.c2g__PrintedText4Text__c;
        newSalesInvoice.c2g__PrintedText4TextDefinitionName__c = salesInvoice.c2g__PrintedText4TextDefinitionName__c;
        
        newSalesInvoice.c2g__PrintedText5AllowEdit__c = salesInvoice.c2g__PrintedText5AllowEdit__c;
        newSalesInvoice.c2g__PrintedText5Heading__c = salesInvoice.c2g__PrintedText5Heading__c;
        newSalesInvoice.c2g__PrintedText5Text__c = salesInvoice.c2g__PrintedText5Text__c;
        newSalesInvoice.c2g__PrintedText5TextDefinitionName__c = salesInvoice.c2g__PrintedText5TextDefinitionName__c;
        
        newSalesInvoice.c2g__PrintStatus__c = salesInvoice.c2g__PrintStatus__c;
        newSalesInvoice.c2g__SalesTaxDocumentCode__c = salesinvoice.c2g__SalesTaxDocumentCode__c;
        newSalesInvoice.c2g__SalesTaxStatus__c = salesinvoice.c2g__SalesTaxStatus__c;
        
        // newSalesInvoice.c2g__Tax1Total__c = salesinvoice.c2g__Tax1Total__c;
        //newSalesInvoice.c2g__Tax2Total__c = salesinvoice.c2g__Tax2Total__c;
        //newSalesInvoice.c2g__Tax3Total__c = salesinvoice.c2g__Tax3Total__c;
        //newSalesInvoice.c2g__TaxCode1__c = salesinvoice.c2g__TaxCode1__c;
        //newSalesInvoice.c2g__TaxCode2__c = salesinvoice.c2g__TaxCode2__c;
        //newSalesInvoice.c2g__TaxCode3__c = salesinvoice.c2g__TaxCode3__c;
        //newSalesInvoice.c2g__TaxTotal__c = salesInvoice.c2g__TaxTotal__c;
        // newSalesInvoice.c2g__Transaction__c = salesInvoice.c2g__Transaction__c;
        newSalesInvoice.c2g__UnitOfWork__c = salesInvoice.c2g__UnitOfWork__c;
        //newSalesInvoice.c2g__Year__c = salesInvoice.c2g__Year__c;
        newSalesInvoice.CR_Sepa_Record__c = salesInvoice.CR_Sepa_Record__c;
        //newSalesInvoice.CreatedById = salesInvoice.CreatedById;
        //newSalesInvoice.CreatedDate = salesInvoice.CreatedDate;
        //newSalesInvoice.Credit_Note_Link__c = salesInvoice.Credit_Note_Link__c;
        //newSalesInvoice.newSalesInvoice_Email_Status__c = salesInvoice.newSalesInvoice_Email_Status__c;
        //newSalesInvoice.External_Credit_Note_Number_text__c = null;
        newSalesInvoice.ffbext__Approved__c = salesInvoice.ffbext__Approved__c;
        //newSalesInvoice.IsDeleted = salesInvoice.IsDeleted;
        //newSalesInvoice.LastActivityDate = salesInvoice.LastActivityDate;
        //newSalesInvoice.LastModifiedById = salesInvoice.LastModifiedById;
        //newSalesInvoice.LastModifiedDate = salesInvoice.LastModifiedDate;
        //newSalesInvoice.LastReferencedDate = salesInvoice.LastReferencedDate;
        //newSalesInvoice.LastViewedDate = salesInvoice.LastViewedDate;
        //newSalesInvoice.Moloni_Credit_Note_ID__c = null;
        //newSalesInvoice.Name = null;
        // newSalesInvoice.OwnerId = salesInvoice.OwnerId;
        //newSalesInvoice.Renting_Application__c = salesInvoice.;
        //newSalesInvoice.SAFT_Imported__c = salesInvoice.SAFT_Imported__c;
        //newSalesInvoice.Sales_Credit_Note_Link__c = salesInvoice.null;
        //newSalesInvoice.SystemModstamp = salesInvoice.SystemModstamp;
        

        
        return newSalesInvoice;    	
    }
    

    
}