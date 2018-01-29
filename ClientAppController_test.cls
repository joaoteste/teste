@isTest (SeeAllData = true)
public class ClientAppController_test {
/*
	@isTest
    static void authentication_test(){
        String loginDateCreated=''; 
        // a vendor is needed to create the login 
        
        Account accVend = RentingApplication_Util_Test.createAccount('vendor_qualquer','vendor','226723155', null);
        
        Contact contact = new contact();
        contact.FirstName = 'doel1';
        contact.LastName = 'Doe1';
        contact.Email = 'test1@email.com';
        contact.Role__c='Master';
        contact.AccountId= accVend.Id;
        insert contact;
        //first the contact, a contact cannot exist if the account is already created
        
        
        Login__c newlogin = new Login__c (Email__c='email@qualquer.com', Username__c='email@qualquer.com', Vendor_vendor__c=contact.ID, IdVendor__c=accVend.ID, master__c=true);
        insert newlogin;
        
        CandorAuthorization.resetPassword('email@qualquer.com', false); 
        Login__c loginResetPw = [SELECT Username__c, Password__c FROM Login__c WHERE Email__c = 'email@qualquer.com'];

        Session__c control = new Session__c();
        
        CandorAuthorization auth = new CandorAuthorization();
        auth = Vendor.login(loginResetPw.Username__c, loginResetPw.Password__c, true, null, null, null);
                
        if(auth.isValid()){
        	control.Id       = auth.getSessionID();
        	control.token__c = auth.getToken();
        	control.Login__c = auth.getUserInfo().Id;
        }
        
        Test.startTest();
            Session__c testSession = ClientAppController.authentication(loginResetPw.Username__c, loginResetPw.Password__c);
        Test.stopTest();
		
        System.assertEquals(testSession.ID,       control.ID);
        System.assertEquals(testSession.token__c, control.token__c);
		System.assertEquals(testSession.Login__c, control.Login__c);        
    }
    @isTest
    static void authenticationJson_test(){ 
        String loginDateCreated=''; 
   		Map<Object,Object> result = new Map<Object,Object>(); 
   		
        //Candor authorization nao tem nda.
        CandorAuthorization auth = new CandorAuthorization();
        auth = Vendor.login('teste', '123456', true, 'asdasdsa', 'asdadas', 'asdadasda');
        
        result.put('Status', auth.isValid());
    	result.put('Id', auth.getSessionID());
    	result.put('access_token', auth.getToken());
        result.put('message', auth.getErrorMsg());
        
        String controlString = JSON.serialize(result, true);
        
        Test.startTest();
        	String res = ClientAppController.authenticationJSON('teste', '123456');
        Test.stopTest();
        
        System.assertEquals(controlString, res);
    }
    @isTest
    static void getAppAttachments_test(){
        Account accVend = RentingApplication_Util_Test.createAccount('vendor_qualquer','Customer - Channel','226723155', null);
        Account accClient = RentingApplication_Util_Test.createAccount('client_qualquer','Channel Partner / Vendor','226723175', null);
        //Associates thee attachment with the account
       	String appID = RentingApplication_Util_Test.createApplication(accVend, accClient);
      
        //creates the attachment associated with the renting app
        Attachment attachTest = new RentingApplication_Util_Test().createAttachment(appID);  
       	
        RentingApplication ra = new RentingApplication(appID);
        String resultControl = JSON.serialize(ra.getAppAttachments(), true);
        
        Test.startTest();
        	String resTest = ClientAppController.getAppAttachments(appID);
        Test.stopTest();
        System.debug('resTest' + resTest);
        System.debug('resultControl' + resultControl);
        System.assertEquals(resultControl, resTest);
        
    }
    @isTest
    static void getInvoiceDetails_test(){
   
        Account acc = RentingApplication_Util_Test.createAccount('client_qualquer','vendor','226723155', null);
        List<Map<String,String>> invoiceDetailsList = Utils_GetInvoiceDetails.getInvoiceDetails(acc.ID);
		string res = invoiceDetailsList != null ? JSON.serialize(invoiceDetailsList, true) : null;
        
        Test.startTest();
        	String resTest = ClientAppController.getInvoiceDetails(acc.ID);
        Test.stopTest();
        System.assertEquals(res, resTest);
    }
    
    @isTest
    static void executeQuery_test(){
        Account accVend = RentingApplication_Util_Test.createAccount('vendor_qualquer_2','Channel Partner / Vendor','502180919', null);
        Account accClient = RentingApplication_Util_Test.createAccount('client_qualquer_2','Customer - Channel','502957417', null);
        List<SObject> sObjectFromQuery = ClientAppController.executeQuery('SELECT ID FROM ACCOUNT WHERE ID IN (\'' + accVend.Id + '\', ' + '\'' + accClient.Id + '\')');
        System.assert(sObjectFromQuery.size()==2);    
    }
    
    //knowledge article
    @isTest
    static void getArticle_test(){
        clientAppController.getArticle('lorem', 'customer', 'pt_BR');
    }
    @isTest
    static void getAllCategories_test(){
        clientAppController.getAllCategories('customer', 'pt_BR');
    }
    @isTest
    static void getCategory_test(){
        clientAppController.getCategory('insurance','customer', 'pt_BR');
    }
    @isTest
    static void getArticlesByCategory_test(){
        clientAppController.getArticlesByCategory('insurance','customer', 'pt_BR');   
    }
    @isTest
    static void rateArticle_test(){
        clientAppController.rateArticle('insurance','up','customer', 'pt_BR');  
    }
    @isTest
    static void searchArticle_test(){
        clientAppController.searchArticle('lorem',  'customer', 'pt_BR');
    }
    @isTest
    static void getAllArticlesOrderedByViews_test(){
        clientAppController.getAllArticlesOrderedByViews('customer', 'pt_BR');
    }
    @isTest
    static void getArticlesByType_test(){
        clientAppController.getArticlesByType('customer', 'pt', 'video');
    }
    */
    

    
    
}