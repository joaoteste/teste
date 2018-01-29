public class ClientApp_Response {
	
	/*
    {
	"data":{
		"items":[
			{"amount":893,"Id":"798748937"},
			{"amount":45,"Id":"432529887"}
		],
		"email":"email@gmail.com",
		"username":"abreu"
	},
	"status":"SUCCESS"
	}
	------------------------------------------
	{
	"data":{
		"errorCode":"INVALID_SESSION",
		"errorDetail":"This session has more than 24 hours"
	},
	"status":"ERROR"
	}
    */
	
    Map<String,Object> response;
    
    public ClientApp_Response(Status status){
    	response = new Map<String,Object>();
    	response.put('status', status);
    }
    
    public void setDataMap(Map<String, Object> dataMap){
    	response.put('data', dataMap);
    }
    
    public void setDataAttribute(String key, Object value){
    	if(response.containsKey('data')){
    		Map<String, Object> previousData = (Map<String, Object>) response.get('data');
    		previousData.put(key,value);
    		response.put('data', previousData);
    	}else{
    		Map<String, Object> dataMap = new Map<String, Object>();
    		dataMap.put(key,value);
    		response.put('data', dataMap);
    	}
    }
        
    public void setErrorCode(ErrorCode value){
    	if(response.containsKey('data')){
    		Map<String, Object> previousData = (Map<String, Object>) response.get('data');
    		previousData.put('errorCode',value);
    		response.put('data', previousData);
    	}else{
    		Map<String, Object> dataMap = new Map<String, Object>();
    		dataMap.put('errorCode',value);
    		response.put('data', dataMap);
    	}
    	
    }
    
    public void setErrorDetail(String value){
    	if(response.containsKey('data')){
    		Map<String, Object> previousData = (Map<String, Object>) response.get('data');
    		previousData.put('errorDetail',value);
    		response.put('data', previousData);
    	}else{
    		Map<String, Object> dataMap = new Map<String, Object>();
    		dataMap.put('errorDetail',value);
    		response.put('data', dataMap);
    	}
    }
    
    public String generate(){
    	return JSON.serialize(response, true);
    }
    
    /*
		<-------------------- Constants ------------------------->
	*/ 
    
    public ENUM Status{
    	SUCCESS,
    	ERROR
    }
    
    public ENUM ErrorCode{
    	//login
    	LOGIN_NOT_FOUND,
    	LOGIN_INACTIVE,
    	INCORRECT_PASSWORD,
    	NO_SESSION_TOKEN,
    	NO_SESSION_FOR_TOKEN,
    	MORE_THAN_ONE_SESSION,
    	PASSWORD_HAS_CHANGED,
    	TOKEN_DOESNT_MATCH,
    	INVALID_SESSION,
    	//business logic
    	NO_CONTRACTS_FOUND,
    	NO_CASE_FOUND,
    	NO_DUNNING_FOUND,
    	NO_AUTO_ATT_FOUND,
    	NO_CONTRACT_ATT_FOUND,
    	NO_ATTS_FOUND,
    	NO_CREDIT_NOTE_ATT_FOUND,
    	NO_INVOICE_ATT_FOUND,
    	//expected function params
    	REASON_AND_CATEGORY_NOT_SET,
    	CREDENTIALS_NOT_SET,
    	NO_NEW_PASS,
    	NO_RENTING_APP_ID,
    	NO_CREDIT_NOTE_ID,
    	NO_INVOICE_ID,
    	NULL_PARAMETERS
    }
}