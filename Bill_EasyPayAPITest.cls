@isTest(SeeAllData=true)
private class Bill_EasyPayAPITest implements HttpCalloutMock{  
    
	//TODO    
    //class with the code of HttpCalloutMock
    public HTTPResponse respond(HTTPRequest req){
        String body;
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        
        // getNewMBReference
        if(req.getEndpoint().contains('_s/api_easypay_01BG.php?')){
        body = '<?xml version="1.0"?><getautoMB>';
          body += '<ep_status>ok0</ep_status>';
          body += '<ep_message>ep_country and ep_entity and ep_user and ep_cin ok and validation by code;code ok - new reference generated - 606300394 - </ep_message>';
          body += '<ep_cin>999800160</ep_cin>';
          body += '<ep_user>CARESA030216</ep_user>';
          body += '<ep_partner>CARESA030216</ep_partner>';
          body += '<ep_entity>11683</ep_entity>';
          body += '<ep_reference>606300394</ep_reference>';
          body += '<ep_value>15.25</ep_value>';
          body += '<t_key></t_key>';
          body += '<ep_link>http://test.easypay.pt/_s/c11.php?e=10611&amp;r=606300394&amp;v=15.25&amp;c=PT&amp;l=PT&amp;t_key=</ep_link>';
          body += '</getautoMB>';
          res.setBody(body);
        res.setStatusCode(200);
      //getFetchMBPayments
        }else if(req.getEndpoint().contains('_s/api_easypay_040BG1.php?')){
            body = '<?xml version="1.0"?><get_ref><ep_status>ok0</ep_status><ep_message>ep_country and ep_entity and ep_user and ep_cin ok and validation by code;code ok - query with 5 records</ep_message><ep_num_records>5</ep_num_records>';
          body += '<ref_detail>';
          body += '<ref><ep_cin>6063</ep_cin><ep_user>CARESA030216</ep_user><ep_entity>10611</ep_entity><ep_reference>606300047</ep_reference><ep_value>15.25</ep_value><ep_key>43450</ep_key><t_key></t_key>';
          body += '<ep_doc>MBTEST374566320170206154313</ep_doc><ep_payment_type>MB</ep_payment_type><ep_value_fixed>0.35</ep_value_fixed><ep_value_var>0.2745</ep_value_var><ep_value_tax>0.131145</ep_value_tax>';
          body += '<ep_value_transf>14.494355</ep_value_transf><ep_date_transf>2017-02-09</ep_date_transf><ep_key_read>43450</ep_key_read><ep_date_read>2017-02-06 15:43:29</ep_date_read><ep_status_read>verified</ep_status_read>';
          body += '<ep_status>pago</ep_status><ep_batch_transf></ep_batch_transf><ep_invoice_number></ep_invoice_number><ep_payment_date>2017-02-06 15:43:13</ep_payment_date></ref>';
      
      body += '<ref><ep_cin>6063</ep_cin><ep_user>CARESA030216</ep_user><ep_entity>10611</ep_entity><ep_reference>606300991</ep_reference><ep_value>15.25</ep_value><ep_key>43444</ep_key><t_key></t_key>';
      body += '<ep_doc>MBTEST374564620170206151549</ep_doc><ep_payment_type>MB</ep_payment_type><ep_value_fixed>0.35</ep_value_fixed><ep_value_var>0.2745</ep_value_var><ep_value_tax>0.131145</ep_value_tax>';
      body += '<ep_value_transf>14.494355</ep_value_transf><ep_date_transf>2017-02-09</ep_date_transf><ep_key_read>43444</ep_key_read><ep_date_read>2017-02-06 15:15:58</ep_date_read><ep_status_read>verified</ep_status_read>';
      body += '<ep_status>pago</ep_status><ep_batch_transf></ep_batch_transf><ep_invoice_number></ep_invoice_number><ep_payment_date>2017-02-06 15:15:49</ep_payment_date></ref>';
      
      body += '</ref_detail></get_ref>';
            res.setBody(body);
          res.setStatusCode(200);
        }
      
        System.debug('test body: ' + body);
        return res;

    }
    
    static void testDataCredential(){
    
        Credentials__c credential = new Credentials__c();
        credential.name = 'EasyPay';
        credential.client_secret_code__c = 'dfaofjoais'; 
        credential.Web_Service_Url__c = 'http://test.easypay.pt/';
        credential.Web_Service_Url_TEST_ENVIRONMENT__c = 'http://test.easypay.pt/';
        insert credential;
    }

    @isTest
    static void testGetNewMBReference() {
        
        Test.setMock(HttpCalloutMock.class, new Bill_EasyPayAPITest());
        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
		ID da = utils.environment3();   
        
        Test.startTest();
		//get mb
        (new Bill_EasyPayAPI()).getNewMBReference('15.25', Date.valueOf('2017-02-09'), da , 'Observacaoes');

        Test.stopTest();
    }
 
    @isTest
    static void testGetFetchMBPayments() {

        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
		Map<String, String> infoMap = utils.environment1();    

        Test.startTest();

        (new Bill_EasyPayAPI()).getFetchMBPaymentsFixedTime();

        Test.stopTest();
    }
    
    @isTest
    static void testGetFetchMBPaymentsAndReferenceChanged() {
        
        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = utils.environment1();         

        Test.startTest();

        (new Bill_EasyPayAPI()).getFetchMBPaymentsFixedTime();

        Test.stopTest();      
        
        ID atmID = infoMap.get('atm');  
        
        ATM_Reference__c atmFinal = [SELECT id, MB_Reference__c, MB_Payment_Status__c, Amount__c  FROM ATM_Reference__c WHERE ID = :atmID LIMIT 1];

        system.assert(atmFinal.MB_Payment_Status__c=='Paid');

    }
    
    @isTest
    static void testGetFetchMBPaymentsAndReferenceMoloni() {

        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = utils.environment2();  
        
        Test.startTest();

        (new Bill_EasyPayAPI()).getFetchMBPaymentsFixedTime();

        Test.stopTest();    
        
        ID atmID = infoMap.get('atm');  
        
        ATM_Reference__c atmFinal = [SELECT id, MB_Reference__c, MB_Payment_Status__c, Amount__c  FROM ATM_Reference__c WHERE ID = :atmID LIMIT 1];

        system.assert(atmFinal.MB_Payment_Status__c=='Paid');

    }
    
    
    @isTest
    static void testGetFetchMBPaymentsAndBatchMoloni() {

        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = utils.environment2();         

        Test.startTest();

        (new Bill_EasyPayAPI()).getFetchMBPaymentsFixedTime();

        Test.stopTest();
        
        ID atmID = infoMap.get('atm');
        ATM_Reference__c atmFinal = [SELECT id, MB_Reference__c, MB_Payment_Status__c, Amount__c  FROM ATM_Reference__c WHERE ID = :atmID LIMIT 1];

        system.assert(atmFinal.MB_Payment_Status__c=='Paid');
        
        ID pcID = infoMap.get('pc');
        
        Payment_Collection__c pc = [SELECT id, Status__c  
                                        FROM Payment_Collection__c 
                                        WHERE ID = :pcID];
        
        System.assertEquals(pc.Status__c,'Paid');
    }
    
    
    @isTest
    static void testGetFetchMBPaymentsAndBatch() {

        RentingApplication_Util_Test utils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = utils.environment1();         

        Test.startTest();

        (new Bill_EasyPayAPI()).getFetchMBPaymentsFixedTime();

        Test.stopTest();
        
        ID atmID = infoMap.get('atm');
        ATM_Reference__c atmFinal = [SELECT id, MB_Reference__c, MB_Payment_Status__c, Amount__c  FROM ATM_Reference__c WHERE ID = :atmID LIMIT 1];

        system.assert(atmFinal.MB_Payment_Status__c=='Paid');
        
        ID ccID = infoMap.get('ccID');
        ID pcID = infoMap.get('pc');
        
        Collection_Case__c	 cc = [SELECT id, Status__c  
                                        FROM Collection_Case__c 
                                        WHERE ID = :ccID];
                                        
		Payment_Collection__c pc = [SELECT ID, Status__c
									FROM Payment_Collection__c
									WHERE ID = :pcID];	                                        
        
        System.assertEquals(cc.Status__c,'Closed');
        System.assertEquals(pc.Status__c,'Paid');
    }
    
    

}