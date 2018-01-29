/*ATTENTION ALL THE Asynchronous CALLS MUST BE DONE AFTER ALL REST CALL: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts_wsdl2apex_testing_dml.htm
that is the reason for the update be done in the end of the transation.
*/
// BILL_QE_CreateInvoiceExtApp used in the trigger Create_Interest_trs_viaBilling calls this API
//Tests:BILL_MoloniAPITest, BILL_QE_MoloniUpdateClientTest
public class BILL_MoloniApi{
    private static String DOCUMENT_SET;
    private static String MATURITY_DATE;
    private static String PAYMENT_METHOD_ATM_REFERENCE;
    private static String PAYMENT_METHOD_DIRECT_DEBIT;
    private static String SALES_MAN_DEFAULT;
    
    
    private Boolean accountUpdateFlag = false; 
    private String moloniClientID = null;
    private Boolean invoiceUpdateNOkFlag = false;
    private Boolean invoiceUpdateOkFlag = false;
    private Boolean updateSendEmail = false;
    private String moloniInvoicesID = null;    //invoices values, probably it will be better create a Inner Wrapper class
    private String invoicePDFLink = null;
    private String moloniInvoiceNumber = null; // documentSetName/invoiceNumber 
    private String documentSetName = null;
    private String invoiceNumber = null;


    private Boolean creditNoteUpdateOkFlag = false;
    private String moloniCreditNoteID = null;
    private String creditNotePDFLink = null;
    private String moloniCreditNoteNumber = null;
    
    private String atmEntity= '';
    private String atmReference = '';
    private String atmValue = '';

    private OrgWideEmailAddress[] owea = null;

    private BILL_MoloniAuth moloniAuth;

    public BILL_MoloniApi(){
        BILL_CS_Moloni__c moloniCSValue = BILL_CS_Moloni__c.getValues('1');
        MATURITY_DATE = moloniCSValue.Moloni_Id__c;
        moloniCSValue = BILL_CS_Moloni__c.getValues('2');
        PAYMENT_METHOD_ATM_REFERENCE = moloniCSValue.Moloni_Id__c;
        moloniCSValue = BILL_CS_Moloni__c.getValues('3');
        DOCUMENT_SET = moloniCSValue.Moloni_Id__c;
        moloniCSValue = BILL_CS_Moloni__c.getValues('4');
        PAYMENT_METHOD_DIRECT_DEBIT = moloniCSValue.Moloni_Id__c;
        
        if(!Utilities.runningInASandbox()){  //Production
            SALES_MAN_DEFAULT = '0';
        }else{
            SALES_MAN_DEFAULT = '1400';
        }

        this.moloniAuth = BILL_MoloniAuth.getInstance();
        
        this.owea = [select Id from OrgWideEmailAddress where Address = 'info@candor.pt'];
    }
    
    /***************************************************************************************/
    /*																					   */
 	/*	         						Invoices 			      	      				   */
    /*																					   */
    /***************************************************************************************/        
     
    public String createInvoiceMoloniFinalized(Id invoiceID){
        String msg = null;
        
        c2g__codaInvoice__c invoiceFinancialForce = queryInvoices(invoiceID);
        
        String validationResult = validateInvoices(invoiceFinancialForce);
        if(validationResult != null){
        	return validationResult;
        }
        
        if(invoiceFinancialForce != null){
            if(invoiceFinancialForce.Moloni_Invoices_ID__c == null && invoiceFinancialForce.Invoice_Express_Number_text__c == null){
                System.debug( '[BILL_MoloniAPI] Sending invoice' + invoiceID + 'to Moloni');
                msg = this.createInvoiceInfo(invoiceFinancialForce, queryAccount(invoiceFinancialForce.c2g__Account__c) );
            }
        }
       
        return msg;
    }
    
    //return null if is ok
    private String validateInvoices(c2g__codaInvoice__c invoice){
    	//TODO all other validations must be implemented
        if(invoice.c2g__InvoiceStatus__c != 'Complete'){
        	if (!Test.isRunningTest()) {
        	    return 'Invoice must be in completed status';
        	}else{
        		return null;
        	}
        }
        if(invoice.c2g__dueDate__c < Date.today()){
        	if (!Test.isRunningTest()) {
        		return 'Invoice due date cannot be in the past';
        	}else{
        		return null;
        	}
        }
        return null;
    }

    public String  getInvoiceInfo(Id invoiceID){
        c2g__codaInvoice__c invoiceFinancialForce = queryInvoices(invoiceID);
                    
        system.debug('c2g__codaInvoice__c' + invoiceFinancialForce);
        system.debug('invoiceFinancialForce.c2g__Account__c' + invoiceFinancialForce.c2g__Account__c);
         
        Account accClient = queryAccount(invoiceFinancialForce.c2g__Account__c);
                                  
        String msg = createInvoiceInfo(invoiceFinancialForce, accClient);
        return msg;
    }

    //This method was created because this query is used in more that one place and that way we don't miss any field :-)
    private c2g__codaInvoice__c queryInvoices(Id invoiceID){
        c2g__codaInvoice__c invoice = [select id, Name, Post_SalesInvoice__c, c2g__Transaction__c, Invoice_Express_Number_text__c, Moloni_Invoices_ID__c, c2g__InvoiceTotal__c, c2g__InvoiceStatus__c,
                     Invoice_express_Link__c, Payment_Method__c, c2g__DueDate__c, c2g__Period__c, first_atm__c, first_atm__r.Entity__c, first_atm__r.MB_Reference__c, first_atm__r.Amount__c,
                     //Account
                     c2g__Account__c, c2g__Account__r.name, c2g__Account__r.Moloni_Client_ID__c, c2g__Account__r.c2g__CODAInvoiceEmail__c, c2g__InvoiceDescription__c,
                     //App
                     Application__c, Application__r.Name,
                     Application__r.Obs_Invoice__c, Application__r.Client_Signer_1__r.name, 

                     // (Line items)
                     // (Select   from Line items)
                     
                     (select c2g__Invoice__r.id, c2g__Quantity__c, c2g__UnitPrice__c,  
                                                                  c2g__Product__r.ProductCode, c2g__Product__r.Name, c2g__TaxCode1__r.Name, c2g__Invoice__r.Application__c,
                                                                 c2g__Invoice__r.c2g__DueDate__c, c2g__Invoice__r.c2g__InvoiceDate__c, c2g__Invoice__r.c2g__CustomerReference__c,
                                                                 c2g__Invoice__r.c2g__Account__r.id, c2g__Invoice__r.c2g__Account__r.Name, c2g__Invoice__r.c2g__Account__r.Moloni_Client_ID__c,
                                                                 c2g__TaxCode1__r.Moloni_TAX_ID__c, c2g__Product__r.Moloni_Product_ID__c, Line_Item_Period__c  
                                                            from c2g__InvoiceLineItems__r)
                                                            
                    from c2g__codaInvoice__c where ID=:invoiceID];
                    
        return invoice;
    }

    private String createInvoiceInfo(c2g__codainvoice__c codainvoice, Account acc){
        String moloniClientId;
        String msg;
 
        try{
            if(codainvoice.Moloni_Invoices_ID__c == null){

                if(codainvoice.c2g__Account__r.Moloni_Client_ID__c == null){
                    moloniClientId = newClient(acc);
                    if(moloniClientId != null){
                        msg = newInvoiceSchedule(codainvoice, moloniClientId);
                        System.debug('[BILL_MoloniAPI - CreateInvoiceInfo] - ' + msg);
                    }else{
                        return 'Erro ao criar conta no Moloni para o cliente: ' + codainvoice.c2g__Account__c;
                    }
                    
                }else{
                    msg = newInvoiceSchedule(codainvoice, codainvoice.c2g__Account__r.Moloni_Client_ID__c);
                    System.debug('[BILL_MoloniAPI - CreateInvoiceInfo] - ' + msg);
                }
                        
            }
            else{
                msg='Factura já existe no Moloni!';
                System.debug('[BILL_MoloniAPI - CreateInvoiceInfo] - ' + msg);
                return msg;
            }
            
            //Done in Bill_Moloni_EmailAndPdf_Batch
            /*
            if(moloniInvoiceNumber != null){   
                            
                String filename = 'Fatura ' + codainvoice.name + datetime.now();
                Attachment attach = attachPdfToDocument(this.invoicePDFLink, filename, codainvoice.Id); 
                sendEmailwithInvoice(codainvoice, attach, moloniInvoiceNumber, true);
            }
            */

        }   
        catch(Exception e){
            System.Debug('Error in Moloni integration GetInvoiceInfo !');
            system.Debug('BILL_MoloniAPI.GetInvoiceInfo ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() + e.getStackTraceString());
            //String emailBody = 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage() +' \n Stack trace: ' + e.getStackTraceString();
            //sendExceptionNotificationEmail(emailBody, codainvoice.id);
            
            
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage(),
            																	printStackTrace__c = e.getStackTraceString());
            insert record;
	        system.debug('CRITICAL: '+ record);
        }

        updateClientMoloniID(acc);
        updateInvoice(codainvoice);
        
        //if(codainvoice.Payment_Method__c == 'ATM Reference' && codainvoice.c2g__InvoiceDescription__c!='Assignment Of Contract Costs'){
        //	PaymentCollection_Utils pcUtils = new PaymentCollection_Utils();
        //	pcUtils.createPaymentCollectionWithATM(codainvoice.c2g__InvoiceTotal__c, acc.ID, codainvoice.c2g__Period__c, codainvoice.c2g__DueDate__c, Integer.valueOf(atmReference), codainvoice.ID, codainvoice.Application__c);
        //	
        //}
        
        return msg;
    }

      public String sendEmailwithInvoice(Id invoiceID){
    	
    	c2g__codainvoice__c invoice = queryInvoices(invoiceID);

    	List<Attachment> attachList = [SELECT Id, Name, Body, parentId FROM Attachment WHERE parentId = :invoiceID ORDER BY CreatedDate DESC Limit 1];
    	Bill_Moloni_EmailAndPdf_Batch batch = new Bill_Moloni_EmailAndPdf_Batch();
    	if(attachList.size() == 0){
    		Database.executeBatch(batch);
    		return 'Invoice has no invoices attached';
    	}
    	
        String invoiceNumber = invoice.Invoice_Express_Number_text__c;
        Messaging.SingleEmailMessage email = batch.createEmailWithInvoice(invoice, attachList[0], invoiceNumber);
        if (!Test.isRunningTest()) {
			try{
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}, true);
				invoice.Invoice_Email_Status__c = 'Sent'; 
				update invoice;
			}catch(Exception e){
	            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
	            																	message__c = 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage(),
	            																	printStackTrace__c =  e.getStackTraceString());																
				insert record;    			
			}
        }
    	
    	return 'Email Sent With Sucess';
    }  

    private void updateInvoice(c2g__codainvoice__c codainvoice){
        if(codainvoice == null){
            return;
        }
        
        if(invoiceUpdateNOkFlag == true){
            codainvoice.Moloni_Invoices_ID__c = this.moloniInvoicesID;//moloniInvoicesID;
             
            update codainvoice;
        }
        
        if(invoiceUpdateOkFlag == true){
            codainvoice.Moloni_Invoices_ID__c= this.moloniInvoicesID;
            codainvoice.Invoice_express_Link__c = this.invoicePDFLink;
            codainvoice.Invoice_Express_Number_text__c = this.moloniInvoiceNumber;
            codainvoice.Post_SalesInvoice__c = true;
            codainvoice.Invoice_Email_Status__c = 'To be send'; 
            //if(this.updateSendEmail == true){
            //    codainvoice.Invoice_Email_Status__c = 'Sent'; 
            //}

            update codainvoice;
        }

    }    
    
    private String newInvoiceSchedule(c2g__codainvoice__c codainvoice, String clientId){ 
        Datetime startreq=datetime.now();
	    String valid;
	    String msg;
	    String bodyResponse;
	    ATM_Reference__c atm;
	            
        //Check if the invoice already exist in Moloni
        String your_reference = codainvoice.Application__r.Name + '/' + codainvoice.Name;
        String invoiceExist = getInvoiceMoloniByYourReference(your_reference);
        if(invoiceExist != null){
            system.debug('Invoice already exist in Moloni1');
            //Simulate that it was created now
            invoiceUpdateOkFlag = true;
            valid = '1';
            
            system.debug('codainvoice.Payment_Method__c' + codainvoice.Payment_Method__c);
            system.debug('this.atmReference' + this.atmReference);
            
            //this mean that faild to create the ATM reference at the first time. It shouldn't happen but...
            //if(codainvoice.Payment_Method__c == 'ATM Reference' && this.atmReference == ''){
        	//   generate_mb_reference(this.moloniInvoicesID, String.valueOf(codainvoice.c2g__InvoiceTotal__c) );
            //}

        }else{

	        String endpoint = this.moloniAuth.getEndpoint() + 'invoices/insert/?access_token=' + this.moloniAuth.getAccessToken(); 
	
	        List<c2g__codaInvoiceLineItem__c> invitems = codainvoice.c2g__InvoiceLineItems__r;
	                        
	        system.Debug('invitems' + invitems);
	        system.Debug('app Id: ' + codainvoice.Application__c);
	
	        String invoiceDate = String.valueOf(date.today());  // '2017-06-03'; String.valueOf(invitems[0].c2g__Invoice__r.c2g__InvoiceDate__c); 
	        String expiration_date = String.valueOf(codainvoice.c2g__DueDate__c); // only for tests   //format '2017-01-16';
	        String document_set_id = DOCUMENT_SET; //Ex PT2017
	        String customer_id = clientId;
	        String notes='';
            if(codainvoice.c2g__InvoiceDescription__c != null ){
	        	notes += 'Descrição: ' + codainvoice.c2g__InvoiceDescription__c.left(75)+'\n'; 
            }
            
            if(codainvoice.Application__r.Obs_Invoice__c != null ){
	        	notes += codainvoice.Application__r.Obs_Invoice__c.left(75)+'\n'; 
            }              
	        	
	        String generate_mb_reference = null;
	        if(codainvoice.Payment_Method__c == 'ATM Reference' && !Test.isRunningTest()){ //TODO does not work?? 
	        	//    generate_mb_reference = '1';
	        	// This code must be improved - Reason: Tests
	        	Bill_EasyPayAPI billEasypay = new Bill_EasyPayAPI(); 
	        	atm = billEasypay.getNewMBReference(String.valueOf(codaInvoice.c2g__InvoiceTotal__c), codaInvoice.c2g__DueDate__c.addDays(3), codaInvoice.ID, codaInvoice.Name);
	        	atmEntity = String.valueOf(atm.Entity__c);
	        	atmReference = atm.ATM_Reference__c;
	        	atmValue = String.valueOf(codaInvoice.c2g__InvoiceTotal__c);
	        	notes += 'Selecione a opção de "Pagamentos de Serviços/Compras" e introduza os seguintes dados: \nEntidade: '+atmEntity+'\nReferência: '+ atmReference + '\nValor: '+atmValue+' €';
	        }
	        
	        String status = '1';  // 1 == finalize
	    
	        String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
	        body += 'date=' + EncodingUtil.urlEncode(invoiceDate ,'UTF-8') + '&';
	        body += 'expiration_date=' + EncodingUtil.urlEncode(expiration_date ,'UTF-8') + '&';
	        body += 'document_set_id=' + EncodingUtil.urlEncode(document_set_id,'UTF-8') + '&';
	        body += 'customer_id=' + EncodingUtil.urlEncode(customer_id ,'UTF-8')+ '&';
	        body += 'your_reference=' + EncodingUtil.urlEncode(your_reference ,'UTF-8')+ '&';
	        if(notes != null){
	            body += 'notes=' + EncodingUtil.urlEncode(notes ,'UTF-8')+ '&';
	        }
	        //if(generate_mb_reference != null){
	        //    body += 'generate_mb_reference=' + EncodingUtil.urlEncode(generate_mb_reference ,'UTF-8') + '&';
	        //}
	        body += 'status=' + EncodingUtil.urlEncode(status ,'UTF-8') + '&';
	
	        //products array
	        String productArray = '';
	        for (integer i=0; i < invitems.size(); i++ ){
	            String product_id = String.valueOf(invitems[i].c2g__Product__r.Moloni_Product_ID__c);
	            String name;
	            if(invitems[i].Line_Item_Period__c != null)
	            	name = invitems[i].c2g__Product__r.Name+ '  ' + invitems[i].Line_Item_Period__c;
				else	            	
					name = invitems[i].c2g__Product__r.Name;
					
	            String qty = String.valueof(invitems[i].c2g__Quantity__c);
	            String price = String.valueof(invitems[i].c2g__UnitPrice__c);
	                
	            productArray += EncodingUtil.urlEncode('products['+i+'][product_id]','UTF-8') + '=' + EncodingUtil.urlEncode(product_id, 'UTF-8') + '&';
	            productArray += EncodingUtil.urlEncode('products['+i+'][name]','UTF-8') + '=' + EncodingUtil.urlEncode(name, 'UTF-8') + '&';
	            productArray += EncodingUtil.urlEncode('products['+i+'][qty]','UTF-8') + '=' + EncodingUtil.urlEncode(qty, 'UTF-8') + '&';
	            productArray += EncodingUtil.urlEncode('products['+i+'][price]','UTF-8') +'=' + EncodingUtil.urlEncode(price, 'UTF-8') + '&';
	
	                //taxes array
	            //for(){      // for now we only use one taxe per product
	                String tax_id = invitems[i].c2g__TaxCode1__r.Moloni_TAX_ID__c;
	                String taxesArray = EncodingUtil.urlEncode('products['+i+'][taxes][0][tax_id]','UTF-8') +' =' + EncodingUtil.urlEncode(tax_id, 'UTF-8') + '&';
	            //}
	
	            productArray += taxesArray;
	        }  
	            
	        body += productArray;
				            
	        HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);
	                       
	        system.debug(body);
	        System.debug('response.getBody():' + response.getBody());
	        bodyResponse = response.getBody();
	            
	        //Parse Result
	        JSONParser parser = JSON.createParser(response.getBody());
	        while (parser.nextToken() != null) {
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'valid')) {
	                // Get the value.
	                parser.nextToken();
	                valid = parser.getText();
	            }
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'document_id')) {
	                // Get the value.
	                parser.nextToken();
	                this.moloniInvoicesID = parser.getText();
	            }
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'document_set_name')) {
	                // Get the value.
	                parser.nextToken();
	                this.documentSetName = parser.getText();
	            }
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'number')) {
	                // Get the value.
	                parser.nextToken();
	                this.invoiceNumber = parser.getText();
	            }/*
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'mb_reference')){
	                parser.nextToken();
	                system.debug(parser.getText());
	                system.debug(parser.getCurrentToken());
	                while (parser.nextToken() != null) {
	                   system.debug(parser.getText());
	                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'entity')) {
	                       // Get the value.
	                       parser.nextToken();
	                       atmEntity = parser.getText();
	                   }
	                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'reference')) {
	                       // Get the value.
	                       parser.nextToken();
	                       atmReference = parser.getText();
	                   }
	                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'value')) {
	                       // Get the value.
	                       parser.nextToken();
	                       atmValue = parser.getText();
	                   }                    
	            	}     
	    		}*/     
	        }
        }
         
        System.debug('valid: ' + valid);
        System.debug('moloniInvoicesID: ' + this.moloniInvoicesID);
        System.debug('entity: '+ this.atmEntity);
        System.debug('reference: '+ this.atmReference);
        System.debug('value: '+ this.atmValue);
        
            
        if(this.moloniInvoicesID == null){
            return 'Moloni not identified';
        }
            
        if(valid == '0' || valid == null){ //NOK
            invoiceUpdateNOkFlag = true;
			
			msg = 'Moloni Erro: '+ bodyResponse;
            
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'error in finalize invoiceId:'+ codainvoice.Id);
            insert record;
            
            
            return msg;
               
        }else{ //Ok
            invoiceUpdateOkFlag = true;
            this.invoicePDFLink = getDocumentPDFLink(this.moloniInvoicesID);
            system.debug('invoicePDFLink: ' + this.invoicePDFLink);
            this.moloniInvoiceNumber = getInvoiceMoloniNumber(this.moloniInvoicesID);
            system.debug('moloniInvoiceNumber: ' + this.moloniInvoiceNumber);
			msg = 'Factura criada no Moloni com sucesso. Verifique no link presente no campo InvoiceXpress Link se está tudo ok.';
            system.debug( msg ); 
            
             
            if(codainvoice.Payment_Method__c == 'ATM Reference' && !Test.isRunningTest() && atm != null){
            	PaymentCollection_Utils pcAPI = new PaymentCollection_Utils();
            	insert atm;
            	pcAPI.createPaymentCollectionWithATM(atm, new c2g__codainvoice__c[]{codaInvoice}); 
            	codainvoice.first_atm__c = atm.ID;
            	update codainvoice;
            }  
        }
           
        return msg;
    }
    
 
    /***************************************************************************************/
    /*																					   */
 	/*	         						Credit Notes		      	      				   */
    /*																					   */
    /***************************************************************************************/    
    
    private void updateCreditNote(c2g__codaCreditNote__c creditNote){
        if(creditNote == null){
            return;
        }
        
        if(creditNoteUpdateOkFlag == true){
            creditNote.Moloni_Credit_Note_ID__c= this.moloniCreditNoteID;
            creditNote.Credit_Note_Link__c = this.creditNotePDFLink;
            creditNote.External_Credit_Note_Number_text__c = this.moloniCreditNoteNumber;
            creditNote.CreditNote_Email_Status__c = 'To be send';

            update creditNote;
        }

    }
    
    private String getCreditNoteMoloniNumber(String moloniCreditNoteId){
         Datetime startreq = datetime.now();
                 
         System.debug('GetCreditNoteMoloniNumber');

         String endpoint = this.moloniAuth.getEndpoint() + 'creditNotes/getOne/?access_token=' + this.moloniAuth.getAccessToken();
         
         String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
         body += 'document_id=' + EncodingUtil.urlEncode(moloniCreditNoteId ,'UTF-8') + '&';

         HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);
         
         String creditNoteNumber ='';
         String documentSetName ='';
         JSONParser parser = JSON.createParser(response.getBody());
         while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'number')) {
               // Get the value.
               parser.nextToken();
               creditNoteNumber = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'document_set_name')) {
               // Get the value.
               parser.nextToken();
               documentSetName = parser.getText();
            }
        }

        String creditNoteIdentifier = documentSetName + '/' + creditNoteNumber;
        System.debug('creditNoteIdentifier:' + creditNoteIdentifier);
        
        return creditNoteIdentifier;
    }    
    
    private String getCreditNoteMoloniByYourReference(String your_reference){
         Datetime startreq = datetime.now();
                 
         System.debug('getCreditNoteMoloniByYourReference');

         String endpoint = this.moloniAuth.getEndpoint() + 'creditNotes/getOne/?access_token=' + this.moloniAuth.getAccessToken();
         
         String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
         body += 'your_reference=' + EncodingUtil.urlEncode(your_reference ,'UTF-8');

         HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);

         String document_id = null;
         JSONParser parser = JSON.createParser(response.getBody());
         while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'document_id')) {
               // Get the value.
               parser.nextToken();
               document_id = parser.getText();
            }
         }

        System.debug('document_id:' + document_id);
        
        return document_id;
    }
    
    
    private String newCreditNote(c2g__codaCreditNote__c creditNote){ 
        Datetime startreq=datetime.now();       
        system.debug('newCreditNote');
        
        try{
            //Check if the credit note already exist in Moloni
            String your_reference = null;
            if(creditNote.c2g__CustomerReference__c != null){
                your_reference = creditNote.c2g__CustomerReference__c + '/' + creditNote.Name;
            }else{
                your_reference = creditNote.Name;
            }
            String creditNoteExist = getCreditNoteMoloniByYourReference(your_reference);
            if(creditNoteExist != null){
                String msg = 'Credit Note already exist in Moloni';
                system.debug(msg);
                return msg;
            }

            List<c2g__codaCreditNoteLineItem__c> credInvoiceItemsList = creditNote.c2g__CreditNoteLineItems__r;
            
            String endpoint = this.moloniAuth.getEndpoint() + 'creditNotes/insert/?access_token=' + this.moloniAuth.getAccessToken(); 

            String creditNoteDate = String.valueof(date.today()); // String.valueOf(creditNote.c2g__CreditNoteDate__c);
            String document_set_id = DOCUMENT_SET;
            String customer_id = creditNote.c2g__Account__r.Moloni_Client_ID__c;
            if(customer_id == null){
                Account accClient = queryAccount(creditNote.c2g__Account__c);
                customer_id = newClient(accClient);
            }
            String status = '1';  // credit Note status, add status = 1 final.
       
            String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
            body += 'date=' + EncodingUtil.urlEncode(creditNoteDate ,'UTF-8') + '&';
            body += 'document_set_id=' + EncodingUtil.urlEncode(document_set_id,'UTF-8') + '&';
            body += 'customer_id=' + EncodingUtil.urlEncode(customer_id ,'UTF-8')+ '&';
            body += 'your_reference=' + EncodingUtil.urlEncode(your_reference ,'UTF-8')+ '&';
            body += 'status=' + EncodingUtil.urlEncode(status ,'UTF-8')+ '&';

            //products array
            String productArray = '';
            for (integer i=0; i < credInvoiceItemsList.size(); i++ ){
                String product_id = String.valueOf(credInvoiceItemsList[i].c2g__Product__r.Moloni_Product_ID__c);
                String name = credInvoiceItemsList[i].c2g__Product__r.Name;
                String qty = String.valueof(credInvoiceItemsList[i].c2g__Quantity__c);
                String price = String.valueof(credInvoiceItemsList[i].c2g__UnitPrice__c);
                
                productArray += EncodingUtil.urlEncode('products['+i+'][product_id]','UTF-8') + '=' + EncodingUtil.urlEncode(product_id, 'UTF-8') + '&';
                productArray += EncodingUtil.urlEncode('products['+i+'][name]','UTF-8') + '=' + EncodingUtil.urlEncode(name, 'UTF-8') + '&';
                productArray += EncodingUtil.urlEncode('products['+i+'][qty]','UTF-8') + '=' + EncodingUtil.urlEncode(qty, 'UTF-8') + '&';
                productArray += EncodingUtil.urlEncode('products['+i+'][price]','UTF-8') +'=' + EncodingUtil.urlEncode(price, 'UTF-8') + '&';

                //taxes array
                //for(){         
                    String tax_id = credInvoiceItemsList[i].c2g__TaxCode1__r.Moloni_TAX_ID__c;
                    String taxesArray = EncodingUtil.urlEncode('products['+i+'][taxes][0][tax_id]','UTF-8') +' =' + EncodingUtil.urlEncode(tax_id, 'UTF-8') + '&';
                //}
                productArray += taxesArray;
            }  
            
            body += productArray;

            HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);
            
            if(response.getStatusCode()!=200){
                System.debug('ERROR in newCreditNote:' + response.getBody());
                System.debug('Http ERROR code: ' + response.getStatusCode());
                return 'Error';
            }  

            //Parse Result
            String valid;
            String creditNoteIdMoloni;
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
               if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'valid')) {
                   // Get the value.
                   parser.nextToken();
                   valid = parser.getText();
               }
               if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'document_id')) {
                   // Get the value.
                   parser.nextToken();
                   creditNoteIdMoloni = parser.getText();
               }
               
            }
                        
            System.debug('valid: ' + valid);
            System.debug('creditNoteIdMoloni: ' + creditNoteIdMoloni);
            
            if(valid == '0'){ //NOK
				Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'error in create Credit Note: ' + creditNote.id);
                insert record;               
                
                return 'Error Moloni: '+response.getBody();
             
            }else{ //Ok
                this.creditNoteUpdateOkFlag = true;
                this.moloniCreditNoteID = creditNoteIdMoloni;
                this.creditNotePDFLink = getDocumentPDFLink(creditNoteIdMoloni);
                String filename = 'Nota Credito ' + creditNote.name + datetime.now();
                system.debug('creditNotePDFLink: ' + this.creditNotePDFLink);
                //Attachment attach = attachPdfToDocument(creditNotePDFLink, filename, creditNote.Id);
                this.moloniCreditNoteNumber = getCreditNoteMoloniNumber(this.moloniCreditNoteID);
                system.debug('moloniCreditNoteNumber: ' + this.moloniCreditNoteNumber);
                system.debug( 'Credit Note criada no Moloni com sucesso. Verifique no link presente no campo Moloni Link se está tudo ok.' );
                //sendEmailWithCreditNote(creditNote, attach, moloniCreditNoteNumber, true);
            }

            updateCreditNote(creditNote);
            return 'CreditNote criada no Moloni com sucesso. Verifique no link presente no campo Moloni Link se está tudo ok.';
        }catch(exception e){
            System.Debug('Error in Moloni integration GetInvoiceInfo !');
            system.Debug('BILL_MoloniAPI.GetInvoiceInfo ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() + e.getStackTraceString());

            updateCreditNote(creditNote);

            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage(),
            																	printStackTrace__c = 'creditNote' + creditNote.id + ':' + e.getStackTraceString());
            																	
			insert record;            																	
            
            return 'Error';
        }
        
        return 'Credit note created without errors';
    }     
       
    private String validateCreditNote(c2g__codaCreditNote__c creditNote){
    	//TODO all other validations must be implemented
        if(creditNote.c2g__CreditNoteStatus__c != 'Complete'){
        	if (!Test.isRunningTest()) {
        	    return 'Credit Note must be in completed status';
        	}else{
        		return null;
        	}
        }

        return null;
    }

    public String createCreditNote(Id creditNoteID){
    
        c2g__codaCreditNote__c creditNote = [SELECT id, Name, c2g__CreditNoteDate__c, Moloni_Credit_Note_ID__c, Credit_Note_Link__c, External_Credit_Note_Number_text__c, CreditNote_Email_Status__c, c2g__CustomerReference__c,
                                             c2g__Invoice__r.Application__r.Client_Signer_1__r.name, c2g__Invoice__r.Invoice_Express_Number_text__c, c2g__CreditNoteStatus__c,
                                             //Account
                                             c2g__Account__c, c2g__Account__r.Moloni_Client_ID__c, c2g__Account__r.Name, c2g__Account__r.c2g__CODAInvoiceEmail__c,
                                             (SELECT id, c2g__Product__r.Moloni_Product_ID__c, c2g__Product__r.Name, c2g__Quantity__c, c2g__UnitPrice__c, c2g__TaxCode1__r.Moloni_TAX_ID__c
                                                  FROM c2g__CreditNoteLineItems__r)
                                             FROM c2g__codaCreditNote__c WHERE ID =:creditNoteId];
                                             
        system.debug('CreditNoteID: ' + creditNoteID);
        
        String validationResult = validateCreditNote(creditNote);
        if(validationResult != null){
        	return validationResult;
        }
        
        String msg = newCreditNote(creditNote);
       
        return msg + 'creditNoteID'  + creditNoteID;
    } 

    /***************************************************************************************/
    /*																					   */
 	/*	         				 		  Clients 		        	      				   */
    /*																					   */
    /***************************************************************************************/      

    private Account queryAccount(Id accountID){
        Account account = [select Id, Name, Country_code__c , c2g__CODAInvoiceEmail__c, BillingCity,  BillingPostalCode,
                                        BillingStreet , Moloni_Client_ID__c, Phone, Fax , Nif__c
                                        //App
                                        
                                   from Account 
                                  where Id=:accountID];
        return account;
    }
    
    private String newClient(Account accClient){
        Datetime startreq=datetime.now();
        System.debug('Create new Client: ');
        
        String endpoint = this.moloniAuth.getEndpoint() + 'customers/insert/?access_token=' + this.moloniAuth.getAccessToken(); 

        if(accClient == null){
            return null;
        }

        // values from Account
        String vat = accClient.Nif__c;
        String name = accClient.Name;
        String contact_email = accClient.c2g__CODAInvoiceEmail__c;
        String city = accClient.BillingCity;
        String zip_code = accClient.BillingPostalCode;
        String address = accClient.BillingStreet;
        String phone = accClient.Phone;
        String fax = accClient.Fax;

        //Static values
        String clientNumber = accClient.ID;     
        String language_id = '1';  //Portuguese
        String country_id = '1';  //  accClient.Country_code__c country_id PT50 = Portugal //Portugal = 1
        String maturity_date_id = MATURITY_DATE;
        String qty_copies_document = '1'; //  1 original 2 duplicado
        String payment_method_id = PAYMENT_METHOD_DIRECT_DEBIT;
        String salesman_id = SALES_MAN_DEFAULT;
        String payment_day = '0';
        String discount = '0';
        String credit_limit = '0';
        String delivery_method_id = '0';

        String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
        body += 'vat=' + EncodingUtil.urlEncode(vat,'UTF-8') + '&';
        body += 'number=' + EncodingUtil.urlEncode(clientNumber ,'UTF-8') + '&';
        body += 'name=' + EncodingUtil.urlEncode(name ,'UTF-8') + '&';
        body += 'language_id=' + EncodingUtil.urlEncode(language_id ,'UTF-8') + '&';
        body += 'address=' + EncodingUtil.urlEncode(address ,'UTF-8') + '&';

            
        if(zip_code != null){
            body += 'zip_code=' + EncodingUtil.urlEncode(zip_code ,'UTF-8') + '&';  //The zip code is checked in Moloni
        }
        body += 'city=' + EncodingUtil.urlEncode(city ,'UTF-8') + '&';
        body += 'country_id=' + EncodingUtil.urlEncode(country_id ,'UTF-8') + '&';
        if(contact_email != null){
            body += 'contact_email=' + EncodingUtil.urlEncode(contact_email ,'UTF-8') + '&';
        }

        if(phone != null){
           body += 'phone=' + EncodingUtil.urlEncode(phone ,'UTF-8') + '&';
        }
        if(fax != null){
           body += 'fax=' + EncodingUtil.urlEncode(fax ,'UTF-8') + '&';
        }
        body += 'maturity_date_id=' + EncodingUtil.urlEncode(maturity_date_id ,'UTF-8') + '&';
        body += 'qty_copies_document=' + EncodingUtil.urlEncode(qty_copies_document ,'UTF-8') + '&';
        body += 'payment_method_id=' + EncodingUtil.urlEncode(payment_method_id ,'UTF-8') + '&';
        
        if(salesman_id != null){
            body += 'salesman_id=' + EncodingUtil.urlEncode(salesman_id ,'UTF-8') +  '&';
        }
        body += 'payment_day=' + EncodingUtil.urlEncode(payment_day ,'UTF-8') +  '&';
        body += 'discount=' + EncodingUtil.urlEncode(discount ,'UTF-8') +  '&';
        body += 'credit_limit=' + EncodingUtil.urlEncode(credit_limit ,'UTF-8') +  '&';
        body += 'delivery_method_id=' + EncodingUtil.urlEncode(delivery_method_id ,'UTF-8') + '&';
    
        HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);
        System.debug('response.getBody()' + response.getBody());

        String valid;
        String clientMoloniId;
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
           if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'valid')) {
               // Get the value.
               parser.nextToken();
               valid = parser.getText();
           }
           if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'customer_id')) {
               // Get the value.
               parser.nextToken();
               clientMoloniId = parser.getText();
           }   
        }
        
        System.debug('valid: ' + valid);
        System.debug('clientMoloniId: ' + clientMoloniId);
            
        if(clientMoloniId == null ){
            // if the client already exist in Moloni update id.
            if(response.getBody().contains('4 vat') ){
                system.debug('Check if the client already exist in Moloni');
                clientMoloniId = getClientMoloniID(vat);
            }
        }
  
        if(clientMoloniId != null){  // if ok
            accountUpdateFlag = true; 
            moloniClientID = clientMoloniId;
        }
       
        return clientMoloniId;
    }    
//*****************************************
//TODO FAZER TESTES
    public String updateClient(Id accountID){
    	
    	Account accClient = queryAccount(accountID);
    	
        Datetime startreq=datetime.now();
        System.debug('Update new Client: ');

        String endpoint = this.moloniAuth.getEndpoint() + 'customers/update/?access_token=' + this.moloniAuth.getAccessToken(); 

        if(accClient == null){
            return null;
        }

        // values from Account
        String name = accClient.Name;
        String customer_id = accClient.Moloni_Client_ID__c;
        String city = accClient.BillingCity;
        String zip_code = accClient.BillingPostalCode;
        String address = accClient.BillingStreet;
        String phone = accClient.Phone;

        String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
        body += 'customer_id=' + EncodingUtil.urlEncode(customer_id ,'UTF-8') + '&';
        body += 'name=' + EncodingUtil.urlEncode(name ,'UTF-8') + '&';
        body += 'address=' + EncodingUtil.urlEncode(address ,'UTF-8') + '&';

            
        if(zip_code != null){
            body += 'zip_code=' + EncodingUtil.urlEncode(zip_code ,'UTF-8') + '&';  //The zip code is checked in Moloni
        }
        body += 'city=' + EncodingUtil.urlEncode(city ,'UTF-8') + '&';

        if(phone != null){
           body += 'phone=' + EncodingUtil.urlEncode(phone ,'UTF-8') + '&';
        }
    
        HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);
        System.debug('response.getBody()' + response.getBody());

        String valid;
        String clientMoloniId;

        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
           if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'valid')) {
               // Get the value.
               parser.nextToken();
               valid = parser.getText();
           }
           if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'customer_id')) {
               // Get the value.
               parser.nextToken();
               clientMoloniId = parser.getText();
           }   
        }
        
        System.debug('valid: ' + valid);
        System.debug('clientMoloniId: ' + clientMoloniId);
            
        if(clientMoloniId == null ){

            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'Problem in update AcountId' + accClient.Id + 'valid: ' + valid + 'clientMoloniId: ' + clientMoloniId);
            insert record;

        }
      
        return clientMoloniId;
    }    
   
    /***************************************************************************************/
    /*																					   */
 	/*	         						UTILS for this class      	      				   */
    /*																					   */
    /***************************************************************************************/         
        
    private void updateClientMoloniID(Account acc){

        // for the case were we can not write in the Account but everything was ok in the creation of the invoice/credit note.
        try{
	        if(accountUpdateFlag == true){
	            acc.Moloni_Client_ID__c = moloniClientID;
	            update acc;
	        }
        }catch(exception e){
            System.Debug('Error in Moloni integration GetInvoiceInfo !');
            system.Debug('BILL_MoloniAPI.GetInvoiceInfo ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() + e.getStackTraceString());
            
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage(),
            																	printStackTrace__c = 'updateClientMoloniID' + acc+ ':' + e.getStackTraceString());
            insert record;
        }
    }
    
    public String getDocumentPDFLink(String document_id){
        try{
            Datetime startreq = datetime.now();

            String endpoint = this.moloniAuth.getEndpoint() + 'documents/getPDFLink/?access_token=' + this.moloniAuth.getAccessToken();

            String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
            body += 'document_id=' + EncodingUtil.urlEncode(document_id ,'UTF-8') + '&';

            HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);

            if(response.getStatusCode()!=200){
                System.debug('ERROR in getDocumentPDFLink:' + response.getBody());
                System.debug('Http ERROR code: ' + response.getStatusCode());
            }
            
            String url;
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
               if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'url')) {
                   // Get the value.
                   parser.nextToken();
                   url = parser.getText();
               }
            }
           
            System.debug('url: '+ url );
            
            return url;
        }catch(exception e){
            String body = 'exception: '+ e.getStackTraceString();
            System.debug(body);
            //sendExceptionNotificationEmail(body, document_id);
            
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage(),
            																	printStackTrace__c = e.getStackTraceString());
            insert record;
            
            return null;
        }

        return null;
    }



    @TestVisible
    private String getClientMoloniID(String vat){
        Datetime startreq=datetime.now();

        String endpoint = this.moloniAuth.getEndpoint() + 'customers/getByVat/?access_token=' + this.moloniAuth.getAccessToken();
        String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
        body+= 'vat=' + EncodingUtil.urlEncode(vat ,'UTF-8') + '&';
       
        HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);

        String moloniClientId = null;
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
           if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'customer_id')) {
               parser.nextToken();
               moloniClientId = parser.getText();
           }
        }

        System.debug('MoloniClientId: '+ moloniClientId );

        return moloniClientId;
    }

    @TestVisible
    private String generate_mb_reference(String document_id, String valueStr){
    	System.debug('generate_mb_reference');
    	
        try{
            Datetime startreq = datetime.now();

            String endpoint = this.moloniAuth.getEndpoint() + 'invoices/generateMBReference/?access_token=' + this.moloniAuth.getAccessToken();

            String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
            body += 'document_id=' + EncodingUtil.urlEncode(document_id ,'UTF-8') + '&';
            body += 'value=' + EncodingUtil.urlEncode(valueStr ,'UTF-8') + '&';

            HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);

            if(response.getStatusCode()!=200){
                System.debug('ERROR in generate_mb_reference:' + response.getBody());
                System.debug('Http ERROR code: ' + response.getStatusCode());
            }
           
            String valid;

            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
               if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'valid')) {
                   // Get the value.
                   parser.nextToken();
                   valid = parser.getText();
               }
               if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'entity')) {
                   // Get the value.
                   parser.nextToken();
                   this.atmEntity = parser.getText();
               }
               if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'reference')) {
                   // Get the value.
                   parser.nextToken();
                   this.atmReference = parser.getText();
               }
               if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'value')) {
                   // Get the value.
                   parser.nextToken();
                   this.atmValue = parser.getText();
               }
            }

            System.debug('valid: '+ valid );
            if(valid == '1'){
            	return valid;
            }else{
                return null;
            }
            return null;
            
        }catch(exception e){
            String body = 'exception: '+ e.getStackTraceString();
            System.debug(body);
            //sendExceptionNotificationEmail(body, document_id);
            
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage(),
            																	printStackTrace__c = e.getStackTraceString());
            insert record;
            
            return null;
        }

        return null;
    }    
    
    private String getInvoiceMoloniNumber(String moloniInvoiceId){
         Datetime startreq = datetime.now();
                 
         System.debug('GetInvoiceMoloniNumber');

         String endpoint = this.moloniAuth.getEndpoint() + 'invoices/getOne/?access_token=' + this.moloniAuth.getAccessToken();
         
         String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
         body += 'document_id=' + EncodingUtil.urlEncode(moloniInvoiceId ,'UTF-8') + '&';

         HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);
         

         JSONParser parser = JSON.createParser(response.getBody());
         while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'number')) {
               // Get the value.
               parser.nextToken();
               this.invoiceNumber = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'document_set_name')) {
               // Get the value.
               parser.nextToken();
               this.documentSetName = parser.getText();
            }
         }
        
        String invoiceIdentifier = this.documentSetName + '/' + this.invoiceNumber;
        System.debug('invoiceIdentifier:' + invoiceIdentifier);
        
        return invoiceIdentifier;
    }

    private String getInvoiceMoloniByYourReference(String your_reference){
         Datetime startreq = datetime.now();
                 
         System.debug('GetInvoiceMoloniByYourReference');

         String endpoint = this.moloniAuth.getEndpoint() + 'invoices/getOne/?access_token=' + this.moloniAuth.getAccessToken();
         
         String body= 'company_id=' + EncodingUtil.urlEncode(this.moloniAuth.getCompanyId() ,'UTF-8') + '&';
         body += 'your_reference=' + EncodingUtil.urlEncode(your_reference ,'UTF-8');

         HTTPResponse response = Rest_Utils.sendPost(endpoint, body, startreq);

         String check_digits = null;
         String sub_entity = null;
         String reference = null;
         JSONParser parser = JSON.createParser(response.getBody());
         while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'document_id')) {
               // Get the value.
               parser.nextToken();
               this.moloniInvoicesID = parser.getText();
            }
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'document_set_name')) {
	                // Get the value.
	                parser.nextToken();
	                this.documentSetName = parser.getText();
	        }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'number')) {
                // Get the value.
                parser.nextToken();
                this.invoiceNumber = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'mb_references')){
                parser.nextToken();
                system.debug(parser.getText());
                system.debug(parser.getCurrentToken());
                while (parser.nextToken() != null) {
                   system.debug(parser.getText());

                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'check_digits')) {
                       // Get the value.
                       parser.nextToken();
                       check_digits = parser.getText();
                   }
                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'entity')) {
                       // Get the value.
                       parser.nextToken();
                       this.atmEntity = parser.getText();
                   }
                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'sub_entity')) {
                       // Get the value.
                       parser.nextToken();
                       sub_entity = parser.getText();
                   }             
                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'reference')) {
                       // Get the value.
                       parser.nextToken();
                       reference = parser.getText();
                   }
                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'value')) {
                       // Get the value.
                       parser.nextToken();
                       this.atmValue = parser.getText();
	               }                   
            	}     
    		}
         }
 
        // "mb_references":[{"check_digits":76,"entity":10611,"sub_entity":500,"reference":99,"creation_date":"2017-06-16T15:26:33+0100","payment_date":null,"value":217.97,"paid":0}
        // reference 500 009 976
         
         if(check_digits != null && sub_entity != null && reference != null){
             this.atmReference = String.valueOf(Integer.valueOf(sub_entity) * 1000000 + Integer.valueOf(reference) * 100 + Integer.valueOf(check_digits)); 
         }

        System.debug('this.moloniInvoicesID:' + this.moloniInvoicesID);
        System.debug('atmReference:' + this.atmReference);
        
        return this.moloniInvoicesID;
    }    

    public String addAttachToInvoice(Id invoiceID){
    	c2g__codainvoice__c invoice = queryInvoices(invoiceID);

        String filename = 'Fatura ' + invoice.name + datetime.now();

        Attachment attach = Bill_Moloni_Util.getPDF(invoice.Invoice_express_Link__c, filename, invoiceID); 

        insert attach;
        
        return ' ';
    }
    
	/*
    private String sendEmailwithInvoice(c2g__codainvoice__c invoice, Attachment attach, String invoiceNumber, Boolean insertAttach){
        system.debug('SendEmailwithInvoice');
     
        EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'Sales_Invoice_Standard' AND Folder.DeveloperName = 'Invoice_Credit_Note_Email_Template'];

        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;

        emailSubject = emailSubject.replace('{!c2g__codaInvoice__c.Invoice_Express_Number_text__c}', invoiceNumber);
        
        emailbody = emailbody.replace('{!c2g__codaInvoice__c.Invoice_Express_Number_text__c}', invoiceNumber);
        htmlBody=htmlBody.replace('{!c2g__codaInvoice__c.Invoice_Express_Number_text__c}', invoiceNumber);
        
        emailbody = emailbody.replace('{!Account.Name}', invoice.c2g__Account__r.name);
        htmlBody=htmlBody.replace('{!Account.Name}', invoice.c2g__Account__r.name);
        
        emailbody = emailbody.replace('{!c2g__codaInvoice__c.Id}', invoice.id);
        htmlBody=htmlBody.replace('{!c2g__codaInvoice__c.Id}', invoice.id);
        
        if(invoice.Application__c == null || invoice.Application__r.Client_Signer_1__r == null){
            emailbody = emailbody.replace('{!Contact.FirstName}', ' ');    
            htmlBody=htmlBody.replace('{!Contact.FirstName}', ' ');

        }else{
            emailbody = emailbody.replace('{!Contact.FirstName}', invoice.Application__r.Client_Signer_1__r.name);    
            htmlBody=htmlBody.replace('{!Contact.FirstName}', invoice.Application__r.Client_Signer_1__r.name);

        }
        htmlBody=htmlBody.replace(']]>', '');
            
        String[] toAddresses = new List<String>();
        if(!Utilities.runningInASandbox()){  //Production
            toAddresses.add(invoice.c2g__Account__r.c2g__CODAInvoiceEmail__c);
        }

        String[] bccAddresses = new List<String>();
        bccAddresses.add('asantos@candor.pt');
        bccAddresses.add('cpedro@candor.pt');
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        email.setBccAddresses(bccAddresses);
        email.setPlainTextBody(emailbody);
        email.setHtmlBody(htmlBody);
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(this.owea.get(0).Id);
        }
       
        if(attach != null && insertAttach == true){
            insert attach;
        }
        String msg = sendEmailWithDocument(email, attach);
        
        return null;
    }*/

	/*
    public String sendEmailWithCreditNote(c2g__codaCreditNote__c creditNote, Attachment attach, String creditNoteNumber, Boolean insertAttach){
        system.debug('SendEmailwithCreditNote');
    
        EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'Sales_Credit_Note_Standard' AND Folder.DeveloperName = 'Invoice_Credit_Note_Email_Template'];

        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;

        emailSubject = emailSubject.replace('{!c2g__codaCreditNote__c.Name}', creditNoteNumber);
        
        if(creditNote.c2g__Invoice__r.Application__r == null || creditNote.c2g__Invoice__r.Application__r.Client_Signer_1__r == null){
            emailbody = emailbody.replace('{!Contact.Name}', ' ');      
            htmlBody=htmlBody.replace('{!Contact.Name}', ' ');
        }else{
            emailbody = emailbody.replace('{!Contact.Name}', creditNote.c2g__Invoice__r.Application__r.Client_Signer_1__r.name);      
            htmlBody=htmlBody.replace('{!Contact.Name}', creditNote.c2g__Invoice__r.Application__r.Client_Signer_1__r.name);
        }
        
        htmlBody=htmlBody.replace('--Invoice Number--', creditNote.c2g__Invoice__r.Invoice_Express_Number_text__c);
        htmlBody=htmlBody.replace(']]>', '');

        String[] toAddresses = new List<String>();
        if(!Utilities.runningInASandbox()){  //Production
            toAddresses.add(creditNote.c2g__Account__r.c2g__CODAInvoiceEmail__c);
        }

        String[] bccAddresses = new List<String>();
        bccAddresses.add('asantos@candor.pt');
        bccAddresses.add('cpedro@candor.pt');
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        email.setBccAddresses(bccAddresses);
        email.setPlainTextBody(emailbody);
        email.setHtmlBody(htmlBody);
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(this.owea.get(0).Id);
        }
        
        if(attach != null && insertAttach == true){
            insert attach;
        }
        String msg = sendEmailWithDocument(email, attach);
        
        return null;
    }*/
	/*
    public String sendEmailWithDocument(Messaging.SingleEmailMessage email, Attachment attach){

       try{
            system.debug('sendEmailWithDocument');

            //add attachments to email
            if(attach != null){

                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                // Add to attachment file list
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(attach.Name);
                efa.setBody(attach.Body);
                fileAttachments.add(efa);
                email.setFileAttachments(fileAttachments);
            }

            if (!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                system.debug('Email sent');
                //flag if email was sent
                this.updateSendEmail = true;
             }
            return 'OK';
        } catch(exception e){
            System.Debug('Error *** Moloni sendEmailWithDocument!');
            system.Debug('[BILL_MoloniAPI - sendEmailWithDocument] ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            //String emailBodyExc = 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage() +' \n Stack trace: ' + e.getStackTraceString();
            //sendExceptionNotificationEmail(emailBodyExc, 'email');
            
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage(),
            																	printStackTrace__c =  e.getStackTraceString());
            																	
			insert record;              
            
            system.debug(e.getStackTraceString());
            return '[BILL_MoloniAPI - sendEmailWithDocument] ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage();
        }

    }*/
	/*
    public static void sendExceptionNotificationEmail(String body, String identifier){
        try{
            string AppName;
            string invoiceID;

            String[] toAddresses = new List<String>();
            toAddresses.add('asantos@candor.pt'); //TODO toAddresses.add('info@candor.pt');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Error in the communication with Moloni identifier: ' + identifier);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody(body);
            if (!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }catch(exception e){
            System.debug('exception: '+ e.getStackTraceString());
            return;
        }
    }

    private HTTPResponse sendPost(String endpoint, String body, Datetime startreq){
        System.debug('Sent Rest Post Body' + body);

        system.debug(body);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        System.debug('req.getEndpoint: '+ req.getEndpoint());
        System.debug('req.getBody: '+ req.getBody());

        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('Response Rest Post Body' + res.getBody());
        
        if(res.getStatusCode()!=200){
            System.debug('res.getBody():' + res.getBody());
            System.debug('Http ERROR code: ' + res.getStatusCode());
        
            String request='--Moloni--\nEndPoint: '+ req.getEndpoint() + '\nMethodType: '+req.getMethod() + '\nHeader: '+ req.getHeader('Content-Type')+ 'Body: '+ req.getBody();
            //String emailBody = 'Problem occurred creating client due to ' + res.getBody();

            //sendExceptionNotificationEmail(emailBody, 'email');
            
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c =  'Problem occurred creating client due to ' + res.getBody());
            insert record;
            
            System.debug('[Moloni API - ] - ' + res.getBody());
            return null;
        }
        
        return res;
    }

    private Attachment attachPdfToDocument(String url, String filename, Id parentId){

       //url = 'https://www.moloni.com/downloads/?h=3ed61efdf77463fd7f06e8bd1e0680a9&d=189606041';   //example URL , only used for tests
       //String url = 'https://www.moloni.com/downloads/?h=98c7ef90097e57380732398e083348e5&d=189548629'; //example URL, only used for tests
// TODO should exist a method to do this but I didn't find...              
       system.debug('attachPdfToDocument: ' + url);
       system.debug('filename: ' + filename);
       system.debug('parentId: ' + parentId);
       if(url == null){
           return null;
       }
       
       String[] aux2 = url.split('=');
       if(aux2.size() != 3){
          return null;
       }
       String h = aux2[1].left(aux2[1].length() - 2);
       String d = aux2[2];
       
       System.debug('aux2: '+ aux2 );
       System.debug('h: '+ h );
       System.debug('d: '+ d );

       url = 'http://www.moloni.com/downloads/index.php?action=getDownload&h=' + h + '&d=' + d + '&e=teste@moloni.com&i=1&t=n';

       Http http = new Http();
       HttpRequest req = new HttpRequest();

       req.setEndpoint(url);

       req.setMethod('GET');

       HttpResponse res = http.send(req);

       String doc = res.getBody();

       transient Blob blbPDFContent = res.getBodyAsBlob();                 
       Attachment attachmentPDF = new Attachment();
       attachmentPdf.parentId = parentId;
       attachmentPdf.name =  filename +'.pdf' ;
       attachmentPdf.body = blbPDFContent;
       //insert attachmentPDF;
       return attachmentPDF;
    }*/

    
}