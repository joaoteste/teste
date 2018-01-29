public class Queueable_Create_due_sales_invoice implements queueable, database.allowsCallouts {    
    
    private ID billID;
    
    public Queueable_Create_due_sales_invoice(ID billID){
        this.billID = billID;
    }
    
    public void execute(QueueableContext ctx){
        if(billID!=null){     
            BillingProcess.Create_Due_Sales_invoice(billID);
        }
    }
}