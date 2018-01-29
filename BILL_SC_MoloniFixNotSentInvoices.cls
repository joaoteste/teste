//BILL_BH_MoloniFixNotSent_Test
public class BILL_SC_MoloniFixNotSentInvoices implements Schedulable, Database.AllowsCallouts{
    
    public void execute(SchedulableContext sc) {
		Database.executeBatch(new Bill_BH_MoloniFixNotSentInvoices(), 1);
    }
}