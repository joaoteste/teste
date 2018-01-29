global class FF_BH_CleanClickLinkLogLineItems implements Database.Batchable<sObject>{

   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'Select Id, CreatedDate  From ffirule__IntegrationRuleLogLineItem__c where CreatedDate < LAST_N_DAYS:5';
      if (Test.isRunningTest()) {
         query += ' LIMIT 2';
      }
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<ffirule__IntegrationRuleLogLineItem__c> clickLinkLogList){
      delete clickLinkLogList;
   }
   
   global void finish(Database.BatchableContext BC){
   }
}