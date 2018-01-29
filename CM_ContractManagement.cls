public class CM_ContractManagement {
	public map<string, string> Result{get; set;}
	
	public CM_ContractManagement() {
		this.Result=New map<string, string> ();
	}
	public  map<string, string>  checkEligibilityforET(Billing_Contract__c billContract){
		if(!UserInfo.isCurrentUserLicensed('c2g') && !Test.isRunningTest()){
            Result.put('Result','Error');
            Result.put('Error','The user ' +  UserInfo.getName() + ' doesn\'t have Financial Force permissions to performe this action.');
        	return Result;
        }
        
        // Validate existance of records in collection Cases; if exists contract in not eligible for early termination
        List<Collection_Case__c> collCaseExists =[Select id, name from Collection_Case__c where Billing_Contract__c =: billContract.id and Status__C!='Closed' Limit 1];
        if(collCaseExists.size()!=0){
            Result.put('Result','Error');
            Result.put('Error','Client has unpaid Invoices - ' + collCaseExists[0].name + '- that must be paid before you can proceed.' );
            return Result;
        }
        return EarlyTermination(billContract);

	}

	public  map<string, string> earlyTermination( Billing_Contract__c billContract) {
		try{
			//create Contract_management string
			List<Injunction_Settings__mdt> InjuctionSettings = [SELECT Residual_Value_Prct__c FROM Injunction_Settings__mdt Limit 1];
			//list of unpaid invoices
			List<c2g__codainvoice__c> unpaidInv= [SELECT id, name, c2g__InvoiceTotal__c  FROM c2g__codainvoice__c where billing_contract__C = :billContract.Id and c2g__PaymentStatus__c='Unpaid'];
			
			
			decimal totUnpaidInv=0;
			

			date hitdate=null;
			hitdate = (system.Today()).addDays(7);	

			// Sum of unpaid Invoices
			if(unpaidInv.size()>0){
				totUnpaidInv=unpaidInv[0].c2g__InvoiceTotal__c ;
				if (unpaidInv.size()>1){
					for (integer i=0; i<unpaidInv.size(); i++){
						totUnpaidInv=+ unpaidInv[i].c2g__InvoiceTotal__c ;
					}
				}
			}

			
			Contract_management__c cmNewRec = New Contract_management__c(Billing_Contract__c=billContract.id, Account_Client__c=billContract.Account__c,	
					Account_Vendor__c=billContract.Account_Vendor__c, CMS_Status__c ='Open',  Hit_Date__c= hitdate, Residual_Value__c = InjuctionSettings[0].Residual_Value_Prct__c,
					Unpaid_Invoice_Amount__c = totUnpaidInv, Termination_Date__c=billContract.Next_Invoice_Date__c, Residual_Value_Amount__c= (InjuctionSettings[0].Residual_Value_Prct__c/100) * billContract.Equipment_cost__c );		
			

			insert cmNewRec;
			billContract.Contract_Sub_Status__c='Early Termination';
			update billContract;
			Result.put('Result','Success');
			Result.put('Id', (string)cmNewRec.id);
			system.debug('Result' + Result);
			return Result;
		}
		catch (exception e){
			Result.put('Result','Error');
			Result.put('Error', e.getLineNumber()  + ' - '  + e.getMessage() );
			system.debug(result);
			return Result;
		}
		
	}

	
	public void expireAndSendAlertEmail(List<Contract_Management__C> CMList){
		try{
			List<Contract_Management__C> CMListUpd = New List<Contract_Management__C>();
			List<string> CMSentNbrs= New List<String>();
			List<string> CMAcceptedNbrs= New List<String>();
			Set <Id> BCIds= New Set<Id>();
			List<Billing_Contract_Line_Item__c> BclistToUpd= New List<Billing_Contract_Line_Item__c> ();
			List<Billing_Contract_Line_Item__c> BclistToDel=New List<Billing_Contract_Line_Item__c> ();

			for(Contract_Management__C CMRec : CMList){
				if(CMRec.CMS_Status__c=='Sent'){
					CMRec.CMS_Status__c='Expired';
					CMSentNbrs.add(CMRec.Name);
					CMListUpd.add(CMRec);
				}
				if(CMRec.CMS_Status__c=='Accepted'){
					CMAcceptedNbrs.add(CMRec.Name);
				}
			}

			Update CMListUpd;

			string[] address=new string[]{'info@candor.pt'};


			Utilities.SendEmail(address, 'The following Early Termination Contract(s) with Status Sent Expired: ' + CMSentNbrs + '\\n The following Early Termination Contract(s) with Status Accepted have hit HitDate with Invoices pending Payment: ' + CMAcceptedNbrs, 'Contract Management Expiration');

		}
		catch(exception e){

			Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL',
			ApplicationID__c = 'CM expireAndSendAlertEmail', message__c = e.getMessage(), printStackTrace__c = e.getStackTraceString());

			insert record;
		
		}
}
	//public List<Billing_contract_line_item__C> ET_InactivateOldAndCreateNewBCLI(List<Contract_Management__C>  CMList){
	public map<string, string> et_InactivateOldAndCreateNewBCLI(List<Contract_Management__C>  CMList){
		try{
				set <Id> BCIds = new Set<Id>();
				For (Contract_Management__C CMRec :CMList){
					BCIds.add(CMRec.Billing_Contract__c);
				}
				/// corrigir para permitir mais que um BC de entrada
				List<Billing_contract_line_item__C> oldbcli =[select id, active__c, interest__C from Billing_contract_line_item__C where Billing_Contract__c in :BCIds and invoiced__c = false /*and line_item_start_date__c> TODAY */ and active__c=true]; // Date filter commented out to test in PreProd... check if there is a reason to leave it in for production
				List<Billing_contract_line_item__C> updbcli=new List<Billing_contract_line_item__C> ();
				List<Billing_contract_line_item__C> newbcli=new List<Billing_contract_line_item__C> ();
				List<Billing_contract_line_item__C> updnewbcli=new List<Billing_contract_line_item__C> ();
				list<PricebookEntry> listProdMB=[Select PriceBook2.id, UnitPrice, Product2.id  From PricebookEntry where Product2.ProductCode ='PT03'];
				map<string,decimal> mapMBPrice = New map<string,decimal> ();
				for(PricebookEntry mbprodRec :listProdMB ){
					mapMBPrice.put( (string) mbprodRec.PriceBook2.id + (string) mbprodRec.Product2.id, mbprodRec.UnitPrice);
				}

				Bill_ProductRegion billProdRegion = New Bill_ProductRegion();
				List<Contract_Management__C> UpdCMList = New List<Contract_Management__C>();
				// map do store values to be used in bcli records
				map<string, string> prodCdTxCd= new map<string, string> ();
				decimal sumInterestOldBcli=0;
				for(Billing_contract_line_item__C bcli :oldbcli){
					bcli.active__c=false;// check if needs to be deleted or if inactive is enough
					sumInterestOldBcli=+bcli.interest__C;
					updbcli.add(bcli);
				}
				update updbcli;

				// get id for products
				For (Contract_Management__C CMRec :CMList){
					integer maxi=3;
					string prod='';
					prodCdTxCd.put(CMRec.id + '1','PT03');
					prodCdTxCd.put(CMRec.id + 'ValuePT03', String.valueOf( mapMBPrice.get( (string) CMRec.Billing_contract__r.Application__r.Price_Book__c + (string) billProdRegion.getProduct('PT03', CMRec.Account_Tax_Zone__c))));
					prodCdTxCd.put(CMRec.id + '2','PT14');
					prodCdTxCd.put(CMRec.id + 'ValuePT14', string.valueOf(CMRec.Advanced_Expired_Payments_Amount__c));
					prodCdTxCd.put(CMRec.id + '3','PT20');
					prodCdTxCd.put(CMRec.id + 'ValuePT20', string.valueOf(CMRec.Residual_Value_Amount__c));
					prodCdTxCd.put(CMRec.id + 'region', CMRec.Account_Tax_Zone__c);
					system.debug(prodCdTxCd);

					for(integer i=1; i<=maxi; i++){
						prod=prodCdTxCd.get(CMRec.id + string.valueOf(i));
						system.debug(prod);
						Billing_Contract_Line_Item__c billContLineItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=CMRec.Billing_contract__c, Billing_Frequency__c='One Time',
			                                                                                 Line_Item_Start_Date__c=system.today(), Line_Item_End_Date__c=system.today()+15, Active__c=true,
			                                                                                 Sales_Price__c=decimal.valueOf(prodCdTxCd.get(CMRec.id + 'Value'+ prod)), Product__c=billProdRegion.getProduct(prod,  prodCdTxCd.get(CMRec.id +'region')), Quantity__c=1, 
			                                                                                 application__c=CMRec.Billing_contract__r.Application__c, Product_Tax_Code__c = billProdRegion.getTaxCode(prod, prodCdTxCd.get(CMRec.id +'region')));
			                                                                                 
			         	newbcli.add(billContLineItem);
					}

				}

				insert newbcli;


				// create sales invoice -- process wil automatically create ATM reference and Payment collection
				Result=CreateSalesInvoice(BCIds, CMList);
				if(Result.get('Result')=='Success'){
					for(Billing_contract_line_item__C BCLIRec : newbcli){
						BCLIRec.Invoiced__c=true;
						updnewbcli.add(BCLIRec);
					}
					update updnewbcli;
				}
				
				return Result;
			}
			catch(exception e){
				Result.put('Result','Error');
				Result.put('Error', 'ET_InactivateOldAndCreateNewBCLI - ' + e.getLineNumber()  + ' - '  + e.getMessage() );
				system.debug(result);
				return Result;
			}
		
	}

	
 	public  map<string, string> createSalesInvoice(Set<Id> BillIds , List<Contract_management__c> CMList){
 		Savepoint sp = Database.setSavepoint();
 		try{
			date today=system.today();		
			Set<Id> SalesId = New Set<Id>();
			Set<Id> CMIds = New Set<Id>();
			List<Contract_management__c> updCMS = New List<Contract_management__c>(); 
			
			List<c2g__codaInvoice__c> salesInvUpd = New List<c2g__codaInvoice__c>();
			Map<Id,c2g__codaInvoice__c> invoiceToInsertMap = new Map<Id,c2g__codaInvoice__c>();
			List<c2g__codaInvoiceLineItem__c> invoiceItemToInsertList = new List<c2g__codaInvoiceLineItem__c>();
			for (Contract_management__c CMRec : CMList){
				CMIds.add(CMRec.Id);
				//BillIds.add(CMRec.Billing_Contract__r.id);

			}
			// get bclis 
			List<contract_management__c> CMListBC=[select billing_contract__c,billing_contract__r.id, billing_contract__r.Application__r.name, billing_contract__r.Application__c, Account_Client__c,Account_Vendor__c, Account_Type__c,billing_contract__r.Payment_Method__c from Contract_Management__C where id in : CMIds];
			List<Billing_Contract_Line_Item__c> billItemList=[Select id, billing_contract__r.id, Product_Tax_Code__c, Product__c, Quantity__c,Sales_Price__c,Billing_Period__c from Billing_Contract_Line_Item__c where Billing_Contract__r.id in :BillIds and active__c=true and invoiced__c = false];
			List<Billing_Contract_Line_Item__c> UpdbillItemList = New List<Billing_Contract_Line_Item__c> ();
			List<c2g__codaPeriod__c> periodIDList = [SELECT ID 
			                                 FROM c2g__codaPeriod__c 
			                                 where c2g__StartDate__c <= :today and c2g__EndDate__c >= :today];
			Id currencyID = [SELECT ID 
			         FROM c2g__codaAccountingCurrency__c 
			         WHERE Name='EUR'].Id;
   
         //create and insert the salesinvoices
        for(contract_management__c CMRec : CMListBC){
        	id accCM=null;
        	
        	if(CMRec.Account_Type__c=='Channel Partner / Vendor'){
        		accCM=CMRec.Account_Vendor__c;
        	}else{
				accCM=CMRec.Account_Client__c;
        	}
            c2g__codaInvoice__c invoice = new c2g__codaInvoice__c();
            invoice.Application__c = CMRec.billing_contract__r.Application__c;
            invoice.Billing_Contract__c = CMRec.billing_contract__c;
            invoice.c2g__Account__c = accCM;
            invoice.c2g__InvoiceDate__c = today;
            invoice.c2g__DueDate__c = today.addDays(7);
            invoice.Candor_Due_Date__c = today.addDays(7);
            invoice.c2g__InvoiceDescription__c = CMRec.billing_contract__r.Application__r.name;
            invoice.c2g__CustomerReference__c = CMRec.billing_contract__r.Application__r.name;
            invoice.c2g__InvoiceCurrency__c = currencyID;
            invoice.Payment_Method__c = 'ATM Reference';
            invoice.c2g__Period__c = periodIDList[0].id;
            
            invoiceToInsertMap.put(CMRec.billing_contract__c,invoice);
        }
          insert invoiceToInsertMap.values();

         for(Billing_Contract_Line_Item__c billItem : billItemList){
         	system.debug(invoiceToInsertMap.get(billItem.Billing_Contract__c).id);
            c2g__codaInvoiceLineItem__c invoiceItem = new c2g__codaInvoiceLineItem__c();
            
            invoiceItem.c2g__Invoice__c = invoiceToInsertMap.get(billItem.Billing_Contract__c).id;
            invoiceItem.Billing_Contract_Line_Item__c = billItem.id;
            invoiceItem.c2g__TaxCode1__c = billItem.Product_Tax_Code__c;
            invoiceItem.c2g__Product__c = billItem.Product__c;
            invoiceItem.c2g__Quantity__c = billItem.Quantity__c;
            invoiceItem.c2g__UnitPrice__c = billItem.Sales_Price__c;
            invoiceItem.Line_Item_Period__c = 	billItem.Billing_Period__c;
            invoiceItem.c2g__DeriveUnitPriceFromProduct__c = false;
            
            invoiceItemToInsertList.add(invoiceItem);
          
        }
         
      
        
        //create sin line itens and insert
        insert invoiceItemToInsertList;
        // update billing line items
       // update UpdbillItemList;
		for(c2g__codaInvoice__c  invoice : invoiceToInsertMap.values()){
            invoice.Post_SalesInvoice__c = true;
            invoice.Posted_InvoiceXpress__c = true;
        }
        update invoiceToInsertMap.values();
        
		for(Contract_management__c CMRec :CMListBC){
			CMRec.sales_invoice__c=invoiceToInsertMap.get(CMRec.billing_contract__r.id).id;
			updCMS.add(CMRec);
		}
		update updCMS;

		Result.put('Result', 'Success');
		//	Result=UpdatePaymntCollct(SalesId, CMList );

			
			return Result;
		}
		catch(exception e){
			Database.Rollback(sp);
			Result.put('Result','Error');
			Result.put('Error', 'CreateSalesInvoice - ' + e.getLineNumber()  + ' - '  + e.getMessage() );
			system.debug(result);
			return Result;
		}


 	}

 	public  void updatePaymntCollct(Set<Id> ATMsId, List<Contract_management__c> CMList){
 		try{

	 		Map<id, ATM_Reference__c > mapATM=new Map<id, ATM_Reference__c >([select Payment_Collection__c, id from ATM_Reference__c where id in :ATMsId ]);
	 		List<Contract_management__c> UpdCMPayColl = New List<Contract_management__c>();
			if(Utilities.runningInASandbox()==false){
				if ( mapATM.size()==0){
					return;
				}
			}

 			for(contract_management__c CMRec :CMList ){
 				CMRec.Payment_Collection__c=mapATM.get(CMRec.sales_invoice__r.first_atm__c).Payment_Collection__c;
					UpdCMPayColl.add(CMrec);
			}

	 		update UpdCMPayColl;
	 	}
		catch(exception e){
			Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL',
            ApplicationID__c = 'CM updatePaymntCollct', message__c = e.getMessage(), printStackTrace__c = e.getStackTraceString());
            
            insert record;
		}
 	}

 	public void closeCMSAndDoMatch(Contract_Management__c CMSRec){
 		Savepoint sp = Database.setSavepoint();

 		try{
 			decimal journVal=0;
 			id c2gAccount=null;
 			id c2gproduct= null;
 			Bill_ProductRegion billProdRegion = New Bill_ProductRegion();
 			Set<Id> jnltoPost= New Set<Id>();
			Set<String> appCountryList = new Set<String>();
		
			appCountryList.add(CMSRec.billing_contract__r.Application__r.Vendor__r.BillingCountryCode);
		
	        List<Accounting_Admin__c> ETJnAdminList = [select  Config_Name__c,  General_Ledger_Account__c, Description__c, Operation__c, Type__c, Journal_Line_Type__c
			                                        from Accounting_Admin__c 
			                                        where Config_Name__c = 'Early Termination' and  Country_Code__c in :appCountryList];

			 
			List<c2g__codaJournalLineItem__c> jnLnItemEndCMList = New List<c2g__codaJournalLineItem__c>();    

            c2g__codaJournal__c jnEndCM = new c2g__codaJournal__c(c2g__JournalDate__c=system.today(),
                                                 c2g__Reference__c='Early Termination',/* sales_invoice__c=saleInvoice.id,*/
                                                 c2g__JournalDescription__c='Early Termination Journal ' +  CMSRec.billing_contract__r.Application__r.name,
                                                 application__c=CMSRec.billing_contract__r.Application__c
                                                 /*TypeDescription__c= 'Proportional Insurance', to_be_deferred__c=true,*/
                                                 /*Deferred_Type__c=(saleInvoice.application__r.Interim_Fee_Days__c/30).intvalue()*/);  
           	insert jnEndCM;

           	system.debug(ETJnAdminList);
			 for(Accounting_Admin__c ETJnAdmin : ETJnAdminList){
                    
                

                if(ETJnAdmin.Journal_Line_Type__c=='Account - Customer'){
                    c2gAccount=CMSRec.billing_contract__r.application__r.AccClient__c;
                    journval=CMSRec.Advanced_Expired_Principals_Amount__c;
                } else {
                	c2gAccount=null;
                }
                if(ETJnAdmin.Journal_Line_Type__c=='Product - Sales'){
                	system.debug(c2gproduct);
                    c2gproduct=billProdRegion.getProduct('PT20', CMSRec.Account_Tax_Zone__c);
                    journval=CMSRec.Residual_Value_Amount__c;

                } else {
                	c2gproduct=null;
                }
                if( ETJnAdmin.Journal_Line_Type__c=='General Ledger Account'){
                	if(ETJnAdmin.Operation__c=='(-)' ){
                	journVal=CMSRec.Total_Amount__c-CMSRec.Residual_Value_Amount__c-CMSRec.Advanced_Expired_Principals_Amount__c;
                	}
                    else{
                    	journval=CMSRec.Total_Amount__c;
                    }
                }
                if(ETJnAdmin.Operation__c=='(-)' ){
               
                    journVal= journval * -1;
                }
                //journalItem changed to accomodate development ACCOUNTING INTEREST    
                c2g__codaJournalLineItem__c jnLnItemEndCM=new c2g__codaJournalLineItem__c(c2g__LineType__c=ETJnAdmin.Journal_Line_Type__c, c2g__Account__c= c2gAccount,
                                                                                        c2g__GeneralLedgerAccount__c= ETJnAdmin.General_Ledger_Account__c, c2g__Value__c =journVal.setscale(2),
                                                                                        c2g__Journal__c=jnEndCM.id/*,  c2g__LineDescription__c =descrip*/, c2g__product__c=c2gproduct);
                jnLnItemEndCMList.add(jnLnItemEndCM);
                system.debug(jnLnItemEndCM);
                
            }
            insert jnLnItemEndCMList;
			jnltoPost.add(jnEndCM.id);

            //post journal to do CashMatch
         	UTIL_CancelAndCreateJournals.postJournal(jnltoPost);
         	c2g__codaJournal__c jnPosted= [select c2g__Transaction__r.id from c2g__codaJournal__c where id=:jnEndCM.id ];

       
         	//find TRS for beginning post and capitla journals and doMatch with End of Contract TRS	
         	list<c2g__codaJournal__c> listprevTrs= new list<c2g__codaJournal__c>([select c2g__Transaction__r.id from c2g__codaJournal__c 
         											where c2g__JournalStatus__c ='Complete' and c2g__CanceledJournal__c =false and application__c =:CMSRec.billing_contract__r.Application__c And (
         	 											  c2g__Reference__c= :CMSRec.billing_contract__r.Application__r.name or c2g__JournalDescription__c like 'Invoice Capital %'  )
         	 											   ]);
			set<id> prevTrs=New set<Id>();
			for(c2g__codaJournal__c prevTr :listprevTrs){
				prevTrs.add(prevTr.c2g__Transaction__r.id);
			}
			prevTrs.add(jnPosted.c2g__Transaction__r.id );



         	List<c2g__codaTransactionLineItem__c> TRNCshEntry=[select c2g__AccountValue__c, name from c2g__codaTransactionLineItem__c where c2g__LineType__c='Account' And c2g__Transaction__r.id in :prevTrs And c2g__MatchingStatus__c='Available' ];

												
			Id MatchRefId=FF_Utils.doMatch(CMSRec.billing_contract__r.application__r.AccClient__c,jnEndCM.c2g__Period__r.id,TRNCshEntry);
			if(MatchRefId != null){
				CMSRec.CMS_Status__c='Closed';
			} 
			Update CMSRec;
			// update contracto para Contract - Closed
			Application__c app=[select id, name, status__C from application__c where id= :CMSRec.billing_contract__r.application__c];
			app.status__C='Contract - Closed';
			update app;

			List<Billing_contract_line_item__c> bclisInactive=[Select id, name from Billing_contract_line_item__c where Billing_Contract__c = :CMSRec.billing_contract__c and active__c=false and invoiced__c = false];
			delete bclisInactive;

			//Send Email to notify Offer Contact that payment was received and Contract is Closed
			List<String> EmailRec=New List<String>();
			EmailRec.add(CMSRec.Offer_Notification_Contact_Email__c);
			Utilities.sendTemplatedEmail(EmailRec,'EndOfContract_EarlyTermination_End',CMSRec.Offer_Notification_Contact__c, CMSRec.Id, true);
 
 		}
		catch(exception e){
			Database.Rollback(sp);
			Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL',
        	ApplicationID__c = 'CM closeCMSAndDoMatch', message__c = e.getMessage(), printStackTrace__c = e.getStackTraceString());
        
            insert record;
			
		}
 	}
 	
 	public boolean changeInvoiceDate(Id CMSId){
 		date today=system.today();
 		Contract_management__c CMREc =[select billing_contract__c, Hit_Date__c from Contract_management__c where id = :CMSId];
 		List<billing_contract_Line_Item__c> BclisList = [select id, active__c, Line_Item_Start_Date__c, Line_Item_End_Date__c 
 				from Billing_Contract_Line_Item__c where billing_contract__c =:CMREc.billing_contract__c and Line_Item_Start_Date__c >= :today and Line_Item_Start_Date__c <= :CMRec.Hit_Date__c ];
 		
 		List<billing_contract_Line_Item__c> UpdBclisList = New	List<billing_contract_Line_Item__c>();	

 		for (billing_contract_Line_Item__c bcli  : BclisList){
 			bcli.line_item_start_date__c=CMRec.Hit_Date__c +1;
 			bcli.line_item_end_date__c=CMRec.Hit_Date__c +7;
 			UpdBclisList.add(bcli);
 		}
 		Update UpdBclisList;

 		return true;
 	
 	}
        
}