@isTest(SeeAllData = true)
public class BILL_BH_MoloniFixNotSent_Test implements HttpCalloutMock {
    
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
        //Customers
        }else if(req.getEndpoint().contains('customers/insert/?access_token=')){
            res.setBody('{"valid":1,"customer_id":2399428}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('customers/getByVat')){
            res.setBody('{"customer_id":2399428}');
            res.setStatusCode(200);
        //Invoices
        }else if(req.getEndpoint().contains('invoices/insert/?access_token=')){
            res.setBody('{"valid":1,"document_id":189667356, "mb_reference": {"entity": "10611", "reference": "500123123", "value": "10.20"}}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('/invoices/getOne/') && req.getBody().contains('your_reference')){
            res.setBody('{}');  // to simulate that the invoice wasn't already created
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('/invoices/getOne/') && req.getBody().contains('document_id')){
            res.setBody('{"number":23,"document_set_name":"Serie2017"}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('invoices/update/?access_token=')){
            res.setBody('{"valid":1,"document_id":189667356,"status":1}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('invoices/generateMBReference/?access_token=')){
            res.setBody('{"valid":1,"entity":10611,"reference":500004549,"value":0,01}');
            res.setStatusCode(200);   
        }else if(req.getEndpoint().contains('documents/getPDFLink')){
            res.setBody('{"valid":1,"url":"https://www.moloni.com/downloads/?h=3ed61efdf77463fd7f06e8bd1e0680a9&d=189606041"}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('https://www.moloni.com/downloads/index')){
            String myString = 'StringToBlob';
            Blob bodyBlob = Blob.valueof(myString);
            res.setBodyAsBlob(bodyBlob);  //TODO
            res.setStatusCode(200);
        // Credit Note
        }else if(req.getEndpoint().contains('creditNotes/insert')){
            res.setBody('{"valid":1,"document_id":189897721}');  //TODO
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('creditNotes/getOne')){
            res.setBody('{"number":111,"document_set_name":"Serie2017"}');  //TODO
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
	public static void testNotSentInvoices(){
		
		Test.setMock(HttpCalloutMock.class, new BILL_BH_MoloniFixNotSent_Test());
		RentingApplication_Util_Test rUtils = new RentingApplication_Util_Test();
		Map<String, String> infoMap = rUtils.environment2();    
		c2g__codainvoice__c si = [SELECT ID FROM c2g__codainvoice__c WHERE ID = :infoMap.get('salesInvoice')];
		si.Invoice_Email_Status__c = 'Not Send';
		si.Invoice_Express_Number_text__c = '';
		update si;		
		
		Test.startTest();
		
		BILL_SC_MoloniFixNotSentInvoices moloniFix = new BILL_SC_MoloniFixNotSentInvoices();

        String jobId = System.schedule('Create Bill EasyPay Schedulable '+ date.today(), '0 0 14 * * ?', moloniFix);

        CronTrigger ct = fetchCronTrigger(jobId);
        
        System.assertEquals('0 0 14 * * ?', ct.CronExpression,'Did not get the same Cron Expression back');
        
        Test.stopTest();
    }
    

    public static CronTrigger fetchCronTrigger(String jobId) {
        return [
            select CronExpression,
            TimesTriggered,
            NextFireTime
            from CronTrigger
            where Id = :jobId
        ];
    }
}