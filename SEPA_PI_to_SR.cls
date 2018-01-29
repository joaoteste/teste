//SEPA Payable Invoice to SEPA record, used by the trigger codaPurchaseInvoice_Trigger ( Payable Invoice - c2g__codaPurchaseInvoice__c)
// Test class: SEPA_PI_to_SR_TEST

public class SEPA_PI_to_SR {

    public static Map<Id, Payment_Collection__c > addSRFromPIs(Set<Id> turnedToCompletedIDs){

	    system.debug(loggingLevel.INFO, '[SEPA_PI_to_SR] turnedToCompletedIDs.size(): ' + turnedToCompletedIDs.size());
     
        List<c2g__codaPurchaseInvoice__c> salesPurchaseInvoicesList = [SELECT Id
                     , Name
                     , c2g__Account__r.Id
                     , c2g__Account__r.Name
                     , c2g__Account__r.Type 
                     , c2g__Account__r.NIF__c
                     , c2g__Account__r.c2g__CODABankIBANNumber__c
                     , c2g__Account__r.c2g__CODABankSWIFTNumber__c
                     , c2g__Account__r.SEPA_Inactive__c
                     , c2g__DueDate__c
                     , c2g__InvoiceDate__c
                     , c2g__InvoiceStatus__c
                     , c2g__InvoiceCurrency__c
                     , c2g__InvoiceTotal__c //c2g__OutstandingValue__c comes 0 from trigger on complete event
                     , c2g__Period__c
                     FROM c2g__codaPurchaseInvoice__c
                     WHERE
                     Id IN :turnedToCompletedIDs
 //              AND CR_Sepa_Record__c = null
               AND c2g__Account__r.SEPA_Inactive__c != true
                    ];

	      return createPaymentCollectionWithSEPAFromPIN(salesPurchaseInvoicesList);
	        
	  
    }     
    
    private static void createSEPAForPurchaseInvoices(List<c2g__codaPurchaseInvoice__c> salesPurchaseInvoicesList, Map<Id, Payment_Collection__c> paymentCollectionPerPINMap){      

          if(salesPurchaseInvoicesList.size()>0){           
              Map<String, String> currencyISOFromIdMap = SEPA_UTILS.getCurrencyISOFromIdMap();
              
              System.debug(loggingLevel.INFO, '[SEPA_PI_to_SR] execute started.');
                        
              List<CR_Sepa_Admin__c> sepaAdmins = [
                  Select Id
                  , Name
                  , Activation_Date__c
                  , SEPA_Category_Purpose__c
                  , SEPA_Initiating_Party_Name__c
                  , SEPA_Our_Bank_SWIFT_BIC__c
                  , SEPA_Our_Bank_IBAN__c
                  , SEPA_Our_Bank_Private_Identification__c
                  , SEPA_Movement_Type__c
                  , SEPA_Payment_Method__c
                  , SEPA_Service_Type__c
                  , SEPA_Tag_xmlns__c
                  , SEPA_Tag_xmlns_xsi__c
                  , Preferred_Weekday__c
                  FROM CR_Sepa_Admin__c
                  WHERE SEPA_Movement_Type__c IN :SEPA_UTILS.getDocumentTypesForPI()
              ];
              
              Map<String, CR_Sepa_Admin__c> sepaAdminsMap = new Map<String, CR_Sepa_Admin__c>();
              for(CR_Sepa_Admin__c sepaAdmin : sepaAdmins){
                  sepaAdminsMap.put(sepaAdmin.SEPA_Movement_Type__c,sepaAdmin);
              }
              
              Map<c2g__codaPurchaseInvoice__c, CR_Sepa_Record__c> sepaRecs = new Map<c2g__codaPurchaseInvoice__c, CR_Sepa_Record__c>();
              
              for(  c2g__codaPurchaseInvoice__c pi : salesPurchaseInvoicesList){
                  
                  system.debug(LoggingLevel.INFO,'Checking if pi.Application__r.Client_BBAN__c is FRST for pi.ID: ' + pi.Id + ' pi.c2g__DueDate__c: ' + pi.c2g__DueDate__c + ' pi.c2g__Account__r.c2g__CODABankIBANNumber__c: ' + pi.c2g__Account__r.c2g__CODABankIBANNumber__c + ' pi.c2g__Account__r.Type: ' + pi.c2g__Account__r.Type );
                  
                  date activationDate = SEPA_UTILS.processActivationDate(sepaAdminsMap.get(SEPA_UTILS.getDocumentTypeAPIName(pi)), pi.c2g__DueDate__c);

                  CR_Sepa_Record__c sepaRec = new CR_Sepa_Record__c(
	                    Document_Due_Date__c = pi.c2g__DueDate__c
	                    , Document_Type__c = SEPA_UTILS.getDocumentTypeAPIName(pi)
	                    , Activation_Date__c = activationDate
	                    , Debtor_Account__c = pi.c2g__Account__r.Id
	                    , Debtor_Name__c = pi.c2g__Account__r.Name.left(70)
	                    , IBAN__c = pi.c2g__Account__r.c2g__CODABankIBANNumber__c
	                    , Invoice_Number__c = pi.Name
	                    , Mandate_Date__c = Date.today()
	                    , Mandate_Identification__c = pi.id
	                    , Request_Count__c = 1
	                    , Request_Amount__c = pi.c2g__InvoiceTotal__c
	                    , Request_Currency__c =  currencyISOFromIdMap.get(pi.c2g__InvoiceCurrency__c)
	                    , Swift_Bic__c = pi.c2g__Account__r.c2g__CODABankSWIFTNumber__c
	                    , Payable_Invoice__c = pi.id
	                    , Payment_Date__c = SEPA_UTILS.processExecutionDate(sepaAdminsMap.get(SEPA_UTILS.getDocumentTypeAPIName(pi)) , activationDate)
	                    , Payment_Collection__c = paymentCollectionPerPINMap.get(pi.id).id
	                );
                  sepaRecs.put(pi, sepaRec);

              }
              
              if(sepaRecs.size() > 0){
                  upsert sepaRecs.values();

                  for (c2g__codaPurchaseInvoice__c pi : sepaRecs.keySet()) {
                      pi.CR_Sepa_Record__c = sepaRecs.get(pi).Id;
                  }

                  update salesPurchaseInvoicesList;
              }
              
              system.debug(loggingLevel.INFO, '[SEPA_PI_to_SR] new SalesInvoices for Sepa Records: ' + salesPurchaseInvoicesList.size());
              return;
          }

          system.debug(loggingLevel.INFO, '[SEPA_PI_to_SR] new SalesInvoices for Sepa Records: ' + salesPurchaseInvoicesList.size());
          return ;

    }

/*
    public static void createPaymentCollectionWithSEPAFromPIN(){
    	Set<Id> salesPurchaseInvoicesList = new Set<Id>();
    	salesPurchaseInvoicesList.add('a3U240000009q5s');
    	addSRFromPIs(salesPurchaseInvoicesList);
    	
    }
*/
    //key PIN Id
    public static Map<Id, Payment_Collection__c > createPaymentCollectionWithSEPAFromPIN(List<c2g__codaPurchaseInvoice__c> salesPurchaseInvoicesList){
    	
    	system.debug('createPaymentCollectionWithSEPAFromPIN');
    	Savepoint sp = Database.setSavepoint();
    	try{
	    	
	    	if(salesPurchaseInvoicesList == null || salesPurchaseInvoicesList.size() == 0){
	    		system.debug('No PurchaseInvoices to process');
	    		return null;
	    	}
	 		
            system.debug('create Payment_Collection__c');
	 		//create Payment_Collection__c
	 		 //key Purchase Invoices Id
	        Map<Id, Payment_Collection__c> paymentCollectionPerPINMap = new Map<Id, Payment_Collection__c>();
	 		for(c2g__codaPurchaseInvoice__c purchaseInvoice : salesPurchaseInvoicesList){

		        Payment_Collection__c paymentCollection = new Payment_Collection__c(
		        Account__c = purchaseInvoice.c2g__Account__c,
		        Expiry_Date__c = purchaseInvoice.c2g__DueDate__c,
		        Period__c = purchaseInvoice.c2g__Period__c,
		        Status__c = 'In Payment',
		        Payment_Method__c = 'Bank Transfer');
		        paymentCollectionPerPINMap.put(purchaseInvoice.Id, paymentCollection);
		 	}
	
	        insert paymentCollectionPerPINMap.values();
	        
	        system.debug('paymentCollectionPerPINMap: ' + paymentCollectionPerPINMap);
	
	 		//create SEPA record.
	 		   //key Account
	 		// Map<id, CR_Sepa_Record__c> salesInvoiceAccountMap = 
	 		createSEPAForPurchaseInvoices(salesPurchaseInvoicesList, paymentCollectionPerPINMap);
	
	       
	        List<Receipt_Line_Item__c> receiptLineItemList = new List<Receipt_Line_Item__c>();
	        for(c2g__codaPurchaseInvoice__c purchaseInvoice : salesPurchaseInvoicesList){
	            //Receipt_Line_Item__c rli = createPaymentCollectionReceiptLineItems(paymentCollection.Id, salesInvoiceList[0].Application__c , salesInvoiceList[0].c2g__InvoiceTotal__c, salesInvoiceList[0].Id);
	            Receipt_Line_Item__c rli = new Receipt_Line_Item__c(
			        Payment_Collection__c = paymentCollectionPerPINMap.get(purchaseInvoice.Id).Id,
	                Amount_Claimed__c = purchaseInvoice.c2g__InvoiceTotal__c,
	                First_try__c = system.today(),
	                Payable_Invoice__c = purchaseInvoice.Id
	            );
	            receiptLineItemList.add(rli);
	        } 

	        insert receiptLineItemList;
	        return paymentCollectionPerPINMap;
        } catch (Exception ex) {
    		Database.rollback(sp);
        	system.debug( 'ERROR:' + ex.getStackTraceString());
 	
		    Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c = system.today(), Code__c = 'CRITICAL',ApplicationID__c = 'SEPA',message__c = 'PaymentCollection_Utils.createPaymentCollectionWithSEPAFromCreditNote' , printStackTrace__c = ex.getStackTraceString() );
			system.debug('CRITICAL: '+ record);
         	return null;
        }

        return null;
    }
    
    
    /////////////////////
	//Update Payable Invoice
	// TODO para apagar depois de usar

	public static Map<Id, Payment_Collection__c > updatePaymentCollectionWithSEPAPayableInvoice(){
        
        system.debug('SEPA_PI_to_SR.updatePaymentCollectionWithSEPAPayableInvoice()');
        Savepoint sp = Database.setSavepoint();
        try{
            //1o Query SEPA records
            List<CR_Sepa_Record__c> sepaRecordList = [SELECT Id, Payable_Invoice__c, Payment_Collection__c, Return_Status_Code__c, Invalid_Record__c FROM CR_Sepa_Record__c WHERE Payment_Collection__c = null AND Payable_Invoice__c != null LIMIT 50]; 
            
            //2o Query to Map Credit Note
            Set<Id> payableInvoiceIdSet = new Set<Id>();
            for(CR_Sepa_Record__c sepaRecord : sepaRecordList){
                payableInvoiceIdSet.add(sepaRecord.Payable_Invoice__c);
                system.debug('sepaRecord: ' + sepaRecord);
            }
             //key Id Payable Invoice
          Map<Id, c2g__codaPurchaseInvoice__c> creditNoteMap = new Map<Id, c2g__codaPurchaseInvoice__c>([SELECT Id
                   , Name
                   , c2g__Account__r.Id
                   , c2g__Account__r.Name
                   , c2g__Account__r.Type 
                   , c2g__Account__r.NIF__c
                   , c2g__Account__r.c2g__CODABankIBANNumber__c
                   , c2g__Account__r.c2g__CODABankSWIFTNumber__c
            //       , c2g__Invoice__r.c2g__PaymentStatus__c
                   , c2g__DueDate__c
                   , c2g__InvoiceStatus__c
                   , c2g__InvoiceCurrency__c
                   , c2g__InvoiceTotal__c //c2g__OutstandingValue__c comes 0 from trigger on complete event
          //         , c2g__Invoice__c
          //         , c2g__Invoice__r.Application__c
                   , c2g__Period__c
                   FROM c2g__codaPurchaseInvoice__c
                   WHERE
                           Id IN :payableInvoiceIdSet
                  ]);

            //3o Create PAC
              //key Sepa Record
            Map<Id, Payment_Collection__c > paymentColectionPerSEPARecordMap = new Map<Id, Payment_Collection__c >();
            for(CR_Sepa_Record__c sepaRecord :sepaRecordList){
                    c2g__codaPurchaseInvoice__c creditNoteaux = creditNoteMap.get(sepaRecord.Payable_Invoice__c);
                    String status = 'In Payment';
                    if(sepaRecord.Return_Status_Code__c == '0000'){
                        status = 'Paid';
                    }else if(sepaRecord.Return_Status_Code__c != null){
                        status = 'Unpaid';
                    }else if(sepaRecord.Invalid_Record__c == true){
                        status = 'Canceled';
                    }
                    
                    Payment_Collection__c paymentCollection = new Payment_Collection__c(
                    Account__c = creditNoteaux.c2g__Account__c ,
                    Expiry_Date__c = creditNoteaux.c2g__DueDate__c,
                    Period__c = creditNoteaux.c2g__Period__c,
                    Status__c = status,
                    Payment_Method__c = 'Direct Debit');
                    
        
                    paymentColectionPerSEPARecordMap.put(sepaRecord.id, paymentCollection);
                }
    
            insert paymentColectionPerSEPARecordMap.values();
            
            //4o update CEPA record
            for(CR_Sepa_Record__c sepaRecord : sepaRecordList){
                sepaRecord.Payment_Collection__c = paymentColectionPerSEPARecordMap.get(sepaRecord.Id).Id;
            }
            update sepaRecordList;
            
            system.debug('paymentColectionPerSEPARecordMap.values():' + paymentColectionPerSEPARecordMap.values());
            //5o create line Item

            List<Receipt_Line_Item__c> receiptLineItemList = new List<Receipt_Line_Item__c>();
            for(CR_Sepa_Record__c sepaRecord : sepaRecordList){
                //Receipt_Line_Item__c rli = createPaymentCollectionReceiptLineItems(paymentCollection.Id, creditNoteList[0].Application__c , creditNoteList[0].c2g__InvoiceTotal__c, creditNoteList[0].Id);
                
                c2g__codaPurchaseInvoice__c creditNote = creditNoteMap.get(sepaRecord.Payable_Invoice__c);
                Receipt_Line_Item__c rli = new Receipt_Line_Item__c(
                    Payment_Collection__c = paymentColectionPerSEPARecordMap.get(sepaRecord.id).Id
                    ,Amount_Claimed__c = creditNote.c2g__InvoiceTotal__c
                    ,First_try__c = system.today()
                    ,Payable_Invoice__c = creditNote.Id
//                    ,Renting_Application__c = creditNote.c2g__Invoice__r.Application__c
                );
                receiptLineItemList.add(rli);
            } 
          
            insert receiptLineItemList;
            system.debug('receiptLineItemList:' + receiptLineItemList);

        } catch (Exception ex) {
            Database.rollback(sp);
            system.debug( 'ERROR:' + ex.getStackTraceString());
    
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c = system.today(), Code__c = 'CRITICAL',ApplicationID__c = 'SEPA',message__c = 'PaymentCollection_Utils.updatePaymentCollectionWithSEPA' , printStackTrace__c = ex.getStackTraceString() );
            system.debug('CRITICAL: '+ record);
            return null;
        }

        return null;
    }

}