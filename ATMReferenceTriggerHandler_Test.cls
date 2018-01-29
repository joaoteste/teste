@isTest(SeeAllData=True)
public class ATMReferenceTriggerHandler_Test {

    @isTest
    public static void testTrigger(){
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
        pp.Collection_Case__c = infoMap.get('ccID');
        insert pp;
        


		ATM_Reference__c atm = new ATM_Reference__c();
        atm.MB_Payment_Status__c = 'Not Payed';
        atm.Amount__c = 100;
        atm.Entity__c = 10611;
        atm.MB_Reference__c = 100100100;
        atm.ATM_Reference__c = '100100100';
        insert atm; 
        
        Payment_Schedule__c ps = new Payment_Schedule__c();
        ps.Payment_Plan__c = pp.ID;
        ps.Amount__c = 100;
        ps.Fees_Amount__c = 20;
        ps.Amount_W_O_Tax__c = 100;
        ps.Due_Date__c = system.today();
        ps.ATM__c = atm.ID;
        ps.Schedule_Number__c = '1';
        insert ps;        
        
        atm.MB_Payment_Status__c = 'Paid';
        
        update atm;
        
        
    }
    
}