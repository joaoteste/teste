@isTest
private class CM_HitDateExpiration_BatchTest
{
	@isTest (seeAllData=true)
    static void testBatch(){
    	
    	Map<String, ID> datamap=new Map<String, ID>(CM_ContractManagementTest.setupCMS());
    	List<Injunction_Settings__mdt> InjuctionSettings = [SELECT Residual_Value_Prct__c FROM Injunction_Settings__mdt Limit 1];
			
    	Billing_Contract__c billContract  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c from Billing_Contract__c where id= :dataMap.get('BCId')];
    	Contract_management__c cmNewRec = New Contract_management__c(Billing_Contract__c=billContract.id,Account_Client__c=billContract.Account__c,	
		Account_Vendor__c=billContract.Account_Vendor__c,CMS_Status__c ='Open',  Hit_Date__c= system.today(), Residual_Value__c = InjuctionSettings[0].Residual_Value_Prct__c,
		Unpaid_Invoice_Amount__c = 0, Termination_Date__c=system.today(), offer_notification_contact__c=datamap.get('contactID'));	

		insert cmNewRec;	
		
        Test.startTest();
        
        DataBase.executeBatch(new CM_HitDateExpiration_Batch());
        
        Test.stopTest();    	
    } 	

    @isTest (seeAllData=true)
    static void testBatch_Sent(){
        
        Map<String, ID> datamap=new Map<String, ID>(CM_ContractManagementTest.setupCMS());
        List<Injunction_Settings__mdt> InjuctionSettings = [SELECT Residual_Value_Prct__c FROM Injunction_Settings__mdt Limit 1];
        Billing_Contract__c billContract  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c from Billing_Contract__c where id= :dataMap.get('BCId')];
        Contract_management__c cmNewRec = New Contract_management__c(Billing_Contract__c=billContract.id,Account_Client__c=billContract.Account__c, 
        Account_Vendor__c=billContract.Account_Vendor__c,CMS_Status__c ='Sent',  Hit_Date__c= system.today(), Residual_Value__c = InjuctionSettings[0].Residual_Value_Prct__c, Residual_Value_Amount__c=5000,
        Unpaid_Invoice_Amount__c=0, Termination_Date__c=system.today(), offer_notification_contact__c=datamap.get('contactID'));    

        insert cmNewRec;    
        
        Test.startTest();
        
        DataBase.executeBatch(new CM_HitDateExpiration_Batch());
        
        Test.stopTest();        
    }   

     @isTest (seeAllData=true)
    static void testBatch_Accepted(){
        
        Map<String, ID> datamap=new Map<String, ID>(CM_ContractManagementTest.setupCMS());
        List<Injunction_Settings__mdt> InjuctionSettings = [SELECT Residual_Value_Prct__c FROM Injunction_Settings__mdt Limit 1];
        Billing_Contract__c billContract  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c from Billing_Contract__c where id= :dataMap.get('BCId')];
        Contract_management__c cmNewRec = New Contract_management__c(Billing_Contract__c=billContract.id,Account_Client__c=billContract.Account__c, 
        Account_Vendor__c=billContract.Account_Vendor__c,CMS_Status__c ='Accepted',  Hit_Date__c= system.today(), Residual_Value__c = InjuctionSettings[0].Residual_Value_Prct__c, Residual_Value_Amount__c=5000,
        Unpaid_Invoice_Amount__c=0, Termination_Date__c=system.today(), offer_notification_contact__c=datamap.get('contactID'));    

        insert cmNewRec;    
        
        Test.startTest();
        
        DataBase.executeBatch(new CM_HitDateExpiration_Batch());
        
        Test.stopTest();        
    }  
}