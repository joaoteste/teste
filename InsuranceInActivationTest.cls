@isTest (SeeAllData = true)
public class InsuranceInActivationTest {
    private static id billId = 'a4o240000000A8x';
    private static InsuranceInactivation controller;
    
    static void setup() {
        Billing_Contract__c billingContract =[Select ID,Application__c,Name from Billing_Contract__c where id = :billId];
        
        String insuranceCompany = 'Seguradoras Unidas, S.A.';
        String policyNumber = '123x';
        Date clientPolicyDate =Date.newInstance(2017, 07, 04);
        
        Insurance_Management__c insurance = InsuranceManagement.createActiveInsuranceManagement(billingcontract.Application__c, insuranceCompany, policyNumber,clientPolicyDate , 'Own Insurance');
        //InsuranceManagement.insuranceInactivationRenting(insurance,policyNumber,insuranceCompany,clientPolicyDate);
        InsuranceManagement.settleInsuranceManagement(insurance, 'Own Insurance', insuranceCompany, 20, 5);   
        
        PageReference pageRef = Page.InsuranceInActivation;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getParameters().put('id', billId);
        ApexPages.StandardController  sc = new ApexPages.StandardController(billingContract);
        
        controller = new InsuranceInactivation(sc);
    }
    
    @isTest
    public static void testInactiveWithoutInsurance(){
        Test.startTest();
        
        Billing_Contract__c billingContract =[Select ID,Application__c,Name from Billing_Contract__c where id = :billId];
        
        PageReference pageRef = Page.InsuranceInActivation;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getParameters().put('id', billId);
        ApexPages.StandardController  sc = new ApexPages.StandardController(billingContract);
        
        controller = new InsuranceInactivation(sc);
        
        // Instantiate a new controller with all parameters in the page
        controller.setApoliceNumber('123');
        controller.setSeguradora('Seguradoras Unidas, S.A.');
        Date beginningDate = Date.newInstance(2017, 07, 04);
        controller.setClientePolicyBeginningTerm(beginningDate);
        Blob file = Blob.valueOf('FILETEXT');
        controller.setApolice(file);
        controller.setApoliceFileName('FileName');
        
        controller.Inactivate();
        controller.Activate();
        controller.Cancel();
        Test.stopTest();
    }
    
    @isTest
    public static void testControllerInsuranceInactive(){
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
        controller.Activate();
        controller.Activate();
        controller.Inactivate();
        controller.Inactivate();
        controller.Cancel();
        Test.stopTest();
    }
    
    @isTest
    public static void testControllerInsuranceActive(){
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
        
        controller.Activate();
        controller.Inactivate();
        controller.Inactivate();
        controller.Activate();
        controller.Cancel();
        Test.stopTest();
    }
    
    @isTest
    public static void testWithoutParameters(){
        setup();
        
        Test.startTest();
   
        Blob file = Blob.valueOf('FILETEST');
        controller.setApolice(file);
        controller.setApoliceFileName('FileName');
        controller.setSeguradora('Seguradoras Unidas, S.A.');
        controller.Inactivate();
        controller.Activate();
        controller.Cancel();
        Test.stopTest();
   }
    
    @isTest
    public static void testWithoutApolice(){
        setup();
        
        Test.startTest();
        controller.setSeguradora('Seguradoras Unidas, S.A.');

        controller.Inactivate();
        controller.Activate();
        controller.Cancel();
        Test.stopTest();
   }

    
    @isTest
    public static void testCancel(){
        setup();
        
        Test.startTest();
        
        controller.Activate();
        controller.Cancel();
        Test.stopTest();
    }    
}