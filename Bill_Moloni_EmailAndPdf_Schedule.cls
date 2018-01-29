public class Bill_Moloni_EmailAndPdf_Schedule implements Schedulable, Database.AllowsCallouts{

	public void execute(SchedulableContext sc) {
    	
		Database.executeBatch(new Bill_Moloni_EmailAndPdf_Batch(), 40);
		
	}    
}