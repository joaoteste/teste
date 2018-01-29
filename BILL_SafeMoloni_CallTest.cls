@isTest
private class BILL_SafeMoloni_CallTest implements HttpCalloutMock{

   //class with the code of HttpCalloutMock
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
        //Customers
        }else if(req.getEndpoint().contains('customers/insert/?access_token=')){
            res.setBody('{"valid":1,"customer_id":2399428}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('customers/update/?access_token=')){
            res.setBody('{"valid":1,"customer_id":2399428}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('customers/getByVat')){
            res.setBody('{"customer_id":2399428}');
            res.setStatusCode(200);
        }
      
        System.debug('test body: ' + Body);
        return res;        

    }

    //   @testSetup //TODO not sure why the tag is not working
    private static void setTestData(){
        BILL_Util_Test.setMoloniData();
        BILL_Util_Test.setFinancialForce();
    }
    
    @isTest 
    static void testCreateInvoiceAndClient() {

        Test.setMock(HttpCalloutMock.class, new BILL_MoloniAPITest());

        setTestData();
        
        Account testAcc = new Account();
        testAcc.Name = 'Big BadumTss';
        testAcc.Nif__c = '501783450';
        testAcc.type = 'Customer - Channel';   
        testAcc.billingPostalCode = '2300-999';
        testAcc.Phone= '925493357';
        testAcc.Moloni_Client_ID__c = '2459170';
        testAcc.BillingStreet = 'Rua da morada';
        testAcc.BillingCity = 'Cidade xpto';
        insert testAcc;
        
        testAcc.Phone= '925493234';
        update testAcc;
        
        List<Id> accountIdList = new List<Id>();
        
        Test.startTest();

        ID jobID = System.enqueueJob(new BILL_QE_MoloniUpdateClient(accountIdList));

        Test.stopTest();
    }
    

}