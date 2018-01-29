global class Criminal_Action_Factory {

    webservice static String createCriminalActionForCollectionCase(Id ccId){
        List<Criminal_Judicial_Procedure__c> crim = [SELECT Id, Name FROM Criminal_Judicial_Procedure__c WHERE Collection_Case__c = :ccId];
        if(crim.size() > 0){
            return 'There is already a Criminal Action for this Collection Case '+crim[0].Name;
        }
        else{
            Criminal_Judicial_Procedure__c action = new Criminal_Judicial_Procedure__c();
            action.Collection_Case__c = ccId;
            insert action;
            
            return 'Created Criminal Action Successfully';
        }
    }
    
}