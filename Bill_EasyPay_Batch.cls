global class Bill_EasyPay_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    global final ID period; 
    global final Map<ID,List<Map<c2g__codaInvoice__c, Double>>> atmToSalesMap;
    global final Map<ID, c2g__codaJournal__c> atmToJournalsMap;
    global final Account easyPayAccount;  
    global final Credentials__c credential;
	global final Credentials__c credentialMoloni;
    
    
    public Bill_EasyPay_Batch(Map<ID,List<Map<c2g__codaInvoice__c, Double>>> atmToSalesMap, Map<ID, c2g__codaJournal__c> atmToJournalsMap, ID period, Account easyPayAccount){
        this.atmToSalesMap = atmToSalesMap;
        this.atmToJournalsMap = atmToJournalsMap;        
        this.period = period;
        this.easyPayAccount = easyPayAccount;
        credential = Credentials__c.getInstance('EasyPay');
    }
    
    
	global Database.QueryLocator start(Database.BatchableContext BC){ 
		
        List<ID> atmRefIDs = new List<ID>();
        atmRefIDs.addAll(atmToSalesMap.keySet());

        String query = 'SELECT Id , MB_Reference__c, Amount__c, Payment_Collection__c FROM ATM_Reference__c WHERE ID in :atmRefIDs';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ATM_Reference__c> atmList){
        Map<c2g__codaTransactionLineItem__c, Double> transactionsForAtmMap;
        List<Outbound_Integration_Log__c> problems = new List<Outbound_Integration_Log__c>();
        
        for(ATM_Reference__c atm : atmList){
        	   	
            Savepoint sp = Database.setSavepoint();
            c2g__codaInvoice__c salesInvoice;
            try{
            	//update atm with Journal
            	c2g__codaJournal__c journal = atmToJournalsMap.get(atm.ID);
            	atm.Journal__c = journal.ID;
            	update atm;            	
            	
                //post journal
                system.debug(atmToJournalsMap);
                system.debug(atm.ID);
                system.debug(journal);
                postJournal(journal);
                
                //get transanctions line items for sales invoices
                system.debug(atmToSalesMap.get(atm.Id));
                transactionsForAtmMap = getTransactionsLineItemsForSalesInvoices(atmToSalesMap.get(atm.Id));
                system.debug(transactionsForAtmMap);
                
                //get and add transactions line items for journal
                getTransactionLineItemForJournal(atmToJournalsMap.get(atm.Id), transactionsForAtmMap);
                system.debug(atmToJournalsMap.get(atm.Id));
                system.debug(transactionsForAtmMap);
                
                salesInvoice =  (new List<c2g__codaInvoice__c>(atmToSalesMap.get(atm.ID).get(0).keySet())).get(0);
                             
                List<Collection_Case__c> cCase = [SELECT ID, Status__c, Amount_Claimed__c FROM Collection_Case__c WHERE ID = :salesInvoice.Collection_Case__c];
                system.debug(cCase);
                system.debug('Close Collection Case');
                
                //close Payment Collection
                if(atm.Payment_Collection__c != null){
                    
                   system.debug('closing payment collection');
                   Payment_Collection__c pc = [SELECT ID, Status__c 
                                               FROM Payment_Collection__c 
                                               WHERE ID = :atm.Payment_Collection__c];
                    pc.Status__c = 'Paid';
                    update pc;
                    system.debug(pc);
                }
                
                List<Partial_Invoice_Payment__c> pipList = [SELECT ID, Payment_Schedule__r.isLast__C, 
                                                            Payment_Schedule__r.Payment_Plan__c,Payment_Schedule__r.Payment_Plan__r.Renting_Application__c 
                                                            FROM Partial_Invoice_Payment__c 
                                                            WHERE Sales_Invoice__c = :salesInvoice.ID ORDER BY CreatedDate desc];
                if(pipList != null && !pipList.isEmpty() && pipList[0].Payment_Schedule__r.isLast__C == true){
                    Partial_Invoice_Payment__c pip = pipList[0];
                    Payment_Plan__c pp = new Payment_Plan__c();
                    pp.ID = pip.Payment_Schedule__r.Payment_Plan__c;
                    pp.Status__c = 'Closed';
                    update pp;
                    
                    //Alteracão PC 2017-12-06 change sub-status Billing Contract
                    List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id, Name, c2g__InvoiceTotal__c, Billing_Contract__c, Application__c
                                                                  FROM c2g__codaInvoice__c
                                                                  WHERE  (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid' ) AND Collection_Case__c =: [Select Id,Collection_Case__c 
                                                                                                                                                                               From Payment_Plan__c 
                                                                                                                                                                               where id = :pp.id].Collection_Case__c 
                                                                  ORDER BY CreatedDate ASC];
                    
                    Set<Billing_Contract__c> billContractToUpdate = new Set<Billing_Contract__c>();
                    for(c2g__codaInvoice__c sin :salesInvoiceList){
			    if(sin.Billing_Contract__c != null){
				Billing_Contract__c billingContract = new Billing_Contract__c();
				billingContract.id = sin.Billing_Contract__c;
				billingContract.Contract_Sub_Status__c = '';
				billContractToUpdate.add(billingContract);
			    }
                    }
                    
                    if(!billContractToUpdate.isEmpty()){
                        List<Billing_Contract__c> bcToUpdateList = new List<Billing_Contract__c>();
                        bcToUpdateList.addAll(billContractToUpdate);
                        update bcToUpdateList;                
                    }
                }
                
                //if collection case exists
                if(cCase != null && cCase.size() != 0 && pipList.isEmpty()){
                	AggregateResult[] groupedResults = [select sum(c2g__OutstandingValue__c)total FROM c2g__codaInvoice__c WHERE Collection_Case__c = :cCase[0].ID];
					Double amount = Double.valueOf(groupedResults[0].get('total'));		
					system.debug('amount: '+amount+' '+atm.Amount__c);
					system.debug(Logginglevel.ERROR,Double.valueOf(amount) == Double.valueOf(atm.Amount__c));
					
                	if(Double.valueOf(amount) == Double.valueOf(atm.Amount__c)){ 
	                    //close collection case
	                    Collection_Case__c cCaseSpec = cCase.get(0);
	                    cCaseSpec.Status__c = 'Closed';
	                    system.debug('closing CC');
	                    system.debug(Logginglevel.ERROR,Limits.getQueries());
	                    update cCaseSpec;
	                    system.debug(Logginglevel.ERROR,Limits.getQueries());
	                    system.debug('collection case closed');
	                    //close dunning alert
			    
	                    List<Dunning_Alert__c> dAlert = new List<Dunning_Alert__c>([SELECT ID, Collection_Case__c, Status__c FROM Dunning_Alert__c WHERE Collection_Case__c = :cCaseSpec.Id AND Status__c = 'Open']);
	                    if(dAlert!=null && !dAlert.isEmpty()){
				    	system.debug(dAlert[0]);
				    	dAlert[0].Status__c= 'Close';
				    	update dAlert[0];
			    	}
	                    
                }else{
                		Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Code__c = 'EASYPAY',
                                                                                    ApplicationID__c = 'CLIENT: ' + salesInvoice.c2g__Account__c + ' MB-REFERENCE: ' + atm.MB_Reference__c,
                                                                                    Status__c = 'WARNING',
                                                                                    message__c = ' Foi paga uma referência com valor diferente do Collection Case. Requer verificação.'
                                                                                    );
                		problems.add(record);
                		system.debug(record);       
                	}
                }                
                system.debug(Logginglevel.ERROR,Limits.getQueries());
                //do match
                FF_Utils.doMatchWithPartial(salesInvoice.c2g__Account__c, period, transactionsForAtmMap);
                system.debug('Match done');                    
                system.debug(Logginglevel.ERROR,Limits.getQueries());
                system.debug('batch completed');
                
            } catch(Exception e){
                //if match failed an email is sent after the outbound integration log is created
                Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Code__c = 'EASYPAY',printStackTrace__c = e.getStackTraceString(),
                                                                                    ApplicationID__c = 'CLIENT: ' + salesInvoice.c2g__Account__c + ' MB-REFERENCE: ' + atm.MB_Reference__c,
                                                                                    message__c = e.getMessage(), Response__c = 'BATCH'
                                                                                    );
                problems.add(record);
                Database.rollback(sp);      
            }
        }
        
        insert problems;
    	
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    //post a single journal
    private void postJournal(c2g__codaJournal__c journal){
        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
        ref.Id = journal.Id;
        c2g.CODAAPIJournal_9_0.PostJournal(null, ref);        
    }
    
    //get all transactions line items associated to each sales invoices
    private Map<c2g__codaTransactionLineItem__c, Double> getTransactionsLineItemsForSalesInvoices(List<Map<c2g__codaInvoice__c, Double>> salesInvoiceMap){
        
       Map<c2g__codaTransactionLineItem__c, Double> transLItemsToAmountMap = new Map<c2g__codaTransactionLineItem__c, Double>();

       Map<ID, Double> documentRefsMap= new Map<ID, Double>();

       for(Map<c2g__codaInvoice__c, Double> siToAmount : salesInvoiceMap){
        	documentRefsMap.put((new List<c2g__codaInvoice__c>(siToAmount.keySet())).get(0).c2g__Transaction__c, siToAmount.get((new List<c2g__codaInvoice__c>(siToAmount.keySet())).get(0)));
       }
		system.debug(LoggingLevel.Info, salesInvoiceMap);
       
		List<c2g__codaTransactionLineItem__c> transactionLinesItemsList = [
            SELECT Id, c2g__AccountValue__c, c2g__Transaction__c
            FROM c2g__codaTransactionLineItem__c
            WHERE
                 c2g__Transaction__c in :documentRefsMap.keySet()
                 AND c2g__LineType__c = 'Account'
         ];

         for(c2g__codaTransactionLineItem__c transLineItem : transactionLinesItemsList){
             transLItemsToAmountMap.put(transLineItem, documentRefsMap.get(transLineItem.c2g__Transaction__c));
         }
		
        return transLItemsToAmountMap;
    }
    
    
    //gets the transaction line item associated to a specific journal
    private void getTransactionLineItemForJournal(c2g__codaJournal__c journal, Map<c2g__codaTransactionLineItem__c, Double> transactionToAmountMap){
        
        //get journal updated
    	c2g__codaJournal__c journalUpdated = [SELECT ID, c2g__Reference__c, c2g__Transaction__c, c2g__Credits__c  FROM c2g__codaJournal__c WHERE ID = :journal.ID];
        
        system.debug(journalUpdated);
        
        c2g__codaTransactionLineItem__c transactionLineItem = [
            SELECT Id, c2g__AccountValue__c, c2g__Account__c, c2g__Transaction__c
            FROM c2g__codaTransactionLineItem__c
            WHERE
                 c2g__Transaction__c = :journalUpdated.c2g__Transaction__c
                 AND c2g__LineType__c = 'Account'
            	 AND c2g__Account__c != :easyPayAccount.Id
         ];
        
        transactionToAmountMap.put(transactionLineItem, journalUpdated.c2g__Credits__c);       
        
    }    
  
    
}