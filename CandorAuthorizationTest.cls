@isTest
public class CandorAuthorizationTest {
    
    private static String userAgent='Mozilla/5.0 (Linux; Android 5.0; SM-G900F Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Crosswalk/15.44.384.13 Mobile Safari/537.36';
    private static String IdDevice = 'fLjmFpcBZiI:APA91bFjWKvCoWu40NotJoGylN4KLLyXgmXvV_gif7qbGL_ZP7xX0_OuWROKq4oL822W4vq5ayVubOaHW7ICeWwM4Dpk55p0kg6RWkA_JnOO-WuRCSar3zrHPvOxDJIQMzZuCh-NYRzP';
    private static String TypeDeviceAndroid = 'Android';
    private static String TypeDeviceIOS = 'IOS';
    private static String pass = 'test';
    private static String user = 'test@email.com';
    private static String HashKey = '';
    private static String encryptPass = '';
    
    private static String getLoginID(){
         //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630330';
        insert vendor;
        
        //New Contact
        Contact contact=new contact();
        contact.firstName = 'Jhon';
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Master';
        contact.AccountId = vendor.ID;
        insert contact;
        
        System.debug(vendor.ID);
        Blob cryptoKey = Crypto.generateAesKey(192);
        hashkey = EncodingUtil.base64Encode(cryptoKey);
        
        Login__c login = new Login__c (Email__c=contact.Email, Username__c=contact.Email, Vendor_vendor__c=contact.ID, IdVendor__c=vendor.ID, master__c=true, HashKey__c = HashKey, NewHash__c=true);
        insert login;
        
        login = [SELECT ID, CreatedDate, Password__c FROM Login__c WHERE ID =: login.ID ];
        
        String initializationVector = login.CreatedDate.formatGmt('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
     
        
        encryptPass = CandorAuthorization.encryptString(HashKey, initializationVector, pass);
        
        login.Password__c = encryptPass;
        
        update login;
        
        return login.ID;
    }
    
    
    static testMethod void SessionCreationTest(){ 
        
        String loginID = getLoginID();
        
        test.startTest();
        CandorAuthorization autho = new CandorAuthorization();        
        Session__c session = autho.createNewSession(user, pass, loginID, UserAgent, IdDevice, TypeDeviceAndroid);
       

        System.assert(autho.isValid(), autho.getErrorMsg());
        System.assertEquals(session.ID, autho.getSessionID(), 'Session ID are not the same');
        
        Login__c UserInfo = autho.getUserInfo();      
        System.assertEquals(UserInfo.ID, loginID, 'Login ID are diferent');
        
        boolean validSession = autho.ValidateSession(autho.getSessionID(), autho.getToken(), UserAgent, IdDevice, TypeDeviceAndroid);
        System.assert(validSession, 'Error validating session');
        
        //testing contructor
        CandorAuthorization autho2 = new CandorAuthorization(autho.getSessionID(), autho.getToken(), UserAgent, IdDevice, TypeDeviceAndroid);
        System.assert(autho2.isValid(), 'Session is not valid!');

        //testing isSessionValid
        Boolean isValid = CandorAuthorization.isSessionValid(autho2.getSessionID(), autho2.getToken());
        System.assert(isValid, 'Session is not valid!');
        
        //testing isSessionValid after changing password
        Id olSessionId = autho.getSessionID();
        autho2.changePassword('carpediem');
        Boolean isValidAfterChangePassword = CandorAuthorization.isSessionValid(autho2.getSessionID(), autho2.getToken());
        System.assert(!isValidAfterChangePassword,'Session is valid!');
        
        test.stopTest();
    }
    
    static testMethod void LoginErrorTest(){ 
        
        String loginID = getLoginID();
        
        test.startTest();
        CandorAuthorization autho = new CandorAuthorization();        
        Session__c session = autho.createNewSession(user, pass, loginID, UserAgent, IdDevice, TypeDeviceAndroid);
        autho.Transition(session.UsernameS__c, session.PasswordS__c, 'UserAgent', 'IdDevice', 'TypeDevice');
        boolean validSession = autho.ValidateSession(autho.getSessionID(), 'WrongToken', UserAgent, IdDevice, TypeDeviceAndroid);
        System.assert(!validSession, 'session validation should have failed!');
        System.assertEquals(autho.getErrorMsg(), 'tokens dont match');
        
        validSession = autho.ValidateSession('WrongID', autho.getToken(), UserAgent, IdDevice, TypeDeviceAndroid);
        System.assert(!validSession, 'session validation should have failed!');
        System.assertEquals(autho.getErrorMsg(), 'Session ID WrongID not found.');
        
        test.stopTest();
    }

    static testMethod void ChangePassTest(){ 
        
        String loginID = getLoginID();
        
        test.startTest();
        CandorAuthorization autho = new CandorAuthorization();        
        Session__c session = autho.createNewSession(user, pass, loginID, UserAgent, IdDevice, TypeDeviceAndroid);
        autho.changePassword('carpediem');
        autho.createNewSession(user, 'carpediem', loginID, UserAgent, IdDevice, TypeDeviceAndroid);
        system.assert(autho.isValid(), 'Password was not changed to carpediem');
        String oldPassword = [SELECT Password__c FROM Login__c WHERE Id=:autho.getUserInfo().Id Limit 1].Password__c;
        CandorAuthorization.resetPassword(autho.getUserInfo().Username__c, true);
        System.assert(oldPassword!=[SELECT Password__c FROM Login__c WHERE Id=:autho.getUserInfo().Id Limit 1].Password__c,'Password was not changed');
        
        test.stopTest();
    }

    static testMethod void CreateNewLogintest(){ 
        String loginID = getLoginID();
        ID vendorID = [SELECT IdVendor__c FROM LOGIN__C WHERE ID=:loginID].IdVendor__c;
        Contact new_c = new Contact(LastName='Miles', FirstName='Davis', Email='email@email.pt', AccountId=vendorID);
        test.startTest();

        String newLoginId = CandorAuthorization.createNewLogin(new_c);
        login__c newLogin = [SELECT Email__c, Username__c, Master__c FROM Login__c  WHERE ID=:newLoginId ];
        System.assertEquals(newLogin.Username__c,'email@email.pt', 'Username__c should be email@email.pt and is ' + newLogin.Username__c);
        
        test.stopTest();
    }

    static testMethod void testCreateLoginTrigger(){

        test.startTest();
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'New Vendor Account'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '999888777';
        insert vendor;
        
        //New Contact
        Contact contact=new contact();
        contact.firstName = 'King';
        contact.LastName = 'Arthur';
        contact.Email = 'mrking@email.com';
        contact.Role__c='Master';
        contact.AccountId = vendor.ID;
        insert contact;

        test.stopTest();
        
        login__c newLogin = [SELECT Email__c, Username__c, Master__c FROM Login__c  WHERE Username__c=:contact.Email ];
        System.assertEquals(newLogin.Username__c,contact.Email, 'Username__c should be ' + contact.Email + ' and is ' + newLogin.Username__c);
    }
    
}