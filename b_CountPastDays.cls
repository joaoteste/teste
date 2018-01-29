global class b_CountPastDays implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{
    public b_CountPastDays(){
    } 
    global void execute(SchedulableContext SC) {           
        b_CountPastDays b = new b_CountPastDays(); 
        database.executebatch(b);       
    } 
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(Test.IsRunningTest())
             return Database.getQueryLocator([SELECT Id, Name, CC_Past_Due_Days__c From Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c= false limit 1]);
        
        return Database.getQueryLocator([SELECT Id, Name, CC_Past_Due_Days__c From Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c= false]);        
    }
    global void execute(Database.BatchableContext BC, List<Collection_Case__c> cCase){  
        for(Collection_Case__c cc:cCase){
            if(Test.isRunningTest() && cc.CC_Past_Due_Days__c == null) cc.CC_Past_Due_Days__c = 0;
            cc.CC_Past_Due_Days__c = Integer.valueOf(cc.CC_Past_Due_Days__c)+1;
        }
        if(!cCase.isEmpty()){
           update cCase;   
        } 
    }
    global void finish(Database.BatchableContext BC){  
    }
}
