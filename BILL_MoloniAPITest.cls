@isTest
public class BILL_MoloniAPITest implements HttpCalloutMock {
    
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
    static void testGetClient() {

        Test.setMock(HttpCalloutMock.class, new BILL_MoloniAPITest());
        BILL_MoloniAPITest.setTestData();
        
        Test.startTest();

        (new BILL_MoloniApi()).getClientMoloniID('503123234');  //dummy value

        Test.stopTest();
    }

     @isTest 
    static void testCreateInvoiceAndClient() {

        Test.setMock(HttpCalloutMock.class, new BILL_MoloniAPITest());

        BILL_MoloniAPITest.setTestData();
        
        Test.startTest();

        ID jobID = System.enqueueJob(new BILL_QE_CreateInvoiceExtApp(BILL_Util_Test.invoiceId));

        Test.stopTest();
    }

    @isTest
    static void testFinalizeInvoiceAndSendEmail() {
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new BILL_MoloniAPITest());
        
        BILL_MoloniAPITest.setTestData();

        c2g__codainvoice__c invoice = [SELECT id, Moloni_Invoices_ID__c  FROM c2g__codainvoice__c WHERE id = :BILL_Util_Test.invoiceID limit 1];
        invoice.Moloni_Invoices_ID__c = '1412';
        update invoice;

        Test.startTest();

        ID jobID = System.enqueueJob(new BILL_QE_CreateInvoiceExtApp(BILL_Util_Test.invoiceID));

        Test.stopTest();
    }

    @isTest
    static void testGetInvoiceInfo() {

        Test.setMock(HttpCalloutMock.class, new BILL_MoloniAPITest());
        
        BILL_MoloniAPITest.setTestData();

        Test.startTest();

        (new BILL_MoloniApi()).getInvoiceInfo(BILL_Util_Test.invoiceID);

        Test.stopTest();
    }

    @isTest
    static void testCreditNote() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new BILL_MoloniAPITest());
        
        BILL_MoloniAPITest.setTestData();
        
        Test.startTest();
        BOReport.createCreditNote(BILL_Util_Test.creditNoteId);
        
        Test.stopTest();
    }

    @isTest
    static void testGenerateMBReference() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new BILL_MoloniAPITest());
        
        BILL_MoloniAPITest.setTestData();
        
        Test.startTest();
        
        (new BILL_MoloniApi()).generate_mb_reference('190638467', '206.06');
        
        Test.stopTest();
    }
    
     @isTest
    static void testSendEmail() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new BILL_MoloniAPITest());
        BILL_MoloniAPITest.setTestData();
        
        Test.startTest();
        
        BOReport.sendEmailwithInvoice(BILL_Util_Test.invoiceID);
        
        Test.stopTest();
    }


}