global class BatchMakeCall implements Database.Batchable < sObject >,Database.AllowsCallouts {

    global set<Id> taskIds;
    

    global BatchMakeCall(set<Id> tIds) {
        taskIds = tIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select id, Tape_Recording_Line_Item__c,WhoId from Task where id in : taskIds');
    }

    global void execute(Database.BatchableContext BC, List < Task > scope) {
        Task objTask = scope[0];
        Contact c = [select phone from Contact where id = : objTask.whoId limit 1];
        if(c.phone!=null)
            Call.makeScheduleCall(c.Phone,objTask.Tape_Recording_Line_Item__c,objTask.Id);
    }
    
    global void finish(Database.BatchableContext BC){
    }
}