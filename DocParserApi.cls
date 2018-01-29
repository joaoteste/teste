global class DocParserApi {
    
    public static String apiKey = 'a1ed217f9604f81920aa3b393a7c0db3f9de32ff';
    
    //vendor invoice (VINV)
    webservice static String vinvDocparser(Id caseID){
        Savepoint sp;
        String msg = '';
        try{
            sp = Database.setSavepoint();
            List<Attachment> attachList = new List<Attachment>([Select ID,Name,ParentId,Body,BodyLength,ContentType,Description 
                                                                From Attachment 
                                                                where ParentId = :caseID]);
            
            Case caseValue = [Select Id,AccountId 
                              From Case 
                              where id = :caseID];
            
            if(attachList.isEmpty()){
                msg = 'There is no attachments on case to send to DocParser!';
                System.debug(msg);
                //Apex.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is no attachments on case to send to DocParser!'));
            }
            Account  acc;
            if(caseValue.AccountId == null){
                msg += ' Please fill the Account Name field!';
                System.debug('Please fill the Account Name field');
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill the Account field!'));
            }else{
                acc= [Select ID,DocParser__c  
                      From Account 
                      where id = :caseValue.AccountId limit 1];
                
                if(acc.DocParser__c == null || acc.DocParser__c == '' ){
                    msg += ' There is no Parser created or associated for that Account!';
                }
            }
            
            if(msg != null && msg != '' ){
                Database.rollback(sp);
                return msg;
            }
            
            
            Attachment attach = attachList.get(0);
            
            List<String> sendTo = new List<String>();
            sendTo.add(acc.DocParser__c);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(sendTo);
            
            //Set email file attachments
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            
            // Add to attachment file list
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(attach.Name);
            efa.setBody(attach.Body);
            fileAttachments.add(efa);
            email.setPlainTextBody('Your Email has been sent');
            
            email.setFileAttachments(fileAttachments);
            //Send email
            if(!Test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
            return 'Sent to DocParser! Make sure there is a layout for this invoice';
            
        }catch(exception e){
            system.debug('ERROR: in DocParser integration');
            System.debug('exception: '+ e.getStackTraceString());
            // Rollback to the previous value
            Database.rollback(sp);
            // To see the exception
            throw e;
            return 'ERROR: in DocParser integration';
        }
    }
    
    public static boolean verifyParserAccount(ID loginId){
        
        Account acc = [Select Id,Name,Type,DocParser__c
                       From Account
                       where id =: ([SELECT ID, IdVendor__c 
                                     FROM Login__c 
                                     WHERE id=:loginId limit 1].IdVendor__c)];
        
        if(acc.DocParser__c == '' || acc.DocParser__c == null){
            
            List<Case> verifyCase = [SELECT id 
                                     FROM Case 
                                     WHERE AccountID = :acc.ID and Category__c = 'DocParser' and Reason__c = 'Sem Parser'];
            
            //if there isn't a case it will create 
            if(verifyCase.isEmpty() || verifyCase == null){
                Case_Utils.createCaseDocParser(acc);
            }
            return false;
        }else{
            return true;
        }
        
    }
    
    public static String getDocParserVendor(ID vendorLoginID, String docPaserAttachID){
        try{
            Account acc = [SELECT ID,DocParser__c 
                           From Account 
                           where id in (Select IdVendor__c 
                                        FROM Login__c 
                                        where id = :vendorLoginID)];
            
            String parserId = acc.DocParser__c;
            String apiUrl = 'https://api.docparser.com/v1/results/' + parserId+'/'+docPaserAttachID+'?api_key='+apiKey;
            
            String body;
            
            if(!Test.isRunningTest()){
                HTTPResponse res = Rest_Utils.sendGet(apiUrl);
                
                if(res == null || res.getStatusCode() != 200){
                    return '';
                }
                
                body  = res.getBody();
            }else{
                body = '[{';
                body += '"id":"d3fb79d05132992307c41df3bceebafa","document_id":"2439dd6add270585c89b33957969f67b","remote_id":"","file_name":"Fatura Parceiro - 0012400000YCyhHAAT.pdf"';
                body += ',"due_date":{"match":"2017-07-26","iso8601":"2017-07-26"}';
                body += ',"line_items":[{"referencia":"HWPOS-47","designacao":"POS OKPOS 1500 ns: KL30128 ns: KL30166 ns: KL30189","quantidade":"3,00","preco_unitario":"800,00","desconto":"","total":"2.400,00","iva":"23 23 23 23"}]';
                body += '}]';
            }
            System.debug('body ' +body);
            JSONParser parser = JSON.createParser(body);
            //recreate the json Parson
            System.debug('parser '+parser);
            
            String toJson = '[{';
            
            while (parser.nextToken() != null) {
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'due_date')) {
                    if(!toJson.equals('[{')){
                        toJson  += ',';
                    }
                    toJson  += '"' + parser.getText() + '":"';
                    
                    while(parser.nextToken() != null){
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'iso8601')) {
                            parser.nextValue();
                            toJson  += parser.getText() + '"';
                            break;
                        }
                    }
                    
                }
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'invoice_date')) {
                    if(!toJson.equals('[{')){
                        toJson  += ',';
                    }
                    toJson  += '"' + parser.getText() + '":"';
                    
                    while(parser.nextToken() != null){
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'iso8601')) {
                            parser.nextValue();
                            toJson  += parser.getText() + '"';
                            break;
                        }
                    }
                }
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'line_items')) {
                    if(!toJson.equals('[{')){
                        toJson  += ',';
                    }
                    toJson  += '"' + parser.getText() + '":"';
                    toJson  += '[{';
                    parser.nextToken();
                    System.debug('toJson1 '+toJson);
                    Boolean first = true;
                    while(parser.getText() != ']'){
                        System.debug('toJson20 '+toJson);
                        
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'referencia')) {
                            if(!first){
                                toJson  += ',';
                            }
                            toJson  += '"' + parser.getText() + '":"';
                            parser.nextValue();
                            toJson  += parser.getText() + '"';
                            System.debug('toJson2 '+toJson);
                            first= false;
                            
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'designacao')) {
                            if(!first){
                                toJson  += ',';
                            }
                            toJson  += '"' + parser.getText() + '":"';
                            parser.nextValue();
                            toJson  += parser.getText() + '"';
                            System.debug('toJson2 '+toJson);
                            first = false;
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'quantidade')) {
                            if(!first){
                                toJson  += ',';
                            }
                            toJson  += '"' + parser.getText() + '":"';
                            parser.nextValue();
                            toJson  += parser.getText() + '"';
                            System.debug('toJson2 '+toJson);
                            first = false;
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'preco_unitario')) {
                            if(!first){
                                toJson  += ',';
                            }
                            toJson  += '"' + parser.getText() + '":"';
                            parser.nextValue();
                            toJson  += parser.getText() + '"';
                            System.debug('toJson2 '+toJson);
                            first = false;
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'total')) {
                            if(!first){
                                toJson  += ',';
                            }
                            toJson  += '"' + parser.getText() + '":"';
                            parser.nextValue();
                            toJson  += parser.getText() + '"';
                            System.debug('toJson2 '+toJson);
                            first = false;
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'iva')) {
                            if(!first){
                                toJson  += ',';
                            }
                            toJson  += '"' + parser.getText() + '":"';
                            parser.nextValue();
                            toJson  += parser.getText() + '"';
                            System.debug('toJson2 '+toJson);
                            first = false;
                        }
                        parser.nextToken();
                    }
                }
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'invoice_number')) {
                    if(!toJson.equals('[{')){
                        toJson  += ',';
                    }
                    toJson  += '"' + parser.getText() + '":"';
                    parser.nextValue();
                    toJson  += parser.getText() + '"';
                }
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'nifnipc')) {
                    if(!toJson.equals('[{')){
                        toJson  += ',';
                    }
                    toJson  += '"' + parser.getText() + '":"';
                    parser.nextValue();
                    toJson  += parser.getText() + '"';
                }
            }
            
            toJson += '}]';
            
            return toJson;
            
        }catch(Exception e){
            Outbound_Integration_Log__c outboundIntegrationLog = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'CRITICAL',ApplicationID__c = 'DOCPARSER REST_GET',message__c = e.getMessage(),printStackTrace__c = e.getStackTraceString());
            system.debug('CRITICAL: '+ outboundIntegrationLog);
            insert outboundIntegrationLog;
            system.debug(e.getStackTraceString());  
            return '';
        }
    }
    
    public static String postDocParserVendor(ID vendorLoginID, Id attachID){
        
        try{
            Account acc = [SELECT ID,DocParser__c 
                           From Account
                           where id in (Select IdVendor__c 
                                        FROM Login__c 
                                        where id = :vendorLoginID)];
            
            String parserId = acc.DocParser__c;
            
            // Get the PDF file from your database, change this accordingly
            Attachment yourPDF = [Select ID,Name,ParentId,Body,BodyLength,ContentType,Description 
                                  From Attachment 
                                  where id = :attachID];
            
            
            // Your Docparser API key and the document parser ID, get these values from the settings of your parser
            
            String apiUrl = 'https://api.docparser.com/v1/document/upload/' + parserId + '?remote_id=' + yourPDF.Id;
            string Authorization = 'Basic ' + apiKey;
            
            String body ='';
            if(!Test.isRunningTest()){
                
                HTTPResponse res = Rest_Utils.postFileAttachment(apiUrl,yourPDF,Authorization);
                
                if(res.getStatusCode() != 200 ){
                    return '';            
                }
                
                body = res.getbody();
            }else{
                body = '{"id":"a4adae6fa4ba2fbde61250cba59ea0ee","file_size":239500,"quota_used":44,"quota_left":6,"quota_refill":"1970-01-01T00:00:00+00:00"}';
            }
            
            JSONParser parser = JSON.createParser(body);
            
            String newJson = '[{';
            
            while(parser.nextToken() != null){
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                    newJson  += '"' + parser.getText() + '":"';
                    parser.nextValue();
                    newJson  += parser.getText() + '"';            
                }
            }
            
            newJson += '}]';
            
            return newJson ;
            
        }catch(Exception e){
            Outbound_Integration_Log__c outboundIntegrationLog = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'CRITICAL',ApplicationID__c = 'DOCPARSER REST_POST Attach', message__c = e.getMessage() ,printStackTrace__c = e.getStackTraceString());
            system.debug('CRITICAL: '+ outboundIntegrationLog);
            insert outboundIntegrationLog;
            system.debug(e.getStackTraceString());  
            return '';
        }
    }
}