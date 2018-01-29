@isTest(SeeAllData=true)
public class PaymentPlan_Controller_Test {
    
    @isTest 
    public static void testPartial(){
        RentingApplication_Util_Test rentUtils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rentUtils.environment1();
        Contact cont = new Contact();
        cont.AccountId = infoMap.get('client');
        cont.Email = 'test@test.pt';
        cont.LastName = 'Test';
        cont.Phone = '915229100';
		insert cont;       
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Type__c = 'Partial';
        pp.Account__c = infoMap.get('client');
        pp.Contact__c = cont.ID;
        pp.Frequency__c = 'Every 15 Days';
        pp.Number_of_Payments__c = '2';
        pp.ATM_Costs__c = true;
        pp.Collection_Case__c = infoMap.get('ccID');
        insert pp;
        
        Payment_Schedule__c ps = new Payment_Schedule__c();
        ps.Payment_Plan__c = pp.ID;
        ps.Amount__c = 100;
        ps.Fees_Amount__c = 20;
        ps.Amount_W_O_Tax__c = 100;
        ps.Due_Date__c = system.today();
        ps.Schedule_Number__c = '1';
        insert ps;

        Payment_Schedule__c ps2 = new Payment_Schedule__c();
        ps2.Payment_Plan__c = pp.ID;
        ps2.Amount__c = 100;
        ps2.Fees_Amount__c = 20;
        ps2.Amount_W_O_Tax__c = 100;
        ps2.Due_Date__c = system.today().addDays(2);
        ps2.Schedule_Number__c = '2';
        insert ps2;        
            
        
        
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(pp);
            ApexPages.currentPage().getParameters().put('id',pp.ID);
            PaymentPlan_Controller objPartialPaymentPlanCtrl = new PaymentPlan_Controller(sc);

            objPartialPaymentPlanCtrl.acceptPaymentPlan();
 
        Test.stopTest();
    }
    
    @isTest
    public static void testFull(){
		RentingApplication_Util_Test rentUtils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rentUtils.environment1();
        
        Contact cont = new Contact();
        cont.AccountId = infoMap.get('client');
        cont.Email = 'test@test.pt';
        cont.LastName = 'Test';
        cont.Phone = '915229100';
		insert cont;              
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Type__c = 'Full';
        pp.Contact__c = cont.ID;
        pp.Account__c = infoMap.get('client');
        pp.Frequency__c = 'Every 15 Days';
        pp.ATM_Costs__c = true;
        pp.Number_of_Payments__c = '2';
        pp.Partial_Payment_Plan_Term__c = 10;
        pp.Collection_Case__c = infoMap.get('ccID');
        insert pp;
        
        Payment_Schedule__c ps = new Payment_Schedule__c();
        ps.Payment_Plan__c = pp.ID;
        ps.Amount__c = 100;
        ps.Amount_W_O_Tax__c = 100;
        ps.Late_Payment_Interest_Amount__c = 100;        
        ps.Due_Date__c = system.today();
        ps.Schedule_Number__c = '1';
        insert ps;

        Payment_Schedule__c ps2 = new Payment_Schedule__c();
        ps2.Payment_Plan__c = pp.ID;
        ps2.Amount__c = 100;
        ps2.Amount_W_O_Tax__c = 100;
        ps2.Due_Date__c = system.today().addDays(2);
        ps2.Schedule_Number__c = '2';
        ps2.Late_Payment_Interest_Amount__c = 100;
        insert ps2;  
        
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(pp);
            ApexPages.currentPage().getParameters().put('id',pp.ID);
            PaymentPlan_Controller objPartialPaymentPlanCtrl = new PaymentPlan_Controller(sc);

            objPartialPaymentPlanCtrl.acceptPaymentPlan();
            objPartialPaymentPlanCtrl.getCompanyName();    
            objPartialPaymentPlanCtrl.getNIF();  
            objPartialPaymentPlanCtrl.getStreet();
            objPartialPaymentPlanCtrl.getPostalCode();    
            objPartialPaymentPlanCtrl.getCity();  
            objPartialPaymentPlanCtrl.getFiador1Name();
            objPartialPaymentPlanCtrl.getFiador2Name();    
            objPartialPaymentPlanCtrl.getFiador1Street();  
            objPartialPaymentPlanCtrl.getFiador2Street();
            objPartialPaymentPlanCtrl.getFiador1PostalCode();    
            objPartialPaymentPlanCtrl.getFiador2PostalCode();  
            objPartialPaymentPlanCtrl.getFiador1NIF();  
            objPartialPaymentPlanCtrl.getFiador2City();
            objPartialPaymentPlanCtrl.getFiador2NIF();    
            objPartialPaymentPlanCtrl.getFiador1City();       
            objPartialPaymentPlanCtrl.getRentingApplicationList();  
            objPartialPaymentPlanCtrl.getSeparator();
            objPartialPaymentPlanCtrl.generatePDF();    
        
 			objPartialPaymentPlanCtrl.acceptPaymentPlan();
        Test.stopTest();        
    }    

}