/**
* @date 2017
*
* @description Wrapper Class for the sObject Accounts. Useful for using in visualforce pages (ex: Partner Portal, client Portal) to show some additional information associated with the sObject instance.
*/

public virtual class AccountWrapper {
	Static Final String APP_STATUS_APPROVED = 'Application - Approved';
	Static Final String APP_STATUS_PENDENT = 'Application - Pendent';
	Static Final String ACCOUNT_STATUS_APPROVED = 'Credit Line - Approved';

    private ID ID {get; set;}
    private String type {get; set;}
    private Account account {get; set;}
    private Login__c login {get; set;}
    private ReportDB__c report {get; set;}
    private List<Login__c> logins {get; set;}
    private List<Contact> contacts {get; set;}
    private List<Attachment> attachments {get; set;}

	private List<dsfs__DocuSign_Recipient_Status__c> docuSignStatus {get; set;}
	private List<Application__c> applicationsClient {get; set;}
	private List<Application__c> applicationsVendor{get; set;}

	//control variables frontend
	private Integer number_of_apps;
	private Boolean can_submit_new_app;
	private Datetime last_modified_app_date;
	private String keywords;

	private Application__c last_aprroved_application;
	private Application__c last_app;

	private String info;

	//docusign variables:
	private DocuSign DocuSignVars;
	private boolean isContractSent {get;set;}

	//dcision 
	private DecisionWrapper decision {get;set;}



    /*******************************************************************************************************
    * Constructor
    */
	public AccountWrapper(Account acc){
        this.account = acc;
        this.attachments = acc.Attachments;
        this.logins = acc.Login__r; 
        this.contacts = acc.Contacts;
        this.report = acc.Reports_DB__r.size()>0  ? acc.Reports_DB__r[0] : null;
		this.applicationsClient = acc.Clientapplications__r;
		this.applicationsVendor = acc.Applications__r;
		this.can_submit_new_app = true;
		this.number_of_apps = 0;
		this.keywords = this.account.Keywords__c;
		this.ID = acc.ID;
        this.type = acc.Type;

		if(acc.Clientapplications__r != null && acc.Clientapplications__r.size() > 0){
			
			this.last_app = this.applicationsClient[0];
			this.keywords = this.keywords +', ' + last_app.Name;
			this.info = (this.account.Account_Status__c !='Red' && this.account.Account_Status__c !='Black' && last_app.Status__c != ACCOUNT_STATUS_APPROVED) ? last_app.Reject_Reason__c : null;
			this.last_aprroved_application = this.last_app.Status__c == APP_STATUS_APPROVED ? this.last_aprroved_application = last_app : null;
			this.number_of_apps = this.applicationsClient.size();
			this.last_modified_app_date = this.last_app.Application_Date__c; 
			//flag to check if exist open status for this account. if exist open status (NULL, Approved and Pendent) new app requests cannot be made -> this boolean = false
			this.can_submit_new_app = !(last_app.Status__c == null || last_app.Status__c == APP_STATUS_APPROVED || last_app.Status__c == APP_STATUS_PENDENT);
			this.account.Credit_Line_Status__c = this.last_app.Status__c != null ? this.account.Credit_Line_Status__c : null; //reset status account para null se a ultima app n tem status
			this.info = this.last_app.Status__c == null && this.report.Last_Request_Status__c == 'ERROR' ? 'O serviço do nosso parceiro InformaDB está com problemas: A decisão poderá demorar mais algum tempo.' : this.info;
		}

		//override the info defined in application__c	
		this.info = acc.Credit_Line_Status__c == 'Credit Line - Suspended' ? Label.PP_ERROR_AccSuspension : this.info; 

		if(acc.dsfs__R00N80000002vw3gEAA__r != null){
			this.DocuSignVars = new DocuSign();
			this.DocuSignVars.recipients = acc.dsfs__R00N80000002vw3gEAA__r;
			for(integer n = 0; n < this.DocuSignVars.recipients.size(); n++) {
				if(this.DocuSignVars.recipients[n].dsfs__Recipient_Status__c == 'AutoResponded' && this.DocuSignVars.recipients[n].dsfs__Parent_Status_Record__r != null ){
					if(this.last_aprroved_application != null && this.DocuSignVars.recipients[n].dsfs__Parent_Status_Record__r.Docusign_Application_Status__c == this.last_aprroved_application.ID){
						this.DocuSignVars.alert_date = this.DocuSignVars.recipients[n].dsfs__Date_Sent__c;
						this.DocuSignVars.alert = true;
					}
				}
			}
		}

		if(acc.Decisions__r!=null && acc.Decisions__r.size()>0){
			this.decision = new DecisionWrapper(acc.Decisions__r);
		}

     	System.debug('[AccountWrapper - construtor] Object: '+ this);
	}


	 /*******************************************************************************************************
    * @description Set the BBAN__c in the
    * @param iban -> is the new IBAN for the Account  
    * @param doUpdate -> if true updates the Account sObject
    * @return the sObject Account with the new Iban
    
	public Account setIBAN (String iban, boolean doUpdate){
        if(this.account != null){
            iban = iban.substring(4);
            this.account.BBAN__c = iban;
            if(doUpdate){
	    		Account accUpdateIban = new Account(Id = this.ID, BBAN__c = iban);
            	update accUpdateIban;
            	System.debug('[AccountWrapper - setIBAN] Iban number for account '+ this.ID + ' updated to '+ iban);
            }else{
            	System.debug('[AccountWrapper - setIBAN] Iban number for account '+ this.ID + ' change to '+ iban + 'but NOT UPDATED');
            }

            return this.account;
        }

        return null;
    }

	 /*******************************************************************************************************
    * @description Update the BBAN__c in the account from the IBAN
    * @param iban -> is the new IBAN for the Account  
    * @return the sObject Account with the new Iban
    
	public Account updateIBAN (String iban){
        return setIBAN(iban,true);
    }

 	/*******************************************************************************************************
    * @description Set the Addres fields from the Account
    * @param address -> new address  
    * @param doUpdate -> if true updates the Account sObject
    * @return the sObject Account with the new Address
    
	public Account setAddress (AccountWrapper.Address address, boolean doUpdate){
		if(this.account != null){
			this.account.BillingCity = address.BillingCity;
			this.account.BillingStreet = address.BillingStreet;
			this.account.BillingPostalCode = address.BillingPostalCode;
			if(doUpdate){
				Account accUpdateAddress = new Account(Id = this.ID, BillingCity = address.BillingCity, BillingStreet = address.BillingStreet, BillingPostalCode = address.BillingPostalCode);
				update accUpdateAddress;
            	System.debug('[AccountWrapper - setAddress] Address for account '+ this.ID + ' updated to '+ address);
			}else{
            	System.debug('[AccountWrapper - setAddress] Address for account '+ this.ID + ' updated to '+ address + 'but NOT UPDATED');
            }

            return this.account;
		}

		return null;
	}

 	/*******************************************************************************************************
    * @description Update the Addres fields from the Account
    * @param address -> new address  
    * @param doUpdate -> if true updates the Account sObject
    * @return the sObject Account with the new Address
    
	public Account updateAddress (AccountWrapper.Address address){
		return setAddress(address, true);
	}	

	//GET SOBJECT Report_DB__c
	public virtual ReportDB__c getSObjectReport(){
		return this.report;
	}

	//GET SOBJECT ACCOUNT
	public virtual Account getSObjectAccount(){
		return this.account;
	}

	//GET LOGIN SOBJECT
	public virtual List<Login__c> getSObjectListLogins(){
		return this.logins;
	}

	public virtual Map<Id, Login__c> getSObjectMapLogins(){
		return new Map<Id, Login__c>(this.logins);
	}

	public virtual  Login__c getSObjectLogin(ID loginID){
		Map<Id, Login__c> mapLogins =  new Map<Id, Login__c>(this.logins);
		return mapLogins.get(loginID);
	}

	//GET CONTACT SOBJECT
	public virtual List<Contact> getSObjectListContacts(){
		return this.contacts;
	}

	public virtual Map<Id, Contact> getSObjectMapContacts(){
		return new Map<Id, Contact>(this.contacts);
	}

	public virtual  Contact getSObjectContact(ID contactID){
		Map<Id, Contact> mapContact =  new Map<Id, Contact>(this.contacts);
		return mapContact.get(contactID);
	}

	//GET ATTACHMENTS SOBJECT
	public virtual List<Attachment> getSObjectListAttach(){
		return this.attachments;
	}

	public virtual Map<Id, Attachment> getSObjectMapAttach(){
		return new Map<Id, Attachment>(this.attachments);
	}

	public virtual Attachment getSObjectAttach(ID attachID){
		Map<Id, Attachment> mapAttachment =  new Map<Id, Attachment>(this.attachments);
		return mapAttachment.get(attachID);
	}

	public virtual  List<Attachment> getSObjectAttach(List<String> searchWord){
		
		boolean wasFound = false;
		List<Attachment> attchList = new List<Attachment>();
		
		for(Attachment attch : this.attachments){
			for(String w : searchWord){
				wasFound = wasFound || attch.Name.contains(w);	
			}
			if(wasFound){attchList.add(attch);} 
		}
		
		return attchList;
	}*/


 	/*******************************************************************************************************
    * @description Check if sObject ReportDB__c is valid according to the date of Last Request
    * @param ReportDB__c creditInfo  
    * @return boolean
    */
	public static boolean isCreditReportValid(ReportDB__c creditInfo, Decimal validMonths){
		//this query doesn't count to governor limits __mdt
        Decimal REPORT_MATURITY_DATE = validMonths;
        boolean reportok=false;

	    if(creditInfo!=null){
            Date DateOfReport = creditInfo.Last_Request__c == null ? Date.valueOf(creditInfo.lastmodifieddate) :  Date.valueOf(creditInfo.Last_Request__c);
            Date now = Date.today();
            Decimal monthsSinceEval = 0;
            // Get months since report was analysed
            if(DateOfReport != null){
                monthsSinceEval=(DateOfReport.daysBetween(now)/30); 
                System.debug('[AccountWrapper - isCreditReportValid()] minimun number of months in order to report be valid: ' + REPORT_MATURITY_DATE);
                System.debug('[AccountWrapper - isCreditReportValid()] months since last request: ' + monthsSinceEval);
                if(monthsSinceEval < REPORT_MATURITY_DATE ){
                    reportok=true;
                }
            }  
        }
        
        System.debug('[AccountWrapper - isCreditReportValid()]: is report valid? -> ' + reportok);

        return reportok;
	}

	/*******************************************************************************************************
    * Inner Class to handle the docuSign in order to help deal with the docuSign
    */
	public class DocuSign{
		public List<dsfs__DocuSign_Recipient_Status__c> recipients {get;set;}
		public Datetime alert_date {get;set;}
		public boolean alert {get;set;}
	}

    /*******************************************************************************************************
    * Inner Class to handle the address in order to help update address field in Account sObject
    */
	public class Address{
		public Id accountId {get;set;}
		public string BillingCity {get;set;}
		public string BillingStreet {get;set;}
		public string BillingPostalCode {get;set;}
		public string PostalCodeFirst {get;set;}
		public string PostalCodeSecond {get;set;}
	}

	/*******************************************************************************************************
    * Inner Class to contruct list of wrappers account
    */
	public class ListOfAccountWrapper{ 

		public List<AccountWrapper> account_wrapper_list = new List<AccountWrapper>();
		public boolean has_empty_status;

		/*******************************************************************************************************
		* Constructor
		*/		
		public ListOfAccountWrapper(List<Account> accList){
			
			System.debug('[AccountWrapper.ListOfAccounts - construtor] List<Account> accList: ' + accList);
		 	Decimal REPORT_MATURITY_DATE = [SELECT Id, Report_Maturity_Date__c FROM Credit_Info_Provider_Setting__mdt WHERE DeveloperName = 'PT' LIMIT 1].Report_Maturity_Date__c;
		 	Map<Id, DecisionWrapper.ConditionWrapper> accountIdConditionsMap = decisionWrapper.getConditionHistoryForAccount(accList);
			Integer i = 0;
			this.has_empty_status = false;
			
			for(Account acc : accList){

				AccountWrapper aw = new AccountWrapper(acc);
				//set conditions to decision if is null
				if(aw.decision != null && aw.decision.conditions == null) {aw.decision.conditions = accountIdConditionsMap.get(acc.Id);}

				if(aw.last_app.Status__c == null && i < 2 && aw.account.Credit_Line_Status__c==null){
					this.has_empty_status = true;
				}

				//only add accounts that have valid reports or have Renting applications
				if((AccountWrapper.isCreditReportValid(aw.report,REPORT_MATURITY_DATE) || aw.applicationsClient.size()>0 || aw.last_aprroved_application != null) && aw.number_of_apps > 0){
					this.account_wrapper_list.add(aw); 
				}
				
				i++;
			}

			System.debug('[AccountWrapper.ListOfAccounts - construtor] Acc list size: '+ this.account_wrapper_list.size());
			System.debug('[AccountWrapper.ListOfAccounts - construtor] Object: '+ this);			
		}
	}
}