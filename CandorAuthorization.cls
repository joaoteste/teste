global class CandorAuthorization {
    
    //public Result result {get;set;}

    public Login__c login {get;set;}
    public Session__c session{get;set;}
    public boolean status{get;set;}  
    public string error{get;set;} 
    
    //no-argument constructor
    public CandorAuthorization(){
        //this.result = new Result();
    }
    
    //Constructor with variables of session
    public CandorAuthorization(String sessionIDFromCookies, String sessionTokenFromCookies ,String UserAgent, String IdDevice, String TypeDevice){
        
        ValidateSession(sessionIDFromCookies, sessionTokenFromCookies , UserAgent, IdDevice, TypeDevice);
    }
    
    //mÃ©todo temporario, a eliminar!
    public Session__c Transition (String encryptUsername, String encryptPassword,String UserAgent, String IdDevice, String TypeDevice){
        
        session__c session = [SELECT ID, usernameS__c,HashKey__c, passwordS__c,CreatedDate, login__c, Login__r.ID FROM Session__c WHERE usernameS__c=:encryptUsername AND passwordS__c=:encryptPassword];

        String loginID = session.Login__r.ID;
        String sessionDateCreated = session.CreatedDate.formatGmt('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
        String decryptedSessionUsername = decryptString(session.HashKey__c, sessionDateCreated, session.UsernameS__c);
        String decryptedSessionPassword = decryptString(session.HashKey__c, sessionDateCreated, session.PasswordS__c);
        
        session__c new_session =  this.createNewSession(decryptedSessionUsername, decryptedSessionPassword, loginID , UserAgent, IdDevice, TypeDevice);
        update session;
        if(new_session!=NULL){
            return session;    
        }else{
            return null;
        }
    }
    
    //Validate Session 
    public boolean ValidateSession(String sessionIDFromCookies, String sessionTokenFromCookies ,String UserAgent, String IdDevice, String TypeDevice){
        List<Session__c> session = new List<Session__c>();
        //this.result = New Result();
        
        try{
            System.debug('[CandorAuthorization] sessionID: ' + sessionIDFromCookies);
            
            session = [SELECT ID,UsernameS__c, PasswordS__c, UserAgent__c, HashKey__c, token__c,
                       CreatedDate, IdDevice__c, TypeDevice__c, LastLogin__c, login__c
                       FROM Session__c 
                       WHERE ID=:sessionIDFromCookies];
            
            if(session.size()>0){
                
                System.debug('[CandorAuthorization] Token from cookies: ' + sessionTokenFromCookies);
                System.debug('[CandorAuthorization] Token from session: ' + session[0].token__c);
                Date today = Date.today();
                session[0].LastLogin__c = session[0].LastLogin__c==null ? today : session[0].LastLogin__c;
                
                if(session[0].token__c == sessionTokenFromCookies){
                    
                    String sessionDateCreated = session[0].CreatedDate.formatGmt('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
                    String decryptedSessionUsername = decryptString(session[0].HashKey__c, sessionDateCreated, session[0].UsernameS__c);
                    String decryptedSessionPassword = decryptString(session[0].HashKey__c, sessionDateCreated, session[0].PasswordS__c);
                    
                    //Get login associated with the current session
                    String loginDateCreated ='';
                    Login__c login= [SELECT Id, HashKey__c,Remember_me__c,Master__c , CreatedDate, Username__c, Password__c/*, NewHash__c*/, CreatedBy.TimeZoneSidKey 
                                     FROM Login__c 
                                     WHERE ID =:session[0].Login__c AND Inactive__c = false];
                    
                    System.debug('[CandorAuthorization] Validate login for user ' + login.username__c + ' with password ' + login.password__c);
                    
                    //if(login.NewHash__c){//IF Colocado para resolver bug da construÃ§Ã£o do vector de incializaÃ§Ã£o para desincriptaÃ§Ã£o da password. Conflito de timeZones. A REMOVER NO FUTURO! 
                        loginDateCreated = login.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
                    /*}else{
                        loginDateCreated = login.CreatedDate.format('YYYYMMddHHmmss', login.CreatedBy.TimeZoneSidKey) + '00'; //initializationVector for decryption 
                    }*/
                    
                    String decryptedLoginPassword = decryptString(login.HashKey__c, loginDateCreated, login.Password__c);
                    
                    //Check if credentials from Session and Login are the same
                    if(decryptedLoginPassword == decryptedSessionPassword && decryptedSessionUsername == login.username__c ){
                        
                        System.debug('[CandorAuthorization] SUCCESSFUL LOGIN AUTHORIZATION.');
                        System.debug('[CandorAuthorization] Session ' + session[0].ID + ' will be updated');
                        
                        /*if(!login.NewHash__c){//Colocado para resolver bug da construÃ§Ã£o do vector de incializaÃ§Ã£o para desincriptaÃ§Ã£o da password. Conflito de timeZones. A REMOVER NO FUTURO! 
                            loginDateCreated = login.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00'; //initializationVector for decryption
                            String NewEncryptedLoginPassword = encryptString(login.HashKey__c, loginDateCreated, decryptedLoginPassword);
                            login.Password__c = NewEncryptedLoginPassword;
                            login.NewHash__c = true;
                            update login;
                        } */
                        
                        
                        session[0].LastLogin__c = today;
                        session[0].userAgent__c = userAgent;
                        session[0].IdDevice__c = IdDevice;
                        session[0].TypeDevice__c = TypeDevice;
                        
                        //new token if last login was more than 1 day ago (HP) - 02/10/2017 
                        if(session[0].LastLogin__c.daysBetween(today)>=1){
                            Blob cryptoKey = Crypto.generateAesKey(192);
                            String newSessionToken = EncodingUtil.base64Encode(cryptoKey);
                            session[0].token__c = newSessionToken;
                            System.debug('[CandorAuthorization] New Session Token: ' + newSessionToken);
                        }
                        
                        update session;
                        
                        //New query to Login__c and session__c to retrive only the relevant data. 
                        Login__c returnLogin = [SELECT Id, Vendor_NIF__C, email__c, username__c, IdVendor__c, Master__c, Remember_me__c, Vendor_Vendor__r.Name, IdVendor__r.Name  FROM Login__c WHERE ID=:login.ID];
                        Session__c returnSession = [SELECT ID, UsernameS__c, PasswordS__c, token__c FROM Session__c WHERE ID=:session[0].ID];
                        
                        /*result.login = returnLogin;
                        result.session = returnSession;
                        result.status = true; */

                        this.login = returnLogin;
                        this.session = returnSession;
                        this.status = true; 
                        
                    }else{
                        
                        System.debug('[CandorAuthorization] LOGIN AUTHORIZATION FAILED - incorrect password or username');
                        /*result.error = 'incorrect password or username';
                        result.status = false; */ 
                        this.error = 'incorrect password or username';
                        this.status = false;  
                    }
                }else{
                    System.debug('[CandorAuthorization] LOGIN AUTHORIZATION FAILED - tokens don\'t match');
                    //result.error = 'tokens dont match';
                    //result.status = false; 
                    this.error = 'tokens dont match';
                    this.status = false;
                }
            }else{
                System.debug('[CandorAuthorization]  LOGIN AUTHORIZATION FAILED! Session ID ' + sessionIDFromCookies + ' not found.');
                /*result.error = 'Session ID ' + sessionIDFromCookies + ' not found.';
                result.status = false;*/
                this.error = 'Session ID ' + sessionIDFromCookies + ' not found.';
                this.status = false; 

            }
        }catch(Exception e){
            System.Debug('[CandorAuthorization] Error *** Authorization failed!');
            system.Debug(e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage());
            /*result.error = e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage();
            result.status = false;*/
            this.error = e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() + ' ';
            this.status = false;
        }   
        
        //return result.status;
        return this.status;
        
    }

    //verifica se os a sessÃ£o Ã© vÃ¡lida sem modificar o token
    public static Boolean isSessionValid(String sessionIDFromCookies, String sessionTokenFromCookies){
        
        try{
            System.debug('[CandorAuthorization - isSessionValid] sessionID: ' + sessionIDFromCookies);
            
            List<Session__c> sList = [SELECT ID,UsernameS__c, PasswordS__c, UserAgent__c, HashKey__c, token__c,
                       CreatedDate, IdDevice__c, TypeDevice__c, LastLogin__c, login__c, 
                       login__r.Password__c, login__r.CreatedDate, login__r.HashKey__c
                       FROM Session__c 
                       WHERE ID=:sessionIDFromCookies];
            
            if(sList.size()>0){
                if(sList[0].token__c == sessionTokenFromCookies){
                    System.debug('[CandorAuthorization] Token from cookies: ' + sessionTokenFromCookies);
                    System.debug('[CandorAuthorization] Token from session: ' + sList[0].token__c);

                    String sessionDateCreated = sList[0].CreatedDate.formatGmt('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
                    String decryptedSessionPassword = decryptString(sList[0].HashKey__c, sessionDateCreated, sList[0].PasswordS__c);
                
                    String loginDateCreated = sList[0].login__r.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
                    String decryptedLoginPassword = decryptString(sList[0].login__r.HashKey__c, loginDateCreated,sList[0].login__r.Password__c);
                     
                    if(decryptedSessionPassword == decryptedLoginPassword){
                        return true;
                    }else{
                        System.Debug('[CandorAuthorization] - isSessionValid - Password has changed');
                        return false;          
                    }
                }else{
                    System.Debug('[CandorAuthorization] - isSessionValid - Session Token donÂ´t match!');
                    return false;
                }
            }else{
                System.Debug('[CandorAuthorization] - isSessionValid - Session doesnt exist');
                return false;
            }
        }catch(Exception e){
            Utilities.LogIntegration(system.now(),system.now(),'error', 'LOGIN',e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage(),'tetse');
            System.Debug('[CandorAuthorization] - isSessionValid - Error *** Authorization failed!');
            system.Debug(e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage());
            return false;
        } 
    }
    
    //Create New Session
    public Session__c createNewSession(string username, string password, String loginID ,String UserAgent, String IdDevice, String TypeDevice){
        
        try{
            String sessionDateCreated='';
            
            //HashKey
            Blob cryptoKey = Crypto.generateAesKey(192);
            String hashkey = EncodingUtil.base64Encode(cryptoKey);
            
            //Session Token
            cryptoKey = Crypto.generateAesKey(192);
            String newSessionToken = EncodingUtil.base64Encode(cryptoKey);
            
            Date today = Date.today();


            //PARA RESOLVER PROBLEMA DA ENCRIPTAÃ‡Ã‚O DO LOGIN --A REMOVER NO FUTURO QUANDO TODOS OS NewHash__c = true!
            /*Login__c l = [SELECT ID, HashKey__c, CreatedDate, Password__c, CreatedBy.TimeZoneSidKey , NewHash__c FROM Login__c WHERE Id=:loginID];

            if(!l.NewHash__c){
                String loginDateCreatedOld = l.CreatedDate.format('YYYYMMddHHmmss', l.CreatedBy.TimeZoneSidKey) + '00';    
                String loginDateCreatedNew =  l.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00';
             
                String decryptedLoginPassword = decryptString(l.HashKey__c, loginDateCreatedOld, l.Password__c);
                String newEncryptLoginPassword = encryptString(l.HashKey__c, loginDateCreatedNew, decryptedLoginPassword);
                l.NewHash__c = true;
                l.password__c = newEncryptLoginPassword;
                update l;
            }*/
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////

            Session__c session = new Session__c(HashKey__c=hashkey, token__c = newSessionToken ,UserAgent__c=UserAgent, IdDevice__c=IdDevice, TypeDevice__c=TypeDevice, LastLogin__c=today, Login__c=loginID);
            insert session;
            
            session = [SELECT usernameS__c, passwordS__c, token__c, CreatedDate FROM session__C WHERE ID=:session.ID];
            
            sessionDateCreated = session.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00'; //initializationVector for encryption 
            
            session.UsernameS__c = CandorAuthorization.encryptString(HashKey, sessionDateCreated, username);
            session.PasswordS__c = CandorAuthorization.encryptString(HashKey, sessionDateCreated, password);
            
            update session;
            
            /*result.session = session;
            result.status = true;
            result.login = [SELECT Id, Vendor_NIF__C, email__c, IdVendor__c FROM Login__c WHERE ID=: loginID];  */

            this.session = session;
            this.status = true;
            this.login = [SELECT Id, Vendor_NIF__C,Master__c, username__c, email__c, IdVendor__c, Vendor_Vendor__r.Name, IdVendor__r.Name FROM Login__c WHERE ID=: loginID];    
            
            return session;
        
        }catch(exception e){
            System.Debug('[CandorAuthorization - createNewSession()] Error *** create new session failed!');
            system.Debug(e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage());
           /* result.error = e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage();
            result.status = false;*/
            this.error = e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage();
            this.status = false;
            return null;
        }
    }

    public Session__c changePassword(String newPassword){

        if(this.isValid()){
            /*Login__c l = [SELECT CreatedDate, HashKey__c, Username__c FROM LOGIN__C WHERE ID=:login.Id];
            String loginDateCreated = l.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
            Login__c newPassLogin = new Login__C();
            newPasslogin.Id = login.Id; 
            newPassLogin.email_psw__c = newPassword; 
            newPasslogin.Password__c = CandorAuthorization.encryptString(l.HashKey__c, loginDateCreated, newPassword);
            update newPasslogin;*/
            String username = [SELECT username__c FROM Login__c WHERE Id=: Login.Id].username__c;
            Login__c newPassLogin = updateNewPassword(username, newPassword);

            Session__c s =  [SELECT UserAgent__c, IdDevice__c, TypeDevice__c FROM SEssion__c WHERE ID=:this.session.ID];

            return this.createNewSession(newPassLogin.Username__c, newPasslogin.Password__c, login.Id ,s.UserAgent__c, s.IdDevice__c, s.TypeDevice__c);
        }else{
            return null;
        }
    }

    //mÃ©todo usado no botÃ£o gerar password na pagina de Login__c
    //e recuperar password a partir do portal
    webservice static boolean resetPassword(String username, boolean sendEmail){

        String newPassword =  passwordGenerator(4);
        Login__c newPassLogin = updateNewPassword(username, newPassword);

        try{
            Login__c login1= [SELECT id, username__c, email__c, email_psw__c, Vendor_Vendor__c, idvendor__c, User__c, Vendor_First_Name__c, Vendor_Last_Name__c FROM Login__c WHERE username__c =: username];
            
            //ENVIA EMAIL !!!!!!
            String[] toRecipients = new String[]{login1.email__c};
            Utilities.sendTemplatedEmail(toRecipients ,'Vendor_Email_Login_Recovery' ,login1.Vendor_Vendor__c ,login1.id ,true);
            return true;

        }catch (Exception e) {
            return false;
        }
        
    }

    private static Login__c updateNewPassword(String username, String newPassword){
        Blob cryptoKey = Crypto.generateAesKey(192);
        String hashkey = EncodingUtil.base64Encode(cryptoKey);
        Login__c l = [SELECT id, CreatedDate, HashKey__c, Username__c, Password__c, User__c, Vendor_Vendor__c, email__c FROM LOGIN__C WHERE username__c =: username];
        String loginDateCreated = l.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
        Login__c newPassLogin = new Login__C();
        newPasslogin.Id = l.Id; 
        newPasslogin.HashKey__c = hashkey;
        //newPasslogin.NewHash__c = true; //campo a remover no futuro
        newPassLogin.email_psw__c = newPassword; 
        newPasslogin.Password__c = CandorAuthorization.encryptString(hashkey, loginDateCreated, newPassword);
        update newPasslogin;
        return newPasslogin;
        /*return l;
        Login__c l = [SELECT id, CreatedDate, HashKey__c, Username__c, Password__c, User__c FROM LOGIN__C WHERE username__c =: username];
        String loginDateCreated = l.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
        Login__c newPassLogin = new Login__C();
        newPasslogin.Id = l.Id; 
        newPassLogin.email_psw__c = newPassword; 
        newPasslogin.Password__c = CandorAuthorization.encryptString(l.HashKey__c, loginDateCreated, newPassword);
        update newPasslogin;
        return l;*/
    }

    public static String createNewLogin(Contact contact){
        
        Savepoint sp = Database.setSavepoint();
        
        upsert contact;

        Blob cryptoKey = Crypto.generateAesKey(192);
        String hashkey = EncodingUtil.base64Encode(cryptoKey);
        Login__c newlogin = new Login__c (
            Email__c = contact.Email, 
            Username__c=contact.Email, 
            Vendor_vendor__c=contact.Id, 
            IdVendor__c = contact.AccountId,
            HashKey__c = hashkey
            //NewHash__c = true //campo a remover no futuro
        );

        if(contact.Role__c=='Master'){
            newlogin.Master__c = true;
        }else{
            newlogin.Master__c = false;
        }

        try{

            insert newlogin;
            String pass = CandorAuthorization.passwordGenerator(4);
            newlogin = CandorAuthorization.updateNewPassword(newlogin.username__c, pass);
            return newlogin.Id;

        }catch(DmlException e){
            Database.rollback(sp);
            //String error = e.getDmlType(0).name();   
            throw e;         
        }
    }

    private static String passwordGenerator(Integer passLength){

        String charSet ='EFGHIJKLMA3456BCDNOPQRSTUVWXYZ012789$?_!%';
        String newPassword = '';

        for (Integer i=0; i<passLength; i++){
            Double num = Math.Floor(Math.random()*(charSet.length()-1));
            Integer numInt = num.intValue();
            newPassword=newPassword+getCharFromString(charSet, numInt);
        }

        return newPassword;
    }

    private static String getCharFromString (String str, Integer poss){
        String result='';
        if (poss<str.length() && str!= '')
        {
            result=str.substring(poss, poss+1);
        }
        return result;
    }
    
    //Get Session Token
    public string getToken(){
        /*if(result.session!=null){
            return result.session.token__c;
        }else{
            return null;
        }*/

        if(this.session!=null){
            return this.session.token__c;
        }else{
            return null;
        }
    } 
    
    //Get Session Token
    public string getSessionID(){
        if(this.session!=null){
            return this.session.ID;
        }else{
            return null;
        }
    } 
    
    //return status if Authorization is valid or not
    public boolean isValid(){
        return this.status;
    } 
    
    //return error
    /*public Result getError(){
        if(!this.status){
            return result;
        }else{
            return null;
        }
    } */
    
    //return error message
    public String getErrorMsg(){
        if(!this.status){
            return this.error;
        }else{
            return null;
        }
    } 
    
    //return info about user Login
    public Login__c getUserInfo(){
        if(this.login!=null){
            return this.login;
        }else{
            return null;
        }
    }
    
    //descrypt strings
    public static String decryptString(String HashKey, String initializationVector, String encryptedData ){
        
        Blob blobCryptoKey = Blob.valueOf(HashKey);//hashkey para o metodo decrypt
        Blob blobInitializationVector = Blob.valueOf(initializationVector);//InitializationvVector desincriptar
        Blob blobEncryptedData = EncodingUtil.base64Decode(encryptedData);
        Blob decrypted = Crypto.decrypt('AES256', blobCryptoKey, blobInitializationVector, blobEncryptedData);
        
        return decrypted.toString();
    }
    
    //encrypt strings
    public static String encryptString(String HashKey, String initializationVector, String dataToEncrypt ){
        
        Blob blobCryptoKey = Blob.valueOf(HashKey);//hashkey para o metodo decrypt
        Blob blobInitializationVector = Blob.valueOf(initializationVector);//InitializationvVector desincriptar
        Blob blobData = Blob.valueOf(dataToEncrypt);
        Blob blobEncryptedData =  Crypto.encrypt('AES256', blobCryptoKey, blobInitializationVector, blobData);
        String encryptedDataString = EncodingUtil.base64Encode(blobEncryptedData);
        
        return encryptedDataString;
    }
    
    //object with the result of the authorization
    /*public class Result{
        public Login__c login {get;set;}
        public Session__c session{get;set;}
        public boolean status{get;set;} 
        public string error{get;set;} 
    }*/
}