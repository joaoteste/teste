@isTest (SeeAllData=true)
private class test_CountPastDays {
 static testMethod void test_CC_CountPastDays(){
        Test.startTest(); 
        
        Account c = [Select id From Account where recordtype.developername = 'Account_Customer_Channel' limit 1];
        
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c =c.id;
        cc.Status__c = 'Open';
        cc.Invoices_Due__c = 1;
        cc.Amount_Claimed__c =10;
        cc.Dunning_Enabled__c = false;
        cc.Flow__c = 'Automatic';
        
        insert cc;       
        
        String cronExpr = '0 0 0 15 3 ? 2022'; 
        String jobId =  System.schedule('myJobTestJobName', cronExpr, new b_CountPastDays());
        
        Test.stopTest(); 
    }
}