@isTest (SeeAllData = true)
public class ClientAppService_getCases_Test {
    @isTest
    static void ClientAppService_getCases_test(){
   		RentingApplication_Util_Test RAUT = new RentingApplication_Util_Test();
        //keys => 'client', 'vendor',  'caseOne', 'caseTwo', 'caseThree', 'contactClient', 'contactVendor', 'loginClient', 'loginVendor', 'sessionClient', 'sessionVendor'
        Map<String, String> infoMap = RAUT.environment8(); 
        List<Case> caseList = [SELECT id, CaseNumber, Reason__c,Category__c, Subject, Priority, CreatedDate, Status, OwnerID, Description, Owner.FirstName,Owner.LastName FROM Case WHERE AccountID = :infomap.get('client')];
        Map<String, Object> args = new Map<String, Object>();
        
        args.put('customer', 'customer');
        args.put('language', 'pt');
        
        Test.startTest();
        	ClientAppService_getCases CAP_getCases = new ClientAppService_getCases();
        	Map<String,Object> casesMapList = CAP_getCases.execute(infomap.get('sessionClient'), args);
        Test.stopTest();
        List<Map<String,String>> casesListMap= (List<Map<String,String>>) casesMapList.get('cases');
	
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
}