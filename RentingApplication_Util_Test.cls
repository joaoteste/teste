@isTest
public class RentingApplication_Util_Test {    
    
    private static list<c2g__codaGeneralLedgerAccount__c> clientesNacionais = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name = '21111 - CLIENTES NACIONAIS' LIMIT 1]; 
    
    static public String createDunningAlert(String cc, String reminder){
        String level='';
        if(reminder=='1st Reminder')
            level='1';
        else if(reminder=='2nd Reminder')
            level='2';
        else if(reminder=='3rd Reminder')
            level='3';
        else if(reminder=='4th Reminder')
            level='4';
        
        Dunning_Alert__c da3 = new Dunning_Alert__c();
        da3.Dunning_Level__c=reminder;
        da3.Level__c=level;
        da3.Status__c='Open';
        da3.Collection_Case__c=cc;
        da3.Sent_Date__c=date.today().addDays(-8);
        da3.Due_Date__c=date.today().addDays(-1);
        da3.Email_Send_Date__c=date.today().addDays(-8);
        insert da3;
        
        return da3.Id;
    }    
    
    static public void createDunningAdmin(){
        
        //insert dunning admin
        Dunning_Admin__c dadmin = new Dunning_Admin__c();
        dadmin.Dunning_Level__c = '1st Reminder';
        dadmin.Nr_of_Days_to_Pay__c=1;
        dadmin.Active__c='Yes';
        dadmin.Dunning_Frequency__c=4;
        dadmin.Email_Template__c='Primeiro_Aviso_ou_Interpelacao';
        dadmin.Past_Due_Days__c=7; 
        insert dadmin;
        
        Dunning_Admin__c dadmin2 = new Dunning_Admin__c();
        dadmin2.Dunning_Level__c = '2nd Reminder';
        dadmin2.Nr_of_Days_to_Pay__c=1;
        dadmin2.Active__c='Yes';
        dadmin2.Dunning_Frequency__c=4;
        dadmin2.Email_Template__c='Segundo_Aviso_ou_Interpelacao';
        dadmin2.Past_Due_Days__c=7;
        insert dadmin2;
        
        Dunning_Admin__c dadmin3 = new Dunning_Admin__c();
        dadmin3.Dunning_Level__c = '3rd Reminder';
        dadmin3.Nr_of_Days_to_Pay__c=1;
        dadmin3.Active__c='Yes';
        dadmin3.Dunning_Frequency__c=4;
        dadmin3.Email_Template__c='Terceiro_Aviso_ou_Interpelacao';
        dadmin3.Past_Due_Days__c=7;
        insert dadmin3;
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = createProduct('1.º Aviso ou interpelação','PT04');
        Product2 prod2 = createProduct('2.º Aviso ou interpelação','PT04');
        Product2 prod3 =createProduct('3.º Aviso ou interpelação','PT04');
      
        PricebookEntry pbe = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod.id, IsActive = true, UseStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod2.id, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        PricebookEntry pbe3 = new PricebookEntry(UnitPrice=100,Pricebook2Id=pricebookId,Product2Id=prod3.id, IsActive = true, UseStandardPrice = false);
        insert pbe3;
        
        Dunning_Product__c dp = new Dunning_Product__c();
        dp.Dunning_Admin__c=dadmin.id;
        dp.Product__c=prod.id;
        insert dp;
        
        Dunning_Product__c dp2 = new Dunning_Product__c();
        dp2.Dunning_Admin__c=dadmin2.id;
        dp2.Product__c=prod2.id;
        insert dp2;
        
        Dunning_Product__c dp3 = new Dunning_Product__c();
        dp3.Dunning_Admin__c=dadmin3.id;
        dp3.Product__c=prod3.id;
        insert dp3;
    }
    
    public static c2g__codaGeneralLedgerAccount__c createGeneralLedgerAccount(){
        c2g__codaGeneralLedgerAccount__c generalLedgerAcc = new c2g__codaGeneralLedgerAccount__c();
        generalLedgerAcc.Name= '21110 - CLIENTES NACIONAIS';
        generalLedgerAcc.c2g__ReportingCode__c='21110';
        generalLedgerAcc.c2g__Type__c = 'Profit and Loss';
        insert generalLedgerAcc;    
        
        return generalLedgerAcc;
    }
    
    public static c2g__codaTaxCode__c createCodaTaxCode(String Region, c2g__codaGeneralLedgerAccount__c generalLedgerAccount){
        c2g__codaTaxCode__c tax = new c2g__codaTaxCode__c();
        tax.Name = 'textTax';
        tax.c2g__Description__c ='testTax description';   
        tax.c2g__GeneralLedgerAccount__c=generalLedgerAccount.id;
        tax.Country__c = 'Portugal';
        tax.Area__c = Region;
        
        insert tax;
        return tax;
    }
    
   public static Product2 createProduct(String productName, String code){
        Product2 prod = new Product2(name = productName,ProductCode = code);
        insert prod;
        return prod;
    }
    
    public static Product2 createProductRegion(String Name, String code,c2g__codaTaxCode__c codaTaxCode){
        Product2 prod = new Product2();
        prod.ProductCode = code;
        prod.c2g__CODATaxCode__c = codaTaxCode.Id;
        prod.c2g__CODAInputTaxCode__c = codaTaxCode.Id;
        prod.Name = Name;
        
        insert prod;
        return prod;
    }
    
    static public Account createAccount(String clientName, String accountType, String nif, c2g__codaTaxCode__c taxCode){
        Account account = new Account();
        account.Name = clientName; 
        account.Type = accountType;
        account.BillingCity = 'Lx';
        account.BillingCountryCode = 'PT';
        account.BillingPostalCode = '1000-423';
        account.NIF__c = nif;
        account.BillingCountry = 'Portugal';
        
        if (UTIL_PostCode.getRegionFromPostCode(account.BillingPostalCode)==null){
            createRegion();
        }
        
        account.BillingStreet = 'BillingStreet';
        account.Website = 'webSite';
        account.Phone = '00351964639755';
        account.Fax = '00351964639755';
        account.FormaObrigar_Val__c = 1;
        account.Credit_Line_Status__c = 'Credit Line - Approved';
        account.c2g__CODAAccountTradingCurrency__c = 'EUR';
        account.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        account.c2g__CODATaxCalculationMethod__c = 'Gross';
        if (!clientesNacionais.isEmpty()){
            account.c2g__CODAAccountsReceivableControl__c = clientesNacionais[0].Id;
        }
        account.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        if(taxCode == null){
            taxCode = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'VCONT23'];
        }
        account.c2g__CODAInputVATCode__c = taxCode.id; //'a3e24000000HWMt';        
        
        insert account;
        return account;
    }
    
    static public Account createAccount(String clientName, String accountType, String nif){
        Account account = new Account();
        account.Name = clientName; 
        account.Type = accountType;
        account.BillingCountryCode = 'PT';        
        account.BillingCity = 'Lx';
        account.BillingPostalCode = '1000-423';
        account.NIF__c = nif;
        account.BillingCountry = 'Portugal';
        
        if (UTIL_PostCode.getRegionFromPostCode(account.BillingPostalCode)==null){
            createRegion();
        }
        
        account.BillingStreet = 'BillingStreet';
        account.Website = 'webSite';
        account.Phone = '00351964639755';
        account.Fax = '00351964639755';
        account.FormaObrigar_Val__c = 1;
        account.Credit_Line_Status__c = 'Credit Line - Approved';
        account.c2g__CODAAccountTradingCurrency__c = 'EUR';
        account.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        account.c2g__CODATaxCalculationMethod__c = 'Gross';
        if (!clientesNacionais.isEmpty()){
          account.c2g__CODAAccountsReceivableControl__c = clientesNacionais[0].Id;
        }
        account.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
        c2g__codaTaxCode__c taxCode = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'VCONT23'];
        account.c2g__CODAInputVATCode__c = taxCode.id; //'a3e24000000HWMt';        
        
        insert account;
        return account;
    }    
    
    public static void createRegion(){
        
        Postal_Code__c postalCode = new Postal_Code__c();
        postalCode.CP_Max__c = 8970;
        postalCode.CP_Min__c = 1000;
        postalCode.Region__c = 'Mainland';
        postalCode.Concelho__c = 'Lisboa';
        postalCode.Name = 'PARA-1000';
        
        insert postalCode;            
    }
    
    
    public ATM_Reference__c createATMReference(Decimal value, Decimal reference, ID dunningAlert, ID pc){
        ATM_Reference__c atm = new ATM_Reference__c();
        atm.Amount__c = value;
        atm.Entity__c = 10611;
        atm.MB_Reference__c = reference;  
        atm.Payment_Collection__c = pc; 
        atm.Dunning_Alert__c = dunningAlert;
        atm.ATM_Reference__c = String.valueOf(reference);
        insert atm;    
        return atm;
    }
    
    static public ID createCollectionCase(String clientID){
        Collection_Case__c cc = new Collection_Case__c();
        cc.Account__c = clientID;
        cc.Status__c = 'Open';
        cc.Amount_Claimed__c = 12.30;
        insert cc;
        return cc.ID;
    }   
    
    static public Vendor_Invoice__c createVendorInvoice (ID accountId, ID applicationID){
 		Vendor_Invoice__c vendorInvoice = new Vendor_Invoice__c();
 		vendorInvoice.Account__c = accountId;
		vendorInvoice.Application__c = applicationID;

 		vendorInvoice.Invoice_Date__c = Date.today();
 		vendorInvoice.Due_Date__c = Date.today();
 		
 		vendorInvoice.Invoice_Total__c = 1029.27;
 		vendorInvoice.Status__c = 'Draft';
 		vendorInvoice.Vendor_Invoice_Number__c = '221222555';
 		vendorInvoice.Submitted__c = true;
        insert vendorInvoice;
        
        Attachment attch = new Attachment();
        attch.body=EncodingUtil.base64Decode('body');
        attch.Name='Factura'; 
        attch.ParentID=vendorInvoice.Id;
        insert attch;
 	 	
 	 	
 	 	return vendorInvoice;
    }
    
    public Map<String, String> environment1(){
        Map<String, String> infoMap = new Map<String,String>();
        Account client = createAccount('Manuel','Customer - Channel','123465789', null);
            infoMap.put('client', client.Id);
        system.debug(Limits.getQueries());
        Account vendor = createAccount('Informatica','Channel Partner / Vendor','123456788', null);
            infoMap.put('vendor', vendor.Id);
        system.debug(Limits.getQueries());        
        String appID = createApplication(client,vendor);
            infoMap.put('appID', appID);
        system.debug(Limits.getQueries());        
        String ccID = createCollectionCase(client.Id);
            infoMap.put('ccID', ccID);    
        system.debug(Limits.getQueries());        
        String dAlert = createDunningAlert(ccID,'1st Reminder');
            infoMap.put('dAlert', dAlert);
        system.debug(Limits.getQueries());        
        String bcID = createBillingContract('AP-00250', client.ID, vendor.ID, appID, ccID);
            infoMap.put('bcID', bcID);    
        system.debug(Limits.getQueries());        
        updateCC(bcID, appID, ccID);
        system.debug(Limits.getQueries());        
        c2g__codainvoice__c salesInvoice = FinancialForce_Util_Test.createInvoice(ccID, client.Id, appID);   
            infoMap.put('salesInvoice', salesInvoice.ID);
        system.debug(Limits.getQueries());            
        String pc = createPaymentCollection(salesInvoice, client);
            infoMap.put('pc', pc); 
        system.debug(Limits.getQueries());            
        ATM_Reference__c atm = createATMReference(12.30,606300991, dAlert, pc);
            infoMap.put('atm', atm.ID);      
        system.debug(Limits.getQueries());            
        createLineItems(pc, salesInvoice);                       
        system.debug(Limits.getQueries());            
        return infoMap;
    } 
    
    static void updateCC(ID bcID, ID appID,ID ccID){
        Collection_Case__c cc = [SELECT ID FROM Collection_Case__c WHERE ID=:ccID];
        cc.Billing_Contract__c = bcID;
        cc.Application__c = appID;
        update cc;
    }    
    
    public static ID createBillingContract(String apName, ID clientID, ID vendorID, ID appID, ID cc){
        
        //RecordType recordType = [Select Id From RecordType where DeveloperName='Active_Insurance' Limit 1];
        
        Billing_Contract__c BillCont = New Billing_Contract__c(Name=apName, Account__c=clientID, Account_Vendor__c=vendorID, 
                                                              Contract_Start_Date__c= date.today(),
                                                             Billing_Date_Override__c=date.today(), application__c=appID,/*
                                                             RecordTypeId = recordType.ID, */Collection_Case__c = cc, Equipment_Cost__c = 1000.20 );
        insert BillCont;
        
        return BillCont.ID;
    }         
    
    public Map<String, String> environment2(){ 
        Map<String, String> infoMap = new Map<String,String>();
        Account client = createAccount('Joao','Customer - Channel','123456777', null);
            infoMap.put('client', client.Id);
        Account vendor = createAccount('Bricolage','Channel Partner / Vendor','123456666', null);
            infoMap.put('vendor', vendor.Id);
        String appID = createApplication(client,vendor);  
            infoMap.put('appID', appID);
        String ccID = createCollectionCase(client.Id); 
            infoMap.put('ccID', ccID);
        String dAlert = createDunningAlert(ccID,'1st Reminder');
            infoMap.put('dAlert', dAlert);
    
        c2g__codainvoice__c salesInvoice = FinancialForce_Util_Test.createInvoice(ccID, client.Id, appID);   
            infoMap.put('salesInvoice', salesInvoice.ID);
        String pc = createPaymentCollection(salesInvoice, client);
            infoMap.put('pc', pc);
            
        String bcID = createBillingContract('AP-00250', client.ID, vendor.ID, appID, ccID);
            infoMap.put('bcID', bcID);              
            
        ATM_Reference__c atm = createATMReference(12.30,509999902, dAlert, pc);
            infoMap.put('atm', atm.ID);       
                      
        createLineItems(pc, salesInvoice);  
                                
        return infoMap;
    }    
    
    public Map<String, String> environment4(){
        Map<String, String> infoMap = new Map<String,String>();
        Account client = createAccount('Joao','Customer - Channel','123456777', null);
            infoMap.put('client', client.Id);
        Account vendor = createAccount('Bricolage','Channel Partner / Vendor','123456666', null);
            infoMap.put('vendor', vendor.Id);
        String appID = createApplication(client,vendor);
            infoMap.put('appID', appID);
        String ccID = createCollectionCase(client.Id);
            infoMap.put('ccID', ccID);
        String dAlert = createDunningAlert(ccID,'1st Reminder');
            infoMap.put('dAlert', dAlert);
   
        c2g__codainvoice__c salesInvoice = FinancialForce_Util_Test.createInvoice(ccID, client.Id, appID,false,'To be Send');   
            infoMap.put('salesInvoice', salesInvoice.ID);
            
        String pc = createPaymentCollection(salesInvoice, client);
            infoMap.put('pc', pc);
            
        ATM_Reference__c atm = createATMReference(12.30,509999902, dAlert, pc);
            infoMap.put('atm', atm.ID);       
                      
        createLineItems(pc, salesInvoice);  
                                
        return infoMap;
    }    
    
    
    public Map<String, String> environment5(){
        Map<String, String> infoMap = new Map<String,String>();
        Account client = createAccount('Joao','Customer - Channel','123456777', null);
            infoMap.put('client', client.Id);
        Account vendor = createAccount('Bricolage','Channel Partner / Vendor','123456666', null);
            infoMap.put('vendor', vendor.Id);
        String appID = createApplication(client,vendor);
            infoMap.put('appID', appID);
        String ccID = createCollectionCase(client.Id);
            infoMap.put('ccID', ccID);
        String dAlert = createDunningAlert(ccID,'1st Reminder');
            infoMap.put('dAlert', dAlert);
   
        c2g__codaCreditNote__c creditNote = FinancialForce_Util_Test.createCreditNote(ccID, client.Id, appID, false,'To be Send');   
            infoMap.put('creditNote', creditNote.ID);
                                
        return infoMap;
    }    
    
    public static Map<String, String> environment6(){
        Map<String, String> infoMap = new Map<String,String>();
        Account client = createAccount('Joao','Customer - Channel','123456777', null);
            infoMap.put('client', client.Id);
        Account vendor = createAccount('Bricolage','Channel Partner / Vendor','123456666', null);
            infoMap.put('vendor', vendor.Id);
        String appID = createApplication(client,vendor);
            infoMap.put('appID', appID);
        String ccID = createCollectionCase(client.Id);
            infoMap.put('ccID', ccID);
        String dAlert = createDunningAlert(ccID,'1st Reminder');
            infoMap.put('dAlert', dAlert);
   
        c2g__codaCreditNote__c creditNote = FinancialForce_Util_Test.createCreditNote(ccID, client.Id, appID, true,'To be Send');   
            infoMap.put('creditNote', creditNote.ID);
                                
        return infoMap;
    }   
 
    
    public static ID createBillingContract(String apName, ID clientID, ID vendorID, ID appID){
        
        //RecordType recordType = [Select Id From RecordType where DeveloperName='Active_Insurance' Limit 1];
        
        Billing_Contract__c BillCont = New Billing_Contract__c(Name=apName, Account__c=clientID, Account_Vendor__c=vendorID, 
                                                              Contract_Start_Date__c= date.today(),
                                                              Billing_Date_Override__c=date.today(), application__c=appID,
                                                              Equipment_Cost__c = 1000.20 
                                                               /*,RecordTypeId = recordType.ID*/ );                                                   
                              
        insert BillCont;
        
        return BillCont.ID;
    }             
   
    public static AssignmentContract__c createAssignmentOfContract(ID oldAccount, ID newAccount, ID appID, ID bcID){

        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId= newAccount;
        insert contact;
        
        AssignmentContract__c ac = new AssignmentContract__c();             
        ac.New_Client_Signer_1__c = contact.ID;
        ac.New_Client_Signer_2__c = contact.ID;
        ac.New_Client_Signer_3__c = contact.ID;
        ac.New_Client_Signer_4__c = contact.ID;  
        ac.Old_Client_Signer_1__c = contact.ID;
        ac.Old_Client_Signer_2__c = contact.ID;
        ac.Old_Client_Signer_3__c = contact.ID;
        ac.Old_Client_Signer_4__c = contact.ID;  
        ac.Invoice_To__c = contact.ID;                          
        ac.New_Client_Account__c = newAccount;
        ac.Old_Client_Account__c = oldAccount;
        ac.Renting_Application__c = appID;
        ac.Billing_Contract__c = bcID;
        ac.Merge_Company__c = false;
        ac.Status__c = 'Aproved';
        ac.New_Invoice_Email__c = 'test@test.pt';
        ac.New_Client_Account__c = oldAccount;
        ac.Invoice_Receiver__c = 'New Client';
        
        insert ac;
        
        return ac;
    }
 
    
    private ID createPaymentCollection(c2g__codainvoice__c si, Account act){
        Payment_Collection__c pc = new Payment_Collection__c();
        pc.Account__c = act.Id;
        pc.Expiry_Date__c = si.c2g__DueDate__c;
        pc.Period__c = si.c2g__Period__c;
        pc.Status__c = 'In Payment';
        pc.Payment_Method__c = 'ATM Reference';
        insert pc;
        return pc.ID;
    }

    
    private Id createLineItems(ID paymentCollection, c2g__codainvoice__c si){

        //receipt line item
        
        Receipt_Line_Item__c rli = new Receipt_Line_Item__c();
        rli.Payment_Collection__c = paymentCollection;
        rli.Amount_Claimed__c = si.c2g__InvoiceTotal__c;
        rli.Attempts__c = 1;
        rli.First_try__c = system.today();
        rli.Invoice__c = si.Id;
        rli.Renting_Application__c = si.Application__c;
        
        insert rli;

        return rli.Id;           
    }        
 
    public ID environment3(){
        Account client = createAccount('Manuel','Customer - Channel','123456555', null);
        Account vendor = createAccount('Informatica','Channel Partner / Vendor','123456444', null);
        String appID = createApplication(client,vendor);
        String ccID = createCollectionCase(client.Id);
        return createDunningAlert(ccID,'1st Reminder');
    }
    
    public static Application__c createApplicationWithStartDate(Account client, Account vendor,Date StartDate){
        
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId= vendor.Id;
        insert contact;
        system.debug('contact ID: ' + contact.ID);
        
        Contact contactClient =new contact();
        contactClient.LastName = 'Client';
        contactClient.Email = 'test@client.com';
        contactClient.Role__c='Client';
        contactClient.AccountId= client.Id;
        insert contactClient;
        system.debug('contact ID: ' + contactClient.ID);
        
        Application__c app= new Application__c(Vendor__c=vendor.id, AccClient__c=client.ID, Vendor_Primary__c=contact.id );
        app.Delivery_Certificate_Sent__c = StartDate;
        app.First_Beginning_Of_Term__c = StartDate;
        app.TermCalc__c = 36;
        
        app.ATM_Reference__c = TRUE;
        app.ATM_Reference_Costs__c = 2;
        //app.Chosen_Insurance_value__c
        app.Insurance_Value__c = 1;
        app.Insurance_Type__c = 'Static Risk';
        
        app.Invoice_To__c = contact.ID;
        app.status__c = 'Contract - Running';
        app.Obs_Invoice__c = 'App Notes';
        app.Client_Signer_1__c = contactClient.Id;              
        
        insert app;
        
        System.debug('app ' + app);
        
        return app;
    }
    
    static public ID createApplication(Account client, Account vendor){     
        
        Contact contact=new contact();
        contact.LastName = 'Doe1';
        contact.Email = 'test1@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId= vendor.Id;
        insert contact;
        system.debug('contact ID: ' + contact.ID);
        
        Contact contactClient =new contact();
        contactClient.LastName = 'Client';
        contactClient.Email = 'test@client.com';
        contactClient.Role__c='Client';
        contactClient.AccountId= client.Id;
        insert contactClient;
        system.debug('contact ID: ' + contactClient.ID);
        
        /*Login__c login = new Login__c();
        login.IdVendor__c = vendor.Id;
        login.Vendor_Vendor__c = contact.Id;
        login.Username__c = UserInfo.getUserName();
        insert login;
        system.debug('login ID: ' + login.ID);*/
        
        Application__c app= new Application__c(Vendor__c=vendor.id, AccClient__c=client.ID, Vendor_Primary__c=contact.id );
        app.Invoice_To__c = contact.ID;
        app.status__c = 'Contract - Running';
        app.Obs_Invoice__c = 'App Notes';
        app.Client_Signer_1__c = contactClient.Id;
        app.Client_Signer_2__c = contactClient.Id;
        app.Client_Signer_3__c = contactClient.Id;
        app.Client_Signer_4__c = contactClient.Id; 
        app.Delivery_Certificate_Sent__c = system.today();
        app.First_Beginning_Of_Term__c = system.today();
        app.TermCalc__c = 36;
        app.Equipment_Cost__c = 1000.00;
              
        insert app;
        
        return app.Id;
        
    }
    
    //returns the current period ID
    public ID getPeriod(){      
        Date d = Date.today();
        system.debug(LoggingLevel.INFO, 'c2g__codaPeriod__c getPeriod periodDate' + d.format());
        Date periodDate = Date.newInstance(d.year(), d.month(), d.day());
        return getPeriod(periodDate).Id;
    }
    
    //given a date returns the period associated
    public c2g__codaPeriod__c getPeriod(date periodDate) {
        system.debug(LoggingLevel.INFO, 'c2g__codaPeriod__c getPeriod periodDate' + periodDate);
        c2g__codaPeriod__c currentPeriod = [SELECT ID FROM c2g__codaPeriod__c where c2g__StartDate__c <= :periodDate AND c2g__EndDate__c >= :periodDate];
        return currentPeriod;
    }

    public static ID createBillingContractLineItem(ID appID, ID billngContractID, product2 prod, String taxLocation){
        taxLocation.toLowerCase();
        c2g__codaTaxCode__c taxCode;   
        if(taxLocation.equals('mainland')){
            taxCode = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'VCONT23'];          
        }
        if(taxLocation.equals('azores')){
            taxCode = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'VAC18'];            
        }
        if(taxLocation.equals('madeira')){
            taxCode = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'VMAD22'];
        }
        String billingPeriod = BILL_BillingProcess.PAYMENT_FREQ_MONTHLY;  
        String Period = BILL_BillingProcess.setBillingPeriod(prod.name, date.today(), 'PT', billingPeriod);
        
        Billing_Contract_Line_Item__c BillContLI = New Billing_Contract_Line_Item__c(Product_Tax_Code__c = taxCode.ID, Billing_Contract__c = billngContractID, 
                                                                                   Billing_Period__c = Period, Product__c = prod.ID,
                                                                                   Line_Item_Start_Date__c = date.today(), Line_Item_End_Date__c = date.today().addDays(5),
                                                                                   Quantity__c = 1, Sales_Price__c = 200.20
                                                                                  );       
        insert BillContLI;
        return BillContLI.ID;
    }             
    
    public Map<String, String> environment7(){
        Map<String, String> infoMap = new Map<String,String>();
        Account client = createAccount('Manuel','Customer - Channel','123465789', null);
            infoMap.put('client', client.Id);
        system.debug('1 :' +Limits.getQueries());
        Account vendor = createAccount('Informatica','Channel Partner / Vendor','123456788', null);
            infoMap.put('vendor', vendor.Id);
        system.debug('2 :' +Limits.getQueries());        
        String appID = createApplication(client,vendor);
            infoMap.put('appID', appID);
        system.debug('3 :' +Limits.getQueries());        
        String bcID = createBillingContract('AP-00250', client.ID, vendor.ID, appID);
            infoMap.put('bcID', bcID);    
        system.debug('4 :' +Limits.getQueries());        
        //updateCC(bcID, appID, NULL);
        system.debug('5 :' +Limits.getQueries());        
        c2g__codainvoice__c salesInvoice = FinancialForce_Util_Test.createInvoice(NULL, client.Id, appID);   
            infoMap.put('salesInvoice', salesInvoice.ID);
        system.debug('6 :' +Limits.getQueries());            
        String pc = createPaymentCollection(salesInvoice, client);
            infoMap.put('pc', pc); 
        system.debug('7 :' +Limits.getQueries());       
        ATM_Reference__c atm = createATMReference(12.30,606300991, null, pc);
            infoMap.put('atm', atm.ID);           
        system.debug('8 :' +Limits.getQueries());            
        Id rliId = createLineItems(pc, salesInvoice);
        infoMap.put('rli', rliId);                      
        system.debug('9 :' +Limits.getQueries());            
        Product2 prod = createProduct('1.º Aviso ou interpelação','PT04');
          infoMap.put('product', prod.ID);
        String bcliID = createBillingContractLineItem(appID, bcID, prod, 'madeira');
        infoMap.put('bcli', bcliID);  
        String bcliID2 = createBillingContractLineItem(appID, bcID, prod, 'madeira');
        infoMap.put('bcli2', bcliID2);
        return infoMap;
    }
    static public Contact createContact(String AccId, String email){	
    	Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = email;
        contact.Role__c ='Binding Power';
        contact.Send_Invoice__c =true;
        contact.AccountId = AccId;
        insert contact;
        return contact;
    }

    public static Login__c createLogin(String accountId, String contactId, String email ){
    	Login__c login = new Login__c();
        login.Email__c = email;
        login.Username__c = email;
        login.Password__c = 'aMinhaPw';
		login.IdVendor__c = accountId;
        login.Vendor_Vendor__c = contactId;
        insert login;
        return login;
    }

   public Case createCase(Id Acc, String subject, String description, Id ContactID){
        case newCase = New Case(AccountId = Acc,
                                ContactId = ContactID,
                                Status ='New',
                                Priority='High',               
                                Subject =subject,
                                Description=description
                               );
        insert newCase;
		return newCase;
    }

    public caseComment createCaseComment(Id caseID, String CommBody){
        caseComment newCaseComment =new CaseComment(
                         CommentBody = CommBody,
                          ParentId = caseID
                          );
        insert newCaseComment;
        return newCaseComment;
    }

    public Attachment createAttachment(id caseId){
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=caseId;
        insert attach;
        return attach;
    }

    public static Session__c createSession(Login__c login, String sessionToken ){
        Session__c testSession = new Session__c();
        testSession.Login__c = login.Id;
        testSession.token__c = sessionToken;
        testSession.LastLogin__c = Date.today();
        testSession.PasswordS__c = login.Password__c;
        insert testSession;
        return testSession;
    }

    /*  
     * Partner Envoirmnent
     */
    public Map<String, String> environment8(){
        Map<String, String> infoMap = new Map<String,String>();

        String emailCliente = 'cliente@exemploecliente.pt';
        String emailParceiro = 'parceiro@exemploparceiro.pt';

        Account client = createAccount('Manuel','Customer - Channel','123465789', null);
        Account vendor = createAccount('Informatica','Channel Partner / Vendor','123456788', null);

        Contact contactCliente = createContact(client.id, emailCliente);
        Contact contactVendor = createContact(vendor.id , emailParceiro);
        System.debug(client.id);
        System.debug(client.id);
        Login__c clientLogin = createLogin(client.id, contactCliente.id,  emailCliente);
        Login__c vendorLogin = createLogin(vendor.id, contactVendor.id,  emailParceiro);
	
		Session__c sessionClient = createSession(clientLogin, 'FVGdHcj/INKa/jdktyjNAJQWjW5bxcZ6');
        Session__c sessionVendor = createSession(vendorLogin, 'FVGdHcj/INKa/jdktyjNAJQWjW5bxcZ7');
        
        contactCliente.email = clientLogin.Email__c;
        contactCliente.Login__c= clientLogin.id;
        update contactCliente;

        contactCliente.email = clientLogin.Email__c;
        contactVendor.Login__c= vendorLogin.id;
        update contactVendor;
        
        Case case1 = createCase(client.id, 'heeelpppp', 'ajuda urgenteeeeeeee', contactCliente.id);
        Case case2 = createCase(client.id, 'heeelpppp', 'ajuda bem rapido', contactCliente.id);
        Case case3 = createCase(client.id, 'heeelpppp', 'ajuda velho', contactCliente.id);
        
        caseComment caseComment1 = createCaseComment(case1.ID,'isto aconteceu porque jesuss assim o mandou');
        caseComment caseComment2 = createCaseComment(case2.ID,'jesus disse para isto aconteceer');
        caseComment caseComment3 = createCaseComment(case3.ID,'isto aconteceu porque jesuss assim o mandou');
        
        infoMap.put('client', client.Id);
        infoMap.put('vendor', vendor.Id);
        infoMap.put('contactCliente', contactCliente.Id);
        infoMap.put('contactVendor', contactVendor.Id);
        
    	infoMap.put('sessionClient', 'FVGdHcj/INKa/jdktyjNAJQWjW5bxcZ6');
      	infoMap.put('sessionVendor', 'FVGdHcj/INKa/jdktyjNAJQWjW5bxcZ7');
        
        infoMap.put('clientLogin', clientLogin.Id);
        infoMap.put('vendorLogin', vendorLogin.Id);

        InfoMap.put('caseOne', case1.ID);
        InfoMap.put('caseTwo', case2.ID);
        InfoMap.put('caseThree', case3.ID);
        
        return infoMap;

    }
    
    public Map<String, String> environment9(){
        Map<String, String> infoMap = new Map<String,String>();
        Account client = createAccount('Manuel','Customer - Channel','123465789', null);
            infoMap.put('client', client.Id);
        system.debug('1 :' +Limits.getQueries());
        Account vendor = createAccount('Informatica','Channel Partner / Vendor','123456788', null);
            infoMap.put('vendor', vendor.Id);
        system.debug('2 :' +Limits.getQueries());        
        String appID = createApplication(client,vendor);
            infoMap.put('appID', appID);
        system.debug('3 :' +Limits.getQueries());        
        String bcID = createBillingContract('AP-00250', client.ID, vendor.ID, appID);
            infoMap.put('bcID', bcID);    
        system.debug('4 :' +Limits.getQueries());        
        //updateCC(bcID, appID, NULL);
        system.debug('5 :' +Limits.getQueries());        
        c2g__codainvoice__c salesInvoice = FinancialForce_Util_Test.createInvoice(NULL, client.Id, appID);   
            infoMap.put('salesInvoice', salesInvoice.ID);
        system.debug('6 :' +Limits.getQueries());            
        String pc = createPaymentCollection(salesInvoice, client);
            infoMap.put('pc', pc); 
        system.debug('7 :' +Limits.getQueries());       
        CR_Sepa_Record__c sepaRecord = createSEPAReference(12.30, pc);
            infoMap.put('sepaRecord', sepaRecord.ID);           
        system.debug('8 :' +Limits.getQueries());            
        Id rliId = createLineItems(pc, salesInvoice);
        infoMap.put('rli', rliId);                      
        system.debug('9 :' +Limits.getQueries());            

        return infoMap;
    }
    
    public CR_Sepa_Record__c createSEPAReference(Decimal value, ID pc){
    	
    	CR_Sepa_Record__c sepaRecord = new CR_Sepa_Record__c();
        sepaRecord.Activation_Date__c = date.today();
        sepaRecord.IBAN__c='PT5023233434123';
        sepaRecord.Payment_Collection__c = pc;
        insert sepaRecord;

        return sepaRecord;
    }
    
}