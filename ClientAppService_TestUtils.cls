public class ClientAppService_TestUtils {
    
    private static Integer KEY_SIZE = 192;
    private static Integer PASS_SIZE = 8;

    public static Login__c createLogin(String username, String pass, boolean inactive){
        Login__c testLogin = new Login__c();
        testLogin.Email__c = username;
        testLogin.Username__c = username;
        testLogin.Inactive__c = inactive;
        testLogin.Master__c = true;
        String hashKey = generateCryptoKeyString(KEY_SIZE);
        testLogin.HashKey__c = hashKey;
        insert testLogin;
        
        Login__c aux = [SELECT CreatedDate FROM Login__c WHERE Id =: testLogin.Id];
        String iv = aux.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00';
        String encryptedPass = encryptString(pass, iv, hashKey);
        testLogin.Password__c = encryptedPass;
        update testLogin;
        return testLogin;
    }
    
    public static Account createAccount(String accountType, String nif){
        Account testAcc = new Account();
        testAcc.Name = 'Test Account Client'; 
        testAcc.Type = accountType;
        testAcc.NIF__c = nif;
        testAcc.BillingCity = 'Lx';
        testAcc.BillingPostalCode = '3000-423';
        testAcc.BillingStreet = 'BillingStreet';
        testAcc.Phone = '00351964639755';
        testAcc.Credit_line__c = 10000;
        testAcc.Credit_Line_Status__c = 'Credit Line - Approved';
        testAcc.Available_Credit_Line__c = 7000;
        testAcc.Used_credit_line__c = 3000;
        testAcc.Tax_Zone__c = 'Madeira';
        insert testAcc;
        return testAcc;
    }
    
    public static Account getParentAccount(Account child){
        Account parent = [SELECT Name, Type, NIF__c, BillingCity, BillingPostalCode, BillingStreet,
                          Phone, Credit_line__c, Available_Credit_Line__c, Used_credit_line__c
                          FROM Account 
                          WHERE Type = 'Account Master' AND NIF__c =: child.NIF__c];
        
        return parent;
    }
    
    public static Contact createContact(Account testAccount, Login__c login){
        Contact testContact = new Contact();
        testContact.FirstName = 'Ricardo';
        testContact.LastName = 'Abreu';
        testContact.Email = 'someone@email.com';
        testContact.Login__c = (login != null) ? login.Id : null;
        testContact.AccountId = testAccount.Id;
        insert testContact;
        return testContact;
    }
    
    //use diffPass to mock scenarios where the user changed his password after having an assigned session
    public static Session__c createSession(Login__c testLogin, boolean diffPass){
        Session__c testSession = new Session__c();
        testSession.Login__c = testLogin.Id;
        testSession.token__c = generateCryptoKeyString(192);
        testSession.LastLogin__c = Date.today();
        testSession.PasswordS__c = (diffPass) ? generateCryptoKeyString(192) : testLogin.Password__c;
        insert testSession;
        return testSession;
    }                                                            
    
    public static Application__c createRentingApp(Account client, Account vendor){
        Application__c testApp= new Application__c();
        testApp.AccClient__c = client.Id;
        testApp.Vendor__c = vendor.Id;
        testApp.Status__c = 'Contract - Running';
        testApp.Payment_Amount__c = 10000;
        testApp.Payment_Freq__c = 'Monthly';
        testApp.Payment_Timing__c = 'Advanced';
        testApp.Term__c = '36';
        testApp.Payment_Method__c = 'ATM Reference';
        insert testApp;
        return testApp;
    }
    
    public static Application__c createRentingApp(Account client, Account vendor, Contact contact){
        Application__c testApp= new Application__c();
        testApp.AccClient__c = client.Id;
        testApp.Vendor__c = vendor.Id;
        testApp.Client_Signer_1__c = contact.Id;
        testApp.Status__c = 'Contract - Running';
        testApp.Payment_Amount__c = 10000;
        testApp.Payment_Freq__c = 'Monthly';
        testApp.Payment_Timing__c = 'Advanced';
        testApp.Term__c = '36';
        testApp.Payment_Method__c = 'ATM Reference';
        insert testApp;
        return testApp;
    }
    
    public static Client_Visit__c createClientVisit(Application__c app){
    	Client_Visit__c visit = new Client_Visit__c();
        visit.Application_Number__c = app.Id;
        visit.Type__c = 'Underwriting Process';
        visit.Visit_Status__c = 'Processing';
        visit.RecordTypeId =[Select Id From RecordType WHERE Name ='Client Visit Underwriting' and SobjectType ='Client_Visit__c'  limit 1].Id;
        insert visit;
        return visit;
    }
    
    public static Vendor_Invoice__c createVendorInvoice(Account vendor, Application__c app){
    	Vendor_Invoice__c inv = new Vendor_Invoice__c();
    	inv.Account__c = vendor.Id;
    	inv.Application__c = app.Id;
    	inv.Invoice_Total__c = 4000;
    	insert inv;
    	return inv;
    }
    
    public static List<Billing_Contract__c> createContractsForRentingApp(Application__c app, Account client, Account vendor, Integer numberOfContracts){
        List<Billing_Contract__c> toReturn = new List<Billing_Contract__c>();
        
        for(Integer i = 0; i<numberOfContracts; i++){
            Billing_Contract__c bc = new Billing_Contract__c();
            bc.Application__c = app.id;
            bc.Account__c = client.Id;
            bc.Account_Vendor__c = vendor.Id;
            bc.Equipment_Cost__c = 1000 + (100*i);
            toReturn.add(bc);
        }
        
        insert toReturn;
        return toReturn;
    }
    
    public static List<Billing_Contract_Line_Item__c> createLineItemsForBillingContract(Billing_Contract__c billing, Application__c app, Integer numberLineItems){
        List<Billing_Contract_Line_Item__c> testLineItems = new List<Billing_Contract_Line_Item__c>();
        
        for(Integer i=0; i<numberLineItems; i++){
            Billing_Contract_Line_Item__c li = new Billing_Contract_Line_Item__c();
            li.Application__c = app.Id;
            li.Billing_Contract__c = billing.Id;
            li.Line_Item_Start_Date__c = Date.today();
            li.Line_Item_End_Date__c = Date.today();
            li.Sales_Price__c = 500;
            li.Invoiced__c = false;
            c2g__codaTaxCode__c auxTaxCode = [SELECT Id FROM c2g__codaTaxCode__c LIMIT 1];
            li.Product_Tax_Code__c = auxTaxCode.Id;
            testLineItems.add(li);
        }
        
        insert testLineItems;
        return testLineItems;
    }
    
    public static Collection_Case__c createCollectionCase(Account client){
        //create Collection Case
        Collection_Case__c testCollectionCase = new Collection_Case__c();
        testCollectionCase.Account__c = client.Id;
        testCollectionCase.Status__c='Open';
        testCollectionCase.Amount_Claimed__c = 5000;
        insert testCollectionCase;
        return testCollectionCase;
    }
    
    public static Billing_Contract__c createBillingContractForCollectionCase(Application__c app, Collection_Case__c testCollectionCase){
        Billing_Contract__c bc1 = new Billing_Contract__c();
        bc1.Application__c = app.id;       
        bc1.Collection_Case__c = testCollectionCase.Id;
        bc1.Account__c = app.AccClient__c;
        bc1.Equipment_Cost__c = 1000;
        insert bc1;
        return bc1;
    }
    
    public static Dunning_Alert__c createDunningAlert(Collection_Case__c collectionCase, String level){
    	Dunning_Alert__c dunning = new Dunning_Alert__c();
        dunning.Collection_Case__c = collectionCase.Id;
        dunning.Dunning_Level__c = level;
        dunning.Status__c = 'Open';
        dunning.Amount_Claimed__c = 5000;
        dunning.Aux_Entity__c = 17862;
        dunning.Aux_Reference__c = 745692318;
        insert dunning;
        return dunning;
    }
    
    public static List<Dunning_Alert__c> createDunningAlerts(Collection_Case__c collectionCase, List<String> levels){
        List<Dunning_Alert__c> toReturn = new List<Dunning_Alert__c>();
        
        for(Integer i = 0; i<levels.size(); i++){
            Dunning_Alert__c dunning = new Dunning_Alert__c();
            dunning.Collection_Case__c = collectionCase.Id;
            dunning.Dunning_Level__c = levels.get(i);
            dunning.Status__c = 'Open';
            dunning.Amount_Claimed__c = 5000;
            dunning.Aux_Entity__c = 17862;
            dunning.Aux_Reference__c = 745692318;
            toReturn.add(dunning);
        }
        
        insert toReturn;
        return toReturn;
    }
    
    public static c2g__codaInvoice__c createInvoice(Application__c app, Account client, Collection_Case__c collectionCase, String taxZone, List<Product2> invoiceLineItems, Billing_Contract__c bc){
        c2g__codaInvoice__c si = new c2g__codaInvoice__c();
        si.c2g__Account__c = client.Id;
        si.Application__c = app.Id;
        si.c2g__DueDate__c = Date.today();
        si.c2g__InvoiceDate__c = Date.today();
        si.Invoice_Express_Number_text__c = '16914y78';
        si.c2g__InvoiceStatus__c = 'In Progress';
        si.Invoice_Email_Status__c = 'Sent';
        si.c2g__PrintStatus__c = 'Not Printed';
        si.c2g__InvoiceDescription__c = 'amazing description'; 
        si.Collection_Case__c = (collectionCase != null) ? collectionCase.Id : null;
        si.Billing_Contract__c = (bc != null) ? bc.Id : null;
        
        c2g__codaAccountingCurrency__c auxCurrency = [SELECT Id
                                                      FROM c2g__codaAccountingCurrency__c
                                                      LIMIT 1];
        si.c2g__InvoiceCurrency__c = auxCurrency.Id;
        
        c2g__codaCompany__c auxCompany = [SELECT Id
                                          FROM c2g__codaCompany__c
                                          LIMIT 1];
        si.c2g__OwnerCompany__c = auxCompany.Id;
        insert si;
            
        List<c2g__codaInvoiceLineItem__c> list_InvoiceLineItem = new List<c2g__codaInvoiceLineItem__c>();
        Bill_ProductRegion billRegion = new Bill_ProductRegion('Input');
        
        for(Product2 p : InvoiceLineItems){
            c2g__codaInvoiceLineItem__c ili = new c2g__codaInvoiceLineItem__c();
            ili.c2g__Invoice__c = si.Id;
            ili.c2g__Product__c = billRegion.getProduct(p.ProductCode, taxZone);
            ili.c2g__TaxCode1__c = billRegion.getTaxCode(p.ProductCode, taxZone);
            ili.c2g__UnitPrice__c = 200;
            ili.c2g__DeriveUnitPriceFromProduct__c = false;
            list_InvoiceLineItem.add(ili);
        }
        
        insert list_InvoiceLineItem;
        
        return si;
    }
    
    public static c2g__codaInvoice__c getInvoiceUNPAID(){
    	c2g__codaInvoice__c aux = [SELECT Id, c2g__Account__c 
        FROM c2g__codaInvoice__c
        WHERE Invoice_Email_Status__c = 'Sent' AND Canceled__c = false 
        AND c2g__PaymentStatus__c = 'Unpaid'
        LIMIT 1];
        
        return aux;
    }
    
    //use helper class to create creditNote from salesInvoice - GENIUS
    public static List<c2g__codaCreditNote__c> createCreditNotes(List<c2g__codaInvoice__c> invoices, Application__c app){
        return SalesInvoiceCreditNote.convertToCreditNote(invoices, app);
    }
    
    public static Attachment createAttachment(Id parentId, String name){
        Attachment testAttachment = new Attachment();
        testAttachment.ParentId = parentId;
        testAttachment.Name = name;
        testAttachment.ContentType = 'application/pdf';
        testAttachment.Description = 'Attachment Description';
        testAttachment.Body = Blob.valueOf('Attachment Body');
        insert testAttachment;
        return testAttachment;
    }
    
    public static Map<String,Object> convertAttachmentToMap(Attachment att){
        Map<String,Object> attMap = new Map<String,Object>();
        attMap.put('Id',att.Id);
        attMap.put('Name',att.Name);
        String bodyStr = EncodingUtil.base64Encode(att.Body);
        attMap.put('Body', bodyStr);
        attMap.put('ContentType',att.ContentType);
        attMap.put('Description',att.Description);
        return attMap;
    }
    
    public static Injunction_Procedure__c createInjunction(Collection_Case__c cc){
        Injunction_Procedure__c inj = new Injunction_Procedure__c();
        inj.Collection_Case__c = cc.Id;
        
        insert inj;
        return inj;
    }
    
    public static Payment_Plan__c createPaymentPlan(Account acc, Contact cont, Collection_Case__c cc){
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Type__c = 'Full';
        pp.Contact__c = cont.Id;
        pp.Account__c = acc.Id;
        pp.Frequency__c = 'Every 15 Days';
        pp.Number_of_Payments__c = '2';
        pp.Partial_Payment_Plan_Term__c = 10;
        pp.Collection_Case__c = cc.Id;
        insert pp;
        return pp;
    }
    
    /*
		<-------------------- Generate Logins ------------------------->
	*/ 
    
    public static List<Login__c> testGenerateLogins(List<Contact> testContacts){
        /*List<Contact> contacts = [SELECT Id, Email 
                                  FROM Contact 
                                  WHERE Login__c = null AND Email != null AND Id IN 
                                 (SELECT Client_Signer_1__c	 
                                  FROM Application__c
                                  WHERE Client_Signer_1__c != null AND (Status__c Like 'Application - Approved' OR status__c like 'Contract - %') AND Cancelled__c = false
                                 )];*/
        

        List<Login__c> newLogins = getLoginFromContacts(testContacts);
        return newLogins;
        //List<Login__c> newLogins = getLoginFromContacts(testList);
    }
    
    public static List<Login__c> createLoginsForEmails(Set<String> emails){
    	List<Login__c> toInsert = new List<Login__c>();
    	//generate login obj from emails
    	for(String email : emails){
    		Login__c newLogin = new Login__c();
            newLogin.Username__c = email;
            newLogin.Email__c = email;
            newLogin.Inactive__c = false;
            newLogin.Master__c = true;
            newLogin.First_Login_With_Password__c = true;
            newLogin.Created_Login_Email_Sent__c = false;
            toInsert.add(newLogin);
    	}
    	
    	//insert logins with no pass
        insert toInsert;
        
        //retrieve created logins' Ids
        Map<Id, Login__c> idToLogin = new  Map<Id, Login__c>();
        for(Login__c l : toInsert){
            idToLogin.put(l.Id, l);
        }
        
        //generate passwords for created logins
        List<Login__c> aux = [SELECT CreatedDate FROM Login__c WHERE Id IN :idToLogin.keySet()];
        List<Login__c> toUpdate = new List<Login__c>();
        for(Login__c newLogin : aux){
            String password = generateRandomString(PASS_SIZE);
            String key = generateCryptoKeyString(KEY_SIZE);
            String iv = newLogin.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00';
            
            newLogin.HashKey__c = key;
            newLogin.email_psw__c = password;
            newLogin.Password__c = encryptString(password, iv, key);
            toUpdate.add(newLogin);
        }
        
        //update logins
        update toUpdate;
        
        return toUpdate;
    }
    
    public static List<Login__c> getLoginFromContacts(List<Contact> contacts){    	
    	Map<String, Contact> emailToContact = new Map<String, Contact>();
    	List<Login__c> toInsert = new List<Login__c>();
        //generate login obj from contact
        for(Contact contact : contacts){
            emailToContact.put(contact.Email, contact);
            
            Login__c newLogin = new Login__c();
            newLogin.Username__c = contact.Email;
            newLogin.Email__c = contact.Email;
            newLogin.Inactive__c = false;
            newLogin.Master__c = true;
            newLogin.First_Login_With_Password__c = true;
            newLogin.Created_Login_Email_Sent__c = false;
            toInsert.add(newLogin);
        }
        
        //insert login with no pass
        insert toInsert;
        
        //retrieve created logins' Ids
        Map<Id, Login__c> idToLogin = new  Map<Id, Login__c>();
        for(Login__c l : toInsert){
            idToLogin.put(l.Id, l);
        }

        //generate passwords for created logins
        List<Login__c> aux = [SELECT CreatedDate FROM Login__c WHERE Id IN :idToLogin.keySet()];
        List<Login__c> toUpdate = new List<Login__c>();
        for(Login__c newLogin : aux){
            String password = generateRandomString(PASS_SIZE);
            String key = generateCryptoKeyString(KEY_SIZE);
            String iv = newLogin.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00';
            
            newLogin.HashKey__c = key;
            newLogin.email_psw__c = password;
            newLogin.Password__c = encryptString(password, iv, key);
            toUpdate.add(newLogin);
        }
        
        //update logins
        update toUpdate;
        
        //update contacts
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Id loginId : idToLogin.keySet()){
        	Login__c loginTemp = idToLogin.get(loginId);
        	Contact contactTemp = emailToContact.get(loginTemp.Email__c);
        	contactTemp.Login__c = loginId;
        	contactsToUpdate.add(contactTemp);
        }
        update contactsToUpdate;
        
        //return logins
        return toUpdate;
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
    
    public static String generateCryptoKeyString(Integer size){
        return EncodingUtil.base64Encode(Crypto.generateAesKey(size));
    }
    
    public static String encryptString(String dataToEncrypt, String initializationVector, String HashKey){
        Blob blobCryptoKey = Blob.valueOf(HashKey);//hashkey para o metodo decrypt
        Blob blobInitializationVector = Blob.valueOf(initializationVector);//InitializationvVector desincriptar
        Blob blobData = Blob.valueOf(dataToEncrypt);
        Blob blobEncryptedData =  Crypto.encrypt('AES256', blobCryptoKey, blobInitializationVector, blobData);
        return EncodingUtil.base64Encode(blobEncryptedData);
    }
    
    
    // --------------------------------- Postal Code
    
    public static void getLimitsForDistrict(){
    	Map<String, List<Decimal>> districtToCodes = new Map<String, List<Decimal>>();
    	List<Postal_Code__c> postalCodes = [SELECT Distrito__c, CP_Min__c, CP_Max__c FROM Postal_Code__c WHERE Distrito__c != null];
    	
    	for(Postal_Code__c pc : postalCodes){
    		List<Decimal> aux;
    		if(districtToCodes.containsKey(pc.Distrito__c)){
    			aux = districtToCodes.get(pc.Distrito__c);
    		}
    		else{
    			aux = new List<Decimal>();
    		}
    		aux.add(pc.CP_Min__c);
    		aux.add(pc.CP_Max__c);
    		districtToCodes.put(pc.Distrito__c, aux);
    	}
    	
    	for(String district : districtToCodes.keySet()){
    		List<Decimal> codes = districtToCodes.get(district);
    		codes.sort();//default ASC order
    		Decimal minCode = codes.get(0);
    		Decimal maxCode = codes.get(codes.size()-1);
    		system.debug(district + ' :: '+minCode + ' -> '+ maxCode);
    	}
    }
}