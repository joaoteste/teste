public class Utilities {
    
    public static void SendEmail(  string address, string content, string subject){
        String[] toAddresses = new List<String>();
        toAddresses.add(address);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(content);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }

    public static void SendEmail(  string[] address, string content, string subject){
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setToAddresses(address);
        email.setPlainTextBody(content);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }

    public static void sendTemplatedEmail(String[] toRecipients, String templateApiName, ID targetObjId, Id whatId, Boolean saveAsActivity) {
      //  templateId   must be ID of an Email template
      // s targetObjId must be a Contact, User, Lead Id -- also ued in merge fields of template recipient.xxxx
      //  whatId    must be an SObject that is used in the merge fields of the template relatedTo.xxxx
      //  fromId    if non null, use current user, otherwise, use this ID (most likely an org wide no reply id)
      
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
    Id templateId;  
    try {
        templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
    }
    catch (Exception e) {
      System.debug('Unable to locate EmailTemplate using name: ' + templateApiName);
    }
        
        
        email.setToAddresses(toRecipients);
        //email.setCcAddresses(ccRecipients);
        email.setTargetObjectId(targetObjId);
        email.setWhatId(whatId);
        //email.setorgWideEmailAddressId(orgWideEmailId);
        email.setTemplateId(templateId);
        email.setSaveAsActivity(saveAsActivity);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users
        
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            return;
        }
        catch (EmailException e) { 
            System.debug(' sendTemplatedEmail error. ' + e.getMessage());
        }
      
    }  

    /*public static Attachment copyAttachment(String OldParentID, String newParentID){
        Attachment oldAttch = [SELECT Name, Body FROM Attachment WHERE ParentID = :oldParentId];
        Attachment newAttch = new Attachment(Name = oldAttch.Name, Body = oldAttch.Body);
        newAttch.parentID = newParentId;
        return newAttch;
    } */ 


    public class OutboundIntegration {
        public datetime startReq { get;set; } 
        public datetime endReq { get;set; } 
        public String status { get;set; } 
        public String code  { get;set; } 
        public String response  { get;set; } 
        public String identifierReq  { get;set; } 
        public string xml { get;set; } 
        public Blob pdf { get;set;}
    }
    
    //ALTERACAO - 23/11/16 - novo método LogIntegrationLongResponse (BP)
    public static ID LogIntegrationLongResponse( datetime startReq, datetime endReq, string status, string code, string request,string identifierReq,string xml){
                                                																								// ,ID Outbound                                              																											
        try{
           /* if(Outbound!=''||Outbound!=null){
            	Outbound_Integration_Log__c out= [Select id,name,get_Received_XML__c from Outbound_Integration_Log__c where id=:Outbound];
            	out.get_Received_XML__c=response;
                update out;
                return out.ID;
            }
            else{*/
            	if(xml.length()>131072)
                   xml = xml.substring(0, 131072);
            
            
            	if(request.length()>131072)
                   request = request.substring(0, 131072);
            	      
            	Outbound_Integration_Log__c log = new Outbound_Integration_Log__c(Start__c = startReq, End__c=endReq, Status__c=status,
                    															Code__c = code,get_Sent_XML__c=request, get_Received_XML__c=xml,  
                                                                                  ApplicationID__c = identifierReq);
                                                                         
                insert log;
                return log.ID;
                }
        //}
        catch(Exception e){
            System.debug('[Utilities - LogIntegration] ERROR - ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage());
            return null;
        }
    }
    
    public static void LogIntegration( datetime startReq, datetime endReq, string status, string code, string response, string identifierReq){
        try{
            
            if(response.length()>250){
                response = response.substring(0, 250);
            }
            
            Outbound_Integration_Log__c log = new Outbound_Integration_Log__c(Code__c = code, Start__c = startReq, ApplicationID__c = identifierReq,                                                                End__c=endReq, Status__c=status, Response__c=response);
            insert log;
            
        }catch(Exception e) {
            System.debug('[Utilities - LogIntegration] ERROR - ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage());
        }
    }
    
    public static Map<String,Object> updateList(List<SObject> listToUpdate, boolean allOrNone){
        
        Map<String, Object> result = new Map<String, Object>();
        
        if(listToUpdate.size()>0){    
            
            if (listToUpdate.size() + Limits.getDMLRows() > Limits.getLimitDMLRows()) {
                
                System.debug('Trying to update ' + listToUpdate.size() + ' records but governor limits will only allow ' + Limits.getLimitDMLRows());
                result.put('error','Trying to update ' + listToUpdate.size() + ' records but governor limits will only allow ' + Limits.getLimitDMLRows());
                
            }else{
                System.debug('Going to update ' + listToUpdate.size() + ' records and governor limits will allow ' + Limits.getLimitDMLRows());
                
                Database.SaveResult[] lsr = Database.update(listToUpdate, allOrNone);
                
                integer i=0;//iteretor needed to get the ID from de failed update. SaveResult come in the same order than listToUpdate.
                for(Database.SaveResult sr : lsr){
                    
                    Map<String, Object> updateResult = new Map<String, Object>();
                    updateResult.put('name', String.valueOf(listToUpdate[i].get('Name')));
                    
                    if(sr.isSuccess()){
                        updateResult.put('status',sr.isSuccess());
                    }else{
                        updateResult.put('status',sr.isSuccess());
                        
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                            updateResult.put('error',err.getStatusCode() + ':  ' + err.getMessage() + ' Fields affected:' + err.getFields());
                        }
                    }
                    
                    result.put(''+listToUpdate[i].ID , updateResult);
                    i++;
                }
            }
        }else{
            result.put('error','List is empty');
        }
        
        return result;
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    } 
   
}