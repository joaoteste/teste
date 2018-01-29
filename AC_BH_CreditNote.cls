global class AC_BH_CreditNote implements Database.Batchable<sObject>, Database.Stateful{
	
	List<ID> salesInvoiceToConvertList;
	List<ID> creditNotesList = new List<ID>() ;
	
	global AC_BH_CreditNote(List<ID> salesInvoiceToConvertList){
		this.salesInvoiceToConvertList = salesInvoiceToConvertList;
	}
  
  	global Database.QueryLocator start(Database.BatchableContext BC){
   	 	    
   	    String query = 'SELECT ID, Invoice_Email_Status__c, Application__c, c2g__Account__c, c2g__CopyAccountValues__c, c2g__CopyDefaultPrintedTextDefinitions__c, c2g__InvoiceCurrency__c,'+
   	    				'c2g__InvoiceRate__c, c2g__CustomerReference__c, c2g__DeriveCurrency__c, c2g__DeriveDueDate__c, c2g__DerivePeriod__c, c2g__Dimension1__c,'+
   	    				'c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, c2g__DiscardReason__c, c2g__DualRate__c, c2g__ExternalId__c, c2g__IntercompanyTransfer__c,'+
   	    				'c2g__InvoiceDate__c, c2g__Opportunity__c, c2g__OwnerCompany__c, c2g__PrintedText1AllowEdit__c, c2g__PrintedText1Heading__c, c2g__PrintedText1Text__c,'+
   	    				'c2g__PrintedText1TextDefinitionName__c, c2g__PrintedText2AllowEdit__c, c2g__PrintedText2Heading__c, c2g__PrintedText2Text__c, c2g__PrintedText2TextDefinitionName__c,'+
   	    				'c2g__PrintedText3AllowEdit__c, c2g__PrintedText3Heading__c, c2g__PrintedText3Text__c, c2g__PrintedText3TextDefinitionName__c, c2g__PrintedText4AllowEdit__c,'+
   	    				'c2g__PrintedText4Heading__c, c2g__PrintedText4Text__c, c2g__PrintedText4TextDefinitionName__c, c2g__PrintedText5AllowEdit__c, c2g__PrintedText5Heading__c,'+
   	    				'c2g__PrintedText5Text__c, c2g__PrintedText5TextDefinitionName__c, c2g__PrintStatus__c, c2g__SalesTaxDocumentCode__c, c2g__SalesTaxStatus__c, c2g__UnitOfWork__c,'+
   	    				'CR_Sepa_Record__c, ffbext__Approved__c '+
   	    				'FROM c2g__codaInvoice__c '+
                        'WHERE id in :salesInvoiceToConvertList';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__codaInvoice__c> salesInvoiceList){
    	
    	c2g__codaInvoice__c si = salesInvoiceList[0];
    	Application__c app = [SELECT ID, Payment_Timing__c FROM Application__c WHERE ID = :si.Application__c];
    		
    	List<c2g__codaCreditNote__c> cnList = SalesInvoiceCreditNote.convertToCreditNote(salesInvoiceList, app);
		c2g__codaCreditNote__c cn = cnList[0];
			
        //post
        c2g.CODAAPICommon.Reference refCreditNote = new c2g.CODAAPICommon.Reference();
        refCreditNote.Id = cn.Id;
        system.debug('Posting credit note for assignment contract costs ' + refCreditNote.id);    		
    	c2g.CODAAPISalesCreditNote_10_0.PostCreditNote(null, refCreditNote);
    		
		//add to list
		creditNotesList.add(cn.ID);  		  		
    }
    
    global void finish(Database.BatchableContext BC){
       system.debug(creditNotesList);
       Database.executeBatch(new AC_BH_CreditNotesMoloni(creditNotesList),1); 
    }
        
}