@isTest (SeeAllData = true)
public class ClientAppService_CasesAttachments_test {
    @isTest
    static void getCasesAttachments_test(){
      	//keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        Map<String, String> infoMap = RAUT.environment8(); 
            
        Map<String, Object> args = new Map<String, Object>();

        Attachment attach = RAUT.createAttachment(infomap.get('caseOne'));
        Attachment attach2 = RAUT.createAttachment(infomap.get('caseOne'));
        args.put('caseId', infomap.get('caseOne'));
        
        Test.startTest();
        	ClientAppService_CasesAttachments cas_casesAttachment = new ClientAppService_CasesAttachments();
        	Map<String, Object> attachmentListObject = cas_casesAttachment.getCasesAttachments(infomap.get('sessionClient'), args);
        Test.stopTest();
         
        //List<Map<String,String>> attachesListMap=(List<Map<String,String>>)JSON.deserialize((String) attachmentListObject.get('CasesAttachment'), List<Map<String,String>>.class);
        List<Map<Object, Object>> attachesListMap = (List<Map<Object,Object>>) attachmentListObject.get('CasesAttachment');
        if(attachesListMap == null){
            System.assert(false, 'the system did not found the attachment associated with caseOne in getCasesattachments');
        }
               
        System.assert(attachesListMap[0].get('id') == attach.id || attachesListMap[1].get('id') == attach.id ,'The attachment 1 was not found in the returning value from getCasesAttachments');
        System.assert(attachesListMap[0].get('id') == attach2.id || attachesListMap[1].get('id') == attach2.id,'The attachment 2 was not found in the returning value from getCasesAttachments');
    } 
    
    @isTest
    static void insertAttachmentList_test(){
    	RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        Map<String, String> infoMap = RAUT.environment8(); 
        List<Attachment> attachListBeforeTest = [SELECT ID FROM Attachment WHERE parentID =:infoMap.get('caseOne')];
        //serializar os attachments, enviar e verificar o numero de attachments associados.
        
        //Attachment attach2 = New Attachment(ParentID = infoMap.get('caseOne'), Name = 'titlekkr', body = EncodingUtil.base64Decode('outrocorpo'));
        //Attachment attach1 = New Attachment(ParentID = infoMap.get('caseOne'), Name = 'outrotitlekkr', body = EncodingUtil.base64Decode('corpodoattach'));
        
        Attachment attach2 = New Attachment( Name = 'titlekkr', body = EncodingUtil.base64Decode('outrocorpo'));
        Attachment attach1 = New Attachment( Name = 'outrotitlekkr', body = EncodingUtil.base64Decode('corpodoattach'));
        
        Map<String, String> attachment1Map = new Map<String,String>();
        attachment1Map.put('title',attach1.Name);
        attachment1Map.put('body',EncodingUtil.base64Encode(attach1.Body));
        Map<String, String> attachment2Map = new Map<String,String>();
        attachment2Map.put('title',attach2.Name);
        attachment2Map.put('body',EncodingUtil.base64Encode(attach2.Body));
        
        List<Map<String,Object>> attachListMap = new List<Map<String,Object>>();
        attachListMap.add(attachment1Map);
        attachListMap.add(attachment2Map);
           
        Map<String, Object> args = new Map<String, Object>();
        args.put('caseId', infomap.get('caseOne'));
        args.put('attachmentListMapSerialized', JSON.serialize(attachListMap,true));
        
        Test.startTest();   
        	ClientAppService_CasesAttachments cas_casesAttachment = new ClientAppService_CasesAttachments();
        	Map<String, Object> returnListObject = cas_casesAttachment.insertAttachmentList(infoMap.get('sessionClient'), args);
        Test.stopTest();
 		System.debug('returnListObject');
        List<Attachment> attachListAfterTest = [SELECT ID FROM Attachment WHERE parentID =:infoMap.get('caseOne')];
        
        System.assertEquals(attachListBeforeTest.size()+2,attachListAfterTest.size(),'The number of attachments did not match');
        
    } 
    
}