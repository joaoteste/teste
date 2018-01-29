global class Executive_Action_Factory {
    
    webservice static String createExecutiveActionForCollectionCase(Id ccId){
        List<Executive_Action_Procedure__c> exec = [SELECT Id, Name FROM Executive_Action_Procedure__c WHERE Collection_Case__c = :ccId];
        if(exec.size() > 0){
            return 'There is already an Executive Action for this Collection Case '+exec[0].Name;
        }
        else{
            Executive_Action_Procedure__c action = new Executive_Action_Procedure__c();
            action.Collection_Case__c = ccId;
            insert action;
            
            return 'Created Executive Action Successfully';
        }
    }

}