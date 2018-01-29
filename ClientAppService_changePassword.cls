public class ClientAppService_changePassword extends ClientAppService{

    
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        
        if(!args.containsKey('newPass')){
            toReturn.put('status', 'ERROR');
            toReturn.put('errorMessage', 'NO_NEW_PASS');
        }
        
        Session__c session = [SELECT Login__c
        FROM Session__c
        WHERE token__c = :sessiontoken
        ORDER BY CreatedDate LIMIT 1];
        
        Login__c userLogin = [SELECT email_psw__c, Password__c, CreatedDate, HashKey__c
                              FROM Login__c
                              WHERE Id = :session.Login__c];
        
        String newPass = (String)args.get('newPass');
        String iv = userLogin.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00';
        String hashKey = userLogin.HashKey__c;
    	String encrypted_pass = encryptString(newPass, iv, hashKey);
        
        userLogin.Password__c = encrypted_pass;
        userLogin.email_psw__c = newPass;
        update userLogin;
        
        return toReturn;
    }
    
    //this should be in some helper crypto class
    private static String encryptString(String dataToEncrypt, String initializationVector, String HashKey){
        Blob blobCryptoKey = Blob.valueOf(HashKey);//hashkey para o metodo decrypt
        Blob blobInitializationVector = Blob.valueOf(initializationVector);//InitializationvVector desincriptar
        Blob blobData = Blob.valueOf(dataToEncrypt);
        Blob blobEncryptedData =  Crypto.encrypt('AES256', blobCryptoKey, blobInitializationVector, blobData);
        return EncodingUtil.base64Encode(blobEncryptedData);
    }
    
}