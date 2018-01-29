//this job ensures that the invoices are completed everyday.
//Generates the PIN associated with vendor Invoice

global class VendorInvoice_completeInvoice implements Schedulable {
    //everyday at 23:00
    global void execute(SchedulableContext ctx) {
        
        String query = 'SELECT ID, NAME,Invoice_Date__c,Due_Date__c,Invoice_Total__c,Status__c, ';
        query += 'Submitted__c,Submitted_Date__c, Vendor_Invoice_Number__c, Application__c, Account__c, ';
        query += 'Account__r.c2g__CODAAccountsPayableControl__c,Account__r.c2g__CODAOutputVATCode__c, Account__r.Type,';
        query += 'Tax_Code__c, Account__r.Name, Account__r.c2g__CODADefaultExpenseAccount__c, Application__r.Invoice_Payment_Date__c, ';
        query += 'Application__r.Name, Invoice_Net__c ';
        query += 'FROM Vendor_Invoice__c ';
        query += 'WHERE Submitted__c=true AND Status__c=\'Draft\' AND CreatedDate > 2018-01-29T00:00:00.000Z';
        
        PayableInvoiceHandler pih = new PayableInvoiceHandler(query);
        Id batchJobId = Database.executeBatch(new PayableInvoiceHandler(query, true), 30);
        
    }  	  

}