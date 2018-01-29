public class Vendor {
  
    static  boolean debug_ON = true;//(BP)
    private ID vendorID;
    private ID loginID;
    private boolean isMaster;
    private Account vendor;
    private Login__c login; 
    
    public vendor(ID loginID){
        
        this.loginID=loginID;

        List<login__c> loginList = [SELECT IdVendor__c, Master__c, Vendor_NIF__c, Username__c FROM login__c WHERE id=:loginID];
        if(loginList.size()>0){
            this.login = loginList[0];
            this.vendorID=login.IdVendor__c;    
            this.isMaster=login.Master__c;
            List<Account> vendorList = [SELECT Id, Application_Daily_Limit_Achieved__c, Insurance_Type__c,
                          Daily_Limit_Counter__c , Date_Last_Application__c, Account_Status__c,
                          (SELECT Id, Application_Daily_Limit_Achieved__c, Insurance_Type__c,
                          Daily_Limit_Counter__c , Date_Last_Application__c, Account_Status__c, Type FROM ChildAccounts WHERE Type = 'Channel Partner / Vendor')  
                          FROM account WHERE Id =: login.IdVendor__c]; 
            if(vendorList.size()>0){
                this.vendor = vendorList[0];
             //   this.vendor = vendorList[0].ChildAccounts.size()>0 ? vendorList[0].ChildAccounts[0] : null;
             //   this.vendorID = this.vendor != null ? vendorList[0].ChildAccounts[0].Id : null; 
            }
        }
    }

    public String getLogo(){
        String res = '';
        List<Attachment> ll = [select Id from Attachment where parentId=:VendorID and Name like 'Logo Partner IMG%' ];
        if(ll.size()>0)
            res=ll[0].Id;
        return res;
    }
    
    public List<application__c> getApps(){
        
        String query = '';
        String fields = getFieldsToQuery(); 

        //build query
        query = 'SELECT ' + fields;
        query += 'FROM application__c ';
        query += 'WHERE vendor__c =\'' + vendorID + '\' ';
        
        if(!isMaster){
            query += 'AND IdLoginCreate__c=\'' + loginID +'\' ';
        }
        query += ' AND (Status__c LIKE \'Application - %\' OR Status__c LIKE \'%Contract%\' OR Status__c = NULL) AND Cancelled__c = FALSE ';
        query +='ORDER BY Application_Date__c DESC';
        
        List<Application__c> clientApps = Database.query(query);

        //retira rendas não permitidas se for startup 28/09/2017 (HP)
        boolean isStartup;
        Decimal startUpMaxAge = ScoreCardConfig.getStartupMaxAge();
        for(Application__c app : clientApps){
            isStartup = false;
            if(app.AccClient__r.Date_Of_Establishment__c!=null && app.AccClient__r.Date_Of_Establishment__c.daysBetween(date.today())/365 < startUpMaxAge){
                isStartup = true;
            }
            if(isStartup){
                app.Rent_36__c = null;
                app.Rent_48__c = null;
                app.Rent_60__c = null;
                app.Rent_72__c = null;
            }
        }
        
        return clientApps;
    }
    
    //ALTERACAO - 29/12/16 - adicao do metodo getVendorInfo para obter nome,mail,contactos do vendor (BP)
    public Account getVendorInfo(){      

        String query ='SELECT ID,Name,NIF__c,Phone, BillingCity, BillingStreet, BillingPostalCode ,c2g__CODABankZipPostalCode__c,c2g__CODABankCity__c,c2g__CODABankIBANNumber__c,Email__c,c2g__CODAOutputVATCode__c,';
        query +=' (SELECT ID, Login__c, Login__r.Inactive__c, Login__r.Master__c  FROM Contacts),';
        query +=' (SELECT ID,Vendor_Vendor__r.name, Inactive__c, Master__c,Vendor_Vendor__r.Email, Vendor_Vendor__r.Title,  Vendor_Vendor__r.Description, Vendor_Vendor__r.Phone, Vendor_Vendor__r.MobilePhone FROM Login__r '; 
        
        if(!isMaster)
            query+='WHERE id= \''+loginID+'\'';
        query+=') FROM Account WHERE id=\''+vendorID+'\' ORDER BY CREATEDDATE DESC'; 
        
        List<Account>relatedAccounts=Database.query(query);
                            
        List<Login__c> relatedLogins = relatedAccounts[0].Login__r; 
        
        //Alteração devido à mudança da hierarquisação das accounts. 
        //Vais buscar login a partir do contacto das contas caso n exista logins directamente relacionados
        /*if(relatedLogins.size()<=0){
            Contact[] contactList = relatedAccounts[0].Contacts;
            Set<Id> idSets = new Set<Id>();
            for(Contact con : contactList){
                idSets.add(con.Login__c);
            }
            String queryLogin = 'SELECT ID,Vendor_Vendor__r.name, Inactive__c, Master__c,Vendor_Vendor__r.Email, Vendor_Vendor__r.Title,  Vendor_Vendor__r.Description, Vendor_Vendor__r.Phone, Vendor_Vendor__r.MobilePhone FROM Login__c ';
            if(!isMaster){
                queryLogin+='WHERE id= \''+loginID+'\'';
            }else{
                queryLogin+='WHERE id IN '+idSets;
            }
            relatedAccounts[0].Login__r = Database.query(queryLogin);
        }*/
        
        if(debug_ON)
        {
            System.debug('relatedLogins: '+ relatedLogins);
            for(Login__c aux: relatedLogins)
                System.debug('aux = '+ aux); 
            //{IdVendor__c,Id,Vendor_Vendor__c} como não consegue passar de uma relacao de 3 objectos se quiser-se 
            //                                                      chegar ao 4º por __r relationship ele devolve apenas os ids em questÃ£o (BP)
        }
        return relatedAccounts[0];
    }
    
    public List<application__c> getApprovedApps(ID clientID){

        String query = 'SELECT Status__c, Client_Name__c, AccClient__c, Name, Application_Date__c,';
        query += 'Equipment_Cost__c, Days_To_Sign_Contract__c, Number_Of_Notifications__c, Reject_Reason__c, Pendent_Actions__c,'; 
        query += 'Available_Credit_Line__c, AccClient__r.Risk_Type__c, Cancelled__c ';
        query += 'FROM application__c ';
        query += 'WHERE vendor__c =\'' + vendorID + '\' AND Status__c IN (\'Application - Approved\') AND Cancelled__c = false AND AccClient__c=\'' + clientID + '\' ';

        if(!isMaster){
            query += 'AND IdLoginCreate__c=\'' + loginID +'\' ';
        }

        query+='ORDER BY Application_Date__c DESC';
        system.debug('getApprovedApps query: ' + query);

        List<Application__c> clientApps = Database.query(query);

        return clientApps;
    }

    public List<application__c> getContractApps(){

        String fields = getFieldsToQuery();
        String query = 'SELECT ' + fields;
        query += ' FROM application__c ';
        query += 'WHERE vendor__c =\'' + vendorID + '\' AND Status__c LIKE \'%Contract%\' AND Cancelled__c = false ';

        if(!isMaster){
            query += 'AND IdLoginCreate__c=\'' + loginID +'\' ';
        }

        query+='ORDER BY Application_Date__c DESC';
        system.debug('getContractApps query: ' + query);

        List<Application__c> clientApps = Database.query(query);

        return clientApps;
    }

    private String getFieldsToQuery(){
        String query = '';
        String fields = '';

        //fields to query
        fields += 'Id, Name, Application_Date__c, Status__c, AccClient__c, Vendor__r.c2g__CODAOutputVATCode__c, AccClient__r.c2g__CODAInputVATCode__c,Client_Forma_Obrigar_Val__c,    ';
        fields +='Vendor__c, IdLoginCreate__c,IdLoginCreate__r.Master__c, IdLoginCreate__r.IdVendor__c, Equipment_Cost__c, Contract_Signed__c, Invoice_Payment_Date__c, Delivery_Certificate_Signed__c, ';
        fields +='Equipment_Delivery_Date__c, Issuing_Date_Invoice__c, Output_Rate_Manager__c, Term__c, Contract_Sent__c,';
        fields +='Payment_Amount__c, Output_Ins_Manager__c, Insurance_Value__c, Insurance_Movement_value__c, TermSetByUser__c, ';
        fields +='Paper_Contract__c, eSignature_Contract__c, Insurance_Type__c, Delivery_Certificate_Sent__c, Vendor__r.Term_12__c, Vendor__r.Term_24__c, ';
        fields +='Vendor__r.Term_36__c, Vendor__r.Term_48__c, Vendor__r.Term_60__c, Vendor__r.Term_72__c,';
        fields +='Available_Credit_Line__c, AccClient__r.Risk_Type__c, AccClient__r.Name, Vendor_Diluted_Doc_Interim_fee__c,';
        fields +='Vendor_Primary__r.Name, Vendor_Primary__r.Description, Vendor_Primary__r.email, Candor_Signer__r.email, Candor_Signer__r.Name, ';
        fields +='Candor_Signer__r.Title, Insurance_Special_Value__c, Payment_Freq__c, AccClient__r.NIF__c, AccClient__r.Available_Credit_Line__c,';
        fields +='AccClient__r.BillingStreet, AccClient__r.BillingPostalCode,AccClient__r.BillingCity,Rent_12__c, Rent_24__c, Rent_36__c, Rent_48__c,';
        fields +='Rent_60__c, Rent_72__c, Client_Signer_1__c,Client_Signer_2__c,Client_Signer_4__c,Client_Signer_5__c, Client_Signer_3__c, AccClient__r.c2g__CODABankIBANNumber__c, ATM_Reference_Costs__c,';
        fields +='Payment_Method__c, Observations__c, Client_Forma_Obriga__c, Vendor_Diluted_Doc_Fee__c, eSignature_Contract_Fee__c, Vendor__r.c2g__CODABankIBANNumber__c, ';
        fields +='Client_Signer_1_Delivery_Certificate__c, TermCalc__c, AccClient__r.Date_Of_Establishment__c , AccClient__r.Credit_line__c, Reject_Reason__c,Client_Signer_1__r.Email,';
        fields +='Client_Signer_2__r.Email, Client_Signer_3__r.Email, Client_Signer_4__r.Email, Client_Signer_5__r.Email, Client_Signer_1_Delivery_Certificate__r.Email, ScoreCard__c, Personal_Guarantee__c, Vendor__r.Discount_Factor__c';     
        
        String queryEquipments = '(SELECT Equipment_Quantity__c, Equipment_Description__c, Equipment_Value__c, Account_Client__c,  Application__c, Equipment_Serial_Number__c FROM Equipments__r ORDER BY CreatedDate ASC)';
        String queryVendorInvoices = '(SELECT ID, Submitted_Date__c, Account__c, Invoice_Date__c, Invoice_Total__c, Status__c, Submitted__c, Vendor_Invoice_Number__c FROM Vendor_Invoices__r ORDER BY CREATEDDATE DESC LIMIT 1)';
        String queryDocuSign = '(SELECT id, dsfs__subject__c, dsfs__Sent_Date_Time__c, dsfs__Completed_Date_Time__c, dsfs__Envelope_Status__c, dsfs__DocuSign_Envelope_ID__c, dsfs__Voided_Date_Time__c, Deleted_by_partner__c '; 
        queryDocuSign += 'FROM DocuSign_Status__r WHERE (dsfs__Envelope_Status__c NOT IN (\'Voided\', \'Deleted\') AND Deleted_by_partner__c = false) ORDER BY CreatedDate DESC )';

        return fields + ', ' + queryEquipments + ', ' + queryVendorInvoices + ', ' + queryDocuSign + ' ';
    }

    public List<Account> getClients(){
            
        String query = 'SELECT ID, name, keywords__c, NIF__c, Date_Last_Application__c, Account_Status__c, Available_Credit_Line__c, Credit_Line_Status__c, Createddate, Type, ';
        query += ' (SELECT ID, Name, Email, Description, New_Binding_Contact__c FROM Contacts WHERE shown_in_app__c = true OR New_Binding_Contact__c=true), ';
        query += ' (SELECT lastmodifieddate, Last_Request__c, Last_Request_Status__c FROM Reports_DB__r),'; //ALTERACAO - 26/05/17 - para tirar report(BP)
        query += ' (SELECT ID, Name, Account__c, Credit_Info__c, Score__c, Grade__c, Decison_Status__c, Sub_Grade__c, Decision_Origin__c, Guidance_Limit_Min__c, Guidance_Limit_Max__c, ';        
        query += ' Override__c, Active__c, Account__r.BillingCountry FROM Decisions__r WHERE Active__c = TRUE ORDER BY CREATEDDATE DESC LIMIT 1 ),';
        query += ' (SELECT ID, NAME, Reject_Reason__c,keywords__c, Status__c,Cancelled__c, Contract_sent__c, Contract_Signed__c, Delivery_Certificate_Sent__c,Delivery_Certificate_Signed__c, Application_Date__c,eSignature_Contract__c,Paper_Contract__c, ScoreCard__c FROM Clientapplications__r  WHERE VENDOR__c=\'' + VendorID + '\' ';
        if(!isMaster){query += 'AND IdLoginCreate__c=\'' + loginID +'\' ';}
        query += ' AND (Status__c LIKE \'Application - %\' OR Status__c = NULL) AND Cancelled__c = FALSE ORDER BY Application_Date__c DESC LIMIT 1 ), ';
        query += ' (SELECT id, name, dsfs__Parent_Status_Record__c, dsfs__Date_Delivered__c , dsfs__Date_Declined__c, '; 
        query += ' dsfs__Recipient_Status__c,dsfs__Docusign_Recipient_Email__c, dsfs__Contact__c, dsfs__Date_Sent__c, ';
        query += ' dsfs__Date_Signed__c , dsfs__docusign_recipient_id__c, dsfs__Account__c, dsfs__Parent_Status_Record__r.Docusign_Application_Status__c FROM R00N80000002vw3gEAA__r WHERE dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c NOT IN (\'Voided\', \'Deleted\') AND dsfs__Parent_Status_Record__r.Deleted_by_partner__c = false ) '; //HP - 06/06/2016 - Informação dos recipients no docusign associados a esta conta
        query += ' FROM Account WHERE ID IN (SELECT AccClient__c from APPLICATION__C WHERE VENDOR__c=\'' + VendorID + '\' AND Cancelled__c = FALSE AND (Status__c != \'Application - Rejected\' OR (Status__c = \'Application - Rejected\' AND Createddate = LAST_N_DAYS:8)) '; //Mantem as que tem as apps rejeitadas com menos de 8 dias
        if(!isMaster){query += 'AND IdLoginCreate__c=\'' + loginID +'\'';}
        query += ') ORDER BY LastModifiedDate DESC';
        System.debug('query e: ' + query);
        List<Account> clients = Database.query(Query);

        return clients;
    } 

    public Account getClient(Id AccountClientId){
        
        String query = 'SELECT ID, name, keywords__c, NIF__c, Date_Last_Application__c ,Available_Credit_Line__c, Credit_Line_Status__c, Createddate, ';
        query += ' (SELECT ID, NAME, Reject_Reason__c,keywords__c, Status__c,Cancelled__c, Application_Date__c,eSignature_Contract__c,Paper_Contract__c FROM Clientapplications__r  WHERE VENDOR__c=\'' + VendorID + '\' ';
        
        if(!isMaster){
            query += 'AND IdLoginCreate__c=\'' + loginID +'\' ';
        }
        
        query+=' AND Cancelled__c = FALSE ORDER BY APPLICATION_DATE__C DESC LIMIT 1) FROM Account WHERE ID = \'' + AccountClientId + '\' ORDER BY LastModifiedDate DESC';
        Account client = Database.query(Query);

        return client;
    }

    /*public Map<Id,dsfs__DocuSign_Recipient_Status__c> getDocuSignRecipientStatusFromCLientAccounts(List<Account> clientList){
        for(Account acc : clientList){
            
            if(hasSObjectField('Clientapplications__r', acc)){
                appList = acc.Clientapplications__r;
            }else{
                
            }
            for(Application__c app : appList){
                public static boolean hasSObjectField(String fieldName, SObject so)
            }
    }

    private static boolean hasSObjectField(String fieldName, SObject so){
        return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName);
    }*/

    public boolean setVendorIban (String iban){
        if(this.vendor != null){
            //TODO: change for field of FinancialForce c2g__CODABankIBANNumber__c
            //vendor.c2g__CODABankIBANNumber__c = iban;
            vendor.Country_Code__c = 'PT50';
            vendor.BBAN__c = iban.removeStart('PT50');
            //if (client.c2g__CODABankIBANNumber__c != null){
                update vendor;
                System.debug('[Vendor - setVendorIban] Iban number for vendor '+ vendor.Name + ' updated to '+ iban);
                return true;
            //}else{
            //  return false;
        //  }
        }   
        System.debug('[Vendor - setVendorIban] Failed to save iban number'+ iban +' -> account vendor not in context');
        return false;
    } 

    public String updateVendorAccountInfo(Account vendorAcc){

        if(vendor!=null){
            Account acc = new Account();
            acc.Id = vendor.Id;
            acc.Name = vendorAcc.Name;
            acc.BillingCity = vendorAcc.BillingCity;
            acc.BillingPostalCode = vendorAcc.BillingPostalCode;
            acc.BillingStreet =vendorAcc.BillingStreet;
            acc.Phone = vendorAcc.Phone;
            
            if(vendorAcc.c2g__CODABankIBANNumber__c!=null){
                acc.BBAN__c = vendorAcc.c2g__CODABankIBANNumber__c.removeStart('PT50');
            }

            update acc;
            return 'OK';
        }else{
            return 'NOT_OK';
        }        

    }

    public String requestApplication_v2(String NIF){

        System.debug('[Vendor.requestApplication] -> Start');
        Client c = new Client(NIF);
        String validation = validateNewAppRequest(c);

        if(validation!='VALID'){
            return validation;
        }

        Account accClient; 
        boolean is_Personal_Guarantee = false;
        if(!c.exist()){
            accClient = c.createAccount();
        }else{
            accClient = c.getAccount();
            ID decisionID = accClient.Decisions__r.size()>0 ? accClient.Decisions__r[0].Id : null;
            DecisionWrapper wd = decisionID != null ? new DecisionWrapper(decisionID) : null;
            is_Personal_Guarantee = wd != null && wd.conditions != null ? wd.conditions.personal_guarantee : false;
        }

        System.debug('[Vendor.requestApplication] -> Client -> ' + c);
        
        list<contact> con = [SELECT Id, name FROM Contact WHERE Id IN (SELECT vendor_vendor__c FROM login__c WHERE Id=:loginID)];

        Application__c newApp = new Application__c();

        if (con.size() != 0){
            newApp.Vendor__c = vendorID;
            newApp.AccClient__c = accClient.Id; 
            newApp.IdLoginCreate__c = loginID;
            newApp.Personal_Guarantee__c = is_Personal_Guarantee;
            newApp.Vendor_Primary__c = con[0].id; 
        } else{
            newApp.Vendor__c = vendorID;
            newApp.AccClient__c = accClient.Id; 
            newApp.IdLoginCreate__c = loginID; 
            newApp.Personal_Guarantee__c = is_Personal_Guarantee;
        }        

        newApp.Application_Date__c = Datetime.now();
        insert newApp;
        
        String res = c.analyseClient_v2(newApp.Id);
        return res;
    }

    //DEPRECATED HP 14/12/2017
    /*public String requestApplication(String NIF){

        System.debug('[Vendor.requestApplication] -> Start');
        Client c = new Client(NIF);
        String validation = validateNewAppRequest(c);

        if(validation!='VALID'){
            return validation;
        }

        Account accClient; 
        boolean is_Personal_Guarantee = false;
        if(!c.exist()){
            accClient = c.createAccount();
        }else{
            accClient = c.getAccount();
            is_Personal_Guarantee = accClient.Personal_Guarantee__c;
        }

        System.debug('[Vendor.requestApplication] -> Client -> ' + c);
        
        list<contact> con = [SELECT Id, name 
                            FROM Contact 
                            WHERE Id IN (SELECT vendor_vendor__c FROM login__c WHERE Id=:loginID)];

        Application__c newApp = new Application__c();

        if (con.size() != 0){
            newApp.Vendor__c = vendorID;
            newApp.AccClient__c = accClient.Id; 
            newApp.IdLoginCreate__c = loginID;
            newApp.Personal_Guarantee__c = is_Personal_Guarantee;
            newApp.Vendor_Primary__c = con[0].id; 
        } else{
            newApp.Vendor__c = vendorID;
            newApp.AccClient__c = accClient.Id; 
            newApp.IdLoginCreate__c = loginID; 
            newApp.Personal_Guarantee__c = is_Personal_Guarantee;
        }        
        
        //(HP) 02/03/2017 - Módulo de seguro retirado
        /*if(Vendor.Available_Insurance_Type__c!=null){
            newapp.Insurance_Type__c = Vendor.Available_Insurance_Type__c.split(';')[0];
        }*/
        //if(Vendor.Insurance_Type__c!=null){newApp.Insurance_Type__c = Vendor.Insurance_Type__c;} //(HP- 03/05/2017 - the set of insurance type is now done at ApplicationTriggerHandler)

        /*newApp.Application_Date__c = Datetime.now();

        insert newApp;
        
        System.debug('[Vendor.requestApplication] - New application inserted -> Id: '  + newApp.Id);

        c.analyseClient(newApp.Id);//ALTERACAO - 22/03/17 - (BP)

        if (vendor != null )  {         
            if(vendor.Insurance_Type__c!=null){ newApp.Insurance_Type__c = vendor.Insurance_Type__c; } 
            if(Vendor.Insurance_Type__c!=null){newApp.Insurance_Type__c = Vendor.Insurance_Type__c;}
        }
        
        return newApp.Id;
    }*/

    public String uploadInvoice(String attachmentBody , ID appID, String attachmentId){

        List<Vendor_Invoice__c> vendorInvoiceList = [SELECT Account__c FROM Vendor_Invoice__c WHERE Account__c=:vendorID AND Application__c =:appID AND Status__c!='Canceled' ORDER BY Createddate DESC LIMIT 1];
        Vendor_Invoice__c vendorInvoice = new Vendor_Invoice__c();
        
        if(vendorInvoiceList.size()==0){
            //cria novo vendor_invoice
            vendorInvoice.Account__c = vendorID;   
            vendorInvoice.Application__c = appID;     
            insert vendorInvoice;
        }else{
            vendorInvoice = vendorInvoiceList[0];
        }

        if(attachmentBody  != null){
            Attachment att = getAttachment(attachmentId);
            String newBody = '';
            if(att.Body != null) {
                newBody = EncodingUtil.base64Encode(att.Body);
            }
            newBody += attachmentBody;
            att.Body = EncodingUtil.base64Decode(newBody);
            if(attachmentId == null) {
                att.Name = 'Fatura Parceiro - ' + vendorID + '.pdf';
                att.parentId = vendorInvoice.Id;
                att.IsPrivate = false;
                //att.contentType = 'application/pdf';
            }
            upsert att;
            return att.Id;            
        }else{
            return 'BODY_NULL';
        }
    }

    public String cancelInvoice(String vendorInvoiceID){
        List<Vendor_Invoice__c> vendorInvoiceList = [SELECT Id, Application__c, Status__c FROM Vendor_Invoice__c WHERE Account__c=:vendorID AND ID =:vendorInvoiceID];
        String res = '';
        if(vendorInvoiceList.size()>0){
            Vendor_Invoice__c vendorInvoice = new Vendor_Invoice__c();
            vendorInvoice = vendorInvoiceList[0];
            if(vendorInvoice.Status__c != 'Completed'){
                vendorInvoice.Status__c = 'Canceled';
                update vendorInvoice;

                //Update aos campos existentes na app. \
                //TODO: implementar trigger (caso estes campos se mantenham no objecto Application__c) 
                //para fazer set destes campos da applications__c quando vendor invoice set submitted__c = true;
                //Remover este código após trigger implementado (HP 2017/09) 
                Application__c app = new Application__c();
                app.Id = vendorInvoice.Application__c;
                app.Issuing_Date_Invoice__c = null;
                app.Vendor_Invoice_Amount__c = null;
                app.Invoice_Number__c = null;
                update app;

                res='OK';     
            }else{
                res='INVOICE_STATUS_COMPLETED';
            }
        }else{
            res = 'INVOICE_NOT_FOUND'; 
        }
        return res;
    }

    public String uploadLogo(String attachmentBody , ID appID, String attachmentId){

            if(attachmentBody  != null){
                delAttachmentByVendor(vendorId);
                Attachment att = getAttachmentByVendor(vendorId);
                String newBody = '';
                if(att!=null)
                {
                    if(att.Body != null) {
                        //newBody = EncodingUtil.base64Encode(att.Body);
                        newBody += attachmentBody;
                        att.Body = EncodingUtil.base64Decode(newBody);
                    }
                }
                else{
                    att = new Attachment();
                }
                newBody += attachmentBody;
                att.Body = EncodingUtil.base64Decode(newBody);
            
                if(att.Id == null && attachmentId == null) {
                    att.Name = 'Logo Partner IMG - ' + System.Now()+'.jpg';
                    att.parentId = vendorID;
                    att.IsPrivate = false;
                }
                upsert att;
                return att.Id;            
            }else{
                return 'BODY_NULL';
            }
        return 'BODY_NULL';
    }

    public static void delAttachmentByVendor(Id vendorId){
        List<Attachment> la = [select Id, Body, Name from Attachment where parentId=:vendorId and Name like 'Logo Partner IMG%'];

        if(la.size()>0)
            delete la[0];
    }

    public static Attachment getAttachmentByVendor(Id vendorId){
        List<Attachment> la = [select Id, Body, Name from Attachment where parentId=:vendorId and Name like 'Logo Partner IMG%'];

        if(la.size()>0)
            return la[0];
            else
            return null;
    }

    public Vendor_Invoice__c getVendorInvoice(ID appID){
        
        List<Vendor_invoice__c> viList = [SELECT ID, NAME, Account__c,Due_Date__c, Invoice_Date__c, Invoice_Total__c, 
                                     Status__c, Submitted__c, Vendor_Invoice_Number__c
                                     FROM Vendor_Invoice__c WHERE Application__c =:appID AND Account__c =:vendorID AND Status__c!='Canceled' ORDER BY Createddate DESC];
        if(viList.size()>0){
            return viList[0];
        }else{
            return null;
        }
    }
    
    public  List<Notification__c> getNotifications(){
        String query = 'SELECT AppClientName__c, AppName__c, Message__c, CreatedDate, read__c ';
        query += ' FROM Notification__c '; 
        query += ' WHERE VendorNIF__c= \'' + login.Vendor_NIF__c + '\' ';       
        if(!isMaster){
            query += ' AND IdLogin__c=\'' + login.Username__c +'\' ';
        }
        query += ' ORDER BY Createddate DESC LIMIT 20';
        
        List<Notification__c> notificationList = Database.query(query);   

        return notificationList;
    }

    public boolean setNotificationsRead(List<ID> notificationsIDList){

        List<Notification__c> notificationsToUpdateList = new List<Notification__c>();
        for(ID notifID : notificationsIDList){
            Notification__c notif = new Notification__c();
            notif.Id = notifID;
            notif.read__c = true;
            notificationsToUpdateList.add(notif);
        }
        update notificationsToUpdateList;

        return true;
    }

    public static CandorAuthorization login(String username, String password, boolean remember, String userAgent, String idDevice, String typeDevice){

            CandorAuthorization loginResponse = new CandorAuthorization();
            List<Login__c> login = [SELECT HashKey__c, Inactive__c, CreatedDate/*, NewHash__c*/, Vendor_Vendor__r.Name, IdVendor__r.Name, Username__c,Remember_me__c, Password__c, Vendor_NIF__C, Email__c, IdVendor__c, Master__c, CreatedBy.TimeZoneSidKey, Language__c FROM Login__c WHERE Username__c=:username];
            String loginDateCreated=''; 

            if(login.size()>0){
                if(login[0].Inactive__c == true)
                {
                    loginResponse.status=false;
                    loginResponse.error='LOGIN_INACTIVE'; 
                    return loginResponse;
                }
                //if(login[0].NewHash__c){//IF Colocado para resolver bug da construção do vector de inicialização para desincriptação da password. Conflito de timeZones. A REMOVER NO FUTURO! 
                    loginDateCreated = login[0].CreatedDate.formatGMT('YYYYMMddHHmmss') + '00'; //initializationVector for decryption 
                /*}else{
                    loginDateCreated = login[0].CreatedDate.format('YYYYMMddHHmmss', login[0].CreatedBy.TimeZoneSidKey) + '00'; //initializationVector for decryption 
                }*/

                if(remember != login[0].Remember_me__c){
                    login[0].Remember_me__c = remember;
                    update login[0];
                }
                
                //descrypt password in database to comapre with the one given by the user.
                String loginDecryptedPassword = CandorAuthorization.decryptString(login[0].hashkey__c, loginDateCreated, login[0].Password__c);

                //System.debug(loginDecryptedPassword);
                if(password == loginDecryptedPassword){
                    
                    System.debug('[Vendor - login()] Passwords match! LOGIN SUCCESSFUL');
                    
                    //create new session
                    CandorAuthorization newSessionAuthorization = new CandorAuthorization (); 
                    Session__c new_session = newSessionAuthorization.createNewSession(username, password, login[0].ID, UserAgent, IdDevice, TypeDevice);
                    
                    if(new_session!=NULL){    
                        System.debug('[Vendor - login()] Session with the id ' +  new_session.ID + 'created!');
                        loginResponse.status = true;
                        //loginResponse.sessionID = new_session.ID;
                        loginResponse.session = new_session;
                        //loginResponse.sessionToken = new_session.token__c;
                        loginResponse.login = login[0];
                    }else{
                        System.debug('[Vendor - login()] Failed to create New Session!');
                        loginResponse.status=false;
                        loginResponse.error = newSessionAuthorization.getErrorMsg(); 
                    }
                    
                }else{
                    System.debug('[Vendor - login()] Incorrect Password! LOGIN FAILED!');
                    loginResponse.status=false;
                    loginResponse.error='Password Incorreta'; 
                }
            }else{
                System.debug('[Vendor - login()] Incorrect Password! LOGIN FAILED!');
                loginResponse.status=false;
                loginResponse.error='Username Incorreto'; 
            }  

            return loginResponse;      
    }

    public String saveVendorContact(Contact contact, ID sessionID){

        if(contact.Id != null && loginID != null){

            //Contacto e username teem que ser o mesmo!
            //Login tem que ser o primeiro a ser actualizado. Caso haja erro 
            //não altera os outros campos. username__c tem que ser unico
            Login__c l = new Login__c();
            l.Id = loginID;
            l.Username__c = contact.Email;
            update l;

            if(sessionID != null){
                Session__c session = [SELECT Id, Login__c, HashKey__c, UsernameS__c,CreatedDate FROM Session__c WHERE ID=:sessionID];
                String sessionDateCreated = session.CreatedDate.formatGMT('YYYYMMddHHmmss') + '00'; //initializationVector for encryption 
                session.UsernameS__c = CandorAuthorization.encryptString(session.HashKey__c, sessionDateCreated,  contact.Email);            
                update session;
            }

            String[] name = contact.Name.split(' ', 2);

            if(name.size() == 1){
                contact.LastName = name[0]; 
            }else{
                contact.FirstName = name[0];    
                contact.LastName = name[1];  
            }

            update contact;

            return 'OK';

        }else{

            return 'NOT_OK';

        }
    }


    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }

    public String validateNewAppRequest(Client client){
        
        if(vendor != null){
            //ALTERACAO - 24/08/17 - para accs com red e black status nao podem submeter novos pedidos (BP)
            if(vendor.Account_Status__c == 'Red' || vendor.Account_Status__c == 'Black')
            {
                return 'FAILED_CREDIT_LINE_SUSPENDED';
            }
            List<String> failedhasopenapp = client.numberOfOpenAppsByVendor(vendor.Id);
            //check if client is already a Vendor
            /*if(client.existAsVendor()){
                return 'FAILED_EXIST_AS_VENDOR';
            }*/

            //Check if Client has open Applications
            if(failedhasopenapp.size()>0){
                return failedhasopenapp[0];
                //return client.numberOfOpenAppsByVendor().get((Id)1)+'-'+'FAILED_HAS_OPEN_APP';
            }

            //check if vendor daily limit is exceeded
            // if (vendor.Application_Daily_Limit_Achieved__c==true && vendor.Date_Last_Application__c!=null && vendor.Date_Last_Application__c ==system.today()){
            if(requestLimitReached()){
                return 'FAILED_VENDOR_LIMIT';           
            }

            return 'VALID';

        }else{

           return 'FAILED_VENDOR_LOGIN_NOT_FOUND';
        }

        
    }

    private boolean requestLimitReached(){

        if(vendor != null){

            List<ScoreCard_Config__c> daylimList = [ SELECT Id, Matching_Value_To_Nr__c from scoreCard_Config__c where RecordType.Name='Score Card' and RelatedObject__c='Application' and FieldName__c='Daily Limit'];
            Decimal DAILY_LIMIT;
            if(daylimList.size()>0){
                DAILY_LIMIT = daylimList[0].Matching_Value_To_Nr__c;
            }
            decimal DAILY_COUNTER = vendor.Daily_Limit_Counter__c;
            boolean LIMIT_ACHIVIED = vendor.Application_Daily_Limit_Achieved__c;
            Datetime DATE_LAST_APPLICATION = vendor.Date_Last_Application__c;
            
            Account vendorUpdate = new Account();
            vendorUpdate.Id = vendor.Id;    
            
            if(DAILY_COUNTER == null){
                vendorUpdate.Daily_Limit_Counter__c=0;
            }

            if (LIMIT_ACHIVIED == true && DATE_LAST_APPLICATION!=null && DATE_LAST_APPLICATION == system.today()){
                
                return true;
            
            }else if (LIMIT_ACHIVIED == true && DATE_LAST_APPLICATION != null && DATE_LAST_APPLICATION < system.today()){
                vendorUpdate.Application_Daily_Limit_Achieved__c = false;
                update vendorUpdate; //fazer update para disparar o workflow que mete o contador a 0. Após isto somar 1 ao Daily_Limit_Counter__c
                
                vendorUpdate.Daily_Limit_Counter__c = 1;
                vendorUpdate.Date_Last_Application__c = system.today(); 
            }

            if(LIMIT_ACHIVIED == false && DATE_LAST_APPLICATION == system.today()){
                if (DAILY_COUNTER >= DAILY_LIMIT ){
                    vendorUpdate.Application_Daily_Limit_Achieved__c=true; 
                }else{
                    vendorUpdate.Daily_Limit_Counter__c= vendor.Daily_Limit_Counter__c + 1;
                }
            }else{
                vendorUpdate.Daily_Limit_Counter__c = 1;
                vendorUpdate.Date_Last_Application__c = system.today(); 
            }

            update vendorUpdate;
            return vendorUpdate.Application_Daily_Limit_Achieved__c;
        }else{
            return true;
        }
    }

    public String saveNewLogin(Contact contact){
        
        String result;

        if(isMaster){

            Contact newContact = new Contact();
            newContact.Email = contact.Email;
            newContact.AccountId = contact.AccountId;
            newContact.FirstName = contact.FirstName;
            newContact.MiddleName = contact.MiddleName;    
            newContact.LastName = contact.LastName; 
            newContact.Role__c = contact.Role__c;  
            
            result = CandorAuthorization.createNewLogin(newContact);
            
        }else{
            
            result = 'IS_NOT_MASTER';
        
        }

        return result;
    }

    //CRIACAO - 01/06/17 - Obtencao dos scorecards (BP)
    public List<ScoreCard_Config__c> getInfoScores()
    {
        List<scorecard_Config__c> scorecards =[SELECT id, Matching_Value_To_Nr__c  
                                                 FROM ScoreCard_Config__c 
                                                WHERE RecordType.Name='Score Card' 
                                                  AND fieldName__c='CreditLine Maturity Date'];
        if(scorecards.size()>0)
            return scorecards;
        else 
            return NULL;
    }      

    //ALTERACAO - 11/07/17 - para apagar logins ou inactivar os mesmos (BP)
    public boolean eraseORinactivateLogin(ID loginIDToErase,String function)//on Vendor Object function is for know if erase or inactive
    {
        System.debug('[Vendor].eraseORinactivateLogin --> login to erase: '+loginIDToErase);
        if(this.loginID == loginIDToErase || this.login.Master__c ==false)//verificar se só os master podem apagar.
            return false;

        if(function =='inactivate')
        {
            Login__c loginUpdated    = new Login__c(id=loginIDToErase);
            loginUpdated.Inactive__c = true;
            update loginUpdated;
            System.debug('[Vendor].eraseORinactivateLogin --> login updated para inactivo...');
            return true;
        }
            
        List<Login__c> loginsAdministrator = [SELECT ID 
                                                FROM Login__c 
                                               WHERE IdVendor__c = : vendorID
                                                 AND ID         != : loginIDToErase 
                                                 AND Master__c   = true
                                                 AND Inactive__c = false];
                                                 
        if(loginsAdministrator.size()==0)
            return false;
        else
        {
            System.debug('[Vendor].eraseORinactivateLogin --> SIZE OF loginsAdministrator: '+loginsAdministrator.size());
            List<Application__c> updatedApps   = new List<Application__c>();
            List<Application__c> appsToUpdate  = [SELECT ID 
                                                    FROM Application__c 
                                                   WHERE IdLoginCreate__c =: loginIDToErase
                                                 ];
            if(function =='erase')
            {
                System.debug('[Vendor].eraseORinactivateLogin --> SIZE OF appsToUpdate: '+appsToUpdate.size());
                List<Contact> contactIDList = [SELECT ID FROM Contact WHERE AccountID =: vendorID LIMIT 1];                
                ID contactID = contactIDList.size()>0 ? contactIDList[0].ID : null;
                if(contactID==null) return false;

                for(Application__c currentApp : appsToUpdate)
                {               
                    currentApp.IdLoginCreate__c  = this.loginID;
                    currentApp.Vendor__c         = this.vendorID;
                    currentApp.Vendor_Primary__c = contactID;
                    updatedApps.add(currentApp);
                } 
                Login__c loginToDelete = new Login__c(id=loginIDToErase);
                System.debug('[Vendor].eraseORinactivateLogin --> SIZE OF updatedApps: '+updatedApps.size());  
                System.debug('[Vendor].eraseORinactivateLogin --> updatedApps: '+updatedApps);            
                update updatedApps;
                delete loginToDelete;  
                return true;          
            }
            return false;            
        }//end else scope       
    }//end eraseORinactivateLogin method

    //(HP) 02/03/2017 - Módulo de seguro retirado
    //Method used in AccountTrigger to populate the available insruance types according to the equipment selected in vendor account
    /*public static List<Account> InsuranceTypeByEquipments(List<Account> triggeraccs){

        for(Account accs : triggeraccs){
        String AIT = ''; 
        
            if(accs.Equipment_Types__c != null && !accs.Own_Insurance__c){
                if ( accs.Equipment_Types__c.toLowerCase().contains('Pure IT'.toLowerCase()) 
                   || accs.Equipment_Types__c.toLowerCase().contains('Software'.toLowerCase())
                    || accs.Equipment_Types__c.toLowerCase().contains('Printers and CopyMachines'.toLowerCase()) ){
                        AIT = 'Static Risk;' ;
                        system.debug('AIT_1: '+AIT);
                }
                
                if ( accs.Equipment_Types__c.toLowerCase().contains('Phone Centrals'.toLowerCase()) 
                   || accs.Equipment_Types__c.toLowerCase().contains('Other Equipments'.toLowerCase())
                    || accs.Equipment_Types__c.toLowerCase().contains('CCTV'.toLowerCase()) ){
                        AIT = AIT+'Special Risk;' ;
                        system.debug('AIT_2: '+AIT);
                }
                
                if ( accs.Equipment_Types__c.toLowerCase().contains('Portable Equipments'.toLowerCase()) ){
                        AIT = AIT+'Risk of Movement;' ;
                        system.debug('AIT_2: '+AIT);
                }
                accs.Available_Insurance_Type__c = AIT;
                //accstoupdate.add(accs);  
            }else if(accs.Own_Insurance__c){
                accs.Available_Insurance_Type__c = AIT+ 'Own Insurance';
            }else{
                accs.Available_Insurance_Type__c = AIT;
            }   
        }
        return triggeraccs;
    }*/

    //joao - funcoes de teste:
    public Login__c getLogin(){
        return this.login;
    }

}