//this class is responsible for canceling a sales invoices

global class Bill_CancelInvoice {
    
    webservice static String cancelMultipleInvoices(List<ID> salesInvoiceIDList){
        Database.executeBatch(new BILL_BH_CancelInvoice(salesInvoiceIDList),1);
        return 'Process started.';
    }

    
    webservice static String cancelInvoice(ID salesInvoiceID){
        Savepoint sp = Database.setSavepoint();	        
        c2g__codaInvoice__c salesInvoice;
        c2g__codaInvoice__c salesInvoiceToUpdate;
        try{
            //Get Transaction
            salesInvoice = [SELECT ID, Name, c2g__Account__c, c2g__Transaction__r.c2g__DocumentNumber__c, c2g__Transaction__r.c2g__TransactionDate__c, c2g__Transaction__r.c2g__Period__c FROM c2g__codaInvoice__c WHERE ID =:salesInvoiceID];
            salesInvoiceToUpdate =  [SELECT ID, Canceled__c FROM c2g__codaInvoice__c WHERE ID =:salesInvoiceID];
            salesInvoiceToUpdate.Canceled__c = true;
            update salesInvoiceToUpdate;            
            ID transactionID = salesInvoice.c2g__Transaction__c;
            
            //Get Transaction Line Items
                    
            List<c2g__codaTransactionLineItem__c> transactionLIList = [SELECT ID, c2g__HomeValue__c, c2g__LineType__c, c2g__AccountValue__c,  c2g__GeneralLedgerAccount__c FROM c2g__codaTransactionLineItem__c WHERE c2g__Transaction__c = :transactionID];
            
            //Create Journal
            
                  c2g__codaJournal__c journal = new c2g__codaJournal__c();
                  journal.c2g__Type__c = 'Manual Journal';
                  journal.c2g__JournalDate__c = salesInvoice.c2g__Transaction__r.c2g__TransactionDate__c;
                  journal.c2g__DeriveCurrency__c = true;
                  journal.c2g__DerivePeriod__c = false;
                  journal.c2g__Reference__c = salesInvoice.Name ;
                  journal.c2g__JournalDescription__c = salesInvoice.Name + ' Anulação';
                  journal.c2g__Period__c = salesInvoice.c2g__Transaction__r.c2g__Period__c;
            system.debug(journal);
                  insert journal;        
            
            
            
            
            //Create Journal Line Items
            List<c2g__codaJournalLineItem__c> allJournalLineItemsList = new List<c2g__codaJournalLineItem__c>();
            
            for(c2g__codaTransactionLineItem__c transLI : transactionLIList){
                
                c2g__codaJournalLineItem__c journalLineItem = new c2g__codaJournalLineItem__c();
                journalLineItem.c2g__Journal__c = journal.ID;
                journalLineItem.c2g__Value__c = -transLI.c2g__HomeValue__c; 
                journalLineItem.c2g__GeneralLedgerAccount__c = transLI.c2g__GeneralLedgerAccount__c;    
                
                if(transLI.c2g__LineType__c == 'Account'){
                    //create journal line item
                    journalLineItem.c2g__Account__c = salesInvoice.c2g__Account__c;    
                    journalLineItem.c2g__LineType__c = 'Account - Customer';
                }else{
                    //create journal line item
                    journalLineItem.c2g__LineType__c = 'General Ledger Account';                
                }
                system.debug(journalLineItem);
                allJournalLineItemsList.add(journalLineItem);
            }
            
            //inserts all journals in the database
            insert allJournalLineItemsList;               
            
            system.debug(journal);
            //Post Journal
            postJournal(journal);        
            
            
            //Get transaction line items
            c2g__codaJournal__c journalUpdated = [SELECT ID, Name, c2g__Transaction__c FROM c2g__codaJournal__c WHERE ID =:journal.ID];   

			c2g.CODAAPICommon_10_0.Context context = new c2g.CODAAPICommon_10_0.Context();
            c2g.CODAAPIInvoiceTypes_10_0.InvoiceForAmend siToUpdate = new c2g.CODAAPIInvoiceTypes_10_0.InvoiceForAmend();
            c2g.CODAAPICommon.Reference ref = new 	c2g.CODAAPICommon.Reference();
            ref.ID = salesInvoice.ID;
            siToUpdate.Invoice = ref;
            siToUpdate.InvoiceDescription = 'Anulado com Journal: '+ journalUpdated.Name;
            c2g.CODAAPISalesInvoice_10_0.BulkAmendInvoice(context, new c2g.CODAAPIInvoiceTypes_10_0.InvoiceForAmend[] {siToUpdate} );
 
            
            List<c2g__codaTransactionLineItem__c> transactionLIJournalList = [SELECT ID, c2g__HomeValue__c, c2g__LineType__c, c2g__AccountValue__c, c2g__GeneralLedgerAccount__c FROM c2g__codaTransactionLineItem__c WHERE c2g__Transaction__c = :transactionID AND c2g__LineType__c = 'Account'];
            List<c2g__codaTransactionLineItem__c> transactionLIList2 = [SELECT ID, c2g__HomeValue__c, c2g__LineType__c, c2g__AccountValue__c,  c2g__GeneralLedgerAccount__c FROM c2g__codaTransactionLineItem__c WHERE c2g__Transaction__c = :journalUpdated.c2g__Transaction__c AND c2g__LineType__c = 'Account'];
            transactionLIJournalList.addAll(transactionLIList2);
            system.debug(transactionLIList2);
            system.debug(transactionLIJournalList);
            //Cash Matching
            FF_Utils.doMatch(salesInvoice.c2g__Account__c, getPeriod(), transactionLIJournalList);
            
            
            return ' Success!';
    	}catch(Exception e){
            system.debug(e);
            Database.rollback(sp);

            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'Cancel Invoice',
            																	message__c = 'It wasnt possible to cancel invoice' + salesInvoice.Id + '\n' + e.getMessage() + e.getStackTraceString());
            system.debug(record);
            insert record;            
        	return ' Not Success';            
        }
    }
    
    //post a single journal
    private static void postJournal(c2g__codaJournal__c journal){
        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
        ref.Id = journal.Id;
        c2g.CODAAPIJournal_9_0.PostJournal(null, ref);         
    }    
    
	//returns the current period ID
    private static ID getPeriod(){      
        Date d = Date.today();
        Date periodDate = Date.newInstance(d.year(), d.month(), d.day());
        return getPeriod(periodDate).Id; 
    }
    
    //given a date returns the period associated 
    private static c2g__codaPeriod__c getPeriod(date periodDate) {
        system.debug(LoggingLevel.INFO, 'c2g__codaPeriod__c getPeriod periodDate' + periodDate);
        c2g__codaPeriod__c currentPeriod = [SELECT ID FROM c2g__codaPeriod__c where c2g__StartDate__c <= :periodDate AND c2g__EndDate__c >= :periodDate];
        return currentPeriod;
    }     
}