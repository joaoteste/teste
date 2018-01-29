public with sharing class SiteAuthentication {
	
    private static Integer KEY_SIZE = 192;
	private String session_token;
	private String message;
    private Map<String, Id> accountTypes;
    private String username;
    private String pass;
    private Boolean firstLoginWithPass;
    
    public Boolean getFirstLoginWithPass(){
        return this.firstLoginWithPass;
    }
    
    public String getSessionToken(){
        return this.session_token;
    }
    
    public String getErrorMessage(){
        return this.message;
    }
    
    public Map<String, Id> getAccountTypes(){
        return this.accountTypes;
    }
    
    public SiteAuthentication(){
    }
    
    public SiteAuthentication(String username, String pass){
        this.username = username;
        this.pass = pass;
    }
    
    public static String recoverPassword(String email){
        List<Login__c> loginList = [SELECT Inactive__c, email_psw__c, Password__c, CreatedDate, HashKey__c, Recover_Password__c, First_Login_With_Password__c FROM Login__c WHERE Username__c =:email];
        if(loginList.size() <= 0){
            return 'LOGIN_NOT_FOUND';
        }
        //logIn.username is unique in backend, so there is only 1
        Login__c userLogin = loginList.get(0);
        
        //login inactive
        if(userLogin.Inactive__c){
            return 'LOGIN_INACTIVE';
        }

        String newPass = generateRandomString(8);
        String iv = userLogin.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00';
        String hashKey = userLogin.HashKey__c;
    	String encrypted_pass = encryptString(newPass, iv, hashKey);
        
        userLogin.Password__c = encrypted_pass;
        userLogin.email_psw__c = newPass;
        userLogin.First_Login_With_Password__c = true;
        userLogin.Recover_Password__c = true;
        update userLogin;
        
        /*
        String subject = 'CANDOR RENTING S.A. - Recover Password';
        String body = 'Your password was reset to: '+newPass+'\n';
        body += 'Use it the next time you are logging in our system\n';
        body += 'Best regards,\n CANDOR RENTING S.A.';
        
        String[] recievers = new String[] {userLogin.Email__c}; 
        
        return sendEmail(recievers, subject, body);*/
        return 'SUCCESS';
    }
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
}
    
    private static String sendEmail(String[] recievers, String subject, String body){
        Messaging.reserveSingleEmailCapacity(1);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
        //String[] ccAddresses = new String[] {'smith@gmail.com'};
        
        mail.setToAddresses(recievers);
        
        mail.setSenderDisplayName('Candor Renting S.A. Support');
        mail.setSubject(subject);
        
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(body);
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        return 'SUCCESS';
    }
    
    public boolean login(){
        //credentials were not set correctly
        if(this.username == null || this.pass == null){
            this.message = 'CREDENTIALS_NOT_SET';
            return false;
        }
        String username = this.username;
        String pass = this.pass;
        
        List<Login__c> loginList = [SELECT Inactive__c, Password__c, Master__c, CreatedDate, HashKey__c, Username__c, Vendor_Vendor__c, First_Login_With_Password__c FROM Login__c WHERE Username__c =:username];
        //no login for this username
        if(loginList.size() <= 0){
            this.message = 'LOGIN_NOT_FOUND';
            return false;
        }
        //login.username is unique in backend, so there is only 1
        Login__c userLogin = loginList.get(0);
        
        //login inactive
        if(userLogin.Inactive__c){
            this.message = 'LOGIN_INACTIVE';
            return false;
        }
		
		boolean match = checkPasswordsMatch(pass, userLogin);
        
        if(match){
			setAccountTypes(userLogin);
			Id sessionId = createNewSession(userLogin);
            handleFirstLogin(userLogin);
            return sessionId != null;
        }else{
            this.message = 'INCORRECT_PASSWORD';
            return false;
        }
    }
    
    private void handleFirstLogin(Login__c login){
        if(login.First_Login_With_Password__c){
            this.firstLoginWithPass = true;
            login.First_Login_With_Password__c = false;
            update login;
        }else{
            this.firstLoginWithPass = false;
        }
    }
    
    private void setAccountTypes(Login__c login){
        List<Account> accountList = [SELECT Id, Type
                                     FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Login__c =: login.Id)];

        Map<String,Id> accountTypes = new Map<String,Id>();
		for(Account acc : accountList){
            accountTypes.put(acc.Type, acc.Id);
		}
        
		this.accountTypes = accountTypes;
    }
    
    private Id createNewSession(Login__c userLogin){
        
	    String newSessionToken = generateCryptoKeyString(KEY_SIZE);

	    Session__c session = new Session__c(
	    	PasswordS__c = userLogin.Password__c,
	    	token__c = newSessionToken, 
	    	LastLogin__c = Date.today(), 
	    	Login__c = userLogin.Id
		);
	    
	    insert session;
        session_token = newSessionToken;
        
	    return session.Id;
    }
    
    //verifica se a sessão é válida
    public Boolean validateSession(String sessionToken){
        if(sessionToken == null || String.isEmpty(sessionToken)){
            this.message = 'NO_SESSION_TOKEN';
            return false;
        }
        
        List<Session__c> sList = [SELECT ID, token__c, LastLogin__c, PasswordS__c, login__r.Username__c, login__r.Password__c
                                   FROM Session__c 
                                   WHERE token__c = :sessionToken];
        
        if(sList.size() == 0){
            this.message = 'NO_SESSION_FOR_TOKEN';
            return false;
        }
        
        if(sList.size() > 1){
            this.message = 'MORE_THAN_ONE_SESSION';
            return false;
        }
        
        Session__c session = sList.get(0);
        if(session.token__c == sessionToken){
            
            Date dateToday = Date.today();
            session.LastLogin__c = (session.LastLogin__c == null) ? dateToday : session.LastLogin__c;

            //the user may have changed his password in the meanwhile. check if his current password matches the password used when this session was created
            boolean match = session.PasswordS__c.equals(session.login__r.Password__c);
            
            if(!match){
                this.message = 'PASSWORD_HAS_CHANGED';
                return false;
            }
            
            //generate new token if passwords match AND last login was more than 1 day ago
            if(session.LastLogin__c.daysBetween(dateToday)>=1){
                this.message = 'INVALID_SESSION';
                return false;
            }
            return true;
        }else{
            //how can I test this? I dont know....
            this.message = 'TOKEN_DOESNT_MATCH';
            return false;
        }
    }
    
    private boolean checkPasswordsMatch(String pass, Login__c userLogin){
        String iv = userLogin.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00';
        String hashKey = userLogin.HashKey__c;
    	String encrypted_pass = encryptString(pass, iv, hashKey);
    	return encrypted_pass.equals(userLogin.Password__c);
    }
    
    //CRYPTO STUFF
    
    private static String encryptString(String dataToEncrypt, String initializationVector, String HashKey){
        Blob blobCryptoKey = Blob.valueOf(HashKey);//hashkey para o metodo decrypt
        Blob blobInitializationVector = Blob.valueOf(initializationVector);//InitializationvVector desincriptar
        Blob blobData = Blob.valueOf(dataToEncrypt);
        Blob blobEncryptedData =  Crypto.encrypt('AES256', blobCryptoKey, blobInitializationVector, blobData);
        return EncodingUtil.base64Encode(blobEncryptedData);
    }
    
    private static String decryptString(String HashKey, String initializationVector, String encryptedData ){
        
        Blob blobCryptoKey = Blob.valueOf(HashKey);//hashkey para o metodo decrypt
        Blob blobInitializationVector = Blob.valueOf(initializationVector);//InitializationvVector desincriptar
        Blob blobEncryptedData = EncodingUtil.base64Decode(encryptedData);
        Blob decrypted = Crypto.decrypt('AES256', blobCryptoKey, blobInitializationVector, blobEncryptedData);
        
        return decrypted.toString();
    
    }
    
    //used to generate session tokens
    private static String generateCryptoKeyString(Integer size){
        return EncodingUtil.base64Encode(Crypto.generateAesKey(size));
    }
	
}