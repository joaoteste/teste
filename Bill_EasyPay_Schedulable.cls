public class Bill_EasyPay_Schedulable implements Schedulable, Database.AllowsCallouts{
    
    public void execute(SchedulableContext sc) {
    	
		system.enqueueJob(new Bill_EasyPay_QueueRun());
		
   }
}