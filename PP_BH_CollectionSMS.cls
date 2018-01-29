global class PP_BH_CollectionSMS implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

	global List<ID> auxPSList = new List<ID>();
	
	global Database.QueryLocator start(Database.BatchableContext BC){ 

        String query = 'SELECT Id, Payment_Plan__c, Schedule_Number__c, Due_Date__c, Payment_Plan__r.Contact__r.Email, Payment_Plan__r.Contact__r.FirstName, Payment_Plan__r.Contact__r.LastName, Payment_Plan__r.Contact__r.MobilePhone,Payment_Plan__r.Collection_Case__c, Payment_Plan__r.Name, ATM__r.Amount__c, ATM_Entity__c, ATM_Reference__c FROM '+
                          'Payment_Schedule__c where ID in:auxPSList';
        
        if(!Test.isRunningTest()) query+= ' LIMIT 1';

        return Database.getQueryLocator(query);
    }
    
    global PP_BH_CollectionSMS(List<ID> listAux){
    	this.auxPSList = listAux;
    }
    
    global void execute(Database.BatchableContext BC, List<Payment_Schedule__C> psList){
		for(Payment_Schedule__C ps : psList){
                String msg = 'A prestação do plano de pagamentos encontra-se vencida. Para regularizar: Ent '+String.valueOf(ps.ATM_Entity__c).left(5)+' Ref '+ps.ATM_Reference__c+' Valor '+ ps.ATM__r.Amount__c+'€';    
                if(!Test.isrunningTest()) SMSUtil.sendSms(ps.Payment_Plan__r.Contact__r.MobilePhone, 'CANDOR', msg, ps.Payment_Plan__c);		
                
                updateRentingStatus(ps.Payment_Plan__r.Collection_Case__c);		
		} 	
    }
     
    global void finish(Database.BatchableContext BC){
		
    }
     
    
    public static void updateRentingStatus(ID ccID){
            List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id, Application__c FROM c2g__codaInvoice__c WHERE  Collection_Case__c =:ccID ];
        
            Set<ID> apIDS = new Set<ID>();
            for(c2g__codaInvoice__c si : salesInvoiceList){

                if(si.Application__c != null)
                    apIDS.add(si.Application__c);
            }
            
            List<Application__c> apList = new List<Application__c>();
            
            
            if(!apIDS.isEmpty()){
                for(ID ap : apIDS){
                    Application__c apToUpdate = new Application__c();
                    apToUpdate.ID = ap;
                    apToUpdate.Status__c = 'Contract - Arreas';
                    apList.add(apToUpdate);
                }     
                
                system.debug(apList);   
            } 
            
            update apList;       	
    }
    
}