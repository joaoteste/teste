@isTest(SeeAllData=true)
public with sharing class testnotifytrigger
{
    public static TestMethod void testNotifyDevices()
    {
        Notification__c n = new Notification__c (Message__c='Aprovado');
      //  n.Application__c='a012400000Lbf7KAAR';
      n.Application__c='a012400000NCxwo';
        upsert(n);
    }
}