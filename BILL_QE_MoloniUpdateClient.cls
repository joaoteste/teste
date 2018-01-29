//Tests: BILL_QE_MoloniUpdateClientTest
public class BILL_QE_MoloniUpdateClient implements Queueable, Database.AllowsCallouts {
    public List<Id> accountIdList;
    
    public BILL_QE_MoloniUpdateClient(List<Id> accountIdList){
        this.accountIdList = accountIdList;
        System.debug('BILL_QE_MoloniUpdateClient' + accountIdList);
    }
     
    public void execute(QueueableContext ctx){

       BILL_MoloniApi moloniApi = new BILL_MoloniApi();
       for(Id accountId : accountIdList){
           moloniApi.updateClient(accountId);
       }
        
    }
}