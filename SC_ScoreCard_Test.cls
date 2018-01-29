@isTest(SeeAllData=true)
private class SC_ScoreCard_Test {
     // Test with real config data, because the tables can change. Be carefull with the error analisys
     
         // Inactive Companies
    static testMethod void withProcessBuilderInactiveTest() {
    	
    	Test.startTest();
    	
        Account accountClient = SC_UTIL_Test.createAccountInactiveCompanies();
        
        SC_ScoreCard scoreCard = new SC_ScoreCard();
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(accountClient.Id);
        
        ReportDB__c report1 = [SELECT Id, Scorecard__c FROM ReportDB__c WHERE Vendor__c = :accountClient.Id ORDER BY CreatedDate DESC LIMIT 1];
        Scorecard__c scoreCardRecord = [SELECT Id FROM Scorecard__c WHERE Name = 'SCA-000002' ];
       
        report1.Scorecard__c = scoreCardRecord.Id;  //Simulate the process builder
        scoreCard.createDecisionsFromCreditInfo(accountIdList);
        
        Test.stopTest();
    }

    // Inactive Companies
    static testMethod void inactiveCompaniesTest() {
    	
    	Test.startTest();
    	
        Account accountClient = SC_UTIL_Test.createAccountInactiveCompanies();
        
        SC_ScoreCard scoreCard = new SC_ScoreCard();
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(accountClient.Id);
        scoreCard.createDecisionsFromCreditInfo(accountIdList);
        
        Test.stopTest();
    }

    // Societies and Corporations >= Cut-Off
    static testMethod void societiesAndCorporationsMCutOffTest() {
    	
    	Test.startTest();
    	// SC_UTIL_Test.createConfigurationData();
        Account accountClient = SC_UTIL_Test.createAccountSocietiesAndCorporationsMCutOff();
        
        SC_ScoreCard scoreCard = new SC_ScoreCard();
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(accountClient.Id);
        scoreCard.createDecisionsFromCreditInfo(accountIdList);
        
        Test.stopTest();
        //TODO Assert do Score card, etc
    }
    
    static testMethod void checkScoreCardTable() {
    	// este metodo tem de ter see all data
        //query all score cards
        
        Map<Id, Scorecard__c> scoreCardMap = new Map<Id, Scorecard__c>([SELECT Id, Name, (SELECT Id
                                                                      , Field_Name__c
                                                                      , Field_API_Name__c
                                                                      , Related_Object_API_Name__c
                                                                      , Matching_Type__c
                                                                      , Matching_Value__c
                                                                      , Min_Value__c
                                                                      , Max_Value__c
                                                                      , Query_Filter__c
                                                                      , Value__c
                                                                      , Related_Object__c FROM Scorecard_Line_Items__r),
                                                                      
                                                                   (SELECT Id
                                                                      , Related_Object__c
                                                                      , Related_Object_API_Name__c
                                                                      , Field_API_Name__c
                                                                      , Field_Name__c
                                                                      , Scorecard__c
                                                                      , Weight__c FROM Score_Card_Fields_Weight__r)
                                                            
                                                             FROM Scorecard__c ]);

 //       Test.startTest();
          
 //       Test.stopTest();
        //check if the sum of Weight is 100%
        for(Scorecard__c scoreCard : scoreCardMap.values() ){
        	Decimal scoreWeightSum = 1;
            if(scoreCard.Score_Card_Fields_Weight__r != null && scoreCard.Score_Card_Fields_Weight__r.size() != 0){
            	scoreWeightSum = 0;
            	for(Score_Card_Field_Weight__c scoreWeight: scoreCard.Score_Card_Fields_Weight__r){
            		scoreWeightSum += scoreWeight.Weight__c;
            	}
            }
            System.assertEquals( 1.00 , scoreWeightSum, 'TODO msg' + scoreCard + 'RRR');
        }                                                   

        //check if the weigth exit when is need
        for(Scorecard__c scoreCard : scoreCardMap.values() ){
            if(scoreCard.Scorecard_Line_Items__r != null && scoreCard.Scorecard_Line_Items__r.size() != 0){

            	for(Scorecard_Line_Item__c scoreLI : scoreCard.Scorecard_Line_Items__r){
            		if(scoreLI.Matching_Type__c != 'Static Value'){
            			Boolean weightExitForTheScoreCardLineItem = false;
            			
            			for(Score_Card_Field_Weight__c scoreWeight: scoreCard.Score_Card_Fields_Weight__r){
            		        if(scoreLI.Field_API_Name__c == scoreWeight.Field_API_Name__c ){ //TODO check also Object
            		        	weightExitForTheScoreCardLineItem = true;
            		        	break;
            		        }
            	        }
            		    System.assert( weightExitForTheScoreCardLineItem == true ,'TODO msg 2135289' + scoreLI );
            		}
            	}
            	
            }else{
            	System.assertEquals(1, 0, 'O score Card' + scoreCard + 'não tem line Items');
            }

        }
         
        //TODO check if the fields exit etc
        
    } 


}