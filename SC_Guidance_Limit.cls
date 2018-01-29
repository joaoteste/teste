// TODO - alterar o código para que possa ser chamado por um trigger sem ter problemas (i.e. rever SELECT's e insert's)
//Tests: SC_Guidance_Limit_Test SC_ScoreCard_Test
public class SC_Guidance_Limit {

    @InvocableMethod  
    public static void updateDecision(List<Decision__c> decisionList){
    	
    	List<Id> decisionIDList = new List<Id>();
    	for(Decision__c decision : decisionList){
    		decisionIDList.add(decision.Id);
    	}
    	
        system.debug('SC_Guidance_Limit.updateDecision');

        //Not sure if this query is needed
        List<Decision__c> decisionListAux = [Select Id, 
                                                    Grade__c, 
                                                    Account__c,
                                                    Credit_Info__c, 
                                                    Guidance_Limit_Scorcard__c, 
                                                    Guidance_Limit_Line_Item__c,
                                                    Trigger_override__c,
                                                    Personal_Guarantee_Override__c,
                                                    Guidance_Limit_Max_Override__c,
                                                    Account__r.BillingCountryCode
                                                         FROM Decision__c WHERE Id IN :decisionIDList];
        
        for(Decision__c decision : decisionListAux){
        	if(decision.Grade__c != null ){ //TODO passar esta condição para o process builder ? 
    		    boolean checkGrade = pattern.matches('[A-G]',decision.Grade__c); //TODO passar também esta condição para o process builder?
    		    if(checkGrade){
    		        processDecision(decision);
    		        system.debug('1 - SC_ScoreCard.selectConditionCardLineItem(');
    		        SC_ScoreCard.selectConditionCardLineItem(decision, decision.Account__r.BillingCountryCode);
    		    }
    	    }
        }
        
    }

    //TODO alterar o nome do metodo
    //private methods
    private static void processDecision(Decision__c dec2){
    	
    	system.debug('dec2: ' + dec2);
    	system.debug('dec2.Guidance_Limit_Scorcard__c: ' + dec2.Guidance_Limit_Scorcard__c);
    	system.debug('dec2.Grade__c: ' + dec2.Grade__c);

        Id accountId = dec2.Account__c;
        
        if(dec2.Guidance_Limit_Scorcard__c == null){
        	system.debug('SC_Guidance_Limit.updateDecision');
        	return;
        }

        List<Guidance_Limit_Line_Item__c> guidLLItemLitList = [Select Id, 
        	                                                 Field_API_Name__c,
        	                                                 Field_Name__c,
        	                                                 Grade__c,
        	                                                 Guidance_Limit_Max__c,
        	                                                 Guidance_Limit_Min__c,
        	                                                 Guidance_Limit_Scorcard__c,
        	                                                 Matching_Type__c,
        	                                                 Max_Value__c,
        	                                                 Min_Value__c,
        	                                                 Related_Object__c,
        	                                                 Related_Object_API_Name__c,
        	                                                 Value__c,
        	                                                 Value_Amount__c
        	                                            FROM Guidance_Limit_Line_Item__c WHERE Grade__c = :dec2.Grade__c AND Guidance_Limit_Scorcard__c = :dec2.Guidance_Limit_Scorcard__c];
        	
        	
         system.debug('guidLLItemLitList: ' + guidLLItemLitList);
        	
//////////////////////////////
// Query values that are use in calculation        
//////////////////////////////


 //     key= object values = set de fields  //just used to confirm if the field is duplicated
        Map<String,Set<String>> objectFieldsMap = new Map<String,Set<String>>();
//     key= object values = String of fields to query
        Map<String, String> objectFieldsQueryFormatMap = new Map<String,String>();
//     key= object values = query Filter
        Map<String, String> objectFieldsQueryFilterMap = new Map<String,String>();

        for(Guidance_Limit_Line_Item__c lineItens : guidLLItemLitList){
        	
        	if( lineItens.Related_Object__c == null){
        		if(lineItens.Matching_Type__c != 'Static Value'){
        			// fazer uma test class para verificar isto
        		    system.debug('ERROR' + lineItens);	
        		}
        		continue;
        	}
        	
            Set<String> auxSet = objectFieldsMap.get(lineItens.Related_Object_API_Name__c);
            if(auxSet == null){
                auxSet = new Set<String>();
                objectFieldsMap.put(lineItens.Related_Object_API_Name__c, auxSet);
                objectFieldsQueryFormatMap.put(lineItens.Related_Object_API_Name__c, ' ');
            }
            
            if(auxSet.add(lineItens.Field_API_Name__c)){  //se o field é novo
                String fieldsStr = objectFieldsQueryFormatMap.get(lineItens.Related_Object_API_Name__c);
                fieldsStr +=  ', ' + lineItens.Field_API_Name__c ;
                objectFieldsQueryFormatMap.put(lineItens.Related_Object_API_Name__c, fieldsStr);
                system.debug('fieldsStr' + fieldsStr);
            }
            
            //TODO usar este código se quisermos ir buscar o valor à ta
            //objectFieldsQueryFilterMap.put(lineItens.Related_Object_API_Name__c, lineItens.Query_Filter__c);
            
        }
        
        objectFieldsQueryFilterMap.put('Account', 'Id = :accountId');
        objectFieldsQueryFilterMap.put('ReportDB__c', 'Vendor__c = :accountId ORDER BY CreatedDate DESC LIMIT 1');
        
        //Query object by object
        // Sim eu sei que é uma query dentro de um ciclo for, mas não se consegue fazer queries a mais que um object e está previsto só 2 ou 3 objectos.
        //     key= object values = resultado da query
        Map<String, List<sObject>> objectQueryMap = new Map<String, List<sObject>>();
        for(String objectAPI : objectFieldsQueryFormatMap.keySet()){
            
            String query = 'SELECT Id '+ objectFieldsQueryFormatMap.get(objectAPI) +' FROM ' + objectAPI + ' WHERE ' + objectFieldsQueryFilterMap.get(objectAPI);
            system.debug('query' + query);
            List<sObject> sobjList = Database.query(query);
            system.debug('sobjList' + sobjList);
            objectQueryMap.put(objectAPI, sobjList);
            
        }

        Guidance_Limit_Line_Item__c guidLLItemChoose = selectGuidanceLimit(dec2, guidLLItemLitList, objectQueryMap);
        system.debug('dec2' + dec2);
        system.debug('guidLLItemLitList' + guidLLItemLitList);
        system.debug('objectQueryMap' + objectQueryMap);

        dec2.Guidance_Limit_Line_Item__c = guidLLItemChoose.Id;
        if(dec2.Trigger_override__c == true && dec2.Guidance_Limit_Max_Override__c != null){
        	dec2.Guidance_Limit_Max__c = dec2.Guidance_Limit_Max_Override__c;
        }else{
        	dec2.Guidance_Limit_Max__c = getGuidanceLimitMax(guidLLItemChoose, dec2);
        }

        createDecisionCreditLimit(dec2);

        update dec2;
        createGuidanceLimitHistory( dec2, guidLLItemChoose);
        
        return;
    }
    
    private static decimal getGuidanceLimitMax(Guidance_Limit_Line_Item__c guidLLItemChoose, Decision__c dec2){
    	
    	ReportDB__c creditInfo = [SELECT ID, Sales__c, TotEmpregados__c FROM ReportDB__c WHERE Id = :dec2.Credit_Info__c];
    	system.debug('creditInfo:' + creditInfo);
    	decimal guidanceLimit = 0;
    	if(guidLLItemChoose.Field_API_Name__c != null && guidLLItemChoose.Field_API_Name__c.equals('Sales__c')){  // Company Sales
    		
    		guidanceLimit = (guidLLItemChoose.Value__c/100) * creditInfo.Sales__c;
    		
    		if(guidanceLimit > guidLLItemChoose.Guidance_Limit_Max__c ){
    			guidanceLimit = guidLLItemChoose.Guidance_Limit_Max__c;
    		}else if(guidanceLimit < guidLLItemChoose.Guidance_Limit_Min__c ){
    			guidanceLimit = guidLLItemChoose.Guidance_Limit_Min__c;
    		}
    		
    	}else if(guidLLItemChoose.Field_API_Name__c != null && guidLLItemChoose.Field_API_Name__c.equals('TotEmpregados__c')){   //Employees
    		
    	    guidanceLimit = guidLLItemChoose.Value_Amount__c * creditInfo.TotEmpregados__c;
    	    
    	    if(guidanceLimit > guidLLItemChoose.Guidance_Limit_Max__c ){
    			guidanceLimit = guidLLItemChoose.Guidance_Limit_Max__c;
    		}else if(guidanceLimit < guidLLItemChoose.Guidance_Limit_Min__c ){
    			guidanceLimit = guidLLItemChoose.Guidance_Limit_Min__c;
    		}
    	}else if(guidLLItemChoose.Value_Amount__c != null){
    		
    		guidanceLimit = guidLLItemChoose.Value_Amount__c;
    		
    	}
    	
    	guidanceLimit = guidanceLimit.setScale(2);
    	return guidanceLimit;
    }

    //////////////////////////////
    private static Guidance_Limit_Line_Item__c selectGuidanceLimit(Decision__c dec2, List<Guidance_Limit_Line_Item__c> guidLLItemLitList, Map<String, List<sObject>> objectQueryMap){
        dec2.Guidance_Limit_Line_Item__c = null;
        Guidance_Limit_Line_Item__c guidLLItemChoose = null;
        for(Guidance_Limit_Line_Item__c guidLLItem : guidLLItemLitList){
        	system.debug('guidLLItem: ' + guidLLItem);
        		
        	if(guidLLItem.Matching_Type__c == 'Static Value'){
        		guidLLItemChoose = guidLLItem;
        		break;
        	}
/*
        	List<sObject> sobjList = objectQueryMap.get(guidLLItem.Related_Object_API_Name__c);
            system.debug('lineItem.Related_Object_API_Name__c: ' + guidLLItem.Related_Object_API_Name__c);
            system.debug('sobjList' + sobjList);
        		
        		
        	if(guidLLItem.Matching_Type__c == '<='){
        		Integer value = Integer.valueof( sobjList[0].get(guidLLItem.Field_API_Name__c));
        		if(value <= guidLLItem.Max_Value__c ){
        			guidLLItemChoose = guidLLItem;
        			break;
        		}
        		continue;
        	}

        	if(guidLLItem.Matching_Type__c == '<'){
        		Integer value = Integer.valueof( sobjList[0].get(guidLLItem.Field_API_Name__c));
        		if(value < guidLLItem.Max_Value__c ){
        			guidLLItemChoose = guidLLItem;
        			break;
        		}
        		continue;
        	}
        		
        	if(guidLLItem.Matching_Type__c == 'Between'){
        		Integer value = Integer.valueof( sobjList[0].get(guidLLItem.Field_API_Name__c));
        		if(value >= guidLLItem.Min_Value__c && value <= guidLLItem.Max_Value__c ){
        			guidLLItemChoose = guidLLItem;
        			break;
        		}
        		continue;
        	}

        	if(guidLLItem.Matching_Type__c == '>'){
        		continue;
        	}
        		
        	if(guidLLItem.Matching_Type__c == '>='){
        		Integer value = Integer.valueof( sobjList[0].get(guidLLItem.Field_API_Name__c));
        		if(value >= guidLLItem.Min_Value__c ){
        			guidLLItemChoose = guidLLItem;
        			break;
        		}
        	    continue;
        	}
        		
        	if(guidLLItem.Matching_Type__c == 'Field Value'){
    			guidLLItemChoose = guidLLItem;
    			break;
        	}
*/      		

        }
        return guidLLItemChoose;
    }


        ///////////////

    private static void createGuidanceLimitHistory(Decision__c decision, Guidance_Limit_Line_Item__c guidanceLimitLI){
    	Decision_Guidance_Limit_History__c decGuidanceLimitH = new Decision_Guidance_Limit_History__c( Decision__c = decision.Id ,
                                                                       Guidance_Limit_Max__c = guidanceLimitLI.Guidance_Limit_Max__c,
                                                                       Guidance_Limit_Min__c = guidanceLimitLI.Guidance_Limit_Min__c,
                                                                       Value_Amount__c = guidanceLimitLI.Value_Amount__c,
                                                                       Value__c = guidanceLimitLI.Value__c );
        insert decGuidanceLimitH;
    }

    //TODO pode ser apagado depois de fazer os updates às decisions já criadas
    public static void createDecisionCreditLimit(Id decisionId){
	    Decision__c decision = [Select Id, 
                                                    Grade__c, 
                                                    Account__c,
                                                    Credit_Info__c, 
                                                    Guidance_Limit_Scorcard__c, 
                                                    Guidance_Limit_Line_Item__c,
                                                    Trigger_override__c,
                                                    Personal_Guarantee_Override__c,
                                                    Guidance_Limit_Max_Override__c,
                                                    Account__r.BillingCountryCode
                                                         FROM Decision__c WHERE Id = :decisionId];

        createDecisionCreditLimit(decision);
    }
    
    private static void createDecisionCreditLimit(Decision__c decision){

    	List<Guidance_Limit_Risk_Modifier__c> guidanceModifierList = [SELECT Id, Status__c, Country__c,
    	                                   (SELECT Id, Min_Value__c, Max_Value__c, Score_Modifier__c, Grade__c, Grade_Modifier__c FROM Guidance_Limit_Risk_Modifier_Line_Items__r WHERE Grade__c = :decision.Grade__c)
    	                                    
    	                                              FROM Guidance_Limit_Risk_Modifier__c WHERE Status__c = 'Active' AND Country__c = :decision.Account__r.BillingCountryCode];


        system.debug('guidanceModifierList' + guidanceModifierList);
    	List<Decision_Credit_Limit__c> decCredLimList = new  List <Decision_Credit_Limit__c>();
    	List<Guidance_Limit_Risk_Modifier_Line_Item__c> asdlist = guidanceModifierList[0].Guidance_Limit_Risk_Modifier_Line_Items__r;
    	system.debug('asdlist' + asdlist);
    	system.debug('decision' + decision);

    	for(Guidance_Limit_Risk_Modifier_Line_Item__c gLRML : asdlist){
    		Decimal minAmount = decision.Guidance_Limit_Max__c * gLRML.Min_Value__c/100;
    		Decimal maxAmount = decision.Guidance_Limit_Max__c * gLRML.Max_Value__c/100;
    		
    		Decision_Credit_Limit__c decCredLim = new Decision_Credit_Limit__c(Decision__c = decision.Id,
    		                                                                   Grade__c = gLRML.Grade__c,
    		                                                                   Min_Amount__c = minAmount,
    		                                                                   Max_Amount__c = maxAmount,
    		                                                                   Modified_Grade__c = gLRML.Grade_Modifier__c);
    		decCredLimList.add(decCredLim);
    	}

    	insert decCredLimList;     
    }

}