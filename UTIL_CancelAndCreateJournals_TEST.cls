//Created BY BP (28/06/17)
@isTest (SeeAllData = true)
private class UTIL_CancelAndCreateJournals_TEST {
    
    /***Testes para criação de journals per invoice comentados*****///
    
    @isTest static void createJournalsListBillingsTest(){
        
        List<Application__c> appList = new List<Application__c>([Select Id From Application__c where Status__c = 'Contract - Running' limit 2]);
        
        List<ID> appIdList = new List<ID>();
        for(Application__c app : appList){
            appIdList.add(app.id);
        }
        
        UTIL_CancelAndCreateJournals.createOldJournalsListAP(appIdList);
        
    }
    
    @isTest static void createJournalsListBillingsTest2(){
        
        List<Application__c> appList = new List<Application__c>([Select Id From Application__c where id = 'a012400001BQFjA']);
        
        List<ID> appIdList = new List<ID>();
        for(Application__c app : appList){
            appIdList.add(app.id);
        }
        
        UTIL_CancelAndCreateJournals.createOldJournalsListAP(appIdList);
        
    }
    
    @isTest static void createJournalsListBillingsTest3(){
        
        List<Application__c> appList = new List<Application__c>([Select Id From Application__c where id = 'a012400000yPEBB']);
        
        List<ID> appIdList = new List<ID>();
        for(Application__c app : appList){
            appIdList.add(app.id);
        }
        
        UTIL_CancelAndCreateJournals.createOldJournalsListAP(appIdList);
        
    }
    
    @isTest static void createJournalsListAPBatchTest(){
        Test.startTest();
        
        CreateJournalsPerInvoiceBatch batch = new CreateJournalsPerInvoiceBatch();
        Database.executeBatch(batch,10);
        
        Test.stopTest();
        
    }
    
    @isTest static void createJournalsListOneAPBatchTest(){
        Test.startTest();
        
        List<String> appNameList = new List<String>();
        appNameList.add('AP-016854');
        
        CreateJournalsPerInvoiceBatch batch = new CreateJournalsPerInvoiceBatch(appNameList);
        Database.executeBatch(batch,10);
        
        Test.stopTest();
    }
    
    @isTest static void createJournalsListOneAPBatchTest2(){
        Test.startTest();
        
        List<String> appNameList = new List<String>();
        appNameList.add('AP-016854');
        
        CreateJournalsPerInvoiceBatch batch = new CreateJournalsPerInvoiceBatch(appNameList,3);
        Database.executeBatch(batch,10);
        
        Test.stopTest();
    }
    
    @isTest static void scheduleBatchTest(){
        Test.StartTest();
        
        CreateJournalsSchedule sh1 = new CreateJournalsSchedule();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        
        Test.stopTest();
    }
    
    @isTest static void createJournalSettleContract_TEST() 
    {
        Test.startTest();
        //select id,name,status__c,Insurance_Pro_Rata__c,Payment_Freq__c,Interim_Fee_Days__c from application__c where Insurance_Pro_Rata__c!=0 AND Payment_Freq__c='Quarterly' AND Interim_Fee_Days__c>29 AND status__c='Contract - Running' order by createddate asc
        Application__c testApp = [SELECT ID,Name FROM Application__c WHERE Name='AP-000386' LIMIT 1];
        
        System.assertNotEquals(null,testApp,'[UTIL_CancelAndCreateJournals_TEST].createJournalSettleContract_TEST --> A App não foi obtida com sucesso...');
        
        UTIL_CancelAndCreateJournals.createJournalSettleContract(testApp.Name);
        Test.stopTest();    
    }//end createJournalSettleContract_TEST method
    
    @isTest static void ReverseJournalsTest(){
        
        Test.startTest();
        
        List<c2g__codaJournal__c> journalsReversed = [Select c2g__SourceJournal__r.ID
                                                      From c2g__codaJournal__c 
                                                      where  c2g__Type__c = 'Reversing Journal'];
        
        List<ID> reversedIDList = new List<ID> ();
        for(c2g__codaJournal__c journal : journalsReversed){
            reversedIDList.add(journal.c2g__SourceJournal__r.ID);
        }
        
        //select some journals
        List<c2g__codaJournal__c> journalsToReverseList = [Select Id,c2g__Reference__c,c2g__Period__c,c2g__Type__c,c2g__JournalDescription__c,c2g__JournalStatus__c,c2g__CanceledJournal__c 
                                                           From c2g__codaJournal__c 
                                                           where  c2g__JournalStatus__c = 'Complete' and c2g__Type__c = 'Manual Journal' and c2g__CanceledJournal__c = false and id NOT IN :reversedIDList
                                                           Limit 20];
        Set<ID> journalsID = new Set<ID>();
        for(c2g__codaJournal__c journal : journalsToReverseList){
            journalsID.add(journal.id);
        }
        
        UTIL_CancelAndCreateJournals.ReverseJournals(journalsID);
        Test.stopTest();        
    }
    
    @isTest static void CancelJournalsTest(){
        
        Test.startTest();
        
        //select some journals
        List<c2g__codaJournal__c> journalsToReverseList = [Select Id,c2g__Reference__c,c2g__Period__c,c2g__JournalDescription__c,c2g__JournalStatus__c,c2g__CanceledJournal__c From c2g__codaJournal__c Limit 20];
        UTIL_CancelAndCreateJournals.CancelJournals(journalsToReverseList);
        Test.stopTest();        
    }
    
    @isTest static void CancelJournalsTestAppname(){
        
        Test.startTest();
        
        //select some journals
        Application__c testApp = [SELECT ID,Name FROM Application__c WHERE Name='AP-001692' LIMIT 1];
        UTIL_CancelAndCreateJournals.CancelJournals(testApp.Name);
        Test.stopTest();        
    }
    
    @isTest static void CancelJournalsTestAppname2(){
        
        Test.startTest();
        
        //select some journals
        Application__c testApp = [SELECT ID,Name FROM Application__c WHERE Name='AP-016992' LIMIT 1];
        UTIL_CancelAndCreateJournals.CancelJournals(testApp.Name);
        Test.stopTest();        
    }
    
    @isTest static void CancelOldJournalAPListTest(){
        
        Test.startTest();
        
        //select some journals
        List<Application__c> appList = new List<Application__c>([Select Id From Application__c where Status__c = 'Contract - Running' ORDER BY Name DESC limit 2]);
        
        List<String> appIDList = new List<String>();
        for(application__c app : appList){
            appIDList.add(app.ID);
        }
        
        UTIL_CancelAndCreateJournals.CancelOldJournalAppList(appIDList);
        Test.stopTest();        
    }  
    
    @isTest static void cashMathingTest(){
        Test.startTest();
        
        List<c2g__codaJournal__c> journalsToCancel = new List<c2g__codaJournal__c>([Select ID,c2g__Period__c,c2g__JournalDescription__c,c2g__Reference__c,c2g__CanceledJournal__c,c2g__JournalStatus__c
                                                                                    FROM c2g__codaJournal__c 
                                                                                    where c2g__JournalStatus__c = 'Complete' and c2g__CanceledJournal__c = false and c2g__Reference__c like 'AP-%'
                                                                                    limit 1
                                                                                   ]);
        
        UTIL_CancelAndCreateJournals.CancelJournals(journalsToCancel);
        
        Application__c app = [Select ID
                              FROM Application__c 
                              where Name = :journalsToCancel[0].c2g__Reference__c
                              limit 1
                             ];
        
        UTIL_CancelAndCreateJournals.cashMatchingCancelJournals(app.id);
        
        Test.stopTest();
    }
    
    @isTest static void dummyTest(){
        UTIL_CancelAndCreateJournals.dummyMethod();
    }
    
    @isTest static void batchToPostDeferredTest(){
        Test.startTest();
        
        JournalDeferredPostBatch batch = new JournalDeferredPostBatch();
        Database.executeBatch(batch,10);
        
        Test.stopTest();
    }
    
    @isTest static void batchToPostDeferredForApListTest(){
        Test.startTest();
        
        List<Application__c> appList = new List<Application__c>([Select ID,Name From Application__c limit 20]);
        
        List<String> appNameList = new List<String>();
        for(Application__c app : appList){
            appNameList.add(app.Name);
        }
        
        JournalDeferredPostBatch batch = new JournalDeferredPostBatch(appNameList);
        Database.executeBatch(batch,10);
        
        Test.stopTest();
    }
    
}//end class