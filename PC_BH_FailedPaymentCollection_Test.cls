@isTest
public class PC_BH_FailedPaymentCollection_Test {
    
    @isTest
    public static void test(){
        Payment_Collection__c pc = new Payment_Collection__c();
        Date lastYear = Date.newInstance(2016,10,10);
        pc.Expiry_Date__c = lastYear;
        pc.Status__c = 'In Payment';
        pc.Payment_Method__c = 'ATM Reference';
        insert pc;
        
        Test.startTest();
        Database.executeBatch(new PC_BH_FailedPaymentCollection(), 50);
        Test.stopTest();
        
                
        Payment_Collection__c pcUpdated = [SELECT ID, Status__c FROM Payment_Collection__c WHERE ID = :pc.ID];
        
        System.assertEquals('Unpaid',pcUpdated.Status__c);
    }

}