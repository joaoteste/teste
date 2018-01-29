global class BILL_BH_CancelInvoice implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global final List<ID> salesInvoiceIDList;
   
    
    public BILL_BH_CancelInvoice(List<ID> salesInvoiceIDList){
        this.salesInvoiceIDList = salesInvoiceIDList;
    }
    
    
	global Database.QueryLocator start(Database.BatchableContext BC){ 		

        String query = 'SELECT Id FROM c2g__codaInvoice__c WHERE ID in :salesInvoiceIDList';
        if(Test.isRunningTest()) query+= ' Limit 1';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<c2g__codaInvoice__c> salesInvoice){
        for(c2g__codaInvoice__c si : salesInvoice){
            Bill_CancelInvoice.cancelInvoice(si.ID);
        }
    }
    
    global void finish(Database.BatchableContext BC){
            //TODO
    }
}