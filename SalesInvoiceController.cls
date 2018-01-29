public class SalesInvoiceController {
    
    public c2g__codaInvoice__c salesInvoice {get; private set;}
    public list<Contact> InvoiceEmail {get; private set;}
    public c2g__codaTransaction__c siTransaction {get; private set;}
    public List<c2g__codaInvoiceLineItem__c> salesinvoiceLI {get; private set;}
    public List<taxCodeWrapper> taxWrapperList {get; private set;}
  
    public Id siId {get; private set;}
    
    public List<Integer> iter {
        get {
            integer i=0;
            List<Integer> integerList = new List<Integer>();
            for(taxCodeWrapper taxWrapper: taxWrapperList){
                integerList.add(i);
                i++;
            }
            return integerList;
        }
        set;
    }

        
    public SalesInvoiceController() {
        InvoiceEmail = new List<Contact>();
        salesinvoiceLI = new List<c2g__codaInvoiceLineItem__c>();
    	List<c2g__codaTransaction__c> siTransactionList = new List<c2g__codaTransaction__c>();
    
        
        salesInvoice = [SELECT Id, Name, c2g__TaxTotal__c, c2g__NetTotal__c, c2g__InvoiceTotal__c, Application__r.Tax_Rate__c, 
                        Application__r.AccClient__r.Tax_Zone__c, c2g__Account__c, c2g__BillingAddress__c, c2g__FirstDueDate__c,
                        c2g__DueDate__c, c2g__InvoiceCurrency__c, c2g__GenerateAdjustmentJournal__c, c2g__CustomerReference__c,
                        c2g__Period__r.name, c2g__InvoiceDescription__c, c2g__DiscardReason__c, c2g__InvoiceStatus__c,    
                        c2g__PaymentStatus__c, c2g__OutstandingValue__c,c2g__Tax1Total__c, Payment_Method__c
 						FROM c2g__codaInvoice__c
                        WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
                        
        siId = salesInvoice.Id;
        InvoiceEmail = [SELECT Email From Contact WHERE AccountID =:salesInvoice.c2g__Account__c AND Send_Invoice__c = true];
        
      	siTransactionList= [SELECT id, name FROM c2g__codaTransaction__c WHERE c2g__SalesInvoice__c =:salesInvoice.ID]; 
      	if(siTransactionList.size()>0){
      		siTransaction = siTransactionList[0];
      	}
		
		
	 	salesinvoiceLI = [SELECT c2g__Product__r.name, c2g__Product__r.ProductCode, c2g__Quantity__c,  
                      c2g__UnitPrice__c, c2g__TaxCode1__r.name, c2g__TaxRate1__c, c2g__NetValue__c, 
                      c2g__CalculateIncomeSchedule__c,  c2g__IncomeScheduleGroup__c ,c2g__TaxValue1__c
                      FROM c2g__codaInvoiceLineItem__c 
                      WHERE c2g__Invoice__c =:salesInvoice.ID ];
    
        
        getTaxSumary();
    }
    
    private void getTaxSumary(){  
        Set<String> taxCodeSet = new Set<String>();
        taxWrapperList = new List<taxCodeWrapper>();
        for(c2g__codaInvoiceLineItem__c sili: salesinvoiceLI){
            taxCodeSet.add(sili.c2g__TaxCode1__r.name);
        }     
        double netValue = 0;
        double taxValue = 0;
        double taxRate;
        for(String taxCode: taxCodeSet){
            for(c2g__codaInvoiceLineItem__c  silitem :salesinvoiceLI){
                if(silitem.c2g__TaxCode1__r.name == taxCode){
                    netValue = netValue + silitem.c2g__NetValue__c;
                    taxValue = taxValue + silitem.c2g__TaxValue1__c;
                    taxRate = silitem.c2g__TaxRate1__c;
                }                
            }
            taxCodeWrapper txWrapper = new taxCodeWrapper(taxCode, ''+netValue, ''+taxValue, ''+taxRate);
            taxWrapperList.add(txWrapper);
            netValue = 0;
            taxValue = 0;
        }
    }
    
    /* Wrapper Class to aggregate info related to the Tax Summary Field
     */
    public class taxCodeWrapper{
        public string taxCode {get; set;}
        public string netValue {get; set;}
        public string taxValue {get; set;}
        public string taxRate {get; set;}
      
        public taxCodeWrapper(String taxCodeParam, String netValueParam, String  taxValueParam, String taxRateParam){
            taxCode = taxCodeParam;
            netValue = netValueParam;
            taxValue = taxValueParam;
            taxRate = taxRateParam;

        }
    }
   
    
    
    
}