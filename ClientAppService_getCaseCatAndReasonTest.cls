@isTest (SeeAllData = true)
public class ClientAppService_getCaseCatAndReasonTest {
    @isTest
    static void ClientAppService_getCaseCatAndReasonTest(){
    	RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
	    //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
	    Map<String, String> infoMap = RAUT.environment8(); 
	    Map<String, Object> args = new Map<String, Object>();
    	
	    Map<String, List<String>> typeToCategory = Utils_DependentPicklist.getFieldDependencies('Case', 'Type', 'Category__c');
        Map<String, List<String>> categoryToReason = Utils_DependentPicklist.getFieldDependencies('Case', 'Category__c', 'Reason__c');
        Map<String, List<String>> categoryAndReason = new Map<String, List<String>>();

        List<String> reasons = new List<String>();
        
        for(String category: typeToCategory.get('Cliente')){
            System.debug(category);
            reasons = categoryToReason.get(category);
            categoryAndReason.put(category, reasons);
        }

        Test.startTest();
         	ClientAppService_getCaseCatAndReason CAS_CatAndReason = new ClientAppService_getCaseCatAndReason();
        	Map<String, Object> caseClientReasonsMap = CAS_CatAndReason.execute(infoMap.get('sessionClient'), args);
        Test.stopTest();
        
        Map<String, List<String>> clientReasonListTest = (Map<String, List<String>>) caseClientReasonsMap.get('categoryAndReason');
        
        List<String> reasonsList = new List<String>();
        List<String> reasonsTestList = new List<String>();

        for(String picklistReason: typeToCategory.get('Cliente')){
            reasonsList = categoryToReason.get(picklistReason);
            reasonsTestList = clientReasonListTest.get(picklistReason);
      
            System.assert(reasonsList.equals(reasonsTestList), 'The Reasons for: '+ picklistReason + '  did not match!!' );

        }  
    } 
}