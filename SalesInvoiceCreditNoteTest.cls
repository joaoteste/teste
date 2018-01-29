@isTest
public class SalesInvoiceCreditNoteTest {
    
    @istest (SeeAllData = true)
    public static void convertToCreditNoteTest(){
        Application__c app = [Select ID, Payment_Timing__c from Application__c where id = 'a012400000Ldf2OAAR' ];
        List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>([Select ID, Name, Invoice_Email_Status__c, Application__c, c2g__Account__c,c2g__CopyAccountValues__c, c2g__CopyDefaultPrintedTextDefinitions__c, c2g__InvoiceCurrency__c,c2g__InvoiceRate__c,c2g__InvoiceTotal__c,
                                                                                    c2g__InvoiceStatus__c, c2g__CustomerReference__c, c2g__DeriveCurrency__c,c2g__DeriveDueDate__c,c2g__DerivePeriod__c,c2g__Dimension1__c,c2g__Dimension2__c,c2g__Dimension3__c,c2g__Dimension4__c,
                                                                                    c2g__DiscardReason__c,c2g__DualRate__c,c2g__DueDate__c,c2g__ExternalId__c,c2g__IntercompanyTransfer__c,c2g__InvoiceDate__c,c2g__Opportunity__c,c2g__OwnerCompany__c,c2g__Period__c,
                                                                                    c2g__PrintedText1AllowEdit__c,c2g__PrintedText1Heading__c,c2g__PrintedText1Text__c,c2g__PrintedText1TextDefinitionName__c,
                                                                                    c2g__PrintedText2AllowEdit__c,c2g__PrintedText2Heading__c,c2g__PrintedText2Text__c,c2g__PrintedText2TextDefinitionName__c,
                                                                                    c2g__PrintedText3AllowEdit__c,c2g__PrintedText3Heading__c,c2g__PrintedText3Text__c,c2g__PrintedText3TextDefinitionName__c,
                                                                                    c2g__PrintedText4AllowEdit__c,c2g__PrintedText4Heading__c,c2g__PrintedText4Text__c,c2g__PrintedText4TextDefinitionName__c,
                                                                                    c2g__PrintedText5AllowEdit__c,c2g__PrintedText5Heading__c,c2g__PrintedText5Text__c,c2g__PrintedText5TextDefinitionName__c,
                                                                                    c2g__PrintStatus__c,c2g__SalesTaxDocumentCode__c,c2g__SalesTaxStatus__c,c2g__UnitOfWork__c,CR_Sepa_Record__c,ffbext__Approved__c
                                                                                    From c2g__codaInvoice__c 
                                                                                    Where c2g__InvoiceStatus__c = 'Complete' and Application__c = :app.ID
                                                                                    limit 5]);
        
        List<c2g__codaCreditNote__c> codaCreditNoteList = new List<c2g__codaCreditNote__c>();
        
        codaCreditNoteList = SalesInvoiceCreditNote.convertToCreditNote(salesInvoiceList, app);
    }

}