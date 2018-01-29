global class SEPA_BH_SF_Return implements Database.Batchable<sObject>, Database.Stateful{


    global final Map<String, SEPA_TxInfAndSts> txInfAndStssMap;
    global final c2g__codaCashEntry__c cashEntry;
    global final ID SEPAFileId;  

    public SEPA_BH_SF_Return(c2g__codaCashEntry__c cashEntry, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, Id SEPAFileId){
    	this.cashEntry = cashEntry;
    	this.txInfAndStssMap = txInfAndStssMap;
    	this.SEPAFileId = SEPAFileId;
    }
 
    global Database.QueryLocator start(Database.BatchableContext BC){ 
    	// ir buscar os line number do Transaction Line Items que é um numero igual ao Cash Entries Line Item.
    	//String query = 'Select Id, CR_Sepa_Record__r.Return_Amount__c, CR_Sepa_Record__r.Sales_Invoice__c, c2g__CashEntry__c  FROM c2g__codaCashEntryLineItem__c WHERE c2g__CashEntry__c = :cashEntryId';

        String query = 'SELECT Id, Invoice_Number__c, Debtor_Account__c, Sales_Invoice__r.c2g__Period__r.Id, Sales_Invoice__r.c2g__DueDate__c, Matching_Reference__c, Name, Payable_Invoice__c, Sales_Credit_Note__c, Document_Type__c, ' + 
                       ' Payable_Invoice__r.Name, Sales_Credit_Note__r.Name, Payment_Collection__c ' +
                           ' FROM CR_Sepa_Record__c ' +
                           ' WHERE Return_Status_Code__c = \'0000\' AND CR_Sepa_File__c = :SEPAFileId';

        system.debug('1 - query:   ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CR_Sepa_Record__c> sepaRecordList){

        system.debug('1- sepaRecordList:   ' + sepaRecordList);
        for(CR_Sepa_Record__c sepaRecord : sepaRecordList){
            SEPA_SF_Return.processInvoicePayments(sepaRecord, txInfAndStssMap, cashEntry, datetime.now() );
        }

    }
    
    global void finish(Database.BatchableContext BC){
	   
    }
    
}
