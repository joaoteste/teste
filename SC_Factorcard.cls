public class SC_Factorcard {
 
    public static Decimal getFactor(Id accountId, String country, Decimal contractValue, String term, String factorType){
        //1 query decision
    	Decision__c decision = [SELECT Id, Grade__c, Sub_Grade__c FROM Decision__c WHERE (Account__c = :accountId AND Active__c = True) ORDER BY CreatedDate NULLS LAST LIMIT 1];
    	system.debug('TEST decision '+decision);

		return getFactor(accountId, decision, country, contractValue, term, factorType);    
    	
    }    
    
    public static Decimal getFactor(Id accountId, Decision__c decision, String country, Decimal contractValue, String term, String factorType){
        system.debug('GGG on factorcard account '+accountId+'; grade '+decision.Grade__c+'; subgrade '+decision.Sub_Grade__c+'; contractValue '+contractValue+'; term '+term+'; type '+factorType);
        
        //query factor card
    	List<Factorcard__c> factorcard_List = [SELECT Id, Name,
                                               		(SELECT Id, Grade__c, Term__c, Factor__c, Max_Value__c, Min_Value__c
                                                	 FROM Factorcard_Line_Items__r 
                                                	 WHERE (Sub_Grade__c = :decision.Sub_Grade__c AND Grade__c = :decision.Grade__c AND Term__c = :term AND Max_Value__c >= :contractValue AND Min_Value__c <= :contractValue)
                                                    LIMIT 1) 
                                               FROM Factorcard__c 
                                               WHERE Type__c = :factorType AND Country__c = :country AND Status__c = 'Active'];
        
        if(factorcard_List.size() == 0){
        	system.debug('ERRO::Lista de Factorcards vazia');
            return null;
        }
                                                     
        Factorcard__c factorcard = factorcard_List[0];
        system.debug('TEST fc '+factorcard);
        if(factorcard.Factorcard_Line_Items__r == null){
        	system.debug('ERRO::Relacao Factorcard-FactorcardLineItem mal definida');
        	return null;
        }
        
        if(factorcard.Factorcard_Line_Items__r.size() != 1){
            system.debug('ERRO::No FactorcardLineItem found');
        	return null;
        }
        
        Decimal factor = factorcard.Factorcard_Line_Items__r[0].Factor__c;
    	return factor;
    }
}