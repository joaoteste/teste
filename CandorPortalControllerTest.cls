@isTest(SeeAllData = true)
public class CandorPortalControllerTest {

	private static Map<String,String> data = getTestData();

	@isTest
	public static void gotoappTest(){
		CandorPortalController cpc = new CandorPortalController();
		PageReference pageRef = Page.partner;
		Login__c login = [SELECT ID, Username__c, password__c FROM Login__c WHERE id=: data.get('loginID')];
		pageRef.getParameters().put('U', login.Username__c);
		pageRef.getParameters().put('P', login.password__c);
		cpc.index = pageRef;
		cpc.Autho();
		cpc.clearSessionCookies(pageRef);

	}

	@isTest
	public static void candorPortalConstructorTest(){
		
	 	PageReference pageRef = Page.partner;
		CandorPortalController cpc = new CandorPortalController();
		cpc.Autho();
		cpc.clearSessionCookies(pageRef);
		boolean issdbx = cpc.isSDBX;	
		String factorcardsJson = CandorPortalController.factorCards;
 	}


	@isTest
	public static void candorPortalgetvendorLoginInfoTest(){
	 	Login__c login = [SELECT ID, Username__c, email_psw__c FROM Login__c WHERE id=: data.get('loginID')];
	 	CandorPortalController.authentication('Wrong', 'wrong',true, 'userAgent', 'idDevice', 'typeDevice');
		CandorPortalController.Result testRes = CandorPortalController.authentication(login.Username__c, login.email_psw__c,true, 'userAgent', 'idDevice', 'typeDevice');
		CandorPortalCOntroller.validateSession(testRes.Id, testRes.info, 'userAgent', 'idDevice', 'typeDevice');
		CandorPortalController.changePassword(login.Username__c, login.email_psw__c, 'carpediem', true);
		CandorPortalController.changeLoginInfo(login, [SELECT ID, NAME, Phone FROM Contact WHERE iD =: testRes.login.Vendor_Vendor__c]);
		CandorPortalController.changePassword(null, null, 'carpediem', true);
		CandorPortalController.getVendorInfo(login.Id);
		CandorPortalController.getVendorClients(login.Id);
		CandorPortalController.getVendorClientsApprovedApps(data.get('clientID'),login.Id);
		CandorPortalController.getVendorContractApps(login.Id);

		Blob cryptoKey = Crypto.generateAesKey(192);
        String newSessionToken = EncodingUtil.base64Encode(cryptoKey);
		CandorPortalCOntroller.validateSession('a012400000aAZjE', newSessionToken, 'userAgent', 'idDevice', 'typeDevice');
		CandorPortalCOntroller.validateSession('togeterrorID', newSessionToken, 'userAgent', 'idDevice', 'typeDevice');
	}

	@isTest
	public static void candorPortalUpdateInfoTest(){
		Login__c login = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID')];
		CandorPortalController.Result testRes = CandorPortalController.authentication(login.Username__c, login.email_psw__c,true, 'userAgent', 'idDevice', 'typeDevice');
		Vendor v = new Vendor(login.Id);
        Account vendorAcc = v.getVendorInfo();
		CandorPortalController.updateVendorAccountInfo(login.Id, vendorAcc);
		CandorPortalController.saveVendorContact(  [SELECT ID, NAME, Phone FROM Contact WHERE AccountID=: login.IdVendor__c limit 1], login.Id, testRes.Id);
	}

	@isTest
	public static void candorPortalInvoiceTest(){
		Blob body = Blob.valueOf('Some Text');
		String attachmentBody = EncodingUtil.base64Encode(body);
		Login__c login = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID')];
		CandorPortalController.Result testRes = CandorPortalController.authentication(login.Username__c, login.email_psw__c,true, 'userAgent', 'idDevice', 'typeDevice');
		CandorPortalController.Result resAttchID = CandorPortalController.uploadInvoice(login.Id,attachmentBody, data.get('appID'), null);
		CandorPortalCOntroller.getAttachments(data.get('appID'));
		CandorPortalController.Result resVendorInvoice = CandorPortalCOntroller.getVendorInvoice(data.get('appID'));
		String vendorInvoiceJson = JSON.Serialize(resVendorInvoice.obj);
		CandorPortalController.updateVendorInvoice(vendorInvoiceJson);
		CandorPortalController.uploadInvoice(login.Id,null, data.get('appID'), null);
	}

	@isTest
	public static void candorPortalApplicationActionsTest0(){
		
		String appID = data.get('appID');
		Login__c login = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID')];
		Login__c login2 = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID2')];
		
		Test.startTest();
		CandorPortalController.Result testRes = CandorPortalController.authentication(login.Username__c, login.email_psw__c,true, 'userAgent', 'idDevice', 'typeDevice');
		CandorPortalController.getApplication(appID, login.Id);
		CandorPortalController.getApplication(appID, login2.Id);
		Application__c app = [SELECT ID, Cancelled__c FROM Application__c WHERE ID =: appID];
		app.Cancelled__c = true;
		update app;
		CandorPortalController.getApplication(appID, login2.Id);

		Account acc = [SELECT ID, Credit_Line_Status__c FROM Account WHERE  ID =: login.IdVendor__c];
		acc.Credit_line_Status__c = 'Credit Line - Suspended';
		update acc;
		CandorPortalController.getApplication(appID, login.Id);
		Test.stopTest();
	}

	@isTest
	public static void candorPortalApplicationActionsTest(){
		Test.startTest();
		String appID = data.get('appID');
		CandorPortalController.setPaymentFreq('Monthly', true, appID);
		CandorPortalController.setPaymentFreq('Monthly', false, appID);
		Test.stopTest();
	}

	@isTest
	public static void candorPortalApplicationActionsTest1(){
		Test.startTest();
		String appID = data.get('appID');
		candorPortalController.calcRents(650, appID);
		CandorPortalController.getRents(appID);

		Application__c app = [SELECT ID, Contract_Sent__c FROM Application__c WHERE ID=:appID ];
		app.Contract_Sent__c = System.today();
		candorPortalController.calcRents(650, appID);
		Test.stopTest();
	}

	@isTest
	public static void candorPortalControllerActionTest2(){
		Test.startTest();
		String appID = data.get('appID');
		CandorPortalController.setTerm('12',250,appID);
		CandorPortalController.Result resContacts = CandorPortalController.getContactsApp(appID);
		CandorPortalController.getAppStatus(appID);

		//New Contact
        Contact contact=new contact();
        contact.firstName = 'West';
        contact.LastName = 'Mongomery';
        contact.Email = 'west@email.com';
        contact.Role__c='Binding Power';
        contact.Department = 'SOCGER';
        insert contact;
        String[] contractTypeTest  = new String[] {'auto','renting','delete'};
		CandorPortalController.setEmailContact(contact,appID);
		CandorPortalController.cancelApplication(appID);
		CandorPortalController.EditContract(appID, contractTypeTest);
		CandorPortalController.EditContract('a012400000aAZjE', contractTypeTest); // to give error 
		CandorPortalController.setEmailById(contact.Id,contact.Email);
		Test.stopTest();
	}
/*
	@isTest
	
	public static void candorPortalApplicationActionsTest3(){
		String appID = data.get('appID');
		Login__c login = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID')];
		CandorPortalController.Result testRes = CandorPortalController.authentication(login.Username__c, login.email_psw__c,true, 'userAgent', 'idDevice', 'typeDevice');

		CandorPortalController.requestApplication('501236478', login.Id);
		CandorPortalController.Result resContract = CandorPortalController.buildContract(appID, 'AUTO');
		CandorPortalController.sendRentingContract(appID, resContract.Id);
		CandorPortalController.sendAutoContract(appID,  resContract.Id);
		CandorPortalController.resendContractDocuSign(data.get('docuSignStatusID'));
		CandorPortalController.setViewedContract(appID);
	}
*/
	@isTest
	public static void candorPortalApplicationActionsTest4(){
		String appID = data.get('appID');
		Login__c login = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID')];
		CandorPortalController.setPaymentMethod(appID, 'ATM REference');
		CandorPortalController.setClientIban('PT50000201231234567890154', data.get('ClientID'));
		CandorPortalController.setVendorIban('PT50000201231234567890154', data.get('VendorID'));

	}	


	@isTest
	public static void imageUploadTest(){
		Blob body = Blob.valueOf('Some Text');
		String attachmentBody = EncodingUtil.base64Encode(body);
		Login__c login = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID')];
		CandorPortalController.Result testRes = CandorPortalController.authentication(login.Username__c, login.email_psw__c,true, 'userAgent', 'idDevice', 'typeDevice');
		CandorPortalController.Result resAttchID = CandorPortalController.uploadLogo(login.Id,attachmentBody, data.get('appID'), null);
		CandorPortalCOntroller.getAttachments(data.get('appID'));
		CandorPortalController.Result resVendorLogo = CandorPortalCOntroller.getLogo(data.get('appID'));
		CandorPortalController.uploadLogo(login.Id,null, data.get('appID'), null);
	}	

	@isTest
	public static void candorPortalApplicationNotificationsTest(){
		String appID = data.get('appID');
		Login__c login = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID')];
		CandorPortalController.Result res = CandorPortalController.getNotifications(login.ID);

        Set<Id> notifSetID = (new Map<Id,SObject>(res.listSo)).keySet();

        ID[] notificationsIDList = new list<ID>();
        for(ID not_id : notifSetID){
            notificationsIDList.add(not_id);
        }
		CandorPortalController.setNotificationsRead(login.ID, notificationsIDList);

	}		

	@isTest
	public static void candorPortalCOntrollerEquipmentActionsTest(){
		String appID = data.get('appID');	
		Equipment__c equip = new Equipment__c(Equipment_Description__c='Capacete telepático', 
			Equipment_Value__c=150,Equipment_Quantity__c=2,
			Equipment_Brand__c='ACME');	

		CandorPortalController.result res = candorPortalController.addEquipment(appID, equip);
		CandorPortalController.getEquipments(appID);
		Equipment__c[] eList = new Equipment__c[1];
		eList[0] = res.equ;
		CandorPortalController.updateEquipments(appID, eList, true);
		CandorPortalController.deleteEquipment(appID, res.equ);
	}


	@isTest
	public static void getAutoLinkTest(){
		
		String appID = data.get('appID'); 

		CandorDocuments.getAutolink(appID);
        CandorPortalController.result re = new CandorPortalController.result();
        re = CandorPortalController.getAutoLink(appID);


        CandorDocuments.getAutolink(appID);
        re = new CandorPortalController.result();
        re = CandorPortalController.getAutoLink(null);

	}


	@isTest 
	public static void validateVendorClientIbanTest(){
	
	String appID = data.get('appID'); 

    CandorPortalController.validateVendorClientIban(appID,'PT50000201231234567890154');

	}

	@isTest //
	public static void validateVendorClientIbanfAILTest(){
		
	String appID = null;

    CandorPortalController.validateVendorClientIban(appID,'PT50000201231234567890154');
	}



	@isTest
	public static void Sessionvalidtest(){
	
        CandorPortalController.result re = new CandorPortalController.result();
        re = CandorPortalController.isSessionValid('adasd','adasd3123asd');
        re = CandorPortalController.isSessionValid(null,null);

	}


	@isTest
	public static void CandorPortalsetClientValuesTest(){
		Account client = new Account(Name = 'cliente 1', NIF__c='501810285', Type='Customer - Channel', 
                                  Personal_Guarantee__c = True, Available_Credit_Line__c = 5000,
                                  BillingCity='NeverLand',BillingStreet='Crocodile Creek', BillingPostalCode='1234-123');
      	insert client;

      	String appID = data.get('appID');
	  
	  Client.Address c_address = new Client.Address();
	  c_address.BillingCity = 'Wonderland';
	  c_address.BillingStreet = 'The Queen of Hearts Castle';
	  c_address.BillingPostalCode ='1234-123';
	  c_address.PostalCodeFirst = '3214';
	  c_address.PostalCodeSecond = '123';
	  c_address.accountId = client.Id;

	  CandorPortalController.setClientAddress(c_address);

	  Id[] contactsId = new Id[1];
	  contactsId[0] = data.get('ContactID'); 
	  CandorPortalController.setAppClientSigners(appID,contactsId);

	}

	/*@isTest
	public static void setInsuranceType(){

		String appID = data.get('appID');
		String insuranceType = 'Special Risk';

		CandorPortalController.setInsuranceType(appID, insuranceType);
	}*/

	@isTest
	public static void calcOpValueFromAmountTest(){

		String appID = data.get('appID');
		Decimal paymentAmount = 160;
		Integer term = 12;

		CandorPortalController.calcOpValueFromAmount(appID, paymentAmount,term);

	}

	@isTest
	public static void setCertificateSignerTest(){
		Application__c app = [SELECT ID FROM Application__c WHERE ID=:data.get('appID')];
		Contact contact =  [SELECT ID, LastName, FirstName, Email, Name FROM Contact WHERE Id =:data.get('contactID')];

		CandorPortalController.setCertificateSigner(contact.ID, app.Id);

	}

	@isTest
	public static void setAppDocFee1(){

		String appID = data.get('appID');

		Test.startTest();
		CandorPortalController.setAppDocFee(appID, true, true);
		RentingApplication ra = new RentingApplication(appID);
		Application__c app = ra.getAppSobject();
		app.Contract_Sent__c = System.today();
		update app;
		CandorPortalController.setAppDocFee(appID, true, true);
		Test.stopTest();

	}

	@isTest
	public static void setAppDocFee2(){

		String appID = data.get('appID');

		Test.startTest();
		CandorPortalController.setAppDocFee(appID, true, false);
		Test.stopTest();

	}

	@isTest
	public static void setSignatureAmountTest(){

		String appID = data.get('appID');

		CandorPortalController.setSignatureAmount(5,appID);
		CandorPortalController.setSignatureAmount(0,appID);

	}

	@isTest
	public static void getInfoScoresTest(){
		ID vendorloginId = (ID) data.get('loginID');
		CandorPortalController.getInfoScores(vendorloginId);
	}



	@isTest
	public static void addNewLoginTest(){

		String LoginID = [SELECT ID FROM LOGIN__C WHERE IdVendor__c=:data.get('vendorID')].Id;
		Contact new_c = new Contact(LastName='Miles', FirstName='Davis', Email='email@email.pt', AccountId=data.get('vendorID'));
		insert new_c;
		new_c = [SELECT LastName, FirstName, Email, Name FROM Contact WHERE Id =: new_c.Id]; 
		CandorPortalController.Result res = CandorPortalController.addNewLogin(new_c,loginID, false);

        login__c newLogin = [SELECT Email__c, Username__c, Master__c FROM Login__c  WHERE ID=:res.id ];
        System.assertEquals(newLogin.Username__c,'email@email.pt', 'Username__c should be email@email.pt and is ' + newLogin.Username__c);
        System.assertEquals(newLogin.Master__c,false, 'Master__c should be false');
        

        Contact c = new Contact(LastName='Chet', FirstName='Baker', Email='email@email.pt');
        CandorPortalController.Result res_failed = CandorPortalController.addNewLogin(c,loginID, false);
        System.assertEquals(res_failed.error.contains('DUPLICATE_VALUE'),true, 'Result should contain "DUPLICATE_VALUE"');

        Contact c2 = new Contact(LastName='Chet', FirstName='Baker', Email='email2@email.pt');
        CandorPortalController.Result res_failed_2 = CandorPortalController.addNewLogin(c2,res.Id, false);
        System.assertEquals(res_failed_2.error,'IS_NOT_MASTER', 'Result should be "IS_NOT_MASTER"');

	}

	@isTest
	public static void recoverpwTest(){
		String Username = [SELECT Username__c FROM LOGIN__C WHERE IdVendor__c=:data.get('vendorID')].Username__c;
		CandorPortalController.Result res = CandorPortalController.recoverpw(Username);
		System.assert(res.status, 'Ocorreu um erro a recuperar password');
	}

	@isTest
	public static void setCorrectedEmailDocusignTest(){
		Test.startTest();
		CandorPortalController.setCorrectedEmailDocusign(data.get('docuSignStatusID'), 'P0024000000WUO1','emailteste@email.pt');
		CandorPortalController.getDocusignCorrectedEmails(data.get('docuSignStatusID'));
		CandorPortalController.resendContractDocuSign(data.get('docuSignStatusID'));
		Test.stopTest();
	}

	@isTest
	public static void CandorPortalControlErrorTest1(){
		Login__c login = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID')];
		CandorPortalController.getVendorInfo(null);
		CandorPortalController.getVendorClients(null);
		CandorPortalController.getVendorClientsApprovedApps(null,login.Id);
		CandorPortalController.getVendorContractApps(null);
		CandorPortalController.setPaymentMethod(null, 'ATM REference');
		CandorPortalController.setClientIban('PT50000201231234567890154', null);
		CandorPortalController.setVendorIban('PT50000201231234567890154', null);
		CandorPortalController.requestApplication_v2('501236478',null);
		CandorPortalController.getLogo('a012400000aAZjE');
		CandorPortalController.uploadLogo(null, null, null, null);
		Vendor v = new Vendor(login.Id);
        Account vendorAcc = v.getVendorInfo();
		CandorPortalController.updateVendorAccountInfo('a012400000aAZjE', null);
		CandorPortalController.updateVendorAccountInfo(null, null);
		CandorPortalController.getVendorInvoice(null);
		CandorPortalController.getVendorInvoice('togeterrorID');
		CandorPortalController.recoverpw(null);
		CandorPortalController.calcRents(null, null);
		CandorPortalController.calcOpValueFromAmount(null,null,null);
		CandorPortalController.setAppDocFee(null,null,null);
		CandorPortalController.setCertificateSigner(null,null);
		CandorPortalController.setEmailContact(null,null);
		CandorPortalController.requestApplication_v2(null,null);
		CandorPortalController.buildContract(null,null);
		CandorPortalController.sendRentingContract(null,null);
		CandorPortalController.validateSession(null,null,null,null,null);
		CandorPortalController.isSessionValid(null,null);
		CandorPortalController.changePassword(null,null,null,null);
		CandorPortalController.changeLoginInfo(null,null);
		CandorPortalController.authentication(null,null,null,null,null,null);
		CandorPortalController.getLogo(null);
		CandorPortalController.updateVendorAccountInfo(null,null);
	}

	@isTest
	public static void CandorPortalControlErrorTest2(){
		Login__c login = [SELECT ID, Username__c, email_psw__c,IdVendor__c FROM Login__c WHERE id=: data.get('loginID')];
		Vendor v = new Vendor(login.Id);
	 	Account vendorAcc = v.getVendorInfo();
		CandorPortalController.updateVendorAccountInfo(null,null);
		CandorPortalController.uploadInvoice(null,null,null,null);
		CandorPortalController.getVendorInvoice(null);
		CandorPortalController.resendContractDocuSignCorrection(null,null);
		CandorPortalController.setClientIban(null,null);
		CandorPortalController.setVendorIban(null,null);
		CandorPortalController.getInfoScores(null);
		CandorPortalController.setClientIban(null,null);
		CandorPortalController.updateVendorAccountInfo(null, vendorAcc);
		CandorPortalController.saveVendorContact( null, login.Id, null);
		CandorPortalController.uploadInvoice(null,null, null, null);
		CandorPortalController.authentication(null,null,null,null,null,null);
		CandorPortalCOntroller.getVendorInvoice(null);
		CandorPortalCOntroller.getAttachments(null);
		CandorPortalController.getApplication(null, login.Id);
		CandorPortalController.getApplication('a012400000aAZpp', login.Id);
		CandorPortalController.getRents('a012400000aAZpp');
		CandorPortalController.setPaymentFreq('something',true,'a012400000aAZpp');
		CandorPortalController.setTerm('12',25,'a012400000aAZpp');
		CandorPortalController.getContactsApp('a012400000aAZpp');
		CandorPortalController.getAppStatus('a012400000aAZpp');
		CandorPortalController.requestApplication_v2('123132', 'a012400000aAZpp');
		CandorPortalCOntroller.setClientAddress(null);
		CandorPortalController.sendAutoContract('a012400000aAZpp',  null);
		CandorPortalController.setAppClientSigners('a012400000aAZpp', null);
		CandorPortalController.setViewedContract('a012400000aAZpp');
		CandorPortalCOntroller.addEquipment('a012400000aAZpp', null);
		CandorPortalCOntroller.deleteEquipment('a012400000aAZpp', null);
		CandorPortalCOntroller.getEquipments(null);
		CandorPortalController.getNotifications(null);
		CandorPortalController.setNotificationsRead(null, null);
		CandorPortalController.Result r = new CandorPortalController.Result();
		r.writeLogFalseRent('erro');

		candorPortalController.Result CPRREsult = new CandorPortalController.Result();
	}

	@isTest
	public static void testCalcPayment_temp(){
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
        CandorPortalController.calcPayments_temp(ra.getAppSObject().Id, selected, 'freq', false);
        CandorPortalController.calcPayments_temp('a012400000aAZjE', selected, 'freq', true);
	}

	@isTest
	public static void testRequestApplication_v2_temp(){
        RentingApplication ra = new RentingApplication(data.get('appID'));
     	ID loginID = data.get('LoginID');
        CandorPortalController.requestApplication_v2('524896357',loginID);
	}

	@isTest
	public static void testConfirmSubmission(){
        RentingApplication ra = new RentingApplication(data.get('appID'));
     	ID loginID = data.get('LoginID');
        Rents.Selected selected = new Rents.Selected();
        Rents rentsObj = new Rents('E','1','Standard','PT');
        Integer[] termOptions = new Integer[]{12,36,48};
        Map<Integer, Decimal> optionsMap = rentsObj.getOptions(24000, termOptions);
        selected.term = 60;
        selected.rent = optionsMap.get(60);
        selected.freq = 'Quarterly';
        selected.admin_costs = 100;
        selected.doc_fee = false;

        CandorPortalController.setPayments(ra.getAppSObject().Id, selected);
        CandorPortalController.confirmSubmission(ra.getAppSObject().Id, new Id[]{data.get('contactID')},selected);
	}

	@isTest 
	public static void testeDeleteLogin(){

		Vendor_Invoice__c vendorInvoice = new Vendor_Invoice__c();
       
        vendorInvoice.Account__c = data.get('vendorID');   
        vendorInvoice.Application__c = data.get('appID');     
        insert vendorInvoice;

        CandorPortalController.cancelInvoice((string) data.get('loginID'), vendorInvoice.Id);
        Contact c = new Contact(AccountID = data.get('vendorID'), LastName='teste');
        insert c; 
    	Contact c2 = new Contact(AccountID = data.get('vendorID2'), LastName='teste2');
        insert c2;

        //New Login
        Login__c login3 = new Login__c();
        login3.IdVendor__c = data.get('vendorID2');
        login3.Username__c = 'vendor3@email.pt';
        login3.Vendor_Vendor__c = c2.Id;
        insert Login3;

		CandorPortalController.deleteLoginInfo(Login3,[SELECT ID FROM Login__c WHERE ID=: data.get('loginID')]);

		//to pass in the cacth block
		CandorPortalController.cancelInvoice(null,null);
		
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

        //New Account Vendor
        Account vendor2 = new Account();
        vendor2.Name = 'Test Account Vendor 2'; 
        vendor2.Type = 'Channel Partner / Vendor';
        vendor2.NIF__c = '507794125';
        //vendor.c2g__CODABankIBANNumber__c ='PT50000700000003253768222';
        insert vendor2;
        dataMap.put('vendorID2', vendor2.ID);

        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendor.Id;
        insert vendorContact;
        dataMap.put('vendorContactID', vendorContact.ID);

        //New VEndor Contact
        Contact vendorContact2=new contact();
        vendorContact2.FirstName = 'José2';
        vendorContact2.LastName = 'Mourinho2';
        vendorContact2.Email = 'vendor2@email.pt';
        vendorContact2.Role__c='Master';
        vendorContact2.AccountId = vendor.Id;
        insert vendorContact2;
        dataMap.put('vendorContactID2', vendorContact.ID);

        //New Login
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Username__c = 'vendor@email.pt';
        login.Vendor_Vendor__c = vendorContact.Id;
        insert Login;
        CandorAuthorization.resetPassword(login.Username__c, false);
        dataMap.put('loginID', login.ID);


        //New Login
        Login__c login2 = new Login__c();
        login2.IdVendor__c = vendor2.Id;
        login2.Username__c = 'vendor2@email.pt';
        login2.Vendor_Vendor__c = vendorContact2.Id;
        insert Login2;
        CandorAuthorization.resetPassword(login2.Username__c, false);
        dataMap.put('loginID2', login2.ID);
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '504092090';
        insert client;
        dataMap.put('clientID', client.ID);
        
        //New Contact
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.Department = 'SOCGER';
        insert contact;
        dataMap.put('contactID', contact.ID);
        
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        // app.Client_Signer_1__c=con.id;
        //app.Vendor_Primary__c=convendor.id;
        app.Insurance_Type__c = 'Special Risk';
        app.Issuing_Date_Invoice__c = Date.newInstance(2016, 6, 1);
        app.Payment_Timing__c='Arreas';
        app.Invoice_Payment_Date__c =Date.newInstance(2016, 9, 20);
        app.TermCalc__c = 48;
        app.Vendor_Invoice_Amount__c = 2402.63;
        //app.Equipment_Cost__c = 2402.63;
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
        //app.Vendor_Invoice_Amount__c = 2402.63;
        app.IdLoginCreate__c = login.Id;
        app.ScoreCard__c = 'a0b24000000WUO1';
        insert app;
        dataMap.put('appID', app.ID);

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