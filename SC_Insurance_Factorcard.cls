public class SC_Insurance_Factorcard {

    public static Decimal getFactor(Id accountId, String country, Decimal contractValueDecimal, String insuranceType){
        Integer contractValue = contractValueDecimal.intValue();
        //1 query decision
        Decision__c newDec = [SELECT Id, Grade__c FROM Decision__c WHERE Account__c = :accountId AND Active__c = true ORDER BY CreatedDate NULLS LAST LIMIT 1];
        
        //2 query factor card
        List<Insurance_Factorcard__c> factorcard_List = [SELECT Id, Name,
                                                    (SELECT Id, Grade__c, Factor__c, Max_Value__c, Min_Value__c
                                                     FROM Insurance_Card_Line_Items__r 
                                                     WHERE (Grade__c = :newDec.Grade__c AND Max_Value__c >= :contractValue AND Min_Value__c <= :contractValue AND Insurance_Type__c = :insuranceType)
                                                    LIMIT 1) 
                                               FROM Insurance_Factorcard__c
                                               WHERE Country__c = :country AND Status__c = 'Active'];
        
        if(factorcard_List.size() == 0){
            system.debug('ERRO::Lista de Factorcards vazia');
            return null;
        }
                                                     
        Insurance_Factorcard__c factorcard = factorcard_List[0];
        if(factorcard.Insurance_Card_Line_Items__r == null){
            system.debug('ERRO::Insurance_Factorcard-Insurance_Factorcard_Line_Item relation not correctly set');
            return null;
        }
        
        //"LIMIT 1" guarantees only 1 Factorcard_Line_Item if it exists
        if(factorcard.Insurance_Card_Line_Items__r.size() != 1){
            system.debug('ERRO::No FactorcardLineItem found');
            return null;
        }
        
        Decimal factor = factorcard.Insurance_Card_Line_Items__r[0].Factor__c;
        System.debug('FACTOR TEST '+factor);
        return factor;
    }


    public static Decimal getInsuranceValue(Id accountId, String country, Decimal contractValueDecimal, String insuranceType){
    	Integer contractValue = contractValueDecimal.intValue();
    	
    	Decimal insuranceFactor = getFactor(accountId, country, contractValue, insuranceType);
    	
    	if(insuranceFactor == null){
    		return null;
    	}
    	Decimal insuranceValue = ((contractValue * insuranceFactor/100)/12).setscale(1);
    	
    	Decimal minimalInsuranceValue =  [SELECT Minimum_Insurance_Value__c FROM Credit_Decisions_Settings__mdt WHERE DeveloperName =:country LIMIT 1].Minimum_Insurance_Value__c;
    	
    	if(insuranceValue < minimalInsuranceValue){
    		insuranceValue = minimalInsuranceValue;
    	}
    	
    	return insuranceValue;
    }

}