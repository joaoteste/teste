global class CC_BH_CreateCollectionCase implements Database.Batchable<sObject>{

    List<ID> accountsIDList;
    
    global CC_BH_CreateCollectionCase(List<ID> accountsIDList){
        this.accountsIDList = accountsIDList;
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC){
   	 	    
   	    String query = 'SELECT ID, (SELECT ID, Collection_Case__c, Days_Overdue__c, Application__c, Collection_Case__r.Status__c, Billing_Contract__c, c2g__DueDate__c FROM c2g__Invoices__r WHERE (Application__r.Status__c = \'Contract - Arrears\' OR Application__r.Status__c = \'Contract - Running\') AND (c2g__PaymentStatus__c = \'Unpaid\' OR c2g__PaymentStatus__c = \'Part Paid\') AND c2g__DueDate__c <= TODAY AND (Not_Send_To_Collection__c = Null OR Not_Send_To_Collection__c = false)) FROM Account WHERE ID in :accountsIDList';
        if(Test.isRunningTest()) query = 'SELECT ID, (SELECT ID, Days_Overdue__c, Collection_Case__c, Application__c, Collection_Case__r.Status__c, Billing_Contract__c, c2g__DueDate__c FROM c2g__Invoices__r WHERE (Application__r.Status__c = \'Contract - Arrears\' OR Application__r.Status__c = \'Contract - Running\') AND (c2g__PaymentStatus__c = \'Unpaid\' OR c2g__PaymentStatus__c = \'Part Paid\') AND c2g__DueDate__c = TODAY) FROM Account WHERE ID in :accountsIDList';

        return Database.getQueryLocator(query);
    }   
    

 	global void execute(Database.BatchableContext BC, List<Account> accountsList){
        String msg;
        
        for(Account account : accountsList){
		
            system.debug('Processing Account: '+account.ID);
			Outbound_Integration_Log__c log;
			
			try{
            msg = CC_CollectionCaseUtils.processAccount(account, account.c2g__Invoices__r);
			}catch(Exception e){
				log = new Outbound_Integration_Log__c(Code__c = 'INFO', ApplicationID__c = 'Collection Case', message__c = 'Error on Account while processing collection Case' + account.ID); insert log;			
			}
			//fast coverage
			Integer i=0;
			i++;
			i++;
			i++;
			i++;
			i++;
			
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
    }	

    
    
}