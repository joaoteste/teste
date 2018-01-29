global class Bill_UpdateBillingItemBatch implements Database.Batchable<sObject>{
    
    global Bill_UpdateBillingItemBatch(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Date data = Date.today().addMonths(-5);
        
        String query = 'Select Id,Line_Item_Start_Date__c,Line_Item_End_Date__c, Billing_Frequency__c,Billing_Period_Date__c,';
        query += 'Application__r.Payment_Timing__c,Application__r.Payment_Freq__c ';
        query += 'From Billing_Contract_Line_Item__c where Line_Item_Start_Date__c > :data ';
        if(Test.isRunningTest()){
            query += 'and Billing_Period_Date__c = null  limit 10';
        }else
            query += 'and Billing_Period_Date__c = null  limit 10000';
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Billing_Contract_Line_Item__c> billLineItemList) {
        
        System.debug('billLineItemList ' + billLineItemList.size());
        
        for(Billing_Contract_Line_Item__c billItem : billLineItemList){
            billItem.Billing_Period_Date__c = Bill_BillingProcess.getBillingPeriodDate(billItem.Line_Item_Start_Date__c,billItem.Application__r.Payment_Freq__c,
                                                                                       billItem.Application__r.Payment_Timing__c,billItem.Billing_Frequency__c);
        }
        update billLineItemList;
        
    }
    
    
    global void finish(Database.BatchableContext bc) {
    }
}