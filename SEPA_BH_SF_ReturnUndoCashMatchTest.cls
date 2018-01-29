@isTest (SeeAllData=true)
public class SEPA_BH_SF_ReturnUndoCashMatchTest{

    static testMethod void testBatch() {

        test.startTest();
        
        CR_Sepa_File__c sepaFile = [SELECT Id, Name, SEPA_Our_Bank_IBAN__c FROM CR_Sepa_File__c WHERE ID = 'a6o24000000L2QS'];  //a6o9E0000004Cb6
        
        c2g__codaBankAccount__c bankAccount = SEPA_UTILS.getBankAccountFromIban(sepaFile.SEPA_Our_Bank_IBAN__c);
        
        
        Map<ID, CR_Sepa_Record__c> sepaRecIdMap = new Map<ID, CR_Sepa_Record__c>([SELECT Id FROM CR_Sepa_Record__c WHERE CR_Sepa_File__c = :sepaFile.id limit 1]);
        
        Id cashEntryId = 'a2L24000000pFYOEA2';
        List<Id> sepaRecIdList = new List<Id>(sepaRecIdMap.keyset());
        c2g__codaCashEntry__c cashEntry  = [SELECT Id FROM c2g__codaCashEntry__c WHERE ID = :cashEntryId];
        Map<String, SEPA_TxInfAndSts> txInfAndStssMap = null;

        
        SEPA_BH_SF_ReturnUndoCashMatch bh = new SEPA_BH_SF_ReturnUndoCashMatch( sepaRecIdList, cashEntry, txInfAndStssMap, sepaFile, bankAccount);

        Id batchJobId = Database.executeBatch(bh, 1);
         
        test.stopTest();
    }    
    
}