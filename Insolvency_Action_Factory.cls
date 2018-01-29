global class Insolvency_Action_Factory {
    
    webservice static String createInsolvencyAction(String rentingAppName){
    	system.debug('GGGGG rentingName: '+rentingAppName);
    	if(rentingAppName == null || String.isEmpty(rentingAppName)){
    		return 'Invalid Renting Application Name: '+ rentingAppName;
    	}
        List<Application__c> app = [SELECT Insolvency_Judicial_Procedure__c, Insolvency_Judicial_Procedure__r.Name, AccClient__c FROM Application__c WHERE Name = :rentingAppName];
        system.debug('GGGGG apps: '+app);
        if(app.size() == 0){
        	return 'Couldnt find Renting Application with Name: '+rentingAppName;
        }
        if(app[0].Insolvency_Judicial_Procedure__c != null){
            return 'There is already an Insolvency Action for this Billing Contract/Renting Application: '+app[0].Insolvency_Judicial_Procedure__r.Name;
        }
        else{
        	//create action
            Insolvency_Judicial_Procedure__c action = new Insolvency_Judicial_Procedure__c();
            action.Account_Client__c = app[0].AccClient__c;
            insert action;
            
            return 'Created Insolvency Action Successfully';
        }
    }

}