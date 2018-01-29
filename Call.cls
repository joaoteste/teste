global class Call{
    public static void makeScheduleCall(string num,Id lineItemId, Id taskId){
        
        /*Twilio_Setting__c setting = Twilio_Setting__c.getInstance('Twilio Account');        
        TwilioRestClient client = new TwilioRestClient(setting.AccountId__c, setting.Auth_Token__c);
        Map<String,String> params = new Map<String,String> {
                'To'   => num,
                'From' => setting.Caller_Id__c,
                'Url' => setting.Call_Response_Url__c+'?trId='+lineItemId,
                'StatusCallback' => setting.Call_Status_Url__c+'?taskid='+taskId
                };        
        TwilioCall call = client.getAccount().getCalls().create(params);
        system.debug('>>'+call.getStatus());*/
        Task objTask = [select id, Call_From__c from Task where id=:taskId limit 1];
        makeTwilioCall(objTask.Call_From__c, num, lineItemId, taskId);
    }
    
    public static void makeCall(string fromNum, string toNum, string description, string lineItemId, string objectId){
        /*Twilio_Setting__c setting = Twilio_Setting__c.getInstance('Twilio Account');        
        TwilioRestClient client = new TwilioRestClient(setting.AccountId__c, setting.Auth_Token__c);
        Map<String,String> params = new Map<String,String> {
                'To'   => toNum,
                'From' => fromNum,
                'Url' => setting.Call_Response_Url__c+'?trId='+lineItemId,
                'StatusCallback' => setting.Call_Status_Url__c
                };
        TwilioCall call = client.getAccount().getCalls().create(params);*/
        string res = makeTwilioCall(fromNum,toNum,lineItemId,null);
        Map<string,Object> jsonObj = (Map<string,Object>)JSON.deserializeUntyped(res);
        Task objTask = new Task();
        RecordType rt = [select id from RecordType where DeveloperName = 'Call' and sobjecttype='Task' limit 1];
        objTask.RecordTypeId = rt.id;
        objTask.Call_From__c = fromNum;        
        objTask.Call_Time__c = System.now();
        objTask.Tape_Recording_Line_Item__c = lineItemId;
        objTask.CallSid__c = string.valueOf(jsonObj.get('sid'));//call.getSid();
        objTask.Call_Status__c = string.valueOf(jsonObj.get('status'));//call.getStatus();
        objTask.Status='Completed';
        objTask.Call_To__c = toNum;
        objTask.Subject = description;
        objTask.Type = 'Call';
        if(objectId.startsWith('003') || objectId.startsWith('00Q'))
            objTask.WhoId = objectId;
        else
            objTask.WhatId = objectId;
        insert objTask;
    }
    
    public static string makeTwilioCall(string fromNum, string toNum, string lineItemId, string taskId){
        
        Twilio_Setting__c setting = Twilio_Setting__c.getInstance('Twilio Account');
        string endpoint = 'https://api.twilio.com/2010-04-01/Accounts/'+setting.AccountId__c+'/Calls.json';             
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        string body = 'From='+EncodingUtil.urlEncode(fromNum, 'UTF-8')+'&To='+EncodingUtil.urlEncode(toNum, 'UTF-8');
        body+='&Url='+EncodingUtil.urlEncode(setting.Call_Response_Url__c+'?trId='+lineItemId, 'UTF-8');
        if(taskId!=null)
            body+='&StatusCallback='+EncodingUtil.urlEncode(setting.Call_Status_Url__c+'?taskid='+taskId, 'UTF-8');
        else
            body+='&StatusCallback='+EncodingUtil.urlEncode(setting.Call_Status_Url__c, 'UTF-8');
        req.setBody(body);        
        Blob headerValue = Blob.valueOf(setting.AccountId__c +':' + setting.Auth_Token__c);
        req.setHeader('X-Twilio-Client', 'salesforce-3.2.0');
        req.setHeader('User-Agent', 'twilio-salesforce/3.2.0');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Accept-Charset', 'utf-8');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization',authorizationHeader);
        req.setTimeout(120000);
        Http h = new Http();
        
        //HttpResponse to get response of request
        HttpResponse response;
        String responseBody = '';
        if(!test.isRunningTest()){
            response = h.send(req);
            responseBody = response.getBody();
        }else{
            response = new HttpResponse();
            response.setStatusCode(201);
            responseBody = '{"sid":"SM1f0e8ae6ade43cb3c0ce4525424e404f","date_created":"Fri, 13 Aug 2010 01:16:24 +0000","date_updated":"Fri, 13 Aug 2010 01:16:24 +0000","date_sent":null,"account_sid":"AC228b97a5fe4138be081eaff3c44180f3","to":"+15305431221","from":"+15104564545","body":"A Test Message","status":"queued","flags":["outbound"],"api_version":"2010-04-01","price":null,"uri":"/2010-04-01/Accounts/AC228ba7a5fe4238be081ea6f3c44186f3/SMS/Messages/SM1f0e8ae6ade43cb3c0ce4525424e404f.json"}';
        }
        
        return responseBody;
    }   
}