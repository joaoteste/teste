@isTest (SeeAllData=true)
public class SEPA_SI_to_SR_TEST {
    
    @isTest (SeeAllData=true)
    public static void test_SEPA_SI_to_SR() { 

		Test.startTest(); 
		Id salesInvoice = 'a2y24000001bTvx';
		Set<Id> turnedToCompletedIDs = new Set<Id>();
		turnedToCompletedIDs.add(salesInvoice);

		SEPA_SI_to_SR.createPaymentCollectionWithSEPAFromSalesInvoice(turnedToCompletedIDs);
			
		Test.stopTest();
         
    }
}