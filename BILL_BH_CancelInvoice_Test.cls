@isTest(SeeAllData=true)
public class BILL_BH_CancelInvoice_Test {
	
    @isTest
    public static void cancelInvoiceBatch_Test(){
        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = utils.environment1();     
        List<ID> salesInvoiceID = new List<ID>();
        ID siID = infoMap.get('salesInvoice');
        salesInvoiceID.add(siID);
        
        Test.startTest();
        	Database.executeBatch(new BILL_BH_CancelInvoice(salesInvoiceID), 1);
        Test.stopTest();
        
        c2g__codaInvoice__c salesInvoice = [SELECT ID, c2g__PaymentStatus__c FROM c2g__codaInvoice__c WHERE ID = :siID];
        system.assertEquals('Paid', salesInvoice.c2g__PaymentStatus__c);

    }
}