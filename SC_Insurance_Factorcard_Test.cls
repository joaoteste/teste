@isTest(SeeAllData=true)
public class SC_Insurance_Factorcard_Test {

    static testMethod void shouldReturnCorrectFactor() {
        //setup
        Account testAccount = SC_UTIL_Test.createAccountSocietiesAndCorporationsMCutOff();

        SC_ScoreCard scoreCard = new SC_ScoreCard();
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(testAccount.Id);
        scoreCard.createDecisionsFromCreditInfo(accountIdList);
           
        String testCountry = 'PT';
        Decimal testContractValue = 15000;
        String testFactorType = 'Static';
        Decimal expectedFactor = 3.1835;//value obtained via debug in SC_Insurance_Factorcard (G,STATIC)
          
        //test
        Test.startTest();
        Decimal factor = SC_Insurance_Factorcard.getFactor(testAccount.Id, testCountry, testContractValue, testFactorType);
           
        Test.stopTest();
        
        //assert
        System.assert(factor != null,'Returned null as factor'); 
//        System.assertEquals(expectedFactor, factor,'Didnt return expected Factor ('+ expectedFactor+') for account '+testAccount.Id + '; contractValue '+testContractValue +'; factorType '+testFactorType+'; returned factor '+factor);
    }
    
    static testMethod void shouldReturnNullFactor(){
        //setup
        Account testAccount = SC_UTIL_Test.createAccountInactiveCompanies();

        SC_ScoreCard scoreCard = new SC_ScoreCard();
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(testAccount.Id);
        scoreCard.createDecisionsFromCreditInfo(accountIdList);
           
        String testCountry = 'PT';
        Decimal testContractValue = 50001;
        String testFactorType = 'Standard';
        Decimal expectedFactor = null;//max contract value is 50000
           
        //test
        Test.startTest();
        Decimal factor = SC_Insurance_Factorcard.getFactor(testAccount.Id, testCountry, testContractValue, testFactorType);
           
        Test.stopTest();
        
        //assert
        System.assertEquals(expectedFactor, factor,'Didnt return expected Factor ('+ expectedFactor +') for account '+testAccount.Id + '; contractValue '+testContractValue +'; factorType '+testFactorType +'; returned factor '+factor);
    }

}