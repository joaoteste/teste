public class PC_SC_FailedPaymentCollection implements Schedulable{
	
    public void execute(SchedulableContext sc) {
    	
		Database.executebatch(new PC_BH_FailedPaymentCollection(),50);
		
   }	
    
}