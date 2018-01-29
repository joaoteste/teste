/**
* @date 2017
*
* @description Class responsible for the request to Credit Info Provider in order to get credit information for the account and insert or update ReportDB__c SObject. 
*              implements Queueable
*/

public without sharing class CreditInfoProviderRequest implements Queueable, Database.AllowsCallouts {
    
    private CreditInfoContext creditInfoContext;
    private ReportDB__c report;
    private boolean changeApplication = false;
    private Decimal MAX_NUMBER_OF_ATTEMPS;
    private Decimal CURRENT_ATTEMP; 
    private String PROVIDER;
    
    private static Map<String,String> DECISION_TO_RENTING_APP_STATUS_MAP {//TODO: quando esta variavel for melhor definida, construi-la a partir de um objecto de settings como os costume metdata types
        get{
            Map<String,String> decisionStatusMap = new Map<String,String>();   
            decisionStatusMap.put('Approved', 'Application - Approved');
            decisionStatusMap.put('Declined', 'Application - Rejected');
            decisionStatusMap.put('Pendent' , 'Application - Pendent' );
            decisionStatusMap.put('Inactive', 'Application - Rejected'); //IF DECISION STATUS IS INACTIVE PUT REJECTED -> 16/10/2017 -> à data de desenvolvimento n havia requesito especifico para este tipo de estado da decisão

            return decisionStatusMap;

        } 
        set;
    }

    private static Map<String,String> DECISION_TO_ACCOUNT_STATUS_MAP {//TODO: quando esta variavel for melhor definida, construi-la a partir de um objecto de settings como os costume metdata types
        get{
            Map<String,String> decisionStatusMap = new Map<String,String>();   
            decisionStatusMap.put('Approved', 'Credit Line - Approved');
            decisionStatusMap.put('Declined', 'Credit Line - Rejected');
            decisionStatusMap.put('Pendent' , 'Credit Line - Pendent' );
            decisionStatusMap.put('Inactive', 'Credit Line - Rejected'); //IF DECISION STATUS IS INACTIVE PUT REJECTED -> 16/10/2017 -> à data de desenvolvimento n havia requesito especifico para este tipo de estado da decisão

            return decisionStatusMap;

        } 
        set;
    }

    /*******************************************************************************************************
    *
    * CONSTRUCTERS
    *
    ********************************************************************************************************/

    public CreditInfoProviderRequest(CreditInfoContext ctx){
        this.creditInfoContext = ctx;
        this.changeApplication = (creditInfoContext.applicationID!=null || creditInfoContext.vendorLoginID!=null);
        this.CURRENT_ATTEMP = 1;
        this.MAX_NUMBER_OF_ATTEMPS = [SELECT Id, Max_Request_Attempts__c FROM Credit_Info_Provider_Setting__mdt WHERE DeveloperName =: creditInfoContext.country].Max_Request_Attempts__c; 
        this.PROVIDER = [SELECT Id, Provider__c FROM Credit_Info_Provider_Setting__mdt WHERE DeveloperName =: creditInfoContext.country].Provider__c; 
        System.debug('[CreditInfoProviderRequest] -> object: ' + this);
    }


    /*******************************************************************************************************
    *
    * PUBLIC METHODS.
    *   
    ********************************************************************************************************/

     /*******************************************************************************************************
    * @description method called when Queueable runs
    */
    public void execute(QueueableContext context) {
       
        Datetime start = Datetime.now();
       
        try{

            System.debug('[CreditInfoProviderRequest - execute()] -> START: ' + start);
            System.debug('[CreditInfoProviderRequest - execute()] -> ATTEMP NUMBER: ' + CURRENT_ATTEMP);
        
            //REQUEST CREDIT INFO FROM CREDIT INFO PROVIDER
            CreditInfoProviderResponse response = getCreditInfo(context);

            System.debug('[CreditInfoProviderRequest - execute()] -> FINISH: ' + Datetime.now() +';  Response: ' + response);

        }catch(exception e){
        
            Outbound_Integration_Log__c recordLog = new Outbound_Integration_Log__c(Start__c = start, Code__c = 'CRITICAL', ApplicationID__c = 'QUEUEABLE_INFROMADB_REQUEST', message__c = 'CreditInfoProviderRequest: : taxPayerNumber: ' + creditInfoContext.taxPayerNumber +'; Account ID: ' +  creditInfoContext.accountID  + '; ERROR: '+ e.getMessage(), printStackTrace__c = e.getStackTraceString());
            System.debug('[CreditInfoProviderRequest - execute()] ->ERROR! LOG: ' + recordLog);
            System.debug('[CreditInfoProviderRequest - execute()] ->ERROR! exception: ' +e.getMessage() + '; ' + e.getStackTraceString());          
        
            insert recordLog;
        }

    }


    /*******************************************************************************************************
    * @description get information from Decision__c and ReportDB__C and fill fields from Account and Application__c
    * @param upsertSObjects: if true inserts or update the new sObjects Created  
    * @return a Map<String, sObject> with the Account and Application__c created
    */
    public Map<String, sObject> fillSObjectsFieldsfromDecision(boolean upsertSObjects){

        Decision__c decision = new Decision__c(); 
        Application__c app   = new Application__c();
        Decimal limitMinCredit =  [SELECT Minimum_Credit_Allowed__c FROM Credit_Decisions_Settings__mdt WHERE DeveloperName =: creditInfoContext.country LIMIT 1].Minimum_Credit_Allowed__c;
        
        List <Decision__c> decisionList = [SELECT ID, Name, Decison_Status__c, Credit_info__c, Credit_info__r.Last_Request_Status__c, Guidance_Limit_Min__c, Guidance_Limit_Max__c,
                                                  Account__r.Credit_line__c, Account__r.Available_Credit_Line__c, Account__r.Used_Credit_Line__c, Account__r.Credit_Line_Status__c, Sub_Grade__c, Grade__c, Account__c,
                                                  (SELECT Personal_Guarantee__c FROM Decision_Conditions_Card_History__r ORDER BY CREATEDDATE DESC LIMIT 1)
                                           FROM Decision__c 
                                           WHERE Account__c =:creditInfoContext.accountID AND Active__c = TRUE ORDER BY CREATEDDATE DESC LIMIT 1];

        if(decisionList.size()>0){

            decision = decisionList[0];
            System.debug('[CreditInfoProviderRequest - execute()] -> Decision__c: ' + decisionList[0]);
        
        }else{
        
            System.debug('[CreditInfoProviderRequest - fillSObjectsFieldsfromDecision()] -> Decision not found');
            //LOG 
            Outbound_Integration_Log__c log = new Outbound_Integration_Log__c(
                Start__c = Datetime.now(), 
                End__c = Datetime.now(), 
                Status__c = 'FAILED', 
                Code__c = 'DECISION_NOT_FOUND', 
                ApplicationID__c = creditInfoContext.accountID, 
                Message__c = 'Decision__c for Account : ' + creditInfoContext.accountID +' NOT FOUND'
            );

            //If decision doesnt exit insert an application without Status__c
            app.Id               = creditInfoContext.applicationID != null ? creditInfoContext.applicationID : null; 
            app.AccClient__c     = creditInfoContext.accountID;
            if(creditInfoContext.vendorAccountID != null){
                list<Login__c> loginList = [SELECT Id, vendor_vendor__c FROM Login__c WHERE ID =: creditInfoContext.vendorLoginID];
                app.IdLoginCreate__c = creditInfoContext.vendorLoginID;
                app.Vendor_Primary__c =  loginList.size()>0 ? loginList[0].vendor_vendor__c : null; 
            } 
            if(creditInfoContext.vendorLoginID != null){   
                app.Vendor__c = creditInfoContext.vendorAccountID;
            }
            upsert app;
        
            insert log;
            return null;
        }       

        //Fill Account fields with report info
        Account acc = decision.Account__r;
        if(this.report!=null){
            acc = ReportToAccount(this.report, acc);   
        } 

        Map<String, SObject> resultMap = new Map<String, sObject>();
        List<sObject> sObjectsToUpsert = new List<sObject>();

        //Fill Account fields with decision info
        acc.Credit_Line_Status__c = DECISION_TO_ACCOUNT_STATUS_MAP.get(decision.Decison_Status__c);
        System.debug('[CreditInfoProviderRequest - fillSObjectsFieldsfromDecision()] -> acc.Credit_Line_Status__c: ' + acc.Credit_Line_Status__c);
        acc.Credit_line__c = decision.Guidance_Limit_Max__c == null ? acc.Credit_line__c : decision.Guidance_Limit_Max__c;
        acc.Personal_Guarantee__c = decision.Decision_Conditions_Card_History__r.size() > 0 ? decision.Decision_Conditions_Card_History__r[0].Personal_Guarantee__c : acc.Personal_Guarantee__c;

        //If Available Credit is inferior to the lower limit of decision the credit is rejected
        acc.Used_Credit_Line__c = acc.Used_Credit_Line__c == null ? 0: acc.Used_Credit_Line__c; 
        acc.Credit_line__c =  acc.Credit_line__c == null ? 0 : acc.Credit_line__c;
        acc.Available_Credit_Line__c = acc.Credit_line__c - acc.Used_Credit_Line__c;
        acc.Available_Credit_Line__c =  acc.Available_Credit_Line__c < 0 ? 0 : acc.Available_Credit_Line__c;
        System.debug('[CreditInfoProviderRequest - fillSObjectsFieldsfromDecision()] -> acc.Available_Credit_Line__c: ' + acc.Available_Credit_Line__c);
        
        if(acc.Available_Credit_Line__c < limitMinCredit && decision.Decison_Status__c == 'Approved'){
            acc.Credit_Line_Status__c = DECISION_TO_ACCOUNT_STATUS_MAP.get('Pendent');
        }

        resultMap.put('Account', acc);
        System.debug('[CreditInfoProviderRequest - fillSObjectsFieldsfromDecision()] -> acc: ' + acc);
        if(upsertSObjects){
            upsert acc;
            System.debug('[CreditInfoProviderRequest - fillSObjectsFieldsfromDecision()] -> acc updated OR inserted');
        }

        //Fill application__c fields with decision info
        System.debug('[CreditInfoProviderRequest - fillSObjectsFieldsfromDecision()] -> boolean this.changeApplication: ' + this.changeApplication);
        if(this.changeApplication == true){
        
            app.Id               = creditInfoContext.applicationID != null ? creditInfoContext.applicationID : null; 
            app.AccClient__c     = creditInfoContext.accountID;

            //put Dicision__c
            app.Decision__c = decision.Id;

            //Transalte decision status to Application__c Status
            app.Status__c = this.report.Last_Request_Status__c == 'ERROR' ? null : DECISION_TO_RENTING_APP_STATUS_MAP.get(decision.Decison_Status__c);
            app.Reject_Reason__c = app.Status__c == 'Application - Pendent' && this.report.Last_Request_Status__c != 'ERROR' ? 'Pendente: Submeter último IRC (Anexo B ou C), IRS ou Relatório e Conta' : app.Reject_Reason__c; //TODO: Colocar esta mensagem nas Custom Labels
            
            if(acc.Available_Credit_Line__c < limitMinCredit && decision.Decison_Status__c == 'Approved' ){
                app.Reject_Reason__c = 'Pendente: Plafond totalmente usado pelo cliente';  
                app.Status__c = DECISION_TO_RENTING_APP_STATUS_MAP.get('Pendent'); 
            }
            
            //credit fiedls -> TODO: In future, see if this fields are realy necessary or cand bo deprecated -> duplicated from account.
            app.Client_Available_Credit_Line__c = acc.Available_Credit_Line__c; 
            app.Personal_Guarantee__c = acc.Personal_Guarantee__c;

            //put login from vendor
            if(creditInfoContext.vendorAccountID != null){
                list<Login__c> loginList = [SELECT Id, vendor_vendor__c FROM Login__c WHERE ID =: creditInfoContext.vendorLoginID];
                app.IdLoginCreate__c = creditInfoContext.vendorLoginID;
                app.Vendor_Primary__c =  loginList.size()>0 ? loginList[0].vendor_vendor__c : null; 
            } 
            
            //Put Partner Account
            if(creditInfoContext.vendorLoginID != null){   
                app.Vendor__c = creditInfoContext.vendorAccountID;
            }

            //app as always interim fee on insert
            app.Interim_Fee__c = true;

            resultMap.put('Application__c', app);
            System.debug('[CreditInfoProviderRequest - fillSObjectsFieldsfromDecision()] -> app: ' + app);
            if(upsertSObjects){
                upsert app;
                System.debug('[CreditInfoProviderRequest - fillSObjectsFieldsfromDecision()] -> app updated OR inserted');
            }

            //LOG
            Outbound_Integration_Log__c log = new Outbound_Integration_Log__c(
                Start__c = Datetime.now(), 
                End__c = Datetime.now(), 
                Status__c = 'OK', 
                Code__c = 'INSERT_SOBJECT_FROM_DECISION',   
                ApplicationID__c = creditInfoContext.taxPayerNumber, 
                Message__c = 'SOBJECT UPSERTED -> appID: ' + app.Id +': accID: ' + acc.Id
            );
            insert log;
        }

        System.debug('[CreditInfoProviderRequest - fillSObjectsFieldsfromDecision()] -> return: ' + resultMap);
        return resultMap;

    }

     /*******************************************************************************************************
    * @description Do the request without the need of QueueableContext
    * @return CreditInfoProviderResponse
    */
    public CreditInfoProviderResponse getCreditInfo(){
        return getCreditInfo(null);
    }


    /*******************************************************************************************************
    *
    * PRIVATE METHODS.
    *
    ********************************************************************************************************/
    /*******************************************************************************************************
    * @description instantiate the right class for request credit info for specified country and do the request
    * @param QueueableContext context
    * @return CreditInfoProviderResponse
    */
    @TestVisible
    private CreditInfoProviderResponse getCreditInfo(QueueableContext context){

        System.debug('[CreditInfoProviderRequest - getCreditInfo()] -> GOING TO REQUEST CREDIT INFO TO PROVIDER IN ' + creditInfoContext.country + ' FOR TAXPAYER NUMBER: ' + creditInfoContext.taxPayerNumber);
        Credit_Info_Provider_Setting__mdt creditInfoProviderSettings = [SELECT Apex_Class__c, Provider__c FROM Credit_Info_Provider_Setting__mdt where DeveloperName =:creditInfoContext.country];       
        String apexClass = creditInfoProviderSettings.Apex_Class__c;
        String provider = creditInfoProviderSettings.Provider__c;

        System.debug('[CreditInfoProviderRequest - getCreditInfo()] -> going to use apex class: ' + apexClass);
        
        Type t = Type.forName(apexClass);
        CreditInfoProvider creditInfoProvider = (creditInfoProvider) t.newInstance();
        CreditInfoProviderResponse response = creditInfoProvider.doRequest(creditInfoContext.taxPayerNumber);
        DBProp dbprop = creditInfoProvider.parseXML(response.xml);
        
        System.debug('[CreditInfoProviderRequest - getCreditInfo()] -> dbprop = ' + dbprop);

        //LOG JOB ID
        String codeStringToLog = context != null ? 'QUEUEABLE_CREDIT_REPORT' : 'GET_CREDIT_REPORT';
        Outbound_Integration_Log__c log = new Outbound_Integration_Log__c(
            Start__c = response.startDate, 
            End__c = Datetime.now(), 
            Status__c = response.status ? 'Success':'Failure', 
            Code__c = codeStringToLog, 
            Get_Sent_XML__c = reduceStringLength(response.info, 131072),   
            Get_Received_XML__c = reduceStringLength(response.xml, 131072),
            ApplicationID__c = creditInfoContext.taxPayerNumber, 
            Message__c = (context!=null ? 'Queueable job ID: ' + context.getJobId() : '')
        );

        insert log;

        //Handle response result from the request -> IF fails call this method again when in a queueable
        //boolean requestResult = handleResponse(response);
        System.debug('[CreditInfoProviderRequest - execute()] -> response: ' + response);
        System.debug('[CreditInfoProviderRequest - execute()] -> response.statusForCreditInfo: ' + response.statusForCreditInfo);
        
        if(!response.status) {

            Boolean anotherAttemp = goForAnotherAttemp(response);
            //IF REQUEST FAILS AND CAN GO FOR ANOTHER ATTEMP, RUN THIS QUEUEABLE AGAIN  
            if(anotherAttemp && context != null){
                
                if(!Test.isRunningTest()){
                    System.debug('[CreditInfoProviderRequest - getCreditInfo()] -> Going for another try!');
                    System.enqueueJob(this);
                    return null;
                }else{
                    response = response == null ? new CreditInfoProviderResponse() : response;
                }

            }else{

                String message = 'NUMBER OF ATTEMPS: ' + (CURRENT_ATTEMP-1) + '-> Maximum number of attempts reached.';
                System.debug('[CreditInfoProviderRequest - getCreditInfo() - goForAnotherAttemp()] ' + message);

                //LOG ERROR
                String status = response.status ? 'Success':'Failure';
                if(response.statusForCreditInfo == 'ERROR'){
                    Outbound_Integration_Log__c log_fail = new Outbound_Integration_Log__c(Start__c = response.startDate, End__c = Datetime.now(), Status__c = status, Code__c = codeStringToLog, Get_Sent_XML__c = reduceStringLength(response.info, 131072), Get_Received_XML__c = reduceStringLength(response.xml, 131072),  ApplicationID__c = creditInfoContext.taxPayerNumber, Message__c = message);
                    insert log_fail;
                }
            }
        }

        //Insert or update the report according to the receive response from INFORMADB
        this.report = response.status ? getSObjectReportDBFromParsedObject (dbprop, response.pdfBlob, response) : getSObjectReportDBStatusInfoFromRequest(response, null);

        if(this.report!=null){
            this.report.Country__c = creditInfoContext.Country;
            this.report.Provider__c = provider;
            upsert this.report;
        }else{
            String message_report = 'Error updating or inserting ReportDB__c for ' + creditInfoContext.taxPayerNumber;
            System.debug('[CreditInfoProviderRequest - getCreditInfo()] ALERT - REPORT IS NULL -' + message_report);
            Outbound_Integration_Log__c log_report = new Outbound_Integration_Log__c(Start__c = response.startDate, End__c = Datetime.now(), Status__c = 'ERROR', Code__c = codeStringToLog, Get_Sent_XML__c = reduceStringLength(response.info, 131072), Get_Received_XML__c = reduceStringLength(response.xml, 131072),  ApplicationID__c = creditInfoContext.taxPayerNumber, Message__c = message_report);
            insert log_report;
            response.setResponseError(message_report);
            response.setResponseStatus(false);
            return response;
        }

        System.debug('[CreditInfoProviderRequest - execute()] -> Report for account ' + creditInfoContext.accountID + ' with the taxPayerNumber ' + creditInfoContext.taxPayerNumber + ' CREATED/UPDATED: ' + this.report); 
    
        //FILL ACCOUNT AND APPLICATION WITH VALUES FROM DECISIONS
        Map<String, sObject> mapSObject = fillSObjectsFieldsfromDecision(true);
            
        //Insert Notification With Decision
        if(mapSObject!=null && mapSObject.containsKey('Application__c')){   
            Application__c app = (Application__c) mapSObject.get('Application__c');
            newNotification(app, true);
        }

        return response;
    }

    /*******************************************************************************************************
    * @description check the number rof attemps that have been made to InformaDB service and return true/false if the number of attemps  were exceeded/not exceeded
    * @param DBInfoXMLResponse resp last response from service  
    * @return boolean
    */
    @TestVisible
    private boolean goForAnotherAttemp(CreditInfoProviderResponse resp){
        
        System.debug('[CreditInfoProviderRequest - execute() - goForAnotherAttemp()] Current Request Attemp: ' + CURRENT_ATTEMP);
        System.debug('[CreditInfoProviderRequest - execute() - goForAnotherAttemp()] Number Max of Request Attemp: ' + MAX_NUMBER_OF_ATTEMPS);
        if(CURRENT_ATTEMP <= MAX_NUMBER_OF_ATTEMPS && resp.statusForCreditInfo == 'ERROR'){
        
            System.debug('[CreditInfoProviderRequest - execute() - goForAnotherAttemp()] Go for request attemp number: ' + CURRENT_ATTEMP);
            CURRENT_ATTEMP = CURRENT_ATTEMP + 1;
            return true;
        
        }else{

            return false;
        
        }
    }


    /*******************************************************************************************************
    * @description Upsert the Credit info object (ReportDB__c) with information from credit info servie
    * @param DBInfoXMLResponse resp response from service 
    * @return ReportDB__c 
    */
    @TestVisible
    private ReportDB__c getSObjectReportDBFromParsedObject(DBProp dbprop, blob pdfBlob, CreditInfoProviderResponse response){

        System.debug('[CreditInfoProviderRequest  - upsertSObjectReportDBFromParsedObject()] -> Going to update/insert ReportDB__c from: ' + dbprop);
        System.debug('[CreditInfoProviderRequest] - upsertSObjectReportDBFromParsedObject()] -> object: ' + this);

        ReportDB__c  rep = DBInfoXML.UpdateReport(dbprop, 'Client', creditInfoContext.accountID, pdfBlob);
        rep = getSObjectReportDBStatusInfoFromRequest(response, rep);

        System.debug('[CreditInfoProviderRequest - upsertSObjectReportDBFromParsedObject()] -> ReportDB__c: ' + rep);

        return rep;
    }


     /*******************************************************************************************************
    * @description write on report the info about the last request
    * @param ReportDB__c report
    * @param CreditInfoProviderResponse response 
    * @return the sObject ReportDB__c
    */
    @TestVisible 
    private ReportDB__c getSObjectReportDBStatusInfoFromRequest(CreditInfoProviderResponse response, ReportDB__c rep){

        if(rep == null){ 
            
            System.debug('[CreditInfoProviderRequest - upsertSObjectReportDBStatusInfoFromRequest()] -> Report is null!');
            List<ReportDB__c> repListFailed = new List<ReportDB__c>();
            
            if(response.statusForCreditInfo != 'OK'){
                System.debug('[CreditInfoProviderRequest - upsertSObjectReportDBStatusInfoFromRequest()] -> Check if exist report for taxpayer number: ' + creditInfoContext.taxPayerNumber);
                repListFailed = [SELECT ID FROM ReportDB__c WHERE Name =: creditInfoContext.taxPayerNumber ORDER BY Createddate DESC LIMIT 1];    
                System.debug('[CreditInfoProviderRequest - upsertSObjectReportDBStatusInfoFromRequest()] -> report list size: ' + repListFailed.size());
            }
            
            rep = repListFailed.size()>0 ? new ReportDB__c(Id = repListFailed[0].Id) : new ReportDB__c();

            if(creditInfoContext.country == 'PT' && (creditInfoContext.taxPayerNumber.startsWithIgnoreCase('1') || creditInfoContext.taxPayerNumber.startsWithIgnoreCase('2') || creditInfoContext.taxPayerNumber.startsWithIgnoreCase('3') || creditInfoContext.taxPayerNumber.startsWithIgnoreCase('45'))){
                Id recordTypeId = Schema.SObjectType.ReportDB__c.getRecordTypeInfosByName().get('ENI').getRecordTypeId();
                rep.RecordTypeId = recordTypeId;
                rep.FormaJuridica__c = 'ENI';
            }else{
                Id recordTypeId = Schema.SObjectType.ReportDB__c.getRecordTypeInfosByName().get('InformaDB').getRecordTypeId();
                rep.RecordTypeId = recordTypeId;
            }

        }
        
        System.debug('[CreditInfoProviderRequest - upsertSObjectReportDBStatusInfoFromRequest()] -> Report: ' + rep);
        System.debug('[CreditInfoProviderRequest - upsertSObjectReportDBStatusInfoFromRequest()] -> response: ' + response); 
        
        rep.Name = creditInfoContext.taxPayerNumber;
        rep.Last_Request__c = Datetime.now();
        rep.Last_Request_Status__c = response.statusForCreditInfo;
        rep.Last_Request_Code__c = response.code;
        if(rep.NumeroContribuinte__c ==null) rep.NumeroContribuinte__c = creditInfoContext.taxPayerNumber;
        if(rep.Vendor__c==null) rep.Vendor__c = creditInfoContext.accountID;

        return rep;

    }

     /*******************************************************************************************************
    * @description create a notification __c
    * @param app parent Application__c of the notification
    * @param insertNotification if true insert the sObject notification__c 
    * @return the sObject Notification__c
    */
    @TestVisible
    private Notification__c newNotification(Application__c app, boolean insertNotification){

        System.debug('[CreditInfoProviderRequest - newNotification()] -> going to create notification -> app.Id = ' + app.Id +'; insertNotification = ' + insertNotification);
        String message;
        String picklistValueApiName_1;
        report = report == null ? new ReportDB__c() : report;

        System.debug('[CreditInfoProviderRequest - newNotification()] -> decision.Credit_info__r.Last_Request_Status__c = ' + report.Last_Request_Status__c);
        if(report.Last_Request_Status__c == 'OK'){
            
            if(app.Status__c == 'Application - Approved'){
        
                picklistValueApiName_1 = 'Aprovado';
        
            }else if(app.Status__c == 'Application - Rejected'){
        
                picklistValueApiName_1 = 'Rejeitado';
        
            }else if(app.Status__c == 'Application - Pendent'){
        
                picklistValueApiName_1 = 'Pendente';
        
            }

        }else if(report.Last_Request_Status__c == 'STOP-DISTRIBUTION' || report.Last_Request_Status__c == 'NONEXISTENT'){
        
            picklistValueApiName_1 = 'Pendente';

        }else if(report.Last_Request_Status__c == 'ERROR' || report.Last_Request_Status__c == null){

            picklistValueApiName_1 = 'InformaDB_unavailable';

        }

        Schema.DescribeFieldResult fieldResult = notification__c.message__c.getDescribe();
        List<Schema.PicklistEntry> plnot = fieldResult.getPicklistValues();
        for(integer i=0; i<plnot.size(); i++){
            if(plnot[i].getValue() == picklistValueApiName_1){
                message= plnot[i].getLabel();
                break;
            }   
        }

        if(app.Reject_Reason__c == 'Pendente: Plafond totalmente usado pelo cliente'){
            message = 'Pendente: Plafond totalmente usado pelo cliente';
        }

        Notification__c notif = new Notification__c( 
            Application__c = app.Id, 
            Message__c = message
        );

        System.debug('[CreditInfoProviderRequest - newNotification()] -> notif = ' + notif);
        
        if(insertNotification){
            insert notif;
            System.debug('[CreditInfoProviderRequest - newNotification()] -> notification INSERTED: ' + notif.Id);
        }

        return notif;       
    }


    /*******************************************************************************************************
    *
    * PRIVATE STATIC METHODS.
    *
    ********************************************************************************************************/

    /*******************************************************************************************************
    * @description get Account from ReportDB__c 
    * @param report sObject ReportDB__c
    * @param Account acc
    * @return the sObject Account
    */
    @TestVisible
    private static Account ReportToAccount(ReportDB__c report, Account acc){

        //acc = acc == null ? new Account() : acc;

        if(report!=null){
            acc.CAE__c                   = report.CAE__c;
            acc.Activity_Code__c         = report.ActivityCode__c;
            acc.D_B_Failure_Score__c     = report.PercentilScore__c;
            acc.FormaObrigar_Val__c      = report.FormaObrigarToNr__c;
            acc.Date_Of_Establishment__c = report.DataConstituicao__c;
            acc.BillingPostalCode        = report.CodigoPostal__c;
            acc.Ano_Ultimo_Balanco__c    = report.Ano_Ultimo_Balanco__c;
            acc.FormaObriga_text__c      = report.FormaObrigar__c;
            acc.AnnualRevenue            = report.ResultLiqUltimoAno__c;
            acc.Sales__c                 = report.Sales__c;
            acc.Updating_Report__c       = false;

            //MARK ACCOUNTS THAT ARE GOING TO BE REPORCESS -> ReprocessStopDistributionReports.class
            if(report.Last_Request_Status__c == 'STOP-DISTRIBUTION'){
                acc.Credit_Line_Status__c = 'Credit Line - Pendent';
                acc.Updating_Report__c = true;
            }
        }
        return acc;
    }

    /*******************************************************************************************************
    * @description method to reduce string length 
    * @param String stringToReduce 
    * @param Integer maxNumberOfChars
    * @return String 
    */
    @TestVisible
    private static String reduceStringLength(String stringToReduce, Integer maxNumberOfChars){
        stringToReduce = (stringToReduce != null && stringToReduce.length()>maxNumberOfChars) ? stringToReduce.substring(0, maxNumberOfChars) : stringToReduce;   
        return stringToReduce;
    }

    /*******************************************************************************************************
    *
    * INNER INTERFACE.
    *
    ********************************************************************************************************/       
    /*******************************************************************************************************
    * @description interface with the methods needed to request Credit Info Report;
    */
    public interface CreditInfoProvider{
        //method to make request to credit info provider
        CreditInfoProviderResponse doRequest(String taxPayerNumber);

        //method to parse response from credit info provider to DBProp
        DBProp parseXML(String xml_response);
    }
}