//Test: BILL_Deferred_Journals_Test
global class SalesInvoiceTriggerHandler extends TriggerHandler{
    
    public SalesInvoiceTriggerHandler() {
        
    }   
    
    /**************************************************************************************************/
    /*                                      CONTEXT OVERRIDES                                         */
    /**************************************************************************************************/
    
    public static void  afterInsert(List<c2g__codaInvoice__c> newSaleInvoiceList){
    	Set<ID> accountSet = new Set<ID>();
    	for(c2g__codaInvoice__c sin : newSaleInvoiceList){
    		accountSet.add(sin.c2g__Account__c);
    	}
    	numberRentInvoiceDue(accountSet);
    	
    	//if a SIN gets associated with a CC create corresponding collection sales invoice
    	List<Collection_Sales_Invoice__c> toInsert = new List<Collection_Sales_Invoice__c>();
        for(c2g__codaInvoice__c inv : newSaleInvoiceList){
        	if(inv.Collection_Case__c != null){
        		Collection_Sales_Invoice__c aux = new Collection_Sales_Invoice__c();
        		aux.Account__c = inv.c2g__Account__c;
        		aux.Period__c = inv.c2g__Period__c;
        		aux.Collection_Case__c = inv.Collection_Case__c;
        		aux.Sales_Invoice__c = inv.Id;
        		toInsert.add(aux);
        	}
        }
        
        insert toInsert;
    }
    
    public static void beforeUpdate(Map<Id,c2g__codaInvoice__c> oldMap, Map<Id,c2g__codaInvoice__c> newMap){
    	//if a SIN gets associated with a CC create corresponding collection sales invoice
    	//if a SIN gets removed from a CC remove corresponding colection sales invoice
    	List<Collection_Sales_Invoice__c> toInsert = new List<Collection_Sales_Invoice__c>();
    	List<Id> removedInvoices = new List<Id>();
    	
    	for(c2g__codaInvoice__c newInv : newMap.values()){
    		c2g__codaInvoice__c oldInv = oldMap.get(newInv.Id);
    		if(oldInv.Collection_Case__c == null && newInv.Collection_Case__c != null){
    			Collection_Sales_Invoice__c aux = new Collection_Sales_Invoice__c();
        		aux.Account__c = newInv.c2g__Account__c;
        		aux.Period__c = newInv.c2g__Period__c;
        		aux.Collection_Case__c = newInv.Collection_Case__c;
        		aux.Sales_Invoice__c = newInv.Id;
        		toInsert.add(aux);
    		}
    		if(oldInv.Collection_Case__c != null && newInv.Collection_Case__c == null){
    			removedInvoices.add(newInv.Id);
    		}
    	}
    	
    	List<Collection_Sales_Invoice__c> toRemoveCSINS = [SELECT Id FROM Collection_Sales_Invoice__c WHERE Sales_Invoice__c IN :removedInvoices];
    	
    	insert toInsert;
    	delete toRemoveCSINS;
    }
    
    public static void afterUpdateTrigger(List<c2g__codaInvoice__c> newSaleInvoiceList, List<c2g__codaInvoice__c> oldSaleInvoiceList){  
    	
        System.debug('SIN afterUpdateTrigger');
        // Set<Id> newids=new Set<Id>();
        List<c2g__codaInvoice__c> updinv=new  List<c2g__codaInvoice__c>();
        List<c2g.CODAAPICommon.Reference> refsinv = new List<c2g.CODAAPICommon.Reference>();

        Set<ID> accountToNumberRentInvoiceSet = new Set<ID>();        
        Set<ID> accountIDSet = new Set<ID>();
        Set<Id> turnedToCompletedIDs = new Set<Id>();
        
        Set<Id> turnedToPaidIDs = new Set<Id>();

       
        Map<Id,c2g__codaInvoice__c> oldSaleInvoiceMap= new Map<Id,c2g__codaInvoice__c>();
        for(c2g__codaInvoice__c saleInvoice :oldSaleInvoiceList){
            oldSaleInvoiceMap.put(saleInvoice.id, saleInvoice);
        }
        
        for( c2g__codaInvoice__c newid: newSaleInvoiceList ){
            c2g__codaInvoice__c oldSaleInvoice = oldSaleInvoiceMap.get(newid.Id);
            if((oldSaleInvoice.c2g__InvoiceStatus__c != 'Complete' && newid.c2g__InvoiceStatus__c == 'Complete' )||(Test.isRunningTest())){
                //if( newid.c2g__InvoiceStatus__c == 'Complete' ){//Test in preprod
                accountIDSet.add(newid.c2g__Account__c);
                turnedToCompletedIDs.add(newid.id); 
            }
            if( oldSaleInvoice.c2g__PaymentStatus__c != 'Paid' && newid.c2g__PaymentStatus__c == 'Paid' ){
                turnedToPaidIDs.add(newid.id); 
            }
          
            if((oldSaleInvoice.c2g__PaymentStatus__c != 'Paid' &&  newid.c2g__PaymentStatus__c == 'Paid') 
            || (oldSaleInvoice.c2g__PaymentStatus__c == 'Not Applicable' && (newid.c2g__PaymentStatus__c == 'Unpaid' || newid.c2g__PaymentStatus__c == 'Part Paid'))
            ){
            	accountToNumberRentInvoiceSet.add(newid.c2g__account__c);
            }
            
            if( (oldSaleInvoice.Post_SalesInvoice__c!= true && newid.Post_SalesInvoice__c ==true) 
               || (oldSaleInvoice.Posted_InvoiceXpress__c != true && newid.Posted_InvoiceXpress__c == true) /*|| (Test.isRunningTest())*/){
                   futureQueueCreateInvoiceExtApp(newid.id);
                   //TODO veridicar se está ok        
                   //        newids.add(newid.id); 
                   if(newid.c2g__InvoiceStatus__c != 'Complete'){ 
                       c2g.CODAAPICommon.Reference refinv = new c2g.CODAAPICommon.Reference();
                       refinv.id = newid.id;
                       refsinv.add(refinv); 
                   }
               }
        }
        
        // This code was move to after the creation of moloni, because there         
        //        if(turnedToCompletedIDs.size() >= 0){
        //            SEPA_SI_to_SR.createPaymentCollectionWithSEPAFromSalesInvoice(turnedToCompletedIDs); 
        //        }
        
        if(turnedToPaidIDs.size() >= 0){
            //Adicionar notas de credito que possam existir de facturas pagas    
            Set<Id> scnIds = (new Map<Id,SObject>([SELECT Id
                                                   FROM c2g__codaCreditNote__c
                                                   WHERE
                                                   c2g__Invoice__c IN :turnedToCompletedIDs
                                                  ])).keySet();
            
            if(scnIds.size() > 0){
                SEPA_SCN_to_SR.addSRFromSCNs(scnIds);   
            }  
        }  
       
           
        
        if(!accountIDSet.isEmpty()){
            //updateUsedCreditLine(accountIDSet);
        }
        
        if(!accountToNumberRentInvoiceSet.isEmpty()){
        	numberRentInvoiceDue(accountToNumberRentInvoiceSet);
        }
        
        // post invoice if due
        if(refsinv.size()>0 && !test.isRunningTest()){            
            c2g.CODAAPISalesInvoice_6_0.BulkPostInvoice(null, refsinv);
        }
        /*
} catch( exception e){
system.debug('Exception:' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() + e.getStackTraceString());
}*/  
        
    }
    /*
    private static void updateUsedCreditLine(Set<ID> accountIDList){
        
        Map<Id,Account> accToUpdateMap = new Map<Id,Account>([SELECT Used_Credit_line__c, Available_Credit_Line__c, Credit_line__c
                                                              FROM Account
                                                              WHERE id IN :accountIDList]);
        
        AggregateResult[] groupedResults = [SELECT SUM(Current_Balance__c)usedCreditLine,Account__c 
                                            FROM Billing_Contract__c 
                                            Where Application__r.Status__c = 'Contract - Running' and Account__c in :accountIDList
                                            group by Account__c];
        
        for(AggregateResult result : groupedResults){
            Id accountId = (ID) result.get('Account__c');
            Decimal usedCreditLine = (Decimal) result.get('usedCreditLine');
            accToUpdateMap.get(accountId).Used_Credit_line__c = usedCreditLine;
            
            Decimal availableCreditLine=accToUpdateMap.get(accountId).Credit_line__c - usedCreditLine;
            if(availableCreditLine<= 0){
                accToUpdateMap.get(accountId).Available_Credit_Line__c = 0;
            }else{
                accToUpdateMap.get(accountId).Available_Credit_Line__c = availableCreditLine;
            }
            
        }       
        
        update accToUpdateMap.values();
    }
    */
    private static void futureQueueCreateInvoiceExtApp(id saleInvoiceID){
        /*Set<Id> invoiceIdSet = New Set<Id>();
        invoiceIdSet.add( saleInvoiceID );
        SEPA_SI_to_SR.createPaymentCollectionWithSEPAFromSalesInvoice(invoiceIdSet);*/
        System.enqueueJob(new BILL_QE_CreateInvoiceExtApp(saleInvoiceID));
    }
    
    public static void numberRentInvoiceDue(Set<id> accIDSet){
        List<Account> accToUpdate = new List<Account>();
        List<String> products = new List<String>{'PT01','PT08','PT09','PT10','PT18','PT19'};
            
            Map<Id,AggregateResult> invoiceItemMap = new Map<Id,AggregateResult>([Select c2g__Invoice__r.c2g__Account__c Id,count(c2g__Invoice__c) cnt
                                                                                  From c2g__codaInvoiceLineItem__c 
                                                                                  where c2g__Invoice__r.Canceled__c = false and c2g__Invoice__r.c2g__Account__c in :accIDSet
                                                                                  and (c2g__Invoice__r.c2g__PaymentStatus__c = 'Part Paid' or c2g__Invoice__r.c2g__PaymentStatus__c = 'Unpaid')
                                                                                  and c2g__Invoice__r.c2g__DueDate__c < :Date.today()
                                                                                  and c2g__Product__r.ProductCode in :products
                                                                                  and c2g__Invoice__r.c2g__InvoiceStatus__c = 'Complete'
                                                                                  group by c2g__Invoice__r.c2g__Account__c]);
		
		for(ID accID : accIDSet){
		    Account acc = new Account();
            acc.id = accID;

           	acc.Overdue_Rents__c = (invoiceItemMap.get(accID) != null ) ? (Integer) invoiceItemMap.get(accID).get('cnt') : 0;

		    accToUpdate.add(acc);
		}
		if(!accToUpdate.isEmpty()){
		    update accToUpdate;                                  
		}
    }
    
}