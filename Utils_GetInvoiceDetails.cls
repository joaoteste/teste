public class Utils_GetInvoiceDetails{
    /* 
* Returns a list of maps with the keys (application, startDate, endDate and value) for the next invoice in all the billing process associated with the Id passed as parameter
*/
    public static List<Map<String,Object>> getInvoiceDetails(ID accountID){   
        //Querys to retrieve both the Billing Contracts and Billing Contracts Line Items of a given account.
        List<Billing_Contract__c> billcont = [SELECT ID,
                                              (SELECT ID, Application__r.name, Quantity__c, Product_Code__c, Line_Item_Start_Date__c, Line_Item_End_Date__c, Billing_Contract__c, Product_Tax_Code__c, Sales_Price__c  
                                               FROM Billing_Contract_Line_Items__r WHERE Invoiced__c = FALSE ORDER BY Line_Item_End_Date__c ASC) 
                                              FROM Billing_Contract__c 
                                              WHERE Account__c = :accountID AND (Application__r.Status__c ='Contract - Running' OR Application__r.Status__c ='Contract - Arrears')];
        
        if(billcont.size() < 1){
            System.debug('No Billing Contract Found');
            //No Billing Contract Line Item found
            return null;
        }
        
        //Get the tax rate for the current product
        BILL_ProductRegion BPR = new BILL_ProductRegion();
        List<Map<String,Object>> apNameValueDateLIST = new List<Map<String,Object>> ();
        
        //Map<String,String> ApDateValue = new Map<String,String>();                                   
        integer i;
        double value, taxRate;
        date endDate;
        for(Billing_Contract__c bc: billcont){  
            i=0;
            value = 0;
            Map<String,Object> ApDateValue = new Map<String,Object>();  
            for(Billing_Contract_Line_Item__c bcli :bc.Billing_Contract_Line_Items__r){
                //the billing contract line item is ordered asc by line item end date, therefore, the positions 0 contains the info for the next invoice
                if(i==0){
                    endDate = bcli.Line_Item_End_Date__c;
                    ApDateValue.put('application',  bcli.Application__r.name);
                    ApDateValue.put('startDate',    bcli.Line_Item_Start_Date__c);
                    ApDateValue.put('endDate',      bcli.Line_Item_End_Date__c);
                } 
                    //sums the value of all the billing contract line items for the nearest due date.
                if(bcli.Line_Item_End_Date__c == endDate) {
                    taxRate = BPR.getTaxRateToTaxCode(bcli.Product_Tax_Code__c);
                    taxRate = taxRate==null ? 0 : taxRate;
                    value = value + (bcli.Sales_Price__c * (1+taxRate));    
                }
                i++;
            } 
            ApDateValue.put('value',  String.valueOf(value));
            apNameValueDateLIST.add(ApDateValue);
        } 
        System.debug(apNameValueDateLIST);
        return apNameValueDateLIST;
    }
}