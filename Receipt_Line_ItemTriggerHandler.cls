//Test: PP_SC_CloseUnpaidPaymentPlan_Test, PaymentSchedule_Ctrl_Test, Receipt_Line_ItemTriggerHandlerTest
public class Receipt_Line_ItemTriggerHandler extends TriggerHandler{

    protected override void afterInsert(){

	    List<Receipt_Line_Item__c> rliList = new List<Receipt_Line_Item__c>();
        validateThatOneRLIHaveOnly1Document();

		List<Receipt_Line_Item__c> newRLIList = [SELECT ID,
                                                        Invoice__c,
                                                        Invoice__r.c2g__InvoiceTotal__c,
                                                        Invoice__r.Application__c,
							Invoice__r.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c,
                                                        Invoice__r.c2g__Account__c,
                                                        Invoice__r.c2g__PaymentStatus__c,
                                                        Sales_Credit_Note__c,
                                                        Sales_Credit_Note__r.c2g__CreditNoteTotal__c,
                                                        Sales_Credit_Note__r.Renting_Application__c,
                                                        Sales_Credit_Note__r.c2g__Account__c,
                                                        Sales_Credit_Note__r.c2g__PaymentStatus__c,
                                                        Payable_Invoice__c,
                                                        Payable_Invoice__r.c2g__InvoiceTotal__c,
                                                        Payable_Invoice__r.c2g__Account__c,
                                                        Payable_Invoice__r.c2g__PaymentStatus__c,
                                                        Payment_Collection__c,
                                                        Payment_Collection__r.Payment_Method__c,
                                                        Payment_Collection__r.Status__c,
                                                        Payment_Collection__r.Account__c
                                                             FROM Receipt_Line_Item__c WHERE ID IN :Trigger.newMap.keySet() ];

        system.debug('newRLIList' + newRLIList);
		//Validation:  
		validateThatAllRLIHaveOnly1Account(newRLIList);

		validatePCStatusInsert(newRLIList);
		
		//validate if the RLI is already paid
		validateRliPaid(newRLIList);

        for(Receipt_Line_Item__c rli : newRLIList){
            if(rli.Invoice__c != null){
                rli.Amount_Claimed__c = rli.Invoice__r.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                rli.Renting_Application__c = rli.Invoice__r.Application__c;
            }
            
            if(rli.Sales_Credit_Note__c != null){ 
                rli.Amount_Claimed__c = -1 * rli.Sales_Credit_Note__r.c2g__CreditNoteTotal__c;
                rli.Renting_Application__c = rli.Sales_Credit_Note__r.Renting_Application__c; 
            }
            
            if(rli.Payable_Invoice__c != null){ 
                rli.Amount_Claimed__c = rli.Payable_Invoice__r.c2g__InvoiceTotal__c;
               // rli.Renting_Application__c = rli.Sales_Credit_Note__r.Renting_Application__c; 
            }
            
        }
		        
		update newRLIList;
		
		updateAmmountSepaRecords(Trigger.newMap.values(), false );

    }
   
    protected override void beforeDelete(){
        List<Receipt_Line_Item__c> newRLIList = [SELECT ID,
                                                        Payment_Collection__c,
                                                        Payment_Collection__r.Status__c
                                                             FROM Receipt_Line_Item__c WHERE ID IN :Trigger.oldMap.keySet() ];
                                                             
        validatePCStatusDelete(newRLIList);
        updateAmmountSepaRecords(Trigger.oldMap.values(), true);
	}
	
	protected override void afterDelete(){

        updateAmmountSepaRecords(Trigger.oldMap.values(), false);
	}
	
	///////////////////
	 //Validation : a RLI can only have one item (SIM, SCN or PIN)
	 private void validateThatOneRLIHaveOnly1Document(){
	     Integer itemsCounter=0;
	     for(Receipt_Line_Item__c rli : (List<Receipt_Line_Item__c>)Trigger.new ){
	         itemsCounter=0;
	         if(rli.Invoice__c != null) itemsCounter++;
	         if(rli.Sales_Credit_Note__c != null) itemsCounter++;
	         if(rli.Partial_Invoice_Payment__c != null) itemsCounter++;  
	         if(rli.Payable_Invoice__c != null) itemsCounter++;
	           
	         if(itemsCounter != 1){
	             rli.adderror('One receipt line item can only have one invoice or one credit note or partial invoice payment');     
	         }
		 }
		 return;  
	 }
	 
	 //Validation : all RLI must be from the same Account
	 private void validateThatAllRLIHaveOnly1Account(List<Receipt_Line_Item__c> newRLIList){

		 for(Receipt_Line_Item__c rli : newRLIList ){
		     if(rli.Invoice__c != null && rli.Payment_Collection__r.Account__c != rli.Invoice__r.c2g__Account__c){
		          Trigger.newMap.get(rli.Id).adderror('The Invoice Account must be the same of the Payment Collection.');
		     }
		     if(rli.Sales_Credit_Note__c != null && rli.Payment_Collection__r.Account__c != rli.Sales_Credit_Note__r.c2g__Account__c){
		         Trigger.newMap.get(rli.Id).adderror('The Credit Note Account must be the same of the Payment Collection.');
		     }
		     if(rli.Payable_Invoice__c != null && rli.Payment_Collection__r.Account__c != rli.Payable_Invoice__r.c2g__Account__c){
		         Trigger.newMap.get(rli.Id).adderror('The Payable Invoice Account must be the same of the Payment Collection.');
		     }
		 }

		 return;   
	 }
	 
	 //validate if the RLI is already paid
	 private void validateRliPaid(List<Receipt_Line_Item__c> newRLIList){

		 for(Receipt_Line_Item__c rli : newRLIList ){
		     if(rli.Invoice__c != null && rli.Invoice__r.c2g__PaymentStatus__c == 'Paid'){
		          Trigger.newMap.get(rli.Id).adderror('The Invoice already in status paid.');
		     }
		     if(rli.Sales_Credit_Note__c != null && rli.Sales_Credit_Note__r.c2g__PaymentStatus__c == 'Paid'){
		         Trigger.newMap.get(rli.Id).adderror('The Credit Note  already in status paid.');
		     }
		     if(rli.Payable_Invoice__c != null && rli.Payable_Invoice__r.c2g__PaymentStatus__c == 'Paid'){
		         Trigger.newMap.get(rli.Id).adderror('The Payable Invoice already in status paid.');
		     }
		 }

		 return;   
	 }
	 

	 private void updateAmmountSepaRecords(List<Receipt_Line_Item__c> newRLIList, boolean validateOnly){
	 	Set<Id> paymentCollectionIdSet = new Set<Id>();

        for(Receipt_Line_Item__c rli : newRLIList){
        	paymentCollectionIdSet.add(rli.Payment_Collection__c);
        }

	 	system.debug('paymentCollectionIdSet' + paymentCollectionIdSet);
	    if(paymentCollectionIdSet.size() > 0){
		    List<CR_Sepa_Record__c> sepaRecordsList = [SELECT Id,
			                                                  Request_Amount__c, 
			                                                  Payment_Collection__c, 
			                                                  Payment_Collection__r.Total_Amount__c,
			                                                  CR_Sepa_File__c
			                                              FROM CR_Sepa_Record__c WHERE Payment_Collection__c = :paymentCollectionIdSet AND 	Invalid_Record__c = false];

            system.debug('sepaRecordsList' + sepaRecordsList);
		    Map<Id, Payment_Collection__c> pcMap = new Map<Id, Payment_Collection__c>([SELECT Id, (SELECT Id, Amount_Claimed__c FROM Receipt_Line_Items__r) FROM Payment_Collection__c WHERE Id IN :paymentCollectionIdSet]);
		                                              
			for(CR_Sepa_Record__c sepaRecord : sepaRecordsList ){
				decimal amount = 0;
				Payment_Collection__c payColl = pcMap.get(sepaRecord.Payment_Collection__c);
				for(Receipt_Line_Item__c rli : payColl.Receipt_Line_Items__r){
					amount += rli.Amount_Claimed__c;
					if(sepaRecord.CR_Sepa_File__c != null ){
						if((Trigger.isbefore == true && Trigger.isDelete == true) && Trigger.oldMap.get(rli.Id) != null){
					        Trigger.oldMap.get(rli.Id).adderror('You can not add/remove a Receipt Line Item if the SEPA has a SEPA File');
					    }
					    if((Trigger.isAfter == true && Trigger.isInsert == true) && Trigger.newMap.get(rli.Id) != null){
					        Trigger.newMap.get(rli.Id).adderror('You can not add/remove a Receipt Line Item if the SEPA has a SEPA File');
					    }
					}
					
				}

				sepaRecord.Request_Amount__c = math.abs(amount);
			}
            
            if(validateOnly == false){
			    update sepaRecordsList;
            }
				
		}
		
	 }

	 private void validatePCStatusInsert(List<Receipt_Line_Item__c> newRLIList){
	 	
	 	for(Receipt_Line_Item__c rli : newRLIList){
		    if(rli.Payment_Collection__r.Status__c != 'In Payment' ){
				Trigger.newMap.get(rli.Id).adderror('You can not add/remove a Receipt Line Item if the Payment collection is not in \'In Payment\'');	    
			}
	 	}
		return;
	 }
	 
	 private void validatePCStatusDelete(List<Receipt_Line_Item__c> newRLIList){
	 	
	 	for(Receipt_Line_Item__c rli : newRLIList){
		    if(rli.Payment_Collection__r.Status__c != 'In Payment' ){
				Trigger.oldMap.get(rli.Id).adderror('You can not add/remove a Receipt Line Item if the Payment collection is not in \'In Payment\'');	    
			}
	 	}
		return;
	 }
	 
}
