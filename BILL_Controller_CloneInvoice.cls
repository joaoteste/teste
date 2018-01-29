public class BILL_Controller_CloneInvoice implements Database.AllowsCallouts{
    private ApexPages.StandardSetController standardController;
    public ID siID {get;set;}	
    public c2g__codaInvoice__c salesInvoice {get; set;}
    public String name {get; set;}
    public Boolean rendered {get; set;}
    public Boolean notRendered {get; set;}
    
	public BILL_Controller_CloneInvoice(ApexPages.StandardSetController standardController) { 
        this.standardController = standardController;
        standardController.setPageSize(10);

        List<c2g__codaInvoice__c> m_Invoices = this.standardController.getSelected();  
        if(m_Invoices!= null && m_Invoices.size() == 1){
            
                rendered = true;
                salesInvoice = new c2g__codaInvoice__c();
                siID =  m_Invoices[0].ID;
                system.debug(siID);
                c2g__codaInvoice__c siOld = [select id, name, c2g__InvoiceCurrency__c, c2g__Account__c, c2g__InvoiceDescription__c, c2g__CustomerReference__c, Application__c from c2g__codaInvoice__c where id = :siID];
                system.debug(siOld);
                salesInvoice.c2g__Account__c = siOld.c2g__Account__c;
                salesInvoice.Application__c = siOld.Application__c;
                salesInvoice.c2g__DueDate__c = System.today();
                salesInvoice.c2g__InvoiceDate__c = System.today();
                salesInvoice.c2g__InvoiceCurrency__c = siOld.c2g__InvoiceCurrency__c;
            	salesInvoice.c2g__InvoiceDescription__c = siOld.c2g__InvoiceDescription__c;
            	salesInvoice.c2g__CustomerReference__c = siOld.c2g__CustomerReference__c;
                name = siOld.Name;
            
        }else{rendered = false; notRendered = true;}

    }
    
    public PageReference cloneInvoice(){

            String result = BILL_CloneInvoice.cloneInvoice(siID, salesInvoice);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Done'));
            return (new PageReference('/'+salesInvoice.ID));
    }
    
    public PageReference GoBack(){

            return (new PageReference('/a2y'));
    }    
    
    
}