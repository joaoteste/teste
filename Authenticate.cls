global with sharing class Authenticate 
{

    @RemoteAction
    public static Login__c authenticationAuto(String username, String password, String userAgent, String IdDevice, String TypeDevice)
    {
        Login__c newlogin = new Login__c();
        List<Session__c> session = new List<Session__c>();
        try 
        {
            String sessionDateCreated='';
            String year; String month; 
            String day;
            String hour;
            String minute;
            String second;
            
            system.debug('UsernameS_c: ' + username );
            system.debug('PasswordS__c: ' + password );
            system.debug('IdDevice: ' + IdDevice );
            system.debug('TypeDevice: ' + TypeDevice );
            
            // session=[select UsernameS__c, PasswordS__c, UserAgent__c, HashKey__c, CreatedDate, IdDevice__c, TypeDevice__c, LastLogin__c from Session__c where UsernameS__c=:username and PasswordS__c=:password and UserAgent__c=:userAgent and IdDevice__c=:IdDevice and TypeDevice__c=: TypeDevice order by createdDate desc ];
            session=[select UsernameS__c, PasswordS__c, UserAgent__c, HashKey__c, CreatedDate, IdDevice__c, TypeDevice__c, LastLogin__c, login__c from Session__c where login__c != NULL and UsernameS__c=:username and PasswordS__c=:password and UserAgent__c=:userAgent and TypeDevice__c=: TypeDevice order by createdDate desc]; 
            
            if (session.size() !=0 ){
                System.debug('SESSION IDDEVICE: ' +  session[0].IdDevice__c);
                System.debug('SESSION TYPEDEVICE: ' +  session[0].TypeDevice__c);
                System.debug('SESSION USERNAME: ' +  session[0].UsernameS__c);
                System.debug('SESSION PASSWORD: ' +  session[0].PasswordS__c);
                System.debug('SESSION USERAGENT: ' + session[0].UserAgent__c);
                /*if(Test.isRunningTest())
                {
                    sessionDateCreated='2016012115291200';
                }
                else
                {*/
                    year = String.valueOf(session[0].CreatedDate).SubString(0,4);
                    month = String.valueOf(session[0].CreatedDate).SubString(5,7); 
                    day = String.valueOf(session[0].CreatedDate).SubString(8,10);
                    hour = String.valueOf(session[0].CreatedDate).SubString(11,13);
                    minute = String.valueOf(session[0].CreatedDate).SubString(14,16);
                    second = String.valueOf(session[0].CreatedDate).SubString(17,19);
                    sessionDateCreated = year+month+day+hour+minute+second+'00';
                //}
                
                Blob cryptoKey = Blob.valueOf(session[0].HashKey__c);//hashkey para o metodo decrypt
                Blob initializationVector = Blob.valueOf(sessionDateCreated);//InitializationvVector desincriptar
                Blob encryptedData = EncodingUtil.base64Decode(username);
                
                //criar um blob com o username que recebemos do localstorage
                
                Blob decrypted = Crypto.decrypt('AES256', cryptoKey, initializationVector, encryptedData);
                
                String decryptedUsername = decrypted.toString();//Login do localStorage desincriptado.
                System.debug('decryptedUsername: ' + decryptedUsername);
                
                
                //criar um blob com a password que recebemos do localstorage
                encryptedData = EncodingUtil.base64Decode(password);
                decrypted = Crypto.decrypt('AES256', cryptoKey, initializationVector, encryptedData);
                String decryptedPassword = decrypted.toString();//Login do localStorage desincriptado.
                
                //System.debug('decryptedPassword: ' + decryptedPassword);
                
                //return authentication(decryptedUsername, decryptedPassword, userAgent);//não posso user este metodo porque vai criar uma nova sessao.
                Login__c tmpLogin = new Login__c();
                String loginDateCreated ='';
                
                tmpLogin = [select HashKey__c, CreatedDate, Username__c, Password__c, NewHash__c from Login__c where username__c=:decryptedUsername];
                DateTime TempCreatedDate = tmpLogin.CreatedDate;
                
                DateTime MarsDate = DateTime.newInstance(2016, 3, 28, 1, 0, 0) ; 
                DateTime OctoberDate = DateTime.newInstance(2016, 10, 30);
                
                if(TempCreatedDate > MarsDate && TempCreatedDate < OctoberDate ){
                    TempCreatedDate = tmpLogin.CreatedDate.addHours(+1);
                }
                
                year = String.valueOf(TempCreatedDate).SubString(0,4);
                month = String.valueOf(TempCreatedDate).SubString(5,7);
                day = String.valueOf(TempCreatedDate).SubString(8,10);
                hour = String.valueOf(TempCreatedDate).SubString(11,13);
                minute = String.valueOf(TempCreatedDate).SubString(14,16);
                second = String.valueOf(TempCreatedDate).SubString(17,19);
                loginDateCreated = year+month+day+hour+minute+second+'00';

                if(tmpLogin.NewHash__c){
                    loginDateCreated =  tmpLogin.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00';
                }
                
                cryptoKey = Blob.valueOf(tmpLogin.HashKey__c);
                initializationVector = Blob.valueOf(loginDateCreated);
                Blob data = Blob.valueOf(decryptedPassword);
                encryptedData = Crypto.encrypt('AES256', cryptoKey, initializationVector, data);
                String encryptedDataString = EncodingUtil.base64Encode(encryptedData);
                
                System.debug('encryptedDataString: ' + encryptedDataString);
                
                newlogin = [select Id, Username__c, Vendor_NIF__C, email__c, Password__c, IdVendor__c, New_Site__c, NewHash__c 
                            from Login__c 
                            Where username__c =:decryptedUsername and password__c=:encryptedDataString];
                
                if(session[0].IdDevice__c == IdDevice && session[0].TypeDevice__c== TypeDevice || session[0].IdDevice__c == null && session[0].TypeDevice__c== null){
                    
                    Date today = Date.today();
                    session[0].LastLogin__c=today;
                    newLogin.Username__c=session[0].UsernameS__c; //posição 0 é a posição que contém o login ecriptado da sessão.
                    newLogin.Password__c=session[0].PasswordS__c;
                    
                    System.debug('newlogin: ' + newLogin);
                    update session;
                    return newlogin;
                }
                else{
                    if(session[0].IdDevice__c != IdDevice && session[0].TypeDevice__c== TypeDevice){
                        List<String> lst = Authenticate.createSessionEncription(decryptedUsername, decryptedPassword, userAgent, IdDevice, TypeDevice, newlogin);
                        newLogin.Username__c=lst[0]; //posição 0 é a posição que contém o login ecriptado da sessão.
                        newLogin.Password__c=lst[1]; //posição 1 é a posição que contém a password encriptada da sessão.
                        
                        System.debug('[AuthenticateAuto]lst[0]: ' + lst[0] );
                        System.debug('[AuthenticateAuto]lst[1]: ' + lst[1] );
                        System.debug('[AuthenticateAuto]newLogin.Username__c: ' + newLogin.Username__c );
                        System.debug('[AuthenticateAuto]newLogin.Password__c: ' + newLogin.Password__c );
                        
                        System.debug('CREATE NEW SESSION!');
                        // upsert(session);

                        //TRANSIÇÂO PARA NOVO LOGIN
                          if(tmpLogin.NewHash__c){
                            Session__c s =  Transition(lst[0], lst[1], UserAgent,  IdDevice,  TypeDevice);
                            Session__c newSession = [SELECT UsernameS__c, PasswordS__c FROM Session__c where id =: s.Id];
                            newLogin.Username__c=newSession.UsernameS__c;
                            newLogin.Password__c=newSession.PasswordS__c;
                        }
                       /////////////////////


                        return newlogin;                      
                    }
                    else{
                        return newlogin;
                    }
                }
            }
            else {
                return newlogin;
            }
            
        }
        catch (QueryException  e)
        {
            System.Debug('Error *** Login authenticationAuto failed!');
            system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return null;
        }
    }
    
    
   	@RemoteAction
	public static Login__c authentication(String username, String password, String userAgent, String IdDevice, String TypeDevice)
    {
		Login__c newlogin = new Login__c();
        Login__c tmpLogin =new Login__c(); 
        try
        {

            tmpLogin = [select HashKey__c, NewHash__c, CreatedDate, Username__c, Password__c from Login__c where username__c=:username];    
            
            Blob cryptoKey = Blob.valueOf(tmpLogin.HashKey__c);

            String loginDateCreated ='';
            DateTime TempCreatedDate = tmpLogin.CreatedDate;
            DateTime MarsDate = DateTime.newInstance(2016, 3, 28, 1, 0, 0) ; 
            DateTime OctoberDate = DateTime.newInstance(2016, 10, 30);
            
            if(TempCreatedDate > MarsDate && TempCreatedDate < OctoberDate ){
                TempCreatedDate = tmpLogin.CreatedDate.addHours(+1);
            }
            
            String year = String.valueOf(TempCreatedDate).SubString(0,4); String month = String.valueOf(TempCreatedDate).SubString(5,7);
            String day = String.valueOf(TempCreatedDate).SubString(8,10); String hour = String.valueOf(TempCreatedDate).SubString(11,13);
            String minute = String.valueOf(TempCreatedDate).SubString(14,16); String second = String.valueOf(TempCreatedDate).SubString(17,19);
            loginDateCreated = year+month+day+hour+minute+second+'00';

            if(tmpLogin.NewHash__c){
                loginDateCreated =  tmpLogin.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00';
            }

            Blob exeIV = Blob.valueOf(loginDateCreated);
            Blob data = Blob.valueOf(password);
            Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, exeIV, data);
            String encryptedDataString = EncodingUtil.base64Encode(encryptedData);
            try
            {
                newlogin = [select Id, Username__c, Vendor_NIF__C, email__c, Password__c, IdVendor__c, NewHash__c, CreatedDate from Login__c Where username__c =:username and password__c=:encryptedDataString];    
            }
            catch (Exception  e)
            {
				System.Debug('Error quering newlogin *** Login authentication failed!');
				system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            }
            
            if (newlogin != null) // se for diferente de null, vai ser criado um novo registo na tabela session. 
            {
                List<String> lst = Authenticate.createSessionEncription(username, password, userAgent, IdDevice, TypeDevice, newlogin);
                newLogin.Username__c=lst[0]; //posição 0 é a posição que contém o login ecriptado da sessão.
                newLogin.Password__c=lst[1]; //posição 1 é a posição que contém a password encriptada da sessão.
            }
            //system.debug('Passo:4');
            return newlogin;
        }
        catch(NullPointerException e)
        {
            System.Debug('Error Authenticate *** Login authentication failed!');
            system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return newlogin;
    	}
        
	}
    
    @RemoteAction
    public static void changePassword(String newPassword, String idLogin)
    {
        Login__c chgLogin = new Login__c();
        chgLogin=[select id, HashKey__c, CreatedDate from login__c where id=:idLogin];
        
        system.debug(chgLogin);
        
        Blob cryptoKey = Blob.valueOf(chgLogin.HashKey__c);
        String loginDateCreated ='';
        if(test.isRunningTest()) 
        {
            loginDateCreated='2016012113494200';
        }
        else
        {
            String year = String.valueOf(chgLogin.CreatedDate).SubString(0,4);
            String month = String.valueOf(chgLogin.CreatedDate).SubString(5,7);
            String day = String.valueOf(chgLogin.CreatedDate).SubString(8,10);
            String hour = String.valueOf(chgLogin.CreatedDate).SubString(11,13);
            String minute = String.valueOf(chgLogin.CreatedDate).SubString(14,16);
            String second = String.valueOf(chgLogin.CreatedDate).SubString(17,19);
            loginDateCreated = year+month+day+hour+minute+second+'00';
        }
        
        
        Blob exeIV = Blob.valueOf(loginDateCreated);
        Blob data = Blob.valueOf(newPassword);
        Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, exeIV, data);
        String encryptedDataString = EncodingUtil.base64Encode(encryptedData);
        system.debug(encryptedDataString);
        
        chgLogin.Password__c = encryptedDataString;
        chgLogin.email_psw__c='';
        update (chgLogin);

    }

    public static List<String> createSessionEncription(String u, String p, String ua, String IdDevice, String TypeDevice, Login__c login)//este metodo é privado, uma vez que só vai ser acedido pela metodo authentication. Fazer o registo da password e username encriptados para o localStorage/Cookies
    {
        List<String> lst = new List<String>();
        Blob cryptoKey = Crypto.generateAesKey(192);
        String hashkey = EncodingUtil.base64Encode(cryptoKey);
        cryptoKey = Blob.valueOf(hashkey);
        Date today = Date.today();
        Session__c session = new Session__c(HashKey__c=hashkey, UserAgent__c=ua, IdDevice__c=IdDevice, TypeDevice__c=TypeDevice, LastLogin__c=today, Login__c=login.Id);
        upsert(session);
        session = [select UsernameS__c, PasswordS__c, HashKey__c, UserAgent__c, CreatedDate, IdDevice__c, TypeDevice__c from Session__c where Hashkey__c=:hashkey and UserAgent__c =:ua];
        String sessionDateCreated='';
        string year = String.valueOf(session.CreatedDate).SubString(0,4);
        String month = String.valueOf(session.CreatedDate).SubString(5,7);
        String day = String.valueOf(session.CreatedDate).SubString(8,10);
        String hour = String.valueOf(session.CreatedDate).SubString(11,13);
        String minute = String.valueOf(session.CreatedDate).SubString(14,16);
        String second = String.valueOf(session.CreatedDate).SubString(17,19);
        sessionDateCreated=year+month+day+hour+minute+second+'00';

        if(login.NewHash__c){
            sessionDateCreated =  session.Createddate.formatGMT('YYYYMMddHHmmss') + '00';
        }
        
        Blob exeIV = Blob.valueOf(sessionDateCreated);
        Blob data = Blob.valueOf(u);
        Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, exeIV, data);
        String encryptedUserString = EncodingUtil.base64Encode(encryptedData);
        data = Blob.valueOf(p);
        encryptedData = Crypto.encrypt('AES256', cryptoKey, exeIV, data);
        String encryptedPassString = EncodingUtil.base64Encode(encryptedData);
        
		session.UsernameS__c=encryptedUserString;
        session.PasswordS__c=encryptedPassString;
        
        upsert(session);
        lst.add(session.UsernameS__c);
        lst.add(session.PasswordS__c);
        return lst;
    }
    
    
    webservice static void generatorPassword(String login_id, Integer passLength)
	{
		String charSet ='EFGHIJKLMfghijklnopqrstuvwxyzA3456BabcdeCDNOPQRSTUVWXYZ012789$?_!%';
		String newPassword = '';
		for (Integer i=0; i<passLength; i++)
		{
			Double num = Math.Floor(Math.random()*(charSet.length()-1));
			Integer numInt = num.intValue();
			newPassword=newPassword+getCharFromString(charSet, numInt);
		}
        try
        {
            Login__c login_gen_pwd = new Login__c();
	        login_gen_pwd = [select id, username__c, createdDate, Email__c, user__c from Login__c where Id =:login_id];
            login_gen_pwd.password__c = newPassword;
            login_gen_pwd.username__c=login_gen_pwd.user__c;
            login_gen_pwd.Email__c=login_gen_pwd.user__c;
            login_gen_pwd.email_psw__c='';
            Blob data = Blob.valueOf(newPassword);
            
            Blob cryptoKey = Crypto.generateAesKey(192);
            String hashkey = EncodingUtil.base64Encode(cryptoKey);
            login_gen_pwd.HashKey__c=hashkey;
            cryptoKey = Blob.valueOf(hashkey);
            String loginDateCreated='';
            String year = String.valueOf(login_gen_pwd.CreatedDate).SubString(0,4);
            String month = String.valueOf(login_gen_pwd.CreatedDate).SubString(5,7);
            String day = String.valueOf(login_gen_pwd.CreatedDate).SubString(8,10);
            String hour = String.valueOf(login_gen_pwd.CreatedDate).SubString(11,13);
            String minute = String.valueOf(login_gen_pwd.CreatedDate).SubString(14,16);
            String second = String.valueOf(login_gen_pwd.CreatedDate).SubString(17,19);
            loginDateCreated=year+month+day+hour+minute+second+'00';
            
            Blob exeIV = Blob.valueOf(loginDateCreated);
            
            Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, exeIV, data);
            String encryptedDataString = EncodingUtil.base64Encode(encryptedData);
            login_gen_pwd.Password__c=encryptedDataString;
            login_gen_pwd.email_psw__c=Crypto.decrypt('AES256', cryptoKey, exeIV, encryptedData).toString();
            upsert(login_gen_pwd);	
      
          /*  String[] toAddresses = new List<String>();
            toAddresses.add(login_gen_pwd.Email__c);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Envio de password');
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('A sua password para aceder à app da Candor é: '+newPassword);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});*/
        }
         catch (Exception e)
        {
            System.Debug('Error in Authentication - generator password!');
            system.Debug('Authentication' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
        } 
	}
    
    private static String getCharFromString (String str, Integer poss)
	{
		String result='';
		if (poss<str.length() && str!= '')
		{
			result=str.substring(poss, poss+1);
		}
		return result;
	}

    private static Session__c Transition (String encryptUsername, String encryptPassword,String UserAgent, String IdDevice, String TypeDevice){
    
        session__c session = [SELECT ID, usernameS__c,HashKey__c, passwordS__c,CreatedDate, login__c, Login__r.ID FROM Session__c WHERE usernameS__c=:encryptUsername AND passwordS__c=:encryptPassword];

        String loginID = session.Login__r.ID;
        String sessionDateCreated = session.CreatedDate.formatGmt('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
        String decryptedSessionUsername = CandorAuthorization.decryptString(session.HashKey__c, sessionDateCreated, session.UsernameS__c);
        String decryptedSessionPassword = CandorAuthorization.decryptString(session.HashKey__c, sessionDateCreated, session.PasswordS__c);
        
        session.UsernameS__c = CandorAuthorization.encryptString(session.HashKey__c, sessionDateCreated, decryptedSessionUsername);
        session.PasswordS__c = CandorAuthorization.encryptString(session.HashKey__c, sessionDateCreated, decryptedSessionPassword);

        update session;

        return session;    

    }
    
    @InvocableMethod
    global Static void ClearOldSessions()
    {
        List<AggregateResult> sessions = [select IdDevice__c D from Session__c where IdDevice__c != '' group by IdDevice__c having count(IdDevice__c)>1];
        Session__c del = new Session__c();
        for (AggregateResult ar : sessions)  
        {
            del=[select Id from Session__c where IdDevice__c=:String.valueOf(ar.get('D')) order by CreatedDate asc limit 1];
            delete del;
        }       
    }
    
    @RemoteAction
    public static void retrievePassword(String username)
    {
           String[] toAddresses = new List<String>();
            toAddresses.add('info@candor.pt');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Solicitação de nova password!');
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('O user: '+ username + ' solicitou uma nova password. ');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}