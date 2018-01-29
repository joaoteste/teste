@isTest (SeeAllData = true)
public class ClientAppSevice_reportCase_test {
	@isTest
	static void reportCase_test(){
		String type = 'Teste';
		String category = 'Teste';
		String reason = 'Teste';
		
		RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
	    //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
	    Map<String, String> infoMap = RAUT.environment8(); 
	    Map<String, Object> args = new Map<String, Object>();
	    args.put('category', category);
	    args.put('type', type);
	    args.put('reason', reason);
	    args.put('message', 'a minha msgs');
	    args.put('subject', 'o meu subject');
	    
	    Test.startTest();
	    	ClientAppService_reportCase CAP_reportCase = new ClientAppService_reportCase(); 
	    	Map<String, Object> casesTestMap = CAP_reportCase.execute(infomap.get('sessionClient'), args);
	    Test.stopTest();
		if(casesTestMap == null){
			System.assert(false, 'There was an error retrieving the case');
		}
	    Map<String, String> caseMap = (Map<String, String>) casesTestMap.get('caseMap');
	    String caseId = (String) caseMap.get('id');
	    Case newCase = [SELECT id FROM Case WHERE ID=:caseId];
	  
	  
	    System.assert(newCase!=null,  'the created case did not match the one obtained on reportCase_test');
    	
	}
}