public class ClientAppService_getCreditNoteAttachs extends ClientAppService{
    
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        
        if(!args.containsKey('creditNoteId')){
            toReturn.put('errorCode','NO_CREDIT_NOTE_ID');
            return toReturn;
        }
        
        Id creditNoteId = Id.valueOf((String)args.get('creditNoteId'));
        
        List<Attachment> atts = [SELECT Id, Name, Body, ContentType, Description FROM Attachment WHERE ParentId = :creditNoteId];
        if(atts == null || atts.size() == 0){
            toReturn.put('errorCode','NO_CREDIT_NOTE_ATT_FOUND');
            return toReturn;
        }
        
        toReturn.put('creditNoteAttachments',convertAttachmentsToMap(atts));
        
        return toReturn;
    }
    
    private List<Map<String,Object>> convertAttachmentsToMap(List<Attachment> atts){
    	List<Map<String, Object>> converted = new List<Map<String, Object>>();
    	
    	for(Attachment att : atts){
    		Map<String, Object> attMap = new Map<String,String>();
        
        	attMap.put('Id',att.Id);
        	attMap.put('Name',att.Name);
        	String bodyStr = EncodingUtil.base64Encode(att.Body);
        	attMap.put('Body', bodyStr);
        	attMap.put('ContentType',att.ContentType);
        	attMap.put('Description',att.Description);
        	
        	converted.add(attMap);
    	}
        
        return converted;
    }
}