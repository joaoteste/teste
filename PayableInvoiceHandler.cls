global class PayableInvoiceHandler implements Database.Batchable<sObject> {
    
    private String query;
    
    private string mailToSendAfterBulk ='';
    private boolean bulkPost = false;
    
    private List<c2g__codaPurchaseInvoice__c> bulkList = new List<c2g__codaPurchaseInvoice__c>();
   
    global PayableInvoiceHandler(){}
    
    global PayableInvoiceHandler(String query_to_Vendor_Invoices){
        this.query = query_to_Vendor_Invoices;
    }

    global PayableInvoiceHandler(String query_to_Vendor_Invoices, boolean bulkPost){
        this.query = query_to_Vendor_Invoices;
        this.bulkPost = bulkPost;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('PayableInvoiceHandler  - Start batch to Create and Post Payable Invoices:  ' + query);
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<Vendor_Invoice__c> VendorInvoiceList){
        createPayableInvoiceFromVendorInvoice(VendorInvoiceList);
        
    }

    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        
        Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'Completed', 'BATCH_PAYABLE_INVOICE', 'JobId: ' + a.Id + ' || Number of errors: ' + a.NumberOfErrors +  ' || Total Job items: ' + a.TotalJobItems + '|| Job Items Processed: ' + a.JobItemsProcessed,'');
        
        if(a.NumberOfErrors > 0 && ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox){
            String[] toAddresses = new List<String>();  toAddresses.add('sf.candor@worldit.pt');  toAddresses.add('info@candor.pt'); toAddresses.add(a.CreatedBy.Email);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('There was a problem creating Payable Invoices');  email.setToAddresses(toAddresses);
            email.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }

        if(bulkPost){
            //prepare the vendor invoices that have conflicting names with the payable invoices created
            System.debug('Bulking vendor Invoice');

            List<c2g.CODAAPICommon.Reference> codareference = new List<c2g.CODAAPICommon.Reference>();
            for(c2g__codaPurchaseInvoice__c payableInvoice: bulkList){
                c2g.CODAAPICommon.Reference refPayableInvoice = new c2g.CODAAPICommon.Reference();
                refPayableInvoice.Id = payableInvoice.Id;  
                codareference.add(refPayableInvoice);    
            }

            c2g.CODAAPICommon_9_0.Context context = new c2g.CODAAPICommon_9_0.Context();
            c2g.CODAAPIPurchaseInvoice_9_0.BulkPostPurchaseInvoice(context,codareference);
        }
        System.debug('PayableInvoiceHandler  - batch to Create and Post Payable Invoices Finished - jobId: ' + a.Id);
     
    }

    public List<c2g__codaPurchaseInvoice__c> createPayableInvoiceFromVendorInvoice (List<Vendor_Invoice__c> VendorInvoiceList){
        List<Attachment> invoiceAttchList = new List<Attachment>();
        List<c2g__codaPurchaseInvoice__c> PayableInvoicesNoVendorInvoiceList = new List<c2g__codaPurchaseInvoice__c>();

        //gets the possible Pins to add, the others are sent as email with an error that they should be created manually
        // this function checks for already in use c2g__AccountInvoiceNumber__c.
        PayableInvoicesNoVendorInvoiceList = getNonRepeatedNumberPurchaseInvoice(VendorInvoiceList);
        insert PayableInvoicesNoVendorInvoiceList;
        
        List<c2g__codaPurchaseInvoiceExpenseLineItem__c> payableLineItemsList = new List<c2g__codaPurchaseInvoiceExpenseLineItem__c>();
        

        //Map with payable invoice map to Vendor Invoice ID
        Map<String, c2g__codaPurchaseInvoice__c> payableInvoiceMap = new Map<String, c2g__codaPurchaseInvoice__c>();
        for(c2g__codaPurchaseInvoice__c payableInvoice : PayableInvoicesNoVendorInvoiceList){
            payableInvoiceMap.put(payableInvoice.Vendor_invoice__c, payableInvoice);
            Attachment attach = copyAttachment(payableInvoice.Vendor_invoice__c, payableInvoice.Id);
            if(attach!=null){
                invoiceAttchList.add(attach);
            }
        }
        
        c2g__codaPurchaseInvoice__c pi = new c2g__codaPurchaseInvoice__c();
        for(Vendor_invoice__c vi : VendorInvoiceList){
            pi = payableInvoiceMap.get(vi.Id);
            if(pi!=null && vi.Id == pi.Vendor_invoice__c){
                System.debug('Payable invoice Id: ' + pi.Id);
                c2g__codaPurchaseInvoiceExpenseLineItem__c payableLineItems = addLiniItemsToPayableInvoice(vi, pi.Id);
                payableLineItemsList.add(payableLineItems);
                vi.Status__c = 'Completed';
            }
        }
       
        bulkList.addAll(PayableInvoicesNoVendorInvoiceList);      
        
        update VendorInvoiceList;
        insert payableLineItemsList;
        insert invoiceAttchList;
        return PayableInvoicesNoVendorInvoiceList; 
    }
    
    @TestVisible
    private List<c2g__codaPurchaseInvoice__c> getPayableInvoiceFromVendorInvoice(List<Vendor_invoice__c> VendorInvoiceList){
        
        List<c2g__codaPurchaseInvoice__c> PayableInvoicesList = new List<c2g__codaPurchaseInvoice__c>();
        
        for(Vendor_invoice__c vendorInvoice : VendorInvoiceList){  
            if(vendorInvoice.Status__c == 'Draft'){
                
                c2g__codaPurchaseInvoice__c payableInvoice = new c2g__codaPurchaseInvoice__c();
                payableInvoice.c2g__Account__c = vendorInvoice.Account__c;
                //HP - 16/03/2017 - vendorInvoice.Due_Date__c foi removida e substituida pela data de settle; 
                //Caso exista a data Invoice_Payment_Date__c (contract Settlment date) coloca essa como due date
                //caso não exista coloca o dia de hoje.
                //PC - 15/11/2017  Alterada para permitir PIN a partir de VINV relacionadas com SFE. É portanto feita a verificação consoante o 
                if(vendorInvoice.Account__r.Type == 'Service Provider'){
                    if(vendorInvoice.Due_Date__c == null){
                        payableInvoice.c2g__DueDate__c = vendorInvoice.Invoice_Date__c;
                    }else{
                        payableInvoice.c2g__DueDate__c = vendorInvoice.Due_Date__c;
                    }
                }else{
                    if(vendorInvoice.Application__r.Invoice_Payment_Date__c == null){ 
                        payableInvoice.c2g__DueDate__c = system.today();
                    }else{
                        payableInvoice.c2g__DueDate__c = vendorInvoice.Application__r.Invoice_Payment_Date__c;
                    }
                }
                
                payableInvoice.c2g__InvoiceDate__c = vendorInvoice.Invoice_Date__c;
                payableInvoice.c2g__RegisteredDate__c = vendorInvoice.Submitted_Date__c;
                payableInvoice.c2g__AccountInvoiceNumber__c = vendorInvoice.Vendor_Invoice_Number__c;
                payableInvoice.c2g__InvoiceDescription__c = '';
                if(vendorInvoice.Application__r.Name != null && vendorInvoice.Application__r.Name != '' ){
                    payableInvoice.c2g__InvoiceDescription__c = vendorInvoice.Application__r.Name + '; ';
                }
                payableInvoice.c2g__InvoiceDescription__c += vendorInvoice.Name;
                payableInvoice.Vendor_Invoice__c = vendorInvoice.id; 
                
                PayableInvoicesList.add(payableInvoice);
            } 
        }
        
        return PayableInvoicesList;
    } 
    
    @TestVisible
    private c2g__codaPurchaseInvoiceExpenseLineItem__c addLiniItemsToPayableInvoice(Vendor_Invoice__c vendorInvoice, String payableInvoiceId){
        c2g__codaPurchaseInvoiceExpenseLineItem__c expenseLineItems_PayableControl = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
        expenseLineItems_PayableControl.c2g__GeneralLedgerAccount__c = vendorInvoice.Account__r.c2g__CODADefaultExpenseAccount__c;
        expenseLineItems_PayableControl.c2g__NetValue__c = vendorInvoice.Invoice_Net__c;
        expenseLineItems_PayableControl.c2g__InputVATCode__c    = vendorInvoice.Tax_Code__c; 
        expenseLineItems_PayableControl.c2g__PurchaseInvoice__c = payableInvoiceId;   
        
        return expenseLineItems_PayableControl;
    }
    
    @TestVisible
    public static Attachment copyAttachment(String OldParentID, String newParentID){
        
        List<Attachment> oldAttch = [SELECT Name, Body 
                                     FROM Attachment 
                                     WHERE ParentID = :oldParentId Order By createddate DESC LIMIT 1];
        Attachment newAttch = new Attachment();
        
        if(oldAttch.size()>0){
            newAttch = new Attachment(Name = oldAttch[0].Name, Body = oldAttch[0].Body);
            newAttch.parentID = newParentId;
        }
        
        return newAttch;
    }
    
    //Used in Vendor Invoice Layout in button "Create And Post Payable Invoice" and "Create Payable Invoice"
    webservice static String CreateAndPostPayableInvoice(String VendorInvoiceID, boolean post){
        
        try{
            String res = validateVendorInvoice(VendorInvoiceID);
            
            if(res=='OK'){
                Vendor_Invoice__c vinv = [SELECT id, application__c FROM Vendor_Invoice__c WHERE Id=:VendorInvoiceID];
                if(vinv.Application__c != null){
                    System.enqueueJob(new Queueable_ProcPayableInvoices(vinv.Application__c, post));
                }else{
                    System.enqueueJob(new Queueable_ProcPayableInvoices(vinv.id, post));
                }
            }
            
            return res;
            
        }catch(Exception e){
            system.Debug('[CreateAndPostPayableInvoice - CreateAndPostPayableInvoice()] ERROR: - ' + e.getMessage() + ' - ' + e.getStackTraceString());
            String res = 'Fail to Create and Post Payable Invoice for Vendor Invoice with ID' + VendorInvoiceID +'.\n Check Outbound Integration Logs with the code PAYABLE_INVOICE.';
            Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'ERRO', 'PAYABLE_INVOICEE', 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString(), VendorInvoiceID);
            return res;
        }
    }
    
    //Used in Vendor Invoice List Layout in button "Create Payable Invoices"
    webservice static String CreatePayableInvocesFromVendorInvoiceList(List<Id> vendorInvoiceIdList){
        
        try{
            
            if(!UserInfo.isCurrentUserLicensed('c2g') && !Test.isRunningTest()){
                String msg =  'The user ' +  UserInfo.getName() + ' don\'t have Financial Force permissions to performe this action.';
                return msg;
            }
            
            String ids = '(';
            for(Id viId : vendorInvoiceIdList){
                ids += '\'' + viId +'\',';
            }
            ids = ids.removeEnd(',');
            ids+=')';
            
            String query = 'SELECT ID, NAME,Invoice_Date__c,Due_Date__c,Invoice_Total__c,Status__c, ';
            query += 'Submitted__c,Submitted_Date__c, Vendor_Invoice_Number__c, Application__c, Account__c, ';
            query += 'Account__r.c2g__CODAAccountsPayableControl__c,Account__r.c2g__CODAOutputVATCode__c, Account__r.Type,';
            query += 'Tax_Code__c, Account__r.Name, Account__r.c2g__CODADefaultExpenseAccount__c, Application__r.Invoice_Payment_Date__c, ';
            query += 'Application__r.Name, Invoice_Net__c ';
            query += 'FROM Vendor_Invoice__c ';
            query += 'WHERE Id IN ' + ids +' AND Submitted__c=true AND Status__c=\'Draft\'';
            
            PayableInvoiceHandler pih = new PayableInvoiceHandler(query);
            Id batchJobId = Database.executeBatch(new PayableInvoiceHandler(query), 5);
            return 'OK';
            
        }catch(Exception e){
            system.Debug('[PayableInvoiceHandler - CreatePayableInvocesFromVendorInvoiceList()] ERROR: - ' + e.getMessage() + ' - ' + e.getStackTraceString());
            Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'ERRO', 'BATCH_PAYABLE_INVOICE', 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString(), '');
            return 'Fail to Create Payable Invoices! \n Check Outbound Integration Logs with the code BATCH_PAYABLE_INVOICE.';
        }
    }
    
    public static String validateVendorInvoice(String VendorInvoiceID){
        
        string msg='';
        String msgh ='\nPlease  correct the following problems: \n\n';
        
        if(!UserInfo.isCurrentUserLicensed('c2g') && !Test.isRunningTest()){
            msg =  'The user ' +  UserInfo.getName() + ' don\'t have Financial Force permissions to performe this action.';
            return msgh + msg;
        }
        
        Set<String> objectFields = Schema.SObjectType.Vendor_Invoice__c.fields.getMap().keySet();
        if(!objectFields.contains('tax_code__c')) {
            msg = 'This user don\'t have acess to Vendor Invoice\'s Tax Code';
            return msgh + msg;   
        }
        
        Vendor_Invoice__c[] vendorInvoiceList = [SELECT Invoice_Total__c, Name, Account__c, Invoice_Date__c, Due_Date__c,
                                                 Vendor_Invoice_Number__c, Submitted__c, application__c, Account__r.c2g__CODADefaultExpenseAccount__c,
                                                 Account__r.c2g__CODADefaultExpenseAccount__r.c2g__TrialBalance2__c,Account__r.c2g__CODAAccountsPayableControl__r.c2g__TrialBalance2__c,
                                                 Account__r.c2g__CODAAccountsPayableControl__c, Account__r.c2g__CODAOutputVATCode__c,
                                                 Account__r.c2g__CODASalesTaxStatus__c, Account__r.c2g__CODAVATStatus__c,
                                                 Account__r.c2g__CODATaxCalculationMethod__c,Account__r.BillingPostalCode,Status__c,Account__r.Type,
                                                 Application__r.Invoice_Payment_Date__c, Application__r.Name, Tax_Code__c
                                                 FROM Vendor_Invoice__c 
                                                 WHERE Id =: VendorInvoiceID];
        
        if(vendorInvoiceList.size()==0 || !vendorInvoiceList[0].Submitted__c){
            msg=msg+'Vendor Invoice is not submitted; \n';
        }else if(vendorInvoiceList[0].Status__c=='Completed'){
            msgh ='';
            msg=msg+'Vendor invoice is Completed.\n';
        }
        else if(vendorInvoiceList[0].Status__c=='Canceled'){
            msgh ='';
            msg=msg+'Vendor invoice is Canceled.\n';                        

        }else {
            
            Vendor_Invoice__c vendorInvoice = vendorInvoiceList[0];  
            Id taxCodeID = SettleContract.GetVendorInputOutputVAT(vendorInvoice.Account__r.BillingPostalCode);
            
            if(vendorInvoice.Vendor_Invoice_Number__c == null){
                msg=msg+'Vendor Invoice has no Number; \n';
            }  
            
            if(vendorInvoice.Account__r.Type  == 'Channel Partner / Vendor'){
                //Validation Of vendor's General ledger Accounts Lookups
                //
                c2g__codaGeneralLedgerAccount__c glacc_DefaultExpenseAccount = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c='311'];
                if(vendorInvoice.Account__r.c2g__CODADefaultExpenseAccount__c!=glacc_DefaultExpenseAccount.Id){
                    msg=msg+'Vendor\'s Default Expense Account is not correct; \n';
                }
                
                c2g__codaGeneralLedgerAccount__c glacc_accountsPayableControl = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c='22114'];
                if(vendorInvoice.Account__r.c2g__CODAAccountsPayableControl__c!=glacc_accountsPayableControl.Id){
                    msg=msg+'Vendor\'s Accounts Payable Control is not correct; \n';
                }
                
                // verifica taxcode de acordo com a região (Portugal, Açores ou Madeira)
                if(vendorInvoice.Account__r.c2g__CODAOutputVATCode__c!=taxCodeID){
                    msg=msg+'Vendor\'s Output VAT/GST Code is not correct; \n';
                }
                
                 if(vendorInvoice.Application__r.Invoice_Payment_Date__c < vendorInvoice.Invoice_Date__c ){
                    msg = msg + 'Invoice Date cannot be older than Contract Settlement Date in ' + vendorInvoice.Application__r.Name +'\n';
                }  
            }
            if(vendorInvoice.Account__r.Type  == 'Service Provider'){
                if(vendorInvoice.Account__r.c2g__CODADefaultExpenseAccount__r.c2g__TrialBalance2__c  != '62 - FORNECIMENTOS E SERVIÇOS EXTERNOS'){
                    msg=msg+'Vendor\'s Default Expense Account is not correct; \n';
                }
                if(vendorInvoice.Account__r.c2g__CODAAccountsPayableControl__r.c2g__TrialBalance2__c != '22 - FORNECEDORES'){
                    msg=msg+'Vendor\'s Accounts Payable Control is not correct; \n';
                }
            }
            
            if(vendorInvoice.Tax_Code__c == null){
                msg=msg+'Vendor Invoice Tax Code cannot be empty; \n';
            }
            
            if(vendorInvoice.Account__r.c2g__CODAVATStatus__c == '' || vendorInvoice.Account__r.c2g__CODAVATStatus__c == null){      //JR 09/02/2017
                msg=msg + 'Vendor Tax Status cannot be empty; \n';
            }
            
            if(vendorInvoice.Account__r.c2g__CODATaxCalculationMethod__c == '' || vendorInvoice.Account__r.c2g__CODATaxCalculationMethod__c == null){      //JR 09/02/2017
                msg=msg + 'Vendor Tax Calculation Method cannot be empty; \n';
            }
            
            if(vendorInvoice.Invoice_Total__c == null){
                msg=msg+'Vendor Invoice Total should not be empty; \n';
            }
            
            if(vendorInvoice.Account__c == null){
                msg=msg+'Vendor Invoice has no vendor account; \n';
            }          
            
            if(vendorInvoice.Invoice_Date__c == null){
                msg=msg+'Vendor Invoice has no Invoice Date; \n';
            } 
            
            if(vendorInvoice.Invoice_Date__c > system.today()){
                msg=msg+'Invoice Date cannot be earlier than today; \n';
            }

        }
               
        if(msg!=''){
            return msgh + msg;
        }else{
            return 'OK';
        }                                
    }
    public static void sendPiSepaFromVendorInvoice(List<Vendor_Invoice__c> vendorInvoiceList){
        List<c2g__codaPurchaseInvoice__c> PayableInvoicesList =[SELECT ID, Send_Sepa__c from c2g__codaPurchaseInvoice__c WHERE Vendor_Invoice__c IN: vendorInvoiceList];
        for(c2g__codaPurchaseInvoice__c PI: PayableInvoicesList){
            PI.Send_Sepa__c = true;
        }
        update PayableInvoicesList;
    }
    

    /*
        This method is used to ensure that it is not tried to create more Payable invoices that have already: c2g__AccountInvoiceNumber__c used
        return a list with non repeating CodaPurchaseInvoice that are possible to add
    */
    private List<c2g__codaPurchaseInvoice__c> getNonRepeatedNumberPurchaseInvoice(List<Vendor_Invoice__c> VendorInvoiceList){
        Map<String, Vendor_Invoice__c> VendorInvoiceMap = new Map<String, Vendor_Invoice__c>();
        Map<String, c2g__codaPurchaseInvoice__c> existingPayableInvoice = new Map<String, c2g__codaPurchaseInvoice__c>();
        List<String> VendorInvoiceNumberList = new List<String>();
        List<c2g__codaPurchaseInvoice__c> PayableInvoicesNoVendorInvoiceList = new List<c2g__codaPurchaseInvoice__c>();
        String body = '';
      
        for(Vendor_Invoice__c vi :VendorInvoiceList){
            VendorInvoiceNumberList.add(vi.Vendor_Invoice_Number__c);
            VendorInvoiceMap.put(vi.Vendor_Invoice_Number__c, vi);
        }

        List<c2g__codaPurchaseInvoice__c> PayableInvoicesExistingList = [SELECT Id, Name, c2g__AccountInvoiceNumber__c, c2g__Account__c
                                                                        FROM c2g__codaPurchaseInvoice__c
                                                                        WHERE c2g__AccountInvoiceNumber__c IN: VendorInvoiceNumberList];
        for(c2g__codaPurchaseInvoice__c pin : PayableInvoicesExistingList){
            existingPayableInvoice.put(pin.c2g__AccountInvoiceNumber__c, pin);
        }

        List<c2g__codaPurchaseInvoice__c> PayableInvoicesList = getPayableInvoiceFromVendorInvoice(VendorInvoiceList);

        for(c2g__codaPurchaseInvoice__c PayableInvoice: PayableInvoicesList){
            if(existingPayableInvoice.containsKey(PayableInvoice.c2g__AccountInvoiceNumber__c)){
                VendorInvoiceMap.get(PayableInvoice.c2g__AccountInvoiceNumber__c);
                body+= VendorInvoiceMap.get(PayableInvoice.c2g__AccountInvoiceNumber__c).ID + ' ---------- '+ PayableInvoice.c2g__AccountInvoiceNumber__c + ' ---------- Account ID:  '+ PayableInvoice.c2g__Account__c+'<br>';
            }else{
                body+= 'Adicionei: ' + VendorInvoiceMap.get(PayableInvoice.c2g__AccountInvoiceNumber__c) +' ---------- <br>';
                PayableInvoicesNoVendorInvoiceList.add(PayableInvoice);
            }
        }
        if(body !=''){
            String msg = 'Não foi possível converter as seguintes Vendor Invoices em Payable Invoices porque já existem Payable Invoices com o mesmo nome: <br><br><br>';
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add('jgomes@candor.pt');
            
            mail.setToAddresses(sendTo);
            mail.setReplyTo('jgomes@candor.pt');
           // mail.setCcAddresses('info@candor.pt');
            mail.setSenderDisplayName('Candor');
            mail.setSubject('Erro na submissão de facturas.');
            mail.setHtmlBody(msg+body);
            mails.add(mail);      
            if(!Test.isRunningTest()){
            	Messaging.sendEmail(mails);        
            }
        }

        return PayableInvoicesNoVendorInvoiceList;

    }
}