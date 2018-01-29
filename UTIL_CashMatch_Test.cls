@isTest
public class UTIL_CashMatch_Test
{
	// method that inserts invoice capital journal to be used in match
	public static void createInvoiceJournal(application__c app){

		list<c2g__codaJournalLineItem__c> jnLnItemEndCMList= new list<c2g__codaJournalLineItem__c> ();

		List<Accounting_Admin__c> balAdminList = new List<Accounting_Admin__c>([Select Journal_line_type__c, General_Ledger_Account__c, Operation__c, Type__c,Description__c,Country_Code__c,Config_Name__c
		                                                                from Accounting_Admin__c 
		                                                                where Config_Name__c= 'Balance Journal' and Country_Code__c ='PT']); 


		c2g__codaJournal__c journalInterestBal=new c2g__codaJournal__c(c2g__JournalDate__c= Date.newInstance(2017, 03, 27),  c2g__Reference__c='BCL', Application__c = app.id,
		                                           Billing_Contract_Line_Item__c = null, c2g__JournalDescription__c='Invoice Capital BCL' ,
		                                           Sales_Invoice__c = null,   TypeDescription__c = 'Invoice Capital'    );      

		insert journalInterestBal;
		id c2gAccount=null;
		decimal journval=null;

		for(Accounting_Admin__c BalJnAdmin : balAdminList){

			if(BalJnAdmin.Journal_Line_Type__c=='Account - Customer'){
			    c2gAccount=app.AccClient__c;
			    journval=150;
			} else {
				c2gAccount=null;
			}

			if( BalJnAdmin.Journal_Line_Type__c=='General Ledger Account'){
				if(BalJnAdmin.Operation__c=='(-)' ){
					journVal= - 150;
				}
			    else{
			    	journval=150;
			    }
			}
			if(BalJnAdmin.Operation__c=='(-)' ){

			    journVal= journval * -1;
			}
			//journalItem changed to accomodate development ACCOUNTING INTEREST    
			c2g__codaJournalLineItem__c jnLnItemEndCM=new c2g__codaJournalLineItem__c(c2g__LineType__c=BalJnAdmin.Journal_Line_Type__c, c2g__Account__c= c2gAccount,
			                                                                        c2g__GeneralLedgerAccount__c= BalJnAdmin.General_Ledger_Account__c, c2g__Value__c =journVal.setscale(2),
			                                                                        c2g__Journal__c=journalInterestBal.id);
			jnLnItemEndCMList.add(jnLnItemEndCM);


		}
		insert jnLnItemEndCMList;

		List<c2g.CODAAPICommon.Reference> refs = new List<c2g.CODAAPICommon.Reference>();

		c2g.CODAAPICommon.Reference ref1 = new c2g.CODAAPICommon.Reference();  
		ref1.Id = journalInterestBal.id;
		refs.add(ref1);

		c2g.CODAAPIJournal_6_0.BulkPostJournal(null, refs);


	} 



	@isTest (seeAllData=true)
	static void doInvoiceCapitalMatchTest()
	{
		Map<String, ID> datamap=new Map<String, ID>(CM_ContractManagementTest.setupCMS());
		test.startTest();
		
		application__c app=[select name, accClient__c from application__c where id= :datamap.get('app')];

		createInvoiceJournal(app);


		UTIL_CashMatch UT = new UTIL_CashMatch();
		UT.doInvoiceCapitalMatch(app);
				       
		Test.stopTest();


	}

	@isTest (seeAllData=true)
	static void doInvoiceCapitalMatchTestWithError1(){
		Map<String, ID> datamap=new Map<String, ID>(CM_ContractManagementTest.setupCMS());
			application__c app=[select name, accClient__c from application__c where id= :datamap.get('app')];
		UTIL_CashMatch UT = new UTIL_CashMatch();
		UT.doInvoiceCapitalMatch(app);
	}

	@isTest (seeAllData=true)
	static void doInvoiceCapitalMatchTestWithErrorExcep(){

		application__c app=new application__c();
		UTIL_CashMatch UT = new UTIL_CashMatch();
		UT.doInvoiceCapitalMatch(app);
	}

}