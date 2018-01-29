public class Client{

	private String NIF;
	private Account client;
	//private boolean isVendor = false;	//(HP)  26/09/2017 --> parceiros podem agora ser clientes

	public Client(String NIF){
		this.NIF = NIF;

		list<Account> listClient = Database.query(getQueryCLientString('NIF__C',NIF));
		
		if (listClient.size()>0){
			this.client = listClient[0];
			System.debug('[Client - construtor] Client account: ' + this.client.ID + '; Name: ' +listClient[0].Name);
		}
	}

	public Client(Id clientId){
		
		list<Account> listClient = Database.query(getQueryCLientString('ID', clientId));

		if (listClient.size()>0 && listClient[0].Type == 'Customer - Channel'){
			this.client = listClient[0];
			this.NIF = listClient[0].NIF__c;
			System.debug('[Client - construtor] Client account: ' + this.client.ID + '; Name: ' +listClient[0].Name);
		}
	}

	public String getQueryCLientString(String field, String param1){
		return 	'SELECT Id, Name, BBAN__c, NIF__c, Credit_Line_Status__c, Type, Personal_Guarantee__c,Available_Credit_Line__c, c2g__CODABankIBANNumber__c, c2g__CODAInvoiceEmail__c, ' + 
	   		   	'(SELECT lastmodifieddate, Last_Request__c  FROM Reports_DB__r ORDER BY CREATEDDATE DESC), ' +
	   		   	'(SELECT ID, Name, Account__c, Credit_Info__c, Score__c, Grade__c, Decison_Status__c, Sub_Grade__c, Decision_Origin__c, Guidance_Limit_Min__c, Guidance_Limit_Max__c, ' +        
        		' Override__c, Active__c, Account__r.BillingCountry FROM Decisions__r WHERE Active__c = TRUE ORDER BY CREATEDDATE DESC LIMIT 1 ), ' +
	   		   	'(SELECT Id, Name, ScoreCard__c, ScoreCard_Config_Final__c, ModifierActCAE__c, Available_Credit_Line__c FROM Clientapplications__r ' + 
	           	'WHERE Status__c = \'Application - Approved\' OR Status__c = \'Contract - Running\' ' +
           	   	'ORDER BY createdDate Desc) '+
			   	'FROM Account ' + 
		   	   	'WHERE ' + field + ' = \''+ param1 +'\' AND Type = \'Customer - Channel\'';
	}

	public Account getAccount(){
		if(client!=null){
			return client;
		}else{
			return null;
		}	

	}

	public Id getId(){
		if(client!=null){
			return client.Id;
		}else{
			return null;
		}
	}

	/*public boolean existAsVendor(){
		return isVendor;
	}*/

	public Account createAccount(){
		System.debug('[Client - createAccount () ] going to create account for NIF: ' + this.NIF);
		if(client==null /*|| isVendor*/){
			Account newClient = new Account();
			newClient.Name=NIF;
			newClient.NIF__c=NIF; 
			newClient.Type='Customer - Channel';
			System.debug('[Client - createAccount() ] sObject Account to be inserted: ' + newClient);
			insert newClient;
			client = newClient;
			return newClient;

		}else{
			return null;
		}
	}

	public static Account getAccountFromID(Id ID) {
		List<Account> clientList =[SELECT Id, Name, Credit_Line_Status__c, Type, Personal_Guarantee__c, NIF__c 
				FROM Account 
				WHERE Id=:ID AND Type='Customer - Channel'];

		return clientList[0];
	}

	/*Get Applications with the Status Contract. 
	HP - 2017/05/23*/
	public List<Application__c> getContracts(){

		if(client!=null){
			List<Application__c> contractList = [SELECT Id, Status__c
											FROM Application__c 
											WHERE AccClient__c=:client.Id 
											AND Status__c LIKE 'Contract%'
											AND Cancelled__c = false ];

			return contractList;
		}else{
			return null;
		}
	}

	/*Set the client email where invoice is sent. 
	HP - 2017/05/23
	String email -> string with new email;
	boolean ignoreContractStatus 	-> If true allow to change email even if exist Applications in Contract - Running;*/
	public boolean setInvoiceEmail(String newEmail, boolean ignoreContractStatus){
		
		boolean result = false;
		List<Application__c> appContracts = getContracts();

		if(!ignoreContractStatus && appContracts!=null && appContracts.size()>0){
			return result;
		}
		
		if(client!=null){
			Account clientAcc = new Account();
			clientAcc.Id = client.Id;
			clientAcc.c2g__CODAInvoiceEmail__c = newEmail;
			result = true;
			update clientAcc;
		}
		return result;
	}

	/*return the email where invoice is sent. 
	HP - 2017/05/23*/
	public String getInvoiceEmail(){
		String email;
		if(client!=null){
			email = client.c2g__CODAInvoiceEmail__c;
		}
		return email;
	}

	public Map<Id,Integer> numberOfOpenAppsByVendor(){

		Map<Id,Integer> result = new Map<Id,Integer>();

		List<AggregateResult> groupedResults = [SELECT count(AccClient__c), vendor__c
		FROM Application__c 
		WHERE AccClient__r.NIF__c=:NIF 
		AND (Status__c = '' 
		OR Status__c = 'Application - Approved' 
		OR Status__c = 'Application - Pendent') 
		AND Cancelled__c = false 
		GROUP BY vendor__c
		HAVING count(id)>=1];

		for(AggregateResult ar : groupedResults){
			result.put((Id) ar.get('vendor__c'),(Integer) ar.get('expr0'));
		}

		return result;
	}

	public List<String> numberOfOpenAppsByVendor(Id vendor){

		List<String> result = new List<String>();

		List<Application__c> vendorsFullName = [select IdLoginCreate__r.Vendor_First_Name__c,  IdLoginCreate__r.Vendor_Last_Name__c
                FROM Application__c 
                WHERE AccClient__r.NIF__c=:NIF
                AND (Status__c = '' 
                OR Status__c = 'Application - Approved' 
                OR Status__c = 'Application - Pendent') 
                AND Cancelled__c = false 
                AND vendor__c =: vendor limit 1];

               for(Application__c acc : vendorsFullName)
               {
               	 result.add('FAILED_HAS_OPEN_APP'+':'+acc.IdLoginCreate__r.Vendor_First_Name__c + ' ' + acc.IdLoginCreate__r.Vendor_Last_Name__c);
               } 

		return result;
	}

	public ReportDB__c getReport(){
		if(client!=null){
        	
        	List<ReportDB__C> reportDB= client.Reports_DB__r;

            if(reportDB.size()>0){
            	return reportDB[0];
            }else{
            	return null;
        	}

     	}else{
     		return null;
     	}
	}

	public boolean exist(){
		if(client!=null){
			return true;
		}else{
			return false;
		}
	}

	public String getCreditLineStatus(){
		if(client!=null){
			return client.Credit_Line_Status__c;
		}else{
			return null;
		}
	}

	public boolean setClientAddress (Client.Address address){

		Account client = new Account();

		client.Id = address.accountId;
		client.BillingCity = address.BillingCity;
		client.BillingStreet = address.BillingStreet;
		client.BillingPostalCode = address.BillingPostalCode;
		update client;
		
		return true;
	}

	public boolean setClientIban (String iban){
		if(this.client != null){
			//TODO: change for field of FinancialForce c2g__CODABankIBANNumber__c
			//client.c2g__CODABankIBANNumber__c = iban;
			client.BBAN__c = iban.removeStart('PT50');
			//if (client.c2g__CODABankIBANNumber__c != null){
			update client;
			System.debug('[Client - setClientIban] Iban number for client '+ client.Name + ' updated to '+ iban);
			return true;
			//}else{
			//	return false;
		//	}
		}	
		System.debug('[Client - setClientIban] Failed to save iban number'+ iban +' -> account client not in context');
		return false;
	} 

	public static boolean reportIsValid(ReportDB__c report){
		
		/*List<scorecard_Config__c> scorecard =[SELECT id, Matching_Value_To_Nr__c  
                                              FROM ScoreCard_Config__c 
                                          	  WHERE RecordType.Name='Score Card' AND fieldName__c='CreditLine Maturity Date'];*/
        //System.debug('[Client.reportIsValid]: scorecard -> ' + scorecard);

        //HP -> 17/10/2017 change settings to metadata type
        Decimal REPORT_MATURITY_DATE = [SELECT Id, Report_Maturity_Date__c FROM Credit_Info_Provider_Setting__mdt WHERE DeveloperName = 'PT' LIMIT 1].Report_Maturity_Date__c;
        if(Test.isRunningTest())REPORT_MATURITY_DATE = 1;
        
        boolean reportok=false;

	    if(report!=null){
            Date DateOfReport = report.Last_Request__c == null ? Date.valueOf(report.lastmodifieddate) :  Date.valueOf(report.Last_Request__c);
            Date now = Date.today();
            Decimal monthsSinceEval = 0;
            // Get months since report was analysed
            if(DateOfReport != null){
                monthsSinceEval=(DateOfReport.daysBetween(now)/30); 
                System.debug('[Client.reportIsValid] meses desde o ultimo request: ' + monthsSinceEval);
                if(monthsSinceEval < REPORT_MATURITY_DATE ){
                    reportok=true;
                }
            }  
        }
        
        System.debug('[Client.reportIsValid]: is report valid? -> ' + reportok);

        return reportok;
	}

	/*public static boolean exist(String inputNIF){
		List<Account> clientList=[SELECT Id, Type FROM Account WHERE NIF__c=:inputNIF AND Type = 'Customer - Channel'];
		if(clientList.size()>0 && clientList[0].Type == 'Customer - Channel'){
			return true;
		}else{
			return false;
		}
	}*/

	//Analise de cliente com base na segunda versão do algoritmo de decisão de crédito -> Devolve id do queueable or 'OK' string
	public String analyseClient_v2(ID appId){//CRIACAO - 17/10/2017 (HP)
		
		String jobID;
		
		//Get report from client id exists
        ReportDB__c reportDB = getReport();

        //check if exsting report is valid
        boolean reportok = reportIsValid(reportDB);
        CreditInfoContext  ctx = new CreditInfoContext(this.nif, 'PT', this.client.ID, appId);
        CreditInfoProviderRequest creditInfoRequest = new CreditInfoProviderRequest(ctx);
        
        if(reportok == true && client.Decisions__r.size()>0){
        	Map<String,Object> fillSObjectResultMap = creditInfoRequest.fillSObjectsFieldsfromDecision(true);
        	jobID = fillSObjectResultMap != null ? 'OK' : 'FAILED_TO_UPDATE_SOBJECTS';
        	System.debug('[Client.analyseClient] - Result for updating Application__c and Account existing Decision__c: ' + jobID + '; sObjects: ' + fillSObjectResultMap);
        }else{
        	jobID = System.enqueueJob(creditInfoRequest);
        	System.debug('[Client.analyseClient] - CreditInfoProviderRequest jobID: ' + jobID);
        }

        return jobID;
	}
	
	//DEPRECATED HP 14/12/2017
	/*public void analyseClient(String appId)//CRIACAO -22/03/17 (BP)
	{	
		Application__c newApp= new Application__c(id=appId);
        //Get report from client id exists
        ReportDB__c reportDB = getReport();
        System.debug('[Client.analyseClient] - reportDB for client ' + client.Id +' -> ' + reportDB);
        
        //check if exsting report is valid
        boolean reportok = reportIsValid(reportDB);
        
        //Check credit line status to see if is necessary to get new report
        string client_credit_line_status = getCreditLineStatus();

		//if report is ok and credit line status is approved then get the coditions from the last approved application
        if(reportok == true && client_credit_line_status == 'Credit Line - Approved')
        {

            // search for previous app and set scorecardconfig the same value
            list<Application__c> LastAppList = client.Clientapplications__r;
        
            if (LastAppList.size()>0)
            {	
            	Application__c LastApp 			 = LastAppList[0];
            	newApp.ScoreCard__c 			 = LastApp.ScoreCard__c;
	    		newApp.ModifierActCAE__c 		 = LastApp.ModifierActCAE__c;
	  			newApp.ScoreCard_Config_Final__c = LastApp.ScoreCard_Config_Final__c;
			    if(LastApp.Available_Credit_Line__c<=0)
			    {
			        newApp.Client_Available_Credit_Line__c=0;
			        client.Available_Credit_Line__c=0;
			    }        
			    else
				    newApp.Client_Available_Credit_Line__c= LastApp.Available_Credit_Line__c;

			    List <ScoreCard_Config__c> allowedLimits =[SELECT id,name,fieldname__c,Matching_Value__c  
			                                                 FROM ScoreCard_Config__c 
			                                                WHERE fieldname__c LIKE '%Credit Allowed' LIMIT 2];
			    Decimal minCreditAllowed;
			    Decimal maxCreditAllowed;

			    for(Integer i=0; i<allowedLimits.size();i++)
			    {
			        if(allowedLimits[i].fieldname__c=='Minimum Credit Allowed')
			            minCreditAllowed=Decimal.valueOf(allowedLimits[i].Matching_Value__c);
			        else//Maximum Credit Allowed
			            maxCreditAllowed=Decimal.valueOf(allowedLimits[i].Matching_Value__c);    
			    }
			    
			    if(newApp.Client_Available_Credit_Line__c>=minCreditAllowed)// && app.Client_Available_Credit_Line__c<=maxCreditAllowed)
			    {
			        newApp.status__c = 'Application - Approved';
			        client.Credit_Line_Status__c = 'Credit Line - Approved';
			        Notification__c notifApproved= new Notification__c(application__c=newApp.Id, Message__c='Aprovado');
			    	insert notifApproved;
			    }
			    else
			    {
			        newApp.status__c = 'Application - Rejected';
			        client.Credit_Line_Status__c = 'Credit Line - Rejected';

			        Notification__c notif= new Notification__c( application__c=newApp.Id, 
			                                                   Message__c='Linha de crédito disponível é inferior a '+minCreditAllowed+'€.');
			                                                   //'ou superior a'+ maxCreditAllowed+'.'); 
			        insert notif;
			        newApp.Reject_Reason__c='Linha de crédito disponível é inferior a '+minCreditAllowed+'€.';   
			    } 

			    update client;
			    update newApp;
			}
 			else
            {
                ID jobID = System.enqueueJob(new AttendReports( newApp.Id,NIF,client.Id));
                System.debug('[Client.analyseClient] - New Application ID:' + newApp.Id + '. New decision with the job Id: ' + jobID);
            }
            //if credit line rejected or report is out of date reanalyse report  
        }
        else if(reportok==false)//|| client_credit_line_status!='Credit Line - Approved') ALTERACAO - 05/06/17 - Só faz o attendReports se o report nok (BP)
        {
            ID jobID = System.enqueueJob(new AttendReports( newApp.Id,NIF,client.Id));
            System.debug('[Client.analyseClient] - New Application ID:' + newApp.Id + '. New decision with the job Id: ' + jobID);

        }else{

          ScoreCardConfig.GetCreditLineStatus(client.ID,newApp.Id);
          System.debug('[Client.analyseClient] - Application ID:' + newApp.Id + '. GetCreditLineStatus to client: ' + client.ID);

        }
	}*/

	public static map<string, String> getCreditLimits(Decimal total)
    {

        Map<String,String> dataMap = new Map<String,String>();
        String MAXIMUM = [SELECT id,name,fieldname__c,Matching_Value__c  
                             FROM ScoreCard_Config__c 
                            WHERE fieldname__c LIKE 'Maximum Credit Allowed' LIMIT 1].Matching_Value__c;
        if(total == null){total = 0;}
        MAXIMUM = String.valueOf(Math.max(Decimal.valueOf(MAXIMUM), total));

        String MINIMUM = [SELECT id,name,fieldname__c,Matching_Value__c  
                             FROM ScoreCard_Config__c 
                            WHERE fieldname__c LIKE 'Minimum Credit Allowed' LIMIT 1].Matching_Value__c;
        dataMap.put('Maximum', MAXIMUM);       
        dataMap.put('Minimum',MINIMUM);
        dataMap.put('Available', String.valueOf(total));
        return dataMap;
    }//end getCreditLimits method


	public class Address{
		public Id accountId {get;set;}
		public string BillingCity {get;set;}
		public string BillingStreet {get;set;}
		public string BillingPostalCode {get;set;}
		public string PostalCodeFirst {get;set;}
		public string PostalCodeSecond {get;set;}
	}
}