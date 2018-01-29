@isTest
private class BILL_ProductRegionTest {
    
    
    /*
    @testSetup 
    public static void billProductRegionSetupTest(){
        
        String postalCodeExample = '1000-423';
        
        c2g__codaGeneralLedgerAccount__c generalLedgerAccount = RentingApplication_Util_Test.createGeneralLedgerAccount();
        c2g__codaTaxCode__c codaTaxCode = RentingApplication_Util_Test.createCodaTaxCode(UTIL_PostCode.getRegionFromPostCode(postalCodeExample),generalLedgerAccount);
        
        Product2 prod1 = RentingApplication_Util_Test.createProductRegion('Product1', 'PT01',codaTaxCode);
        Product2 prod2 = RentingApplication_Util_Test.createProductRegion('Product2', 'PT02',codaTaxCode);
        Product2 prod3 = RentingApplication_Util_Test.createProductRegion('Product3', 'PT03',codaTaxCode);
        
    }
    
    @isTest
    static void getProductP(){
        String region = UTIL_PostCode.getRegionFromPostCode('1000-423');
        
        BILL_ProductRegion billProductRegion = new BILL_ProductRegion();
        system.debug('PT01 ' +billProductRegion.getProduct('PT01', region)); 
        system.debug('PT02 ' +billProductRegion.getProduct('PT02', region));     
        system.debug('PT03 ' +billProductRegion.getProduct('PT03', region)); 
        
    }*/
    
    @testSetup
    static void billProductRegionSetup(){
        Product2 prod = new Product2(name='Produto Test',ProductCode = 'PT01');
        insert prod;
        
            
        c2g__codaGeneralLedgerAccount__c generalLedgerAcc = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAcc.Name = '21110 - CLIENTES NACIONAIS';
        generalLedgerAcc.c2g__ReportingCode__c = '21110';
        generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
        insert generalLedgerAcc;
                
        c2g__codaTaxCode__c taxv2 = new c2g__codaTaxCode__c();
        taxv2.Name = 'textTaxv2';
        taxv2.c2g__Description__c ='testTaxv2 description';   
        taxv2.c2g__GeneralLedgerAccount__c = generalLedgerAcc.id;
        taxv2.Tax_Zone__c = 'Mainland';
        insert taxv2;  
        
        Product_Tax_Code__c prdTaxCode = new Product_Tax_Code__c(Product__c = prod.ID, Tax_Code__c = taxv2.ID, VAT_GST__c = 'Input');
        insert prdTaxCode;
        Product_Tax_Code__c prdTaxCodeOutput = new Product_Tax_Code__c(Product__c = prod.ID, Tax_Code__c = taxv2.ID, VAT_GST__c = 'Output');
        insert prdTaxCodeOutput;
    }
    
    @isTest
    static void getProductInput(){
        String region = Tax_Utils.convertPostalCodeToTaxZone('1234-123','PT');
        BILL_ProductRegion billRegion = new BILL_ProductRegion('Input');
        billRegion.getProduct('PT01', region);
        billRegion.getTaxCode('PT01', region);
        billRegion.getProduct('PT01', region, true);
        billRegion.getTaxCode('PT01', region, true);
    }
    
    
    @isTest
    static void getProductOutput(){
        String region = Tax_Utils.convertPostalCodeToTaxZone('1234-123','PT');
        BILL_ProductRegion billRegion = new BILL_ProductRegion('Output');
        billRegion.getProduct('PT01', region, false);
        billRegion.getTaxCode('PT01', region, false);
    }    
    
}