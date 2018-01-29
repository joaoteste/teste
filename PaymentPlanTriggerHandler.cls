public class PaymentPlanTriggerHandler {
    
    public static void handleUpdateInjunction(List<Payment_Plan__c> newValues){
        //if the collection case of the created payment plan has an injunction, populate injunction's (PP) fields and change its recordType 
        Map<Id,Payment_Plan__c> ccToPp = new Map<Id,Payment_Plan__c>();
        for(Payment_Plan__c pp : newValues){
            ccToPp.put(pp.Collection_Case__c, pp);
        }
        
        List<Injunction_Procedure__c> injs = [SELECT Collection_Case__c, RecordTypeId, Payment_Plan__c FROM Injunction_Procedure__c WHERE Collection_Case__c IN :ccToPp.keySet()];
        Id recordTypeId = Schema.getGlobalDescribe().get('Injunction_Procedure__c').getDescribe()
        .getRecordTypeInfosByName().get('Injunction With Payment Plan').getRecordTypeId();
        for(Injunction_Procedure__c inj : injs){
            Payment_Plan__c aux = ccToPp.get(inj.Collection_Case__c);
            inj.Payment_Plan__c = aux.Id;
            inj.RecordTypeId = recordTypeId;
        }
        
        update injs;
    }
    
    
    public static void handleSinglePayment(List<Payment_Plan__c> newValues, Map<ID, Payment_Plan__c> oldMapValues){
    	Set<ID> ppIDList = new Set<ID>();
    	for(Payment_Plan__c pp : newValues){
    		if(pp.Status__c == 'Closed' && oldMapValues.get(pp.ID).Status__c == 'Open' && pp.Number_of_Payments__c == '1'){
    			ppIDList.add(pp.ID);
    		}
    	}
    	
    	if(!ppIDList.isEmpty()){
    		List<Payment_Schedule__c> psList = new List<Payment_Schedule__c>([SELECT ID, Payment_Plan__c, Payment_Plan__r.Collection_Case__r.Nr_of_Single_Payments__c  FROM Payment_Schedule__c WHERE Schedule_Number__c = '1' AND Payment_Collection__r.Status__c = 'Paid' AND Payment_Plan__c in :ppIDList]);
    		
    		if(!psList.isEmpty()){
    			List<Collection_Case__c> ccList = new List<Collection_Case__c>();
    			for(Payment_Schedule__c ps : psList){
					Collection_Case__c  cc = new Collection_Case__c(ID = oldMapValues.get(ps.Payment_Plan__c).Collection_Case__c);
                    if(ps.Payment_Plan__r.Collection_Case__r.Nr_of_Single_Payments__c != null)
						cc.Nr_of_Single_Payments__c = ps.Payment_Plan__r.Collection_Case__r.Nr_of_Single_Payments__c + 1;
                    else
                        cc.Nr_of_Single_Payments__c = 1;
					cc.Last_Payment_Date__c  = system.today();
					ccList.add(cc);
    			}	
    			update ccList;			    			
    		}
    	}
    }

}