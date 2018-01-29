@isTest(SeeAllData=true)
public class RentingApplicationTest {
    Application__c app;
    Application__c app2;
    Contact contact3;
    private static Map<String,String >data = getTestData();
    
    @isTest
    public static void getInfoTester(){

        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        rentapp.getInfo(); 
    }

    @isTest(SeeAllData=true)
    public static void setSignatureAmountTest(){
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Application__c app = rentapp.getInfo();
        ReportDB__c report = [SELECT ID, FormaObrigarToNr__c, Vendor__c FROM ReportDB__c WHERE Vendor__c =: app.AccClient__c];
        rentApp.setSignatureAmount(4);
    } 

    @isTest
    public static void RentingApplicationsPaymentValuesTest(){
        Test.startTest();
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Map<string, object> rents = new Map<string, object>();
        rents = rentapp.CalcPayments(500000);
        rentApp.setPaymentMethod('Debit Direct');

        RentingApplication ra = new RentingApplication(data.get('appID'));
        Rents.Selected selected = new Rents.Selected();
        Rents rentsObj = new Rents('E','1','Standard','PT');
        Integer[] termOptions = new Integer[]{12,36,48};
        Map<Integer, Decimal> optionsMap = rentsObj.getOptions(24000, termOptions);
        selected.term = 60;
        selected.rent = optionsMap.get(60);
        selected.freq = 'Quarterly';
        selected.admin_costs = 100;
        selected.doc_fee = false;
        Application__c app  = ra.CalcPayments(selected, 'freq',false);

        Test.stopTest();
    }

    @isTest
    public static void setPaymentstest(){
        Test.startTest();
        RentingApplication ra = new RentingApplication(data.get('appID'));
        Rents rents = new Rents('E','1','Standard','PT');
        Integer[] termOptions = new Integer[]{12,36,48};
        Map<Integer, Decimal> optionsMap = rents.getOptions(24000, termOptions);
        Rents.Selected selected = new Rents.Selected();
        selected.term = 60;
        selected.rent = optionsMap.get(60);
        selected.freq = 'Quarterly';
        selected.admin_costs = 100;
        selected.doc_fee = false;

        Boolean  res = ra.setPayments(selected);
        Test.stopTest();
    }

    @isTest
    public static void getRentsTest(){
        Test.startTest();
        RentingApplication ra = new RentingApplication(data.get('appID'));
        Rents.Selected rents = ra.getRents();
        Test.stopTest();
    }
    
    @isTest
    public static void RentingApplicationsPaymentValuesTest2(){
        Test.startTest();
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        map<string, object> mapgetrents = rentapp.getRents_deprecated();
        rentapp.setPaymentFreq('Monthly',false);
        rentapp.setPaymentFreq('Monthly',true);
        Test.stopTest();
    }
    
    @isTest
    public static void RentingApplicationsPaymentValuesTest3(){
        Test.startTest();
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        map<string, object> mapgetrents = rentapp.getRents_deprecated();
        rentapp.setTerm('36',100);  
        Test.stopTest();
    }

    @isTest
    public static void RentingApplicationsPaymentValuesTest4(){
        Test.startTest();
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        rentapp.setPaymentFreq('Quarterly',false);
        rentapp.setPaymentFreq('Quarterly',true);
        Test.stopTest();
    }

    @isTest
    public static void validateVendorClientIbanTest(){
    Test.startTest();
    String sappid= data.get('appID');

    rentingApplication.validateVendorClientIban(sappid,'PT50000201231234567890154');   
    Test.stopTest();
    }

    @isTest
    public static void set5AppClientSignersTest(){
        
        Test.startTest();

        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Application__c app = rentapp.getInfo();

        Id accountID = app.AccClient__c;
        Contact[] contactList = new List<Contact>();
        Contact con2 = new Contact(FirstName = 'Miles', LastName='Davis', Email='Miles@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con2);
        Contact con3 = new Contact(FirstName='Jhon', LastName='Coltrane', Email='Coltrane@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con3);
        Contact con6 = new Contact(FirstName='Chet', LastName='Baker', Email='baker@email.pt', AccountId=accountID, Role__c='Binding Power');        
        contactList.add(con6);
        Contact con4 = new Contact(FirstName='Freddie', LastName='Hubbard',Email='Hubbard@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con4);
        Contact con5 = new Contact(FirstName='Charles', LastName='Mingus',Email='Mingus@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con5);
        
        insert contactList;
        list<Id> listId = new List<Id>();
        for(contact c : contactList){
            listId.add(c.Id);
        }
        
        rentapp.setAppClientSigners(listId);
        Application__c appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__c , contactList[0].id);
        System.assertEquals(appUpdated.Client_Signer_2__c , contactList[1].id);
        System.assertEquals(appUpdated.Client_Signer_3__c , contactList[2].id);
        System.assertEquals(appUpdated.Client_Signer_4__c , contactList[3].id);
        System.assertEquals(appUpdated.Client_Signer_5__c , contactList[4].id);

        //change email signer 1 to check if updates  invoice email in client
        contactList[0].email ='davis@email.pt';
        update contactList[0];

        /*String resultFail = rentapp.setAppClientSigners(listId);
        System.debug(resultFail);
        System.assert(resultFail.contains('CONTRACT_ALREADY_SENT:'));*/

        app.Contract_sent__c = null;
        update app;    

        rentapp.setAppClientSigners(listId);
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email changed
        Account accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        //change app status to Contract Running and change signer 1
        Application__c newAppStatus = new Application__c(Id = app.Id , Status__c = 'Contract - Running');
        update newAppStatus;

        //change email signer 1 to check that dont updates invoice email beacuse client has one app in Contract - Running
        contactList[0].email ='milesdavis@email.pt';
        update contactList[0];
        rentapp.setAppClientSigners(listId);
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email has not changed
        accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertNotEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        Test.stopTest();
    }    

     @isTest
     public static void set4AppClientSignersTest(){
                Test.startTest();

        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Application__c app = rentapp.getInfo();
        Id accountID = app.AccClient__c;
        Contact[] contactList = new List<Contact>();
        Contact con2 = new Contact(FirstName = 'Miles', LastName='Davis', Email='Miles@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con2);
        Contact con3 = new Contact(FirstName='Jhon', LastName='Coltrane', Email='Coltrane@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con3);
        Contact con6 = new Contact(FirstName='Chet', LastName='Baker', Email='baker@email.pt', AccountId=accountID, Role__c='Binding Power');        
        contactList.add(con6);
        Contact con4 = new Contact(FirstName='Freddie', LastName='Hubbard',Email='Hubbard@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con4);
        
        insert contactList;
        list<Id> listId = new List<Id>();
        for(contact c : contactList){
            listId.add(c.Id);
        }
        
        rentapp.setAppClientSigners(listId);
        Application__c appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__c , contactList[0].id);
        System.assertEquals(appUpdated.Client_Signer_2__c , contactList[1].id);
        System.assertEquals(appUpdated.Client_Signer_3__c , contactList[2].id);
        System.assertEquals(appUpdated.Client_Signer_4__c , contactList[3].id);

        //change email signer 1 to check if updates  invoice email in client
        contactList[0].email ='davis@email.pt';
        update contactList[0];
        rentapp.setAppClientSigners(listId);
        
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email changed
        Account accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        //change app status to Contract Running and change signer 1
        Application__c newAppStatus = new Application__c(Id = app.Id , Status__c = 'Contract - Running');
        update newAppStatus;

        //change email signer 1 to check that dont updates invoice email beacuse client has one app in Contract - Running
        contactList[0].email ='milesdavis@email.pt';
        update contactList[0];
        rentapp.setAppClientSigners(listId);
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email has not changed
        accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertNotEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        Test.stopTest();
     }

     @isTest
     public static void set3AppClientSignersTest(){
        Test.startTest();

        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Application__c app = rentapp.getInfo();
        Id accountID = app.AccClient__c;
        Contact[] contactList = new List<Contact>();
        Contact con2 = new Contact(FirstName = 'Miles', LastName='Davis', Email='Miles@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con2);
        Contact con3 = new Contact(FirstName='Jhon', LastName='Coltrane', Email='Coltrane@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con3);
        Contact con6 = new Contact(FirstName='Chet', LastName='Baker', Email='baker@email.pt', AccountId=accountID, Role__c='Binding Power');        
        contactList.add(con6);
        
        insert contactList;
        list<Id> listId = new List<Id>();
        for(contact c : contactList){
            listId.add(c.Id);
        }
        
        rentapp.setAppClientSigners(listId);
        Application__c appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__c , contactList[0].id);
        System.assertEquals(appUpdated.Client_Signer_2__c , contactList[1].id);
        System.assertEquals(appUpdated.Client_Signer_3__c , contactList[2].id);

        //change email signer 1 to check if updates  invoice email in client
        contactList[0].email ='davis@email.pt';
        update contactList[0];
        rentapp.setAppClientSigners(listId);
        
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email changed
        Account accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        //change app status to Contract Running and change signer 1
        Application__c newAppStatus = new Application__c(Id = app.Id , Status__c = 'Contract - Running');
        update newAppStatus;

        //change email signer 1 to check that dont updates invoice email beacuse client has one app in Contract - Running
        contactList[0].email ='milesdavis@email.pt';
        update contactList[0];
        rentapp.setAppClientSigners(listId);
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email has not changed
        accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertNotEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        Test.stopTest();
     }     

     @isTest
     public static void set2AppClientSignersTest(){
        Test.startTest();

        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Application__c app = rentapp.getInfo();
        Id accountID = app.AccClient__c;
        Contact[] contactList = new List<Contact>();
        Contact con2 = new Contact(FirstName = 'Miles', LastName='Davis', Email='Miles@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con2);
        Contact con3 = new Contact(FirstName='Jhon', LastName='Coltrane', Email='Coltrane@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con3);
        
        insert contactList;
        list<Id> listId = new List<Id>();
        for(contact c : contactList){
            listId.add(c.Id);
        }
        
        rentapp.setAppClientSigners(listId);
        Application__c appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__c , contactList[0].id);
        System.assertEquals(appUpdated.Client_Signer_2__c , contactList[1].id);

        //change email signer 1 to check if updates  invoice email in client
        contactList[0].email ='davis@email.pt';
        update contactList[0];
        rentapp.setAppClientSigners(listId);
        
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email changed
        Account accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        //change app status to Contract Running and change signer 1
        Application__c newAppStatus = new Application__c(Id = app.Id , Status__c = 'Contract - Running');
        update newAppStatus;

        //change email signer 1 to check that dont updates invoice email beacuse client has one app in Contract - Running
        contactList[0].email ='milesdavis@email.pt';
        update contactList[0];
        rentapp.setAppClientSigners(listId);
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email has not changed
        accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertNotEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        Test.stopTest();
     }       

     @isTest
     public static void set1AppClientSignersTest(){
        Test.startTest();

        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Application__c app = rentapp.getInfo();
        Id accountID = app.AccClient__c;
        Contact[] contactList = new List<Contact>();
        Contact con2 = new Contact(FirstName = 'Miles', LastName='Davis', Email='Miles@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con2);
        
        insert contactList;
        list<Id> listId = new List<Id>();
        for(contact c : contactList){
            listId.add(c.Id);
        }
        
        rentapp.setAppClientSigners(listId);
        Application__c appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__c , contactList[0].id);

        //change email signer 1 to check if updates  invoice email in client
        contactList[0].email ='davis@email.pt';
        update contactList[0];
        rentapp.setAppClientSigners(listId);
        
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email changed
        Account accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        //change app status to Contract Running and change signer 1
        Application__c newAppStatus = new Application__c(Id = app.Id , Status__c = 'Contract - Running');
        update newAppStatus;

        //change email signer 1 to check that dont updates invoice email beacuse client has one app in Contract - Running
        contactList[0].email ='milesdavis@email.pt';
        update contactList[0];
        rentapp.setAppClientSigners(listId);
        //Check if Signer 1 changed
        appUpdated = rentapp.getInfo();
        System.assertEquals(appUpdated.Client_Signer_1__r.email , contactList[0].email);

        //Check if Invoice Email has not changed
        accClient = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id=:accountID];
        System.assertNotEquals(accClient.c2g__CODAInvoiceEmail__c, contactList[0].email);

        Test.stopTest();
     }   


    
     @isTest(SeeAllData=true)
     public static void RentingApplicationsContactAndContractTest(){
        Test.startTest();

        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Application__c app = rentapp.getInfo();
        Id accountID = app.AccClient__c;
        Contact[] contactList = new List<Contact>();
        Contact con2 = new Contact(FirstName = 'Miles', LastName='Davis', Email='Miles@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con2);
        Contact con3 = new Contact(FirstName='Jhon', LastName='Coltrane', Email='Coltrane@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con3);
        Contact con6 = new Contact(FirstName='Chet', LastName='Baker', Email='baker@email.pt', AccountId=accountID, Role__c='Binding Power');        
        contactList.add(con6);
        Contact con4 = new Contact(FirstName='Freddie', LastName='Hubbard',Email='Hubbard@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con4);
        Contact con5 = new Contact(FirstName='Charles', LastName='Mingus',Email='Mingus@email.pt', AccountId=accountID, Role__c='Binding Power');
        contactList.add(con5);
        
        insert contactList;
        list<Id> listId = new List<Id>();
        for(contact c : contactList){
            listId.add(c.Id);
        }
        
        rentapp.setAppClientSigners(listId);
        
        Message__c subjectVendor = new Message__c(Message_text__c='Be happy',Message_code__c='EMAIL_VENDOR_SUBJECT', Country_code__c ='PT50');
        insert subjectVendor;

        String contractidtypeA = rentapp.buildContract('RENTING');
        rentapp.SendRentingContract(contractidtypeA);

        String idtypeB = rentapp.buildContract('AUTO'); 
        rentApp.sendAutoContract(idtypeB);

        rentApp.getDocuSignInfo();
        rentApp.getAttachments();

        RentingApplication.getVendorInvoice(data.get('appID'));
        RentingApplication.resendContractDocuSign(data.get('docuSignStatusID'));

        RentingApplication.setCorrectedEmailDocusign(data.get('docuSignStatusID'),data.get('contactID'),'newEmail@fuu.pt' );
        RentingApplication.getDocusignCorrectedEmails(data.get('docuSignStatusID'));
        Test.stopTest();
 
     }
    
    @isTest(SeeAllData=true)
    public static void changeAppStateTest1(){
        Test.startTest();
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Application__c app = rentapp.getInfo();
        app.Invoice_Payment_Date__c=null;
        update app;
        String[] contractTypeTest  = new String[] {'auto','renting','delete'}; 
        rentApp.EditContract( contractTypeTest );
        rentApp.cancelApplication();
        Test.stopTest();
    } 

    @isTest
    public static void getAppAttachmentsTest(){
        
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        rentapp.getAppAttachments(); 
    }

    @isTest(SeeAllData=true)
    public static void changeAppStateTest2(){
        Test.startTest();
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Application__c app = rentapp.getInfo();
        app.Invoice_Payment_Date__c=null;
        update app;
        String[] contractTypeTest  = new String[] {'auto','renting','delete'}; 
        Set<String> contractTypeSet = new Set<String>();
        contractTypeSet.addAll(contractTypeTest);
        rentApp.voidDocusign(contractTypeSet,'test');
        rentApp.deleteAndVoidDocusign('test');
        Test.stopTest();
    }    
    
    @isTest
    public static void handleEquipmentTest(){
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        Equipment__c equip = new Equipment__c(Equipment_Description__c='Capacete telepático', 
                                              Equipment_Value__c=150,Equipment_Quantity__c=2,
                                             Equipment_Brand__c='ACME');
        rentapp.addEquipment(equip);
        list<Equipment__c> equipList = rentapp.getEquipments();
        rentapp.updateEquipments(equipList);
    }
    
    @isTest(SeeAllData=true)
    public static void SendRentingContractTester(){
        
        RentingApplication rentapp = new RentingApplication(data.get('appID'));
        
        String contractidtypeA = rentapp.buildContract('RENTING');
        
        rentapp.SendRentingContract(contractidtypeA);
    }

    @isTest(SeeAllData=true)
    public static void setAppDocFeeTest(){
        Test.startTest();

        RentingApplication rentapp = new RentingApplication(data.get('appID'));

        rentapp.setAppDocFee(true, false);
        Application__c app = rentapp.getInfo();
        System.assert(app.Vendor_Diluted_Doc_Fee__c, 'Doc Fee should be true');

        rentapp.setAppDocFee(false, true);
        app = rentapp.getInfo();

        System.assert(!app.Vendor_Diluted_Doc_Fee__c, 'Doc Fee should be false');

        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void changeApplicationFieldsTest(){

        Test.startTest();
        
            RentingApplication rentapp = new RentingApplication(data.get('appID'));
            Application__c app = rentapp.getInfo();
            app.Status__c ='Application - Approved';
            update app;

            rentapp.setInsuranceType('Static Risk');

            Contact con2 = new Contact(FirstName = 'Miles', LastName='Davis', Email='vendor@email.pt', AccountId=app.AccClient__c, Role__c='Binding Power');
            String result = rentapp.setEmailContact(con2);
            System.assertEquals(result,'SAME_EMAIL');

            Contact con = new Contact(FirstName = 'Miles', LastName='Davis', Email='Miles@email.pt', AccountId=app.AccClient__c, Role__c='Binding Power');
            result = rentapp.setEmailContact(con);
            
            insert con;//inserir para depois fazer query pelo field Name
            Contact conWithName = [SELECT ID, NAME, Email,Role__c, AccountId, Description, New_Binding_Contact__c FROM Contact WHERE ID=:con.Id];
            result = rentapp.setEmailContact(conWithName);
            System.assertEquals(conWithName.Id,result);

            String status = rentapp.getAppStatus().Status__c;
            Application__c app_after = rentapp.getInfo();
            System.assertEquals(app_after.Insurance_Type__c,'Static Risk');
            System.assertEquals(status, 'Application - Approved');

            rentapp.calcOpValueFromAmount(125,12);
            rentapp.getContactsApp();
            RentingApplication.setEmailById(data.get('contactID'),'ffuu@fuuu.pt');
            rentapp.setCertificateSigner(data.get('contactID'));

        Test.stopTest();
    }

    /*@isTest(SeeAllData=true)
    public static void ResendDocuSignCorrection(){
        String[] contactArray = new String[]{data.get('contactID')}; 
        RentingApplication.resendContractDocuSignCorrection((ID)data.get('docuSignStatusID'),contactArray);
    }*/

    @isTest
    public static void testFirstContractRunning(){

        //Account Vendor
        Account vendorFirstContract = new Account();
        vendorFirstContract.Name = 'Test Account Vendor'; 
        vendorFirstContract.Type = 'Channel Partner / Vendor';
        vendorFirstContract.NIF__c = '509895956';
        insert vendorFirstContract;

        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '505740060';
        Client.Date_Of_Establishment__c = Date.newInstance(2015, 01, 01);
        insert client;

        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendorFirstContract.Id;
        insert vendorContact;

        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendorFirstContract.ID;
        app.Vendor_Primary__c=vendorContact.id;
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
        app.Equipment_Cost__c = 2402.63;
        app.Insurance_Special_Value__c = 9.31;
        app.Insurance_Movement_value__c = 11.01;
        app.Client_BBAN__c = '004563904014640899590';
        app.Payment_Freq__c ='Monthly';
        app.Payment_Amount__c = 2500;
        app.Invoice_Payment_Date__c =date.today();
        app.Generate_Billing__c=true;
        app.Annual_Interest_Rate__c=9.2;
        app.Vendor_Diluted_Doc_Fee__c=true;
        app.ATM_Reference__c=true;
        app.Interim_Fee__c=true;
        app.ATM_Reference_Costs__c=10;
        app.eSignature_Contract__c=true;
        app.Paper_Contract__c=true;
        app.Insurance_Pro_Rata_Checkbox__c=true;
        insert app;
        
        Test.startTest();
            
            app.Status__c ='Contract - Running';
            update app;
            Account acc = [Select First_application__c From Account WHERE ID=:vendorFirstContract.Id];
            System.assert(acc.First_application__c);

        Test.stopTest();
    }  
    
   //Create data test
    private static Map<String, ID> getTestData() {

        Map<String, ID> dataMap = new Map<String,ID>();
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630311';
        //vendor.c2g__CODABankIBANNumber__c ='PT50000700000003253768222';
        insert vendor;
        dataMap.put('vendorID', vendor.ID);

        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendor.Id;
        insert vendorContact;
        dataMap.put('vendorContactID', vendorContact.ID);

        //New Login
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Username__c = 'vendor@email.pt';
        login.Vendor_Vendor__c = vendorContact.Id;
        insert Login;
        Authenticate.generatorPassword(login.Id, 4);
        dataMap.put('loginID', login.ID);
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '504092090';
        Client.Date_Of_Establishment__c = Date.newInstance(2015, 01, 01);
        //Client.BillingPostalCode = '1234-123';
        insert client;
        dataMap.put('clientID', client.ID);
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId=client.ID;
        insert contact;
        dataMap.put('contactID', contact.ID);
        
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        // app.Client_Signer_1__c=con.id;
        app.Vendor_Primary__c=vendorContact.id;
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
        //app.Vendor_Invoice_Amount__c = 2402.63;
        app.Equipment_Cost__c = 2402.63;
        app.Insurance_Special_Value__c = 9.31;
        app.Insurance_Movement_value__c = 11.01;
        app.Client_BBAN__c = '004563904014640899590';
        app.Payment_Freq__c ='Monthly';
        app.Payment_Amount__c = 2500;
        app.Invoice_Payment_Date__c =date.today();
        app.Generate_Billing__c=true;
        app.Annual_Interest_Rate__c=9.2;
        app.Vendor_Diluted_Doc_Fee__c=true;
        app.ATM_Reference__c=true;
        app.Interim_Fee__c=true;
        app.ATM_Reference_Costs__c=10;
        app.eSignature_Contract__c=true;
        app.Paper_Contract__c=true;
        app.Insurance_Pro_Rata_Checkbox__c=true;
        app.ScoreCard__c = 'a0b24000000WUO0';
        //app.Payment_Method__c = 'Direct Debit';
        insert app;
        dataMap.put('appID', app.ID);



        ReportDB__c report = new ReportDB__c();
        report.Vendor__c = client.id;
        Id devRecordTypeId = Schema.SObjectType.ReportDB__c.getRecordTypeInfosByName().get('InformaDB').getRecordTypeId();
        report.RecordTypeId = devRecordTypeId;
        insert report;


        
                
        dsfs__DocuSign_Status__c docuSignStatusTest = new dsfs__DocuSign_Status__c(dsfs__subject__c = 'Auto Aceitação', dsfs__Envelope_Status__c = 'Sent'
                                                                                      ,dsfs__DocuSign_Envelope_ID__c = '5FD15451-8568-4E58-A427-5442A3F43970'
                                                                                      ,docusign_application_status__c = app.id);
        insert docuSignStatusTest;
        dataMap.put('docuSignStatusID', docuSignStatusTest.ID);
        
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusTest = new dsfs__DocuSign_Recipient_Status__c(name='Steve Vai',dsfs__Parent_Status_Record__c = docuSignStatusTest.id
                                                                                                               ,dsfs__Recipient_Status__c='Completed',dsfs__Docusign_Recipient_Email__c = 'Vai@worldit.pt'
                                                                                                               ,dsfs__Contact__c = contact.id, dsfs__docusign_recipient_id__c='502C9EE2-3C61-4818-8023-5DE2B9E0B999' 
                                                                                                               );
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusTest2 = new dsfs__DocuSign_Recipient_Status__c(name='Merlyn Monroe',dsfs__Parent_Status_Record__c = docuSignStatusTest.id
                                                                                                               ,dsfs__Recipient_Status__c='Sent',dsfs__Docusign_Recipient_Email__c = 'Monroe@worldit.pt'
                                                                                                               ,dsfs__Contact__c = contact.id, dsfs__docusign_recipient_id__c='502C9EE2-3C61-4818-3333-5DE2B9E0B999' 
                                                                                                               );
        insert docuSignRecipientStatusTest;
        insert docuSignRecipientStatusTest2;
        dataMap.put('docuSignRecipientID', docuSignRecipientStatusTest.ID);
       
        return dataMap;
    }
    
}