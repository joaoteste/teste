@isTest (SeeAllData = true)
public class decisionWrapper_test {
	@isTest
    static void decisionWrapperId_test(){
        
        Account acc = SC_UTIL_Test.createAccountInactiveCompanies();
        List<Decision__c> dec = [SELECT ID, Name, Active__c, Score__c, Credit_Info__c, Decision_Origin__c, Decison_Status__c, Grade__c, Guidance_Limit_Line_Item__c,
                                 Guidance_Limit_Max__c, Guidance_Limit_Min__c, Guidance_Limit_Scorcard__c, Override__c, Sub_Grade__c, Account__r.BillingCountry FROM Decision__c WHERE Account__c =:acc.ID AND Active__c = true Limit 1];
        if(dec == null || dec.size()==0){
            System.assert(false, 'No decision found for this account');
        }
    
        Decimal min_credit =  [SELECT Minimum_Credit_Allowed__c FROM Credit_Decisions_Settings__mdt WHERE Label =: dec[0].Account__r.BillingCountry LIMIT 1].Minimum_Credit_Allowed__c;       
        Test.startTest();
        	decisionWrapper dw = new decisionWrapper(dec[0].ID);
        Test.stopTest();
        
        System.assertEquals(dec[0].Id, dw.decisionID, 'The id did not match gotten: '+ dw.decisionID +' expected: ' + dec[0].Id);
        System.assertEquals(dec[0].Name, dw.decisionName, 'The name did not match gotten: '+ dw.decisionName +' expected: ' + dec[0].Name);
        System.assertEquals(dec[0].Credit_Info__c, dw.creditInfo, 'The credit info did not match gotten: '+ dw.creditInfo +' expected: ' + dec[0].Credit_Info__c);
        System.assertEquals(dec[0].Score__c, dw.candorScore, 'The Candor score did not match gotten: '+ dw.candorScore +' expected: ' + dec[0].Score__c);
        System.assertEquals(dec[0].Grade__c, dw.grade, 'The grade did not match gotten: '+ dw.grade +' expected: ' + dec[0].Grade__c);
        System.assertEquals(dec[0].Decison_Status__c, dw.decisionStatus, 'The decision status did not match gotten: '+ dw.decisionStatus +' expected: ' + dec[0].Decison_Status__c);
        System.assertEquals(dec[0].Sub_Grade__c, dw.subGrade, 'The sub_grade did not match gotten: '+ dw.subGrade +' expected: ' + dec[0].Sub_Grade__c);
        System.assertEquals(min_credit, dw.guidanceLimitMin, 'The guidance limit min did not match gotten: '+ dw.guidanceLimitMin +' expected: ' + dec[0].Guidance_Limit_Min__c);
        System.assertEquals(dec[0].Guidance_Limit_Max__c, dw.guidanceLimitMax, 'The guidance limit max not match gotten: '+ dw.guidanceLimitMax +' expected: ' + dec[0].Guidance_Limit_Max__c);
    	System.assertEquals(dec[0].Override__c, dw.Over_ride, 'The override did not match gotten: '+ dw.Over_ride +' expected: ' + dec[0].Override__c);
    	System.assertEquals(dec[0].Active__c, dw.active, 'The active did not match gotten: '+ dw.active +' expected: ' + dec[0].Active__c);
        
    }
    @isTest
    static void decisionWrapperDecision_test(){
 
        Account acc = SC_UTIL_Test.createAccountInactiveCompanies();
        List<Decision__c> dec = [SELECT ID, Name,Account__r.BillingCountry, Active__c, Account__c, Score__c, Credit_Info__c, Decision_Origin__c, Decison_Status__c, Grade__c, Guidance_Limit_Line_Item__c,
                                 Guidance_Limit_Max__c, Guidance_Limit_Min__c, Guidance_Limit_Scorcard__c, Override__c, Sub_Grade__c FROM Decision__c WHERE Account__c =:acc.ID];
        if(dec == null || dec.size()==0){
            System.assert(false, 'No decision found for this account');
        }
    
        Decimal min_credit =  [SELECT Minimum_Credit_Allowed__c FROM Credit_Decisions_Settings__mdt WHERE Label =: dec[0].Account__r.BillingCountry LIMIT 1].Minimum_Credit_Allowed__c;       
        Test.startTest();
        	decisionWrapper dw = new decisionWrapper(dec[0]);
		Test.stopTest();
        
        System.assertEquals(dec[0].Id, dw.decisionID, 'The id did not match gotten: '+ dw.decisionID +' expected: ' + dec[0].Id);
        System.assertEquals(dec[0].Name, dw.decisionName, 'The name did not match gotten: '+ dw.decisionName +' expected: ' + dec[0].Name);
        System.assertEquals(dec[0].Credit_Info__c, dw.creditInfo, 'The credit info did not match gotten: '+ dw.creditInfo +' expected: ' + dec[0].Credit_Info__c);
        System.assertEquals(dec[0].Score__c, dw.candorScore, 'The Candor score did not match gotten: '+ dw.candorScore +' expected: ' + dec[0].Score__c);
        System.assertEquals(dec[0].Grade__c, dw.grade, 'The grade did not match gotten: '+ dw.grade +' expected: ' + dec[0].Grade__c);
        System.assertEquals(dec[0].Decison_Status__c, dw.decisionStatus, 'The decision status did not match gotten: '+ dw.decisionStatus +' expected: ' + dec[0].Decison_Status__c);
        System.assertEquals(dec[0].Sub_Grade__c, dw.subGrade, 'The sub_grade did not match gotten: '+ dw.subGrade +' expected: ' + dec[0].Sub_Grade__c);
        System.assertEquals(min_credit, dw.guidanceLimitMin, 'The guidance limit min did not match gotten: '+ dw.guidanceLimitMin +' expected: ' + dec[0].Guidance_Limit_Min__c);
        System.assertEquals(dec[0].Guidance_Limit_Max__c, dw.guidanceLimitMax, 'The guidance limit max not match gotten: '+ dw.guidanceLimitMax +' expected: ' + dec[0].Guidance_Limit_Max__c);
    	System.assertEquals(dec[0].Override__c, dw.Over_ride, 'The override did not match gotten: '+ dw.Over_ride +' expected: ' + dec[0].Override__c);
    	System.assertEquals(dec[0].Active__c, dw.active, 'The active did not match gotten: '+ dw.active +' expected: ' + dec[0].Active__c);
    	
    }
    @isTest
    static void getFactorCardLineItem_test(){
        Account acc = SC_UTIL_Test.createAccountInactiveCompanies();
        Factorcard__c fcDilutedTest = [SELECT ID, Name, (SELECT ID, Name, Factor__c, Grade__c, Max_Instalment__c, Max_Value__c, Min_Instalment__c, Min_Value__c, Sub_grade__c, Term__c FROM Factorcard_Line_Items__r) 
                            		   FROM Factorcard__c WHERE Type__c =:'Diluted'  ];
        Factorcard__c fcStandardTest = [SELECT ID, Name, (SELECT ID, Name, Factor__c, Grade__c, Max_Instalment__c, Max_Value__c, Min_Instalment__c, Min_Value__c, Sub_grade__c, Term__c FROM Factorcard_Line_Items__r) 
                            		    FROM Factorcard__c WHERE Type__c =:'Standard' ];
        Test.startTest();
            List<Decision__c> dec = [SELECT ID, Name, Active__c, Account__c, Score__c, Credit_Info__c, Decision_Origin__c, Decison_Status__c, Grade__c, Guidance_Limit_Line_Item__c,
                                 Guidance_Limit_Max__c, Guidance_Limit_Min__c, Guidance_Limit_Scorcard__c, Override__c, Sub_Grade__c FROM Decision__c WHERE Account__c =:acc.ID];
            if(dec == null){
                System.assert(false, 'No decision found for this account');
            }
        
        	//decisionWrapper dw = new decisionWrapper(dec[0]);
        
        	List<Factorcard_Line_Item__c> fcliStand = decisionWrapper.getFactorCardLineItem('Standard');
        	List<Factorcard_Line_Item__c> fcliDiluted = decisionWrapper.getFactorCardLineItem('Diluted');
		Test.stopTest();
        
        System.assertEquals(fcDilutedTest.Factorcard_Line_Items__r, fcliDiluted, 'Standard factor cards did not match');
        System.assertEquals(fcStandardTest.Factorcard_Line_Items__r, fcliStand, 'Diluted factor cards did not match');
    }

    @isTest
    static void getAllFactorCards_test(){
        Test.startTest();
            List<DecisionWrapper.FactorWrapper> factorWrapperList = DecisionWrapper.getAllFactorCards();
            System.assert(factorWrapperList.size()>0, 'Did not retrieve any factorcards');
        Test.stopTest();
    }

    @isTest
    static void FactorCardLineItem_test(){
        String type_standard = 'Standard';
        String type_diluted = 'Diluted';

        Test.startTest();

            List<Factorcard_Line_Item__c> factorcardLineItemList = DecisionWrapper.getFactorCardLineItem(type_standard,'A','1');
            System.assert(factorcardLineItemList.size()>0, 'Did not retrieve any Factorcard_Line_Item__c');
            System.assertEquals(factorcardLineItemList[0].Grade__c, 'A', 'Wrong factor card line item');
            System.assertEquals(factorcardLineItemList[0].Sub_Grade__c, '1', 'Wrong factor card line item');


            List<Factorcard_Line_Item__c> factorcardLineItemList_2 = DecisionWrapper.getFactorCardLineItem(type_diluted,'C','2');
            System.assert(factorcardLineItemList_2.size()>0, 'Did not retrieve any Factorcard_Line_Item__c');
            System.assertEquals(factorcardLineItemList_2[0].Grade__c, 'C', 'Wrong factor card line item');
            System.assertEquals(factorcardLineItemList_2[0].Sub_Grade__c, '2', 'Wrong factor card line item');
        
        Test.stopTest();
    }

    @isTest
    static void getConditionHistoryForAccountTest(){
        
        Account acc_1 = SC_UTIL_Test.createAccount('500697604', 'Customer - Channel', '500697604');
        Account acc_2 = SC_UTIL_Test.createAccount('502445300', 'Customer - Channel', '502445300');
        Account[] accArray = new Account[]{acc_1,acc_2};

        Date dataConstituicao = Date.newInstance(1960, 2, 17);
        ReportDB__c report_1 = new ReportDB__c(Estado__c = 'Ativa', FormaJuridica__c = 'SA', DataConstituicao__c = dataConstituicao , Vendor__c =acc_1.id, Name = acc_1.Name, n_dependents__c = 3, CAE__c = '16101'
                                            ,Estado_Civil__c = 'Outro', Sales__c = 1000000, yearincome__c = 2002, EnderecoPostal__c = 'FEBRES', Localidade__c = 'xxxxx', CodigoPostal__c = '3060-318'
                                            ,AttachB__c = true, PercentilScore__c = 70, RecordTypeId = '012240000006iFx' );
        insert report_1;

        Date dataConstituicao_2 = Date.newInstance(1994, 4, 20);
        ReportDB__c report_2= new ReportDB__c(Estado__c = 'Ativa', FormaJuridica__c = 'SA', DataConstituicao__c = dataConstituicao_2 , Vendor__c =acc_2.id, Name = acc_2.Name, n_dependents__c = 3, CAE__c = '16101'
                                            ,Estado_Civil__c = 'Outro', Sales__c = 1000000, yearincome__c = 2002, EnderecoPostal__c = 'FEBRES', Localidade__c = 'xxxxx', CodigoPostal__c = '3060-318'
                                            ,AttachB__c = true, PercentilScore__c = 70, RecordTypeId = '012240000006iFx' );
        insert report_2;

        Test.startTest();

        Map<Id, DecisionWrapper.ConditionWrapper> accDecisionMap = DecisionWrapper.getConditionHistoryForAccount(accArray);
        System.assert(accDecisionMap.get(acc_1.Id) != null , 'Did not return any decision conditions');
        System.assert(accDecisionMap.get(acc_2.Id) != null , 'Did not return any decision conditions');

        Test.stopTest();
    }

}