@isTest(SeeAllData=true)
public class Decision_Trigger_Test {
    
    static testMethod void testModifiyDecision(){
    	
    	
    	// SC_UTIL_Test.createConfigurationData();
        Account accountClient = SC_UTIL_Test.createAccountSocietiesAndCorporationsMCutOff();
        
        SC_ScoreCard scoreCard = new SC_ScoreCard();
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(accountClient.Id);
        scoreCard.createDecisionsFromCreditInfo(accountIdList);
        
     //   Test.stopTest();
        //TODO alterar o grade e ver o se faz o novo calculo da Guidance, etc
     //   Test.startTest();
        
        //TODO Assert do Score card, etc
    }
}