@isTest(SeeAllData=true)
public class AC_RenderController_Test {

    
    @isTest
    public static void testRender(){
        Map<String, String> infoMap = AC_AssignmentContractAPI_Test.setData();
        
        PageReference acPage = Page.AssignmentOfContractRender;
        test.setCurrentPage(acPage);
        ID acID = infoMap.get('acID');
        ApexPages.currentPage().getParameters().put('id',acID);

        ApexPages.StandardController sc = new ApexPages.StandardController(new AssignmentContract__c(ID=acID));
        AC_AssignmentOfContractRender_Controller acControler = new AC_AssignmentOfContractRender_Controller(sc);  
        acControler.getFiador0NIF();
        acControler.getFiador1NIF();
        acControler.getFiador0PostalCode();
		acControler.getFiador1PostalCode();     
        acControler.getFiador0Address();
        acControler.getFiador1Address();
        acControler.getFiador0City();
        acControler.getFiador1City();
        acControler.getIban();
    }
}