@isTest(SeeAllData = true)
private class INJ_CreateInjunctionSchedule_Test {
	
	
	private static String CRON_EXP = '0 0 0 15 3 ? 2022';
	private static String taxZone = 'Mainland';
	private static Integer NUMBER_INVOICES = 2;
	private static Integer nifCounter = 100000000;
	private static Date minus30Days = Date.today().addDays(-30);
	private static String typeCustomer = 'Customer - Channel';
	private static String typeVendor = 'Channel Partner / Vendor';
	private static String level1 = '1st Reminder';
	private static String level4 = '4th Reminder';
	
	private static Account testClient;
    private static Account testVendor;
    private static Application__c testApp;
    private static Collection_Case__c testCollectionCase;
    private static Billing_Contract__c testContract;
    private static Dunning_Alert__c testDunning;
    private static List<c2g__codaInvoice__c> testInvoices;
    
    //with 0 invoices
    static testMethod void shouldCreateNewDunning0Invoices() {
    	//setup
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        testDunning = ClientAppService_TestUtils.createDunningAlert(testCollectionCase, level4);
        //manually update sent date because trigger in insert sets it to today
        testDunning.Sent_Date__c = minus30Days;//this date has to be before the Nr_of_Days_to_Pay__c in dunning admin
        update testDunning;
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new INJ_CreateInjunctionSchedule());
                  
        // Verify the scheduled job has not run yet.
        List<Injunction_Procedure__c> injs = [SELECT Id
        FROM Injunction_Procedure__c
        WHERE Collection_Case__c = :testCollectionCase.id];
        System.assertEquals(0, injs.size(), 'Injunctions exist before job has run');
        
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        // Now that the scheduled job has executed,
        // check that injs werent created and dunnings were
        List<Injunction_Procedure__c> auxInj = [SELECT Id
        FROM Injunction_Procedure__c
        WHERE Collection_Case__c  = :testCollectionCase.id];
        System.assertEquals(0, auxInj.size(), 'Injunctions were created');//shouldnt happen because this CC has no invoices
        
        List<Dunning_Alert__c> auxDunn = [SELECT Id
        FROM Dunning_Alert__c
        WHERE Collection_Case__c  = :testCollectionCase.id
        AND Dunning_Level__c = :level1];
        System.assertEquals(1, auxDunn.size(), 'New Dunning wasnt created');
    }
    
    //with 2 invoices
    static testMethod void shouldCreateNewDunning1Invoice() {
    	//setup
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        testDunning = ClientAppService_TestUtils.createDunningAlert(testCollectionCase, level4);
        //manually update sent date because trigger in insert sets it to today
        testDunning.Sent_Date__c = minus30Days;//this date has to be before the Nr_of_Days_to_Pay__c in dunning admin
        update testDunning;
        
        List<Product2> InvoiceLineItems = new List<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'Aluguer Mensal Equipamento CANDOR RENTING S.A.';
        p1.ProductCode = 'PT01';
        InvoiceLineItems.add(p1);
        insert InvoiceLineItems;
        
        testInvoices = new List<c2g__codaInvoice__c>();
        testInvoices.add(ClientAppService_TestUtils.createInvoice(testApp, testClient, testCollectionCase, taxZone, InvoiceLineItems, null));
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new INJ_CreateInjunctionSchedule());
                  
        // Verify the scheduled job has not run yet.
        List<Injunction_Procedure__c> injs = [SELECT Id
        FROM Injunction_Procedure__c
        WHERE Collection_Case__c = :testCollectionCase.id];
        System.assertEquals(0, injs.size(), 'Injunctions exist before job has run');
        
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        // Now that the scheduled job has executed,
        // check that injs werent created and dunnings were
        List<Injunction_Procedure__c> auxInj = [SELECT Id
        FROM Injunction_Procedure__c
        WHERE Collection_Case__c  = :testCollectionCase.id];
        System.assertEquals(0, auxInj.size(), 'Injunctions were created');//shouldnt happen because this CC has no invoices
        
        List<Dunning_Alert__c> auxDunn = [SELECT Id
        FROM Dunning_Alert__c
        WHERE Collection_Case__c  = :testCollectionCase.id
        AND Dunning_Level__c = :level1];
        System.assertEquals(1, auxDunn.size(), 'New Dunning wasnt created');
    }
    
    //with 2 invoices
    static testMethod void shouldCreateInjunctions() {
    	//setup
    	testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        testDunning = ClientAppService_TestUtils.createDunningAlert(testCollectionCase, level4);
        //manually update sent date because trigger in insert sets it to today
        testDunning.Sent_Date__c = minus30Days;//this date has to be before the Nr_of_Days_to_Pay__c in dunning admin
        update testDunning;
        
        List<Product2> InvoiceLineItems = new List<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'Aluguer Mensal Equipamento CANDOR RENTING S.A.';
        p1.ProductCode = 'PT01';
        InvoiceLineItems.add(p1);
        insert InvoiceLineItems;
        
        testInvoices = new List<c2g__codaInvoice__c>();
        for(Integer i=0; i<NUMBER_INVOICES; i++){
            testInvoices.add(ClientAppService_TestUtils.createInvoice(testApp, testClient, testCollectionCase, taxZone, InvoiceLineItems, null));
        }
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new INJ_CreateInjunctionSchedule());
                  
        // Verify the scheduled job has not run yet.
        List<Injunction_Procedure__c> injs = [SELECT Id
        FROM Injunction_Procedure__c
        WHERE Collection_Case__c = :testCollectionCase.id];
        System.assertEquals(0, injs.size(), 'Injunctions exist before job has run');
        
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        // Now that the scheduled job has executed,
        // check that injs were created
        List<Injunction_Procedure__c> aux = [SELECT Id
        FROM Injunction_Procedure__c
        WHERE Collection_Case__c  = :testCollectionCase.id];
        System.assertEquals(1, aux.size(), 'Injunctions were not created');//only the dunn30 should have inj
    }
}