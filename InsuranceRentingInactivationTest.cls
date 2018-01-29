@isTest (SeeAllData = true)
public class InsuranceRentingInactivationTest {
	private static Id appId = 'a012400000Qevek';
    private static InsuranceRentingInactivation controller;

    static void setup() {
        Application__c app = [Select ID,Name,Insurance_Type__c from Application__c where id = :appId];
        
        String insuranceCompany = 'Seguradoras Unidas, S.A.';
        String policyNumber = '123x';
        Date clientPolicyDate = Date.newInstance(2017, 07, 04);
        
        Insurance_Management__c insurance = InsuranceManagement.createActiveInsuranceManagement(appId, insuranceCompany, policyNumber, clientPolicyDate, 'Own Insurance');
        
        PageReference pageRef = Page.InsuranceRentingInactivation;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getParameters().put('id', appId);
        ApexPages.StandardController  sc = new ApexPages.StandardController(app);
        controller = new InsuranceRentingInactivation(sc);
    }
    
    @isTest (SeeAllData = true)
    public static void testControllerInsurance(){
        setup();

        Test.startTest();        
        // Instantiate a new controller with all parameters in the page
        controller.setApoliceNumber('123');
        controller.setSeguradora('Seguradoras Unidas, S.A.');
        Date beginningDate = Date.newInstance(2017, 07, 04);
        
        controller.setClientePolicyBeginningTerm(beginningDate);
        Blob file = Blob.valueOf('FILETEXT');
        controller.setApolice(file);
        controller.setApoliceFileName('FileName');     
        
        controller.Inactivate();
        controller.Cancel();
        Test.stopTest();

    }
    
    @isTest (SeeAllData = true)
    public static void testWithoutParameters(){
        setup();

        Test.startTest();
        
        Blob file = Blob.valueOf('FILETEXT');
        controller.setApolice(file);
        controller.setApoliceFileName('FileName');
        
        controller.Inactivate();
        controller.Cancel();   
        Test.stopTest();
    }

    @isTest (SeeAllData = true)
    public static void testWithoutApolice(){
        setup();
        
        Test.startTest();
        
        controller.Inactivate();
        controller.Cancel();
        Test.stopTest();
    }
    
}