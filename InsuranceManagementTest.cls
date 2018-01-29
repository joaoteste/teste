@isTest
public class InsuranceManagementTest {

    //montly advanced - direct debit
    @isTest(SeeAllData=true)
    private static Application__c  AppMontlhyAdvanced(){
        Application__c app = [Select Id From Application__c where ID ='a012400000cmJzR'];
        InsuranceCancelTest(app.Id);
        return app;
    }
    
    //montly arreas - direct debit
    @isTest(SeeAllData=true)
    private static Application__c  getAppMontlyArreas(){
        Application__c app = [Select Id From Application__c where ID ='a012400000LbvEM'];
        InsuranceCancelTest(app.Id);
        return app;
    }
    
    //montly arreas - atm
    @isTest(SeeAllData=true)
    private static Application__c  getAppMontlyArreasAtm(){
        Application__c app = [Select Id From Application__c where ID ='a012400000V2ZYB'];
        InsuranceCancelTest(app.Id);
        return app;
    }

    //montly arreas - atm
   /* 
    @isTest(SeeAllData=true)
    private static Application__c  getAppMontlyActivation(){
        Application__c app = [Select Id,Chosen_Insurance_value__c 
                              From Application__c 
                              where Payment_Freq__c = 'Monthly' and Insurance_Type__c = 'Own Insurance'
                              and Status__c = 'Contract - Running' and id = 'a012400000ZIcA3'
                              limit 1];
        
        InsuranceActivationTest(app.Id);
        return app;
    }
*/
    
    //**********************************Quarterly Apps are all Advanced******************************/
    
    //quarterly advanced
   /* @isTest(SeeAllData=true)
    private static Application__c getAppQuarterlyATM(){
        Application__c app= [Select Id From Application__c where ID = 'a012400000eltZ1' ];
        InsuranceCancelTest(app.Id);
        return app;
    }
    */
    @isTest(SeeAllData=true)
    private static Application__c getAppQuarterlyActivation(){
        Application__c app= [Select Id From Application__c where Payment_Freq__c = 'Quarterly' and Insurance_Type__c = 'Own Insurance' and Status__c = 'Contract - Running'
                             limit 1];
        InsuranceActivationTest(app.Id);
        return app;
    }
    
    //quarterly advanced
    @isTest(SeeAllData=true)
    private static Application__c getAppQuarterlyDirectDebit(){
        Application__c app= [Select Id From Application__c where ID = 'a012400000Qevek' ];
        InsuranceCancelTest(app.Id);
        return app;
    }
    
    @isTest(SeeAllData=true)
    private static void webserviceTest(){
        Application__c app= [Select Id,Name From Application__c where Insurance_Type__c != null and Insurance_Type__c != '' limit 1 ];
        
        InsuranceManagement.createAndSettleInsurance(app.Name);
    }
    

    /*Methods to Test*/
    public static void InsuranceCancelTest(ID appId){
        String insuranceCompany = 'Seguradoras Unidas, S.A.';
        String policyNumber = '123';
        Date beginningTerm = DAte.newInstance(2017, 1, 20);
        String insuranceType = 'Own Insurance';
        
        Insurance_Management__c insurance = InsuranceManagement.createActiveInsuranceManagement(appId, insuranceCompany, policyNumber,  beginningTerm,  insuranceType);
        
        Decimal insuranceValue = 30.14;
        Decimal insurancePercent = 4.5;
        
        
        InsuranceManagement.settleInsuranceManagement(insurance, insuranceType, insuranceCompany, insuranceValue, insurancePercent);
        
        InsuranceManagement.cancelInsurance(insurance.Renting_Application__c,policyNumber,insuranceCompany,Date.today());
        
    }
    
    public static void InsuranceActivationTest(ID appId){
        String insuranceCompany = 'Seguradoras Unidas, S.A.';
        String policyNumber = '123';
        Date beginningTerm = DAte.newInstance(2017, 1, 20);
        String insuranceType = 'Own Insurance';
        
        Insurance_Management__c insurance = InsuranceManagement.createActiveInsuranceManagement(appId, insuranceCompany, policyNumber,  beginningTerm,  insuranceType);
        
        Decimal insuranceValue = 30.14;
        Decimal insurancePercent = 4.5;
        
        //app está com seguro client insurance (own insurance) logo o método inativará o seguro
        InsuranceManagement.settleInsuranceManagement(insurance, insuranceType, insuranceCompany, insuranceValue, insurancePercent);
        
        Test.startTest();
        InsuranceManagement.activationInsurance(insurance.Renting_Application__c,policyNumber,insuranceCompany,Date.today());
        
        InsuranceManagement.cancelInsurance(insurance.Renting_Application__c,policyNumber,insuranceCompany,Date.today());
        Test.stopTest();

    }
    
    @isTest(SeeAllData=true)
    private static void InsuranceInactivationRentingTest(){
        String insuranceCompany = 'Seguradoras Unidas, S.A.';
        String policyNumber = '123';
        Date beginningTerm = DAte.newInstance(2017, 1, 20);
        String insuranceType = 'Own Insurance';

        Application__c app = [Select ID FROm Application__c where Status__c = 'Contract - Running' limit 1];
        
        Test.startTest();
        Insurance_Management__c insurance = InsuranceManagement.createActiveInsuranceManagement(app.Id, insuranceCompany, policyNumber,  beginningTerm,  insuranceType);
                
        Decimal insuranceValue = 30.14;
        Decimal insurancePercent = 4.5;
        
        InsuranceManagement.insuranceInactivationRenting(app.Id,policyNumber,insuranceCompany,Date.today());
        Test.stopTest();
        
    }
    
}