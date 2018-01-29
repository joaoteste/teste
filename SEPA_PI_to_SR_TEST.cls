@isTest (SeeAllData=true)
public class SEPA_PI_to_SR_TEST {
	//TODO
  /*  
    @isTest (SeeAllData=true)
    public static void test_SEPA_PI_to_SR() {
        
         c2g__codaPurchaseInvoice__c pi
            = [
                SELECT Id
                    , Name
                    , c2g__Account__r.c2g__CODABankIBANNumber__c
                    , c2g__Account__r.Id
                    , c2g__Account__r.Name
                    , c2g__Account__r.NIF__c
                    , c2g__Account__r.Type
                    , c2g__DueDate__c
                    , c2g__AccountInvoiceNumber__c
                    , c2g__InvoiceStatus__c
                    , c2g__InvoiceCurrency__c
                    , c2g__OutstandingValue__c
                    FROM c2g__codaPurchaseInvoice__c
                    WHERE
 				c2g__InvoiceStatus__c = 'In Progress'
                LIMIT 1];
        
        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
        ref.id = pi.id  ;
        c2g.CODAAPIPurchaseInvoice_8_0.PostPurchaseInvoice(null, ref);
        
    }
   */ 
    @isTest
    public static void updatePaymentCollectionWithSEPATest(){
    	
    	Test.startTest();
    	
    	SEPA_PI_to_SR.updatePaymentCollectionWithSEPAPayableInvoice();
    	
    	Test.stopTest();
    }
    
}