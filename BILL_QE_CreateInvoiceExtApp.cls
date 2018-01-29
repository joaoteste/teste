// The test class used is: BILL_MoloniAPITest 
public class BILL_QE_CreateInvoiceExtApp implements queueable, database.allowsCallouts {

    public ID invoiceID;
    
    public BILL_QE_CreateInvoiceExtApp(ID invoiceID){
        this.invoiceID = invoiceID;
    }
    
    public void execute(QueueableContext ctx){

        String msg=(new BILL_MoloniApi()).createInvoiceMoloniFinalized(this.invoiceID);
        
        //create SEPA record to add again in  trigger Create_Interest_trs_viaBilling
        Set<Id> invoiceIdSet = New Set<Id>();
        invoiceIdSet.add( this.invoiceID );
        SEPA_SI_to_SR.createPaymentCollectionWithSEPAFromSalesInvoice(invoiceIdSet);
    }
}