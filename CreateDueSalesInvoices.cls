public class CreateDueSalesInvoices implements Schedulable{

/*    public static String scheduleIt(String CRON_EXP) {
        CreateDueSalesInvoices cdsi = new CreateDueSalesInvoices();
        return System.schedule('Create Due Sales Invoices', CRON_EXP, cdsi);
    }
*/
    public void execute(SchedulableContext sc) {
      
        BILL_BH_CreateDueSalesInvoices createDueSalesInvoicesBatch = new BILL_BH_CreateDueSalesInvoices(0);
        ID batchprocessid = Database.executeBatch(createDueSalesInvoicesBatch, 1);

    }
    
}