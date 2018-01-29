global class BILL_BillingRenewalBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public BILL_BillingRenewalBatch(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
        Integer year= Date.Today().Year();
        Integer month = Date.Today().Month();
        Date firstDayOfCurrPeriod = Date.newInstance(year, month, 1);
        Date lastDayOfFirstPeriod = Date.newInstance(year, month,Date.daysInMonth(year, month));
        lastDayOfFirstPeriod = lastDayOfFirstPeriod.addMonths(1);
        
        String query = 'SELECT Id, End_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, AccClient__c, ATM_Reference__c, ATM_Reference_Costs__c, Chosen_Insurance_value__c, Beginning_of_Term__c , Invoice_Payment_Date__c, Interim_Fee_Amount__c, ';
        query = query + ' Insurance_Pro_Rata__c,eSignature_Contract_Fee__c, Paper_Contract_Fee__c, TermCalc__c ';
        query = query + 'FROM Application__c WHERE End_of_Term__c <= :lastDayOfFirstPeriod and Id In (Select Application__c from Billing_Contract__c Where BC_Contract_Inactive__c=False)';
        
        if(Test.isRunningTest()){
        	query += ' limit 15';
        }			
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Application__c> appList){
        
        try{
            (new BILL_BillingRenewal()).billingRenewal(appList);
        }catch(Exception e){
            
        }      
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}