@isTest
public class Tax_Utils_Test {

    @isTest
    public static void getMainland(){
        System.assertEquals('Mainland', Tax_Utils.convertPostalCodeToTaxZone('2100-123', 'PT'));
    }
    
    @isTest
    public static void getAzores(){
        System.assertEquals('Azores', Tax_Utils.convertPostalCodeToTaxZone('9600-123', 'PT'));
    }

    @isTest
    public static void getMadeira(){
        System.assertEquals('Madeira', Tax_Utils.convertPostalCodeToTaxZone('9100-123', 'PT'));
    }  
    
    @isTest
    public static void getUndefined(){
        System.assertEquals('Tax Zone not identified to this address.', Tax_Utils.convertPostalCodeToTaxZone('9999-123', 'PT'));
    }    
}