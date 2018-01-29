@isTest (SeeAllData=true)
public class SEPA_ImportFromReturnFileTest {
    
    static testMethod void importSentRequestFiles1() {
        CR_Sepa_File__c sepaFile = [SELECT Id, SEPA_Tag_xmlns__c FROM CR_Sepa_File__c WHERE id = 'a6o240000008TJm' /* SEPA_Tag_xmlns__c = 'urn:iso:std:iso:20022:tech:xsd:pain.008.001.02' AND Request_DateTime__c != null limit 1 */];
        system.debug('rrrrrrrrrr' + sepaFile.id);
        SEPA_GL_Web_Services.importAttachments(sepaFile.id);
    }
   
/*    static testMethod void importSentRequestFiles() {
        CR_Sepa_File__c sepaFile = [SELECT Id, SEPA_Tag_xmlns__c FROM CR_Sepa_File__c WHERE SEPA_Tag_xmlns__c = 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.03' limit 1];
        SEPA_GL_Web_Services.importAttachments(sepaFile.id);
    }
*/    
    
    
     @isTest 
     static void testdummy() {
     	
       test.startTest();
       SEPA_ImportFromReturnFile.dummy();
       test.stopTest(); 
    }
}