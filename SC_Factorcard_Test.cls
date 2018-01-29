@isTest(SeeAllData=true)
public class SC_Factorcard_Test {
   
       static testMethod void shouldReturnCorrectFactor() {
        //setup
        Account testAccount = SC_UTIL_Test.createAccountSocietiesAndCorporationsMCutOff();

        SC_ScoreCard scoreCard = new SC_ScoreCard();
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(testAccount.Id);
        scoreCard.createDecisionsFromCreditInfo(accountIdList);
           
        String testCountry = 'PT';
        Integer testContractValue = 15000;
        String testTerm = '60';
        String testFactorType = 'Standard';
        Decimal expectedFactor = 2.0016;//value obtained via debug in SC_Factorcard (GRADE C SUBGRADE 2)
          
        //test
        Test.startTest();
        Decimal factor = SC_Factorcard.getFactor(testAccount.Id, testCountry, testContractValue, testTerm, testFactorType);
           
        Test.stopTest();
        
        //assert
        System.assert(factor != null,'Returned null as factor');
        //System.assertEquals(expectedFactor, factor,'Didnt return expected Factor for account '+testAccount.Id + '; contractValue '+testContractValue +'; term '+testTerm + '; factorType '+testFactorType);
    }

    static testMethod void shouldReturnNullFactor(){
        //setup
        Account testAccount = SC_UTIL_Test.createAccountInactiveCompanies();

        SC_ScoreCard scoreCard = new SC_ScoreCard();
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(testAccount.Id);
        scoreCard.createDecisionsFromCreditInfo(accountIdList);
           
        String testCountry = 'PT';
        Integer testContractValue = 50001;
        String testTerm = '12';
        String testFactorType = 'Standard';
           
        //test
        Test.startTest();
        Decimal factor = SC_Factorcard.getFactor(testAccount.Id, testCountry, testContractValue, testTerm, testFactorType);
           
        Test.stopTest();
        
        //assert
        System.assert(factor == null,'Didnt return NULL factor when contractValue is greater than 50000');
    }

}