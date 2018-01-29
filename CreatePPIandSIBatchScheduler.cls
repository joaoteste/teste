/**

Author   |Date  | Comments
Vinod    |09/26/2017 | Initial Creation

**/

global class CreatePPIandSIBatchScheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new CreatePPIandSIBatch(),1);
    }
    
}