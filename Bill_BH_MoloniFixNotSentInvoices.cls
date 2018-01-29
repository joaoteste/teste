global class Bill_BH_MoloniFixNotSentInvoices implements Database.Batchable<sObject>, Database.AllowsCallouts{
	
    List<String> oilList = new List<String>();

    
	global Database.QueryLocator start(Database.BatchableContext BC){
   	 	    
   	    String query = 'SELECT ID,Name FROM c2g__codaInvoice__c WHERE Invoice_Email_Status__c = \'Not Send\' AND Invoice_Express_Number_text__c = \'\' AND  c2g__InvoiceStatus__c = \'Complete\' AND c2g__PaymentStatus__c = \'Unpaid\'';
   	    if(Test.isRunningTest()) query+= ' LIMIT 1';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__codaInvoice__c> salesInvoiceList){
    	BILL_MoloniApi billMoloniAPI = new BILL_MoloniApi();
        
    	for(c2g__codaInvoice__c si : salesInvoiceList){
    		
    		String msg;
    		
    		if(!Test.isRunningTest()) msg = billMoloniAPI.createInvoiceMoloniFinalized(si.ID); else msg = 'Failed';
    		
    		if(msg != 'Factura criada no Moloni com sucesso. Verifique no link presente no campo InvoiceXpress Link se está tudo ok.' || msg!= ''){
    			oilList.add(si.Name + ' ' + si.ID); 
    		}
    	}
    }    
    
    global void finish(Database.BatchableContext BC){
        if(!oilList.isEmpty()){
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
                                                                                            message__c = 'Could not send invoices to moloni: '+ oilList);
            insert record;   
        }
        
    }	    
}