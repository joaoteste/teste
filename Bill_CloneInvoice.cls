//this class is responsible for canceling a sales invoices

global class Bill_CloneInvoice {
    
    webservice static String cloneMultipleInvoices(List<ID> salesInvoiceIDList){
        //Database.executeBatch(new BILL_BH_CloneInvoice(salesInvoiceIDList),1);
        return 'Process started.';
    }

    
    webservice static String cloneInvoice(ID salesInvoiceID, c2g__codaInvoice__c salesInvoice){
        system.debug(salesInvoice);
        
        c2g__codaInvoice__c salesInvoiceOld = [SELECT ID, c2g__Account__c, Application__c, c2g__CopyAccountValues__c, c2g__CopyDefaultPrintedTextDefinitions__c, c2g__InvoiceCurrency__c,
   	    				c2g__InvoiceRate__c, c2g__CustomerReference__c, c2g__DeriveCurrency__c, c2g__DeriveDueDate__c, c2g__DerivePeriod__c, c2g__Dimension1__c,
   	    				c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, c2g__DiscardReason__c, c2g__DualRate__c, c2g__ExternalId__c, c2g__IntercompanyTransfer__c,
   	    				c2g__InvoiceDate__c, c2g__Opportunity__c, c2g__OwnerCompany__c, c2g__PrintedText1AllowEdit__c, c2g__PrintedText1Heading__c, c2g__PrintedText1Text__c,
   	    				c2g__PrintedText1TextDefinitionName__c, c2g__PrintedText2AllowEdit__c, c2g__PrintedText2Heading__c, c2g__PrintedText2Text__c, c2g__PrintedText2TextDefinitionName__c,
   	    				c2g__PrintedText3AllowEdit__c, c2g__PrintedText3Heading__c, c2g__PrintedText3Text__c, c2g__PrintedText3TextDefinitionName__c, c2g__PrintedText4AllowEdit__c,
   	    				c2g__PrintedText4Heading__c, c2g__PrintedText4Text__c, c2g__PrintedText4TextDefinitionName__c, c2g__PrintedText5AllowEdit__c, c2g__PrintedText5Heading__c,
   	    				c2g__PrintedText5Text__c, c2g__PrintedText5TextDefinitionName__c, c2g__PrintStatus__c, c2g__SalesTaxDocumentCode__c, c2g__SalesTaxStatus__c, c2g__UnitOfWork__c,
   	    				CR_Sepa_Record__c, ffbext__Approved__c
   	    				FROM c2g__codaInvoice__c
                        WHERE ID = :salesInvoiceID];



        salesInvoice.c2g__CopyAccountValues__c = salesInvoiceOld.c2g__CopyAccountValues__c;
        salesInvoice.c2g__CopyDefaultPrintedTextDefinitions__c = salesInvoiceOld.c2g__CopyDefaultPrintedTextDefinitions__c;
        salesInvoice.c2g__InvoiceCurrency__c = salesInvoiceOld.c2g__InvoiceCurrency__c;

        salesInvoice.c2g__InvoiceRate__c = salesInvoiceOld.c2g__InvoiceRate__c;

    
        salesInvoice.c2g__DeriveCurrency__c = salesInvoiceOld.c2g__DeriveCurrency__c;
        salesInvoice.c2g__DeriveDueDate__c = salesInvoiceOld.c2g__DeriveDueDate__c;
        salesInvoice.c2g__DerivePeriod__c = salesInvoiceOld.c2g__DerivePeriod__c;
        salesInvoice.c2g__Dimension1__c = salesInvoiceOld.c2g__Dimension1__c;
        salesInvoice.c2g__Dimension2__c = salesInvoiceOld.c2g__Dimension2__c;
        salesInvoice.c2g__Dimension3__c = salesInvoiceOld.c2g__Dimension3__c;
        salesInvoice.c2g__Dimension4__c = salesInvoiceOld.c2g__Dimension4__c;

        salesInvoice.c2g__DualRate__c = salesInvoiceOld.c2g__DualRate__c;


        salesInvoice.c2g__IntercompanyTransfer__c = salesInvoiceOld.c2g__IntercompanyTransfer__c;



        salesInvoice.c2g__Opportunity__c = salesInvoiceOld.c2g__Opportunity__c;

        salesInvoice.c2g__OwnerCompany__c = salesInvoiceOld.c2g__OwnerCompany__c;
		Date startDate = Date.newInstance(salesInvoice.c2g__DueDate__c.year(), salesInvoice.c2g__DueDate__c.Month(), 1);
		Date endDate = startDate.addMonths(1).addDays(-1);
        c2g__codaPeriod__c period = [Select Id From c2g__codaPeriod__c Where c2g__StartDate__c = :startDate and c2g__EndDate__c = :endDate];
        salesInvoice.c2g__Period__c = period.id;

        
        salesInvoice.c2g__PrintedText1AllowEdit__c = salesInvoiceOld.c2g__PrintedText1AllowEdit__c;
        salesInvoice.c2g__PrintedText1Heading__c = salesInvoiceOld.c2g__PrintedText1Heading__c;
        salesInvoice.c2g__PrintedText1Text__c = salesInvoiceOld.c2g__PrintedText1Text__c;
        salesInvoice.c2g__PrintedText1TextDefinitionName__c = salesInvoiceOld.c2g__PrintedText1TextDefinitionName__c;
        
        salesInvoice.c2g__PrintedText2AllowEdit__c = salesInvoiceOld.c2g__PrintedText2AllowEdit__c;
        salesInvoice.c2g__PrintedText2Heading__c = salesInvoiceOld.c2g__PrintedText2Heading__c;
        salesInvoice.c2g__PrintedText2Text__c = salesInvoiceOld.c2g__PrintedText2Text__c;
        salesInvoice.c2g__PrintedText2TextDefinitionName__c = salesInvoiceOld.c2g__PrintedText2TextDefinitionName__c;
        
        salesInvoice.c2g__PrintedText3AllowEdit__c = salesInvoiceOld.c2g__PrintedText3AllowEdit__c;
        salesInvoice.c2g__PrintedText3Heading__c = salesInvoiceOld.c2g__PrintedText3Heading__c;
        salesInvoice.c2g__PrintedText3Text__c = salesInvoiceOld.c2g__PrintedText3Text__c;
        salesInvoice.c2g__PrintedText3TextDefinitionName__c = salesInvoiceOld.c2g__PrintedText3TextDefinitionName__c;
        
        salesInvoice.c2g__PrintedText4AllowEdit__c = salesInvoiceOld.c2g__PrintedText4AllowEdit__c;
        salesInvoice.c2g__PrintedText4Heading__c = salesInvoiceOld.c2g__PrintedText4Heading__c;
        salesInvoice.c2g__PrintedText4Text__c = salesInvoiceOld.c2g__PrintedText4Text__c;
        salesInvoice.c2g__PrintedText4TextDefinitionName__c = salesInvoiceOld.c2g__PrintedText4TextDefinitionName__c;
        
        
        salesInvoice.c2g__PrintedText5AllowEdit__c = salesInvoiceOld.c2g__PrintedText5AllowEdit__c;
        salesInvoice.c2g__PrintedText5Heading__c = salesInvoiceOld.c2g__PrintedText5Heading__c;
        salesInvoice.c2g__PrintedText5Text__c = salesInvoiceOld.c2g__PrintedText5Text__c;
        salesInvoice.c2g__PrintedText5TextDefinitionName__c = salesInvoiceOld.c2g__PrintedText5TextDefinitionName__c;
        
        salesInvoice.c2g__PrintStatus__c = salesInvoiceOld.c2g__PrintStatus__c;
        salesInvoice.c2g__SalesTaxDocumentCode__c = salesInvoiceOld.c2g__SalesTaxDocumentCode__c;
        salesInvoice.c2g__SalesTaxStatus__c = salesInvoiceOld.c2g__SalesTaxStatus__c;
        
        //newsalesInvoiceOld.c2g__Tax1Total__c = salesInvoiceOld.c2g__Tax1Total__c;
        //newsalesInvoiceOld.c2g__Tax2Total__c = salesInvoiceOld.c2g__Tax2Total__c;
        //newsalesInvoiceOld.c2g__Tax3Total__c = salesInvoiceOld.c2g__Tax3Total__c;
        //newsalesInvoiceOld.c2g__TaxTotal__c = salesInvoiceOld.c2g__TaxTotal__c;
        salesInvoice.c2g__UnitOfWork__c = salesInvoiceOld.c2g__UnitOfWork__c;



        salesInvoice.ffbext__Approved__c = salesInvoiceOld.ffbext__Approved__c;

        insert salesInvoice;
        
    	List<c2g__codaInvoiceLineItem__c> oldInvoiceLineItemsList = [SELECT ID, c2g__Product__r.ProductCode, c2g__UnitPrice__c, c2g__DeriveUnitPriceFromProduct__c FROM c2g__codaInvoiceLineItem__c WHERE c2g__Invoice__c =:salesInvoiceOld.ID];
    	List<Account> accountList = [SELECT ID, Tax_Zone__c FROM Account WHERE ID = :salesInvoice.c2g__Account__c];
        String taxZone = accountList[0].Tax_Zone__c;
    	List<c2g__codaInvoiceLineItem__c> newInvoiceLineItemsList = new List<c2g__codaInvoiceLineItem__c>();
    	Bill_ProductRegion billRegion = new BILL_ProductRegion('Input');
        
    	for(c2g__codaInvoiceLineItem__c ili : oldInvoiceLineItemsList){
    		system.debug(ili);
    		c2g__codaInvoiceLineItem__c newInvoiceLineItem = ili.clone(false, true, false, false);
    		newInvoiceLineItem.c2g__Invoice__c = salesInvoice.ID;
            system.debug(taxZone);
            system.debug(ili.c2g__Product__r.ProductCode);
    		newInvoiceLineItem.c2g__Product__c = billRegion.getProduct(ili.c2g__Product__r.ProductCode, taxZone);
            newInvoiceLineItem.c2g__TaxCode1__c = billRegion.getTaxCode(ili.c2g__Product__r.ProductCode, taxZone);
            newInvoiceLineItem.c2g__DeriveUnitPriceFromProduct__c = ili.c2g__DeriveUnitPriceFromProduct__c;
            newInvoiceLineItem.c2g__UnitPrice__c = ili.c2g__UnitPrice__c;
    		newInvoiceLineItemsList.add(newInvoiceLineItem);
    		system.debug(newInvoiceLineItem);
    		
    	}


    	insert newInvoiceLineItemsList;       
        
        
        
        

    	return 'test';
        //c2g__codaInvoice__c salesInvoice = 
    }
}