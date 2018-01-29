//Test Trigger_AC_FinalizeContract_Test
public class AC_FinalizeContract {

    	public static void execute(List<ID> acIDList){
            if(acIDList!=null){
                List<AssignmentContract__c> acList = [SELECT ID, Payment_Collection__c, Payment_Collection__r.Status__c, New_Client_Payment_Collection__c,  New_Client_Payment_Collection__r.Status__c, Contract_Signed_Date__c FROM AssignmentContract__c WHERE ID in :acIDList];
                
                for(AssignmentContract__c ac : acList){
                    ac.Contract_Signed_Date__c = system.today();
                    if(ac.Payment_Collection__c != null && ac.New_Client_Payment_Collection__c != null && ac.Payment_Collection__r.Status__c == 'Paid' && ac.New_Client_Payment_Collection__r.Status__c == 'Paid' ||
                       ac.Payment_Collection__c == null &&  ac.New_Client_Payment_Collection__r.Status__c == 'Paid' ||
                       ac.New_Client_Payment_Collection__c == null && ac.Payment_Collection__r.Status__c == 'Paid')
                        AC_AssignmentContractAPI.finalizeAssignmentOfContract(ac.ID);
                }
                
                update acList;
            }              
        }
}