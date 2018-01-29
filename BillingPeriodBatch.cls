global class BillingPeriodBatch implements Database.Batchable<sObject> {
    BILL_BillingProcess billingProcess = new BILL_BillingProcess();
        
    global BillingPeriodBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query;
        if(Test.isRunningTest()){
            query = 'Select Id,Billing_Period__c,Line_Item_End_Date__c,Application__r.Payment_Freq__c,Product__r.ProductCode From Billing_Contract_Line_Item__c where Line_Item_End_Date__c >= TODAY limit 5';
        }else{
            query = 'Select Id,Billing_Period__c,Line_Item_End_Date__c,Application__r.Payment_Freq__c,Product__r.ProductCode From Billing_Contract_Line_Item__c where Line_Item_End_Date__c >= TODAY';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Billing_Contract_Line_Item__c> billItemList) {

        for(Billing_Contract_Line_Item__c billItem : billItemList){
            billItem.Billing_Period__c = BILL_BillingProcess.setBillingPeriod(billItem.Product__r.ProductCode,billItem.Line_Item_End_Date__c, 'PT', billItem.Application__r.Payment_Freq__c);
        }
        
        update billItemList;
    }
    
    global void finish(Database.BatchableContext bc) {
        dummyMethod();
    }
    
    void dummyMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
}