public class ClientAppService_getAppAttachments extends ClientAppService{
    
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        
        if(!args.containsKey('rentingAppId')){
            toReturn.put('errorCode','NO_RENTING_APP_ID');
            return toReturn;
        }
        
        Id appId = Id.valueOf((String)args.get('rentingAppId'));
        RentingApplication ra = new RentingApplication(appId);
		RentingApplication.appDownloads attachments = ra.getAppAttachments();
        
        if(attachments.contratoAttchDownload == null && attachments.autoAttchDownload == null){
            toReturn.put('errorCode','NO_ATTS_FOUND');
        }
        
        toReturn.putAll(convertAttachmentsToMap(attachments));
        return toReturn;
    }
    
    private Map<String,Object> convertAttachmentsToMap(RentingApplication.appDownloads atts){
        Map<String,Object> converted = new Map<String,Object>();
        
        if(atts.contratoAttchDownload != null){
            Map<String, Object> attMap = new Map<String,String>();
            Attachment att = atts.contratoAttchDownload;
            attMap.put('Id',att.Id);
            attMap.put('Name',att.Name);
            //String bodyStr = EncodingUtil.base64Encode(att.Body);
            //attMap.put('Body', bodyStr);
            //attMap.put('ContentType',att.ContentType);
            //attMap.put('Description',att.Description);
            converted.put('contractAttachment',attMap);
        }
        if(atts.autoAttchDownload != null){
            Map<String, Object> attMap = new Map<String,String>();
            Attachment att = atts.autoAttchDownload;
            attMap.put('Id',att.Id);
            attMap.put('Name',att.Name);
            //String bodyStr = EncodingUtil.base64Encode(att.Body);
            //attMap.put('Body', bodyStr);
            //attMap.put('ContentType',att.ContentType);
            //attMap.put('Description',att.Description);
            converted.put('autoAttachment',attMap);
        }
        
        return converted;
    }
    
}