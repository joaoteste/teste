public class ClientAppService_CasesAttachments extends ClientAppService {
	public Map<String, Object> getCasesAttachments(String sessionToken, Map<String,Object> args){
		super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        
    	String caseId = (String) args.get('caseId');
        if(caseId==null){
       		System.debug('caseParam e null'); 	
           	toReturn.put('errorCode','NULL_PARAMETERS');
            return toReturn;
        }

    	Case caseParam = new Case();
        caseParam = [SELECT ID FROM case WHERE id=:(String) args.get('caseId') ];
        if(caseParam==null){
       		System.debug('caseParam e null'); 	
           	toReturn.put('errorCode','NULL_PARAMETERS');
            return toReturn;
        }
    	
	    List<Map<Object, Object>> casesMapList = new List<Map<Object, Object>>();
        List<Attachment> attachments = new List<Attachment>();
	    attachments = Case_Utils.getCaseAttachments(caseId);
	        
        for(Attachment attach: attachments){
        	System.debug('attachment found: ' + attach.id); 
            Map<Object, Object> attachmentMap = new Map<Object, Object>();
            
            attachmentMap.put('id',     attach.id);
            attachmentMap.put('title',  attach.name);
            attachmentMap.put('body',   attach.body);
            
            casesMapList.add(attachmentMap);
        }
	    System.debug('Cases Map List: ' + casesMapList);     
	    toReturn.put('CasesAttachment', casesMapList); 	
	    return toReturn;
	}
	
	public Map<String, Object> insertAttachmentList(String sessionToken, Map<String,Object> args){
		super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
		
        if(args.get('caseId') == null || args.get('attachmentListMapSerialized') == null){
            toReturn.put('errorCode','NULL_PARAMETERS');
            return toReturn;
        }
        Case caseParam = [SELECT ID FROM case WHERE id=:(String) args.get('caseId') ];
        if(caseParam==null){
           	toReturn.put('errorCode','NO_CASE_FOUND');
            return toReturn;
        }      
        
        List<Map<String,String>> attachesListMap=(List<Map<String,String>>) JSON.deserialize((String)args.get('attachmentListMapSerialized'), List<Map<String,String>>.class);
        List<Attachment> AttachmentList = new List<Attachment>();
        
        for(Map<String,Object> attachMap : attachesListMap){
            Attachment newAttach = new Attachment( Name =(String) attachMap.get('title'), Body =  EncodingUtil.base64Decode((String) attachMap.get('body')), ParentId = caseParam.ID );
            AttachmentList.add(newAttach);  
            System.debug('newAttach: ' + newAttach); 
        }
        System.debug('AttachmentList: ' + AttachmentList); 
        insert AttachmentList;
        return toReturn;
	}
    
}