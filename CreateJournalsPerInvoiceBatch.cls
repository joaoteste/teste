global class CreateJournalsPerInvoiceBatch implements Database.Batchable<sObject>{
    global Id appId;
    global List<String> apNameList = new List<String>();
    global Integer op = 0;
    
    global createJournalsPerInvoiceBatch() {
        this.op = 3;
    }
    
    global createJournalsPerInvoiceBatch(List<String> appList) {
        this.apNameList.addAll(appList);
        this.op = 3;
    }
    
    global createJournalsPerInvoiceBatch(List<String> appList, Integer operation) {
        this.apNameList.addAll(appList);
        this.op = operation;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> contractStatusList = new List<String>();
        contractStatusList.add('Contract - Running');
        contractStatusList.add('Contract - Arreas');
        contractStatusList.add('Contract - Arrears');
        contractStatusList.add('Contract - Closed');
        contractStatusList.add('Contract - Lawsuit');
        contractStatusList.add('Contract - Payment Plan');
        contractStatusList.add('Contract Early Termination');
        contractStatusList.add('Contract - Cancelled');
        
        String query;
        if(Test.isRunningTest()){
            query = 'Select Id From Application__c where Status__c in :contractStatusList ORDER BY Name DESC limit 5';
        }else{
            if(this.apNameList == null || this.apNameList.isEmpty()){
                query = 'Select Id From Application__c where Status__c in :contractStatusList ORDER BY Name DESC';
            }else{
                query = 'Select Id From Application__c where name in :apNameList';
            }
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Application__c> apList) {
        ID appId = null;
        try{
            Set<Id> journalsToPostId = new Set<Id>();  
            
            List<ID> apIdList = new List<ID>();
            for(Application__c app : apList){
                apIdList.add(app.id);
            }
            
            if(this.op == 1){
                UTIL_CancelAndCreateJournals.cancelOldJournalAppList(apIdList);
                appId = apIdList.get(0);
                UTIL_CancelAndCreateJournals.cashMatchingCancelJournals(appId);
            }else{
                if(this.op == 2){
                    journalsToPostId.addAll(Util_CancelAndCreateJournals.createJournalSettleContractAppList(apIdList));
                }else{
                    if(this.op == 3){
                        journalsToPostId.addAll(UTIL_CancelAndCreateJournals.createOldJournalsListAP(apIdList));
                        UTIL_CancelAndCreateJournals.postJournal(journalsToPostId);
                        
                    }
                }
            }
            
        }catch(Exception e){
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'CANCELJOURNALS',
                                                                                 message__c = appId +' Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage(),
                                                                                 printStackTrace__c = e.getStackTraceString());
            insert record;
        }
        
        //journalsToPostId.addAll(UTIL_CancelAndCreateJournals.createOldJournalsListAP(apIdList));
        /*if(!journalsToPostId.isEmpty()){
UTIL_CancelAndCreateJournals.postJournal(journalsToPostId);
}*/
    }
    
    global void finish(Database.BatchableContext bc) {
    }
    
}//