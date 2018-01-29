public class BILL_QE_Create_Deferred_Journals implements queueable {
    public set<ID> journalID;
    
    public BILL_QE_Create_Deferred_journals(set<ID> journalID){
        this.journalID = journalID;
        System.debug('JournasQe_Create_Deferred' + journalID);
    }
     
    public void execute(QueueableContext ctx){

       BILL_Deferred_Journals CreateDeferredJnl = new BILL_Deferred_Journals();
       CreateDeferredJnl.Create_Deferred_Journals(journalID);
        
    }
}