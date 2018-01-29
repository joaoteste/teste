public class AC_Controler_ListOfUnpaidInvoices {
	
	public List<c2g__codaInvoice__c> unpaidInvoices {get; set;}
	private ApexPages.StandardController standardController;
	
	public AC_Controler_ListOfUnpaidInvoices(ApexPages.StandardController standardController){
        this.standardController = standardController;
        ID acID = standardController.getId();
        AssignmentContract__c ac = [SELECT ID, Old_Client_Account__c FROM AssignmentContract__c WHERE ID = :acID];
        unpaidInvoices = [SELECT ID, c2g__DueDate__c,c2g__Account__c,  c2g__ExternalId__c, c2g__InvoiceDescription__c,c2g__PaymentStatus__c, c2g__InvoiceDate__c, Invoice_Link__c, Name FROM c2g__codaInvoice__c WHERE c2g__Account__c = :ac.Old_Client_Account__c AND c2g__PaymentStatus__c = 'Unpaid'];
    }	
    
}