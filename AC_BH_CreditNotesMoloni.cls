global class AC_BH_CreditNotesMoloni implements Database.Batchable<sObject>, Database.Stateful{

	List<ID> creditNotesInputList;
	BILL_MoloniApi billAPI = new BILL_MoloniApi(); 
		
	global AC_BH_CreditNotesMoloni(List<ID> creditNotesInputList){
		this.creditNotesInputList = creditNotesInputList;
	}
  
  	global Database.QueryLocator start(Database.BatchableContext BC){
   	 	    
   	    String query = 'SELECT ID FROM c2g__codaCreditNote__c WHERE ID in :creditNotesInputList';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__codaCreditNote__c> creditNotesList){
    	
    	c2g__codaCreditNote__c cn = creditNotesList[0];
        
        ID cnID = cn.ID;

        billAPI.createCreditNote(cnID); 
    		
    }
    
    global void finish(Database.BatchableContext BC){
    }
        
}