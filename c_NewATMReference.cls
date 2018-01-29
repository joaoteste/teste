Public class c_NewATMReference{
    
    public PageReference pgReturnPage;
    Public string IdUrl {get;set;} 
    
    Public c_NewATMReference(ApexPages.StandardController stdController){
        IdUrl  = stdController.GetID();
        
        String returnUrl = '/' + IdUrl;
        pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
    }    
    
    Public PageReference RedirectDunningAlert(){   
    
        Dunning_Alert__c da = [Select id, Collection_Case__c, Amount_Claimed__c, Due_Date__c from Dunning_Alert__c where id = :IdUrl ];       
  
        PaymentCollection_Utils pcUtils = new PaymentCollection_Utils();
        if(!Test.isRunningTest()){
            AggregateResult[] salesInvoiceList = [SELECT SUM(c2g__Transaction__r.c2g__DocumentOutstandingTotal__c)total FROM c2g__codaInvoice__c WHERE Collection_Case__c = :da.Collection_Case__c AND (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid')];
            pcUtils.createPaymentCollectionWithATM((Decimal) salesInvoiceList[0].get('total'), Date.valueOf(da.Due_Date__c), da.id, 'DunningAlert');          
        }
        return pgReturnPage;
    }
   
}