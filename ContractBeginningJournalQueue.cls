public class ContractBeginningJournalQueue implements queueable {
    public ID appId;
    
    public ContractBeginningJournalQueue(ID appID){
        this.appId = appID;
        System.debug('ContractBeginningJournalQueue' + appID);
    }
    
    public void execute(QueueableContext ctx){
        
        List<ID> appIdList = new List<ID>();
        appIdList.add(this.appId);
        Set<ID> setJournalContractBeginning = new Set<ID>();
        setJournalContractBeginning.addAll(UTIL_CancelAndCreateJournals.createJournalSettleContractAppList(appIdList));
        if(!setJournalContractBeginning.isEmpty()){
        	UTIL_CancelAndCreateJournals.postJournal(setJournalContractBeginning);
        }

    }
}