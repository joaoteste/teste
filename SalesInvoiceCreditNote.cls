public class SalesInvoiceCreditNote {
    
    public SalesInvoiceCreditNote(){}
    
    /*
    This function receive a list of salesInvoice and convert them to credit note
    Insert and Update operators are already executed during the function
    */
    public static List<c2g__codaCreditNote__c> convertToCreditNote(List<c2g__codaInvoice__c> salesInvoiceList,Application__c app){
        List<c2g__codaCreditNote__c> codaCreditNoteList = new List<c2g__codaCreditNote__c>();
        
        //create credit notes
        for(c2g__codaInvoice__c salesinvoice : salesInvoiceList){
            //convert to creditNote
            c2g__codaCreditNote__c creditNote = createCreditNoteFromSalesInvoice(salesinvoice,app);
            codaCreditNoteList.add(creditNote);
            //System.debug(billMoloni.createCreditNote(salesinvoice.ID));
            
        }
        insert codaCreditNoteList;
                
        //Map Key ID Invoice -> object Credit Note
        //Map<ID,c2g__codaCreditNote__c> creditNotePerInvoiceMap = new Map<ID,c2g__codaCreditNote__c>([Select c2g__Invoice__c,ID From c2g__codaCreditNote__c Where id in :codaCreditNoteList]);       
        
        //List with all salesInvoiceItem
        List<c2g__codaInvoiceLineItem__c> salesInvoiceLineItemList = new List<c2g__codaInvoiceLineItem__c>([Select ID,c2g__Invoice__c,c2g__DeriveLineNumber__c,c2g__DeriveUnitPriceFromProduct__c,c2g__GeneralLedgerAccount__c,c2g__LineDescription__c,
                                                                                                            c2g__LineNumber__c,c2g__OwnerCompany__c,c2g__Product__c,c2g__Quantity__c,c2g__UnitOfWork__c,c2g__UnitPrice__c,
                                                                                                            c2g__CalculateTaxValue1FromRate__c,c2g__DeriveTaxRate1FromCode__c,c2g__Dimension1__c,c2g__SetTaxCode1ToDefault__c,c2g__TaxCode1__c,
                                                                                                            c2g__CalculateTaxValue2FromRate__c,c2g__DeriveTaxRate2FromCode__c,c2g__Dimension2__c,c2g__SetTaxCode2ToDefault__c,c2g__TaxCode2__c,
                                                                                                            c2g__CalculateTaxValue3FromRate__c,c2g__DeriveTaxRate3FromCode__c,c2g__Dimension3__c,c2g__SetTaxCode3ToDefault__c,c2g__TaxCode3__c,c2g__TaxValue1__c,c2g__TaxValue3__c,c2g__TaxValue2__c,
                                                                                                            c2g__Dimension4__c 
                                                                                                            From c2g__codaInvoiceLineItem__c 
                                                                                                            Where c2g__Invoice__c IN :salesInvoiceList]);    
        
        List<c2g__codaCreditNoteLineItem__c> codaCreditNoteItemList = new List<c2g__codaCreditNoteLineItem__c>();

        //create credit note line itens! For every saleInvoiceLineItem it will get the creditNote associated (through the creditNotePerInvoiceMap) 
        //and create the creditnoteItem with the data from the saleInvoiceItem
        for(c2g__codaInvoiceLineItem__c saleInvoiceItem: salesInvoiceLineItemList){
            for(c2g__codaCreditNote__c creditNote: codaCreditNoteList){
                if(saleInvoiceItem.c2g__Invoice__c == creditNote.c2g__Invoice__c){
                    c2g__codaCreditNoteLineItem__c codaCreditNoteItem = createCreditNoteItemFromSaleInvoiceItem(saleInvoiceItem,creditNote.Id);
                    codaCreditNoteItemList.add(codaCreditNoteItem);
                }
            }
        }
        

        /*
        for(c2g__codaInvoiceLineItem__c saleInvoiceItem: salesInvoiceLineItemList){
            c2g__codaCreditNote__c creditNote = creditNotePerInvoiceMap.get(saleInvoiceItem.c2g__Invoice__c);
            if(creditNote != null){
                c2g__codaCreditNoteLineItem__c codaCreditNoteItem = createCreditNoteItemFromSaleInvoiceItem(saleInvoiceItem,creditNote.Id);
                codaCreditNoteItemList.add(codaCreditNoteItem);
            }
        }*/
        
        //the creditNoteLineItem are insert and the credit noite updated
        if(codaCreditNoteItemList != null || codaCreditNoteItemList.size()>0){
            insert codaCreditNoteItemList;
            update codaCreditNoteList;
        }
        
        return codaCreditNoteList;
    }
    
    /*
    This function receive a salesInvoice and create a credit Note with the data from that salesInvoice
    Neither insert or updated operatores are executed in the function (Example: the function convertToCreditNote calls this function multiple times and executes the insert operator after that)
    The line itens aren't also created (the function createCreditNoteItemFromSaleInvoiceItem is responsible for that)
    */
    public static c2g__codaCreditNote__c createCreditNoteFromSalesInvoice(c2g__codaInvoice__c salesInvoice,Application__c app){
        
        c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();

        creditNote.c2g__Account__c = salesInvoice.c2g__Account__c;
        creditNote.c2g__Invoice__c = salesInvoice.Id;
        creditNote.c2g__CopyAccountValues__c = salesInvoice.c2g__CopyAccountValues__c;
        creditNote.c2g__CopyDefaultPrintedTextDefinitions__c = salesInvoice.c2g__CopyDefaultPrintedTextDefinitions__c;
        creditNote.c2g__CreditNoteCurrency__c = salesInvoice.c2g__InvoiceCurrency__c;
        //      creditNote.c2g__CreditNoteDate__c = DAte.today();
       // creditNote.c2g__CreditNoteDescription__c = null;
        creditNote.c2g__CreditNoteRate__c = salesInvoice.c2g__InvoiceRate__c;
       // creditNote.c2g__CreditNoteReason__c = null ;
       // creditNote.c2g__CreditNoteStatus__c = salesInvoice.c2g__InvoiceStatus__c;
        creditNote.c2g__CustomerReference__c = salesInvoice.c2g__CustomerReference__c;
        creditNote.c2g__DeriveCurrency__c = salesInvoice.c2g__DeriveCurrency__c;
        creditNote.c2g__DeriveDueDate__c = salesInvoice.c2g__DeriveDueDate__c;
        creditNote.c2g__DerivePeriod__c = salesInvoice.c2g__DerivePeriod__c;
        creditNote.c2g__Dimension1__c = salesInvoice.c2g__Dimension1__c;
        creditNote.c2g__Dimension2__c = salesInvoice.c2g__Dimension2__c;
        creditNote.c2g__Dimension3__c = salesInvoice.c2g__Dimension3__c;
        creditNote.c2g__Dimension4__c = salesInvoice.c2g__Dimension4__c;
        creditNote.c2g__DiscardReason__c = salesInvoice.c2g__DiscardReason__c;
        creditNote.c2g__DualRate__c = salesInvoice.c2g__DualRate__c;
        if(app.Payment_Timing__c == 'Advanced'){
            creditNote.c2g__DueDate__c = Bill_BillingProcess.getLineItemEndDateAdvanced(Date.today());
        }else if(app.Payment_Timing__c == 'Arreas'){
            creditNote.c2g__DueDate__c = Bill_BillingProcess.getLineItemEndDateArreas(Date.today());
        }
        //creditNote.c2g__ExternalId__c = salesInvoice.c2g__ExternalId__c;
        creditNote.c2g__IntercompanyTransfer__c = salesInvoice.c2g__IntercompanyTransfer__c;
        creditNote.c2g__InvoiceDate__c = salesInvoice.c2g__InvoiceDate__c;
        // creditNote.c2g__MatchType__c = salesInvoice.c2g__MatchType__c;
        // creditNote.c2g__NetTotal__c = salesInvoice.c2g__NetTotal__c;
        creditNote.c2g__Opportunity__c = salesInvoice.c2g__Opportunity__c;
        // creditNote.c2g__OutstandingValue__c = salesInvoice.c2g__OutstandingValue__c;
        creditNote.c2g__OwnerCompany__c = salesInvoice.c2g__OwnerCompany__c;
        Date periodStartDate = Date.newInstance(creditNote.c2g__DueDate__c.year(), creditNote.c2g__DueDate__c.Month(), 1);
        Date periodEndDate = periodStartDate.addMonths(1).addDays(-1);		
        c2g__codaPeriod__c period = [Select Id From c2g__codaPeriod__c Where c2g__StartDate__c = :periodStartDate and c2g__endDate__c = :periodEndDate];
        creditNote.c2g__Period__c = period.id;
        // creditNote.c2g__PaymentStatus__c = salesInvoice.c2g__PaymentStatus__c;
        
        creditNote.c2g__PrintedText1AllowEdit__c = salesInvoice.c2g__PrintedText1AllowEdit__c;
        creditNote.c2g__PrintedText1Heading__c = salesInvoice.c2g__PrintedText1Heading__c;
        creditNote.c2g__PrintedText1Text__c = salesInvoice.c2g__PrintedText1Text__c;
        creditNote.c2g__PrintedText1TextDefinitionName__c = salesInvoice.c2g__PrintedText1TextDefinitionName__c;
        
        creditNote.c2g__PrintedText2AllowEdit__c = salesInvoice.c2g__PrintedText2AllowEdit__c;
        creditNote.c2g__PrintedText2Heading__c = salesInvoice.c2g__PrintedText2Heading__c;
        creditNote.c2g__PrintedText2Text__c = salesInvoice.c2g__PrintedText2Text__c;
        creditNote.c2g__PrintedText2TextDefinitionName__c = salesInvoice.c2g__PrintedText2TextDefinitionName__c;
        
        creditNote.c2g__PrintedText3AllowEdit__c = salesInvoice.c2g__PrintedText3AllowEdit__c;
        creditNote.c2g__PrintedText3Heading__c = salesInvoice.c2g__PrintedText3Heading__c;
        creditNote.c2g__PrintedText3Text__c = salesInvoice.c2g__PrintedText3Text__c;
        creditNote.c2g__PrintedText3TextDefinitionName__c = salesInvoice.c2g__PrintedText3TextDefinitionName__c;
        
        creditNote.c2g__PrintedText4AllowEdit__c = salesInvoice.c2g__PrintedText4AllowEdit__c;
        creditNote.c2g__PrintedText4Heading__c = salesInvoice.c2g__PrintedText4Heading__c;
        creditNote.c2g__PrintedText4Text__c = salesInvoice.c2g__PrintedText4Text__c;
        creditNote.c2g__PrintedText4TextDefinitionName__c = salesInvoice.c2g__PrintedText4TextDefinitionName__c;
        
        creditNote.c2g__PrintedText5AllowEdit__c = salesInvoice.c2g__PrintedText5AllowEdit__c;
        creditNote.c2g__PrintedText5Heading__c = salesInvoice.c2g__PrintedText5Heading__c;
        creditNote.c2g__PrintedText5Text__c = salesInvoice.c2g__PrintedText5Text__c;
        creditNote.c2g__PrintedText5TextDefinitionName__c = salesInvoice.c2g__PrintedText5TextDefinitionName__c;
        
        creditNote.c2g__PrintStatus__c = salesInvoice.c2g__PrintStatus__c;
        creditNote.c2g__SalesTaxDocumentCode__c = salesinvoice.c2g__SalesTaxDocumentCode__c;
        creditNote.c2g__SalesTaxStatus__c = salesinvoice.c2g__SalesTaxStatus__c;
        
        // creditNote.c2g__Tax1Total__c = salesinvoice.c2g__Tax1Total__c;
        //creditNote.c2g__Tax2Total__c = salesinvoice.c2g__Tax2Total__c;
        //creditNote.c2g__Tax3Total__c = salesinvoice.c2g__Tax3Total__c;
        //creditNote.c2g__TaxCode1__c = salesinvoice.c2g__TaxCode1__c;
        //creditNote.c2g__TaxCode2__c = salesinvoice.c2g__TaxCode2__c;
        //creditNote.c2g__TaxCode3__c = salesinvoice.c2g__TaxCode3__c;
        //creditNote.c2g__TaxTotal__c = salesInvoice.c2g__TaxTotal__c;
        // creditNote.c2g__Transaction__c = salesInvoice.c2g__Transaction__c;
        creditNote.c2g__UnitOfWork__c = salesInvoice.c2g__UnitOfWork__c;
        //creditNote.c2g__Year__c = salesInvoice.c2g__Year__c;
        //creditNote.CR_Sepa_Record__c = salesInvoice.CR_Sepa_Record__c;
        //creditNote.CreatedById = salesInvoice.CreatedById;
        //creditNote.CreatedDate = salesInvoice.CreatedDate;
        //creditNote.Credit_Note_Link__c = salesInvoice.Credit_Note_Link__c;
        creditNote.CreditNote_Email_Status__c = salesInvoice.Invoice_Email_Status__c;
        //creditNote.External_Credit_Note_Number_text__c = null;
        creditNote.ffbext__Approved__c = salesInvoice.ffbext__Approved__c;
        //creditNote.IsDeleted = salesInvoice.IsDeleted;
        //creditNote.LastActivityDate = salesInvoice.LastActivityDate;
        //creditNote.LastModifiedById = salesInvoice.LastModifiedById;
        //creditNote.LastModifiedDate = salesInvoice.LastModifiedDate;
        //creditNote.LastReferencedDate = salesInvoice.LastReferencedDate;
        //creditNote.LastViewedDate = salesInvoice.LastViewedDate;
        //creditNote.Moloni_Credit_Note_ID__c = null;
        //creditNote.Name = null;
        // creditNote.OwnerId = salesInvoice.OwnerId
        if(salesInvoice.Application__c != null){
            creditNote.Renting_Application__c = salesInvoice.Application__c;
        }
        //creditNote.Sales_Credit_Note_Link__c = salesInvoice.null;
        //creditNote.SystemModstamp = salesInvoice.SystemModstamp;
        
        return creditNote;
    }
    
    /*
    Receive the saleInvoiceItem and a creditNoteID 
    Neither insert or updated operatores are executed in the function (Example: the function convertToCreditNote calls this function multiple times and executes the insert operator after that)
    */
    public static c2g__codaCreditNoteLineItem__c createCreditNoteItemFromSaleInvoiceItem(c2g__codaInvoiceLineItem__c saleInvoiceItem,ID creditNoteID){
        c2g__codaCreditNoteLineItem__c creditNoteLineItem = new c2g__codaCreditNoteLineItem__c();
        
        
        creditNoteLineItem.c2g__CalculateTaxValue2FromRate__c = saleInvoiceItem.c2g__CalculateTaxValue2FromRate__c;
        creditNoteLineItem.c2g__CalculateTaxValue3FromRate__c = saleInvoiceItem.c2g__CalculateTaxValue3FromRate__c;
        creditNoteLineItem.c2g__CalculateTaxValueFromRate__c = saleInvoiceItem.c2g__CalculateTaxValue1FromRate__c;
        creditNoteLineItem.c2g__CreditNote__c = creditNoteID;
        creditNoteLineItem.c2g__DeriveLineNumber__c = saleInvoiceItem.c2g__DeriveLineNumber__c;
        creditNoteLineItem.c2g__DeriveTaxRate2FromCode__c = saleInvoiceItem.c2g__DeriveTaxRate2FromCode__c;
        creditNoteLineItem.c2g__DeriveTaxRate3FromCode__c = saleInvoiceItem.c2g__DeriveTaxRate3FromCode__c;
        creditNoteLineItem.c2g__DeriveTaxRateFromCode__c = saleInvoiceItem.c2g__DeriveTaxRate1FromCode__c;
        creditNoteLineItem.c2g__DeriveUnitPriceFromProduct__c = saleInvoiceItem.c2g__DeriveUnitPriceFromProduct__c;
        creditNoteLineItem.c2g__Dimension1__c = saleInvoiceItem.c2g__Dimension1__c;
        creditNoteLineItem.c2g__Dimension2__c = saleInvoiceItem.c2g__Dimension2__c;
        creditNoteLineItem.c2g__Dimension3__c = saleInvoiceItem.c2g__Dimension3__c;
        creditNoteLineItem.c2g__Dimension4__c = saleInvoiceItem.c2g__Dimension4__c;
        //creditNoteLineItem.c2g__ExternalId__c = saleInvoiceItem.c2g__ExternalId__c;
        creditNoteLineItem.c2g__GeneralLedgerAccount__c = saleInvoiceItem.c2g__GeneralLedgerAccount__c;
        creditNoteLineItem.c2g__LineDescription__c = saleInvoiceItem.c2g__LineDescription__c;
        creditNoteLineItem.c2g__LineNumber__c = saleInvoiceItem.c2g__LineNumber__c;
        //creditNoteLineItem.c2g__NetValue__c = saleInvoiceItem.c2g__NetValue__c;
        creditNoteLineItem.c2g__OwnerCompany__c = saleInvoiceItem.c2g__OwnerCompany__c;
        creditNoteLineItem.c2g__Product__c = saleInvoiceItem.c2g__Product__c;
        creditNoteLineItem.c2g__Quantity__c = saleInvoiceItem.c2g__Quantity__c;
        creditNoteLineItem.c2g__SetTaxCodeToDefault__c = saleInvoiceItem.c2g__SetTaxCode1ToDefault__c;
        creditNoteLineItem.c2g__SetTaxCode2ToDefault__c = saleInvoiceItem.c2g__SetTaxCode2ToDefault__c;
        creditNoteLineItem.c2g__SetTaxCode3ToDefault__c = saleInvoiceItem.c2g__SetTaxCode3ToDefault__c;
        creditNoteLineItem.c2g__TaxCode1__c = saleInvoiceItem.c2g__TaxCode1__c;  
        creditNoteLineItem.c2g__TaxValue1__c = saleInvoiceItem.c2g__TaxValue1__c;        
        creditNoteLineItem.c2g__TaxCode2__c = saleInvoiceItem.c2g__TaxCode2__c;
        creditNoteLineItem.c2g__TaxValue2__c = saleInvoiceItem.c2g__TaxValue2__c;        
        creditNoteLineItem.c2g__TaxCode3__c = saleInvoiceItem.c2g__TaxCode3__c;
        creditNoteLineItem.c2g__TaxValue3__c = saleInvoiceItem.c2g__TaxValue3__c;        
        //  creditNoteLineItem.c2g__TaxValueTotal__c = saleInvoiceItem.c2g__TaxValueTotal__c;
        creditNoteLineItem.c2g__UnitOfWork__c = saleInvoiceItem.c2g__UnitOfWork__c;
        creditNoteLineItem.c2g__UnitPrice__c = saleInvoiceItem.c2g__UnitPrice__c;
        
        return creditNoteLineItem;
    }
    
}