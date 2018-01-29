public class Trigger_AC_FinalizeContractC {
	
    public static void execute(List<ID> pcIDList){

            if(!pcIDList.isEmpty()){
                List<AssignmentContract__c> acFullList = new List<AssignmentContract__c>();
                
                List<AssignmentContract__c> acList = [SELECT ID, Payment_Collection__c, Contract_Signed_Date__c, New_Client_Payment_Collection__r.Status__c, Payment_Collection__r.Status__c, TypeOfAssignContract__c FROM AssignmentContract__c WHERE Payment_Collection__c in :pcIDList];
                List<AssignmentContract__c> acList2 = [SELECT ID, Payment_Collection__c, Contract_Signed_Date__c, New_Client_Payment_Collection__r.Status__c, Payment_Collection__r.Status__c, TypeOfAssignContract__c FROM AssignmentContract__c WHERE New_Client_Payment_Collection__c in :pcIDList];    
                
                if(!acList.isEmpty())
                    acFullList.addAll(acList);
                if(!acList2.isEmpty()) 
                    acFullList.addAll(acList2);
               
                //finalize contracts 
                if(!acFullList.isEmpty()){
                    for(AssignmentContract__c ac : acFullList){
                        if(ac.Payment_Collection__c != null && ac.New_Client_Payment_Collection__c != null && ac.Payment_Collection__r.Status__c == 'Paid' && ac.New_Client_Payment_Collection__r.Status__c == 'Paid' ||
                           ac.Payment_Collection__c == null &&  ac.New_Client_Payment_Collection__r.Status__c == 'Paid' ||
                           ac.New_Client_Payment_Collection__c == null && ac.Payment_Collection__r.Status__c == 'Paid'){
                            if(ac.TypeOfAssignContract__c == 'Merged Company' || ac.TypeOfAssignContract__c != 'Merged Company' && ac.Contract_Signed_Date__c != null)
                                AC_AssignmentContractAPI.finalizeAssignmentOfContract(ac.ID);
                           }
                    }
                }
            }
    }
}