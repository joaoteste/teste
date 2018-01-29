global class SEPA_GL_Web_Services {

    webservice static String generateXMLFromSepaFile(String sepaFileName) {
        return SEPA_SF_to_XML.generateXMLFromSepaFile(sepaFileName);
    }
    
    webservice static String generateSepaRecord(Id sepaRecord) {
        String msg = '';
        
        List<CR_Sepa_Record__c> CR_Sepa_RecordList = [SELECT Id, Sales_Invoice__c FROM CR_Sepa_Record__c WHERE Id = :sepaRecord];
        if(CR_Sepa_RecordList.size() != 1){
            msg = 'The CR_Sepa_RecordList must have only 1 record';
            system.debug(msg);
            return msg;
        }
         
        Set<Id> toCreatePayCollIDsSet = new Set<Id>();
        toCreatePayCollIDsSet.add(CR_Sepa_RecordList.get(0).Sales_Invoice__c);
        //TODO só está a funcionar para sales invoice. fazer alterações para funcionar com todos os tipos de SEPA records.
        //key Account Id
        Map<String, Payment_Collection__c > paymentColectionPerAccountMap = SEPA_SI_to_SR.createPaymentCollectionWithSEPAFromSalesInvoice(toCreatePayCollIDsSet);

        // ver para que link vou depois de criar
        if(paymentColectionPerAccountMap.values().size() == 0){
            msg = 'No SEPA Record created, please check the error with IT team.';
        }else{
          
          CR_Sepa_Record__c auxSepaRecord = [SELECT Id FROM CR_Sepa_Record__c WHERE Payment_Collection__c = :paymentColectionPerAccountMap.values().get(0).Id LIMIT 1];
            msg = 'The SEPA Record with id: ' + auxSepaRecord.Id + ' was created';
        }
        return msg;
        
    }
    
    webservice static String importAttachments(Id importSource){

        // SEPA_ImportSentRequestFiles.importAttachments(importSource);
        return (new SEPA_ImportFromReturnFile()).importReturnFileAndCreateSEPARecords(importSource);

    }  

    //Botão Create SEPA in SIN
    webservice static String generatePaymentCollectionSIN(Id invoiceID) {
    	
    	Set<Id> turnedToCompletedIDs = new Set<Id>();
        turnedToCompletedIDs.add(invoiceID);
        Map<String, Payment_Collection__c > paymentCollectionMap = SEPA_SI_to_SR.createPaymentCollectionWithSEPAFromSalesInvoice(turnedToCompletedIDs);
 
        if(paymentCollectionMap == null || paymentCollectionMap.values().size() == 0 ){
        	return 'The Payment Collection was not created, please check all data';
        }
        
        if(paymentCollectionMap.values().size() == 1 ){
        	Payment_Collection__c payment_collection = paymentCollectionMap.values().get(0);
        	payment_collection = [Select Id, Name FROM Payment_Collection__c WHERE Id = :payment_collection.Id];
        	return 'The Payment collection: ' + payment_collection.Name + ' was created (ID: ' + payment_collection.Id + ')';
        }
        
    	return '?? WTF ?? this should never happens';
    }

    webservice static Boolean checkIfSinHasPCOpenOrInPayment(Id invoiceID) {
    	
    	List<Receipt_Line_Item__c> recLineItemList = [SELECT Invoice__c,Payable_Invoice__c, Payment_Collection__r.Status__c ,Payment_Collection__c,Sales_Credit_Note__c FROM Receipt_Line_Item__c WHERE Invoice__c = :invoiceID AND (Payment_Collection__r.Status__c = 'Paid' OR Payment_Collection__r.Status__c = 'In Payment')];
    	
    	if(recLineItemList.size() > 0){
    		return true;
    	}else{
    	    return false;	
    	}
    	
    }
    
    //Botão Create SEPA in SCN
    webservice static String generatePaymentCollectionSCN(Id scnID) {
    	
    	Set<Id> turnedToCompletedIDs = new Set<Id>();
        turnedToCompletedIDs.add(scnID);
        Map<Id, Payment_Collection__c > paymentCollectionMap = SEPA_SCN_to_SR.addSRFromSCNs(turnedToCompletedIDs);
 
        if(paymentCollectionMap == null || paymentCollectionMap.values().size() == 0 ){
        	return 'The Payment Collection was not created, please check all data.';
        }
        
        if(paymentCollectionMap.values().size() == 1 ){
        	Payment_Collection__c payment_collection = paymentCollectionMap.values().get(0);
        	payment_collection = [Select Id, Name FROM Payment_Collection__c WHERE Id = :payment_collection.Id];
        	return 'The Payment collection: ' + payment_collection.Name + ' was created (ID: ' + payment_collection.Id + ')';
        }
        
    	return '?? WTF ?? this should never happens';
    }

    webservice static Boolean checkIfSCNHasPCOpenOrInPayment(Id scnID) {
    	
    	List<Receipt_Line_Item__c> recLineItemList = [SELECT Invoice__c,Payable_Invoice__c, Payment_Collection__r.Status__c ,Payment_Collection__c,Sales_Credit_Note__c FROM Receipt_Line_Item__c WHERE Sales_Credit_Note__c = :scnID AND (Payment_Collection__r.Status__c = 'Paid' OR Payment_Collection__r.Status__c = 'In Payment')];
    	
    	system.debug(recLineItemList);
    	if(recLineItemList.size() > 0){
    		return true;
    	}else{
    	    return false;	
    	}
    	
    }
    
    //Botão Create SEPA in PIN
    webservice static String generatePaymentCollectionPIN(Id pinID) {
    	
    	Set<Id> turnedToCompletedIDs = new Set<Id>();
        turnedToCompletedIDs.add(pinID);
        Map<Id, Payment_Collection__c > paymentCollectionMap = SEPA_PI_to_SR.addSRFromPIs(turnedToCompletedIDs);
 
        if(paymentCollectionMap == null || paymentCollectionMap.values().size() == 0 ){
        	return 'The Payment Collection was not created, please check all data';
        }
        
        if(paymentCollectionMap.values().size() == 1 ){
        	Payment_Collection__c payment_collection = paymentCollectionMap.values().get(0);
        	payment_collection = [Select Id, Name FROM Payment_Collection__c WHERE Id = :payment_collection.Id];
        	return 'The Payment collection: ' + payment_collection.Name + ' was created (ID: ' + payment_collection.Id + ')';
        }
        
    	return '?? WTF ?? this should never happens';
    }

    webservice static Boolean checkIfPINHasPCOpenOrInPayment(Id pinID) {
    	
    	List<Receipt_Line_Item__c> recLineItemList = [SELECT Invoice__c,Payable_Invoice__c, Payment_Collection__r.Status__c ,Payment_Collection__c,Sales_Credit_Note__c FROM Receipt_Line_Item__c WHERE Payable_Invoice__c = :pinID AND (Payment_Collection__r.Status__c = 'Paid' OR Payment_Collection__r.Status__c = 'In Payment')];
    	
    	if(recLineItemList.size() > 0){
    		return true;
    	}else{
    	    return false;	
    	}
    	
    }

}