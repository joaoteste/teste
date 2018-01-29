public class UTIL_QE_CashMatchCancelJnl implements queueable {
 
    public Id clientId;
    public Id periodId;
    public List<c2g__codaTransactionLineItem__c> TrsLineItems;
    
    public UTIL_QE_CashMatchCancelJnl(Id clientId, Id periodId,  List<c2g__codaTransactionLineItem__c> TrsLineItems){
        this.clientId = clientId;
        this.periodId = periodId;
        this.TrsLineItems =TrsLineItems;
        
    }
     
    public void execute(QueueableContext ctx){

          FF_Utils.doMatch( clientId,null,TrsLineItems);
        
    }
}