global class b_ReminderUpdate implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{
     
    public void execute(SchedulableContext SC) {
        b_ReminderUpdate ru = new b_ReminderUpdate();
        Database.executebatch(ru, 1);
    } 
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(Test.IsRunningTest())
            return Database.getQueryLocator([select Id,Amount_Claimed__c,Due_Date__c,Updated_Reminder__c,Updated_Date__c From Dunning_Alert__c where Updated__c = true and Updated_Reminder__c = false limit 1]);
        
        return Database.getQueryLocator([select Id,Amount_Claimed__c,Due_Date__c,Updated_Reminder__c,Updated_Date__c From Dunning_Alert__c where Updated__c = true and Updated_Reminder__c = false]);
        
    }
    
    public void execute(Database.BatchableContext BC, List<Dunning_Alert__c> DunningAlert){ 
        List<ATM_Reference__c> listATM = new List<ATM_Reference__c>();  
        for(Dunning_Alert__c da : DunningAlert){
            Date date_today = date.today();
            /*if(Test.isRunningTest()){
                date_today = da.Updated_Date__c;
                date_today = date_today-1;
            }*/          
            
            if(da.Updated_Date__c == date_today-1){
                da.Updated_Reminder__c = true;
                da.Email_Send_Date__c = date_today + 1;
                Bill_EasyPayAPI billEasyPay = new Bill_EasyPayAPI(); 
                if(!Test.isRunningTest())
                    listATM.add(billEasyPay.getNewMBReference(String.ValueOf(da.Amount_Claimed__c), Date.valueOf(da.Due_Date__c), da.id, 'DunningAlert'));
            } 
        }
        if(!listATM.isEmpty()){  
             
            try{
                insert listATM;                
                PaymentCollection_Utils pcUtils = new PaymentCollection_Utils(); pcUtils.createPaymentCollectionWithATM(listATM);             
            }catch(Exception e){
                system.debug('Erro EasyPay');          
            }            
        }
        update  DunningAlert;
    }
    
    public void finish(Database.BatchableContext BC){}
}