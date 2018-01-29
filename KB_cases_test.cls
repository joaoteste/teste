@isTest (SeeAllData = true)
public class KB_cases_test {
	/*
    @isTest
    static void getCasesAttachments_test(){
        //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        Map<String, String> infoMap = RAUT.environment8(); 
        
        Attachment attach = RAUT.createAttachment(infomap.get('caseOne'));
        Attachment attach2 = RAUT.createAttachment(infomap.get('caseOne'));
        Test.startTest();
        String attachmentSerial = KB_cases.getCasesAttachments(infomap.get('caseOne'));
        Test.stopTest();
        List<Map<String,String>> attachesListMap=(List<Map<String,String>>)JSON.deserialize(attachmentSerial, List<Map<String,String>>.class);
        if(attachesListMap == null){
            System.assert(false, 'the system did not found the attachment associated with caseOne in getCasesattachments');
        }
        Boolean foundAttach1 = false;
        Boolean foundAttach2 = false;
        For(Map<String, String> attachMap : attachesListMap){
            if(attachMap.get('id')== attach.id){
                foundAttach1 = true;
            }
            if(attachMap.get('id')== attach2.id){
                foundAttach2 = true;
            }
        }
        System.assert(foundAttach1,'The attachment 1 was not found in the returning value from getCasesAttachments');
        System.assert(foundAttach2,'The attachment 2 was not found in the returning value from getCasesAttachments');
    } 
    
    @isTest
    static void insertAttachmentList_test(){
        RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        Map<String, String> infoMap = RAUT.environment8(); 
        List<Attachment> attachListBeforeTest = [SELECT ID FROM Attachment WHERE parentID =:infoMap.get('caseOne')];
        //serializar os attachments, enviar e verificar o numero de attachments associados.
        
        Attachment attach2 = New Attachment(ParentID = infoMap.get('caseOne'), Name = 'titlekkr', body = EncodingUtil.base64Decode('outrocorpo'));
        Attachment attach1 = New Attachment(ParentID = infoMap.get('caseOne'), Name = 'outrotitlekkr', body = EncodingUtil.base64Decode('corpodoattach'));
        
        Map<String, String> attachment1Map = new Map<String,String>();
        attachment1Map.put('title',attach1.Name);
        attachment1Map.put('body',EncodingUtil.base64Encode(attach1.Body));
        Map<String, String> attachment2Map = new Map<String,String>();
        attachment2Map.put('title',attach2.Name);
        attachment2Map.put('body',EncodingUtil.base64Encode(attach2.Body));
        
        List<Map<String,String>> attachListMap = new List<Map<String,String>>();
        attachListMap.add(attachment1Map);
        attachListMap.add(attachment2Map);
        
        Test.startTest();   
        KB_cases.insertAttachmentList(infoMap.get('caseOne'), JSON.serialize(attachListMap,true));
        Test.stopTest();
        List<Attachment> attachListAfterTest = [SELECT ID FROM Attachment WHERE parentID =:infoMap.get('caseOne')];
        
        System.assertEquals(attachListBeforeTest.size()+2,attachListAfterTest.size(),'The number of attachments did not match');
    }
    
    @isTest
    static void getCasesPerLogin_test(){
        
        RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        Map<String, String> infoMap = RAUT.environment8(); 
        List<Case> caseList = [SELECT id, CaseNumber, Reason__c,Category__c, Subject, Priority, CreatedDate, Status, OwnerID, Description, Owner.FirstName,Owner.LastName FROM Case WHERE AccountID = :infomap.get('client')];
        
        Test.startTest();
        	String casesTestList = KB_cases.getCasesPerLogin(infomap.get('sessionClient'), 'customer', 'pt');
        Test.stopTest();
        List<Map<String,String>> casesListMap=(List<Map<String,String>>)JSON.deserialize(casesTestList, List<Map<String,String>>.class);
	
	
		//System.debug(casesListMap.size());
		//System.debug(caseList.size());
        //if(casesListMap.size() != caseList.size()){
        //    System.assert(false, 'The number of cases did not match');
        //}
        boolean foundCaseOne = false;
        boolean foundCaseTwo = false;
        boolean foundCaseThree = false;
        
        for(Map<String,String> casesMap:  casesListMap){
            if(infoMap.get('caseOne') == casesMap.get('id')){
                foundCaseOne = true;
            }
            if(infoMap.get('caseTwo') == casesMap.get('id')){
                foundCaseTwo = true;
            }
            if(infoMap.get('caseThree') == casesMap.get('id')){
                foundCaseThree = true;
            }
        }
        System.assert(foundCaseOne, 'didn\'t find the case one from ClientAppController_test');
        System.assert(foundCaseTwo, 'didn\'t find the case two from ClientAppController_test');
        System.assert(foundCaseThree, 'didn\'t find the case three from ClientAppController_test');
    }
    
    @isTest //tests if using an account there is cases for it
    static void getCaseCommentsPerCase_test(){
        RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        List<Map<String,String>> casesListMap = new List<Map<String,String>>();
        Map<String, String> infoMap = RAUT.environment8(); 
        
        Test.startTest();
        	String casesTestList = KB_cases.getCaseCommentsPerCase(infomap.get('sessionClient'), infoMap.get('caseOne'));
        Test.stopTest();
        casesListMap = (List<Map<String,String>>) JSON.deserialize(casesTestList, List<Map<String,String>>.class);
        if(casesListMap.isEmpty()){
            System.assert(false,'Case Comments were returned empty');
        }
        
        List<CaseComment> realCaseComment = [SELECT id, parentID FROM CaseComment WHERE ParentId =:infoMap.get('caseOne')];
        boolean foundEntry=false;
        
        for(Map<String, String> casesCommentMapTest : casesListMap){
            foundEntry = false;
            for(CaseComment realCaseCom: realCaseComment){
                if(casesCommentMapTest.get('id') == realCaseCom.ID){
                    foundEntry = true;
                }
            }
            System.assert(foundEntry,'Expected Case comment was not found!'); 
        }
        return;
    }
    
    @isTest
    static void reportCase_test(){
        RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        Map<String, String> infoMap = RAUT.environment8(); 
        Test.startTest();
        String casesTestList = KB_cases.reportCase(infomap.get('sessionClient'),'Alteração de Dados do Parceiro','oMeuTema','aminhaMensagem');
        Test.stopTest();
        Map<String, String> caseMap= (Map<String, String>) JSON.deserialize(casesTestList, Map<String, String>.class);
        Case newCase = [SELECT id FROM Case WHERE ID=:caseMap.get('id')];
        System.assertEquals(newCase.id, caseMap.get('id'), 'the created case did not match the one obtained on reportCase_test');
    }
    
    @isTest
    static void newCaseComment_test(){
        RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        Map<String, String> infoMap = RAUT.environment8(); 
        
        Test.startTest();
        KB_cases.newCaseComment(infoMap.get('caseThree'),'aminhaMensagem');
        Test.stopTest();
        list<CaseComment> caseCommentList = [SELECT CommentBody, ParentID From CaseComment WHERE ParentId =: infoMap.get('caseThree') ORDER BY CreatedDate ASC];
        System.assertEquals(caseCommentList[0].ParentID, infoMap.get('caseThree'), 'The mensage did not match the expected value');
        
        boolean foundComment = false;
        for(CaseComment csComm: caseCommentList){
            if(csComm.CommentBody =='aminhaMensagem'){
                foundComment = true;
            }
            
        }
        System.assert(foundComment,'Inserted Comment was not found'); 
    }
    
    @isTest
    static void getCaseClientReasons_test(){
        Map<String, List<String>> fieldDependenciesMapList = Utils_DependentPicklist.getFieldDependencies('Case', 'Category__c', 'Reason__c');
        Test.startTest();
        	String caseClientReasonsSerialized = KB_cases.getCaseClientReasons();
        Test.stopTest();
        List<String> clientReasonList= (List<String>) JSON.deserialize(caseClientReasonsSerialized, List<String>.class);
        Boolean foundPickListValue;
        for(String picklistReason: clientReasonList){
            List<String> reasonsList = fieldDependenciesMapList.get('Cliente');
            foundPickListValue = false;
            for(String reasons :reasonsList){
                if(reasons == picklistReason){
                    foundPickListValue = true;
                }
            }
            System.assert(foundPickListValue, 'The value: '+picklistReason+ ' was not found by the returned value of getCaseClientReasons');
            foundPickListValue = false;
        }  
    } */
    
}