public class Bill_Moloni_EPDFCreditNotes_Schedule implements Schedulable, Database.AllowsCallouts{

	public void execute(SchedulableContext sc) {
    	
		Database.executeBatch(new Bill_Moloni_EPDFCreditNotes_Batch(), 40);
		
	}    
}