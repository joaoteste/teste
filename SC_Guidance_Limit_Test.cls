@isTest(SeeAllData=true)
private class SC_Guidance_Limit_Test {
	
    static testMethod void withProcessBuilderInactiveTest() {

    	Test.startTest();
    	
        Account accountClient = SC_UTIL_Test.createAccountSocietiesAndCorporationsMCutOff();
        
        SC_ScoreCard scoreCard = new SC_ScoreCard();
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(accountClient.Id);
        
        ReportDB__c report1 = [SELECT Id, Scorecard__c FROM ReportDB__c WHERE Vendor__c = :accountClient.Id ORDER BY CreatedDate DESC LIMIT 1];
        Scorecard__c scoreCardRecord = [SELECT Id FROM Scorecard__c WHERE Name = 'SCA-000002' ];
        
        report1.Scorecard__c = scoreCardRecord.Id;  //Simulate the process builder
        List<Id> decisionIdList = scoreCard.createDecisionsFromCreditInfo(accountIdList);
        
        
        List<Decision__c> decisionList = [SELECT Id FROM Decision__c WHERE Id IN :decisionIdList];
    	
    	SC_Guidance_Limit.updateDecision(decisionList);
        
        Test.stopTest();
    }

}