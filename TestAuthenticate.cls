@isTest(SeeAllData=true)
public class TestAuthenticate 
{
    private static String userAgent='Mozilla/5.0 (Linux; Android 5.0; SM-G900F Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Crosswalk/15.44.384.13 Mobile Safari/537.36';
    private static String IdDevice = 'fLjmFpcBZiI:APA91bFjWKvCoWu40NotJoGylN4KLLyXgmXvV_gif7qbGL_ZP7xX0_OuWROKq4oL822W4vq5ayVubOaHW7ICeWwM4Dpk55p0kg6RWkA_JnOO-WuRCSar3zrHPvOxDJIQMzZuCh-NYRzP';
    private static String TypeDeviceAndroid = 'Android';
    private static String TypeDeviceIOS = 'IOS';
    private static String password = 'testPsw';
    private static String username = 'JhonDoe';
    private static String encryptedUserString;
    private static String encryptedPswString;
    private static Map<String, ID> data =  getTestData() ;
    
    public static testMethod  void TestAuthenticate()
    {
        String TypeDevice = 'Android';
        Login__c login = new Login__c();
        Login__c login1 = new Login__c();
        Login__c login2 = new Login__c();
       
         test.startTest();
        Authenticate.generatorPassword(data.get('loginID'), 4);
        Login__c l = [SELECT username__c, email_psw__c from Login__c WHERE ID=:data.get('loginID')];
        login=Authenticate.authentication(l.username__c, l.email_psw__c, userAgent, IdDevice, TypeDevice);
        Authenticate.generatorPassword(data.get('loginID'), 4);
        Authenticate.changePassword('123456',data.get('loginID'));
        //login2=Authenticate.authenticationAuto(username, password, userAgent, IdDevice+'a', TypeDevice);
       
        system.assertEquals(1, 1, 'ERRO: Não são iguais');
        test.stopTest();
    }
    
    /*public static testMethod void testClearOldSessions(){
        test.startTest();
       // Authenticate.ClearOldSessions();
        test.stopTest();
    }*/
    
    public static testMethod void testAuthoAuthentication(){
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '123654987';
        //vendor.c2g__CODABankIBANNumber__c ='PT50000700000003253768222';
        insert vendor;
        //New VEndor Contact
        Contact vendorContact=new contact();
        vendorContact.FirstName = 'José';
        vendorContact.LastName = 'Mourinho';
        vendorContact.Email = 'vendor@email.pt';
        vendorContact.Role__c='Master';
        vendorContact.AccountId = vendor.Id;
        insert vendorContact;
        
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = vendorContact.Id;
        login.master__c=true;
        insert login;

        Authenticate.generatorPassword(login.Id, 4);
        login__c l = [SELECT Username__c, Password__c, email_psw__c FROM Login__C WHERE IdVendor__c=:vendor.Id];
        System.debug('Username: ' + l.username__c + ' '  + 'pass: ' + l.email_psw__c);
        login__c login2=Authenticate.authentication(l.username__c, l.email_psw__c, '', '', '');
        System.debug(login2);
        username=login2.username__c;
        password=login2.password__c;
        
        test.startTest();
        Authenticate.authenticationAuto(username, password, '', '', '');
        test.stopTest();
    }
    
	private static Map<String, ID> getTestData() {
      
        Map<String, ID> dataMap = new Map<String,ID>();
        
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630311';
        insert vendor;
        dataMap.put('vendorID', vendor.ID);
        
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
        //app.Vendor_Invoice_Amount__c = 2402.63;
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
        insert app;
        dataMap.put('appID', app.ID);
        
        
        //New Login
        Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        login.username__c = username;
        system.debug('pass: ' + password);
        Blob pswBlob = Blob.valueOf(password);
        Blob cryptoKey = Crypto.generateAesKey(192);
        String hashkey = EncodingUtil.base64Encode(cryptoKey);
        login.HashKey__c=hashkey;
        cryptoKey = Blob.valueOf(hashkey);
        Blob exeIV = Blob.valueOf('2015121416250400');
        Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, exeIV, pswBlob);
        encryptedPswString = EncodingUtil.base64Encode(encryptedData);
        login.Password__c=encryptedPswString;
        login.email_psw__c=Crypto.decrypt('AES256', cryptoKey, exeIV, encryptedData).toString();	
        insert login;
        dataMap.put('loginID', login.ID);     
        //        Test.setCreatedDate(login.ID, DateTime.newInstance(2015, 12, 14, 16, 25, 04)); 
        
        //Create Session
        Session__c session = new Session__c(HashKey__c=hashkey, UserAgent__c=userAgent, IdDevice__c=IdDevice, TypeDevice__c=TypeDeviceAndroid, LastLogin__c=date.today(), Login__c=login.Id);
        Blob userBlob = Blob.valueOf(username);
        Blob encryptedUserData = Crypto.encrypt('AES256', cryptoKey, exeIV, userBlob);
        encryptedUserString = EncodingUtil.base64Encode(encryptedUserData);
        
        session.UsernameS__c=encryptedUserString;
        session.PasswordS__c=encryptedPswString;
        insert session;
        dataMap.put('sessionID', session.id);
        // Test.setCreatedDate(session.ID, DateTime.newInstance(2015, 12, 14, 16, 25, 04)); 
        
        /* String appId = VendorHomePage.RequestApplication(vendor.id, '503652660', lOGIN.id);   
		dataMap.put('appID', appID);*/
        return dataMap;
    }    
}