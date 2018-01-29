//Test PP_SC_CloseUnpaidPaymentPlan
global class PP_BH_CloseUnpaidPaymentPlan implements Database.Batchable<sObject>{
    
	global Database.QueryLocator start(Database.BatchableContext BC){ 

        String query = 'SELECT Id, Payment_Plan__c FROM '+
                          'Payment_Schedule__c where Sales_Invoice__c = Null AND Payment_Plan__r.Status__c = \'Open\' AND Due_Date__c = LAST_N_DAYS:1 AND (Payment_Status__c = \'\' OR Payment_Status__c = Null OR Payment_Status__c = \'Not Payed\' OR Payment_Status__c = \'Not Paid\' OR Payment_Status__c = \'Unpaid\')';
		if(Test.isRunningTest()) query+=' LIMIT 1';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Payment_Schedule__c> psList){
        List<Payment_Plan__c> ppList = new List<Payment_Plan__c>();
          
        for(Payment_Schedule__c ps : psList){
            Payment_Plan__c pp = new Payment_Plan__c();
            pp.ID = ps.Payment_Plan__c;  
            pp.Status__c = 'Closed';
            ppList.add(pp);
        }
        
        //Criar novo Collection caso não haja nenhum aberto e adicionar as facturas em atraso
        
    }
    
    global void finish(Database.BatchableContext BC){
        //TODO
    }
}