@isTest
private class CM_UpdPaymentCollection_BatchTest
{
	@isTest (seeAllData=true)
    static void testBatch(){
    	
    	Map<String, ID> datamap=new Map<String, ID>(CM_ContractManagementTest.setupCMS());

    	List<Injunction_Settings__mdt> InjuctionSettings = [SELECT Residual_Value_Prct__c FROM Injunction_Settings__mdt Limit 1];
		Set<Id> BillIds= new Set<ID>();	
		List<Contract_management__c> cmList= new List<Contract_management__c> ();
    	Billing_Contract__c billContract  =  [select name, Next_Invoice_Date__c, account__c,Account_Vendor__c from Billing_Contract__c where id= :dataMap.get('BCId')];
    	BillIds.add(billContract.id);
    	Contract_management__c cmNewRec = New Contract_management__c(Billing_Contract__c=billContract.id,Account_Client__c=billContract.Account__c,	
		Account_Vendor__c=billContract.Account_Vendor__c,CMS_Status__c ='Accepted',  Hit_Date__c= system.today(), Residual_Value__c = InjuctionSettings[0].Residual_Value_Prct__c,
		Termination_Date__c=system.today(), offer_notification_contact__c=datamap.get('contactID'), residual_value_amount__c = 1250.00, sales_invoice__c=null );	

		insert cmNewRec;	
		cmList.add(cmNewRec);
		ATM_Reference__c atm = New ATM_Reference__c();
		insert atm;
		CM_ContractManagement CM = new CM_ContractManagement();
		CM.CreateSalesInvoice( BillIds , cmList);
		Contract_management__c CMrec=[select name, sales_invoice__c from contract_management__c where id = :cmNewRec.id];

		c2g__codaInvoice__c salesInv=[select id, first_atm__c, billing_contract__c from c2g__codaInvoice__c where id =: cmRec.sales_invoice__c];

        salesInv.first_atm__c=atm.id;
        update salesInv;
        Test.startTest();
        
        DataBase.executeBatch(new CM_UpdPaymentCollection_Batch());
        
        Test.stopTest();    	
    } 	
}