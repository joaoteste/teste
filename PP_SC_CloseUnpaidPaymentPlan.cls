public class PP_SC_CloseUnpaidPaymentPlan implements Schedulable{
    
    public void execute(SchedulableContext sc) {
		Database.executeBatch(new PP_BH_CloseUnpaidPaymentPlan(), 40);
    }
}