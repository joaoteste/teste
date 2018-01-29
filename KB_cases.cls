public class KB_cases {
    /*private static Login__c sessionTokenToLogin(String sessionToken){
    	Session__c session = [SELECT Login__c from Session__c WHERE Token__c = :sessionToken LIMIT 1];
    	Login__c login = [SELECT id, Email__c , IdVendor__c, Password__c, Vendor_Vendor__c	 from Login__c WHERE id = :session.Login__c LIMIT 1];
    	return login;
    }        
	 public static String getCasesPerLogin(String sessionToken, String channel, String language){
        if(sessionToken == null || channel == null || language == null){
            return null;
        }
        List<Map<String, String>> casesMapList = new List<Map<String, String>>();
        Login__c loginId= sessionTokenToLogin(sessionToken);
        if(loginId == null){
            return null;
        }
        System.debug(loginId.IdVendor__c);
        List<Case> caseList = [SELECT id, CaseNumber, Reason__c,Category__c, Subject, Priority, CreatedDate, Status, OwnerID, Description, Owner.FirstName,Owner.LastName FROM Case WHERE AccountID = :loginId.IdVendor__c];
        for(Case caseResult : caseList){
            System.debug(caseResult.id);
            Map<String, String> caseMap = Case_Utils.caseToMap(caseResult);
        	casesMapList.add(caseMap);
            System.debug(caseResult.CaseNumber);
        }
        
        return JSON.serialize(casesMapList, true);
    }

    
    
    public static String getCaseCommentsPerCase(String sessionToken, String caseId){
        if(caseId == null || sessionToken == null){
            return null;
        }
        Login__c loginId= sessionTokenToLogin(sessionToken);
        Case caseInfo = [SELECT OwnerID FROM Case WHERE ID=:caseId];
    	list<CaseComment> commentList = [SELECT id, commentBody, CreatedBy.FirstName, CreatedBy.LastName, createdDate, createdById  from CaseComment WHERE ParentId= :caseId ORDER BY createdDate DESC];
		
        list<ID> Users = new List<ID>();
        for(CaseComment cc :commentList){
            Users.add(cc.createdById);
        }
        Map<ID, User> usersMap = new Map<ID, User>([SELECT ID, fullPhotoUrl FROM User WHERE ID IN: Users]);
        
        
        List<Map<Object, Object>> casesMapList = new List<Map<Object, Object>>();
        for(CaseComment caseCommentsInCase: commentList){
            Map<Object, Object> caseCommentMap= new Map<Object, Object>();
      
            caseCommentMap.put('id',      	  caseCommentsInCase.ID);  
            caseCommentMap.put('createdDate', caseCommentsInCase.createdDate);
            caseCommentMap.put('message',     caseCommentsInCase.commentBody);
            caseCommentMap.put('photo',       usersMap.get(caseCommentsInCase.CreatedById).fullPhotoUrl);
			String userName;
            if(isUserGuest(loginID.ID)){
                userName = getContactName(sessionToken);
                caseCommentMap.put('author',      userName);
            }else{
                userName = caseCommentsInCase.CreatedBy.FirstName +' '+caseCommentsInCase.CreatedBy.LastName;
                caseCommentMap.put('author',      userName); 
            }
                
            System.debug(caseCommentMap.get('author'));
            System.debug(caseCommentsInCase.createdDate);
            System.debug(caseCommentsInCase.commentBody);
            
            casesMapList.add(caseCommentMap);
        }
        
		return JSON.serialize(casesMapList, true);
    }
    
    
    public static String getCasesAttachments(String caseId){
        List<Map<Object, Object>> casesMapList = new List<Map<Object, Object>>();
        List<Attachment> attachments = Case_Utils.getCaseAttachments(caseId);
        
        for(Attachment attach: attachments){
            Map<Object, Object> attachmentMap = new Map<Object, Object>();
            attachmentMap.put('id',     attach.id);
            attachmentMap.put('title',  attach.name);
            attachmentMap.put('body',   attach.body);
            casesMapList.add(attachmentMap);
        }
        ClientApp_Response response = new ClientApp_Response(ClientApp_Response.status.SUCCESS);
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('casesMapList', casesMapList);
        response.setDataMap(responseMap);
        //return response.generate();
        return JSON.serialize(casesMapList,true);
    }
    
    public static void insertAttachmentList(String caseId , String attachmentListMapSerialized){
        if(caseId == null || attachmentListMapSerialized == null){
            return;
        }
        Case caseParam = [SELECT ID FROM case WHERE id=:caseID];
        if(caseParam==null){
            return;
        }
        
        List<Map<String,String>> attachesListMap=(List<Map<String,String>>)JSON.deserialize(attachmentListMapSerialized, List<Map<String,String>>.class);
        List<Attachment> AttachmentList = new List<Attachment>();
        for(Map<String,String> attachMap : attachesListMap){
            Attachment newAttach = new Attachment( Name = attachMap.get('title'), Body =  EncodingUtil.base64Decode(attachMap.get('body')), ParentId = caseParam.id );
            AttachmentList.add(newAttach);  
        }
        insert AttachmentList;
        
    }
    
    private static string caseToMapSerialized(ID caseId){
        Case caseReturned = [SELECT id, CaseNumber, Reason__c, Category__c, Subject, Priority, CreatedDate, Status, OwnerID, Description, Owner.FirstName, Owner.LastName FROM Case WHERE ID = :caseId];
        Map<String , String> caseMap = Case_Utils.CaseToMap(caseReturned);
        
        ClientApp_Response response = new ClientApp_Response(ClientApp_Response.status.SUCCESS);
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('casesMapList', caseMap);
        response.setDataMap(responseMap);
        //return response.generate();
        
        return JSON.serialize(caseMap, true);
    }
   	
	//Map Return Keys => ID, caseNumber, topic, subject, priority, createdDate, message, status, atributedTo
    public static String reportCase(String sessionToken, String subject, String category, String reason, String message){
        if(sessionToken == null || subject == null || category == null || reason == null){
            return null;
        }
        Login__c loginId= sessionTokenToLogin(sessionToken);
        //Login__c loginInfo = [ SELECT ID, IdVendor__c, Email__c FROM Login__c WHERE id=:loginId.Vendor_Vendor__c];
        //System.debug(loginInfo.id);
        //TODO: Alternar entre o ID da Celia e Tatiana
        Case newCase = Case_Utils.newCase('High', category, reason, message, null);
        newCase.Subject = subject;
        newCase.ownerID = '00524000001jOd5';
        insert newCase;
        sendConfirmationEmail(loginId.Email__c, ''+newCase.CreatedDate, newCase.CaseNumber);  
        
        ClientApp_Response response = new ClientApp_Response(ClientApp_Response.status.SUCCESS);
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('casesMapList', caseToMapSerialized(newCase.id));
        response.setDataMap(responseMap);
        //return response.generate();
        
      	return caseToMapSerialized(newCase.id);
    }
    
	public static void newCaseComment(String caseId,  String message){
        if(message== null || caseID== null){
         	return; 
        }
        CaseComment newCaseComment  = Case_Utils.newCaseComment(caseId, message);
        insert newCaseComment;
        return;
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
    
    private static String getContactName(String sessionToken){
    	Login__c login= sessionTokenToLogin(sessionToken);
        List<Contact> contact = [SELECT id, FirstName, LastName  FROM Contact WHERE Login__c =:login.id];
        if(contact.isEmpty()){
            return null;
        }
        return contact[0].FirstName + ' ' + contact[0].LastName;  
    }
    
	 public static String getCaseClientReasons(){
	 	  
	    Map<String, List<String>> categoryToReason = Utils_DependentPicklist.getFieldDependencies('Case', 'Category__c', 'Reason__c');
	    List<String> partnerReasonList = new List<String>();
	    List<String> reasonList = categoryToReason.get('Cliente');
	    
	    for(String category: reasonList){
	        partnerReasonList.add(category);    
	    }
	    System.debug(partnerReasonList);
         
        ClientApp_Response response = new ClientApp_Response(ClientApp_Response.status.SUCCESS);
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('casesMapList', partnerReasonList);
        response.setDataMap(responseMap);
        //return response.generate();
         
	    return JSON.serialize(categoryToReason, true);
	    
	}
	
    
     private static void sendConfirmationEmail(String email, String createdDate, String caseNumber){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {email};
      
        mail.setToAddresses(toAddresses);
        mail.setSubject('New Case created on Candor Support Center: ');
        mail.setBccSender(false);
        mail.setUseSignature(false);
         
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support-no-reply@candor.pt'];
        if ( owea.size() > 0 ) {
    		mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}
        mail.setPlainTextBody('Hello \n Your Case: ' + caseNumber +' has been created. Our team will get to you as soon as possible.\n Thank you, \n Candor Support Team');
        mail.setHtmlBody('<p>Hello</p> Your case:<b> ' + caseNumber +' </b>has been created. Our team will get to you as soon as possible.<p><p>Thank you</p>,<p> Candor Support Team</p>');
        if(!Test.isRunningTest()){
	    	Messaging.reserveSingleEmailCapacity(1);
	   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
          
    }*/
     
}