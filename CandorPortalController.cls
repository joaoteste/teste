public class CandorPortalController {

    private final static boolean LOGS = true;
    public static String factorCards {
            get{
                List<DecisionWrapper.FactorWrapper> factorList =  DecisionWrapper.getAllFactorCards();
                return JSON.serialize(factorList);
            }
            set;
        }

    public boolean isSDBX {
        get{return [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;} 
        set;
    }
    public PageReference index  {get;set;}
    public String currentLanguage {get{return 'pt_BR';} set;}

    public CandorPortalController(){
        this.index = ApexPages.currentPage();
    }
 
    public PageReference Autho(){ 
         
        try{

            Map<String,System.Cookie> cookies =  index.getCookies();
            Cookie cdrS =  cookies.get('cdrS'); // cookie com o session ID
            Cookie cdrtk =  cookies.get('cdrtk');// cookie com o token da sessão
            Cookie cdrUsrlang = cookies.get('cdrUsrlang'); // cookie com a language do user


            String IdDevice = index.getParameters().get('Id');    
            String TypeDevice = index.getParameters().get('type');

            String userAgent = index.getHeaders().get('User-Agent');
            Integer maxAge = 999999999;
            
            String urlSessionToken = (index.getParameters().get('sessionToken') != null) ? index.getParameters().get('sessionToken').replaceAll(' ', '+') : '';
            Cookie cdrUsr = null;
            
            system.debug('ZZZZZ sessionToken '+urlSessionToken);
            SiteAuthentication auth = new Siteauthentication();
            boolean isAuth = auth.validateSession(urlSessionToken);
            System.debug('[CandorPortalController - Autho()]  isAuth = ' + isAuth);
            if(isAuth){// go to App
                clearSessionCookies(index);
                
                Session__c session = [SELECT Id, Login__r.Language__c, Login__r.Username__c, Login__r.email_psw__c
                FROM Session__c
                WHERE token__c = :urlSessionToken
                ORDER BY CreatedDate LIMIT 1];
                
                system.debug('ZZZZ session '+session);
                
                CandorAuthorization authorization = Vendor.login(session.Login__r.Username__c, session.Login__r.email_psw__c, false, '', '', '');
                
                if(session.Login__r.Language__c == null){
                    session.Login__r.Language__c ='pt_BR';
                    update session;
                }
                
                cdrS = new Cookie('cdrS', authorization.getSessionID(), null , null , false);
                cdrtk = new Cookie('cdrtk', authorization.getToken(), null , null , false);
                cdrUsr = new Cookie('cdrUsr', JSON.serialize(authorization.getUserInfo(), true), null , maxAge , false);
                cdrUsrlang = new Cookie('cdrUsrlang', session.Login__r.Language__c, null, null, false);
                index.setCookies(new Cookie[]{cdrS, cdrtk, cdrUsr, cdrUsrlang});  
                
                system.debug('ZZZZZ cookies '+cdrUsrlang);
                
                return null;

            }else if(index.getParameters().get('sessionToken') != null){

                clearSessionCookies(index);
                //Descomentar quando todos os logins forem feitos a partir do portal de cliente
                //PageReference cliente = new PageReference('/cliente');
                //return cliente;
                return null;
            
            }

            if(cdrUsrlang == null){
                currentLanguage= 'pt_BR';  
            }
            else {
                currentLanguage=  cdrUsrlang.getValue();  
            }

            if(Test.isRunningTest()){
                cdrS = new Cookie('apex_cdrS','a069E000000xu2zQAA',null,999999,false);
                cdrtk = new Cookie('apex_cdrtk','GmDS9zt3c61boRsIjYD9C6UcDf8fO18v',null,999999,false);
                cdrUsrlang =new Cookie('cdrUsrlang', 'pt_BR', null, null, false);
            }

            if(cdrS!=NULL && cdrtk!=NULL){                

                String sessionID = cdrS.getValue().substringBetween('"'); 
                String sessionToken = cdrtk.getValue().substringBetween('"');

                //if string from cookies doesnt have char " -> get direct value
                if(sessionID==null){sessionID = cdrS.getValue();}
                if(sessionToken==null){sessionToken = cdrtk.getValue();}

                CandorAuthorization authorization = new CandorAuthorization(sessionID, sessionToken, UserAgent, IdDevice, TypeDevice);
                boolean sessionIsValid = authorization.isValid();
                boolean remember;
                Login__c userInfo = authorization.getUserInfo();

                if(userInfo!=null){
                    remember = userInfo.Remember_me__c;
                }else{
                    remember = false;
                }
                //System.debug('[CandorPortalController - Autho()] authorization is valid? ' + sessionIsValid);

                if(Test.isRunningTest()){
                    sessionIsValid = true;
                }

                if(sessionIsValid){
                    //System.debug('[CandorPortalController - Autho()]  SUCCESSFUL LOGIN AUTHORIZATION.');
                     //se selecionar não gravar acesso o tempo do cookie é apenas o de sessão; 
                    if(!remember){
                        maxAge = null;
                        System.debug('[CandorPortalController - Autho()]  Not remember was selected.');
                    }
                    cdrS = new Cookie('cdrS', authorization.getSessionID(), null , maxAge , false);
                    cdrtk = new Cookie('cdrtk', authorization.getToken(), null , maxAge , false);
                    cdrUsr = new Cookie('cdrUsr', JSON.serialize(authorization.getUserInfo(), true), null , maxAge , false);//cookie com Login info
                    cdrUsrlang =new Cookie('cdrUsrlang', currentLanguage , null, null, false);
                    index.setCookies(new Cookie[]{cdrS, cdrtk, cdrUsr, cdrUsrlang});    
                    //System.debug('[CandorPortalController - Autho()]  Vendor Info: ' + authorization.getUserInfo());
                    return null;
                }else{
                    clearSessionCookies(index);
                    //Utilities.LogIntegration(datetime.now(), datetime.now(), 'ERRO', 'LOGIN', 'Sessão invalida', 'teste');
                    return null;
                }
            }else{
                //Utilities.LogIntegration(datetime.now(), datetime.now(), 'ERRO', 'LOGIN','SEM Cookies', 'teste');
               return null;   
            }
        }catch(Exception e){
            System.Debug('[CandorPortalController - Autho()] Error *** Authorization');
            system.Debug('[CandorPortalController - Autho()] ' + e.getMessage() + ' - ' + e.getStackTraceString());
            clearSessionCookies(index);
            //Utilities.LogIntegration(datetime.now(), datetime.now(), 'ERRO', 'LOGIN', e.getMessage() + ' - ' + e.getStackTraceString(), 'teste');
            return null;
        } 
    }

    @TestVisible
    private void clearSessionCookies(PageReference currentPage){
        Cookie cdrtk = new Cookie('cdrtk', '', null, 0 , false);
        Cookie cdrS = new Cookie('cdrS', '' , null , 0 , false);
        Cookie cdrUsr = new Cookie('cdrUsr', '', null , 0 , false);
        currentPage.setCookies(new Cookie[]{cdrtk, cdrS, cdrUsr});
    }    

    @RemoteAction
    public static Result validateSession(String sessionID, String sessionToken,  String userAgent, String idDevice, String typeDevice){

        Result result = new Result();

        try{

            CandorAuthorization auth = new CandorAuthorization(sessionID, sessionToken, userAgent, idDevice, typeDevice);

            if(auth.isValid()){
                result.status = true;
                result.info = auth.getToken();
            }else{
                result.status = false;
                result.error = auth.getErrorMsg();
            }

            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[validateSession] ERROR: session ID: '+sessionID+' sessionToken: '+sessionToken+' userAgent: '+userAgent+' idDevice: '+idDevice+' typeDevice: '+typeDevice); 
            return result;
        }
    }

    @RemoteAction
    public static Result isSessionValid(String sessionID, String sessionToken){

        Result result = new Result();
 
        try{

            result.status = CandorAuthorization.isSessionValid(sessionID, sessionToken);
            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[isSessionValid] ERROR: session ID: '+sessionID+' sessionToken: '+sessionToken); 
            return result;
        }
    }

    @RemoteAction
    public static Result changeLoginInfo(Login__c login, Contact contact){

        Result result = new Result();

        try{
            
            update login;

            if(contact.Id!=null){
                candorPortalController.saveVendorContact(contact, login.Id, null);
                //update contact;         
            }

            result.status= true;
            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[changeLoginInfo] ERROR: login: '+login+' contact: '+contact); 
            return result;
        }

    }

    @RemoteAction
    public static Result deleteLoginInfo(Login__c loginDeleter, Login__c loginToDelete)
    {
        Result result = new Result();
        
        Vendor v = new Vendor(loginDeleter.Id);
        result.status = v.eraseORinactivateLogin(loginToDelete.Id,'erase');
        return result;  
    }

    //(HP) 02/03/2017 - Módulo de seguro retirado
    /*@RemoteAction 
    public static Result setInsuranceType(Id appID, String ChosenInsuranceType){

        Result result = new Result();

        try{
            RentingApplication ra = new RentingApplication(appID);
            result.status = ra.setInsuranceType(ChosenInsuranceType);

            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            return result;
        }
    }*/





    @RemoteAction
    public static Result changePassword (String username, String oldPassword, String newPassword, boolean remember){

         Result result = new Result();

        try{

            CandorAuthorization auth = Vendor.login(username, oldPassword, remember, null, null, null);

            if(auth.isValid()){
                auth.changePassword(newPassword);
                auth = Vendor.login(username, newPassword, remember, null, null, null);
                result.Id = auth.getSessionID();
                result.info = auth.getToken();
                result.login = auth.getUserInfo();
                result.status = true; 
            }else{
                result.status = false; 
                result.error = auth.getErrorMsg();
            }

            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[changePassword] ERROR: username: '+username + ' remember: '+remember); 
            return result;
        }
    }    

    @RemoteAction
    public static Result authentication(String username, String password, boolean remember, String userAgent, String idDevice, String typeDevice){
        
        String loginDateCreated=''; 
        Result result = new Result(); 

        try{

            CandorAuthorization auth = new CandorAuthorization();
            auth = Vendor.login(username, password, remember, userAgent, idDevice, typeDevice);

            if(auth.isValid()){
                result.Id = auth.getSessionID();
                result.info = auth.getToken();
                result.login = auth.getUserInfo();
                result.status = true;
            }else{
                result.status = false;
                result.error = auth.getErrorMsg();
            }

        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            //result.writeLog('[authentication] ERROR: username: '+username + ' remember: '+remember+' userAgent: '+userAgent+' idDevice: '+idDevice+' typeDevice: '+typeDevice); 
            return result;

        }

        return result;
    }

    @RemoteAction
    public static Result getVendorInfo(Id vendorloginId){

        Result result = new Result();  

        try{

            Vendor v = new Vendor(vendorLoginID);
            result.acc = v.getVendorInfo();
            result.logo = v.getLogo();//Id do attachment apenas
            c2g__codaTaxRate__c[] taxList = [SELECT c2g__Rate__c FROM c2g__codaTaxRate__c WHERE c2g__TaxCode__c=:result.acc.c2g__CODAOutputVATCode__c LIMIT 1];
            if(taxList.size()>0){
                result.tax = taxList[0].c2g__Rate__c;
            }
            result.status=true;
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getVendorInfo] ERROR: vendorLogin ID: '+vendorLoginID); 
            return result;

        }
    }

    @RemoteAction
    public static Result getLogo(Id vendorLoginID){
        //falta acabar aafl
        Result result = new Result();

        try{
            Vendor v = new Vendor(vendorLoginID);
            result.logo = v.getLogo(); //string do path espetacular
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status = false;
            result.writeLog('[getLogo] ERROR: vendorLogin ID: '+vendorLoginID);
        }
        return result;
    }   
    
    @RemoteAction
    public static Result getVendorClients(Id vendorLoginID){

        Result result = new Result();

        try{

            Vendor v = new Vendor(vendorLoginID);
            // result.accounts = v.getClients();
            result.accountsWr = new AccountWrapper.ListOfAccountWrapper(v.getClients());
            result.applications = v.getApps();
            result.scoreCards = v.getInfoScores();
            result.status = true;
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
             result.status=false;
            result.writeLog('[getVendorClients] ERROR: vendorLogin ID: '+vendorLoginID); 
            return result;

        }
    }   

    @RemoteAction
    public static Result getVendorClientsApprovedApps(ID clientID, Id vendorLoginID){

        Result result = new Result();

        try{
            
            Vendor v = new Vendor(vendorLoginID);
            result.applications = v.getApprovedApps(clientID);
            result.status=true;
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getVendorClientsApprovedApps] ERROR: vendorLogin ID: '+vendorLoginID+' client ID: '+clientID); 
            return result;

        }

    }

    @RemoteAction
    public static Result getVendorContractApps(Id vendorLoginID){

        Result result = new Result();

        try{
            
            Vendor v = new Vendor(vendorLoginID);
            result.applications = v.getContractApps();
            result.status=true;
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getVendorContractApps] ERROR: vendorLogin ID: '+vendorLoginID); 
            return result;

        }

    }    

    @RemoteAction
    public static Result updateVendorAccountInfo(ID vendorLoginID, Account vendorAccount){
        
        Result result = new Result();

        try{

            Vendor v = new Vendor(vendorLoginID);
            String res = v.updateVendorAccountInfo(vendorAccount);

            if(res == 'OK'){
                result.status=true;
            }else{
                result.status=false;
                result.error='Wrong login ID'; 
            }
            
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[updateVendorAccountInfo] ERROR: vendorLogin ID: '+vendorLoginID+' vendorAccount: '+vendorAccount); 
            return result;

        }
    
    }

    @RemoteAction
    public static Result addNewLogin(Contact contact, Id loginID, boolean Inactive){

        Result result = new Result();

        try{
            
            Vendor v = new Vendor(LoginID);

            if(contact.Name != null){
                
                String[] name = contact.Name.split(' ', 2); 

                if(name.size() == 1){
                    result.status = false;
                    result.error = 'INSERT_TWO_NAMES';
                    return result;
                    //contact.LastName = name[0]; 
                }else{
                    contact.FirstName = name[0];    
                    contact.LastName = name[1];  
                }                   
            }

            contact.AccountId = [SELECT IdVendor__c FROM Login__c WHERE Id=:loginID].IdVendor__c;

            String res = v.saveNewLogin(contact);
            
            //Define se na criação o login se encontra inactivo ou nao
            if(Inactive==true){
                Login__c l = new Login__c(Id=res, Inactive__c = true);
                update l;
            }

            if(res=='IS_NOT_MASTER'){
                result.status=false;
                result.error=res;
            }else{
                result.status=true;
                result.Id=res;
            }
            
            return result;
            
        }catch(exception e){
            System.debug( e.getDmlType(0).name());
            System.debug(e.getTypeName());
            if(e.getTypeName() == 'System.DmlException'){
                result.error = e.getDmlType(0).name() +' - '+ e.getMessage();
                result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            }else{
                result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            }
            
            result.status=false;
            result.writeLog('[addNewLogin] ERROR: contact: '+contact+' Login ID: '+loginID+' Inactive: '+Inactive); 
            //Utilities.LogIntegrationLongResponse(Datetime.now(), Datetime.now(), 'ERRO', 'Change Username', '', loginID, result.error);
            return result;
        } 
    }


    @RemoteAction
    public static Result saveVendorContact(Contact contact, Id loginID, Id sessionID){
        
        Result result = new Result();

        try{
            
            Vendor v = new Vendor(LoginID);
            String res = v.saveVendorContact(contact, sessionID);

            if(res=='OK'){
                result.status=true;
            }else{
                result.status=false;
                result.error='Empty contact Id';
            }
            
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[saveVendorContact] ERROR: contact: '+contact+' Login ID: '+loginID+' session ID: '+sessionID); 
            return result;
        } 
    }

    @RemoteAction
    public static Result uploadInvoice(String vendorLoginID, String attachmentBody , ID appID, String attachmentId){

        Result result = new Result();

        try{

            Vendor v = new Vendor(vendorLoginID);
            String res = v.uploadInvoice(attachmentBody, appID,attachmentId);

            if(res != 'BODY_NULL'){
                Vendor_Invoice__c vi = RentingApplication.getVendorInvoice(appID);
                result.obj = vi;
              
                
                List<Attachment> attchid = [SELECT ID FROM Attachment WHERE ParentID=:vi.Id Order by Createddate desc LIMIT 1];
                if(attchid.size()>0){
                    result.Id = attchid[0].id;
                }
                
                result.status=true;
                result.Id = res;
				System.enqueueJob(new Queueable_ProcPayableInvoices(appID, true));
                
            }else{
                result.status=false;
                result.error='Error occurred while uploading Invoice'; 
            }
            
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[uploadInvoice] ERROR: application ID: '+appID+' vendorLogin ID: '+vendorLoginID+' attachmentBody: '+attachmentBody+' attachment Id: '+attachmentId); 
            return result;

        }
    }

    @RemoteAction
    public static Result cancelInvoice(String vendorLoginID, String vendorInvoiceID){

        Result result = new Result();

        try{

            Vendor v = new Vendor(vendorLoginID);
            String res = v.cancelInvoice(vendorInvoiceID);

            if(res == 'OK'){
                result.status=true;
            }else{
                result.status = false;
                result.error = res;
            }
            
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[cancelInvoice] ERROR: vendor invoice ID: '+vendorInvoiceID+' vendorLogin ID: '+vendorLoginID); 
            return result;

        }
    } 

    @RemoteAction
    public static Result uploadLogo(String vendorLoginID, String attachmentBody , ID appID, String attachmentId){

        Result result = new Result();

        try{

            Vendor v = new Vendor(vendorLoginID);
            String res = v.uploadLogo(attachmentBody, appID,attachmentId);

            if(res != 'BODY_NULL'){
                Account vi = RentingApplication.getAccount(appID);
                result.obj = vi;
                List<Attachment> attchid = [SELECT ID FROM Attachment WHERE ParentID=:vi.Id Order by Createddate desc LIMIT 1];
                if(attchid.size()>0){
                    result.Id = attchid[0].id;
                }
                result.status=true;
                result.Id = res;
                vi.Company_Logo_Id__c = result.Id;
                update vi; 
            }else{
                result.status=false;
                result.error='Error occurred while uploading Invoice'; 
            }
            
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[uploadLogo] ERROR: application ID: '+appID+' vendorLoginID: '+vendorLoginID+' attachmentBody: '+attachmentBody+' attachmentId: '+attachmentId); 
            return result;

        }
    }

    /*@RemoteAction
    public static Result uploadAttch(String AttachParentID, String attachmentBody , String attachmentId, String attName){

        Result result = new Result();

        try{

            if(attachmentBody  != null){

                list<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE Id =: attachmentId];
                
                Attachment att = new Attachment();
                if(!attachments.isEmpty()) {
                    att = attachments[0];
                } 
                    
                String newBody = '';
                if(att.Body != null) {
                    newBody = EncodingUtil.base64Encode(att.Body);
                }
                newBody += attachmentBody;
                att.Body = EncodingUtil.base64Decode(newBody);
                if(attachmentId == null) {
                    att.Name = attName + ' - ' + AttachParentID;
                    att.parentId = AttachParentID;
                    att.IsPrivate = false;
                    //att.contentType = 'application/pdf';
                }
  
                result.status=true;
                result.Id = att.Id;          
            }else{
                result.status=false;
                result.error='Error occurred while uploading attachment'; 
            }
            
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            return result;

        }
    }*/

    @RemoteAction
    public static Result getVendorInvoice(String appID){

        Result result = new Result();

        try{

            result.obj = RentingApplication.getVendorInvoice(appID);
            result.status=true;
            
            return result;
            
        }catch(exception e){
            
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getVendorInvoice] ERROR: application ID: '+appID);  
            return result;

        }

    }


    @RemoteAction 
    public static Result recoverpw(String username){

        Result result = new Result();

        try{
            result.status = CandorAuthorization.resetPassword(username, true);

            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            //result.writeLog('[recoverpw] ERROR: username: '+username);  
            return result;
        }
    }



    @RemoteAction
    public static Result getAttachments(String appID){
        
        Result result = new Result();

        try{
            RentingApplication ra = new RentingApplication(appID);
            result.listSo = ra.getAttachments();
            result.status=true;
            
            return result;
            
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getAttachments] ERROR: application ID: '+appID);  
            return result;
        }
    }
    
    @RemoteAction
    public static Result updateVendorInvoice(String vendorInvoiceJSON){
        Result result = new Result();
        Vendor_Invoice__c vi = new  Vendor_Invoice__c();
        try{
            vi = (Vendor_Invoice__c)JSON.deserialize(vendorInvoiceJSON, Vendor_Invoice__c.class);
            //JG 28/12 - Vendor Invoice Date must be in the same year
            if( date.today().year() != vi.Invoice_Date__c.year() ){
                result.status=false;
                result.error='The uploaded invoice date must on the current year';
                result.writeLog('[updateVendorInvoice] ERROR: A vendor invoice was uploaded that did not match the current year');
                return result; 
            }
            //vi.Status__c = 'Completed';          
            update vi;
            //Update aos campos existentes na app. 
            //TODO: implementar trigger (caso estes campos se mantenham no objecto Application__c) 
            //para fazer set destes campos da applications__c quando vendor invoice set submitted__c = true;
            //Remover este código após trigger implementado (HP 2017/01) 
            Application__c app = new Application__c();
            app.Id = vi.Application__c;
            app.Issuing_Date_Invoice__c = vi.Invoice_Date__c;
            app.Vendor_Invoice_Amount__c = [SELECT Invoice_Net__c FROM Vendor_Invoice__c WHERE Id=:vi.Id].Invoice_Net__c;
            app.Invoice_Number__c = vi.Vendor_Invoice_Number__c;
            update app;
			
            String response = PayableInvoiceHandler.CreateAndPostPayableInvoice(vi.id, true);
		    System.debug(response);
            
            result.status=true;
            result.sObj = vi;
            return result;
            
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[updateVendorInvoice] ERROR: vendorInvoiceID: '+vi.Id);  
            return result;
        }
    }  

    /*@RemoteAction
    public static Result confirmVendorInvoice(String vendorInvoiceJSON, boolean postPayableInvoice){

        Result res = CandorPortalController.updateVendorInvoice(vendorInvoiceJSON);
        
        if(res.status){

            Vendor_Invoice__c vi = (Vendor_Invoice__c) res.sObj;
            List<Vendor_Invoice__c> viList = new List<Vendor_Invoice__c>{vi};
            PayableInvoiceHandler pih= new PayableInvoiceHandler();
            List<c2g__codaPurchaseInvoice__c> payableInvoiceList =  pih.createPayableInvoiceFromVendorInvoice(viList);
             c2g__codaPurchaseInvoice__c payableInvoice = new  c2g__codaPurchaseInvoice__c();
            if(payableInvoiceList!= null  && payableInvoiceList.size()>0 && postPayableInvoice){
                //Se post colocado a true faz POST das payable invoices e gera as transactions
                payableInvoice = payableInvoiceList[0];
                c2g.CODAAPICommon.Reference refPayableInvoice = new c2g.CODAAPICommon.Reference();
                refPayableInvoice.Id = payableInvoice.Id;  
                system.debug('[Queueable_ProcPayableInvoices] - journal ref ' + payableInvoice.id);
                c2g.CODAAPIPurchaseInvoice_6_0.PostPurchaseInvoice(null,refPayableInvoice);
            }

            Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'Success', 'VENDOR_INVOICE', payableInvoice.ID, vi.Id);
        }
        System.debug('[CandorPortalController - confirmVendorInvoice] -> ' + res);
        return res;
    }  */  

/*
    @RemoteAction
    public static Result getContractLink(ID appID){

        Result result = new Result();

        try{
            RentingApplication ra = new RentingApplication(appID);
            result.contractLink = CandorDocuments.getContractlink(appID);

            result.status=true;

            return result;

        }catch(exception e){    
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            return result;

        }       
    }*/
    //deprecated for the time being ########### :D


    @RemoteAction
    public static Result getApplication(ID appID, ID vendorLoginID){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            result.app = ra.getAppSObject();
            result.attchDownloads = ra.getAppAttachments();  //devolve um objecto 'CONTRATO_RENTING' e 'AUTO_ACEITACAO'
			if(result.attchDownloads.vendorInvoiceAttchDownload != null) result.attchDownloads.vendorInvoiceAttchDownload.Body = null;
            if(result.attchDownloads.contratoAttchDownload != null ) result.attchDownloads.contratoAttchDownload.Body = null;
            if(result.attchDownloads.autoAttchDownload != null ) result.attchDownloads.autoAttchDownload.Body = null;

            //Verifica se idlogin e valido para pedir esta aplicação
            if(result.app.IdLoginCreate__c != vendorLoginID) {
                Login__c [] loginList = [SELECT ID, Master__c, IdVendor__c FROM Login__c WHERE ID =: vendorLoginID];
                Login__c login = new Login__c();    
                if(loginList.size()>0){login = loginList[0];}
                result.error ='login: ' + login.Id + '; ' + login.Master__c + '; ' + login.IdVendor__c; 
                if(login.Master__c == false || login.IdVendor__c != result.app.IdLoginCreate__r.IdVendor__c){
                    result.status = false; 
                    result.error = 'UNAUTHORIZED_APP_ACCESS';
                    return result;
                }
            }

            //Verifica se a App esta cancelada
            if(result.app.Cancelled__c){
                result.status = false; 
                result.error = 'APP_CANCELLED';
                return result;
            }

            //Verifica se a App esta cancelada
            if(result.app.AccClient__r.Credit_Line_Status__c == 'Credit Line - Suspended'){
                result.status = false;
                result.error = 'ACCOUNT_SUSPENDED';
                result.writeLog('[getApplication] ERROR: application ID: ' + result.app.Id);
                return result;
            }
            
            result.contacts = ra.getContactsApp();
            result.signers = new Set<Id>{result.app.Client_Signer_1__c, result.app.Client_Signer_2__c, result.app.Client_Signer_3__c, result.app.Client_Signer_4__c, result.app.Client_Signer_5__c, result.app.Client_Signer_1_Delivery_Certificate__c};
            List<Id> rentingSigners = new list<Id>{result.app.Client_Signer_1__c, result.app.Client_Signer_2__c, result.app.Client_Signer_3__c, result.app.Client_Signer_4__c, result.app.Client_Signer_5__c};
            List<Id> autoSigner = new List<Id>{result.app.Client_Signer_1_Delivery_Certificate__c};
            result.signersMap = new Map<String, List<Id>>();
            result.signersMap.put('renting',rentingSigners);
            result.signersMap.put('auto',autoSigner);
            result.docusigninfo = ra.getDocuSignInfo();
            result.equipments = ra.getEquipments();
            result.contractLink = CandorDocuments.getContractlink(appID);
            Rents.Selected rentSelected = ra.getRents();//client.getCreditLimits(result.app.AccClient__r.Credit_line__c);
            
            //get Decision from account for this application
            Decision__c[] decArray = [SELECT Id FROM Decision__c WHERE Account__c =:result.app.AccClient__c AND Active__c = true ORDER BY Createddate DESC LIMIT 1];
            if(decArray.size()>0 && result.app.ScoreCard__c == null){
                result.decision = new DecisionWrapper(decArray[0].Id);
                rentSelected.admin_costs = rentSelected.doc_fee == true ? result.decision.conditions.admin_costs : 0;
            }

            result.obj = rentSelected;
            //get Tax for this application
            c2g__codaTaxRate__c[] taxList = [SELECT c2g__Rate__c FROM c2g__codaTaxRate__c WHERE c2g__TaxCode__c=:result.app.Vendor__r.c2g__CODAOutputVATCode__c LIMIT 1];
            if(taxList.size()>0){
                result.tax = taxList[0].c2g__Rate__c;
            }

           
            Vendor_Invoice__c vendorInvoice = RentingApplication.getVendorInvoice(appID);
            result.vendor_invoice = vendorInvoice;
            if(vendorInvoice != null){
                Attachment[] vendorInvoiceAttch = [SELECT ID FROM Attachment WHERE ParentID=:vendorInvoice.Id ORDER BY CREATEDDATE DESC LIMIT 1];
                if(vendorInvoiceAttch.size()>0){
                    result.attchDownloads.vendorInvoiceAttchDownload = vendorInvoiceAttch[0];
                }
            }else{
                //Ir buscar as faturas das aplicações anteriores ao deploy do novo site do parceiro
                Attachment[] appInvoiceAttch = [SELECT ID FROM Attachment WHERE ParentID IN (SELECT ID FROM Application__c WHERE Id=:appID) AND NAME LIKE '%Fa%tura%'ORDER BY CREATEDDATE DESC LIMIT 1];
                if(appInvoiceAttch.size()>0){
                    result.attchDownloads.vendorInvoiceAttchDownload = appInvoiceAttch[0];
                }
            }

            result.status=true;

            return result;

        }catch(exception e){
                
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getApplication] ERROR: application ID: ' + appID+' vendorLogin ID: '+vendorLoginID);  
            return result;

        }      
    }    

    @RemoteAction
    public static Result calcRents(Decimal amount, ID appID){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);

            if(ra.wasContractSent()){
                result.error = 'CONTRACT_ALREADY_SENT';
                result.status=false;
                return result;
            }

            result.obj = ra.CalcPayments(amount);
            result.status=true;
            
            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[calcRents] ERROR: application ID: ' + appID+' amount: '+amount);  
            return result;

        }           
    }

    @RemoteAction
    public static Result calcPayments_temp(Id appId, Rents.Selected selectedRent, String type_of_Change, boolean calcOpValueFromAmount){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);

            if(ra.wasContractSent()){
                result.error = 'CONTRACT_ALREADY_SENT';
                result.status=false;
                return result;
            }

            result.app = ra.CalcPayments(selectedRent, type_of_Change, calcOpValueFromAmount);
            result.status=true;
            
            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[calcPayments_temp] ERROR: application ID: ' + appID+' amount: '+selectedRent.opValue);  
            return result;

        }           
    }

    @RemoteAction
    public static Result setPayments(Id appId, Rents.Selected selectedRent){

        Result result = new Result();

        try{
            RentingApplication ra = new RentingApplication(appID);

            if(ra.wasContractSent()){
                result.error = 'CONTRACT_ALREADY_SENT';
                result.status=false;
                return result;
            }

            result.status = ra.setPayments(selectedRent);
            
            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setPayments] ERROR: application ID: ' + appID+' selectedRent: '+selectedRent);  
            return result;

        }              
    }

    @RemoteAction
    public static Result getRents(ID appID){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            result.obj = ra.getRents_deprecated(); //activa enquanto transição para nova decisao
            result.status=true;
            
            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getRents] ERROR: application ID: ' + appID);  
            return result;

        }           
    }

    @RemoteAction
    public static Result calcOpValueFromAmount(ID appID, Decimal paymentAmount,Integer term){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);

            if(ra.wasContractSent()){
                result.error = 'CONTRACT_ALREADY_SENT';
                result.status=false;
                return result;
            }

            result.obj = ra.CalcOpValueFromAmount(paymentAmount, term);
            Map<String,object> resCalc = (Map<String,object>) result.obj;
            if(resCalc.get('error')==null){
                result.status=true;
            }else{
                result.status=false;
                result.error= (String) resCalc.get('error');
            }
            
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();   
            result.status=false;
            result.writeLog('[setSignatureAmount] ERROR: application ID: ' + appID+' paymentAmount: '+paymentAmount+' term: '+term);
            return result;

        }           
    }


    @RemoteAction
    public static Result setSignatureAmount(Integer amount,ID appID){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            result.status = ra.setSignatureAmount(amount);
            if(result.status == false){  result.error = 'Valor não pode ser menos que zero.'; }else if(result.status == true){ result.status = true;}
            return result;
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString(); 
            result.status=false; 
            result.writeLog('[setSignatureAmount] ERROR: application ID: ' + appID+' amount: '+amount);
            return result;
        }           
    }

    
    @RemoteAction
    public static Result setAppDocFee(ID appID, Boolean yes_no, boolean calcOpValueFromAmount){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);

            if(ra.wasContractSent()){
                result.error = 'CONTRACT_ALREADY_SENT';
                result.status=false;
                return result;
            }
            result.obj = ra.setAppDocFee(yes_no, calcOpValueFromAmount);
            if(result.obj == null){
                result.status=false;
                result.error = 'obj is null.';
            }else{
                result.status=true;
            }
           
            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setAppDocFee] ERROR: application ID: ' + appID+' yes_no: '+yes_no);  
            return result;

        }           
    }

    @RemoteAction
    public static Result setPaymentFreq(string freq, boolean calcOpValueFromAmount, ID appID){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            if(ra.wasContractSent()){
                result.error = 'CONTRACT_ALREADY_SENT';
                result.status=false;
                return result;
            }
            result.status = ra.setPaymentFreq(freq, calcOpValueFromAmount);
            if(result.status == false){
                result.status=false;
                result.error = 'ERROR_UPDATING_PAYMENT_FREQ';
            }else{
                result.status=true;
            }
            
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;  
            result.writeLog('[setPaymentFreq] ERROR: application ID: ' + appID+' calcOpValueFromAmount: '+calcOpValueFromAmount+' freq: '+freq);  
            return result;
        }           
    }

    @RemoteAction
    public static Result setTerm(string term, Decimal paymonthly,ID appID){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            if(ra.wasContractSent()){
                result.error = 'CONTRACT_ALREADY_SENT';
                result.status=false;
                return result;
            }
            ra.setTerm(term, paymonthly);  result.status=true;
            
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();    
            result.status=false;    
            result.writeLog('[setTerm] ERROR: application ID: ' + appID+' term: '+term+' paymonthly: '+paymonthly);
            return result;

        }           
    }

    @RemoteAction
    public static Result getContactsApp(ID appID){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            result.contacts = ra.getContactsApp();
            result.status=true;
            
            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getContactsApp] ERROR: application ID: ' + appID);
            return result;

        }           
    }

    @RemoteAction
    public static Result getAppStatus(ID appID){
        
        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            result.app = ra.getAppStatus();
            if(result.app.Cancelled__c){
                result.app.Status__c = null;
            }
            result.status=true;
            
            return result;

        }catch(exception e){

            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getAppStatus] ERROR: application ID: ' + appID);
            return result;

        } 
    }

    @RemoteAction
    public static Result setCertificateSigner(Id contact,Id appID){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            string res = ra.setCertificateSigner(contact);
            if(res==''){
                result.status = false;
                result.error = 'ERRO';
            }else{
                result.status = true;
                result.Id = res;
            }

            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setCertificateSigner] ERROR: application ID: ' + appID+' contact: '+contact);
            return result;
        } 


        result.writeLog('[setCertificateSigner] ERROR: application ID: ' + appID +'; contact ID: ' +  contact);
        return result;

    }
    
    @RemoteAction
    public static Result setEmailContact(Contact contact, Id appID){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            string res = ra.setEmailContact(contact);
            if(res=='SAME_EMAIL'){
                result.status = false;
                result.error = 'SAME_EMAIL';
                //result.error = 'O email do cliente e do parceiro não podem ser o mesmo.';
            }else{
                result.status = true;
                result.Id = res;
            }

            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setEmailContact] ERROR: application ID: ' + appID+' contact: '+contact);
            return result;
        } 
    }

    @RemoteAction
    public static Result setEmailById(String contactid,String email){

        Result result = new Result();

        try{
            
            string res = rentingApplication.setEmailById(contactid,email);

            
            result.status = true;
            result.email = res;

            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setEmailById] ERROR: contactid: '+contactid);
            return result;
        } 
    }

    @RemoteAction
    public static Result setCorrectedEmailDocusign(String docusignStatusId, String contactid,String email){

        Result result = new Result();

        try{
            
            string res = rentingApplication.setCorrectedEmailDocusign(docusignStatusId,contactid,email);

            
            result.status = true;
            result.email = res;

            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setCorrectedEmailDocusign] ERROR: contactid: '+contactid+' docusignStatusId: '+docusignStatusId);
            return result;
        } 
    }

    @RemoteAction
    public static Result getDocusignCorrectedEmails(String docusignStatusId){
         Result result = new Result();

        try{
            
            result.Ids = rentingApplication.getDocusignCorrectedEmails(docusignStatusId);
            result.status = true;
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getDocusignCorrectedEmails] ERROR: docusignStatusId: '+docusignStatusId);
            return result;
        } 
    }


    @RemoteAction
    public static Result cancelApplication(ID appID){

        Result result = new Result();

        try{
            
            RentingApplication ra = new RentingApplication(appID);
            Boolean res = ra.cancelApplication(); 
            if(res==true){
                result.status = true;
            }else{
                 result.status = false;
                 result.error ='Erro ao cancelar a aplicação';
            }
            
            //return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            //return result;
        } 

        result.writeLog('[cancelApplication] ERROR: application ID: ' + appID);
        return result;
    }

    @RemoteAction
    public static Result EditContract(ID appID, List<String> contractType){

        Result result = new Result();

        try{
            
            RentingApplication ra = new RentingApplication(appID);
            String  res = ra.EditContract(contractType);

            if(res=='OK'){
                result.status = true;
            }else if(res=='NOT_EXIST'){
                result.status = false;
                result.error = res; //'Applicação não existe';
            }else if(res=='APP_ALREADY_SETTLE'){
                result.status = false;
                result.error = res; //'O pedido já se encontra com o contrato fechado.';
            }else if (res=='NOT_SYNC'){
                result.status = false;
                result.error = res; //Por favor aguarde até os dados estarem sincronizados.
            }else if(res=='INVOICE_STATUS_COMPLETED'){
           		result.status = false;
                result.error = res;
            }else{
                 result.status = false;
                 result.error ='Erro ao editar o pedido';
            }
            
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[EditContract] ERROR: application ID: ' + appID);
            return result;
        } 

    }

    @RemoteAction
    public static Result requestApplication_v2(String NIF, Id vendorLoginID){

        Result result = new Result();

        try{
            
            Vendor v = new Vendor(vendorLoginID);
            String request_result = v.requestApplication_v2(NIF);

            if(request_result.contains('FAILED')){
                result.status = false;
                result.error = request_result;
                return result;
            }
            result.status=true;    
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[requestApplication_v2] ERROR: vendorLogin ID: ' + vendorLoginID);
            return result;
        } 
    }    

     //DEPRECATED HP 14/12/2017
    /*@RemoteAction
    public static Result requestApplication(String NIF, Id vendorLoginID){

        Result result = new Result();

        try{
            
            Vendor v = new Vendor(vendorLoginID);
            String request_result = v.requestApplication(NIF);

            if(request_result.contains('FAILED')){
                result.status = false;
                result.error = request_result;
            }else{
                result.status=true;    
                RentingApplication ra = new RentingApplication(request_result);
                result.app = ra.getAppSObject();
            }
            
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[requestApplication] ERROR: vendorLogin ID: ' + vendorLoginID);
            return result;
        } 
    }*/

    @RemoteAction
    public static Result setClientAddress(Client.Address clientAddress){

        Result result = new Result();
        
        try{
            Client c = new Client(clientAddress.accountId);
            result.status = c.setClientAddress(clientAddress);
            return result;
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setClientAddress] ERROR: clientAddress: ' + clientAddress);
            return result;
        }
    }

    @RemoteAction
    public static Result buildContract(Id appID, String typeOfContract){

        Result result = new Result();

        try{
            RentingApplication ra = new RentingApplication(appID);
            String contractId = ra.buildContract(TypeOfContract);

            result.status= true;
            result.Id = contractId;
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[buildContract] ERROR: application ID: ' + appid+' typeOfContract: '+typeOfContract);
            return result;
        }  

        return result;
    }

   /* @RemoteAction
    public static Result getCandorDocument(Id contractID){

        Result result = new Result();

        try{

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            return result;
        }  

        return null;
    }*/

    @RemoteAction 
    public static Result setAppClientSigners(Id appID, List<Id> contactsId){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            Application__c appVal = ra.getAppSObject();
            if(appVal.Client_Forma_Obrigar_Val__c <= 0){
                result.status = false;
                result.error = 'INVALID_OBRIGAR_VAL';
                return result;
            }
            
            String res = ra.setAppClientSigners(contactsId);

            if(res!='OK'){
                result.status = false;
                result.error = res;
            }else{
                result.status = true;
                Application__c app = new Application__c();
                app.Id=appID;
                app.Contract_Accessed__c=true;
                app.TermSetByUser__c=true;
                upsert app;
            }

            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setAppClientSigners] ERROR: application ID: ' + appid);
            return result;
        }
    }

    @RemoteAction
    public static Result confirmSubmission(Id appID, List<Id> contactsId, Rents.Selected selectedRent){

        Result result = new Result();

        try{

            RentingApplication ra = new RentingApplication(appID);
            
            String res = ra.setAppClientSigners(contactsId);

            result = validateSubmission(ra, selectedRent);
            if(result.status == false){
                return result;
            }

            if(!ra.setPayments(selectedRent)){
                result.status = false;
                result.error = 'INVALID_RENTS';
                result.writeLog('[validateSubmission] ERROR: application ID: ' + appID +'; reason: ' + result.error);
                return result;
            }

            if(res!='OK'){
                result.status = false;
                result.error = res;
                return result;
            }else{
                Application__c app = new Application__c();
                app.Id=appID;
                app.Contract_Accessed__c=true;
                app.TermSetByUser__c=true;
                upsert app;

                result.status= true;
                
            }

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
        }

        result.writeLog('[confirmSubmission] ERROR: application ID: ' + appID);
        return result;
    }

    private static Result validateSubmission(RentingApplication ra, Rents.Selected selectedRent){

        Result result = new Result();

        Application__c application = ra.getAppSObject();

        if(selectedRent.opValue > application.AccClient__r.Available_Credit_Line__c){
            result.status = false;
            result.error = 'INVALID_OPVALUE';
            result.writeLog('[validateSubmission] ERROR: application ID: ' + application.Id +'; reason: ' + result.error);
            return result;
        }
        
        if(application.Client_Forma_Obrigar_Val__c <= 0){
            result.status = false;
            result.error = 'INVALID_OBRIGAR_VAL';
            result.writeLog('[validateSubmission] ERROR: application ID: ' + application.Id);
            return result;
        }

        if(application.AccClient__r.Credit_Line_Status__c == 'Credit Line - Suspended'){
            result.status = false;
            result.error = 'ACCOUNT_SUSPENDED';
            result.writeLog('[validateSubmission] ERROR: application ID: ' + application.Id);
            return result;
        }

        result.status = true;

        return result;
    }



    @RemoteAction
    public static Result sendRentingContract(Id appID, Id contractId){

        Result result = new Result();

        try{
            RentingApplication ra = new RentingApplication(appID);
            Application__c app = ra.getAppSObject();

            decimal discfactor=0;
            if(app.vendor__r.Discount_Factor__c!=null && app.vendor__r.Discount_Factor__c!=''){
                discfactor=decimal.valueOf(((app.vendor__r.Discount_Factor__c).replace(',','.')).replace('%',''));
            }

            
            /*String aditionalInfo = 'Error: Installments showed to dealer do not match the backend values. Please contact development team.';
            String email ='sf.candor@worldit.pt';

            if(res == 'SUCCESS'){
                result.status = true;
            }else if(res.contains('DIFFERENT_RENT') ){
                //result.status = false;
                //result.error=res;
                //return result;
                System.debug('a Enviar Email de erro para: '+email);
               Utilities.SendEmail(email, res, aditionalInfo);
            }else{
                //result.status = false;
                //result.error=res;
                //return result;
                System.debug('a Enviar Email de erro para: '+email);
                Utilities.SendEmail(email, res, aditionalInfo);
            }*/

            DocuSignAPI.EnvelopeStatus es = ra.SendRentingContract(contractId);

            if(es.status == 'Sent'){
                result.status = true;
                result.Id = es.EnvelopeID;
            }else if(es.status == 'Not Found'){
                result.status = false;
                result.error='CONTRACT_NOT_CREATED';
            }else if(es.Status == 'MIN_NUMBER_OF_SIGNERS'){
                result.status = false;
                result.error='MIN_NUMBER_OF_SIGNERS';
            }else if(es.Status == 'INVALID_ATTACH'){
                result.status = false;
                result.error='INVALID_ATTACH';
            }else{
                result.status = false;
                result.error=es.status;
            }

            //return result;
            if (app.ScoreCard__c != null){ //just for the old contracts. Before New Decision 17/11/2017 (HP)
                String res = ScoreCardConfig.getRentsWithNoUpdate(app,app.Equipment_Cost__c, Integer.valueOf(app.Term__c),discfactor);

                if(res.contains('DIFFERENT_RENT') || res=='Failure')
                    result.writeLogFalseRent(res + ' - Apllication ID: ' + appID + '; Application Name: ' + app.Name);
            }


        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[sendRentingContract] ERROR: application ID: ' + appID + '; Contract ID: ' + contractId);
            //return result;
        }

        return result;
    }

    @RemoteAction
    public static Result sendAutoContract(Id appID, Id autoId){

        Result result = new Result();

        try{
            RentingApplication ra = new RentingApplication(appID);
            DocuSignAPI.EnvelopeStatus es = ra.sendAutoContract(autoId);

            if(es.status == 'Sent'){
                result.status = true;
                result.Id = es.EnvelopeID;
            }else if(es.status == 'Not Found'){
                result.status = false;
                result.error='CONTRACT_NOT_CREATED';
            }else if(es.status == 'Signer Not Found'){
                result.status = false;
                result.error='AUTO_SIGNER_NOT_FOUND';
            }else if(es.status == 'Vendor Not Found'){
                result.status = false;
                result.error='VENDOR_NOT_FOUND';
            }else{
                result.status = false;
                result.error=es.status;
            }

            //return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            //return result;
        }

        result.writeLog('[sendAutoContract] ERROR: application ID: ' + appID + '; Auto ID: ' + autoId);
        return result;
    }

    @RemoteAction
    public static Result resendContractDocuSign(Id DocuSignStatusId){

        Result result = new Result();

        try{        
            result.obj = RentingApplication.resendContractDocuSign(DocuSignStatusId);
            result.status = true;
            //return result;
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            //return result;
        }

        result.writeLog('[resendContractDocuSign] ERROR: DocuSignStatusId ID: ' + DocuSignStatusId);
        return result;
    }


    @RemoteAction
    public static Result resendContractDocuSignCorrection(Id DocuSignStatusId,String[] contactArray){

        Result result = new Result();

        try{        
            result.obj = RentingApplication.resendContractDocuSignCorrection(DocuSignStatusId,contactArray);
            result.status = true;
            //return result;
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            //return result;
        }

        result.writeLog('[resendContractDocuSign] ERROR: DocuSignStatusId ID: ' + DocuSignStatusId);
        return result;
    }



    @RemoteAction
    public static Result setViewedContract(Id appID){

        Result result = new Result();

        try{
            
            Application__c app = new Application__c();
            app.Id = appID;
            app.Contract_Accessed__c=true;
            update app;

            result.status = true;
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[addEquipment] ERROR: application ID: ' + appid);
            return result;
        }        
    }

    @RemoteAction
    public static Result addEquipment(Id appID, Equipment__c equipment){

        Result result = new Result();

        try{
            
           RentingApplication ra = new RentingApplication(appID);
           if(ra.wasAutoSent()){
                result.status = false;
                result.error = 'AUTO_ALREADY_SENT';
                return result;
           }
           result.equ = ra.addEquipment(equipment);
           result.autoLink = CandorDocuments.getAutolink(appID);

            result.status = true;
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[addEquipment] ERROR: application ID: ' + appid+ ' equipment: '+equipment);
            return result;
        }          

    }

    @RemoteAction
    public static Result updateEquipments(Id appID, List<Equipment__c> equipmentList, boolean buildAuto){
 
        Result result = new Result();

        try{
            
           RentingApplication ra = new RentingApplication(appID);
           
           if(ra.wasAutoSent()){
                result.status = false;
                result.error = 'AUTO_ALREADY_SENT';
                return result;
           }
           
           for(Integer i=0; i < equipmentList.size(); i++){
                equipmentList[i].Equipment_Description__c = equipmentList[i].Equipment_Description__c.abbreviate(69);
                equipmentList[i].Equipment_Serial_Number__c = equipmentList[i].Equipment_Serial_Number__c.abbreviate(15);
           }
           result.equipments = ra.updateEquipments(equipmentList);
           
           if(buildAuto){
                result.attachmentID = ra.buildContract('AUTO');
           }
           result.autoLink = CandorDocuments.getAutolink(appID);
           result.status = true;
           return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[updateEquipments] ERROR: application ID: ' + appid+ ' buildAuto: '+buildAuto);
            return result;
        }          

    }

    @RemoteAction
    public static Result deleteEquipment(Id appID, Equipment__c equipment){

        Result result = new Result();

        try{
            
           RentingApplication ra = new RentingApplication(appID);
          if(ra.wasAutoSent()){
                result.status = false;
                result.error = 'AUTO_ALREADY_SENT';
                return result;
           }
           result.status = ra.deleteEquipment(equipment);
           result.autoLink = CandorDocuments.getAutolink(appID);
           return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[deleteEquipment] ERROR: application ID: ' + appid+ ' equipment: '+equipment);
            return result;
        }
    }          

//result.contractLink = CandorDocuments.getContractlink(appID);
    @RemoteAction
    public static Result getAutoLink(Id appID){

        Result result = new Result();

        try{
            
           RentingApplication ra = new RentingApplication(appID);
           result.autoLink = CandorDocuments.getAutolink(appID);
           result.status = true;
           return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getAutoLink] ERROR: application ID: ' + appid);
            return result;
        }          

    }

    @RemoteAction
    public static Result getEquipments(Id appID){

        Result result = new Result();

        try{
            
           RentingApplication ra = new RentingApplication(appID);
           result.equipments = ra.getEquipments();
           result.autoLink = CandorDocuments.getAutolink(appID);
           result.status = true;
           return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getEquipments] ERROR: application ID: ' + appid);
            return result;
        }          

    }   

    @RemoteAction
    public static Result setPaymentMethod(Id appid, String paymentMethod){
        
        Result result = new Result();
        
        try{
            RentingApplication ra= new RentingApplication(appId);
            result.status = ra.setPaymentMethod(paymentMethod);
            return result;
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setPaymentMethod] ERROR: application ID: ' + appid+' paymentMethod: '+paymentMethod);
            return result;
        }
    }

    @RemoteAction
    public static Result validateVendorClientIban(id appid,String iban){


        Result result = new Result();

        
        try{
            Boolean sameIBAN = RentingApplication.validateVendorClientIban(appid,iban);

            if(sameiBAN == true){
                result.status = false;
                result.error = 'ERROR_SAMEIBAN';
                return result;
            }else{
                result.status = true;
                return result;
            }
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[validateVendorClientIban] ERROR: application ID: ' + appid+' iban: '+iban);
            return result;
        }


    }



    @RemoteAction
    public static Result setClientIban(String iban, Id clientId){

        Result result = new Result();

        
        try{
            
            Client c = new Client(clientID);
            result.status = c.setClientIban(iban);
            if(!result.status){
                result.error = 'ERROR: Iban for client with Id: ' + c.getId() + ' not Updated';   
            }
            return result;
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setClientIban] ERROR: client ID: ' + clientId+' iban: '+iban);
            return result;
        }
    }

    @RemoteAction
    public static Result setVendorIban(String iban, Id vendorloginId){

        Result result = new Result();
        
        try{
            Vendor v = new Vendor(vendorloginId);
            result.status = v.setVendorIban(iban);
            if(!result.status){
                result.error = 'ERROR: Iban for vendor with Id: ' + vendorloginId + ' not Updated';   
            }
            return result;
        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setVendorIban] ERROR: vendorlogin ID: ' + vendorloginId+' iban: '+iban);
            return result;
        }
    } 

    @RemoteAction
    public static Result getNotifications(Id vendorloginId){

        Result result = new Result();
        
        try{

            Vendor v = new Vendor(vendorloginId);
            result.listSo = v.getNotifications();
            result.status = true;
            //result.mapLabels = new map<string, string>();
            //result.mapLabels.put('PP_Status',System.Label.PP_Status);
            //system.debug(result.mapLabels);
            //system.debug(userInfo.getLanguage());
            
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getNotifications] ERROR: vendorlogin ID: ' + vendorloginId);
            return result;
        }
    } 

    @RemoteAction
    public static Result setNotificationsRead(Id vendorloginId, List<ID> notificationsIDList){

        Result result = new Result();
        
        try{
            
            Vendor v = new Vendor(vendorloginId);
            result.status = v.setNotificationsRead(notificationsIDList);
            return result;

        }catch(exception e){
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[setNotificationsRead] ERROR: vendorlogin ID: ' + vendorloginId);
            return result;
        }
    } 

    //CRIACAO - 01/06/17 - para recolher todas as infos dos score cards necessarios (BP)
    @RemoteAction
    public static Result getInfoScores(ID vendorloginId)
    {
        Result result = new Result();
        try
        {            
            Vendor v = new Vendor(vendorloginId);
            result.scoreCards = v.getInfoScores();            
            return result;
        }
        catch(exception e)
        {
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[getInfoScores] ERROR: vendorlogin ID: ' + vendorloginId);
            return result;
        }
    }       
     
    /*@RemoteAction
    public static Result getLabels(){
        Result result = new Result();
        result.mapLabels = new map<string, string>();
        result.mapLabels.put('PP_Status',System.Label.PP_Status);
                system.debug(result.mapLabels);
                result.status=true;
                result.error=null;
        return result;
    }*/

    /*@RemoteAction 
    public static Result docParserGet(ID vendorloginId, ID docID){
        Result result = new Result();
        try{            
            result.status = true;           
            result.info = DocParserApi.getDocParserVendor(vendorLoginID, docID);
            return result;
        }
        catch(exception e)
        {
            result.error = 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
            result.status=false;
            result.writeLog('[docParserGet] ERROR: vendorlogin ID: ' + vendorloginId);
            return result;
        }
    }*/
    
    public class Result{
        public Login__c login {get;set;}
        public Session__c session{get;set;}
        public String logo{get;set;}
        
        public Application__c app {get; set;}
        public List<Application__c> applications {get;set;}
        
        public Contact con {get;set;} 
        public List<Contact> contacts {get;set;}
        
        public Account acc {get; set;}
        public List<Account> accounts{get;set;}
        public AccountWrapper.ListOfAccountWrapper accountsWr {get; set;}

        public DecisionWrapper decision {get; set;}

        public Equipment__c equ {get; set;}
        public List<Equipment__c> equipments {get;set;}
        
        public List<sObject> listSo{get;set;}
        public sObject sObj {get;set;}
        public Object obj {get;set;}

        public Id attachmentID {get;set;} 
        public RentingApplication.appDownloads attchDownloads {get;set;} 

        public Vendor_invoice__c vendor_invoice {get;set;}
        
        public Integer cod_erro {get;set;}
        public boolean status{get;set;} 
        public string error{get;set;}
        public string Id {get;set;}
        public string info {get;set;}
        public string autoLink {get; set;}
        public string contractLink {get; set;}
        public string email {get; set;}
        public Decimal tax {get;set;}
        public List<Id> Ids {get;set;}
        public Set<Id> signers {get;set;}
        public Map<String,List<Id>> signersMap {get;set;}
        public List<RentingApplication.DocuSignInfo> docusigninfo {get;set;}
        public List<ScoreCard_Config__c> scoreCards {get; set;}
        //public map<string,string> maplabels {get; set;}

        public void writeLog(String aditionalInfo){
            if(LOGS || !Test.isRunningTest()){
                if (status == false){
                    if(error.length()>32768){error = error.substring(0, 131072);}
                    Outbound_Integration_Log__c log = new Outbound_Integration_Log__c(Start__c = Datetime.now(), End__c = Datetime.now(), Status__c = 'FAILED', Code__c = 'PARTNER_APP', Message__c = aditionalInfo, printStackTrace__c = error);
                    System.debug('[CandorPortalController - writeLog()] ->ERROR! LOG: ' + log);
                    insert log;
                }
            }
        }

        public void writeLogFalseRent(String error){

        String aditionalInfo = 'ALERT: Installments showed to dealer do not match the backend values. Please contact development team.';

            if(LOGS || !Test.isRunningTest()){
                if (status == false){
                    String[] listEmails = new List<String>();
                    listEmails.add('info@candor.pt');
                    Utilities.SendEmail(listEmails, error, aditionalInfo);
                }
            }
        }
    } 
}