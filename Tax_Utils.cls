public class Tax_Utils {

    //can be used inside triggers
    public static String convertPostalCodeToTaxZone(String postalCode, String country){
    	
        system.debug(postalCode);
        system.debug(country);
        
        
        //get significant numbers for postal code
        Tax_Postal_Code__mdt postalCodeLimits = [SELECT MasterLabel, CP_MIN__c, CP_MAX__c, Country__c FROM Tax_Postal_Code__mdt WHERE MasterLabel = :country];

        if(postalCodeLimits==null) return 'Country not defined in custom settings.';
        system.debug(postalcodeLimits);
        
        Integer min = Integer.valueOf(postalCodeLimits.CP_MIN__c);
        Integer max = Integer.valueOf(postalCodeLimits.CP_MAX__c);
        system.debug('Min:'+min+' Max:'+max);            
        
        //convert postal code into number
        String significantPostalCode = postalCode.substring(min, max);
    	Integer postalCodeNumber = Integer.valueOf(significantPostalCode);
    	
        
        //obtain tax zone
 		List<Tax_Postal_Code__mdt> taxZone = [SELECT MasterLabel, CP_MAX__c, Country__c FROM Tax_Postal_Code__mdt WHERE CP_MIN__c <= :postalCodeNumber AND Country__c = :country AND CP_MAX__c >= :postalCodeNumber];
        system.debug(taxZone);
		if(!taxZone.isEmpty())
    		return taxZone[0].MasterLabel; 
    	else
    		return 'Tax Zone not identified to this address.';
    	
    } 
    

}