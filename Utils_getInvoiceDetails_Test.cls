@isTest (SeeAllData = true)
public class Utils_getInvoiceDetails_Test {
    @isTest
    static void testgetInvoiceDetails(){
        RentingApplication_Util_Test utils_envoirment = new RentingApplication_Util_Test();
        Map<String, String> environmentVariables = utils_envoirment.environment7();
        Test.startTest();
        	List<Map<String,Object>> invoiceDetailsList = Utils_GetInvoiceDetails.getInvoiceDetails(environmentVariables.get('client'));
        Test.stopTest();
        System.debug('id do bill:'+environmentVariables.get('client'));
        
        List<Billing_Contract__c> billcont = [SELECT ID,(SELECT ID, Application__r.name, Quantity__c, Product_Code__c, Line_Item_Start_Date__c, Line_Item_End_Date__c, Billing_Contract__c, Product_Tax_Code__c, Sales_Price__c  FROM Billing_Contract_Line_Items__r WHERE Invoiced__c = FALSE ORDER BY Line_Item_End_Date__c ASC) FROM Billing_Contract__c WHERE Account__c = :environmentVariables.get('client') AND (Application__r.Status__c ='Contract - Running' OR Application__r.Status__c ='Contract - Arrears')];
		
        if(billcont == null){
            System.assert(false, 'No Billing Contract Found');
            return;
        }
        integer i;
        double value, taxRate;
        date endDate;
        BILL_ProductRegion BPR = new BILL_ProductRegion();
        List<Map<String,Object>> apNameValueDateLIST = new List<Map<String,Object>> ();
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
        
        Integer j = 0;
        for( ;j<apNameValueDateLIST.size(); j++){
            System.debug('comparision between values');
            System.assertEquals(apNameValueDateLIST[j].get('application'),invoiceDetailsList[j].get('application'));
			//Date auxStartDate = ;
			//Date auxEndDate =;
            System.assertEquals(apNameValueDateLIST[j].get('startDate'), (Date)invoiceDetailsList[j].get('startDate'));
            System.assertEquals(apNameValueDateLIST[j].get('endDate'), (Date)invoiceDetailsList[j].get('endDate'));
            System.assertEquals(apNameValueDateLIST[j].get('value'),invoiceDetailsList[j].get('value'));
        }
    }
}