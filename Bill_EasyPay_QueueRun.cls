public class Bill_EasyPay_QueueRun implements Queueable, Database.AllowsCallouts {
    
       public void execute(QueueableContext context) {
        	new Bill_EasyPayAPI().getFetchMBPaymentsFixedTime();
       }

}