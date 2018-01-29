public class DecisionTriggerHandler extends TriggerHandler{
    
    protected override void beforeUpdate(){
    	List<Decision__c> activeDecisionList = new List<Decision__c>();

    	for(Decision__c decNew : (List<Decision__c>)Trigger.new){
    		Decision_Modifier_History__c aux = new Decision_Modifier_History__c();
    		aux.Decision__c = decNew.Id;
    		Decision__c decOld = (Decision__c)Trigger.oldMap.get(decNew.Id);

    		//Update the decision after the approve when the Grade is change
    		if( decOld.Trigger_override__c == false && decNew.Trigger_override__c == true){
    			activeDecisionList.add(decNew);
    			
    			if(decNew.Grade_Override__c != null){
    				//TODO get this values form "Grade Card Line Items" table (pnly if there are many changes is the table)
    			    decNew.Grade__c = decNew.Grade_Override__c;
    			    if(decNew.Grade__c == '	KO'){
    			        decNew.Decison_Status__c = 'Declined';
    			    }else if(decNew.Grade__c == 'N/A'){
    			        decNew.Decison_Status__c = 'Pendent';
    			    }else{
    			        decNew.Decison_Status__c = 'Approved';
    			        decNew.Sub_Grade__c = '1';
    			    }
    			}
    			
    			if(decNew.Guidance_Limit_Max_Override__c != null){
    			    decNew.Guidance_Limit_Max__c = decNew.Guidance_Limit_Max_Override__c;
    			}
    			
    		}

    	}

    	setOverriteAndSetActiveCorrectly(activeDecisionList);
    }
    
    protected override void afterUpdate(){
    	Set<Decision__c> decisionSetToUpdate = new Set<Decision__c>();
    	List<Decision_Conditions_Card_History__c> conditionsTo_updateList = new List<Decision_Conditions_Card_History__c>();
    	List<Decision_Modifier_History__c> decisionModifierList = new List<Decision_Modifier_History__c>();
    	Map<Id,Decision__c> decision_ConditionCardMap = new Map<Id,Decision__c>([SELECT ID, Guidance_Limit_Max__c, (SELECT Id, Personal_Guarantee__c FROM Decision_Conditions_Card_History__r ORDER BY CreatedDate DESC NULLS LAST LIMIT 1) FROM Decision__c WHERE ID IN:Trigger.newMap.keySet() ]);
	
    	for(Decision__c decNew : (List<Decision__c>)Trigger.new){
    		Decision__c decision_Aux = decision_ConditionCardMap.get(decNew.Id);
    		Decision__c decOld = (Decision__c)Trigger.oldMap.get(decNew.Id);
    		List<Decision_Conditions_Card_History__c> conditionCardList = decision_Aux.Decision_Conditions_Card_History__r;
    		system.debug('conditionCardList' + conditionCardList);
    		
    		//store override chages
   		    if(decOld.Trigger_override__c == false && decNew.Trigger_override__c == true){
	            Decision_Modifier_History__c trackDecisionChange = new Decision_Modifier_History__c(Decision__c = decision_Aux.Id, 
	                                                                                                Grade__c = decOld.Grade__c, 
	                                                                                                Guidance_Limit_Max__c = decOld.Guidance_Limit_Max__c);
	            if(conditionCardList != null && conditionCardList.size() == 1){
	                trackDecisionChange.Personal_Guarantee__c = conditionCardList[0].Personal_Guarantee__c;
	            }  
    			decisionModifierList.add(trackDecisionChange);
            }   		
    		///////////
    		//Update the decision after the approve is not inclued when the grade is change
    		if( decOld.Trigger_override__c == false && decNew.Trigger_override__c == true && decOld.Grade__c != null && decOld.Grade__c == decNew.Grade__c){
    			 decision_Aux.Override__c = true;
    			    			
    			if(decNew.Guidance_Limit_Max_Override__c != null){
    				
    			    decision_Aux.Guidance_Limit_Max__c = decNew.Guidance_Limit_Max_Override__c;
    			    decisionSetToUpdate.add(decision_Aux);
    			}
    			if(decNew.Personal_Guarantee_Override__c != null){
    				if(decNew.Personal_Guarantee_Override__c != null && decNew.Personal_Guarantee_Override__c == 'Yes' && conditionCardList != null && conditionCardList[0].Personal_Guarantee__c == false){
    					conditionCardList[0].Personal_Guarantee__c = true;
    			        conditionsTo_updateList.add(conditionCardList[0]);

    				}else if(decNew.Personal_Guarantee_Override__c != null && decNew.Personal_Guarantee_Override__c == 'No' && conditionCardList != null && conditionCardList[0].Personal_Guarantee__c == true){
                        conditionCardList[0].Personal_Guarantee__c = false;
    			        conditionsTo_updateList.add(conditionCardList[0]);
    				}
    			}
    		}
    		

    	}
    	
        if(decisionModifierList.size() > 0){
    		system.debug('decisionModifierList' + decisionModifierList);
    		insert decisionModifierList;
    	}
    	    	
    	if(conditionsTo_updateList.size() > 0){
    		system.debug('conditionsTo_updateList' + conditionsTo_updateList);
    		update conditionsTo_updateList;
    	}
    	if(decisionSetToUpdate.size() > 0){
    		system.debug('decisionSetToUpdate' + decisionSetToUpdate);
    		update new List<Decision__c>(decisionSetToUpdate);
    	}
    	
    }
    
    public static void setOverriteAndSetActiveCorrectly(List<Decision__c> activeDecisionList) {
    	//used in before update TODO criar um handler para o Trigger
    	List<Id> accountIdList = new List<Id>();
    	for(Decision__c dec : activeDecisionList){
    		accountIdList.add(dec.Account__c);
    	}

    	List<Decision__c> inactiveDecisionList = [SELECT Id, Active__c, Account__c FROM Decision__c WHERE Account__c IN :accountIdList AND Active__c = true AND Id NOT IN :activeDecisionList];
        
        for(Decision__c decision : inactiveDecisionList){
        	decision.Active__c = false;
        }
        
        for(Decision__c decision : activeDecisionList){
        	decision.Active__c = true;
        	decision.Override__c = true;
        }
           	
    	if(inactiveDecisionList.size() > 0){
    	    update inactiveDecisionList;
    	}
    	
    }
    
}