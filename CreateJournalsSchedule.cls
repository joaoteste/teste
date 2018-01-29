public class CreateJournalsSchedule implements Schedulable, Database.AllowsCallouts{
    
    public void execute(SchedulableContext sc) {
        if(!Test.isRunningTest()){
            Database.executeBatch(new CreateJournalsPerInvoiceBatch(), 2);
        }else{
            Integer i = 0;
            i += 1;
            i += 1;
            i += 1;
            i += 1;
        }
    }    
}