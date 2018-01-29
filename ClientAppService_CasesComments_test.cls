@isTest (SeeAllData = true)
public class ClientAppService_CasesComments_test {
	@isTest
	static void getCaseCommentsPerCase_test(){
	 	RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
	    //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
	    List<Map<Object, Object>> casesListMap = new List<Map<Object,Object>>();
	    Map<String, String> infoMap = RAUT.environment8(); 
	    
        Map<String, Object> args = new Map<String, Object>();
        args.put('caseId', infomap.get('caseOne'));
        
	    Test.startTest();
	    	ClientAppService_CasesComments CAP_caseComments = new ClientAppService_CasesComments();
	    	Map<String,Object> casesCommentMap = (Map<String,Object>) CAP_caseComments.getCasesComments(infomap.get('sessionClient'), args);
	    Test.stopTest();
	    casesListMap = (List<Map<Object, Object>>) casesCommentMap.get('caseComments');
	    //casesListMap = (List<Map<String,String>>) JSON.deserialize(casesTestList, List<Map<String,String>>.class);
	    if(casesListMap.isEmpty()){
	        System.assert(false,'Case Comments were returned empty');
	    }
	    
	    List<CaseComment> realCaseComment = [SELECT id, parentID FROM CaseComment WHERE ParentId =:infoMap.get('caseOne')];
	    boolean foundEntry=false;
	    
	    for(Map<Object, Object> casesCommentMapTest : casesListMap){
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
    static void newCaseComment_test(){
        RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        Map<String, String> infoMap = RAUT.environment8(); 
        Map<String, Object> args = new Map<String, Object>();
        String commentMsg = 'aminhaMensagem';
        
        args.put('caseId', infoMap.get('caseThree'));
        args.put('message', commentMsg);
        
        Test.startTest();
	        ClientAppService_CasesComments CAP_caseComments = new ClientAppService_CasesComments();
	        CAP_caseComments.newCaseComment(infoMap.get('sessionClient'),args);
        Test.stopTest();
        
        list<CaseComment> caseCommentList = [SELECT CommentBody, ParentID From CaseComment WHERE ParentId =: infoMap.get('caseThree') ORDER BY CreatedDate ASC];
        System.assertEquals(caseCommentList[0].ParentID, infoMap.get('caseThree'), 'The message did not match the expected value');
        
        boolean foundComment = false;
        for(CaseComment csComm: caseCommentList){
            if(csComm.CommentBody == commentMsg){
                foundComment = true;
            }
            
        }
        System.assert(foundComment,'Inserted Comment was not found'); 
    }
}