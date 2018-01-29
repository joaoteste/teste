@isTest
private class CreditInfoContextTest {
    
    @isTest
    static void constructorTest(){
        String TaxPayerNumber = '123456789';
        String country = 'Portugal';
        ID accountID  = 'a012600000JDkDDDDD';
        ID applicationID = 'a012600000JDkZPCCC';
        ID vendorAccountID = 'a012600000JDkZPBBB';
        ID vendorLoginID = 'a012600000JDkZPAA1';
        
        Test.startTest();
        
        CreditInfoContext creditInfoContext = new CreditInfoContext(taxPayerNumber, country, accountID);
        System.assertEquals(TaxPayerNumber, creditInfoContext.TaxPayerNumber);
        System.assertEquals(country, creditInfoContext.country);
        System.assertEquals(accountID, creditInfoContext.accountID);
        
        CreditInfoContext creditInfoContext_2 = new CreditInfoContext(taxPayerNumber, country, accountID, vendorAccountID, vendorLoginID);
        System.assertEquals(TaxPayerNumber, creditInfoContext_2.TaxPayerNumber);
        System.assertEquals(country, creditInfoContext_2.country);
        System.assertEquals(accountID, creditInfoContext_2.accountID);
        System.assertEquals(vendorAccountID, creditInfoContext_2.vendorAccountID);
        System.assertEquals(vendorLoginID, creditInfoContext_2.vendorLoginID);
        
        CreditInfoContext creditInfoContext_3 = new CreditInfoContext(taxPayerNumber, country, accountID, applicationID);
        System.assertEquals(TaxPayerNumber, creditInfoContext_3.TaxPayerNumber);
        System.assertEquals(country, creditInfoContext_3.country);
        System.assertEquals(accountID, creditInfoContext_3.accountID);
        System.assertEquals(applicationID, creditInfoContext_3.applicationID);
        
        Test.stopTest();
        
    }
}