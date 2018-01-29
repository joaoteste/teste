public class Queueable_ProcPayableInvoices implements Queueable {

	private ID appVinvID;
	private boolean post = false;

    public Queueable_ProcPayableInvoices(ID appVinvID){
        this.appVinvID = appVinvID;
    }

    public Queueable_ProcPayableInvoices(ID appVinvID, boolean post){
        this.appVinvID = appVinvID;
        this.post = post;
    }

	public void execute(QueueableContext context) {
       
        try{
            
            List<Vendor_Invoice__c> vendorInvoiceList = [SELECT ID, NAME, Due_Date__c,Invoice_Date__c,Invoice_Total__c,Status__c,Submitted__c,
                                                         Submitted_Date__c, Vendor_Invoice_Number__c, Application__c, Account__c, Account__r.c2g__CODAAccountsPayableControl__c,Account__r.Type,
                                                         Account__r.c2g__CODAOutputVATCode__c, Tax_Code__c, Account__r.Name, Account__r.c2g__CODADefaultExpenseAccount__c, Application__r.Name,
                                                         Invoice_Net__c, Application__r.Invoice_Payment_Date__c
                                                         FROM Vendor_Invoice__c
                                                         WHERE (Application__c=:appVinvID or id = :appVinvID) AND Submitted__c=true AND Status__c = 'Draft']; 
            
            Vendor_Invoice__c vendorInvoice = new Vendor_Invoice__c();
            
            if(vendorInvoiceList.size()==0){
    			Utilities.LogIntegration( Datetime.now(), Datetime.now(),'ERRO' , 'VENDOR_INVOICE', vendorInvoiceList.size() + ' Vendor Invoice is not submitted or does not exit',appVinvID);
    			return;
    		}     									  

	 		PayableInvoiceHandler pih = new PayableInvoiceHandler();
	 		List<c2g__codaPurchaseInvoice__c> payableInvoiceList  = pih.createPayableInvoiceFromVendorInvoice(vendorInvoiceList);
	 		c2g__codaPurchaseInvoice__c payableInvoice = payableInvoiceList[0];
           
            //Se post colocado a true faz POST das payable invoices e gera as transactions
           	if(post){
        		c2g.CODAAPICommon.Reference refPayableInvoice = new c2g.CODAAPICommon.Reference();
            	refPayableInvoice.Id = payableInvoice.Id;  
            	system.debug('[Queueable_ProcPayableInvoices] - journal ref ' + payableInvoice.id);
            	c2g.CODAAPIPurchaseInvoice_6_0.PostPurchaseInvoice(null,refPayableInvoice);
           	}
            Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'Success', 'VENDOR_INVOICE', payableInvoice.ID, appVinvID);
    	}catch(exception e){
    		Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'ERRO', 'VENDOR_INVOICE', 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString(), appVinvID);
    		
            System.debug('[Queueable_ProcPayableInvoices] - Error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
    		
			String[] toAddresses = new List<String>();  
            //toAddresses.add('sf.candor@worldit.pt');  
            //toAddresses.add('info@candor.pt');
           	toAddresses.add('pcaetano@candor.pt');
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setSubject('Error Generating Payable Invoice for ' + appVinvID );  
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage()+' \n Stack trace: ' + e.getStackTraceString());
            //if(![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox){
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
			//}
    	}
	}
}