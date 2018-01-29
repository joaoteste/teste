//Test Class: CreateDueSalesInvoicesTest
global class BILL_BH_CreateDueSalesInvoices implements Database.Batchable<sObject>, Database.Stateful {
	// This variable is used when when we want to launch the batch manually in a more 'safe'way 
	global final Integer queryLimit;

	public BILL_BH_CreateDueSalesInvoices(Integer queryLimit){
		this.queryLimit = queryLimit;

        
        List<Billing_Contract__c> billContList=[select id from Billing_contract__c where id in (select  Billing_contract__c from Billing_Contract_Line_Item__c 
                                                                                            where Ready_to_Invoice__c=true and Invoiced__c!=true) AND BC_Contract_Inactive__c = FALSE]; /*AND aux_queued__c = FALSE*/
        
        list<ID> listbillids=new List<ID>();         
        for( Billing_Contract__c bill :billContList){
            listbillids.add(bill.id);
        } 
        List<Billing_Contract_Line_Item__c> salesinvoicedue=[select id, name, Line_Item_Start_Date__c,  Line_Item_End_Date__c, Billing_contract__c from Billing_Contract_Line_Item__c 
                                                             where Ready_to_Invoice__c=true and Invoiced__c!=true and Billing_contract__c in :listbillids order by Billing_contract__c];
        system.debug(salesinvoicedue);
        system.debug(billContList);
  
   //key=Billing_Contract__c id
        Map<Id, Billing_Contract_Line_Item__c> billinContractLineItemMap = new Map<Id, Billing_Contract_Line_Item__c>();
        for(Billing_Contract_Line_Item__c billContractLineItem : salesinvoicedue){
        	billinContractLineItemMap.put(billContractLineItem.Billing_contract__c , billContractLineItem);
        }

        List <Billing_Contract__c> billsToUpd = new List<Billing_Contract__c>();
        for(Billing_Contract__c billContract : billContList){
        	Billing_Contract_Line_Item__c auxBilingCLI = billinContractLineItemMap.get(billContract.id);
        	billContract.Aux_Due_Date__c = auxBilingCLI.Line_Item_End_Date__c;
            billContract.Aux_Invoice_Date__c = auxBilingCLI.Line_Item_Start_Date__c;
            billsToUpd.add(billContract);
        }

        update billsToUpd;
        

/*    
        // Old code to delete if the new code work 
        List<Billing_Contract__c> BillCont=[select id from Billing_contract__c where id in (select  Billing_contract__c from Billing_Contract_Line_Item__c 
                                                                                            where Ready_to_Invoice__c='Yes' and Invoiced__c!=true) AND BC_Contract_Inactive__c = FALSE AND aux_queued__c = FALSE];
        
        list<ID> listbillids=new List<ID>();         
        for( Billing_Contract__c bill :BillCont){
            listbillids.add(bill.id);
        } 
        List<Billing_Contract_Line_Item__c> salesinvoicedue=[select id, name, Line_Item_Start_Date__c,  Line_Item_End_Date__c, Billing_contract__c from Billing_Contract_Line_Item__c 
                                                             where Ready_to_Invoice__c='Yes' and Invoiced__c!=true and Billing_contract__c in :listbillids order by Billing_contract__c];
        system.debug(salesinvoicedue);
        system.debug(BillCont);
        
        List<Billing_Contract__c> updlistBill=New List<Billing_Contract__c>();
        for( Billing_Contract__c bill :BillCont){
            for (integer i=0; i< salesinvoicedue.size(); i++){
                if(salesinvoicedue[i].Billing_contract__C == bill.id){
                    bill.Aux_Due_Date__c = salesinvoicedue[i].Line_Item_End_Date__c;
                    bill.Aux_Invoice_Date__c = salesinvoicedue[i].Line_Item_Start_Date__c;
                    updlistBill.add(bill);
                } 
            }
        }
        Set<Billing_Contract__c> setdistinctBillIds = new set<Billing_Contract__c>();
        setdistinctBillIds.addall(updlistBill);
        List <Billing_Contract__c> billsToUpd=New List<Billing_Contract__c>(setdistinctBillIds);
        
        update billsToUpd;
        
        Set<Id> BillIds = new Map<Id, SObject>(billsToUpd).keySet();
        List<ID> listIDs = new List<ID>(BillIds);
        List<ID> listBCQueued = new List<ID>();
        //Verificar se tem menos de 15 registos, pois existe um imite de 50 queueables chamados numa mesma transação.
        //Caso existam mais é calendarizado outro job. 
        System.debug('[CreateDueSalesInvoices] ' + listIDs.size() + ' left to create sales invoice from billing contracts.');
        Utilities.LogIntegration(datetime.now(), datetime.now(), 'running','CreateDueSalesInvoices - Schedulable', listIDs.size() + ' left to create sales invoice from billing contracts.', '-' );
 */       
	}
	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	 	    
   	    String query = 'SELECT id FROM Billing_contract__c ' + 
                                ' WHERE id IN (SELECT  Billing_contract__c from Billing_Contract_Line_Item__c WHERE Ready_to_Invoice__c= true and Invoiced__c!=true) AND BC_Contract_Inactive__c = FALSE' ;
        
        if(this.queryLimit != 0 && !Test.isRunningTest() ){
        	query = query + ' Limit ' + this.queryLimit;
        }
        else if(Test.isRunningTest()){
        	query = query + ' Limit 1';
        }
 
        system.debug('BILL_BH_CreateDueSalesInvoices query' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Billing_Contract__c> billingContractList){
    	//TODO chamar o mesmo código que a Queue, mas não chamar a queue (está a dar erro ???).
    	//TODO O tamanho do batch tem de ser 1. demora muito tempo mas tem de ser porque se não o moloni funciona mal :-(
        system.debug('BILL_BH_CreateDueSalesInvoices billingContractList' + billingContractList);
        Set<ID> billContratSet = new Set<ID>();
        for(Billing_Contract__c billContract : billingContractList){
    		//ID jobID = System.enqueueJob(new Queueable_Create_due_sales_invoice(billContract.Id));
            billContratSet.add(billContract.Id);
        }
        BILL_BillingProcess.billlingToSIN(billContratSet);

    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}

// TODO aux_queued__c no biling contract pode ser apagado