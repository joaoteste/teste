@isTest(SeeAllData=true)
public class testManagedCreditLine {
    public static testMethod void testUpdateCreditLine(){
        //string appId='a012400000Lbf7KAAR';
        
        string appId='a012400000NCxwo';

        Application__c app = [SELECT Id, Name, AccClient__c
                              FROM   Application__c
                              WHERE  Id=:appId];
        
        ManagedCreditLine.updateCreditLine ( app );
    }    
}