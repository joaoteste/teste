@isTest
private class CreditInfoProviderRequestTest {
    
    @isTest 
    static void queueableTestFromExistentAccount() {

        Account client = SC_UTIL_Test.createAccountWithCreditReport('500697604', 'Customer - Channel', '500697604');
        Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '507688333');
        Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());
        app.Status__c  = null;

        Test.startTest();
        CreditInfoContext  ctx = new CreditInfoContext(client.Nif__c, 'PT', client.Id, app.Id);
        CreditInfoProviderRequest creditInfoProviderReq = new CreditInfoProviderRequest(ctx);
        System.enqueueJob(creditInfoProviderReq);
        Test.stopTest();

        ReportDB__C report = [SELECT Last_Request__c FROM ReportDB__C WHERE Vendor__c =:client.Id ORDER BY Createddate DESC LIMIT 1];
        Datetime reqDate = report.Last_Request__c;
        System.assertEquals(Date.newinstance(reqDate.year(), reqDate.month(), reqDate.day()), Date.today(), 'Last request date from report should be: ' + Date.Today());
    }


    
    @isTest 
    static void queueableTestOnlyClient() {

        Account client = SC_UTIL_Test.createAccountWithCreditReport('505521296', 'Customer - Channel', '505521296');
        Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '511089880');

        Test.startTest();
        CreditInfoContext  ctx = new CreditInfoContext(client.Nif__c, 'PT', client.Id);
        CreditInfoProviderRequest creditInfoProviderReq = new CreditInfoProviderRequest(ctx);
        System.enqueueJob(creditInfoProviderReq);
        Test.stopTest();

        ReportDB__C report = [SELECT Last_Request__c FROM ReportDB__C WHERE Vendor__c =:client.Id ORDER BY Createddate DESC LIMIT 1];
        Datetime reqDate = report.Last_Request__c;
        System.assertEquals(Date.newinstance(reqDate.year(), reqDate.month(), reqDate.day()), Date.today(), 'Last request date from report should be: ' + Date.Today());

    }



    @isTest 
    static void queueableTestCreateApplication() {

        Account client = SC_UTIL_Test.createAccountWithCreditReport('508259096', 'Customer - Channel', '508259096');
        Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '507362187');
        
        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendor.Id;
        insert vendorContact;
        
        //New Login
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Username__c = 'vendor@email.pt';
        login.Vendor_Vendor__c = vendorContact.Id;
        insert login;

        Test.startTest();
        CreditInfoContext  ctx = new CreditInfoContext(client.Nif__c, 'PT', client.Id,vendor.Id, login.Id);
        CreditInfoProviderRequest creditInfoProviderReq = new CreditInfoProviderRequest(ctx);
        System.enqueueJob(creditInfoProviderReq);
        Test.stopTest();

        ReportDB__C report = [SELECT Last_Request__c FROM ReportDB__C WHERE Vendor__c =:client.Id ORDER BY Createddate DESC LIMIT 1];
        Datetime reqDate = report.Last_Request__c;
        System.assertEquals(Date.newinstance(reqDate.year(), reqDate.month(), reqDate.day()), Date.today(), 'Last request date from report should be: ' + Date.Today());

        Application__c app = [SELECT ID, Createddate FROM Application__c ORDER BY Createddate DESC LIMIT 1];
        Datetime createdate = app.Createddate;
        System.assertEquals(Date.newinstance(createdate.year(), createdate.month(), createdate.day()), Date.today(), 'Created date from Application__c should be: ' + Date.Today());

    }   



    @isTest 
    static void getCreditInfoTest() {
        Account client = SC_UTIL_Test.createAccountWithCreditReport('507645855', 'Customer - Channel', '507645855');
        Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '506038939');
        Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());

        Test.startTest();
        CreditInfoContext  ctx = new CreditInfoContext(client.Nif__c, 'PT', client.Id, app.Id);
        CreditInfoProviderRequest creditInfoProviderReq = new CreditInfoProviderRequest(ctx);
        CreditInfoProviderResponse resp = creditInfoProviderReq.getCreditInfo();
        Test.stopTest();

        System.Assert(resp!=null, 'did not return any response');

        ReportDB__C report = [SELECT Last_Request__c FROM ReportDB__C WHERE Vendor__c =:client.Id  ORDER BY Createddate DESC LIMIT 1];
        Datetime reqDate = report.Last_Request__c;
        System.AssertEquals(Date.newinstance(reqDate.year(), reqDate.month(), reqDate.day()), Date.today(), 'Last request date from report should be: ' + Date.Today());
    }


/*
    @isTest
    static void fillSObjectsFieldsfromDecisionTest() {

        Account client = SC_UTIL_Test.createAccountWithCreditReport('508871778', 'Customer - Channel', '508871778');
        Account client_withoutReport = SC_UTIL_Test.createAccountWithCreditReport('508176174', 'Customer - Channel', '508176174');
        Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '510524788');
        Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());
        Datetime lastModifiedDate = app.lastModifiedDate;
        
        Test.startTest();

        CreditInfoContext  ctx = new CreditInfoContext(client.Nif__c, 'PT', client.Id, app.Id);
        CreditInfoProviderRequest creditInfoProviderReq = new CreditInfoProviderRequest(ctx);
        Map<String, sObject> mapSObjects = creditInfoProviderReq.fillSObjectsFieldsfromDecision(true);
        
        Test.stopTest();

        Application__c appReturned = (Application__c) mapSObjects.get('Application__c');
        Account accReturned = (Account) mapSObjects.get('Account');
        System.Assert(accReturned != null, 'Account was not updated');
        System.Assert(appReturned != null, 'Application was not updated');

    }
*/
    @isTest
    static void fillSObjectsFieldsfromDecisionWithNoDecisionTest() {

        Account client = SC_UTIL_Test.createAccountWithCreditReport('508871778', 'Customer - Channel', '508871778');
        Account client_withoutReport = SC_UTIL_Test.createAccount('508176174', 'Customer - Channel', '508176174');
        Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '510524788');
        Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());
        Datetime lastModifiedDate = app.lastModifiedDate;
        
        Test.startTest();

        //test account with no decision
        CreditInfoContext  ctx = new CreditInfoContext(client.Nif__c, 'PT', client_withoutReport.Id, app.Id);
        CreditInfoProviderRequest creditInfoProviderReq = new CreditInfoProviderRequest(ctx);
        Map<String, sObject> mapSObjects = creditInfoProviderReq.fillSObjectsFieldsfromDecision(true);
        
        Test.stopTest();

        Outbound_Integration_Log__c log = [SELECT Id, Code__c FROM Outbound_Integration_Log__c WHERE ApplicationID__c =: client_withoutReport.Id ORDER BY CREATEDDATE DESC LIMIT 1];
        System.AssertEquals(log.Code__c, 'DECISION_NOT_FOUND');
        
    }    

    @isTest 
    static void getSObjectReportDBFromParsedObjectTest(){
        
        Blob pdfBlob = Blob.ValueOf('pdf blob test');
        DBProp dbprop = new DBProp();
        dbprop.IndRisco = 74;
        dbprop.CapcFin = '10';
        dbprop.OpCred = 'OpCred'; 
        dbprop.RiscoInforma = 67;

        String xml = '<xml></xml>';
        Boolean resp_status = true;
        CreditInfoProviderResponse response = new CreditInfoProviderResponse(xml, resp_status);

        Account client = SC_UTIL_Test.createAccountWithCreditReport('508871778', 'Customer - Channel', '508871778');
        Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '510524788');
        Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());

        Test.startTest();

        CreditInfoContext  ctx = new CreditInfoContext(client.Nif__c, 'PT', client.Id, app.Id);
        CreditInfoProviderRequest creditInfoProviderReq = new CreditInfoProviderRequest(ctx);
        ReportDB__c report = creditInfoProviderReq.getSObjectReportDBFromParsedObject(dbprop, pdfBlob, response);

        Test.stopTest();

    }
}