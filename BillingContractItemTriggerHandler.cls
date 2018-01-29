public class BillingContractItemTriggerHandler extends TriggerHandler{

    public BillingContractItemTriggerHandler(){
        
    }
    
    /**************************************************************************************************/
    /*                                      Trigger Methods                                           */
    /**************************************************************************************************/
    public static void afterUpdateTrigger(List<Billing_Contract_Line_Item__c> newBCLItemList , Map<Id,Billing_Contract_Line_Item__c> oldBCLItemMap){
        
        List<ID> billingItensInvoicedList = new List<ID>();
        
        for(Billing_Contract_Line_Item__c billItem : newBCLItemList){
            if(oldBCLItemMap.get(billItem.id).Invoiced__c == false && billItem.Invoiced__c == true){
                billingItensInvoicedList.add(billItem.id);
            }
        }
        
        if(!billingItensInvoicedList.isEmpty()){
            UTIL_CancelAndCreateJournals.createJournalsListBLI(billingItensInvoicedList);
        }
        
    }
}