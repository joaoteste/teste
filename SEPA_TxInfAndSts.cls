// Used in the processing of the return file
// test class SEPA_SF_Return_Test
public class SEPA_TxInfAndSts {
	
        public SEPA_TxInfAndSts(string invoice, string ReqdColltnDt, string status, string bankTrnId, string paid) {
            system.debug(LoggingLevel.INFO, 'Adding TxInfAndSts, invoice: ' + invoice + ' status: ' + status + ' bankTrnId: ' + bankTrnId + ' paid: ' + paid);
            this.invoice = invoice;
            this.ReqdColltnDt = ReqdColltnDt;
            this.status = status;
            this.bankTrnId = bankTrnId;
            this.paid = paid;
        }
         
        public String invoice { get; set; }
        public String ReqdColltnDt { get; set; }
        public String status { get; set; }
        public String bankTrnId { get; set; }
        public String paid { get; set; }
       // public c2g__codaCashEntryLineItem__c CashEntryLineItem { get; set; }
	
}