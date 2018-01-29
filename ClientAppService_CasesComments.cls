public class ClientAppService_CasesComments extends ClientAppService {
    
    public Map<String,Object> getCasesComments(String sessionToken, Map<String,Object> args){
    	super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
    	
	    Session__c session = [SELECT Login__c
        FROM Session__c
        WHERE token__c = :sessiontoken
        ORDER BY CreatedDate LIMIT 1];
        
    	String caseId = (String) args.get('caseId');
    	
    	Case caseInfo = [SELECT OwnerID FROM Case WHERE ID =  :caseId];
    	list<CaseComment> commentList = [SELECT id, commentBody, CreatedBy.FirstName, CreatedBy.LastName, createdDate, createdById  from CaseComment WHERE ParentId= :caseId ORDER BY createdDate DESC];
		
        list<ID> Users = new List<ID>();
        
        for(CaseComment cc :commentList){
            Users.add(cc.createdById);
        }
        
        Map<ID, User> usersMap = new Map<ID, User>([SELECT ID, fullPhotoUrl FROM User WHERE ID IN: Users]);
        List<Map<Object, Object>> casesMapList = new List<Map<Object, Object>>();
        
        for(CaseComment caseCommentsInCase: commentList){
            Map<Object, Object> caseCommentMap= new Map<Object, Object>();
  			String userName;

            if(isUserGuest(session.Login__c)){
                userName = getContactName(session.Login__c);
            }else{
                userName = caseCommentsInCase.CreatedBy.FirstName +' '+caseCommentsInCase.CreatedBy.LastName;
            }
            
            caseCommentMap.put('author',      userName); 
            caseCommentMap.put('id',      	  caseCommentsInCase.ID);  
            caseCommentMap.put('createdDate', caseCommentsInCase.createdDate);
            caseCommentMap.put('message',     caseCommentsInCase.commentBody);
            caseCommentMap.put('photo',       usersMap.get(caseCommentsInCase.CreatedById).fullPhotoUrl);   
                      
            //System.debug(caseCommentMap.get('author'));
            //System.debug(caseCommentsInCase.createdDate);
            //System.debug(caseCommentsInCase.commentBody);
            
            casesMapList.add(caseCommentMap);
        }
        
		toReturn.put('caseComments', casesMapList);
		return toReturn;
    	
    }
    
    public Map<String,Object> newCaseComment(String sessionToken, Map<String,Object> args){
    	super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        
    	String caseId = (String) args.get('caseId');
    	String message = (String) args.get('message');

        if(args.get('message')== null || args.get('caseId')== null){
        	toReturn.put('errorCode','NULL_PARAMETERS');
         	return toReturn; 
        }
        CaseComment newCaseComment  = Case_Utils.newCaseComment(caseId, message);
        insert newCaseComment;
        return toReturn;
        
    }
    
    private static String getContactName(String loginId){
        List<Contact> contact = [SELECT id, FirstName, LastName  FROM Contact WHERE Login__c =:loginId];
        if(contact.isEmpty()){
            return null;
        }
        return contact[0].FirstName + ' ' + contact[0].LastName;  
    }
    
  	private static boolean isUserGuest(String loginId){
        List<Contact> contactList = [SELECT id, FirstName, LastName  FROM Contact WHERE Login__c =:loginId LIMIT 50000];
        List<User> user = [SELECT c2g__APILicenseKey__c  FROM User WHERE ContactId in:contactList];
        if(user.size()<1){
            return false;
        }
        if(user[0].c2g__APILicenseKey__c =='Guest License'){
            return true;
        }
        return false;
	} 
    
}