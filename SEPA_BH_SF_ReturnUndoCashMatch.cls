global class SEPA_BH_SF_ReturnUndoCashMatch  implements Database.Batchable<sObject>, Database.Stateful {
    
    global final Map<String, SEPA_TxInfAndSts> txInfAndStssMap;
    global final c2g__codaCashEntry__c cashEntry;
    global final CR_Sepa_File__c sepaFile;
    global final List<Id> sepaRecIdList;
    global final c2g__codaBankAccount__c bankAccount;
	global List<ID> accountAuxList = new List<ID>();      

    public SEPA_BH_SF_ReturnUndoCashMatch(List<Id> sepaRecIdList, c2g__codaCashEntry__c cashEntry, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, CR_Sepa_File__c sepaFile, c2g__codaBankAccount__c bankAccount){
    	this.cashEntry = cashEntry;
    	this.txInfAndStssMap = txInfAndStssMap;
    	this.sepaFile = sepaFile;
    	this.sepaRecIdList = sepaRecIdList;
    	this.bankAccount = bankAccount;
    }
 
    global Database.QueryLocator start(Database.BatchableContext BC){ 
  
        String query = 'SELECT Id, Name, Matching_Reference__c, Invoice_Number__c, Debtor_Account__c, Undo_Matching_Reference__c, Payment_Collection__c, CR_Sepa_File__c, Request_Amount__c  ' + 
                           ' FROM CR_Sepa_Record__c ' +
                           ' WHERE Id IN :sepaRecIdList';

        system.debug('1 - query:   ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CR_Sepa_Record__c> sepaRecordList){

        system.debug('1- sepaRecordList:   ' + sepaRecordList);

        SEPA_SF_Return.processRefundInvoicePayments(sepaFile, sepaRecordList, txInfAndStssMap, cashEntry, bankAccount, datetime.now() );
		
		for(CR_Sepa_Record__c sepaRecord : sepaRecordList){
            accountAuxList.add(sepaRecord.Debtor_Account__c);
        }           

    }
    
    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
            Database.executeBatch(new CC_BH_CreateCollectionCase(accountAuxList), 1);
		}
    }
    
}