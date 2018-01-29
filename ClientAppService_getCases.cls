public class ClientAppService_getCases extends ClientAppService {
    
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
    	super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
    	List<Map<String, String>> casesMapList = new List<Map<String, String>>();
    	
	    Session__c session = [SELECT Login__r.IdVendor__c 
        FROM Session__c
        WHERE token__c = :sessiontoken
        ORDER BY CreatedDate LIMIT 1];

        List<Contact> contacts = [SELECT AccountId
        FROM Contact
        WHERE Login__c = :session.Login__c];
        
        List<Case> caseList = [SELECT id, CaseNumber, Type, Category__c, Reason__c,  Subject, Priority, CreatedDate, Status, OwnerID, Description, Owner.FirstName,Owner.LastName 
        FROM Case 
        WHERE AccountID = :contacts[0].AccountID ORDER BY CreatedDate DESC LIMIT 300 ];

        for(Case caseResult : caseList){
            System.debug(caseResult.id);
            Map<String, String> caseMap = Case_Utils.caseToMap(caseResult);
        	casesMapList.add(caseMap);
            System.debug(caseResult.CaseNumber);
        }
        toReturn.put('cases', casesMapList);
        return toReturn;
        //return response.generate();
    	
    }
}