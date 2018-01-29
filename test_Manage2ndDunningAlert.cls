@isTest  (SeeAllData=true)
public class test_Manage2ndDunningAlert{
    
    static testMethod void test_Manage2ndDunningAlert() {
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
        
        insert listdalerts;
        
        b_Manage2ndDunningAlert b2 = new b_Manage2ndDunningAlert(); 
        database.executebatch(b2,1);  
        
        Test.stopTest();
        
    }
}