/**

Author   |Date  | Comments
Vinod    |10/12/2017 | Initial Creation

**/

global class SMSUtil{
    
    //Constructor
    public SMSUtil(){
    }
    
    //To send scheduled messages from task
    @future(callout = true)
    public static void sendSmsInFuture(String toNumber, String fromNumber, String body, Id contactId){
    
        System.debug(' ============ In SendSMS method ==========');
        List<Task> msgList = new List<Task>();
        Twilio_Setting__c setting;
        
        //Get Twillo login credentilas
        List<Twilio_Setting__c> settingList = [SELECT Id, Name, AccountId__c, Auth_Token__c, From_Number__c,Status_Callback_URL__c FROM Twilio_Setting__c WHERE Name = 'Twilio Account' LIMIT 1];
        if(settingList.size() > 0){
            setting = settingList[0];
        }
        
        //Endpoint to hit
        string endpointUrl = 'https://api.twilio.com/2010-04-01/Accounts/';
        string statusCallbackURL = '';
        string username = '';
        string password = '';
        
        if(setting.AccountId__c != null){
            endpointUrl += setting.AccountId__c+'/Messages.json';
            username = setting.AccountId__c;
        }
        
        if(setting.Auth_Token__c != null){
            password = setting.Auth_Token__c;
        }
        
        if(setting.From_Number__c != null){
            fromNumber = setting.From_Number__c;
        }
        
        if(setting.Status_Callback_URL__c != null){
            statusCallbackURL = setting.Status_Callback_URL__c;
        }
        
        //HttpRequest to send
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('POST');
        req.setBody('From='+EncodingUtil.urlEncode(fromNumber, 'UTF-8')+'&To='+EncodingUtil.urlEncode(toNumber, 'UTF-8')+'&Body='+EncodingUtil.urlEncode(body, 'UTF-8')+'&StatusCallback='+EncodingUtil.urlEncode(statusCallbackURL, 'UTF-8'));
        
        Blob headerValue = Blob.valueOf(username +':' +password);
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
            responseBody = '{"from": "+14154847489","to": "+919767199136", "body": "Hello", "status": "queued", "sid": "asdsf514554fdhgd"}';
        }
        
        Boolean isWho = false;
        String objectAPIName = '';
        
        if(contactId !=null){
            objectApiName = contactId.getSObjectType().getDescribe().getName();
        }
        if(!(objectApiName == null || objectApiName=='') && (objectApiName.equals('Contact') || objectApiName.equals('Lead'))){
            isWho = true;
        }
        //If Status is ok then create task for message sent
        if(response.getStatusCode() == 201){
            msgList = new List<Task>();
            Task msg = new Task();
            List<RecordType> smsRecordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE sObjectType = 'Task' AND DeveloperName = 'SMS'];
            if(smsRecordTypeList.size() > 0){
                msg.RecordTypeId = smsRecordTypeList[0].Id;
            }
            
            Map<string,Object> obj = (Map<string,Object>)JSON.deserializeUntyped(responseBody);
            msg.Message_Date__c = datetime.now();
            msg.Subject = 'Outgoing Message';
            if(obj.containsKey('body')){
                msg.Message__c = (string)obj.get('body');
            }
            if(obj.containsKey('from')){
                msg.From__c = (string)obj.get('from');
            }
            if(obj.containsKey('to')){
                msg.To__c = (string)obj.get('to');
            }
            if(obj.containsKey('status')){
                // To convert first alphabet capital
                String statusStr = (string)obj.get('status');
                if(statusStr.length() > 1){
                    msg.Message_Status__c = statusStr.substring(0,1).toUpperCase() + statusStr.substring(1,statusStr.length());
                }
            }
            if(obj.containsKey('sid')){
                msg.MessageSid__c = (string)obj.get('sid');
            }
            msg.Status = 'Completed';
            msg.Type__c = 'Outgoing';
            if(isWho){
                msg.WhoId = contactId;
            }else{
                msg.WhatId = contactId;
            }
            msgList.add(msg);
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error:'+response.getBody());
            ApexPages.addMessage(myMsg);
        }
        
        //Insert task created for messsage sent
        if(msgList.size() > 0){
            insert msgList;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,'Message Sent Successfully');
            ApexPages.addMessage(myMsg);
            body='';
        }
    }
    
    //Method to send message and create task for the sent message from external service
    public static void sendSms(String toNumber, String fromNumber, String body, Id contactId){
  
        System.debug(' ============ In SendSMS method ==========');
        List<Task> msgList = new List<Task>();
        Twilio_Setting__c setting = new Twilio_Setting__c();
        
        //Get Twillo login credentilas
        List<Twilio_Setting__c> settingList = [SELECT Id, Name, AccountId__c, Auth_Token__c, From_Number__c,Status_Callback_URL__c FROM Twilio_Setting__c WHERE Name = 'Twilio Account' LIMIT 1];
        if(settingList.size() > 0){
            setting = settingList[0];
        }
        
        //Endpoint to hit
        string endpointUrl = 'https://api.twilio.com/2010-04-01/Accounts/';
        string statusCallbackURL = '';
        string username = '';
        string password = '';
        //string fromNumber = '';
        
        if(setting.AccountId__c != null){
            endpointUrl += setting.AccountId__c+'/Messages.json';
            username = setting.AccountId__c;
        }
        
        if(setting.Auth_Token__c != null){
            password = setting.Auth_Token__c;
        }
        
        /*if(setting.From_Number__c != null){
            fromNumber = setting.From_Number__c;
        }*/
        
        if(setting.Status_Callback_URL__c != null){
            statusCallbackURL = setting.Status_Callback_URL__c;
        }
        
        //HttpRequest to send
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('POST');
        req.setBody('From='+EncodingUtil.urlEncode(fromNumber, 'UTF-8')+'&To='+EncodingUtil.urlEncode(toNumber, 'UTF-8')+'&Body='+EncodingUtil.urlEncode(body, 'UTF-8')+'&StatusCallback='+EncodingUtil.urlEncode(statusCallbackURL, 'UTF-8'));
        
        Blob headerValue = Blob.valueOf(username +':' +password);
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
            responseBody = '{"from": "+14154847489","to": "+919767199136", "body": "Hello", "status": "queued", "sid": "asdsf514554fdhgd"}';
        }
        Boolean isWho = false;
        String objectAPIName = '';
        
        if(contactId !=null){
            objectApiName = contactId.getSObjectType().getDescribe().getName();
        }
        if(!(objectApiName == null || objectApiName=='') && (objectApiName.equals('Contact') || objectApiName.equals('Lead'))){
            isWho = true;
        }
        
        //If Status is ok then create task for message sent
        if(response.getStatusCode() == 201){
            Task msg = new Task();
            List<RecordType> smsRecordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE sObjectType = 'Task' AND DeveloperName = 'SMS'];
            if(smsRecordTypeList.size() > 0){
                msg.RecordTypeId = smsRecordTypeList[0].Id;
            }
            
            Map<string,Object> obj = (Map<string,Object>)JSON.deserializeUntyped(responseBody);
            msg.Message_Date__c = datetime.now();
            msg.Subject = 'Outgoing Message';
            if(obj.containsKey('body')){
                msg.Message__c = (string)obj.get('body');
            }
            if(obj.containsKey('from')){
                msg.From__c = (string)obj.get('from');
            }
            if(obj.containsKey('to')){
                msg.To__c = (string)obj.get('to');
            }
            if(obj.containsKey('status')){
                // To convert first alphabet capital
                String statusStr = (string)obj.get('status');
                if(statusStr.length() > 1){
                    msg.Message_Status__c = statusStr.substring(0,1).toUpperCase() + statusStr.substring(1,statusStr.length());
                }
            }
            if(obj.containsKey('sid')){
                msg.MessageSid__c = (string)obj.get('sid');
            }
            msg.Status = 'Completed';
            msg.Type__c = 'Outgoing';
            if(isWho){
                msg.WhoId = contactId;
            }else{
                msg.WhatId = contactId;
            }
            msgList.add(msg);
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error:'+response.getBody());
            ApexPages.addMessage(myMsg);
        }
        
        //Insert task created for messsage sent
        if(msgList.size() > 0){
            insert msgList;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,'Message Sent Successfully');
            ApexPages.addMessage(myMsg);
            body='';
        }
    }
}