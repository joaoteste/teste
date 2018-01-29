/*
1 - process builder
2 - trigger do credit info
3 - codigo do SC_scoreCard
TODO
???
guide process builder
SC_Guidance
etc

*/
// TODO - alterar o código para que possa ser chamado por um trigger sem ter problemas (i.e. rever SELECT's e insert's)
public class SC_ScoreCard {
	static Integer SUB_GRADE_LEVEL = 3;
	    
	     // key = account Id
    private Map<Id, ReportDB__c> creditInfoPerAccountMap = new Map<Id, ReportDB__c>();
         //key scoreCard Id
    private Map<Id, Scorecard__c> scoreCardMap = new Map<Id, Scorecard__c>();
    
    public List<Id> createDecisionsFromCreditInfo(List<Id> accountIdList) {
    	
    	List<Id> decisionIdList = new List<Id>();
    	// Get Credit Info

    	List<Account> accountList = [SELECT ID, BillingCountryCode, (SELECT Id, Scorecard_Selection__c, Scorecard_Selection__r.Scorecardv2__c, Scorecard__c, Vendor__r.BillingCountryCode From Reports_DB__r ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN :accountIdList];
    	Set<Id> scoreCardIdSet = new Set<Id>();
    	for(Account account : accountList){
    		if(account.Reports_DB__r.size() > 0){
    			ReportDB__c creditInfo = account.Reports_DB__r.get(0);
    		    creditInfoPerAccountMap.put(account.Id, creditInfo);
    		    scoreCardIdSet.add(creditInfo.Scorecard_Selection__r.Scorecardv2__c);
    		    
    		    system.debug('Country:' + creditInfo.Vendor__r.BillingCountryCode);
    		}
    	}
    	
    	//Get Score Card
    	scoreCardMap = new Map<Id, Scorecard__c>([SELECT Id, Name, (SELECT Id
                                                                      , Field_Name__c
                                                                      , Field_API_Name__c
                                                                      , Related_Object_API_Name__c
                                                                      , Matching_Type__c
                                                                      , Matching_Value__c
                                                                      , Min_Value__c
                                                                      , Max_Value__c
                                                                      , Query_Filter__c
                                                                      , Value__c
                                                                      , Related_Object__c FROM Scorecard_Line_Items__r),
                                                                      
                                                                   (SELECT Id
                                                                      , Related_Object__c
                                                                      , Related_Object_API_Name__c
                                                                      , Field_API_Name__c
                                                                      , Field_Name__c
                                                                      , Scorecard__c
                                                                      , Weight__c FROM Score_Card_Fields_Weight__r)
                                                            
                                                             FROM Scorecard__c WHERE Id IN :scoreCardIdSet ]);
                                                            
         system.debug('scoreCardMap:' + scoreCardMap);
         system.debug('scoreCardIdSet:' + scoreCardIdSet);
         
        // process each account
    	for(Account account : accountList){
    		Savepoint sp = null;
    		try{
    			sp = Database.setSavepoint();
    		    Id newDecisionId = createDecision(account);
    		    if(newDecisionId != null){
    		        decisionIdList.add(newDecisionId);
    		    }
  
    		} catch (Exception ex) {
	            if (sp != null) {
	                Database.rollback(sp);
	            }
	            //outbound and debug
                system.debug(LoggingLevel.INFO, 'Exception SC_ScoreCard ');
                system.debug(LoggingLevel.INFO, 'ex.getCause(): ' + ex.getCause());
                system.debug(LoggingLevel.INFO, 'ex.getLineNumber(): ' + ex.getLineNumber());
                system.debug(LoggingLevel.INFO, 'ex.getMessage(): ' + ex.getMessage());
                system.debug(LoggingLevel.INFO, 'ex.getTypeName(): ' + ex.getTypeName());
                system.debug(LoggingLevel.INFO, 'ex.getStackTraceString(): ' + ex.getStackTraceString());
                
                Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SCORE_CARD',
            																	message__c = 'Account Id:' + account.Id + 'Problem occurred in line: '+ ex.getLineNumber() + ' \n Due to ' + ex.getCause() + ' \n giving error Message: ' + ex.getMessage(),
            																	printStackTrace__c = ex.getStackTraceString());
                insert record;
	        }
    		
    	}
    	
    	return decisionIdList;
    }

    private Id createDecision(Account account) {
    	
    	setInactiveAllOtherDecisions(account.Id);
    	// get last Credit Info
    	ReportDB__c creditInfo = creditInfoPerAccountMap.get(account.Id); 
        
        // Validations:
        if(creditInfo == null){
        	Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SCORE_CARD',
            																	message__c = 'The acount' + account.Id + 'does not have Credit Info',
            																	printStackTrace__c = ' ');
            insert record;
            system.debug('The acount' + account.Id + 'does not have Credit Info');
        	return null;
        }
        
        if(creditInfo.Scorecard_Selection__r.Scorecardv2__c == null){
        	//Error
        	Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SCORE_CARD',
            																	message__c = 'Credit Info ' + creditInfo + 'does not have an associated Score Card',
            																	printStackTrace__c = ' ');
            insert record;
            system.debug('Credit Info ' + creditInfo + 'does not have an associated Score Card');
        	return null;
        }

        Decision__c newDec = new Decision__c();
        newDec.Credit_Info__c = creditInfo.Id;
        newDec.Account__c = account.Id;
        newDec.Active__c = true;
        newDec.Scorecard__c = creditInfo.Scorecard_Selection__r.Scorecardv2__c;
        //TODO inserir numa lista em vez de um a um
        insert newDec;

        Decimal score = calculateScore(newDec, account.Id);
        if( score == null){
        	Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SCORE_CARD',
            																	message__c = 'The acount does not have Credit Info',
            																	printStackTrace__c = ' ');
            insert record;
            system.debug('Error');
        	return null;
        }
        
        newDec.Score__c = score;
        
        String errorMessage = calculateGradeCard(score, newDec, creditInfo.Vendor__r.BillingCountryCode);
        if(errorMessage != null){
            return errorMessage;
        }
        
//        selectConditionCardLineItem(newDec, creditInfo.Vendor__r.BillingCountryCode);

        system.debug('New Decision: ' + newDec);
        update newDec;
        system.debug('New Decision: ' + newDec);
        
        return newDec.Id;
    }

    ///////////////////////////////////
    ///      Private methods         //
    ///////////////////////////////////

    private Decimal calculateScore(Decision__c newDec, Id accountId){

     //Query values    
    	Id scoreCardId = newDec.Scorecard__c;
    
        Scorecard__c scorecard = scoreCardMap.get(scoreCardId);
        system.debug('scorecard' + scorecard); 
        
        if(scorecard == null){
        	Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SCORE_CARD',
            																	message__c = 'The acount does not have Credit Info',
            																	printStackTrace__c = ' ');
            insert record;
        	return null;
        }
      
        List<Score_Card_Field_Weight__c> fieldWeightList = scorecard.Score_Card_Fields_Weight__r;

        //Key = Field_API_Name__c + Related_Object_API_Name__c
        Map<String, Score_Card_Field_Weight__c> fieldWeightMap = new Map<String, Score_Card_Field_Weight__c>();
        for(Score_Card_Field_Weight__c fieldWeight : fieldWeightList){
            fieldWeightMap.put(fieldWeight.Field_API_Name__c + fieldWeight.Related_Object_API_Name__c , fieldWeight);
        }

// Query values that are use in calculation        
 //     key= object values = set de fields  //just used to confirm if the field is duplicated
        Map<String,Set<String>> objectFieldsMap = new Map<String,Set<String>>();
//     key= object values = String of fields to query
        Map<String, String> objectFieldsQueryFormatMap = new Map<String,String>();
//     key= object values = query Filter
        Map<String, String> objectFieldsQueryFilterMap = new Map<String,String>();

        for(Scorecard_Line_Item__c lineItens : scorecard.Scorecard_Line_Items__r){
        	if( lineItens.Related_Object_API_Name__c == null){
        		if(lineItens.Matching_Type__c != 'Static Value'){
        			//TODO  fazer uma test class para verificar isto
        			Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SCORE_CARD',
            																	message__c = 'The acount does not have Credit Info',
            																	printStackTrace__c = ' ');
                    insert record;
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
            
            
            objectFieldsQueryFilterMap.put(lineItens.Related_Object_API_Name__c, lineItens.Query_Filter__c);
            
        }
        
        //Query object by object
        // Sim eu sei que é uma query dentro de um ciclo for, mas não se consegue fazer queries a mais que um object e está previsto só 2 ou 3 objectos.
        //     key= object values = resultado da query
        // outra opção é ir buscar sempre todos fields dos objectos, assim posso poupar nas queries e exectuar as queries no construtor.
        Map<String, List<sObject>> objectQueryMap = new Map<String, List<sObject>>();
        for(String objectAPI : objectFieldsQueryFormatMap.keySet()){
            
            String query = 'SELECT Id '+ objectFieldsQueryFormatMap.get(objectAPI) +' FROM ' + objectAPI + ' WHERE ' + objectFieldsQueryFilterMap.get(objectAPI);
            system.debug('query:' + query );
            List<sObject> sobjList = Database.query(query);
            objectQueryMap.put(objectAPI, sobjList);
            
        }

/////////// Start calculation 

        List<Decision_ScoreCard_History__c> decisionHistoryList = new List<Decision_ScoreCard_History__c>();
        Decimal score = makeScoreCalculation(newDec, scorecard, fieldWeightMap, objectQueryMap, decisionHistoryList);
        insert decisionHistoryList;
        
        return score;
    }
    
    private Decimal makeScoreCalculation(Decision__c newDec, Scorecard__c scorecard, Map<String, Score_Card_Field_Weight__c> fieldWeightMap, Map<String, List<sObject>> objectQueryMap, List<Decision_ScoreCard_History__c> decisionHistoryList){
    	
        Decimal score = 0;
        for(Scorecard_Line_Item__c lineItem : scorecard.Scorecard_Line_Items__r){
            system.debug('lineItem: ' + lineItem);

            if(lineItem.Matching_Type__c == 'Static Value'){
                score += scoreStatic( newDec, lineItem, fieldWeightMap, decisionHistoryList);
                continue;
            }

            List<sObject> sobjList = objectQueryMap.get(lineItem.Related_Object_API_Name__c);
            system.debug('lineItem.Related_Object_API_Name__c: ' + lineItem.Related_Object_API_Name__c);
            system.debug('sobjList' + sobjList);
            
            if(lineItem.Matching_Type__c == 'Field Value'){
            	Integer fieldValue = Integer.valueof( sobjList[0].get(lineItem.Field_API_Name__c) );
            	system.debug('RRRRRRRR' + fieldValue);
                score += scoreFieldValue( newDec, fieldValue, lineItem, fieldWeightMap, decisionHistoryList);
                continue;
            }
            
            if(lineItem.Matching_Type__c == '<='){
            	Decimal fieldValue = Integer.valueof( sobjList[0].get(lineItem.Field_API_Name__c));
                if(fieldValue <= lineItem.Matching_Value__c){
                    score += scoreField( newDec, lineItem, fieldValue, fieldWeightMap,  decisionHistoryList);
                }
                continue;
            }
            
            if(lineItem.Matching_Type__c == '<'){
            	Decimal fieldValue = Integer.valueof( sobjList[0].get(lineItem.Field_API_Name__c));
                if(fieldValue < lineItem.Matching_Value__c){
                    score += scoreField( newDec, lineItem, fieldValue, fieldWeightMap,  decisionHistoryList);
                }
                continue;
            }
            
            if(lineItem.Matching_Type__c == 'Between'){
                Decimal fieldValue = Integer.valueof( sobjList[0].get(lineItem.Field_API_Name__c));
                if(fieldValue > lineItem.Min_Value__c && fieldValue < lineItem.Max_Value__c){
                    score += scoreField( newDec, lineItem, fieldValue, fieldWeightMap,  decisionHistoryList);
                }
                continue;
            }
            
            if(lineItem.Matching_Type__c == '>'){
            	Decimal fieldValue = Integer.valueof( sobjList[0].get(lineItem.Field_API_Name__c));
                if(fieldValue > lineItem.Matching_Value__c){
                    score += scoreField( newDec, lineItem, fieldValue, fieldWeightMap,  decisionHistoryList);
                }
                continue;
            }
            
            if(lineItem.Matching_Type__c == '>='){
            	Decimal fieldValue = Integer.valueof( sobjList[0].get(lineItem.Field_API_Name__c));
                if(fieldValue >= lineItem.Matching_Value__c){
                    score += scoreField( newDec, lineItem, fieldValue, fieldWeightMap,  decisionHistoryList);
                }
                continue;
            }


        }
        
        return Math.round(score);
    }
    
    private static Decimal scoreField(Decision__c newDec, Scorecard_Line_Item__c lineItem, Decimal fieldValue, Map<String, Score_Card_Field_Weight__c> fieldWeightMap, List<Decision_ScoreCard_History__c> decisionHistoryList){
        //TODO Código repetido + definir o que vai ser posto no construtor
        Decimal fieldScore = 0;
        
        Decimal weight = 0;
        String mapKey = lineItem.Field_API_Name__c + lineItem.Related_Object_API_Name__c;
        
        if(null == fieldWeightMap.get(mapKey)){
            //Error
            // score = -1 * score;
        }else{
            weight = fieldWeightMap.get(mapKey).Weight__c;
        }
        fieldScore = lineItem.Value__c * weight;
        
        fieldScore = Math.round(fieldScore);
        
        decisionHistoryList.add( createHistory( newDec, lineItem, fieldValue ,weight, fieldScore));
        
        return fieldScore;
    }

    private static Decimal scoreStatic(Decision__c newDec, Scorecard_Line_Item__c lineItem, Map<String, Score_Card_Field_Weight__c> fieldWeightMap, List<Decision_ScoreCard_History__c> decisionHistoryList){

        Decimal fieldScore = lineItem.Value__c;
        
        decisionHistoryList.add( createHistory( newDec, lineItem, 0, 1, fieldScore));
        
        return fieldScore;
    }

    private static Decimal scoreFieldValue(Decision__c newDec, Integer fieldValue, Scorecard_Line_Item__c lineItem, Map<String, Score_Card_Field_Weight__c> fieldWeightMap, List<Decision_ScoreCard_History__c> decisionHistoryList){
        Decimal fieldScore = 0;
        
        Decimal weight = 0;
        String mapKey = lineItem.Field_API_Name__c + lineItem.Related_Object_API_Name__c;
        
        if(null == fieldWeightMap.get(mapKey)){
            //Error
            // score = -1 * score;
        }else{
            weight = fieldWeightMap.get(mapKey).Weight__c;
        }
        
        fieldScore = fieldValue * weight;
        fieldScore = Math.round(fieldScore);

        decisionHistoryList.add( createHistory( newDec, lineItem, fieldValue, weight, fieldScore));
        
        return fieldScore;
    }

    private static Decision_ScoreCard_History__c createHistory(Decision__c newDec, Scorecard_Line_Item__c lineItem, Decimal originalValue, Decimal weight, Decimal lineItemScore){
        Decision_ScoreCard_History__c decScCarHist = new Decision_ScoreCard_History__c(Decision__c = newDec.Id,
                                                                                       Field_API_Name__c = lineItem.Field_API_Name__c,
                                                                                       Field_Name__c = lineItem.Field_Name__c, 
                                                                                       Matching_Type__c = lineItem.Matching_Type__c,
                                                                                       Matching_Value__c = lineItem.Value__c,
                                                                                       Value__c = lineItemScore,
                                                                                       Weight__c = weight,
                                                                                       OriginalValue__c = originalValue);
        
        return decScCarHist;
    }
    
    
     private static String calculateGradeCard(Decimal score, Decision__c newDec, String country){
        
        //try catch, controlo caso o valor seja null
        //TODO este SELECT devia ser feito só uma vez dentro da class
        Grade_Card__c gradecard = [SELECT Id, Name, (SELECT Id
                                                            , Grade__c
                                                            , Min_Value__c
                                                            , Max_Value__c
                                                            , Decison_Status__c
                                                        //    , Sub_Grade__c
                                                             FROM Grade_Card_Line_Item__r WHERE Min_Value__c <= :score AND Max_Value__c >= :score) FROM Grade_Card__c WHERE Status__c = 'Active' And Country__c = :country ];
        
        
        system.debug('score:' + score);
        system.debug('gradecard:' + gradecard);
        
        if(gradecard.Grade_Card_Line_Item__r == null || gradecard.Grade_Card_Line_Item__r.size() != 1){
            system.debug('score' + score +'newDec:' + newDec + 'gradecard:' + gradecard + 'Error!!!!!');
            return 'score' + score +'newDec:' + newDec + 'gradecard:' + gradecard + 'Error!!!!!';
        }
        
        newDec.Grade__c = gradecard.Grade_Card_Line_Item__r[0].Grade__c;
        newDec.Decison_Status__c = gradecard.Grade_Card_Line_Item__r[0].Decison_Status__c;
        if(score != null && score > 0 && newDec.Grade__c != 'KO' && newDec.Grade__c != 'N/A'){
            newDec.Sub_Grade__c = calculateSubGrad(score, gradecard.Grade_Card_Line_Item__r[0]).toPlainString();
        }
        
        return null ;
    }
    
    public static Decimal calculateSubGrad(Decimal score, Grade_Card_Line_Item__c gradeCardLineItem){

    	Decimal subGrade = 0;

    	Decimal step = (gradeCardLineItem.Max_Value__c - gradeCardLineItem.Min_Value__c) / SUB_GRADE_LEVEL;
    	system.debug('calculateSubGrad gradeCardLineItem' + gradeCardLineItem);
//    	system.debug('gradeCardLineItem.Min_Value__c' + gradeCardLineItem.Min_Value__c);
//    	system.debug('gradeCardLineItem.Max_Value__c' + gradeCardLineItem.Max_Value__c);
//    	system.debug('score' + score);
//    	system.debug('step' + step);
    	Decimal aux = score - gradeCardLineItem.Min_Value__c;
    	if(aux <= 0){
    		return 1;
    	}
//    	system.debug('aux' + aux);
    	subGrade = aux/step;
    	subGrade = subGrade.intValue();
    	subGrade = SUB_GRADE_LEVEL - subGrade;
    	system.debug('subGrade' + subGrade);
//    	system.debug('subGrade.intValue()' + subGrade.intValue());
    	
    	if(subGrade.intValue() == 0){
    		return 1;
    	}

    	return subGrade.intValue(); 
    }

    //TODO check if is needed to be public
    public static String selectConditionCardLineItem(Decision__c newDec, String country){
    	
    	 //try catch, controlo caso o valor seja null
    	 //TODO este SELECT devia ser feito só uma vez dentro da class
    	 Conditions_Card__c conditionCard = [SELECT Id, Name, (SELECT Id
    	                                                    , Administrative_Costs__c
    	                                                    , Advance_Payment__c
    	                                                    , Billing_Frequency__c
                                                            , Grade__c
                                                            , Personal_Guarantee__c
                                                            , Term_12__c
                                                            , Term_24__c
                                                            , Term_36__c
                                                            , Term_48__c
                                                            , Term_60__c
                                                            , Term_72__c
                                                             FROM Condition_Card_Line_Items__r WHERE Grade__c = :newDec.Grade__c) FROM Conditions_Card__c WHERE Status__c = 'Active' And Country__c = :country ];
        system.debug('conditionCard:' + conditionCard);
        
         if(conditionCard.Condition_Card_Line_Items__r == null || conditionCard.Condition_Card_Line_Items__r.size() != 1){
            // TODO send EMAIL
            system.debug(' ' + conditionCard + 'Error!!!!!!!');
            return ' ' + conditionCard + 'Error!!!!!!!';
        }

        Condition_Card_Line_Item__c condCardLI = conditionCard.Condition_Card_Line_Items__r[0];
        
        Decision_Conditions_Card_History__c condCard_History = new Decision_Conditions_Card_History__c(
                                                                             Administrative_Costs__c = condCardLI.Administrative_Costs__c,
                                                                             Advance_Payment__c = condCardLI.Advance_Payment__c,
                                                                             Billing_Frequency__c = condCardLI.Billing_Frequency__c,
                                                                             Decision__c = newDec.Id,
                                                                             Grade__c = condCardLI.Grade__c,
                                                                             Personal_Guarantee__c = condCardLI.Personal_Guarantee__c,
                                                                             Term_12__c = condCardLI.Term_12__c,
                                                                             Term_24__c = condCardLI.Term_24__c,
                                                                             Term_36__c = condCardLI.Term_36__c,
                                                                             Term_48__c = condCardLI.Term_48__c,
                                                                             Term_60__c = condCardLI.Term_60__c,
                                                                             Term_72__c = condCardLI.Term_72__c,
                                                                             Source_Condition_Card_Line_Item__c = condCardLI.Id);

        
        if(newDec.Trigger_override__c == true && newDec.Personal_Guarantee_Override__c != null){
        	if(newDec.Personal_Guarantee_Override__c == 'Yes'){
        	    condCard_History.Personal_Guarantee__c = true;
        	}else if(newDec.Personal_Guarantee_Override__c == 'No'){
        	    condCard_History.Personal_Guarantee__c = false;
        	}
        }
        
        insert condCard_History;
        
        return '  ';
    }
    
    
    private static void setInactiveAllOtherDecisions(Id accountId) {
    	
    	List<Decision__c> decisionList = [SELECT Id, Active__c, Account__c FROM Decision__c WHERE Account__c = :accountId AND Active__c = true];
        
        for(Decision__c decision : decisionList){
        	decision.Active__c = false;
        }
    	
    	if(decisionList.size() > 0){
    	    update decisionList;
    	}
    }

}