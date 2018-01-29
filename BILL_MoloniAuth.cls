public class BILL_MoloniAuth {
    private static BILL_MoloniAuth instance = null;
    
    private String companyId; // TODO posso ir buscar a uma custom setting mais tarde
    private String endpointStart;
    private String userName;
    private String password;
    private String developerId;
    private String clientSecretCode;
    private datetime lastRequestDateTime;
    private String accessToken;
    private String refreshToken;

    private BILL_MoloniAuth(){
       processPassword();
       processEndpoint();
    }
    
    public static BILL_MoloniAuth getInstance(){
        if(instance == null) instance = new BILL_MoloniAuth();
        return instance;
    }

    private void processEndpoint(){

       System.debug('UserInfo.getOrganizationId'+ UserInfo.getOrganizationId());
       Credentials__c credential = Credentials__c.getInstance('Moloni');
       if(!Utilities.runningInASandbox()){  //Production 
           
                                              
           this.endpointStart = credential.Web_Service_Url__c;
           this.companyId = credential.AccountID__c;
           
           system.debug('this.endpointStart:' + this.endpointStart);
           system.debug('this.companyId:' + this.companyId);
       }else{
           this.endpointStart = credential.Web_Service_Url_TEST_ENVIRONMENT__c; //'https://api.moloni.com/sandbox/';
           this.companyId = '0';
       }

       return;
    }
    
    private void processPassword(){
         Credentials__c credential = Credentials__c.getInstance('Moloni');
                                              
         this.userName = credential.Username__c;
         this.password=credential.Password__c;
         this.developerId=credential.developer_id__c;
         this.clientSecretCode=credential.client_secret_code__c;

//         System.debug('userName'+ userName);  
//         System.debug('password'+ password);  
    }

	public String getEndpoint(){
		return this.endpointStart;
	}
	
	public String getCompanyId(){
		return this.companyId;
	}
	
    public String getAccessToken(){
       datetime nowDataTime = datetime.now();
       
       Long nowDataTimeLong = nowDataTime.getTime(); //data time in milliseconds
       Long lastRequestDateTimeLong;
       if( lastRequestDateTime != null){
           lastRequestDateTimeLong = this.lastRequestDateTime.getTime(); //data time in milliseconds
       }
       
       if(lastRequestDateTime == null || (nowDataTimeLong - lastRequestDateTimeLong)/(1000 * 60 * 60 * 24) > 13){  // '13 days'
//       	   System.debug('getAccessToken processAccessToken(): '); 
       	   processAccessToken();
       }
       else if((nowDataTimeLong - lastRequestDateTimeLong) / (1000 * 60) > 50 ){  //50 minutes
//       	   System.debug('getAccessToken refreshToken(): '); 
       	   refreshToken();
       }
 
       if(this.accessToken == null){ //if there is any error
           lastRequestDateTime = null;
       }else{
       	   lastRequestDateTime = nowDataTime;
       }
       
       return this.accessToken;
    }

    private void processAccessToken(){
//       System.debug('processAccessToken'); 	
    // https://api.moloni.com/v1/grant/?grant_type=password&client_id=[your_developer_id]&client_secret=[your_client_secret_code]&username=[your_user_username]&password=[your_user_password]

       String endpointUrl = this.endpointStart + 'grant/?';
       endpointUrl +='grant_type=password&';
       endpointUrl +='client_id=' + this.developerId +'&';
       endpointUrl +='client_secret=' + this.clientSecretCode +'&';
       endpointUrl +='username=' + this.userName +'&';
       endpointUrl +='password=' + this.password;
    
       HTTPResponse response = sendGet(endpointUrl);
       
       System.debug('Endpoint: '+ endpointUrl ); 
       System.debug('ProcessAccessToken Response.getBody: '+ response.getBody()); 
       parseAcessToken(response);
       
       return;
    }
   
    @TestVisible
    private void refreshToken(){
    // https://api.moloni.com/v1/grant/?grant_type=refresh_token&client_id=[your_developer_id]&client_secret=[your_client_secret_code]&refresh_token=[your_refresh_token_code]

       String endpoint = this.endpointStart + 'grant/?';
       endpoint +='grant_type=refresh_token&';
       endpoint +='client_id=' + this.developerId +'&';
       endpoint +='client_secret=' + this.clientSecretCode +'&';
       endpoint +='refresh_token=' + this.refreshToken;

       HTTPResponse response = sendGet(endpoint);
       
//       System.debug('refreshToken body:'+ response.getBody());           

	   parseAcessToken(response);
       
       return;
    }
  
    private void parseAcessToken(HTTPResponse response){
       this.accessToken = null;
       this.refreshToken = null;
    
       JSONParser parser = JSON.createParser(response.getBody());
	   while (parser.nextToken() != null) {
		   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
		   	   // Get the value.
		       parser.nextToken();
		       this.accessToken = parser.getText();
		   }
		   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'refresh_token')) {
		   	   // Get the value.
		       parser.nextToken();
		       this.refreshToken = parser.getText();
		   }
		   
		   // ERROR managament
		   //Error ex: {"error":"invalid_grant","error_description":"Invalid username and password combination"}
		   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'error')) {
		   	   // Get the value.
		       parser.nextToken();
		       String error = parser.getText();
		       system.debug('Error:' + error);
		   }
		   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'error_description')) {
		   	   // Get the value.
		       parser.nextToken();
		       String error = parser.getText();
		       system.debug('error_description: ' + error);
		   }
	   }

	   //TODO comment
//	   System.debug('parseAcessToken response.getBody:'+ response.getBody());   
//	   System.debug('access_token: '+ this.accessToken);
//	   System.debug('refresh_token: '+ this.refreshToken );
	   
	   return;
	}
    
    private HTTPResponse sendGet(String endpoint){
    	HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }
    
}