@isTest
public class Trigger_ACFinalizePayment_Test {

    @isTest
    public static void testPC(){
        Payment_Collection__c pc = new Payment_Collection__c();
        AssignmentContract__c ac = new AssignmentContract__c();
        ac.TypeOfAssignContract__c ='Merged Company';
        //c.Amount__c = 120.0;  
        pc.Status__c = 'Paid';
        insert pc;
        ac.Payment_Collection__c = pc.ID;
        insert ac;
        //pc.Amount__c = 121.0;
        update pc;        
    }
}