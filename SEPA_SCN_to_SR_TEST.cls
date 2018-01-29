@isTest (SeeAllData=true)
public class SEPA_SCN_to_SR_TEST {
/*    
    @isTest (SeeAllData=true)
    public static void test_SEPA_SCN_to_SR() {
        
        c2g__codaCreditNote__c scn
            = [
                SELECT Id
                , Name
                , c2g__Transaction__r.c2g__DocumentOutstandingTotal__c
                , c2g__CreditNoteStatus__c
                , c2g__OutstandingValue__c
                , c2g__CreditNoteCurrency__c
                , c2g__Account__r.c2g__CODABankIBANNumber__c
                , c2g__Account__r.Id
                , c2g__Account__r.Name
                , c2g__Account__r.NIF__c
                , c2g__DueDate__c
                , c2g__Invoice__r.Id
                , c2g__Invoice__r.Name
                , c2g__Invoice__r.c2g__Account__c
                , c2g__Invoice__r.c2g__PaymentStatus__c
                , c2g__Invoice__r.c2g__InvoiceStatus__c
                , c2g__Invoice__r.c2g__OutstandingValue__c
                , c2g__Invoice__r.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c
                , c2g__Invoice__r.Application__r.Delivery_Certificate_Signed__c
                FROM c2g__codaCreditNote__c
                WHERE
                c2g__Invoice__r.c2g__InvoiceStatus__c = 'Complete'
                AND c2g__CreditNoteStatus__c = 'In Progress'
                LIMIT 1];
        
        Test.startTest();
        if(scn.c2g__Invoice__r.c2g__PaymentStatus__c != 'Paid'){
            
            Id periodDueDate = SEPA_UTILS.getPeriod(Date.today()).Id;
            
            // Generate appropriate Cash Entry
            c2g__codaCashEntry__c cashEntry = new c2g__codaCashEntry__c();
            
            cashEntry.c2g__Type__c = 'Receipt';
            
            c2g__codaBankAccount__c bankAccount = SEPA_UTILS.getBankAccountFromIban('PT50001000005300067000263');
            
            cashEntry.c2g__BankAccount__c = bankAccount.Id;
            //'a2A8E0000003qpM';
            cashEntry.c2g__Period__c = periodDueDate;
            cashEntry.c2g__CashEntryCurrency__c = bankAccount.c2g__BankAccountCurrency__r.Id;
            cashEntry.c2g__PaymentMethod__c = 'Electronic';
            //'a2624000002u9bt';
            List<c2g__codaCashEntryLineItem__c> cashEntryLineItems = new List<c2g__codaCashEntryLineItem__c>();
            
            //adicionar todos os Sepas

            c2g__codaCashEntryLineItem__c cashEntryLineItem = new c2g__codaCashEntryLineItem__c();
            cashEntryLineItem.c2g__AccountPaymentMethod__c = 'Electronic';
            cashEntryLineItem.c2g__Account__c = scn.c2g__Invoice__r.c2g__Account__c;
            cashEntryLineItem.c2g__CashEntryValue__c = scn.c2g__Invoice__r.c2g__OutstandingValue__c;
            cashEntryLineItems.add(cashEntryLineItem);
            
            //Execute DML to insert Cash Entry
            insert cashEntry;
            
            //atualizar o cashEntry.Id nos line items....
            for (c2g__codaCashEntryLineItem__c cashEntryLineItem2 : cashEntryLineItems) {
                cashEntryLineItem2.c2g__CashEntry__c = cashEntry.Id;
            }
            
            insert cashEntryLineItems;
            
            // Post the Cash Entry
            List<c2g.CODAAPICommon.Reference> cashEntryRefs = new List<c2g.CODAAPICommon.Reference>();
            cashEntryRefs.add(c2g.CODAAPICommon.getRef(cashEntry.Id, null));
            c2g.CODAAPICashEntry_7_0.BulkPostCashEntry(null, cashEntryRefs);
            
            
            List<String> documentRefs = new List<String>();
                
            documentRefs.add(scn.c2g__Invoice__r.Name);
            
            documentRefs.add([
                select Id, Name
                from c2g__codaCashEntry__c
                where Id = :cashEntry.Id
            ].Name);
                
            List<c2g__codaTransactionLineItem__c> transactionLinesToMatch = [
                select
                Id,
                c2g__AccountValue__c
                from c2g__codaTransactionLineItem__c
                where
                c2g__Transaction__r.c2g__DocumentNumber__c in :documentRefs
                and c2g__LineType__c = 'Account'
                AND c2g__Account__c = :scn.c2g__Account__c
            ];
            system.debug(LoggingLevel.INFO, 'transactionLinesToMatch.size(): ' + transactionLinesToMatch.size());
            
            // Match Invoice with Cash Entry
            c2g.CODAAPICommon_7_0.Context context = new c2g.CODAAPICommon_7_0.Context();
            c2g.CODAAPICashMatchingTypes_7_0.Configuration configuration = new c2g.CODAAPICashMatchingTypes_7_0.Configuration();
            configuration.Account = c2g.CODAAPICommon.getRef(scn.c2g__Account__c, null);
            
            system.debug(LoggingLevel.INFO, 'configuration.Account: ' + configuration.Account);
            configuration.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_7_0.enumMatchingCurrencyMode.Account;
            configuration.MatchingDate = System.today();
            
            system.debug(LoggingLevel.INFO, 'c2g.CODAAPICommon.getRef getPeriod(sepaRec.Sales_Invoice__r.c2g__DueDate__c).Id: ' + periodDueDate);
            
            configuration.MatchingPeriod = c2g.CODAAPICommon.getRef(periodDueDate, null);
            
            system.debug(LoggingLevel.INFO, 'configuration.MatchingPeriod: ' + configuration.MatchingPeriod);
            List<c2g.CODAAPICashMatchingTypes_7_0.Item> items = new List<c2g.CODAAPICashMatchingTypes_7_0.Item>();
            for (c2g__codaTransactionLineItem__c transactionLine : transactionLinesToMatch) {
                c2g.CODAAPICashMatchingTypes_7_0.Item item = new c2g.CODAAPICashMatchingTypes_7_0.Item();
                item.TransactionLineItem = c2g.CODAAPICommon.getRef(transactionLine.Id, null);
                item.Paid = transactionLine.c2g__AccountValue__c;
                item.Discount = 0; // No discount
                item.WriteOff = 0;  // No write off
                system.debug(LoggingLevel.INFO, 'c2g.CODAAPICashMatchingTypes_7_0.Item added: ' + item + ' transactionLine.Id:' + transactionLine.Id + ' transactionLine.c2g__AccountValue__c:' + transactionLine.c2g__AccountValue__c);
                
                items.add(item);
            }
            system.debug(LoggingLevel.INFO, 'List<c2g.CODAAPICashMatchingTypes_7_0.Item> items.size()' + items.size());
            
            c2g.CODAAPICashMatchingTypes_7_0.Analysis analisysInfo = new c2g.CODAAPICashMatchingTypes_7_0.Analysis();
            
            system.debug(LoggingLevel.INFO, 'analisysInfo: ' + analisysInfo);
            
            c2g.CODAAPICommon.Reference matchReference = c2g.CODAAPICashMatching_7_0.Match(context, configuration, items, analisysInfo);
            
            system.debug(LoggingLevel.INFO, 'matchReference: ' + matchReference);
            
        }
        Test.stopTest();
        
        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
        ref.id = scn.id  ;
        c2g.CODAAPISalesCreditNote_7_0.PostCreditNote(null, ref);
        
    }
    */
    
    @isTest (SeeAllData=true)
    public static void test_SEPA_SCN_to_SR() {
    
        Id scdId = 'a2T24000000xYHB';

        c2g__codaCreditNote__c salesCreditNote = [SELECT Id
                   , Name
                   , CR_Sepa_Record__c         
                   FROM c2g__codaCreditNote__c
                   WHERE
                   Id = :scdId ];
                   
        salesCreditNote.CR_Sepa_Record__c = null;
        update salesCreditNote;
        
        Test.startTest();
        Set<Id> creditNoteIdList = new Set<Id>();
        creditNoteIdList.add(scdId);
        SEPA_SCN_to_SR.addSRFromSCNs(creditNoteIdList);
        Test.stopTest();
        
    }
    
/*
    @isTest
    public static void updatePaymentCollectionWithSEPATest(){
        
        Test.startTest();
        
        SEPA_SCN_to_SR.updatePaymentCollectionWithSEPACreditNotes();
        
        Test.stopTest();
    }
*/    
    
}