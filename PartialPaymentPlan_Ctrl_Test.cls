/**

Author   |Date  | Comments
Vinod    |09/25/2017 | Initial Creation primary test class PartialPaymentPlan_Ctrl

**/
@isTest(SeeAllData = true)
public class PartialPaymentPlan_Ctrl_Test {
   
    
    @isTest 
    public static void testPartialPayment(){
		RentingApplication_Util_Test rentUtils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rentUtils.environment1();
        Collection_Case__c cc = new Collection_Case__c(ID = infoMap.get('ccID'));
        Contact cont = new Contact();
        cont.AccountId = infoMap.get('client');
        cont.Email = 'test@test.pt';
        cont.LastName = 'Test';
        cont.Phone = '915229100';
        insert cont;
        
        system.debug(Limits.getQueries());
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(cc);
        ApexPages.currentPage().getParameters().put('id',cc.ID);
        PartialPaymentPlan_Ctrl objPartialPaymentPlanCtrl = new PartialPaymentPlan_Ctrl(sc);
        objPartialPaymentPlanCtrl.objPaymentPlan.Frequency__c = 'Manual';
        objPartialPaymentPlanCtrl.objPaymentPlan.Number_Of_Payments__c = '3';
		objPartialPaymentPlanCtrl.objPaymentPlan.Contact__c = cont.ID;
        //objPartialPaymentPlanCtrl.payScheduleList[0].Amount__c = 10
        objPartialPaymentPlanCtrl.calculateFeesAmount();       
        objPartialPaymentPlanCtrl.updateDate();
        //objPartialPaymentPlanCtrl.recalculatePaymentSchedule();        
        objPartialPaymentPlanCtrl.savePaymentPlan();
        Test.stopTest();
        
        
    }
    
    @isTest 
    public static void testFullPayment(){
		RentingApplication_Util_Test rentUtils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rentUtils.environment1();
        Collection_Case__c cc = new Collection_Case__c(ID = infoMap.get('ccID'));
        Contact cont = new Contact();
        cont.AccountId = infoMap.get('client');
        cont.Email = 'test@test.pt';
        cont.LastName = 'Test';
        cont.Phone = '915229100';
        insert cont;
        
        system.debug(Limits.getQueries());
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(cc);
        ApexPages.currentPage().getParameters().put('id',cc.ID);
        PartialPaymentPlan_Ctrl objPartialPaymentPlanCtrl = new PartialPaymentPlan_Ctrl(sc);
        objPartialPaymentPlanCtrl.objPaymentPlan.Type__c = 'Full';
		objPartialPaymentPlanCtrl.objPaymentPlan.Contact__c = cont.ID;
		objPartialPaymentPlanCtrl.objPaymentPlan.Signer_1__c = cont.ID;    
		objPartialPaymentPlanCtrl.objPaymentPlan.Extension_Term_Months__c = '12';            
        //objPartialPaymentPlanCtrl.payScheduleList[0].Amount__c = 10
        objPartialPaymentPlanCtrl.changePaymentPlanType();
        objPartialPaymentPlanCtrl.calculateFullPaymentPlan();
        objPartialPaymentPlanCtrl.savePaymentPlan();
        Test.stopTest();		
    }    
    
 	@isTest 
    public static void testFullPaymentInitialPayment(){
		RentingApplication_Util_Test rentUtils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rentUtils.environment1();
        Collection_Case__c cc = new Collection_Case__c(ID = infoMap.get('ccID'));
        Contact cont = new Contact();
        cont.AccountId = infoMap.get('client');
        cont.Email = 'test@test.pt';
        cont.LastName = 'Test';
        cont.Phone = '915229100';
        insert cont;
        
        system.debug(Limits.getQueries());
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(cc);
        ApexPages.currentPage().getParameters().put('id',cc.ID);
        PartialPaymentPlan_Ctrl objPartialPaymentPlanCtrl = new PartialPaymentPlan_Ctrl(sc);
        objPartialPaymentPlanCtrl.objPaymentPlan.Type__c = 'Full';
		objPartialPaymentPlanCtrl.objPaymentPlan.Contact__c = cont.ID;
		objPartialPaymentPlanCtrl.objPaymentPlan.Signer_1__c = cont.ID;    
		objPartialPaymentPlanCtrl.objPaymentPlan.Extension_Term_Months__c = '12';        
		objPartialPaymentPlanCtrl.objPaymentPlan.Initial_Payment__c = 20;                
        //objPartialPaymentPlanCtrl.payScheduleList[0].Amount__c = 10
        objPartialPaymentPlanCtrl.changePaymentPlanType();
        objPartialPaymentPlanCtrl.calculateFullPaymentPlan();
        objPartialPaymentPlanCtrl.savePaymentPlan();
        Test.stopTest();		
    }        
    
}