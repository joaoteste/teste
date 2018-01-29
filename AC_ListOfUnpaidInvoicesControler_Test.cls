@isTest(SeeAllData=true)
public class AC_ListOfUnpaidInvoicesControler_Test {
    
    @isTest
    public static void testUnpaid(){
        Map<String, String> infoMap = AC_AssignmentContractAPI_Test.setData();
        
        PageReference acPage = Page.AssignmentOfContractRender;
        test.setCurrentPage(acPage);
        ID acID = infoMap.get('acID');
        ApexPages.currentPage().getParameters().put('id',acID);

        ApexPages.StandardController sc = new ApexPages.StandardController(new AssignmentContract__c(ID=acID));
        AC_Controler_ListOfUnpaidInvoices acControler = new AC_Controler_ListOfUnpaidInvoices(sc);       
    }

}