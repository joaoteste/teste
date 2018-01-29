public class PaymentPlan_Utils {
    
    public static void firstPaymentSchedule(ID ccID){
            List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id, Name, c2g__InvoiceTotal__c, Billing_Contract__c, Application__c, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c FROM c2g__codaInvoice__c WHERE  (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid' ) AND Collection_Case__c =:ccID ORDER BY CreatedDate ASC];
        
            Set<ID> apIDS = new Set<ID>();
            Set<ID> bcIDS = new Set<ID>();
            for(c2g__codaInvoice__c si : salesInvoiceList){
                if(si.Billing_Contract__c != null)
                    bcIDS.add(si.Billing_Contract__c);
                if(si.Application__c != null)
                    apIDS.add(si.Application__c);
            }
            
            Collection_Case__c cc = new Collection_Case__c();
            cc.ID = ccID;
            cc.Status__c = 'Closed';
            update cc;
            
            List<Billing_Contract__c> bcList = new List<Billing_Contract__c>();
            List<Application__c> apList = new List<Application__c>();
            
            if(!bcIDS.isEmpty()){
                for(ID bc : bcIDS){
                    Billing_Contract__c bcToUpdate = new Billing_Contract__c();
                    bcToUpdate.ID = bc;
                    bcToUpdate.Contract_Sub_Status__c = 'Partial Payment Plan';
                    bcList.add(bcToUpdate);
                }
                system.debug(bcList);
                update bcList;
            }
            
            if(!apIDS.isEmpty()){
                for(ID ap : apIDS){
                    Application__c apToUpdate = new Application__c();
                    apToUpdate.ID = ap;
                    apToUpdate.Status__c = 'Contract - Running';
                    apList.add(apToUpdate);
                }     
                
                system.debug(apList);   
            }        
    }
    
    public static Boolean startSchedule(ID ppID, String scheduleNumber){
        Payment_Plan__c pp = [SELECT ID, Type__c, ATM_Costs__c, Number_of_Payments__c, Partial_Payment_Plan_Term__c, Account__c, Collection_Case__c, Renting_Application__c FROM Payment_Plan__c WHERE ID = :ppID];
        List<Payment_Schedule__c> payScheduleList = new List<Payment_Schedule__c>([SELECT ID, Principal__c, Name, Schedule_Number__c, Due_Date__c, Amount__c, Fees_Amount__c, Total_Amount__c, Amount_W_O_Tax__c, Balance__c, Sales_Invoice__c, Late_Payment_Interest_Amount__c FROM Payment_Schedule__c WHERE Payment_Plan__c=:pp.id AND Schedule_Number__c = :scheduleNumber]);
		List<Partial_Invoice_Payment__c> pipList = new List<Partial_Invoice_Payment__c>();
		if(pp.ATM_Costs__c == null) pp.ATM_Costs__c = true;
        if(!payScheduleList.isEmpty() && payScheduleList.size()==1){
            Payment_Schedule__c ps = payScheduleList[0];
            
            //verificar que tipo- de invoice é para criar
            ID salesInvoiceId;
            Boolean addInvoices = false;
            if(pp.Type__c == 'Partial'){ 
                //create Invoice for Costs
                if(pp.ATM_Costs__c){
                	salesInvoiceId = PP_CreateSalesInvoice.createInvoice(pp.Account__c, ps.Due_Date__c, pp.Renting_Application__c);
                	ps.Sales_Invoice__c = salesInvoiceID;
                }
                addInvoices = true;
            }else{ 
                if(pp.Partial_Payment_Plan_Term__c >= Integer.valueOf(scheduleNumber)){
                    salesInvoiceId = PP_CreateSalesInvoice.createInvoiceWithInterest(pp.Account__c, ps.Due_Date__c, pp.Renting_Application__c, (Double)ps.Late_Payment_Interest_Amount__c,pp.ATM_Costs__c);
                	addInvoices = true;
                	ps.Sales_Invoice__c = salesInvoiceID;
                }else{
                	//delete bcli and activate BC
                	if(pp.Partial_Payment_Plan_Term__c == Integer.valueOf(scheduleNumber)) deleteOldContract(pp.Collection_Case__c);
                    salesInvoiceId = PP_CreateSalesInvoice.createInvoiceFull(pp.Account__c, ps.Due_Date__c, pp.Renting_Application__c, (Double)ps.Late_Payment_Interest_Amount__c, (Double)ps.Amount_W_O_Tax__c,pp.ATM_Costs__c);
                    //create capital journal 
                    createJournal(pp.Account__c, ps.Name, salesInvoiceID, (Double)ps.Principal__c, (Double)ps.Amount_W_O_Tax__c);
                	ps.Sales_Invoice__c = salesInvoiceID;
                }
                
            }
			
            
            //create Partial Invoice Payments
            
            List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>([SELECT Id, Name, c2g__InvoiceTotal__c, Billing_Contract__c, Application__c, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c FROM c2g__codaInvoice__c WHERE  (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid' ) AND Collection_Case__c =: pp.Collection_Case__c ORDER BY CreatedDate ASC]);
			
            Decimal totalAmount = ps.Amount__c;
            Integer invoiceIndex = 0;
            while(totalAmount != 0 && !salesInvoiceList.isEmpty() && addInvoices){
                c2g__codaInvoice__c si = salesInvoiceList[invoiceIndex];
                Double invoiceAmount  = si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                
                Partial_Invoice_Payment__c objPartialInvoice = new Partial_Invoice_Payment__c();
                objPartialInvoice.Payment_Schedule__c = ps.Id;
                objPartialInvoice.Sales_Invoice__c = si.ID;
                if(totalAmount >= invoiceAmount){
                	objPartialInvoice.Amount__c = invoiceAmount;
                    totalAmount -= invoiceAmount;
                }else{
                    objPartialInvoice.Amount__c = totalAmount;
                    totalAmount = 0;
                }  
                pipList.add(objPartialInvoice);
                
                invoiceIndex++;
                
                //just for tests
                if(salesInvoiceList.size() == invoiceIndex)
                    totalAmount = 0;
            }
            if(ps.Sales_Invoice__c != null){
	            //create partial invoice payment for costs
	             Partial_Invoice_Payment__c objPartialInvoice = new Partial_Invoice_Payment__c();
	             objPartialInvoice.Payment_Schedule__c = ps.Id;
	             objPartialInvoice.Sales_Invoice__c = salesInvoiceId;
	             if(pp.Type__c == 'Partial')
			     	objPartialInvoice.Amount__c = ps.Fees_Amount__c;
	             else{
	                 c2g__codaInvoice__c invoice = [SELECT Id, Name, c2g__InvoiceTotal__c FROM c2g__codaInvoice__c WHERE  ID = :salesInvoiceId ];
	
	                 objPartialInvoice.Amount__c = invoice.c2g__InvoiceTotal__c;
	             }
	             pipList.add(objPartialInvoice);
	            
	             update ps;
             }
            
             insert pipList;
             
             if(pp.Type__c == 'Partial' && scheduleNumber == '1'&& pp.Number_of_Payments__c != '1')
             	firstPaymentSchedule(pp.Collection_Case__c);
            
             if(pp.Type__c == 'Full' && scheduleNumber == '1')
                 firstFullPaymentSchedule(pp.Collection_Case__c, pp.ID);
            
             if(scheduleNumber == '1')
             	createATM(ps.ID);
				
			//update collection case recordtype
			if(scheduleNumber == '1' && pp.Number_of_Payments__c != '1'){
				RecordType recordType = [SELECT ID FROM RecordType WHERE Name = 'Collection Case With Single Payment' LIMIT 1];
				Collection_Case__c cc = new Collection_Case__c(ID = pp.Collection_Case__c);
				cc.RecordTypeID = recordType.ID;
				update cc;
			}				
            
             return true;
        }
        
        return false;
    }
    
    public static void deleteOldContract(ID ccID){
    	
    	//get BCs
    	List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id, Name, c2g__InvoiceTotal__c, Billing_Contract__c, Application__c, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c FROM c2g__codaInvoice__c WHERE  (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid' ) AND Collection_Case__c =:ccID ORDER BY CreatedDate ASC];
        
            Set<ID> bcIDS = new Set<ID>();
            for(c2g__codaInvoice__c si : salesInvoiceList){
                if(si.Billing_Contract__c != null)
                    bcIDS.add(si.Billing_Contract__c);
            }
        
        //delete not invoiced billing contract line items    
        List<Billing_Contract_Line_Item__c> bcliToDelete = [SELECT ID FROM Billing_Contract_Line_Item__c WHERE Billing_Contract__c IN :bcIDS AND Invoiced__c = false];
        delete bcliToDelete;
        
        //contract active
        List<Billing_Contract__c> bcToUpdate = new List<Billing_Contract__c>();
        for(ID contract : bcIDS){
        	Billing_Contract__c bc = new Billing_Contract__c(ID = contract);
        	bc.BC_Contract_Inactive__c = false;
        	bcToUpdate.add(bc);
        }
        
        update bcToUpdate;	
	
    }
    
	public static void firstFullPaymentSchedule(ID ccID, ID ppID){
    	//Inactivate contracts
    	
        //get all AP 
        Set<ID> apList = new Set<ID>();
		List<Application__c> apObjectList = new List<Application__c>();
		List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id, Name, c2g__InvoiceTotal__c, Billing_Contract__c, Application__c, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c FROM c2g__codaInvoice__c WHERE  (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid' ) AND Collection_Case__c =:ccID ORDER BY CreatedDate ASC];
        
        for(c2g__codaInvoice__c si : salesInvoiceList){
        	if(si.Application__c != null)
        		apList.add(si.Application__c);
        }
        
        List<Billing_Contract__c> bcList = new List<Billing_Contract__c>([SELECT ID FROM Billing_Contract__c WHERE Application__c in :apList]);
        
        for(Billing_Contract__c bc : bcList){
        	bc.BC_Contract_Inactive__c = true;  
            bc.Payment_Plan__c = ppID;
            bc.Contract_Sub_Status__c = 'Full Payment Plan';
        }
        
        for(ID ap : apList){
            Application__c app = new Application__c(ID = ap, Payment_Plan__c = ppID, Status__c = 'Contract - Running');
            apObjectList.add(app);
        }
        
        update apObjectList;
        update bcList;     

    }
    
	@future(callout=true)
    public static void createATM(Id objPaymentScheduleId){

        Payment_Schedule__c objPaymentSchedule = [select id, Payment_Plan__r.Type__c, Total_Amount__c,Amount__c,Due_Date__c,Payment_Plan__r.Collection_Case__r.Account__c,(select id,Amount__c from Partial_Invoice_Payments__r) from  Payment_Schedule__c where id =:objPaymentScheduleId LIMIT 1];
        Double total = 0;
        for(Partial_Invoice_Payment__c pip : objPaymentSchedule.Partial_Invoice_Payments__r){
            total += pip.Amount__c;
        }
        //Create Atm Reference for first payment schedule
        PaymentCollection_Utils pUtils = new PaymentCollection_Utils();
		Date dueDateAtm = objPaymentSchedule.Due_Date__c;
		if(objPaymentSchedule.Payment_Plan__r.Type__c == 'Full') dueDateAtm = dueDateAtm.addDays(15);
        List<Id> listATMPaymentIds = pUtils.createPaymentCollectionWithPartialInvoicePayments(objPaymentSchedule.Partial_Invoice_Payments__r, total,objPaymentSchedule.Id,dueDateAtm,objPaymentSchedule.Payment_Plan__r.Collection_Case__r.Account__c);
        
        //Assign ATM reference to payment schedule
        if(listATMPaymentIds!=null && listATMPaymentIds.size()>0){
            objPaymentSchedule.ATM__c = listATMPaymentIds[0];

            if(listATMPaymentIds.size()>1){
                objPaymentSchedule.Payment_Collection__c = listATMPaymentIds[1];
            }
        }
        //update schedule with ATM Reference
        update objPaymentSchedule;
        System.debug('objPaymentSchedule --->>> '+objPaymentSchedule);
    }    
    

    public static void createATMNotFuture(Id objPaymentScheduleId){

        Payment_Schedule__c objPaymentSchedule = [select id,Payment_Plan__r.Type__c, Total_Amount__c,Amount__c,Due_Date__c,Payment_Plan__r.Collection_Case__r.Account__c,(select id,Amount__c from Partial_Invoice_Payments__r) from  Payment_Schedule__c where id =:objPaymentScheduleId LIMIT 1];
        Double total = 0;
        for(Partial_Invoice_Payment__c pip : objPaymentSchedule.Partial_Invoice_Payments__r){
            total += pip.Amount__c;
        }
        //Create Atm Reference for first payment schedule
        PaymentCollection_Utils pUtils = new PaymentCollection_Utils();
        Date dueDateAtm = objPaymentSchedule.Due_Date__c;
		if(objPaymentSchedule.Payment_Plan__r.Type__c == 'Full') dueDateAtm = dueDateAtm.addDays(15);
        List<Id> listATMPaymentIds = pUtils.createPaymentCollectionWithPartialInvoicePayments(objPaymentSchedule.Partial_Invoice_Payments__r, total,objPaymentSchedule.Id,dueDateAtm,objPaymentSchedule.Payment_Plan__r.Collection_Case__r.Account__c);
         
        //Assign ATM reference to payment schedule
        if(listATMPaymentIds!=null && listATMPaymentIds.size()>0){
            objPaymentSchedule.ATM__c = listATMPaymentIds[0];

            if(listATMPaymentIds.size()>1){
                objPaymentSchedule.Payment_Collection__c = listATMPaymentIds[1];
            }
        }
        
        //update schedule with ATM Reference
        update objPaymentSchedule;
        System.debug('objPaymentSchedule --->>> '+objPaymentSchedule);
    }   
    
    /*************************************************/
    /*				JOURNALS					     */
    /*************************************************/
    @future(callout=true)    
    public static void createJournal(ID accountID, String psName, ID invoiceID, Double amount, Double totalAmount){
    	Account accountObj = [SELECT ID, BillingCountryCode FROM Account WHERE ID = :accountID];
    	List<Accounting_Admin__c> accAdminsBalance = [SELECT ID, General_Ledger_Account__c, Operation__c, Journal_Line_Type__c FROM Accounting_Admin__c WHERE Config_Name__c = 'Balance Journal' AND Country_Code__c = :accountObj.BillingCountryCode];	
    	c2g__codaInvoice__c invoice = [SELECT Id, Name, c2g__InvoiceTotal__c FROM c2g__codaInvoice__c WHERE  ID = :invoiceID ];
    	List<Accounting_Admin__c> accAdminsInterest = [SELECT ID, General_Ledger_Account__c, Operation__c, Journal_Line_Type__c FROM Accounting_Admin__c WHERE Config_Name__c = 'Transaction' AND Country_Code__c = :accountObj.BillingCountryCode AND Type__c = 'Payment Plan - Interest'];	

		//BALANCE JOURNAL
    	
		c2g__codaJournal__c journal = new c2g__codaJournal__c();
        journal.c2g__Type__c = 'Manual Journal';
        journal.c2g__JournalDate__c = System.today();
        journal.c2g__DeriveCurrency__c = true;
        journal.c2g__DerivePeriod__c = false;
        journal.c2g__Reference__c = psName;
		journal.c2g__JournalDescription__c = 'Invoice Capital '+invoice.Name;    
		journal.c2g__Period__c = Bill_EasyPayAPI.getPeriod();
		journal.Sales_Invoice__c = invoiceID;
		insert journal;
		
		List<c2g__codaJournalLineItem__c> jliList = new List<c2g__codaJournalLineItem__c>();
		
		for(Accounting_Admin__c acc : accAdminsBalance){
			c2g__codaJournalLineItem__c jli = new c2g__codaJournalLineItem__c();
            jli.c2g__Value__c = amount;
            if(acc.Operation__c == '(-)')
            	jli.c2g__Value__c = -amount;
            if(acc.Journal_Line_Type__c == 'Account - Customer')
				jli.c2g__Account__c = accountID;
				
            jli.c2g__Journal__c = journal.Id;
            jli.c2g__GeneralLedgerAccount__c = acc.General_Ledger_Account__c;
            jli.c2g__LineType__c = acc.Journal_Line_Type__c;	
            
            jliList.add(jli);		
		}
		
		insert jliList;
		
		//INTEREST JOURNAL
		c2g__codaJournal__c journalInterest = new c2g__codaJournal__c();
        journalInterest.c2g__Type__c = 'Manual Journal';
        journalInterest.c2g__JournalDate__c = System.today();
        journalInterest.c2g__DeriveCurrency__c = true;
        journalInterest.c2g__DerivePeriod__c = false;
        journalInterest.c2g__Reference__c = psName;
		journalInterest.c2g__JournalDescription__c = 'Interest '+invoice.Name;    
		journalInterest.c2g__Period__c = Bill_EasyPayAPI.getPeriod();
		journalInterest.Sales_Invoice__c = invoiceID;
		insert journalInterest;
		
		List<c2g__codaJournalLineItem__c> jliInterestList = new List<c2g__codaJournalLineItem__c>();
		Double interestAmount = totalAmount - amount;
		for(Accounting_Admin__c acc : accAdminsInterest){
			c2g__codaJournalLineItem__c jli = new c2g__codaJournalLineItem__c();
            jli.c2g__Value__c = interestAmount;
            if(acc.Operation__c == '(-)')
            	jli.c2g__Value__c = -interestAmount;
            if(acc.Journal_Line_Type__c == 'Account - Customer')
				jli.c2g__Account__c = accountID;
				
            jli.c2g__Journal__c = journalInterest.Id;
            jli.c2g__GeneralLedgerAccount__c = acc.General_Ledger_Account__c;
            jli.c2g__LineType__c = acc.Journal_Line_Type__c;	
            
            jliInterestList.add(jli);		
		}
		
		insert jliInterestList;		
		
        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
        ref.Id = journal.Id;
        
        c2g.CODAAPICommon.Reference refInterest = new c2g.CODAAPICommon.Reference();
        refInterest.Id = journalInterest.Id;
        
        List<c2g.CODAAPICommon.Reference> refList = new List<c2g.CODAAPICommon.Reference>{ref, refInterest};
        
        c2g.CODAAPIJournal_9_0.BulkPostJournal(null, refList);  		

    }

}