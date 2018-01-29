@isTest(SeeAllData=true)
public class AC_ControlerAssignmentOfContract_Test {
	public static ApexPages.StandardController standardController;
    
    @isTest
    public static void testAssignmentContract(){
        
        Map<String, String> infoMap = AC_AssignmentContractAPI_Test.setData();
        
        PageReference acPage = Page.AssignmentContract;
        test.setCurrentPage(acPage);
        ID bcID = infoMap.get('bcID');
        ApexPages.currentPage().getParameters().put('id',bcID);

        ApexPages.StandardController sc = new ApexPages.StandardController(new Billing_Contract__c(ID=bcID));
        AC_Controler_AssignmentOfContract acControler = new AC_Controler_AssignmentOfContract(sc);
        acControler.nif = '123456789';
        acControler.typeOfAssignContract = 'Closed Company';
        acControler.closedCompanyDate = Date.newInstance(2017,5,5);
        acControler.validate();
        acControler.attachment.name = 'test';
        acControler.validate();
        acControler.assignmentContract();
    }
    
    @isTest
    public static void testAssignmentContractMerge(){
        
        Map<String, String> infoMap = AC_AssignmentContractAPI_Test.setData();
        
        PageReference acPage = Page.AssignmentContract;
        test.setCurrentPage(acPage);
        ID bcID = infoMap.get('bcID');
        ApexPages.currentPage().getParameters().put('id',bcID);

        ApexPages.StandardController sc = new ApexPages.StandardController(new Billing_Contract__c(ID=bcID));
        AC_Controler_AssignmentOfContract acControler = new AC_Controler_AssignmentOfContract(sc);
        acControler.nif = '123456789';
        acControler.typeOfAssignContract = 'Merged Company';
        acControler.attachment.name = 'test';
        acControler.validate();
        acControler.assignmentContract();
    }    
}