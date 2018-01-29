@isTest (SeeAllData=true)
private class SEPA_GL_Web_Services_Test {

    // test addDirectDebitXMLtoDocument
    static testMethod void generateXMLFromSepaFileTest1() {
    	
    	CR_Sepa_File__c sepaFile = [SELECT Id, Name FROM CR_Sepa_File__c WHERE id = 'a6o240000008Sf4'];
        SEPA_GL_Web_Services.generateXMLFromSepaFile(sepaFile.Name);

    }
    
    // test addPaymentsXMLtoDocument
    static testMethod void generateXMLFromSepaFileTest2() {
    	
    	CR_Sepa_File__c sepaFile = [SELECT Id, Name FROM CR_Sepa_File__c WHERE id = 'a6o240000008SkS'];
        SEPA_GL_Web_Services.generateXMLFromSepaFile(sepaFile.Name);

    }
    
    //TODO remake this test is horrible !!!!!!!!!!!1
/*    static testMethod void generateSepaRecordTest() {
    	String sepaRecord = 'a6q24000000LBpX';
        SEPA_GL_Web_Services.generateSepaRecord(sepaRecord); 
    }
*/    
    //TODO remake this test is horrible !!!!!!!!!!!2
    static testMethod void importAttachmentsTest() {
        Id sepaFileId = 'a6o240000008TJm';
        SEPA_GL_Web_Services.importAttachments(sepaFileId); 
    }
 ////////////   
    

    static testMethod void generatePaymentCollectionSINTest() {
    	
    	c2g__codaInvoice__c sin = [Select Id, Name FROM c2g__codaInvoice__c LIMIT 1];
        SEPA_GL_Web_Services.generatePaymentCollectionSIN(sin.Id);

    }
    
    static testMethod void checkIfSinHasPCOpenOrInPaymentTest() {
    	
    	Payment_Collection__c payment_collection = [Select Id, Name FROM Payment_Collection__c LIMIT 1];
        SEPA_GL_Web_Services.checkIfSinHasPCOpenOrInPayment(payment_collection.Id);

    }
    
    static testMethod void generatePaymentCollectionSCNTest() {
    	
    	c2g__codaCreditNote__c scn = [Select Id, Name FROM c2g__codaCreditNote__c LIMIT 1];
        SEPA_GL_Web_Services.generatePaymentCollectionSCN(scn.Id);

    }
    
    static testMethod void checkIfSCNHasPCOpenOrInPaymentTest() {
    	
    	Payment_Collection__c payment_collection = [Select Id, Name FROM Payment_Collection__c LIMIT 1];
        SEPA_GL_Web_Services.checkIfSCNHasPCOpenOrInPayment(payment_collection.Id);

    }
    
    static testMethod void generatePaymentCollectionPINTest() {
    	
    	c2g__codaPurchaseInvoice__c pin = [Select Id, Name FROM c2g__codaPurchaseInvoice__c LIMIT 1];
        SEPA_GL_Web_Services.generatePaymentCollectionPIN(pin.Id);

    }
    
    static testMethod void checkIfPINHasPCOpenOrInPaymentTest() {
    	
    	Payment_Collection__c payment_collection = [Select Id, Name FROM Payment_Collection__c LIMIT 1];
        SEPA_GL_Web_Services.checkIfPINHasPCOpenOrInPayment(payment_collection.Id);

    }
    
   
}