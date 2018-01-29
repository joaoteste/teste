@isTest (SeeAllData=true)
public class test_ReminderUpdate {
    
    static testMethod void test_ReminderUpdate1(){
        Test.startTest();
        
        Account c = [Select id From Account where recordtype.developername = 'Account_Customer_Channel' limit 1];
        
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c =c.id;
        cc.Status__c = 'Open';
        
        insert cc;
        
        Dunning_Alert__c da = new Dunning_Alert__c();
        da.Collection_Case__c = cc.Id;
        da.Dunning_Level__c = ' 1st Reminder';
        da.Level__c = '1';
        da.Amount_Claimed__c = 10;
        da.Due_Date__c = system.today();
        da.Updated_Reminder__c = false;
        da.Updated_Date__c = date.today()-1;
        da.Updated__c = true;
        
        insert da;
        
        String cronExpr = '0 0 0 15 3 ? 2022'; 
        String jobId =  System.schedule('myJobTestJobName', cronExpr, new b_ReminderUpdate());  
        Test.stopTest();
    }
    
   
    
}