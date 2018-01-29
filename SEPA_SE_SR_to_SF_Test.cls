@isTest (SeeAllData=true)
public class SEPA_SE_SR_to_SF_Test {

    @isTest (SeeAllData=true)
    static void test_SEPA_SE_SR_to_SF() {
    
        //Account account = [SELECT Id FROM Account WHERE Id];
        Id accountId = '0012400000Z7ktT';
    
        CR_Sepa_Record__c sepaRecord = new CR_Sepa_Record__c( Document_Due_Date__c = system.today()
            , Document_Type__c = 'RCUR', Activation_Date__c  = system.today()
            , Debtor_Account__c = accountId , Debtor_Name__c = 'xpto'
            , IBAN__c = 'PT50001800034034367502010', Invoice_Number__c = 'xpto2'
            , Mandate_Date__c = system.today(), Mandate_Identification__c = 'xpto3'
            , Request_Count__c = 1, Request_Amount__c = 21
            , Request_Currency__c = 'EUR', Request_DateTime__c = system.today()
            , Return_Amount__c = 8, Return_Currency__c = 'EUR'
            , Return_DateTime__c = system.today()
            ,  Swift_Bic__c = 'TOTAPTPL');
        insert sepaRecord;

        test.startTest();
        SEPA_SE_SR_to_SF.scheduleIt('SEPA_SE_SR_to_SF_Test'+Datetime.now(), '0 30 14 * * ?');
        test.stopTest();
    }    
}