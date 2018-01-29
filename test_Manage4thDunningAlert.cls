@isTest (SeeAllData=true)
public class test_Manage4thDunningAlert{
    
    static testMethod void test_Manage4thDunningAlert() {
           
        Test.startTest();
        
        Account c = [Select id From Account where recordtype.developername = 'Account_Customer_Channel' limit 1];
        
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c =c.id;
        cc.Status__c = 'Open';
        cc.Invoices_Due__c = 1;
        cc.Amount_Claimed__c =10;
        cc.Dunning_Enabled__c = false;
        cc.Flow__c = 'Automatic';
        //cc.Count_Dunning_Alert__c = 3;
        
        insert cc;
        
        List<Dunning_Alert__c> listdalerts = new List<Dunning_Alert__c>();
        
        Dunning_Alert__c da = new Dunning_Alert__c();
        da.Dunning_Level__c = '1st Reminder';
        da.Level__c = '1';
        da.Status__c= 'Open';
        da.Collection_Case__c = cc.Id;
        da.Sent_Date__c = date.today().addDays(-1);
        da.Due_Date__c = date.today().addDays(10);
        listdalerts.add(da);  
        
        Dunning_Alert__c da2 = new Dunning_Alert__c(); 
        da2.Dunning_Level__c = '2nd Reminder';
        da2.Level__c = '2';
        da2.Status__c= 'Open';
        da2.Collection_Case__c = cc.Id;
        da2.Sent_Date__c = date.today().addDays(-1);
        da2.Due_Date__c = date.today().addDays(10);
        listdalerts.add(da2);  
        
        Dunning_Alert__c da3 = new Dunning_Alert__c();
        da3.Collection_Case__c = cc.Id;
        da3.Status__c = 'Open';
        da3.Dunning_Level__c = '3rd Reminder';
        da3.Level__c = '3';
        da3.Amount_Claimed__c = 10;
        da3.Due_Date__c = system.today();
        da3.Updated_Reminder__c = false;
        da3.Updated_Date__c = date.today()-1;
        da3.Updated__c = true;
        da3.Sent_Date__c = system.today();
        //da3.Total_Interest_Charges__c = 1;  
        listdalerts.add(da3);
        
        insert listdalerts;
        
        
        String cronExpr = '0 0 0 15 3 ? 2022'; 
        String jobId =  System.schedule('myJobTestJobName', cronExpr, new b_Manage4thDunningAlert());  
        
        Test.stopTest();
    }
    
}