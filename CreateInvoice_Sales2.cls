global class CreateInvoice_Sales2 implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    global String query;
    global CreateInvoice_Sales2(Integer limitAux){
        if(limitAux == 0)
            query = 'SELECT ID, Product_Tax_Code__c,Product__r.ProductCode, Application__r.AccClient__r.Tax_Zone__c FROM Billing_Contract_Line_Item__c WHERE Product_Tax_Code__c = Null';
        else
            query = 'SELECT ID, Product_Tax_Code__c,Product__r.ProductCode, Application__r.AccClient__r.Tax_Zone__c FROM Billing_Contract_Line_Item__c Limit 1';
    }

    
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Billing_Contract_Line_Item__c> billList){
        BILL_ProductRegion billRegion = new BILL_ProductRegion('Input');
        String productCode;
        String taxZone;
        for(Billing_Contract_Line_Item__c bcli : billList){
            system.debug(bcli.ID);
                productCode = bcli.Product__r.ProductCode;
                taxZone = bcli.Application__r.AccClient__r.Tax_Zone__c;
            system.debug(taxZone);
                bcli.Product_Tax_Code__c = billRegion.getTaxCode(productCode, taxZone);
        }   
        
        update billList;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
  
    
}