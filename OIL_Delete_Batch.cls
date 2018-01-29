global class OIL_Delete_Batch implements Database.Batchable<sObject>{
	
   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'Select Id, CreatedDate  From Outbound_Integration_Log__c  where CreatedDate <= LAST_N_DAYS:5';
      if (Test.isRunningTest()) {
         query += ' LIMIT 2';
      }
      
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Outbound_Integration_Log__c> outboundIntegrationLogs){
      delete outboundIntegrationLogs;
   }
   
   global void finish(Database.BatchableContext BC){
   }  
     
}