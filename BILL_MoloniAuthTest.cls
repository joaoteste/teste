@isTest
private class BILL_MoloniAuthTest implements HttpCalloutMock {
    
    //create a class with the code of HttpCalloutMock
    public HTTPResponse respond(HTTPRequest req){
        String Body;

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Autentication
        if(req.getEndpoint().contains('grant/?grant_type=password&client_id=')){
	        res.setBody('{"access_token":"2b6fe0fb8829233ef5d3daf90c111ff697b13a7c","expires_in":3600,"token_type":"bearer","scope":null,"refresh_token":"6de8a8043345ac210fab9c775dbc785ee6744162"}');
	        res.setStatusCode(200);
        }else if(req.getEndpoint().contains('grant/?grant_type=refresh_token&client_id=')){
	        res.setBody('{"access_token":"2b6fe0fb8829233ef5d3daf90c111ff697b13a7c","expires_in":3600,"token_type":"bearer","scope":null,"refresh_token":"6de8a8043345ac210fab9c775dbc785ee6744162"}');
	        res.setStatusCode(200);
        }
      
        System.debug('test body: ' + Body);
        return res;        

    }
   
    @isTest 
    private static void testAuth() {
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new BILL_MoloniAuthTest());
        BILL_Util_Test.setMoloniData();
        
        Test.startTest();
        BILL_MoloniAuth moloniAuth = BILL_MoloniAuth.getInstance();
        moloniAuth.getEndpoint();
        moloniAuth.getAccessToken();
        moloniAuth.getAccessToken();
        moloniAuth.getCompanyId();
        moloniAuth.refreshToken();

        Test.stopTest();
    }

}