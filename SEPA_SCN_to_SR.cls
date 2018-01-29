/********************************************************************************
                        SCN ação (criar SCN) *trigger
                        |                          \
       Sales invoice In PC                        Sales Invoice not in PT
          /      \                                       |
   SIM   /        \ Não                                  |
        /          \                               Espera que seja pago
     SI=CN        SI!=CN                                            / \
   Cancela PC      /   \                                           /   \
    +match        /     \                                       IVA=0   IVA!=0
                IVA=0    IVA != 0                                /        \
                  |          |                                 Pago      Attach Assinado 
              Junta SCN      |                                          (adicionar Attach) *trigger
              à PC da SI    Attach Assinado 
                           (adicionar Attach) *trigger 

************************************************************************************/   
//Sales credit Note to SEPA Record
public class SEPA_SCN_to_SR {

	public static Map<Id, Payment_Collection__c > addSRFromSCNs(Set<Id> creditNoteCompletedIDs){

	    system.debug(loggingLevel.INFO, '[SEPA_SCN_to_SR] creditNoteCompletedIDs.size(): ' + creditNoteCompletedIDs.size());
            
        //TODO o que fazer se o pagamento foi por referencia e nao temos iban.
        Map<Id,c2g__codaCreditNote__c> salesCreditNoteMap = new Map<Id,c2g__codaCreditNote__c>([SELECT Id
                   , Name
                   , c2g__Account__c
                   , c2g__Account__r.Name
                   , c2g__Account__r.Type 
                   , c2g__Account__r.NIF__c
                   , c2g__Account__r.c2g__CODABankIBANNumber__c
                   , c2g__Account__r.c2g__CODABankSWIFTNumber__c
                   , c2g__DueDate__c
                   , c2g__CreditNoteStatus__c
                   , c2g__CreditNoteCurrency__c
                   , c2g__CreditNoteTotal__c //c2g__OutstandingValue__c comes 0 from trigger on complete event
                   , c2g__Invoice__r.Name
                   , c2g__Invoice__r.c2g__PaymentStatus__c
                   , c2g__Invoice__r.Application__c
                   , c2g__Invoice__r.c2g__InvoiceTotal__c
                   , c2g__Period__c
                   , c2g__PaymentStatus__c
                   , c2g__TaxTotal__c
                   FROM c2g__codaCreditNote__c
                   WHERE
                   Id IN :creditNoteCompletedIDs
                   AND CR_Sepa_Record__c = null   // nao e necessario, mas fica a dupla verificacao porque voltara a fazer Mer"#$"$DQA
         //          AND c2g__Invoice__r.c2g__PaymentStatus__c = 'Paid'
                   AND c2g__PaymentStatus__c = 'Unpaid'   // some times the invoice status change but the credit note was already pay.
                  ]);

        //check is the Credit Note is already in a Payment collection
        //Remove Credit notes that are already in a Payment Collection
        List<Receipt_Line_Item__c> receiptLineItemList = [SELECT Id, Sales_Credit_Note__c, Payment_Collection__c, Payment_Collection__r.Status__c FROM Receipt_Line_Item__c WHERE (Payment_Collection__r.Status__c ='In Payment' OR Payment_Collection__r.Status__c ='Paid') AND Sales_Credit_Note__c IN :salesCreditNoteMap.keySet()];
        for(Receipt_Line_Item__c receipientLineItem : receiptLineItemList){
        	salesCreditNoteMap.remove(receipientLineItem.Sales_Credit_Note__c);
        }

        system.debug('salesCreditNoteMap' + salesCreditNoteMap); 
//1 SEPARA EM 2 (com PC em aberto) e (sem PC em aberto) 
        Map<Id,Payment_Collection__c> creditNoteWithUnPaidSalesInvoiceWithSepa_PC_Map = salesCreditNoteWithSalesInvoiceUNPaidWithPC(salesCreditNoteMap);
        
        system.debug('creditNoteWithUnPaidSalesInvoiceWithSepa_PC_Map' + creditNoteWithUnPaidSalesInvoiceWithSepa_PC_Map); 
        system.debug('salesCreditNoteMap' + salesCreditNoteMap); 
        Map<Id,c2g__codaCreditNote__c> salesCreditNoteMapPaidORInpaymentMap = new Map<Id,c2g__codaCreditNote__c>();
        Map<Id,c2g__codaCreditNote__c> creditNoteWithSalesInvoicePaidMap = new Map<Id,c2g__codaCreditNote__c>();
        for( Id creditNoteId : salesCreditNoteMap.keySet() ){
        	if(creditNoteWithUnPaidSalesInvoiceWithSepa_PC_Map.containsKey(creditNoteId)){
        		creditNoteWithSalesInvoicePaidMap.put(creditNoteId, salesCreditNoteMap.get(creditNoteId) );    //1
        	}else{
        		salesCreditNoteMapPaidORInpaymentMap.put(creditNoteId, salesCreditNoteMap.get(creditNoteId) );  //2
        	}
        }

        system.debug('salesCreditNoteMapPaidORInpaymentMap' + salesCreditNoteMapPaidORInpaymentMap);
        system.debug('creditNoteWithSalesInvoicePaidMap' + creditNoteWithSalesInvoicePaidMap);
        
  //1 com payment collection, com SEPA, ainda por pagar
        withPCOpen(creditNoteWithSalesInvoicePaidMap, creditNoteWithUnPaidSalesInvoiceWithSepa_PC_Map);

 //2 nenhum PC em aberto
        system.debug('salesCreditNoteMapPaidORInpaymentMap:' + salesCreditNoteMapPaidORInpaymentMap);
        //Só faz sentido pagar a SCN depois do sales invoice estar pago, daí tirar todos os SCN que têm SIN por pagar
        salesCreditNoteMapPaidORInpaymentMap =  removeCreditNoteWithSalesInvoiceUNPaind(salesCreditNoteMapPaidORInpaymentMap);
        
        return noPCOpen( salesCreditNoteMapPaidORInpaymentMap );
	}
	
	public static Map<Id, Payment_Collection__c > createSEPAForCNFromSalesInvoices(List<Id> creditNotePaidListIDs){

	    system.debug(loggingLevel.INFO, '[SEPA_SCN_to_SR] creditNotePaidListIDs.size(): ' + creditNotePaidListIDs.size());
            
        //TODO o que fazer se o pagamento foi por referencia e nao temos iban.
        Map<Id, c2g__codaCreditNote__c> salesCreditNoteMap = new Map<Id, c2g__codaCreditNote__c> ([SELECT Id
                   , Name
                   , c2g__Account__c
                   , c2g__Account__r.Name
                   , c2g__Account__r.Type 
                   , c2g__Account__r.NIF__c
                   , c2g__Account__r.c2g__CODABankIBANNumber__c
                   , c2g__Account__r.c2g__CODABankSWIFTNumber__c
                   , c2g__DueDate__c
                   , c2g__CreditNoteStatus__c
                   , c2g__CreditNoteCurrency__c
                   , c2g__CreditNoteTotal__c //c2g__OutstandingValue__c comes 0 from trigger on complete event
                   , c2g__Invoice__r.Name
                   , c2g__Invoice__r.c2g__PaymentStatus__c
                   , c2g__Invoice__r.Application__c
                   , c2g__Invoice__r.c2g__InvoiceTotal__c
                   , c2g__Period__c
                   , c2g__PaymentStatus__c
                   , c2g__TaxTotal__c
                   FROM c2g__codaCreditNote__c
                   WHERE
                //   Id IN :turnedToCompletedIDs AND 
//                   CR_Sepa_Record__c = null AND 
                   c2g__PaymentStatus__c = 'Unpaid' AND
                   c2g__Invoice__c IN :creditNotePaidListIDs
                  ]);
		
		//check is the Credit Note is already in a Payment collection
        //Remove Credit notes that are already in a Payment Collection
        List<Receipt_Line_Item__c> receiptLineItemList = [SELECT Id, Sales_Credit_Note__c, Payment_Collection__c, Payment_Collection__r.Status__c FROM Receipt_Line_Item__c WHERE (Payment_Collection__r.Status__c ='In Payment' OR Payment_Collection__r.Status__c ='Paid') AND Sales_Credit_Note__c IN :salesCreditNoteMap.keySet()];
        for(Receipt_Line_Item__c receipientLineItem : receiptLineItemList){
        	salesCreditNoteMap.remove(receipientLineItem.Sales_Credit_Note__c);
        }
		return noPCOpen(salesCreditNoteMap);
	}
	
	private static Map<Id, Payment_Collection__c > noPCOpen(Map<Id,c2g__codaCreditNote__c> salesCreditNoteMapPaidORInpaymentMap ){
		List<c2g__codaCreditNote__c> toCreateNewSEPAAndPCList = new List<c2g__codaCreditNote__c>();
        if(salesCreditNoteMapPaidORInpaymentMap.values().size() > 0){
        	toCreateNewSEPAAndPCList = withoutTaxORWithAttached(salesCreditNoteMapPaidORInpaymentMap);
        }
       
        system.debug('toCreateNewSEPAAndPCList' + toCreateNewSEPAAndPCList);
        return createPaymentCollectionWithSEPAFromCreditNote(toCreateNewSEPAAndPCList);
	}

	private static Map<Id,c2g__codaCreditNote__c> removeCreditNoteWithSalesInvoiceUNPaind(Map<Id,c2g__codaCreditNote__c> salesCreditNoteMapPaidORInpaymentMap ){
		Map<Id,c2g__codaCreditNote__c> creditNoteWithSalesInvoiceUnpaidMap = new Map<Id,c2g__codaCreditNote__c>();
		system.debug('salesCreditNoteMapPaidORInpaymentMap' + salesCreditNoteMapPaidORInpaymentMap);
		for( c2g__codaCreditNote__c aux : salesCreditNoteMapPaidORInpaymentMap.values() ){
			//system.debug('aux.c2g__Invoice__r.c2g__PaymentStatus__c' + aux.c2g__Invoice__r.c2g__PaymentStatus__c );
			if(aux.c2g__Invoice__r.c2g__PaymentStatus__c.equals('Paid') ){
			    creditNoteWithSalesInvoiceUnpaidMap.put(aux.Id, aux);
			}
		}
		system.debug('creditNoteWithSalesInvoiceUnpaidMap' + creditNoteWithSalesInvoiceUnpaidMap);
		return creditNoteWithSalesInvoiceUnpaidMap;
	}
	
	private static Map<Id,Payment_Collection__c> salesCreditNoteWithSalesInvoiceUNPaidWithPC(Map<Id,c2g__codaCreditNote__c> salesCreditNoteMap ){
        system.debug('salesCreditNoteMap' + salesCreditNoteMap);
    //    system.debug('creditNoteWithUnPaidSalesInvoiceWithSepaMap' + creditNoteWithUnPaidSalesInvoiceWithSepaMap);
    //key =sales invoice Id value crediteNote 
    	Map<Id, c2g__codaCreditNote__c> salesInvoiceId_CreditNote = new Map<Id, c2g__codaCreditNote__c>();
    	for(c2g__codaCreditNote__c creditNote : salesCreditNoteMap.values()){
    		if(creditNote.c2g__Invoice__r.c2g__PaymentStatus__c != 'Paid'){
    		    salesInvoiceId_CreditNote.put(creditNote.c2g__Invoice__c, creditNote);
    		}
    	}
    	system.debug('salesInvoiceId_CreditNote' + salesInvoiceId_CreditNote);

    	List<Receipt_Line_Item__c> recLineItemList = [SELECT Id, name, Sales_Credit_Note__c, Payment_Collection__c, Invoice__c, Payment_Collection__r.Status__c FROM Receipt_Line_Item__c WHERE Invoice__c IN :salesInvoiceId_CreditNote.keySet() AND Payment_Collection__r.Status__c = 'In Payment'];
    	Set<Id> paymentCollectionIdSet = new Set<Id>();
    	for(Receipt_Line_Item__c rli : recLineItemList){
    		paymentCollectionIdSet.add(rli.Payment_Collection__c);
    	}
    	system.debug('paymentCollectionIdSet' + paymentCollectionIdSet);
    	
    	List<CR_Sepa_Record__c> sepaRecordsList = [SELECT Id, Payment_Collection__c FROM CR_Sepa_Record__c WHERE Payment_Collection__c IN :paymentCollectionIdSet AND CR_Sepa_File__c = null];

    	Set<Id> paymentCollectionFinalId = new Set<Id>();
    	for(CR_Sepa_Record__c sepaRecord : sepaRecordsList){
    		paymentCollectionFinalId.add(sepaRecord.Payment_Collection__c);
    	}
    	system.debug('paymentCollectionFinalId' + paymentCollectionFinalId);
    	
    	Map<Id,Payment_Collection__c> paymentCollectionMap = new Map<Id,Payment_Collection__c>([SELECT Id FROM Payment_Collection__c WHERE Id IN :paymentCollectionFinalId]);
  	
    //key IdSCRN value PC
        Map<Id,Payment_Collection__c> sCN_PCMap = new Map<Id,Payment_Collection__c>();
    //key IdSaleIv value PC
        Map<Id,Payment_Collection__c> salesInvoice_PCMap = new Map<Id,Payment_Collection__c>();
        
    	for(Receipt_Line_Item__c rli : recLineItemList){
    		if(paymentCollectionMap.get(rli.Payment_Collection__c ) != null){
    			salesInvoice_PCMap.put(rli.Invoice__c , paymentCollectionMap.get(rli.Payment_Collection__c));
    			sCN_PCMap.put( salesInvoiceId_CreditNote.get(rli.Invoice__c).Id , paymentCollectionMap.get(rli.Payment_Collection__c) );
    		}
    		
    	}
    	system.debug('salesInvoice_PCMap' + salesInvoice_PCMap);
    	system.debug('sCN_PCMap' + sCN_PCMap);
    	
    	return sCN_PCMap;
    }

    private static void withPCOpen(Map<Id,c2g__codaCreditNote__c> creditNoteWithSalesInvoicePaidMap, Map<Id,Payment_Collection__c> creditNoteWithUnPaidSalesInvoiceWithSepa_PC_Map){

        Map<Id,Payment_Collection__c> addToCC = new Map<Id,Payment_Collection__c>();
        
        Map<Id,c2g__codaCreditNote__c> creditNoteWithSalesInvoiceToPaidV2Map = new Map<Id,c2g__codaCreditNote__c>();
        Map<Id,c2g__codaCreditNote__c> creditPaidWithInvoiceMap = new Map<Id,c2g__codaCreditNote__c>();
    	for(Id creditNoteId : creditNoteWithSalesInvoicePaidMap.keySet() ){
    		c2g__codaCreditNote__c creditNote = creditNoteWithSalesInvoicePaidMap.get(creditNoteId);
        	if( creditNote.c2g__CreditNoteTotal__c == creditNote.c2g__Invoice__r.c2g__InvoiceTotal__c){
        		//Make the match later.
        		creditPaidWithInvoiceMap.put(creditNoteId, creditNoteWithSalesInvoicePaidMap.get(creditNoteId) );
        		addToCC.put( creditNote.Id, creditNoteWithUnPaidSalesInvoiceWithSepa_PC_Map.get(creditNote.Id) );
        	}else{
        		creditNoteWithSalesInvoiceToPaidV2Map.put(creditNoteId, creditNoteWithSalesInvoicePaidMap.get(creditNoteId) );
        	}
    	}

    	system.debug('creditNoteWithSalesInvoiceToPaidV2Map' + creditNoteWithSalesInvoiceToPaidV2Map); 
    	
        List<c2g__codaCreditNote__c> addToCCCreditNoteList = withoutTaxORWithAttached(creditNoteWithSalesInvoiceToPaidV2Map);
        for(c2g__codaCreditNote__c creditNote : addToCCCreditNoteList){
        	addToCC.put( creditNote.Id, creditNoteWithUnPaidSalesInvoiceWithSepa_PC_Map.get(creditNote.Id) );
        }
        
        system.debug('addToCC' + addToCC);
                
                                     //key=scn  value=PC
        addSCNToPaymentCollectionWithSEPA( addToCC , creditNoteWithSalesInvoicePaidMap);
        
        
        //Make the matching when creditNote.c2g__CreditNoteTotal__c == creditNote.c2g__Invoice__r.c2g__InvoiceTotal__c
        for(c2g__codaCreditNote__c creditNote : creditPaidWithInvoiceMap.values() ){
            system.debug('Fazer o cash matching');
        	matchCreditNoteWithSalesInvoice( creditNote );
        	Payment_Collection__c paymentCollection = creditNoteWithUnPaidSalesInvoiceWithSepa_PC_Map.get(creditNote.Id);
        	CR_Sepa_Record__c sepaRecord = [SELECT ID, Invalid_Record__c, Payment_Collection__c FROM CR_Sepa_Record__c WHERE Payment_Collection__c = :paymentCollection.Id];
        	sepaRecord.Invalid_Record__c = true;
        	update sepaRecord;
        }
    }

	private static void addSCNToPaymentCollectionWithSEPA(Map<Id,Payment_Collection__c> creditNoteWithUnPaidSalesInvoiceWithSepaMap, Map<Id,c2g__codaCreditNote__c> creditNoteMap){
		
		List<Receipt_Line_Item__c> receiptLineItemList = new List<Receipt_Line_Item__c>();
		for(Id salesCreditNoteId : creditNoteWithUnPaidSalesInvoiceWithSepaMap.keySet()){
			Receipt_Line_Item__c rli = new Receipt_Line_Item__c(
			        Payment_Collection__c = creditNoteWithUnPaidSalesInvoiceWithSepaMap.get(salesCreditNoteId).Id,
	                Amount_Claimed__c = creditNoteMap.get(salesCreditNoteId).c2g__CreditNoteTotal__c,
	                First_try__c = system.today(),
	                Sales_Credit_Note__c = salesCreditNoteId
	               // Renting_Application__c = salesCreditNote.c2g__Invoice__r.Application__c
	            );
	        receiptLineItemList.add(rli);
		}
		
		system.debug('receiptLineItemList' + receiptLineItemList);
		insert receiptLineItemList;

	}
	
	private static List<c2g__codaCreditNote__c> withoutTaxORWithAttached(Map<Id,c2g__codaCreditNote__c> salesCreditNoteMap){
        // Check if IVA == 0
        List<c2g__codaCreditNote__c> salesCreditNoteWithoutTAXList = salesCreditNoteWithoutTAX(salesCreditNoteMap.values());
        system.debug('salesCreditNoteWithoutTAXList' + salesCreditNoteWithoutTAXList);
        // check if IVA != 0 AND Credit NOTE Attach Name contains "ASSINADA"
        List<c2g__codaCreditNote__c> salesCreditNoteWithTAXAndAttchList = salesCreditNoteWithTAXAndAttch(salesCreditNoteMap);
        system.debug('salesCreditNoteWithTAXAndAttchList' + salesCreditNoteWithTAXAndAttchList);
        
        List<c2g__codaCreditNote__c> salesCreditNoteToProcess = new List<c2g__codaCreditNote__c>();
        salesCreditNoteToProcess.addAll(salesCreditNoteWithoutTAXList);
        salesCreditNoteToProcess.addAll(salesCreditNoteWithTAXAndAttchList);
        
        return salesCreditNoteToProcess;
    }
    
    private static List<c2g__codaCreditNote__c> salesCreditNoteWithoutTAX(List<c2g__codaCreditNote__c> salesCreditNoteList){

    	List<c2g__codaCreditNote__c> salesCreditNoteWithoutTAXList = new List<c2g__codaCreditNote__c>();
    	for(c2g__codaCreditNote__c creditNote : salesCreditNoteList){
    		if(creditNote.c2g__TaxTotal__c == 0){
    			salesCreditNoteWithoutTAXList.add(creditNote);
    		}
    	}
    	
    	return salesCreditNoteWithoutTAXList;
    }
    
    private static List<c2g__codaCreditNote__c> salesCreditNoteWithTAXAndAttch(Map<Id,c2g__codaCreditNote__c> salesCreditNoteMap){
    	system.debug('salesCreditNoteMap' + salesCreditNoteMap);
    	List<Id> salesCreditNoteWithTaxIdList = new List<Id>();
    	for( c2g__codaCreditNote__c creditNote : salesCreditNoteMap.values() ){
    		if(creditNote.c2g__TaxTotal__c != 0){
    			salesCreditNoteWithTaxIdList.add(creditNote.Id);
    		}
    	}
    	
    	List<c2g__codaCreditNote__c> salesCreditNoteWithTAXAndAttchList = new List<c2g__codaCreditNote__c>();
    	List<Attachment> attachmentList = [SELECT Id, name, ParentId FROM Attachment WHERE ParentId IN :salesCreditNoteWithTaxIdList];
    	Set<Id> salesCreditNoteWithTaxAndAttchIdSet = new Set<Id>();
    	for(Attachment attch : attachmentList){
    		if( attch.name.containsIgnoreCase('assinada') || attch.name.containsIgnoreCase('assinado')){
    			salesCreditNoteWithTaxAndAttchIdSet.add(attch.ParentId);
    		}
    	}
    	
    	for(Id creditNoteId : salesCreditNoteWithTaxAndAttchIdSet){
    	    salesCreditNoteWithTAXAndAttchList.add( salesCreditNoteMap.get(creditNoteId) );
    	}

        system.debug('salesCreditNoteWithTAXAndAttchList' + salesCreditNoteWithTAXAndAttchList);
    	return salesCreditNoteWithTAXAndAttchList;
    }

	private static void createSEPAForCrediteNotes(List<c2g__codaCreditNote__c> salesCreditNoteList, Map<Id, Payment_Collection__c> paymentCollectionPerSCNMap){
		
 		Datetime startDatetime = Datetime.now();
		
		try{

	        if(salesCreditNoteList.size()>0){
	            
	            System.debug(loggingLevel.INFO, '[SEPA_SCN_to_SR] execute started.');
	            
	            CR_Sepa_Admin__c sepaAdmin = SEPA_UTILS.getSepaAdmin(salesCreditNoteList.get(0));
	            
	            Map<c2g__codaCreditNote__c, CR_Sepa_Record__c> sepaRecs = new Map<c2g__codaCreditNote__c, CR_Sepa_Record__c>();
	            Map<String, String> currencyISOFromIdMap = SEPA_UTILS.getCurrencyISOFromIdMap();
	            
	            for(  c2g__codaCreditNote__c scn : salesCreditNoteList){
	                
	                system.debug(LoggingLevel.INFO,'Checking if scn.Application__r.Client_BBAN__c is FRST for scn.ID: ' + scn.Id + ' scn.c2g__DueDate__c: ' + scn.c2g__DueDate__c + ' scn.c2g__Account__r.c2g__CODABankIBANNumber__c: ' + scn.c2g__Account__r.c2g__CODABankIBANNumber__c );
	                
	                date activationDate = SEPA_UTILS.processActivationDate(sepaAdmin, scn.c2g__DueDate__c);
	                CR_Sepa_Record__c sepaRec = new CR_Sepa_Record__c(
	                    Document_Due_Date__c = scn.c2g__DueDate__c
	                    , Document_Type__c = SepaAdmin.SEPA_Movement_Type__c
	                    , Activation_Date__c = activationDate
	                    , Debtor_Account__c = scn.c2g__Account__r.Id
	                    , Debtor_Name__c = scn.c2g__Account__r.Name.left(70)
	                    , IBAN__c = scn.c2g__Account__r.c2g__CODABankIBANNumber__c
	                    , Invoice_Number__c = scn.Name
	                    , Mandate_Date__c = Date.today()
	                    , Mandate_Identification__c = scn.c2g__Account__r.NIF__c
	                    , Request_Count__c = 1
	                    , Request_Amount__c = scn.c2g__CreditNoteTotal__c
	                    , Request_Currency__c =  currencyISOFromIdMap.get(scn.c2g__CreditNoteCurrency__c)
	                    , Swift_Bic__c = scn.c2g__Account__r.c2g__CODABankSWIFTNumber__c
	                    , Sales_Credit_Note__c = scn.Id
	                    , Payment_Date__c = SEPA_UTILS.processExecutionDate(sepaAdmin, activationDate)
	                    , Payment_Collection__c = paymentCollectionPerSCNMap.get(scn.id).id
	                );
	                
	                sepaRecs.put(scn, sepaRec);

	            }
	            
	       
	            if(sepaRecs.size() > 0){
	            	Savepoint sp = Database.setSavepoint();
		            try {
			            	
			                upsert sepaRecs.values();

		                    for (c2g__codaCreditNote__c scn : sepaRecs.keySet()) {
		                    	scn.CR_Sepa_Record__c = sepaRecs.get(scn).Id;
			                }

			                update salesCreditNoteList;
			            
			        } catch (Exception ex) {
			            if (sp != null) {
			                Database.rollback(sp);
			            }
			            //outbound and debug
			            system.debug(LoggingLevel.ERROR, 'ex.getCause(): ' + ex.getCause());
			            system.debug(LoggingLevel.ERROR, 'ex.getLineNumber(): ' + ex.getLineNumber());
			            system.debug(LoggingLevel.ERROR, 'ex.getMessage(): ' + ex.getMessage());
			            system.debug(LoggingLevel.ERROR, 'ex.getTypeName(): ' + ex.getTypeName());
			            system.debug(LoggingLevel.ERROR, 'ex.getStackTraceString(): ' + ex.getStackTraceString());
			            Utilities.LogIntegration(startDatetime, datetime.now(), 'Error', 'SEPA_SCN_to_SR at: ' + ex.getLineNumber(), ex.getMessage(), null);
			        }
	            }
	        }
	        
	        system.debug(loggingLevel.INFO, '[SEPA_SCN_to_SR] new Sales Credit Notes for Sepa Records: ' + salesCreditNoteList.size());
	        
        } catch (Exception ex) {
        	system.debug(loggingLevel.ERROR, 'SEPA_SCN_to_SR Exception:' + ex.getLineNumber() + ' ' + ex.getCause() + ' ' + ex.getMessage() + ' ' + ex.getStackTraceString());
         	Utilities.LogIntegration(startDatetime, datetime.now(), 'Error', 'SEPA_SCN_to_SR at: ' + ex.getLineNumber(), ex.getStackTraceString(), null);
        }
	 
	 }
	 
//TODO 
/*	 
    public static void testcreatePaymentCollectionWithSEPAFromCreditNote(){
    	Set<Id> creditNoteIdList = new Set<Id>();
    	creditNoteIdList.add('a2T24000000xYHB');
    	addSRFromSCNs(creditNoteIdList);
    	
    }
*/
    //key credit note Id
    private static Map<Id, Payment_Collection__c > createPaymentCollectionWithSEPAFromCreditNote(List<c2g__codaCreditNote__c> salesCreditNoteList){
    	
    	system.debug('createPaymentCollectionWithSEPAFromCreditNote');
    	Savepoint sp = Database.setSavepoint();
    	try{
	    	
	       //TODO 1, verificar se já existe um Payment collection para a mesma account e due date se sim, adicionar Receipt_Line_Item__c e somar o valor ao SEPA Record
	
	    	if(salesCreditNoteList == null || salesCreditNoteList.size() == 0){
	    		system.debug('No Credit Note to process');
	    		return null;
	    	}
	 		
            system.debug('create Payment_Collection__c');
	 		//create Payment_Collection__c
	 		 //key credit not Id
	        Map<Id, Payment_Collection__c> paymentCollectionPerSCNMap = new Map<Id, Payment_Collection__c>();
	 		for(c2g__codaCreditNote__c salesCreditNote : salesCreditNoteList){

		        Payment_Collection__c paymentCollection = new Payment_Collection__c(
		        Account__c = salesCreditNote.c2g__Account__c,
		        Expiry_Date__c = salesCreditNote.c2g__DueDate__c,
		        Period__c = salesCreditNote.c2g__Period__c,
		        Status__c = 'In Payment',
		        Payment_Method__c = 'Bank Transfer');
		        paymentCollectionPerSCNMap.put(salesCreditNote.Id, paymentCollection);
		 	}
	
	        insert paymentCollectionPerSCNMap.values();
	        
	        system.debug('paymentCollectionPerSCNMap: ' + paymentCollectionPerSCNMap);
	
	 		//create SEPA record.
	 		   //key Account
	 		// Map<id, CR_Sepa_Record__c> creditNoteAccountMap = 
	 		createSEPAForCrediteNotes(salesCreditNoteList, paymentCollectionPerSCNMap);
	
	       
	        List<Receipt_Line_Item__c> receiptLineItemList = new List<Receipt_Line_Item__c>();
	        for(c2g__codaCreditNote__c salesCreditNote : salesCreditNoteList){

	            Receipt_Line_Item__c rli = new Receipt_Line_Item__c(
			        Payment_Collection__c = paymentCollectionPerSCNMap.get(salesCreditNote.Id).Id,
	                Amount_Claimed__c = salesCreditNote.c2g__CreditNoteTotal__c,
	                First_try__c = system.today(),
	                Sales_Credit_Note__c = salesCreditNote.Id,
	                Renting_Application__c = salesCreditNote.c2g__Invoice__r.Application__c
	            );
	            receiptLineItemList.add(rli);
	        } 

	        insert receiptLineItemList;
	        return paymentCollectionPerSCNMap;
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
	//Update credit Notes
	// TODO para apagar depois de usar
/*
	public static Map<Id, Payment_Collection__c > updatePaymentCollectionWithSEPACreditNotes(){
        
        system.debug('SEPA_SCN_to_SR.updatePaymentCollectionWithSEPACreditNotes()');
        Savepoint sp = Database.setSavepoint();
        try{
            //1o Query SEPA records
            List<CR_Sepa_Record__c> sepaRecordList = [SELECT Id, Sales_Credit_Note__c, Payment_Collection__c, Return_Status_Code__c, Invalid_Record__c FROM CR_Sepa_Record__c WHERE Payment_Collection__c = null AND Sales_Credit_Note__c != null LIMIT 50]; 
            
            //2o Query to Map Credit Note
            Set<Id> creditNoteIdSet = new Set<Id>();
            for(CR_Sepa_Record__c sepaRecord : sepaRecordList){
                creditNoteIdSet.add(sepaRecord.Sales_Credit_Note__c);
                system.debug('sepaRecord: ' + sepaRecord);
            }
             //key Id credit note
          Map<Id, c2g__codaCreditNote__c> creditNoteMap = new Map<Id, c2g__codaCreditNote__c>([SELECT Id
                   , Name
                   , c2g__Account__r.Id
                   , c2g__Account__r.Name
                   , c2g__Account__r.Type 
                   , c2g__Account__r.NIF__c
                   , c2g__Account__r.c2g__CODABankIBANNumber__c
                   , c2g__Account__r.c2g__CODABankSWIFTNumber__c
                   , c2g__Invoice__r.c2g__PaymentStatus__c
                   , c2g__DueDate__c
                   , c2g__CreditNoteStatus__c
                   , c2g__CreditNoteCurrency__c
                   , c2g__CreditNoteTotal__c //c2g__OutstandingValue__c comes 0 from trigger on complete event
                   , c2g__Invoice__c
                   , c2g__Invoice__r.Application__c
                   , c2g__Period__c
                   FROM c2g__codaCreditNote__c
                   WHERE
                           Id IN :creditNoteIdSet
                  ]);

            //3o Create PAC
              //key Sepa Record
            Map<Id, Payment_Collection__c > paymentColectionPerSEPARecordMap = new Map<Id, Payment_Collection__c >();
            for(CR_Sepa_Record__c sepaRecord :sepaRecordList){
                    c2g__codaCreditNote__c creditNoteaux = creditNoteMap.get(sepaRecord.Sales_Credit_Note__c);
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
                
                c2g__codaCreditNote__c creditNote = creditNoteMap.get(sepaRecord.Sales_Credit_Note__c);
                Receipt_Line_Item__c rli = new Receipt_Line_Item__c(
                    Payment_Collection__c = paymentColectionPerSEPARecordMap.get(sepaRecord.id).Id,
                    Amount_Claimed__c = creditNote.c2g__CreditNoteTotal__c,
                    First_try__c = system.today(),
                    Sales_Credit_Note__c = creditNote.Id,
                    Renting_Application__c = creditNote.c2g__Invoice__r.Application__c
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
*/	 

    public static void matchCreditNoteWithSalesInvoice(c2g__codaCreditNote__c creditNote) {

        Savepoint sp = null;
        
        system.debug(LoggingLevel.INFO, 'matchCreditNoteWithSalesInvoice creditNote:' + creditNote);

        try {      
   
           //start transation
           sp = Database.setSavepoint();
                         
           // Query for the Transaction Line Items
           // (resulting from the postings above) to match

           Id periodDueDate = creditNote.c2g__Period__c;
           List<String> documentRefs = new List<String>();
           documentRefs.add(creditNote.Name);
           documentRefs.add(creditNote.c2g__Invoice__r.Name);

           List<c2g__codaTransactionLineItem__c> invoiceTransactionLinesToMatch = [
           SELECT   Id, c2g__AccountValue__c
                FROM c2g__codaTransactionLineItem__c
                WHERE c2g__Transaction__r.c2g__DocumentNumber__c IN :documentRefs
                AND c2g__LineType__c = 'Account'
                AND c2g__Account__c = :creditNote.c2g__Account__c   // is not needed but is used has a double check.
            ];           
          
           List<c2g__codaTransactionLineItem__c> transactionLinesToMatch = new List<c2g__codaTransactionLineItem__c>();
           transactionLinesToMatch.addall(invoiceTransactionLinesToMatch);
           
           system.debug(LoggingLevel.INFO, 'transactionLinesToMatch.size(): ' + transactionLinesToMatch.size());
           system.debug(LoggingLevel.INFO, 'transactionLinesToMatch: ' + transactionLinesToMatch);

     
           Id matchReferenceId = FF_Utils.doMatch(creditNote.c2g__Account__c, periodDueDate, transactionLinesToMatch );
                                  
        } catch (Exception ex) {
            if (sp != null) {
                Database.rollback(sp);
            }

            //outbound and debug
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SEPA',
            																	message__c = 'Problem occurred in CreditNote :' + creditNote + ' + line: '+ ex.getLineNumber() + ' \n Due to ' + ex.getCause() + ' \n giving error Message: ' + ex.getMessage(),
            																	printStackTrace__c = ex.getStackTraceString());
            insert record;
        }
    }
    

}