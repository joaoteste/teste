public class BILL_ProductRegion {
    
    //New Implementation of Products
    //Product Code - Product Region => Product
    private Map<String, Map<String, ID>> productCodeToProductInputMap = new Map<String, Map<String, ID>>();
	//Product Code - Product Region => Tax Code
    private Map<String, Map<String, ID>> productCodeToTaxCodeInputMap = new Map<String, Map<String, ID>>(); 
    
    //Product Code - Product Region => Product
    private Map<String, Map<String, ID>> productCodeToProductOutputMap = new Map<String, Map<String, ID>>();
	//Product Code - Product Region => Tax Code
    private Map<String, Map<String, ID>> productCodeToTaxCodeOutputMap = new Map<String, Map<String, ID>>();    
    // Product ID => Product Code
    private Map<ID, String> productIDtoProductCode = new Map<ID, String>();
    // Tax Rate ID => Tax Rate 
    private Map<ID, Double> taxCodeToTaxRateMap = new Map<ID, Double>();
    
    
    public BILL_ProductRegion(){
		loadInformation('Standard');
    }
    
    public BILL_ProductRegion(String vatGstOption){
		loadInformation(vatGstOption);
    }    
    
    private void loadInformation(String vatGstOption){
        
        List<Product_Tax_Code__c> productTaxCodeList;
        if(vatGstOption == 'Standard'){
        	productTaxCodeList = [SELECT ID, Name, Product__r.ProductCode, Tax_Code__r.Tax_Zone__c, VAT_GST__c FROM Product_Tax_Code__c];
        }else if(vatGstOption == 'Input'){
            productTaxCodeList = [SELECT ID, Name, Product__r.ProductCode, Tax_Code__r.Tax_Zone__c, VAT_GST__c FROM Product_Tax_Code__c WHERE VAT_GST__c = 'Input'];
        }else if(vatGstOption == 'Output'){
            productTaxCodeList = [SELECT ID, Name, Product__r.ProductCode, Tax_Code__r.Tax_Zone__c, VAT_GST__c FROM Product_Tax_Code__c WHERE VAT_GST__c = 'Output'];
        }
		
        //no products found or vatGstOption bad formulated
        if(productTaxCodeList.isEmpty()){
            return;
        }
        
        //Joao
        Set <ID> taxCodeSet = new Set <ID>();
        
        for(Product_Tax_Code__c tc : productTaxCodeList){
            taxCodeSet.add(tc.Tax_Code__c);
        }           
        
        List<c2g__codaTaxRate__c> taxCodePerTaxRateList = [SELECT ID, c2g__TaxCode__c, c2g__Rate__c FROM c2g__codaTaxRate__c WHERE c2g__TaxCode__c IN :taxCodeSet];
    
        for(c2g__codaTaxRate__c tr : taxCodePerTaxRateList){
            if(tr.c2g__TaxCode__c != null && tr.c2g__Rate__c != null)
            	taxCodeToTaxRateMap.put(tr.c2g__TaxCode__c, (tr.c2g__Rate__c / 100));
        }
        
        system.debug(taxCodeToTaxRateMap);
        //  
        
        system.debug(productTaxCodeList);
        for(Product_Tax_Code__c ptc : productTaxCodeList){
            system.debug(ptc);
            if(ptc.VAT_GST__c == 'Input'){
                //region => Product ID
                Map<String, ID> regionToProductMap;
                //region => Product ID
                Map<String, ID> regionToTaxCodeMap;     
                
                if(!productCodeToProductInputMap.containsKey(ptc.Product__r.ProductCode)){
                    system.debug('PRD - Creating new Map for: '+ ptc.Product__r.ProductCode);
                    regionToProductMap = new Map<String,ID>();
                    productCodeToProductInputMap.put(ptc.Product__r.ProductCode, regionToProductMap);                    
                }else{
                    system.debug('PRD - Using the same Map for: '+ ptc.Product__r.ProductCode);
                    regionToProductMap = productCodeToProductInputMap.get(ptc.Product__r.ProductCode);
                }
                
                if(!productCodeToTaxCodeInputMap.containsKey(ptc.Product__r.ProductCode)){
                    system.debug('Region - Creating new Map for: '+ ptc.Name);
                    regionToTaxCodeMap = new Map<String,ID>();
                    productCodeToTaxCodeInputMap.put(ptc.Product__r.ProductCode, regionToTaxCodeMap);
                }else{
                    system.debug('Region - Using the same Map for: '+ ptc.Name);                    
                    regionToTaxCodeMap = productCodeToTaxCodeInputMap.get(ptc.Product__r.ProductCode);
                }    
                
                system.debug(ptc.Tax_Code__r.Tax_Zone__c+' ||| '+ ptc.Tax_Code__c);
                system.debug(ptc.Tax_Code__r.Tax_Zone__c+' ||| '+ ptc.Product__c);                
                regionToTaxCodeMap.put(ptc.Tax_Code__r.Tax_Zone__c, ptc.Tax_Code__c);
                regionToProductMap.put(ptc.Tax_Code__r.Tax_Zone__c, ptc.Product__c);
                
            }else{
                
                //region => Product ID
                Map<String, ID> regionToProductMap;
                //region => Product ID
                Map<String, ID> regionToTaxCodeMap;     
                
                if(!productCodeToProductOutputMap.containsKey(ptc.Product__r.ProductCode)){
                    system.debug('PRD - Creating new Map for: '+ ptc.Name);
                    regionToProductMap = new Map<String,ID>();
                    productCodeToProductOutputMap.put(ptc.Product__r.ProductCode, regionToProductMap);                    
                }else{
                    system.debug('PRD - Using the same Map for: '+ ptc.Name);
                    regionToProductMap = productCodeToProductOutputMap.get(ptc.Product__r.ProductCode);
                }
                
                if(!productCodeToTaxCodeOutputMap.containsKey(ptc.Product__r.ProductCode)){
                    system.debug('Region - Creating new Map for: '+ ptc.Name);
                    regionToTaxCodeMap = new Map<String,ID>();
                    productCodeToTaxCodeOutputMap.put(ptc.Product__r.ProductCode, regionToTaxCodeMap);
                }else{
                   system.debug('Region - Using the same Map for: '+ ptc.Name);                    
                    regionToTaxCodeMap = productCodeToTaxCodeOutputMap.get(ptc.Product__r.ProductCode);
                }    
                
                system.debug(ptc.Tax_Code__r.Tax_Zone__c+' ||| '+ ptc.Tax_Code__c);
                system.debug(ptc.Tax_Code__r.Tax_Zone__c+' ||| '+ ptc.Product__c);                
                regionToTaxCodeMap.put(ptc.Tax_Code__r.Tax_Zone__c, ptc.Tax_Code__c);
                regionToProductMap.put(ptc.Tax_Code__r.Tax_Zone__c, ptc.Product__c);             
            }
            productIDtoProductCode.put(ptc.Product__c, ptc.Product__r.ProductCode);

        }
        
        system.debug(productCodeToProductInputMap);
        system.debug(productCodeToTaxCodeInputMap);        
    }
    
    /**
     * true if Input VAT, false otherwise
    */
    public ID getProduct(String productCode, String taxZone){
		return getProduct(productCode, taxZone, true);
    }
    
    public ID getProduct(String productCode, String taxZone, Boolean InputOutputVATGST){
        system.debug('Product Code: '+ productCode + ' TaxZone: '+ taxZone + ' InputOutputVATGST: ' + InputOutputVATGST);
        if(InputOutputVATGST){
            return (productCodeToProductInputMap.get(productCode)).get(taxZone);
        }else{
            return (productCodeToProductOutputMap.get(productCode)).get(taxZone);
        }
    }


    /**
     * true if Input VAT, false otherwise
    */  
    
    public ID getTaxCode(String productCode, String taxZone){
		return getTaxCode(productCode, taxZone, true);
    }
    
    public ID getTaxCode(String productCode, String taxZone, Boolean InputOutputVATGST){
        system.debug('Product Code: '+ productCode + ' TaxZone: '+ taxZone + ' InputOutputVATGST: ' + InputOutputVATGST);        
        if(InputOutputVATGST){
            return (productCodeToTaxCodeInputMap.get(productCode)).get(taxZone);
        }else{
            return (productCodeToTaxCodeOutputMap.get(productCode)).get(taxZone);
        }
    }  
    
    
    //
    public String getProductCode(ID productID){
        return productIDtoProductCode.get(productID);
    }
    
    //joao
    public double getTaxRateToTaxCode(ID taxCodeID){
        system.debug(taxCodeToTaxRateMap);
        system.debug(taxCodeID);
        return taxCodeToTaxRateMap.get(taxCodeID);
    }
    //

    
}