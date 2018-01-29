@isTest
global class Rest_Utils_Test implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req){
    	
        String body; 
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
		body = '<?xml version="1.0"?><get_ref><ep_status>ok0</ep_status><ep_message>ep_country and ep_entity and ep_user and ep_cin ok and validation by code;code ok - query with 5 records</ep_message><ep_num_records>5</ep_num_records>';
        body += '<ref_detail>';
        body += '<ref><ep_cin>6063</ep_cin><ep_user>CARESA030216</ep_user><ep_entity>10611</ep_entity><ep_reference>606300991</ep_reference><ep_value>12.30</ep_value><ep_key>43450</ep_key><t_key></t_key>';
        body += '<ep_doc>MBTEST374566320170206154313</ep_doc><ep_payment_type>MB</ep_payment_type><ep_value_fixed>0.35</ep_value_fixed><ep_value_var>0.2745</ep_value_var><ep_value_tax>0.131145</ep_value_tax>';
        body += '<ep_value_transf>14.494355</ep_value_transf><ep_date_transf>2017-02-09</ep_date_transf><ep_key_read>43450</ep_key_read><ep_date_read>2017-02-06 15:43:29</ep_date_read><ep_status_read>verified</ep_status_read>';
        body += '<ep_status>pago</ep_status><ep_batch_transf></ep_batch_transf><ep_invoice_number></ep_invoice_number><ep_payment_date>2017-02-06 15:43:13</ep_payment_date></ref>';
        body += '</ref_detail></get_ref>';
        res.setBody(body);
        res.setStatusCode(200);

        System.debug('test body: ' + body);
        return res;
    }
    
    @isTest
    public static void sendGetTest(){
    	Test.setMock(HttpCalloutMock.class, new Rest_Utils_Test());
    	Test.startTest();
    		Rest_Utils.sendGet('www.stet.pt');
    	Test.stopTest();
    }
    
    @isTest
    public static void sendPostTest(){
    	Test.setMock(HttpCalloutMock.class, new Rest_Utils_Test());
    	Test.startTest();
    		Rest_Utils.sendPost('www.test.pt','test.pt',DateTime.newInstance(2017,5,3));
    	Test.stopTest();
    }
    
    @isTest
    public static void sendPostAttachmentTest(){
    	Test.setMock(HttpCalloutMock.class, new Rest_Utils_Test());
        
    	Test.startTest();
        Case newCase = new Case();    
       // insert newCase;
        
        Attachment newCaseAttach = new Attachment();
        newCaseAttach.Body = Blob.toPdf('Body text attach');
        newCaseAttach.Description = 'This is a test description for the attachment';
        newCaseAttach.Name = 'attachNameTest.txt';
        //newCaseAttach.parentID = newCase.ID;
        
        //insert newCaseAttach;

        Rest_Utils.postFileAttachment('www.test.pt', newCaseAttach);
        Test.stopTest();
    }
    
}