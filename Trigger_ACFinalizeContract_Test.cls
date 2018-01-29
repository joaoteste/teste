@isTest
public class Trigger_ACFinalizeContract_Test {
	
    @isTest
    public static void testTrigger(){
        AssignmentContract__c ac = new AssignmentContract__c();
        insert ac;
        Test.startTest();
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.Assignment_of_Contract__c = ac.ID;
        insert ds;
        ds.dsfs__Envelope_Status__c = 'Completed';
        update ds;
        Test.stopTest();
    }
    
}