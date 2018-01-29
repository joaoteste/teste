@isTest(SeeAllData=true)
public class ClientTest{
    
    
    public ClientTest(){  
        Account cli1 = new Account(Name = 'cliente 1', NIF__c='501810200', Type='Customer - Channel', Personal_Guarantee__c = True, Available_Credit_Line__c = 5000);
        insert cli1;
        ReportDB__C report1 = new ReportDB__C(Vendor__c = cli1.id, Name = '500659931', n_dependents__c = 3, CAE__c = '16101'
                                            ,Estado_Civil__c = 'Outro', yearincome__c = 2002, EnderecoPostal__c = 'FEBRES', Localidade__c = 'xxxxx', CodigoPostal__c = '3060-318'
                                            ,AttachB__c = true, RecordTypeId = '012240000006iFx');
        insert report1;
    }
    
 
   @isTest
    public static void ClientConstructorTester(){
        ClientTest addDados = new ClientTest();       //add testing data
        
        Client clitest = new Client('501810200');    //Constructor Testing
        
    Boolean randomtestexist = clitest.exist();    
        Account newacc = clitest.getAccount();         //testing methods by forcing the values
        ID testgetID = clitest.getId();
        
        
        System.assert(newacc != null,'getAccount() failed, not worked as expected!');
        System.assert(testgetID != null,'getID() failed, not worked as expected!');

            Client clitest2 = new Client('501810286');
            Boolean randomtestDontexist = clitest2.exist();
            Account newacc3 = null;
            System.assert(newacc3 == null,'createAccount() failed, not worked as expected!   '+newacc);
            newacc3 = clitest2.createAccount();
            System.assert(newacc3 != null,'createAccount() failed, not worked as expected!   '+newacc);
            newacc3 = clitest2.createAccount();
            System.assert(newacc3 == null,'createAccount() failed, not worked as expected!   '+newacc);
        //}

        Account newacc2 = Client.getAccountFromID(testgetID);
        System.assert(newacc2 != null,'createAccount() failed, not worked as expected!');
        
         Map<Id,Integer> mappie = clitest.numberOfOpenAppsByVendor();
         System.assert(mappie != null,'numberOfOpenAppsByVendor() failed, not worked as expected!');

    }
        
      @isTest(SeeAllData=true)
      public static void getReportTester(){
           ClientTest addDados = new ClientTest();       //add testing data

            
           Client clitest = new Client('501810200');
           clitest.exist();
           System.assert(clitest != null,'new clitest failed, not worked as expected!   '+clitest);
           ReportDB__c reportest = clitest.getReport();
           System.assert(reportest != null,'getReport() failed, not worked as expected!   '+reportest);
           Boolean isItValid = Client.reportIsValid(reportest);     
          //System.assert(isItValid == true,'reportIsValid failed, not worked as expected!   ');
            
    }
    
      @isTest
      public static void getCreditLineStatusTester(){
            ClientTest addDados = new ClientTest();       //add testing data      
            
            Client clitest = new Client('501810200'); 
      String Stest = clitest.getCreditLineStatus();
            System.assert(Stest != null,'getCreditLineStatus() failed, not worked as expected!   ');            
            
          Address newadd = new Address();
            //clitest.setClientAddress(newadd);
        }  

    @isTest
    public static void setClientAdressTest(){

       Account client = new Account(Name = 'cliente 1', NIF__c='501810285', Type='Customer - Channel', 
                                  Personal_Guarantee__c = True, Available_Credit_Line__c = 5000,
                                  BillingCity='NeverLand',BillingStreet='Crocodile Creek', BillingPostalCode='1234-123');
      insert client;
      
      Client.Address c_address = new Client.Address();
      c_address.BillingCity = 'Wonderland';
      c_address.BillingStreet = 'The Queen of Hearts Castle';
      c_address.BillingPostalCode ='1234-123';
      c_address.PostalCodeFirst = '3214';
      c_address.PostalCodeSecond = '123';
      c_address.accountId = client.Id;

      Client c = new Client(client.id);
      c.setClientAddress(c_address);
      System.assertEquals([SELECT BillingCity FROM Account WHERE ID=:client.Id].BillingCity,'Wonderland','Address was not changed');
    }  

    @isTest(SeeAllData=true)
    public static void setClientIbanTest(){

     Account cl = new Account(Name = 'cliente 1', NIF__c='501810123', Type='Customer - Channel', 
                                  Personal_Guarantee__c = True, Available_Credit_Line__c = 5000,
                                  BillingCity='SomePlaceSomewhere',BillingStreet='SouthBay', BillingPostalCode='1234-123', Country_Code__c = 'PT50');
      insert cl;
      System.debug('[ClientTest - setClientIbanTest() client account ID] -> '+ cl);

      Client c = new Client(cl.Id);
      c.setClientIban('PT50003600409911001102673');
     
      System.debug('[ClientTest - setClientIbanTest() client account BBAN__C] -> '+ [SELECT BBAN__c FROM Account WHERE ID=:cl.Id].BBAN__c);
      System.assertEquals([SELECT BBAN__c FROM Account WHERE ID=:cl.Id].BBAN__c,'003600409911001102673','Client Iban not set');
      
    }

    @isTest 
    public static void getCreditLimitsTest(){
      
      Decimal total = 56000;
      ScoreCard_Config__c scMax = new ScoreCard_Config__c(fieldname__c = 'Maximum Credit Allowed', Matching_Value__c = '50000');
      ScoreCard_Config__c scMin = new ScoreCard_Config__c(fieldname__c = 'Minimum Credit Allowed', Matching_Value__c = '500');
      insert scMax;
      insert scMin;

      Map<String, String> mapLimits = client.getCreditLimits(total);
      System.assertEquals(mapLimits.get('Maximum'), String.valueOf(total));
      System.assertEquals(mapLimits.get('Minimum'), scMin.Matching_Value__c);

      total = 4000;
      mapLimits = client.getCreditLimits(total);
      System.assertEquals(mapLimits.get('Maximum'),scMax.Matching_Value__c);
      System.assertEquals(mapLimits.get('Available'), String.valueOf(total));
    }

    @isTest
    public static void getContractsTest(){

        Test.startTest();

        Client c = new Client('503476072');
        c.createAccount();
        List<Application__c> contractList = c.getContracts();
        System.assertEquals(contractList.size(), 0, 'Client has more than 0 contracts');

        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630311';
        insert vendor;

        Application__c app = new Application__c();
        app.AccClient__c = c.getId();
        app.Vendor__c = vendor.ID;
        app.Status__c = 'Application - Approved';
        insert app;

        contractList = c.getContracts();
        System.assertEquals(contractList.size(), 0, 'Client has more than 0 contracts');

        Application__c contract = new Application__c();
        contract.AccClient__c = c.getId();
        contract.Vendor__c = vendor.ID;
        contract.Status__c = 'Contract - Running';
        insert contract;

         contractList = c.getContracts();
        System.assertEquals(contractList.size(), 1, 'Client has retruned ' + contractList.size() + ' contracts and should have returned 1');

        Application__c contractArreas = new Application__c();
        contractArreas.AccClient__c = c.getId();
        contractArreas.Vendor__c = vendor.ID;
        contractArreas.Status__c = 'Contract - Arreas';
        insert contractArreas;

        contractList = c.getContracts();
        System.assertEquals(contractList.size(), 2, 'Client has retruned ' + contractList.size() + ' contracts and should have returned 2');

        Test.stopTest();
    }


        
    @isTest (SeeAllData=true)//(BP)
    public static void analyseClientTest()
    {
     MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
     mock.setStaticResource('http://api.salesforce.com/foo/bar','testreportPdf');
     mock.setStaticResource('https://api.moloni.com/sandbox/grant/?grant_type=password&client_id=candorrentingdeequipamentossa&client_secret=bc2a5b885fd84faa05b40167c2420bf3a24cebd4&username=asantos@candor.pt&password=37BF8003','test234');

     mock.setStatusCode(200);
     mock.setHeader('Content-Type', 'application/pdf');
     Test.setMock(HttpCalloutMock.class, mock);
                

      Account client = SC_UTIL_Test.createAccountWithCreditReport('500697604', 'Customer - Channel', '500697604');
      Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '507688333');
      Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());
      app.Status__c  = null;
      update app;
      //ClientTest addDados     = new ClientTest();       //add testing data
       
      Client  clientTest      = new Client('500697604');   //Constructor Testing
      Account clientTest0     = clientTest.getAccount();
      clientTest0.Credit_Line_Status__c='Credit Line - Approved';
      update clientTest0;

      
      //vendor.requestApplication('501810200');
      Test.startTest(); 
      clientTest.analyseClient_v2(app.id);
      Test.stopTest();
    } 

    @isTest static void analyseClientTest2(){
      Account client = SC_UTIL_Test.createAccountWithCreditReport('500697604', 'Customer - Channel', '500697604');
      Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '507688333');
      Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());
      app.Status__c  = null;
      Test.startTest(); 
      Client  clientTest      = new Client('500697604');   //Constructor Testing
      clientTest.analyseClient_v2(app.id);
      Test.stopTest();
    }

    //22/06/17 -(BP)
    @isTest static void setInvoiceEmailTest()
    {

      Client clientTest = new Client('000000007');
      clientTest.createAccount();

      boolean result = clientTest.setInvoiceEmail('testEmail@example.com',false);
      System.assertEquals(true,result,'[ClientTest].setTest --> Não é o resultado esperado...');
    }

    @isTest static void numberOfOpenAppsByVendorTest(){
      Account client = SC_UTIL_Test.createAccountWithCreditReport('500697604', 'Customer - Channel', '500697604');
      Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '507688333');
      Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());
      app.Status__c  = 'Application - Approved';
      update app;

      Test.startTest();
      Client c = new Client('500697604');
      c.numberOfOpenAppsByVendor();

      app.Status__c  = null;
      update app;
      client.Credit_Line_Status__c = 'Credit Line - Approved';
      update client;

      Contact vendorContact=new contact();
      vendorContact.FirstName = 'José';
      vendorContact.LastName = 'Mourinho';
      vendorContact.Email = 'vendor@email.pt';
      vendorContact.Role__c='Master';
      vendorContact.AccountId = vendor.Id;
      insert vendorContact;

      Login__c login = new Login__c();
      login.IdVendor__c = vendor.Id;
      login.Username__c = 'vendor@email.pt';
      login.vendor_vendor__c = vendorContact.id;
      app.IdLoginCreate__c = login.Id;
      update app;
      insert Login;

      c.numberOfOpenAppsByVendor(Login.id);
      c.getInvoiceEmail();
      Test.stopTest();
      
    }

    @isTest
    static void analyseClientTeste3(){
      Account client = SC_UTIL_Test.createAccountWithCreditReport('500697604', 'Customer - Channel', '500697604');
      Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '507688333');
      Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());
      app.Status__c  = null;
      update app;
      client.Credit_Line_status__c = 'Credit Line - Approved';
      update client;
      Test.startTest(); 
      Client  clientTest      = new Client('500697604');   //Constructor Testing
      clientTest.analyseClient_v2(app.id);
      Test.stopTest();

    }

}