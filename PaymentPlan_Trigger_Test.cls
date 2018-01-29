@isTest(SeeAllData = true)
private class PaymentPlan_Trigger_Test {
    
    private static Integer nifCounter = 100000000;
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    private static String recordTypeName = 'Injunction With Payment Plan';
    
    private static Account testClient;
    private static Account testVendor;
    private static Contact testContact;
    private static Application__c testApp;
    private static Collection_Case__c testCollectionCase;
    private static Injunction_Procedure__c testInj;
    private static Payment_Plan__c testPP;
    
    
	private static testMethod void shouldUpdateInjunctionData() {
	    //setup
	    testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testContact = ClientAppService_TestUtils.createContact(testClient, null);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
	    testInj = ClientAppService_TestUtils.createInjunction(testCollectionCase);
	    
	    
	    //test
	    Test.startTest();
	    testPP = ClientAppService_TestUtils.createPaymentPlan(testClient, testContact, testCollectionCase);
	    Test.stopTest();
	    
	    //assert
	    Injunction_Procedure__c aux = [SELECT RecordType.Name, Payment_Plan__c FROM Injunction_Procedure__c WHERE Id = :testInj.ID];
	    system.assertEquals(testPP.Id, aux.Payment_Plan__c, 'Didnt set the correct Payment Plan on Injunction');
	    system.assertEquals(recordTypeName, aux.RecordType.Name,'Didnt set the correct record type');
	}
    
    @isTest
    public static void increaseSinglePayment(){
        Map<String, String> dataMap = setData();
        
        Test.startTest();
        	Payment_Plan__c pp = new Payment_Plan__c(ID = dataMap.get('ppID'));
        	pp.Status__c = 'Closed';
        	update pp;
        Test.stopTest();
        
        Collection_Case__c cc = [select id, Nr_of_Single_Payments__c, Last_Payment_Date__c FROM Collection_Case__c WHERE ID = :dataMap.get('ccID')];
        System.assert(cc.Last_Payment_Date__c == system.today());
        System.assert(cc.Nr_of_Single_Payments__c == 1);
        
        
    }
    
    private static Map<String, String> setData(){
        
        RentingApplication_Util_Test rentUtils = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rentUtils.environment1();
        Contact cont = new Contact();
        cont.AccountId = infoMap.get('client');
        cont.Email = 'test@test.pt';
        cont.LastName = 'Test';
        cont.Phone = '915229100';
        insert cont;       
        infoMap.put('Contact', cont.id);
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Type__c = 'Partial';
        pp.Account__c = infoMap.get('client');
        pp.Contact__c = cont.ID;
        pp.Frequency__c = 'Every 15 Days';
        pp.Status__c = 'Open';
        pp.Number_of_Payments__c = '1';
        pp.Collection_Case__c = infoMap.get('ccID');
        insert pp;
        infoMap.put('ppID', pp.id);
        
        Payment_Collection__c pc = new Payment_Collection__c(Status__c = 'Paid');
        insert pc;
        
        infoMap.put('pcPS', pc.ID);
        
		Payment_Schedule__c ps = new Payment_Schedule__c();
        ps.Payment_Plan__c = pp.ID;
        ps.Amount__c = 100;
        ps.Fees_Amount__c = 20;
        ps.Amount_W_O_Tax__c = 100;
        ps.Payment_Collection__c = pc.ID;
        ps.Due_Date__c = system.today().addDays(3);
        ps.Schedule_Number__c = '1';
        ps.isLast__c = true;
        insert ps;
        
        infoMap.put('psID', ps.id);        
        
        return infoMap;
    }

}