global class ClientAppController {
    /*
		<-------------------- New Services ------------------------->
	*/ 
    
    //Logged out services
    
    @RemoteAction
    WebService static String login(String username, String password){
        Map<String,Object> responseJSON = new Map<String,Object>();
        username = String.escapeSingleQuotes(username);
        password = String.escapeSingleQuotes(password);
        
        SiteAuthentication auth = new SiteAuthentication(username, password);
        boolean success = auth.login();
        
        ClientApp_Response response;
        if(success){
            responseJSON.put('accountTypes', auth.getAccountTypes());
            responseJSON.put('firstLoginWithPass', auth.getFirstLoginWithPass());
            String sessionToken = auth.getSessionToken();
            responseJSON.put('sessionToken', sessionToken);
            //auto return userInfo
            Map<String, Object> info = (Map<String,Object>) JSON.deserializeUntyped(getCurrentUserInfo(sessionToken));
            
            system.debug('info '+info);
            
            responseJSON.putAll((Map<String, Object>)info.get('data'));
            
            response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
        }
        else{
            responseJSON.put('errorCode', auth.getErrorMessage());
            response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
        }
        
        response.setDataMap(responseJSON);
        return response.generate();
    }
    
    @RemoteAction
    WebService static String recoverPassword(String email){
        Map<String,Object> responseJSON = new Map<String,Object>();
        email = String.escapeSingleQuotes(email);
        
        String status = SiteAuthentication.recoverPassword(email);
        
        ClientApp_Response response;
        if(status.equalsIgnoreCase('success')){
        	response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
        }
        else{
        	responseJSON.put('errorCode', status);
        	response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
        }
        response.setDataMap(responseJSON);
        return response.generate();
    }
    
    //Logged In Services
    
    @RemoteAction
    WebService static String validateSession(String sessionToken){
    	sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        ClientAppService_validateSession service = new ClientAppService_validateSession();        
        serviceResponse = service.execute(sessionToken, new Map<String,Object>());
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
     
    @RemoteAction
    WebService static String changePassword(String sessionToken, String newPass){
    	sessionToken = String.escapeSingleQuotes(sessionToken);
        newPass = String.escapeSingleQuotes(newPass);
        
        ClientAppService_changePassword service = new ClientAppService_changePassword();
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        args.put('newPass', newPass);
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
    
    @RemoteAction
    WebService static String getCurrentUserInfo(String sessionToken){
    	sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        ClientAppService_getUserInfo service = new ClientAppService_getUserInfo();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
    
    @RemoteAction
    WebService static String getCurrentAccountInfo(String sessionToken){
        sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        ClientAppService_getAccountInfo service = new ClientAppService_getAccountInfo();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
    
    @RemoteAction
    WebService static String getContractsInfo(String sessionToken){
        sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        ClientAppService_getContracts service = new ClientAppService_getContracts();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
    
    @RemoteAction
    WebService static String getLatePayment(String sessionToken){
        sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        ClientAppService_getLatePayment service = new ClientAppService_getLatePayment();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
    
    @RemoteAction
    WebService static String getInvoices(String sessionToken){
        sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        ClientAppService_getInvoices service = new ClientAppService_getInvoices();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
    
    @RemoteAction
	WebService static String getNextInvoiceDetails(String sessionToken) {
        sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        ClientAppService_getNextInvoiceDetails service = new ClientAppService_getNextInvoiceDetails();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
	}
    
    @RemoteAction
    WebService static String getCreditNotes(String sessionToken){
        sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        ClientAppService_getCreditNotes service = new ClientAppService_getCreditNotes();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
    
    //Attachments
    
    @RemoteAction
    WebService static String getInvoiceAttachments(String sessionToken, String invoiceId){
        sessionToken = String.escapeSingleQuotes(sessionToken);
        invoiceId = String.escapeSingleQuotes(invoiceId);
        
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        args.put('invoiceId',invoiceId);
        
        ClientAppService_getInvoiceAttachments service = new ClientAppService_getInvoiceAttachments();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
    
    @RemoteAction
    WebService static String getCreditNoteAttachments(String sessionToken, String creditNoteId){
        sessionToken = String.escapeSingleQuotes(sessionToken);
        creditNoteId = String.escapeSingleQuotes(creditNoteId);
        
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        args.put('creditNoteId',creditNoteId);
        
        ClientAppService_getCreditNoteAttachs service = new ClientAppService_getCreditNoteAttachs();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
    }
    
    @RemoteAction
	WebService static String getAppAttachments(String sessionToken, String applicationId) {
        sessionToken = String.escapeSingleQuotes(sessionToken);
        applicationId = String.escapeSingleQuotes(applicationId);
        
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        args.put('rentingAppId',applicationId);
        
        ClientAppService_getAppAttachments service = new ClientAppService_getAppAttachments();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
        return response.generate();
	}

	/*
		<-------------------- Knowledge Base Articles Functions ------------------------->
	*/
	/*
   	@RemoteAction
    WebService static String getArticle(String urlName, String channel, String language){
        return KB_articles.getArticle(urlName, channel, language); 
    }
    @RemoteAction
    WebService static String getAllCategories(String channel, String language){
        return KB_articles.getAllCategories(channel, language); 
    }
    @RemoteAction
    WebService static String getCategory(String uniqueName, String channel, String language){
        return KB_articles.getCategory(uniqueName, channel, language); 
    }
    @RemoteAction
    WebService static String getArticlesByCategory(String uniqueName, String channel, String language){
        return KB_articles.getArticlesByCategory(uniqueName, channel, language); 
    }
    @RemoteAction
    WebService static String rateArticle(String urlName, String articleVote, String channel, String language){
        return KB_articles.rateArticle(urlName, articleVote, channel, language); 
    }
    @RemoteAction
    WebService static String searchArticle(String term,  String channel, String language){
        return KB_articles.searchArticle(term, channel, language);
    }
    
    @RemoteAction
    WebService static String getAllArticlesOrderedByViews(String channel, String language){
        return KB_articles.getAllArticlesOrderedByViews(channel, language);
    }
    @RemoteAction
    WebService static String getArticlesByType(String channel, String language, String articleType){
        return KB_articles.getArticlesByType(channel, language, articleType);
    }  */
   
    /*
		<-------------------- CASES Base Functions ------------------------->
	*/
	/*
	@RemoteAction
	WebService static String getCaseCategoryAndReason(String sessionToken, String channel, String language){
		sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        ClientAppService_getCaseCatAndReason service = new ClientAppService_getCaseCatAndReason();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
		return response.generate();
		
		
		//return KB_cases.getCaseClientReasons(); 
	}
	
	@RemoteAction
    WebService static String getCasesPerLogin(String sessionToken, String channel, String language){
    	
    	sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        ClientAppService_getCases service = new ClientAppService_getCases();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}

		response.setDataMap(serviceResponse);
		return response.generate();
		
    }
    
    @RemoteAction
    WebService static String getCaseCommentsPerCase(String sessionToken, String caseId){
    	sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
      	Map<String,Object> args = new Map<String,Object>();
    	args.put('caseId', caseId);
    	
    	
    	ClientAppService_CasesComments service = new ClientAppService_CasesComments();
        serviceResponse = service.getCasesComments(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}
		
		response.setDataMap(serviceResponse);
		return response.generate();
        //return KB_cases.getCaseCommentsPerCase(sessionToken, caseId);
    }
    
    @RemoteAction
	WebService static String newCaseComment(String sessionToken, String caseId,  String message){
    	 sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
      	Map<String,Object> args = new Map<String,Object>();
    	args.put('caseId', caseId);
    	args.put('message', message);
    	
    	ClientAppService_CasesComments service = new ClientAppService_CasesComments();
        serviceResponse = service.newCaseComment(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}
		
		response.setDataMap(serviceResponse);
		return response.generate();
        //return KB_cases.getCaseCommentsPerCase(sessionToken, caseId);
    }
    
    
    
	@RemoteAction
    WebService static String reportCase(String sessionToken, String subject, String category, String reason, String message){
    	/*sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
      	Map<String,Object> args = new Map<String,Object>();
        args.put('sessionToken', sessionToken);
    	args.put('subject', subject);
    	args.put('category', category);
    	args.put('reason', reason);
    	args.put('message', message);
    	
    	ClientAppService_getCaseCommPerCase service = new ClientAppService_getCaseCommPerCase();
        serviceResponse = service.execute(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}
		
		response.setDataMap(serviceResponse);
		return response.generate();
    	
    	
    	
    	
    	
    	return KB_cases.reportCase(sessionToken, subject, category, reason, message);
    }
        

    @RemoteAction
	WebService static String insertAttachmentList(String sessionToken, String caseId , String attachmentListMapSerialized){
    	 //KB_cases.insertAttachmentList(caseId, attachmentListMapSerialized);	
    	sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
      	Map<String,Object> args = new Map<String,Object>();
        args.put('caseId', caseId);
    	args.put('attachmentListMapSerialized', attachmentListMapSerialized);
    	
    	
    	ClientAppService_CasesAttachments service = new ClientAppService_CasesAttachments();
        serviceResponse = service.insertAttachmentList(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}
		
		response.setDataMap(serviceResponse);
		return response.generate();
 
    }
    
    @RemoteAction
	WebService static String getCasesAttachments(String sessionToken, String caseId){
    	sessionToken = String.escapeSingleQuotes(sessionToken);
        
        Map<String,Object> serviceResponse = new Map<String,Object>();
      	Map<String,Object> args = new Map<String,Object>();
        args.put('caseId', caseId);
    	
    	
    	
    	ClientAppService_CasesAttachments service = new ClientAppService_CasesAttachments();
        serviceResponse = service.getCasesAttachments(sessionToken, args);
        
        ClientApp_Response response;
		if(serviceResponse.containsKey('errorCode')){
			response = new ClientApp_Response(ClientApp_Response.Status.ERROR);
		}
		else{
			response = new ClientApp_Response(ClientApp_Response.Status.SUCCESS);
		}
		
		response.setDataMap(serviceResponse);
		return response.generate();
    	
    	//return KB_cases.reportCase(sessionToken, subject, category, reason, message);
    }*/
    
}