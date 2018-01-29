public class Queueable_ProcBilling implements queueable, database.allowsCallouts {
    
    public ID appID;
    
    public Queueable_ProcBilling(ID appID){
        this.appID = appID;
    }

    public void execute(QueueableContext ctx){
        
        list<Application__c> applist=[select id from application__c where generate_billing__c=true AND ID = :appID order by createdDate Desc Limit 1];
        
        for( application__c app: applist){
            //BillingProcess.Create_Billing_Invoice(app.id);
            (new BILL_BillingProcess()).createBillingInvoice(app.id);
        }     
    }
}