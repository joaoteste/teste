global class SC_BH_Create_Old_Decisions implements Database.Batchable<sObject>, Database.Stateful{

    public SC_BH_Create_Old_Decisions(){

    }
 // 0012400000w23BQ no decision
 // 0011o00001R6ePZAAZ with decision
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
        String query = 'SELECT Id, (SELECT Id,Vendor__c, Dummy__c, CreatedDate FROM Reports_DB__r ORDER BY CreatedDate DESC LIMIT 1) FROM Account '; 

        system.debug('1 - query:   ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> AccountList){

        system.debug('2- AccountList:   ' + AccountList);
        for(Account acc : AccountList){
        	system.debug('3- Account:   ' + acc);
        	//check if account has credit info
        	List<ReportDB__c> creditInfoList = [SELECT Id, Vendor__c, CreatedDate, Dummy__c FROM ReportDB__c WHERE Vendor__c = :acc.Id ORDER BY CreatedDate DESC LIMIT 1];
            if(creditInfoList != null || creditInfoList.size() == 1){
            	ReportDB__c crediInfo = creditInfoList.get(0);
            	system.debug('4- acc.Reports_DB__r:   ' + crediInfo);
            	system.debug('4- creditInfoList:   ' + creditInfoList);
            	//check if credit info has
            	List<Decision__c> decisionList = [SELECT Id FROM Decision__c WHERE Credit_Info__c = :crediInfo.Id];
            	system.debug('decisionList   ' + decisionList);
            	if(decisionList == null || decisionList.isEmpty() ){
            		system.debug('4- Create Decision');
            		crediInfo.Dummy__c = true;
            		update crediInfo;
            	}
            }
        }
        
    }

    global void finish(Database.BatchableContext BC){
	   
    }
  
/*

SC_BH_Create_Old_Decisions createDecisions = new SC_BH_Create_Old_Decisions(0);
ID batchprocessid = Database.executeBatch(createDecisions, 1);
*/
}