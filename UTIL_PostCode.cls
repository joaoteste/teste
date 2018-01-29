public class UTIL_PostCode {
    
    public static Boolean validationPostCode(String postalCode){

         Integer first4Digit = 0;
         Integer last3Digit = 0;
         // validation XXXX-YYY
         if(postalCode.length() != 8){
             system.debug('ERROR: The PostalCode must have the format 0000-000');
             return false;
         }else{
            try{
             first4Digit = Integer.valueOf(postalCode.left(4));
             if( '-' != postalCode.mid(4, 1) ){
                 system.debug('ERROR: The PostalCode must have a - After the first 4 digit');
                 return false;
             }
             last3Digit = Integer.valueOf(postalCode.right(3));
             
            }catch(exception e){
                system.debug('ERROR: The PostalCode must have the format 0000-000: ' + postalCode);
                System.debug('exception: '+ e.getStackTraceString());
                return false;
            }
         }
         
         system.debug('first4Digit' + first4Digit);
         system.debug('last3Digit' + last3Digit);
         
         return true;
    }

    //Don't use in a trigger 
    public static String getRegionFromPostCode(String postalCode){
         
         if(validationPostCode(postalCode) == false){
            return null;
         }
         
         Integer first4DigitPostalCode = Integer.valueOf( postalCode.left(4) );
         
         list <Postal_Code__c> postcod=[select CP_Min__c, CP_Max__c, Region__c 
                                          from Postal_Code__c 
                                         where Region__c != null AND CP_MIN__C  <= :first4DigitPostalCode AND CP_MAX__c >= :first4DigitPostalCode];
     
        system.debug('postcod: ' + postcod);
            
        if(postcod.size() > 0){
            return postcod[0].Region__C;
        }  
        
        return null;
    }
    
    //TODO create a method that can be used in a trigger ex a singleton to query the data and the create a no Static method

}