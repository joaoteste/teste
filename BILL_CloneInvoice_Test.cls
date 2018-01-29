@isTest(SeeAllData=true)
public class BILL_CloneInvoice_Test {

    
    @isTest
    public static void testCloneInvoice(){
        

        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = utils.environment1();      
        
        PageReference acPage = Page.Clone_Invoice;
        test.setCurrentPage(acPage);
        ID siID = infoMap.get('salesInvoice');
		List<c2g__codaInvoice__c> salesInvoiceList = [select id from c2g__codaInvoice__c where id = :siID];

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(salesInvoiceList);
        sc.setSelected(salesInvoiceList);
        BILL_Controller_CloneInvoice ciController = new BILL_Controller_CloneInvoice(sc);        
		
        Test.startTest();
        	ciController.cloneInvoice();
        Test.stopTest();
        
        c2g__codaInvoice__c si = ciController.salesInvoice;
        List<c2g__codaInvoice__c> siNew = [SELECT ID FROM c2g__codaInvoice__c WHERE ID = :si.ID];
        
        System.assert(!siNew.isEmpty());
        
    }
}