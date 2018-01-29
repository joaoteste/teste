public class Invocable_UpdateFirstApplication {
    @InvocableMethod 
    public static void UpdateFirstApplication(List<Application__c> App){
        list<Account> acc = [SELECT id, First_Application__c FROM Account WHERE id=:App[0].Vendor__c];
        if(!acc[0].First_Application__c){
            acc[0].First_Application__c = true;
            update acc;
        }
    }

}