@isTest
public class BillingContractLineItemTriggerTest {
    
    //select billing line itens with the field invoiced uncheck. It update to check and should create the corresponding journals
    @isTest (SeeAllData = true)
    public static void createJournalsByInvoicedFalseTest(){
        Test.startTest();
        List<Billing_Contract_Line_Item__c> billItemList = new List<Billing_Contract_Line_Item__c>([Select Id,Name,Invoiced__c 
                                                                                                    From Billing_Contract_Line_Item__c 
                                                                                                    where Invoiced__c = false and Line_Item_End_Date__c > Today and ((Product_code__c='PT02' OR  Product_code__c='PT11' OR 
                                                                                                                                                                      Product_code__c='PT18' OR  Product_code__c='PT19'))
                                                                                                    limit 2 ]);
        billItemList.addAll([Select Id,Name,Invoiced__c 
                             From Billing_Contract_Line_Item__c 
                             where Invoiced__c = false and Line_Item_End_Date__c > Today and Interest__c!=0 And Interest__c!=null
                             limit 2]);
        
        System.debug('billItemList false ' + billItemList);
        for(Billing_Contract_Line_Item__c billingItem : billItemList){
            billingItem.Invoiced__c = true;
        }
        System.debug('billItemList to update to true ' + billItemList);

        update billItemList;
        Test.stopTest();
    }
        
}