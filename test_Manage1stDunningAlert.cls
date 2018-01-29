@isTest  (SeeAllData=true)
public class test_Manage1stDunningAlert{
    
    static testMethod void test_Manage1stDunningAlert() {
        
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
        
        b_Manage1stDunningAlert b = new b_Manage1stDunningAlert(); 
        database.executebatch(b,1);   
        
        Test.stopTest();  
    }
    
}