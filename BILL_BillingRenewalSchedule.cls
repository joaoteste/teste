public class BILL_BillingRenewalSchedule implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        
        BILL_BillingRenewalBatch billingRenewalBatch = new BILL_BillingRenewalBatch();
        
        ID batchprocessid = Database.executeBatch(billingRenewalBatch, 15);
    }   
}