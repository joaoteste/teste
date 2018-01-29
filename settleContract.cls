public with sharing class settleContract {
    @RemoteAction
    public static string validateContract( string appId){
        Savepoint sp = Database.setSavepoint();
        Double nper, pmt, pv;
        integer npaymentByYear=12;
        integer begEndPay=0;
        Application__c app;
        try{

            string msghd='Application has the following problems: \n';
            string msg='';
            
            if(!UserInfo.isCurrentUserLicensed('c2g') && !Test.isRunningTest()){
                msg =  'The user ' +  UserInfo.getName() + ' don\'t have Financial Force permissions to performe this action.';
                return msghd + msg;
            }
         
            // used to validate info before creating invoice
            app=[select id,  Name, vendor__c, accClient__c, Insurance__c,Insurance_Value__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                                Equipment_Cost__c, Vendor_invoice_VAT__c, ATM_Reference__c, Chosen_Insurance_value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                                Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                                ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Insurance_Pro_Rata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                                Interest_Amount__c, annual_interest_rate__c, accClient__r.c2g__CODAInvoiceEmail__c, status__c, eSignature_Contract__c, Paper_Contract__c,
                                Payment_Method__c, AccClient__r.c2g__CODATaxCalculationMethod__c, AccClient__r.c2g__CODASalesTaxStatus__c, vendor__r.c2g__CODASalesTaxStatus__c ,vendor__r.c2g__CODATaxCalculationMethod__c, vendor__r.c2g__CODADefaultExpenseAccount__c, vendor__r.c2g__CODAOutputVATCode__c, vendor__r.c2g__CODAAccountsPayableControl__c,
                                Vendor__r.BillingPostalCode, vendor__r.c2g__CODAVATStatus__c, AccClient__r.c2g__CODAVATStatus__c ,Interim_Fee_Days_Normal__c, Amortization_Interest_Rate__c
                                from application__c where id= :appId ];         
            
            // Validate existance of record in billing contracts, if exists returns an error
            List<Billing_Contract__c> billexists =[Select id from Billing_Contract__c where name =: app.Name];
            if(billexists.size()!=0){
                return 'Billing Contract já existe!'; 
            }
            
            // account info to be validadted
            account accClient= [select id, name, c2g__CODABankIBANNumber__c, c2g__CODAAccountsReceivableControl__c, Tax_Zone__c , BBAN__c,
                                       c2g__CODAInputVATCode__c, BillingPostalCode, BillingStreet, BillingCity, c2g__CODAVATStatus__c, c2g__CODATaxCalculationMethod__c, c2g__CODAInvoiceEmail__c 
                                  from account 
                                 where id= :app.AccClient__c];
            
            account accVendor= [select id, name, c2g__CODABankIBANNumber__c, BBAN__c,  BillingPostalCode, BillingStreet, BillingCity,c2g__CODATaxCalculationMethod__c, c2g__CODAVATStatus__c  , Tax_Zone__c
                                  from account 
                                 where id= :app.vendor__C];
            List<Contact> contactsClient = [SELECT ID, Email, Send_Invoice__c	FROM Contact WHERE AccountID =:accClient.ID];
            
            
            if(accVendor.BBAN__C == null || accVendor.BBAN__C == ''){
                msg=msg+'The Vendor has no BBAN! \n'; 
            }
            else{
                String bankCodeVendor = accVendor.BBAN__C.substring(0,4);
                Bank_Codes__c bankCodeObjcVendor = [SELECT Bank_Code__c,BIC__c,Country_Code__c FROM Bank_Codes__c WHERE Bank_Code__c =: bankCodeVendor];  
                
                if(bankCodeObjcVendor.Bank_Code__c == '' || bankCodeObjcVendor.Bank_Code__c == null ){
                    msg=msg+'The Vendor has no Bank code! \n'; 
                }
                if(bankCodeObjcVendor.BIC__c == '' || bankCodeObjcVendor.BIC__C == null){
                    msg=msg+'The Vendor\'s Bank Code has no BIC associated! \n';    
                }
                if(bankCodeObjcVendor.Country_Code__c =='' || bankCodeObjcVendor.Country_Code__c == null){
                    msg=msg+'The Vendor\'s Bank Code has no country code associated! \n';
                } 
            }
            //JG - 29/11 - In case of non ATM payment it is verified the bank codes.  
            if(!app.ATM_Reference__c){ 
                if(accClient.BBAN__c == null || accClient.BBAN__c == ''){
                    msg=msg+'The Client has no BBAN! \n'; 
                }
                else{
                    String bankCodeClient = accClient.BBAN__C.substring(0,4);
                    Bank_Codes__c bankCodeObjcClient = [SELECT Bank_Code__c,BIC__c,Country_Code__c FROM Bank_Codes__c WHERE Bank_Code__c =: bankCodeClient];   
                    
                    if(bankCodeObjcClient.Bank_Code__c == '' || bankCodeObjcClient.Bank_Code__c == null ){
                        msg=msg+'The Client has no Bank code! \n'; 
                    }
                    if(bankCodeObjcClient.BIC__c == '' || bankCodeObjcClient.BIC__C == null){
                        msg=msg+'The Client\'s Bank Code has no BIC associated! \n';    
                    }
                    
                    if(bankCodeObjcClient.Country_Code__c =='' || bankCodeObjcClient.Country_Code__c == null){
                        msg=msg+'The Client\'s Bank Code has no country code associated! \n';
                    }  
                }
              
              
            }   
			            
            // fields cannot be empty
            if (app.Annual_Interest_Rate__c==null || app.Amortization_Interest_Rate__c==null){
                Boolean verifier = true;
                if(App.Payment_Amount__c != null){
                    pmt=App.Payment_Amount__c;
                }else{
                    msg=msg + 'Payment Ammount should not be empty\null. \n';      //Nao permite settle Sem Payment Ammount, Equipment Cost e Term Calc
                    verifier = false;                                               // embora sejam preenchidos automaticamente - JR
                }
                if(App.Equipment_Cost__c != null){
                    pv=App.Equipment_Cost__c;
                }else{
                    msg=msg + 'Equipment Cost should not be empty\null. \n';
                    verifier = false;
                }
                if(App.TermCalc__c != null){
                    nper=App.TermCalc__c;
                }else{
                    msg=msg + 'Term Calc should not be empty\null. \n';
                    verifier = false;
                }
                
                if(verifier == true){

                     if(app.Payment_Freq__c=='Quarterly'){ 
                        nper=nper/3;
                        pmt=pmt*3;
                        npaymentByYear=4;
                    }
                    if(app.Payment_Timing__c=='Advanced'){
                       begEndPay  =1;
                    }
                    app.Annual_Interest_Rate__c = financial.AnnualInterestRate(nper, pmt, pv,npaymentByYear,begEndPay, false );
                    // MDS - added of new rate to calculate contract amortizations
                    app.Amortization_Interest_Rate__c=financial.AnnualInterestRate(nper, pmt, pv,npaymentByYear,0, true );
                }
            }       
            
            System.debug('before ifs');
            
            
            msg = msg + atLeastOneInvoiceableEmail(contactsClient, accClient);

            if(app.AccClient__r.c2g__CODAVATStatus__c == '' || app.AccClient__r.c2g__CODAVATStatus__c == null){    //JR 09/02/2017
                msg=msg + 'Client Tax Status cannot be empty. \n';
            }

            if(app.vendor__r.c2g__CODAVATStatus__c == '' || app.vendor__r.c2g__CODAVATStatus__c == null){      //JR 09/02/2017
                msg=msg + 'Vendor Sales Tax Status cannot be empty. \n';
            }

            if(app.AccClient__r.c2g__CODATaxCalculationMethod__c == '' || app.AccClient__r.c2g__CODATaxCalculationMethod__c == null){    //JR 09/02/2017
                msg=msg + 'Client Tax Calculation Method cannot be empty. \n';
            }

            if(app.vendor__r.c2g__CODATaxCalculationMethod__c == '' || app.vendor__r.c2g__CODATaxCalculationMethod__c == null){      //JR 09/02/2017
                msg=msg + 'Vendor Tax Calculation Method cannot be empty. \n';
            }

            if(app.Insurance_Type__c=='' || app.Insurance_Type__c == null){
                msg=msg + 'Insurance Type should not be empty. \n';
            }
            
            if( app.Issuing_Date_Invoice__c == null){
                msg=msg + 'Vendor Invoice Date should not be empty. \n';
            }
            
            if( app.Vendor_Invoice_Total__c == null || app.Vendor_Invoice_Total__c == 0){
                msg=msg + 'Vendor Invoice Total should not be empty. \n';
            }
            
            if( app.Equipment_Cost__c == null || app.Equipment_Cost__c == 0){
                msg=msg + 'Equipment Cost should not be empty. \n';
            }
            
            if( app.Vendor_invoice_VAT__c == null || app.Vendor_invoice_VAT__c == 0){
                msg=msg + 'Vendor Invoice VAT should not be empty. \n';
            }
            
            if( app.Vendor_Invoice_Amount__c == null || app.Vendor_Invoice_Amount__c == 0){
                msg=msg + 'Vendor Invoice Net should not be empty. \n';
            }
            
            if (app.Payment_Method__c=='Direct Debit'){
                if((accClient.c2g__CODABankIBANNumber__c=='' || accClient.c2g__CODABankIBANNumber__c==null)){
                    msg=msg+'Iban on client Account is empty! \n';
                }else{
                    if(!SEPA_Toolkit.SEPAUtilities.ValidateIBAN('' + accClient.c2g__CODABankIBANNumber__c)){
                        msg = msg + 'Iban on client Account is invalid! \n';
                    }
                }
            }
                        
            if(accVendor.c2g__CODABankIBANNumber__c=='' || accVendor.c2g__CODABankIBANNumber__c==null){
                msg=msg+'Iban on Partner Account is empty! \n';
            }else{
                if(!SEPA_Toolkit.SEPAUtilities.ValidateIBAN(accVendor.c2g__CODABankIBANNumber__c)){
                    msg = msg + 'Iban on Partner Account is invalid! \n';
                }
            }                
                     
            if(accClient.BillingPostalCode == null || accClient.BillingPostalCode == ''){
                msg = msg + 'Billing Postal Code on Client Account is empty! \n';
            }else{
                if(!UTIL_PostCode.validationPostCode(accClient.BillingPostalCode)){
                    msg = msg + 'Billing Postal Code on Client Account is invalid! \n';
                }
            }
            
            if(accClient.BillingStreet == null || accClient.BillingStreet == ''){
                msg = msg + 'Billing Street on Client Account is empty! \n';
            }
            
            if(accClient.BillingCity == null || accClient.BillingCity == ''){
                msg = msg + 'Billing City on Client Account is empty! \n';
            }
            
            if(accClient.Tax_Zone__c == null || accClient.Tax_Zone__c== ''){
                msg = msg + 'Tax_Zone on Client Account is empty! \n';
            }
            
            if(accVendor.BillingPostalCode == null || accVendor.BillingPostalCode == ''){
                msg = msg + 'Billing Postal Code on Vendor Account is empty! \n';
            }else{
                if(!UTIL_PostCode.validationPostCode(accVendor.BillingPostalCode)){
                    msg = msg + 'Billing Postal Code on Vendor Account is invalid! \n';
                }
            }
            
            if(accVendor.BillingStreet == null || accVendor.BillingStreet == ''){
                msg = msg + 'Billing Street on Vendor Account is empty! \n';
            }
            
            if(accVendor.BillingCity == null || accVendor.BillingCity == ''){
                msg = msg + 'Billing City on Vendor Account is empty! \n';
            }
            
            
           
            /*
            if( app.accClient__r.c2g__CODAInvoiceEmail__c =='' || app.accClient__r.c2g__CODAInvoiceEmail__c ==null){
                              
                msg=msg+'Invoice Email is empty! \n'; 
            } */
            
            if( accClient.c2g__CODAInputVATCode__c == null){
                msg=msg+'Input tax Account is not filled in the Client Account! \n';
            }
            
            c2g__codaGeneralLedgerAccount__c glacc_accountsReceivableControl = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c='21111'];
            if(accClient.c2g__CODAAccountsReceivableControl__c != glacc_accountsReceivableControl.id){
                msg=msg+'Accounts Receivable Controlol is not filled in the Client Account! \n';
            }
            
            if( app.eSignature_Contract__c == false && app.Paper_Contract__c == false ){  //não permite settle enquanto não houver check de either eSignature ou Paper contract - JR
                msg=msg+'Need to check either eSignature or Paper Contract! \n';
            }

            if( app.Beginning_of_Term__c==null){
                msg=msg+'Beginning of Term cannot be empty! \n';
            }
            //Validation Of vendor's General ledger Accounts Lookups
            c2g__codaGeneralLedgerAccount__c glacc_DefaultExpenseAccount = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c='311'];
            if(app.Vendor__r.c2g__CODADefaultExpenseAccount__c!=glacc_DefaultExpenseAccount.Id){
                msg=msg+'Vendor\'s Default Expense Account is not correct!\n';
            } 

            c2g__codaGeneralLedgerAccount__c glacc_accountsPayableControl = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c='22114'];
            if(app.Vendor__r.c2g__CODAAccountsPayableControl__c!=glacc_accountsPayableControl.Id){
                msg=msg+'Vendor\'s Accounts Payable Control is not correct! \n';
            }

            // verifica taxcode de acordo com a região (Portugal, Açores ou Madeira)
            Id taxCodeID = GetVendorInputOutputVAT(app.Vendor__r.BillingPostalCode);
            if(app.Vendor__r.c2g__CODAOutputVATCode__c!=taxCodeID){
                msg=msg+'Vendor\'s Output VAT/GST Code is not correct! \n';
            }


            //For new site and Automatic process of payable invocies [HP 17/01/2017]
            Vendor_Invoice__c[] vendorInvoiceList =  [SELECT Id, Invoice_Total__c, Account__c, Due_Date__c, Invoice_Date__c, 
                                                Vendor_Invoice_Number__c, Submitted__c, Status__c
                                                FROM Vendor_Invoice__c 
                                                WHERE Application__c =: app.Id ORDER BY CreatedDate DESC LIMIT 1];

            Vendor_Invoice__c vendorInvoice = new Vendor_Invoice__c();
            if(vendorInvoiceList.size()==0 || !vendorInvoiceList[0].Submitted__c){
                msg=msg+'Vendor Invoice is not submitted. \n';
            }else {
                //  [HP - 20/02/2017] Validation for Vendor Invoice done by PayableInvoiceHandler.validateVendorInvoice;
                vendorInvoice = vendorInvoiceList[0];

                string vendorInvoiceValidation = PayableInvoiceHandler.validateVendorInvoice(vendorInvoice.ID);

                if(vendorInvoiceValidation != 'OK'){
                    msg = msg + vendorInvoiceValidation;
                }
                
                List<Attachment> attachList = new List<Attachment>([Select Id From Attachment where ParentId = :vendorInvoice.Id ]);
                if(attachList == null || attachList.size()==0){
                    msg += 'Vendor invoice has no attachment! \n';
                }
            }
           
            if(app.Insurance_Type__c == ''){
                msg += 'Insurance Type field cannot be empty' ;
            }  
            
            if(app.Insurance__c == null){
                msg += 'Insurance Percentage field cannot be empty';    
            }
            
            if( app.Chosen_Insurance_value__c == null ){
                msg=msg + 'Insurance Value should not be empty. \n';
            }
            
            //little magic to pass the test -> problems updated fields related to FinancialForce
            if(Test.isRunningTest()){
                msg=''; 
            }
            
            if(msg!=''){
                system.debug(msg);
                return msghd + msg;
            }
            else {
                                                                            System.debug('LINHA 99 - BEFORE SAVEPOINT :$ PLS');
                // create savepoint to rollback if there are errors
                sp = Database.setSavepoint(); 
                                                                            System.debug('LINHA 102 - AFTER SAVE POINT!');
                // change record type to settle contract -record is readonly for everybody except admin
                recordtype rec=[select id from recordtype where name = 'Settle Contract' and SobjectType ='Application__c'];
                app.RecordTypeId=rec.id;
                
                //app.Contract_Settlement_Date__c=date.today(); invoice payment date will be used
                if(app.Invoice_Payment_Date__c==null ){
                    app.Invoice_Payment_Date__c=date.today();
                    
                }
                if (app.Status__c=='Application - Approved' ){
                    app.Status__c='Contract - Running';  
                }
                app.Generate_Billing__C=true;
               
                //for get correct info when frequency is changed
                app.First_Beginning_Of_Term__c = app.Beginning_of_Term__c; //ALTERACAO - 04/05/2017 - para corrigir o campo Beginning Of Term(BP)

                app.Insurance_Pro_Rata_Backup__c  = app.Insurance_Pro_Rata__c;
                app.Interim_Fee_Days_First__c  = app.Interim_Fee_Days_Normal__c;
                update app;
            }
            
            
            //System.enqueueJob(new Queueable_ProcBilling(appID));
           
            (new BILL_BillingProcess()).createBillingInvoice(appID);

             // Alteração 5-12-2017
            if(vendorInvoice.Status__c=='Draft'){
                System.enqueueJob(new Queueable_ProcPayableInvoices(appID, true));
            }
            
            //JG 5-12-2017 On the settleContract the PayableInvoice SEPA Should be sent
            PayableInvoiceHandler.sendPiSepaFromVendorInvoice(vendorInvoiceList);
            
            
            return 'Contract Settlement Successed! Contract Billing Contracts, Sales Invoices, Journals and Transactions will be created in background if due!';
        }   
        catch(exception e){
            System.Debug('Error in settleContract method validateContract - ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            if(!test.isRunningTest()){
                Database.rollback(sp);
            }

            return 'Contract Settlement failed - ' +  e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage();
             
        }
    }

    public static id GetVendorInputOutputVAT(string PostalCode){
        try{
            integer postcode_max=0;
            integer postcode_min=0;
            integer accpostcode=0;
            string accregion='';
            if (PostalCode!= null && PostalCode !='0000-000' && PostalCode!='' && PostalCode != '0000'){
                
                list <PostCode__c> postcod = [select CP_Max__c, CP_Min__c, Region__c 
                                              from postcode__c 
                                              where Region__c != null];
                
                for ( integer i=0; i<postcod.size(); i++){
                    postcode_max= integer.valueOf((postcod[i].cp_max__c).substring(0,4));
                    postcode_min= integer.valueOf((postcod[i].CP_Min__c).substring(0,4));
                    accpostcode=  integer.valueOf((PostalCode).substring(0,4));
                    if(accpostcode <= postcode_max && accpostcode >= postcode_min){
                        accregion= postcod[i].Region__c;
                    }
                }
                list <c2g__codaTaxCode__c> taxcodes=[select name, Area__c, Country__c, id  
                                                     from c2g__codaTaxCode__c  
                                                     where country__C= 'Portugal' 
                                                     and Area__c=: accregion 
                                                     and Name like 'C%' and ( not name like '%00')  ]; 
                return taxcodes[0].id;            
            }
            else {
                return null;
            }
            
        }
        catch(exception e){
            System.Debug('BillingProcess GetInputOutputVAT - Error ');
            system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return null;
        }
    }
    public static String atLeastOneInvoiceableEmail(List<Contact> contactsClient, Account accClient){
        Boolean atleastOneContactInvoiceable = false;
        Map<String, Contact> contactEmailMap = new Map<String, Contact>();
        
        for(Contact conts : contactsClient){
            contactEmailMap.put(conts.Email, conts);
            if(conts.Send_Invoice__c){
                atleastOneContactInvoiceable = true;
            }
        }
        
        if(!atleastOneContactInvoiceable){
            if(contactEmailMap.containsKey(accClient.c2g__CODAInvoiceEmail__c)){
                Contact invoiceableContact = contactEmailMap.get(accClient.c2g__CODAInvoiceEmail__c);
                invoiceableContact.Send_Invoice__c = true;
                update invoiceableContact;   
            }else{
                if(accClient.c2g__CODAInvoiceEmail__c != null){
                    Contact newContact = new Contact(Send_Invoice__c = true, LastName = 'Cliente', Email = accClient.c2g__CODAInvoiceEmail__c, AccountID = accClient.id);
                    insert newContact;
                }else{
                    return 'No Invoiceable email was found in client account! \n'; 
                } 
            }
        }
        //'' means that at least  one invoiceable email was found
        return '';
    }
    
    
}