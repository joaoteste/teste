//testClass: UTIL_CancelAndCreateJournals_TEST
global class JournalDeferredPostBatch implements Database.Batchable<sObject>{
    global List<String> apNameList = new List<String>();
    
    global JournalDeferredPostBatch() {
        
    }
    
    global JournalDeferredPostBatch(List<String> appList) {
        this.apNameList.addAll(appList);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String inProgress = 'In Progress';
        String query;
        if(Test.isRunningTest()){
            if(this.apNameList == null || this.apNameList.isEmpty()){
                query = 'Select ID FROM c2g__codaJournal__c  where c2g__JournalStatus__c = :inProgress and Batch_To_Post__c = True limit 5';
            }else{
                query = 'Select ID FROM c2g__codaJournal__c  where c2g__JournalStatus__c = :inProgress and Batch_To_Post__c = True and Application__r.Name in :apNameList limit 5';
            }
        }else{
            if(this.apNameList == null || this.apNameList.isEmpty()){
                query = 'Select ID FROM c2g__codaJournal__c  where c2g__JournalStatus__c = :inProgress and Batch_To_Post__c = True';
            }else{
                query = 'Select ID FROM c2g__codaJournal__c  where c2g__JournalStatus__c = :inProgress and Batch_To_Post__c = True and Application__r.Name in :apNameList';
            }
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<c2g__codaJournal__c> journalList) {
        
        List<c2g.CODAAPICommon.Reference> refs = new List<c2g.CODAAPICommon.Reference>();
        for(c2g__codaJournal__c journal :journalList){
            c2g.CODAAPICommon.Reference ref1 = new c2g.CODAAPICommon.Reference();  
            ref1.Id = journal.id;
            refs.add(ref1);
        }
        c2g.CODAAPIJournal_6_0.BulkPostJournal(null, refs);
    }
    
    
    global void finish(Database.BatchableContext bc) {
    }
    
}