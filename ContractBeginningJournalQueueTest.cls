@isTest (SeeAllData=true)
public class ContractBeginningJournalQueueTest {

    @isTest
    public static void contractBeginningTest (){
        Application__c app = [Select ID FROM Application__c where status__c = 'Contract - Running' limit 1];
        System.enqueueJob(new ContractBeginningJournalQueue(app.id));
    }   
    
}