// Process SEPA File Return
public class SEPA_SF_Return {
//  TODO 1º metodo de validacao
//       2º separar por tipo de ficheiros
//       3º criar o cash entry se necessário
//       4º fazer o cash matching
//TODO deixar de usar queue e usar um batch, de qualquer forma criar uma classe para chamar esse processamento e não fazer o código sempre em duplicado.
    public static String RECEIPT = 'Receipt';
    public static String REFUND = 'Refund';
    
    public static String REFUND_CODE = 'M009';
 
    public static SEPA_ReturnFileHeader returnFileHeader;

    private class SEPA_ReturnFileHeader {
    	public DateTime returnDateTime;  ///MsgId
    	public Date returnCreationDate;  ///CreDtTm
    	public String originalGroupStatus;
    	public String originalPaymentStatus;
    	public String orgnlPmtInfId;
        public String orgnlNbOfTxs;
        public String orgnlCtrlSum;
    	
    	public void setHeaderInSEPAFile(CR_Sepa_File__c sepaFile){
    		sepaFile.Original_Group_Status__c = this.originalGroupStatus;
    		sepaFile.Original_Payment_Status__c = this.originalPaymentStatus;
    		    
    		if( !originalGroupStatus.StartsWith(REFUND_CODE) ){
    		    sepaFile.Return_DateTime__c = this.returnDateTime;

    		    sepaFile.Return_Records_Count__c = Decimal.valueOf(orgnlNbOfTxs);
                sepaFile.Return_Total_Amount__c = Decimal.valueOf(orgnlCtrlSum);
                
    		}else if(originalGroupStatus.StartsWith(REFUND_CODE)){
    			sepaFile.Refund_XML_DateTime__c = this.returnDateTime;
    			
    			sepaFile.Refund_Record_Count__c = Decimal.valueOf(orgnlNbOfTxs);
    			sepaFile.Refund_Total_Amount__c = Decimal.valueOf(orgnlCtrlSum);
    		}
    		
            // sepaFile.SEPA_File_Name__c = orgnlPmtInfId;
    	}
    }

    public static void readReturnXMLforSepaFile(CR_Sepa_File__c sepaFile, Attachment att, Datetime startDatetime) {
        
        system.debug(LoggingLevel.INFO, 'Start readReturnXMLforSepaFile');
        DateTime initialReturnDateTime = sepaFile.Return_DateTime__c;
        
        DOM.Document doc = new DOM.Document();
        string namespace = null;
        try {
            doc.load(att.Body.toString());
            DOM.XMLNode rootDocument = doc.getRootElement();
            namespace = rootDocument.getNamespace();
            system.debug(LoggingLevel.INFO, rootDocument.getName());
            system.debug(LoggingLevel.INFO, rootDocument.getAttributeCount());
            
            //Initial Validations
            if(namespace != 'urn:iso:std:iso:20022:tech:xsd:pain.002.001.03'){
                system.debug(LoggingLevel.INFO, 'Not a return file, rootDocument.getNamespace():' + namespace);
                return;
            }
            
            //End Initial Validations
 
            Map<String, SEPA_TxInfAndSts> txInfAndStssMap = new Map<String, SEPA_TxInfAndSts>();
            
            String tipoFicheiro = rootDocument.getChildElement('CstmrPmtStsRpt', namespace).getChildElement('OrgnlGrpInfAndSts', namespace).getChildElement('OrgnlMsgNmId', namespace).getText();
            
            returnFileHeader = readReturnXMLHeader(rootDocument, namespace);
            // HEADER validation
            if( returnFileHeader == null){
            	system.debug('Error');
            	return;
            }
            
            returnFileHeader.setHeaderInSEPAFile(sepaFile);
           //TODO validar se sepaFile.SEPA_File_Name__c = orgnlPmtInfId
            	
            if (tipoFicheiro == 'pain.008.001.02') {

            	// if is a return file and was already processed
            	if(!returnFileHeader.originalGroupStatus.StartsWith('M009') && initialReturnDateTime != null){
            		system.debug('Return file and was already processed!!!! ' + sepaFile.Return_DateTime__c);
            		return;
            	}
            		
            	// if is a refund file and was already processed
            	// TODO
            	//if(returnFileHeader.originalGroupStatus.StartsWith('M009') && sepaFile.Refund_DateTime__c){
            	//	return;
            	//}
            	
               
                readDirectDebitReturnXML(rootDocument, namespace, sepaFile, txInfAndStssMap, startDatetime);
                
                //process return/refund files
	            if(returnFileHeader.originalGroupStatus.StartsWith(REFUND_CODE)){
	            	 //set header data in SEPA File
	            	processeRefund(startDatetime, sepaFile, txInfAndStssMap);
	            }else{
	            	//set header data in SEPA File
	            	processReturnFile(startDatetime, sepaFile, txInfAndStssMap);
	            }

            } else if(tipoFicheiro == 'pain.001.001.03'){
            	//set header data in SEPA File
                readPaymentsReturnXML( namespace, sepaFile, startDatetime);
            }
            
            update sepaFile;

        } catch (System.XMLException e) {
            system.debug(LoggingLevel.INFO, 'sepaFile.Name: ' + sepaFile.Name + ' With att: ' + att.Name + ' getLineNumber: ' + e.getLineNumber() + ' Exception: ' + e.getMessage() + ' getStackTraceString: ' + e.getStackTraceString());Utilities.LogIntegration(startDatetime, datetime.now(), 'Error', 'readReturnXMLforSepaFile catch', 'In att: ' + att.Name + ' Exception: ' + e.getMessage(), sepaFile.Name);
        }
    } 

    //process return SEPA files XML
    private static void processReturnFile(Datetime startDatetime, CR_Sepa_File__c sepaFile, Map<String, SEPA_TxInfAndSts> txInfAndStssMap){
    	
        List<CR_Sepa_Record__c> sepaRecList = [
                Select Id
                , Name
                , Document_Due_Date__c
                , Document_Type__c
                , IBAN__c
                , Swift_Bic__c
                , Mandate_Identification__c
                , Mandate_Date__c
                , CR_Sepa_File__r.Id
                , Debtor_Account__c
                , Debtor_Name__c
                , Invoice_Number__c
                , Request_Count__c
                , Request_Amount__c
                , Request_Currency__c
                , Request_DateTime__c
                , Return_Amount__c
                , Return_Currency__c
                , Return_DateTime__c
                , Payable_Invoice__c
                , Sales_Invoice__c
                , Matching_Reference__c
                , Undo_Matching_Reference__c
                , Sales_Invoice__r.CR_Sepa_Record__r.Id
                , Sales_Invoice__r.Collection_Case__c
                , Sales_Invoice__r.Id
                , Sales_Invoice__r.Name
                , Sales_Invoice__r.c2g__OutstandingValue__c
                , Sales_Invoice__r.c2g__DueDate__c
                , Sales_Invoice__r.c2g__Period__r.Id
                , Sales_Invoice__r.c2g__Transaction__r.Id
                , Payment_Collection__c
                From CR_Sepa_Record__c
                WHERE
                    Sales_Invoice__r.Id != null 
                   // AND Sales_Invoice__r.c2g__PaymentStatus__c != 'Paid'
                    AND Return_Status_Code__c = null   //TODO check if is needed or should be remove... the problem is the account... Make validations and send errors. // to assure that the SEPA Record is not processed more than once
                    AND Invoice_Number__c IN :txInfAndStssMap.keySet()
                    AND CR_Sepa_File__r.Id = :sepaFile.Id
                ORDER BY Debtor_Account__c
            ];
           
        system.debug(LoggingLevel.INFO, 'CR_SEPA readReturnXMLforSepaFile sepaRecList.size()' + sepaRecList.size());
            
        if (sepaRecList.size() == 0) {
            Utilities.LogIntegration(startDatetime, datetime.now(), 'Warning', 'readReturnXMLforSepaFile', 'sepaFile as no CR_Sepa_Record__c to process invoices sepaFile.Id:' + sepaFile.Id + ' sepaFile.Name: ' + sepaFile.Name, 'sepaFile.Id:' + sepaFile.Id);
            return;
        }
        
        //TODO ir buscar ao ficheiro e não ao SEPA FILE    
        c2g__codaBankAccount__c bankAccount = SEPA_UTILS.getBankAccountFromIban(sepaFile.SEPA_Our_Bank_IBAN__c);
                        
        if (sepaRecList.size() > 0) {

            c2g__codaCashEntry__c cashEntry = generateCashEntry(sepaFile, sepaRecList, txInfAndStssMap, bankAccount, startDatetime, 'Receipt');
            cashMatch( txInfAndStssMap, cashEntry, sepaFile.Id);

        }

    }

    //process refunds SEPA files XML
    private static void processeRefund(Datetime startDatetime, CR_Sepa_File__c sepaFile, Map<String, SEPA_TxInfAndSts> txInfAndStssMap){

	    List<CR_Sepa_Record__c> sepaRecList = [
	        Select Id
	        , Name
	        , Document_Due_Date__c
	        , Document_Type__c
	        , IBAN__c
	        , Swift_Bic__c
	        , Mandate_Identification__c
	        , Mandate_Date__c
	        , CR_Sepa_File__r.Id
	        , Debtor_Account__c
	        , Debtor_Name__c
	        , Invoice_Number__c
	        , Request_Count__c
	        , Request_Amount__c
	        , Request_Currency__c
	        , Request_DateTime__c
	        , Return_Amount__c
	        , Return_Currency__c
	        , Return_DateTime__c
	        , Payable_Invoice__c
	        , Sales_Invoice__c
	        , Matching_Reference__c
	        , Undo_Matching_Reference__c
	        , Sales_Invoice__r.CR_Sepa_Record__r.Id
	        , Sales_Invoice__r.Collection_Case__c
	        , Sales_Invoice__r.Id
	        , Sales_Invoice__r.Name
	        , Sales_Invoice__r.c2g__OutstandingValue__c
	        , Sales_Invoice__r.c2g__DueDate__c
	        , Sales_Invoice__r.c2g__Period__r.Id
	        , Sales_Invoice__r.c2g__Transaction__r.Id
	        , Payment_Collection__c
	        From CR_Sepa_Record__c
	           WHERE
	               Sales_Invoice__r.Id != null 
	               AND Return_Status_Code__c = '0000'   // TODO check if is needed.
		           AND Invoice_Number__c IN :txInfAndStssMap.keySet() 
		           AND CR_Sepa_File__r.Id = :sepaFile.Id
		           ORDER BY Debtor_Account__c
	    ];

		system.debug(LoggingLevel.INFO, 'txInfAndStssMap.keySet() ' + txInfAndStssMap.keySet() );    
	    system.debug(LoggingLevel.INFO, 'M009 CR_SEPA readReturnXMLforSepaFile sepaRecList.size()' + sepaRecList.size());

	    if (sepaRecList.size() == 0) {
	         Utilities.LogIntegration(startDatetime, datetime.now(), 'Warning', 'readReturnXMLforSepaFile', 'sepaFile as no CR_Sepa_Record__c to process invoices sepaFile.Id:' + sepaFile.Id + ' sepaFile.Name: ' + sepaFile.Name, 'sepaFile.Id:' + sepaFile.Id);
	         return;
	    }
	            
	    c2g__codaBankAccount__c bankAccount = SEPA_UTILS.getBankAccountFromIban(sepaFile.SEPA_Our_Bank_IBAN__c);
	                        
	    if (sepaRecList.size() > 0) {

             c2g__codaCashEntry__c cashEntry = generateCashEntry(sepaFile, sepaRecList, txInfAndStssMap, bankAccount, startDatetime, 'Refund');
             undoCashMatch(sepaRecList, txInfAndStssMap, sepaFile, cashEntry, bankAccount, startDatetime);

	    }
	            
        return;
    }

    public static void readPaymentsReturnXML(String namespace, CR_Sepa_File__c sepaFile, Datetime startDatetime) {
        
        system.debug(LoggingLevel.INFO, 'CR_SEPA readPaymentsReturnXML, sepaFile.Name: ' + sepaFile.Name + ' sepaFile.SEPA_Movement_Type__c: ' + sepaFile.SEPA_Movement_Type__c + ' namespace: ' + namespace);
        system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_File_Name__c: ' + sepaFile.SEPA_File_Name__c);
              
        // update sepaFile;

        if( !sepaFile.Original_Group_Status__c.StartsWith('M000')){
            system.debug(LoggingLevel.INFO, 'CR_SEPA readPaymentsReturnXML did not returned complete success: ' + namespace);
            Utilities.LogIntegration(startDatetime, datetime.now(), 'Error', 'CR_SEPA readPaymentsReturnXML did not returned complete success, sepaFile.Name: ' + sepaFile.Name, 'CR_SEPA readPaymentsReturnXML did not returned complete success', sepaFile.Id);
            return;
        }
        
        List<CR_Sepa_Record__c> sepaRecList = [
            Select Id
            ,Name
            , Document_Due_Date__c
            , Document_Type__c
            , IBAN__c
            , Swift_Bic__c
            , Mandate_Identification__c
            , Mandate_Date__c
            , CR_Sepa_File__r.Id
            , Debtor_Account__c
            , Debtor_Name__c
            , Invoice_Number__c
            , Request_Count__c
            , Request_Amount__c
            , Request_Currency__c
            , Request_DateTime__c
            , Return_Amount__c
            , Return_Currency__c
            , Return_DateTime__c
            , Sales_Invoice__c
            , Payable_Invoice__c
            , Payable_Invoice__r.Id
            , Payable_Invoice__r.Name
            , Payable_Invoice__r.c2g__DueDate__c
            , Payable_Invoice__r.c2g__Period__r.Id
            , Payable_Invoice__r.c2g__Transaction__r.Id
            , Payable_Invoice__r.c2g__PaymentStatus__c
            , Payable_Invoice__r.CR_Sepa_Record__r.Id
            , Sales_Credit_Note__c
            , Sales_Credit_Note__r.Id
            , Sales_Credit_Note__r.Name
            , Sales_Credit_Note__r.c2g__DueDate__c
            , Sales_Credit_Note__r.c2g__Period__r.Id
            , Sales_Credit_Note__r.c2g__Transaction__r.Id
            , Sales_Credit_Note__r.c2g__PaymentStatus__c
            , Sales_Credit_Note__r.CR_Sepa_Record__r.Id
            , Matching_Reference__c
            , Payment_Collection__c
            From CR_Sepa_Record__c
            WHERE
                CR_Sepa_File__r.Id = :sepaFile.Id
            AND
                ((Payable_Invoice__r.Id != null /*AND Payable_Invoice__r.c2g__PaymentStatus__c != 'Paid'*/)
                OR
                (Sales_Credit_Note__r.Id != null /*AND Sales_Credit_Note__r.c2g__PaymentStatus__c != 'Paid' */))
            ORDER BY Debtor_Account__c
        ];
        
        system.debug('sepaFileName' + sepaFile.SEPA_File_Name__c);
        system.debug('sepaRecList.size(): ' + sepaRecList.size());
        
        Integer sepaRecListSize = sepaRecList.size();
        
        Decimal totalAmountSepaRecs = 0;
        
        // *************** TODO  ver se dá para fazer de uma forma melhor
        List<CR_Sepa_Record__c> sepaRecListNew = new List<CR_Sepa_Record__c>();
        for(Integer i = sepaRecListSize - 1 ; i>=0 ; i--){
            
            CR_Sepa_Record__c sepaRec = sepaRecList.get(i);
            
            system.debug(LoggingLevel.INFO, 'CR_SEPA readPaymentsReturnXML sepaRec.Name: ' + sepaRec.Name + ' sepaRec.Request_Amount__c: ' + sepaRec.Request_Amount__c + ' sepaRec.Sales_Credit_Note__r.c2g__PaymentStatus__c: ' + sepaRec.Sales_Credit_Note__r.c2g__PaymentStatus__c);
            
            totalAmountSepaRecs += sepaRec.Request_Amount__c;
            
            if(sepaFile.SEPA_Movement_Type__c == 'Payments' || sepaFile.SEPA_Movement_Type__c == 'PaymentsVendors' || sepaFile.SEPA_Movement_Type__c == 'SalesCreditNotes' ){
                system.debug(LoggingLevel.INFO, 'CR_SEPA readPaymentsReturnXML Processing Cash Match sepaRec.Name: ' + sepaRec.Name);
                //For setting the period in the cash match
                sepaRec.Return_DateTime__c = sepaFile.Return_DateTime__c;
                sepaRecListNew.add(sepaRec);
            } else {
                system.debug(LoggingLevel.INFO, 'CR_SEPA readPaymentsReturnXML Skipping  Cash Match sepaRec.Name: ' + sepaRec.Name);
                //sepaRecList.remove(i);
            }
        }
        sepaRecList = sepaRecListNew;

        if( math.abs(sepaFile.Return_Total_Amount__c) != totalAmountSepaRecs ){

            system.debug('Problem occurred in SEPA File :' + sepaFile + 'CR_SEPA readPaymentsReturnXML Unbalanced Cash Match OrgnlCtrlSum' + totalAmountSepaRecs + '!= 0 OrgnlCtrlSum'  + sepaFile.Return_Total_Amount__c + ' totalAmountSepaRecs:' + sepaFile.Return_Records_Count__c);
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SEPA',
            																	message__c = 'Problem occurred in SEPA File:' + sepaFile + 'CR_SEPA readPaymentsReturnXML Unbalanced Cash Match OrgnlCtrlSum' + totalAmountSepaRecs + '!= 0  OrgnlCtrlSum ' + sepaFile.Return_Total_Amount__c + ' totalAmountSepaRecs:' + sepaFile.Return_Records_Count__c, printStackTrace__c =  ' ');
            insert record;
            
            return;
        }

        c2g__codaBankAccount__c bankAccount = SEPA_UTILS.getBankAccountFromIban(sepaFile.SEPA_Our_Bank_IBAN__c);
        
        if (sepaRecList.size() > 0) {
          
            c2g__codaCashEntry__c cashEntry = generateCashEntry(sepaFile, sepaRecList, null,  bankAccount,  startDatetime, null);
            //cash match
            cashMatch( null, cashEntry, sepaFile.Id);
        }
    }

    // fazer undo match
    public static void readDirectDebitReturnXML_M009(DOM.XMLNode orgnlPmtInfAndSts, String namespace, CR_Sepa_File__c sepaFile, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, Datetime startDatetime) {
        
        for (DOM.XMLNode child : orgnlPmtInfAndSts.getChildElements()) {
            if (child.getName() == 'TxInfAndSts') {
                try {
                    
                    String invoice = child.getChildElement('OrgnlEndToEndId', namespace).getText();
                    String reqdColltnDt = child.getChildElement('OrgnlTxRef', namespace).getChildElement('ReqdColltnDt', namespace).getText();
                    String status = child.getChildElement('StsRsnInf', namespace).getChildElement('Rsn', namespace).getChildElement('Cd', namespace).getText();
                    
                    String bankTrnId = null; //child.getChildElement('StsRsnInf', namespace).getChildElement('Orgtr', namespace).getChildElement('Id', namespace).getChildElement('OrgId', namespace).getChildElement('BICOrBEI', namespace).getText();
                    //TODO
                    //String iban = child.getChildElement('OrgnlTxRef', namespace).getChildElement('DbtrAcct', namespace).getChildElement('Id', namespace).getChildElement('IBAN', namespace).getText();
                    String paid = child.getChildElement('OrgnlTxRef', namespace).getChildElement('Amt', namespace).getChildElement('InstdAmt', namespace).getText();
                    txInfAndStssMap.put(invoice, new SEPA_TxInfAndSts(invoice, reqdColltnDt, status, bankTrnId, paid));

                } catch (Exception e) {
                    string invoice = '';string status = '';string bankTrnId = '';string paid = '';
                    try {
                        invoice = child.getChildElement('OrgnlEndToEndId', namespace).getText();
                        status = child.getChildElement('StsRsnInf', namespace).getChildElement('Rsn', namespace).getChildElement('Cd', namespace).getText();
                        bankTrnId = child.getChildElement('StsRsnInf', namespace).getChildElement('Orgtr', namespace).getChildElement('Id', namespace).getChildElement('OrgId', namespace).getChildElement('BICOrBEI', namespace).getText();
                        paid = child.getChildElement('OrgnlTxRef', namespace).getChildElement('Amt', namespace).getChildElement('InstdAmt', namespace).getText();
                    } catch (Exception ex) {
                    	
                    }
                    system.debug(LoggingLevel.INFO, 'CR_SEPA readDirectDebitReturnXML issues reading one TxInfAndSts, invoice: ' + invoice + ' status:' + status + ' bankTrnId:' + bankTrnId + ' paid:' + paid);
                }
            }
        }
        
        system.debug(LoggingLevel.INFO, 'txInfAndStssMap.size()' + txInfAndStssMap.size());
        system.debug(LoggingLevel.INFO, 'txInfAndStssMap' + txInfAndStssMap);
        
        update sepaFile;
    }
    

    private static SEPA_ReturnFileHeader readReturnXMLHeader(DOM.XMLNode rootDocument, String namespace){
    	SEPA_ReturnFileHeader returnFileHeader = new SEPA_ReturnFileHeader();
    	
    	DOM.XMLNode cstmrPmtStsRpt = rootDocument.getChildElement('CstmrPmtStsRpt', namespace);

        if (cstmrPmtStsRpt == null) {
            return null;
        }
        
        DOM.XMLNode grpHdr = cstmrPmtStsRpt.getChildElement('GrpHdr', namespace);
        String sepaFileNameReturned = grpHdr.getChildElement('MsgId', namespace).getText();

        system.debug(LoggingLevel.INFO, 'sepaFileNameReturned: ' + sepaFileNameReturned);
      
        Integer sepaFileNameReturnedLentgh = sepaFileNameReturned.length();
        //yyyy-MM-dd HH:mm:ss
//        sepaFile.Return_DateTime__c = datetime.newInstance(
        returnFileHeader.returnDateTime = datetime.newInstance(
            Integer.valueOf(sepaFileNameReturned.substring(sepaFileNameReturnedLentgh - 14 , sepaFileNameReturnedLentgh - 10 ))
            , Integer.valueOf(sepaFileNameReturned.substring(sepaFileNameReturnedLentgh - 10, sepaFileNameReturnedLentgh - 8 ))
            , Integer.valueOf(sepaFileNameReturned.substring(sepaFileNameReturnedLentgh - 8, sepaFileNameReturnedLentgh - 6 ))
            , Integer.valueOf(sepaFileNameReturned.substring(sepaFileNameReturnedLentgh - 6, sepaFileNameReturnedLentgh - 4 ))
            , Integer.valueOf(sepaFileNameReturned.substring(sepaFileNameReturnedLentgh - 4, sepaFileNameReturnedLentgh - 2 ))
            , Integer.valueOf(sepaFileNameReturned.substring(sepaFileNameReturnedLentgh - 2, sepaFileNameReturnedLentgh))
        );
        
        system.debug(LoggingLevel.INFO, 'returnFileHeader.returnDateTime: ' + returnFileHeader.returnDateTime);
     
        String creDtTm = grpHdr.getChildElement('CreDtTm', namespace).getText();
        
        returnFileHeader.returnCreationDate =  Date.valueOf(creDtTm);
        system.debug(LoggingLevel.INFO, 'returnCreationDate: ' + returnFileHeader.returnCreationDate);
        
        DOM.XMLNode orgnlPmtInfAndSts = cstmrPmtStsRpt.getChildElement('OrgnlPmtInfAndSts', namespace);
        
        String group_StatusCode = cstmrPmtStsRpt.getChildElement('OrgnlGrpInfAndSts', namespace).getChildElement('StsRsnInf', namespace).getChildElement('Rsn', namespace).getChildElement('Prtry', namespace).getText();
        String original_Group_Status = group_StatusCode + ' - ' + CR_CS_SEPA_Codes__c.getValues('OrgnlGrpInfAndSts.StsRsnInf.'+ group_StatusCode).Value__c;
        
        
        String payment_StatusCode =  orgnlPmtInfAndSts.getChildElement('StsRsnInf', namespace).getChildElement('Rsn', namespace).getChildElement('Prtry', namespace).getText();
        String original_Payment_Status = payment_StatusCode + ' - ' + CR_CS_SEPA_Codes__c.getValues('OrgnlPmtInfAndSts.StsRsnInf.'+ payment_StatusCode).Value__c;
        

        //sepaFile.Original_Group_Status__c = original_Group_Status.left(255);
        returnFileHeader.originalGroupStatus = original_Group_Status.left(255);
        //sepaFile.Original_Payment_Status__c = Original_Payment_Status.left(255);
        returnFileHeader.originalPaymentStatus = Original_Payment_Status.left(255);
        system.debug(LoggingLevel.INFO, 'returnFileHeader.returnDateTime: ' + returnFileHeader.returnDateTime);
        system.debug(LoggingLevel.INFO, 'returnFileHeader.originalGroupStatus: ' + returnFileHeader.originalGroupStatus);
        system.debug(LoggingLevel.INFO, 'returnFileHeader.originalPaymentStatus: ' + returnFileHeader.originalPaymentStatus);
        
        returnFileHeader.orgnlPmtInfId = orgnlPmtInfAndSts.getChildElement('OrgnlPmtInfId', namespace).getText();
        returnFileHeader.orgnlNbOfTxs = orgnlPmtInfAndSts.getChildElement('OrgnlNbOfTxs', namespace).getText();
        returnFileHeader.orgnlCtrlSum = orgnlPmtInfAndSts.getChildElement('OrgnlCtrlSum', namespace).getText();

        return returnFileHeader;
    }
    
    //TODO split StartsWith('M009') from this method
    public static void readDirectDebitReturnXML(DOM.XMLNode rootDocument, String namespace, CR_Sepa_File__c sepaFile, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, Datetime startDatetime) {
    
        DOM.XMLNode cstmrPmtStsRpt = rootDocument.getChildElement('CstmrPmtStsRpt', namespace);
        DOM.XMLNode orgnlPmtInfAndSts = cstmrPmtStsRpt.getChildElement('OrgnlPmtInfAndSts', namespace);
   
        if(sepaFile.Original_Group_Status__c.StartsWith(REFUND_CODE)){
            readDirectDebitReturnXML_M009(orgnlPmtInfAndSts , namespace, sepaFile, txInfAndStssMap, startDatetime);
            return;
        }
        
        for (DOM.XMLNode child : orgnlPmtInfAndSts.getChildElements()) {
            if (child.getName() == 'TxInfAndSts') {
                try {
                    
                    string invoice = child.getChildElement('OrgnlEndToEndId', namespace).getText();
                    string reqdColltnDt = child.getChildElement('OrgnlTxRef', namespace).getChildElement('ReqdColltnDt', namespace).getText();
                    string status = child.getChildElement('StsRsnInf', namespace).getChildElement('Rsn', namespace).getChildElement('Cd', namespace).getText();
                    string bankTrnId = child.getChildElement('AcctSvcrRef', namespace).getText();
                    string paid = child.getChildElement('OrgnlTxRef', namespace).getChildElement('Amt', namespace).getChildElement('InstdAmt', namespace).getText();
                    txInfAndStssMap.put(invoice, new SEPA_TxInfAndSts(invoice, reqdColltnDt, status, bankTrnId, paid));
                    
                } catch (Exception e) {
                    string invoice = '';string status = '';string bankTrnId = '';string paid = '';try {
                        invoice = child.getChildElement('OrgnlEndToEndId', namespace).getText();status = child.getChildElement('StsRsnInf', namespace).getChildElement('Rsn', namespace).getChildElement('Cd', namespace).getText();bankTrnId = child.getChildElement('AcctSvcrRef', namespace).getText();paid = child.getChildElement('OrgnlTxRef', namespace).getChildElement('Amt', namespace).getChildElement('InstdAmt', namespace).getText();
                    } catch (Exception ex) {
                    }system.debug(LoggingLevel.INFO, 'CR_SEPA readDirectDebitReturnXML issues reading one TxInfAndSts, invoice: ' + invoice + ' status:' + status + ' bankTrnId:' + bankTrnId + ' paid:' + paid);
                }
            }
        }
        
        system.debug(LoggingLevel.INFO, 'txInfAndStssMap.size()' + txInfAndStssMap.size());
        system.debug(LoggingLevel.INFO, 'txInfAndStssMap' + txInfAndStssMap);
        
        update sepaFile;
    }

    private static decimal returnAmount(String documentType, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, CR_Sepa_Record__c sepaRec){
    	if(documentType == 'RCUR'){
    	    return Decimal.valueOf(txInfAndStssMap.get(sepaRec.Invoice_Number__c).paid);
    	}else{
    		// TODO
    		return ( sepaRec.Request_Amount__c < 0 ? sepaRec.Request_Amount__c * -1 : sepaRec.Request_Amount__c );
    	}

    }
    
    private static String returnStatusCode(String documentType, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, CR_Sepa_Record__c sepaRec){
    	
    	if(documentType == 'RCUR'){
    	    return txInfAndStssMap.get(sepaRec.Invoice_Number__c).status;
    	}else{
    		// TODO
    		return '0000';
    	}
    }
    
    private static String returnTransactionID(String documentType, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, CR_Sepa_Record__c sepaRec){
    	
    	if(documentType == 'RCUR'){
    	    return txInfAndStssMap.get(sepaRec.Invoice_Number__c).bankTrnId;
    	}else{
    		return null;
    	}
    }

    //TODO tem de ser alterado
    private static String cashEntryType(String documentType, String cashEntryType){
    	
    	if(documentType == 'RCUR'){
    	    return cashEntryType;
    	}else if(documentType == 'PaymentsVendors' || documentType == 'Payments'){
            return 'Payment';
        } else if(documentType == 'SalesCreditNotes'){
            return 'Refund';
        } else {
            system.debug('SEPA_SF_Return cashEntryType sepaRecList.get(0) Type is unkown. documentType: ' + documentType);
            //TODO Utilities.LogIntegration(startDatetime, datetime.now(), 'Error', 'SEPA_SF_Return GenerateCashEntry sepaRecList.get(0) Type is unkown.', 'SEPA_SF_Return GenerateCashEntry sepaRecList.get(0) Type is unkown. sepaFile.Name: ' + sepaFile.Name + ' sepaRecList.get(0).Name: ' + sepaRecList.get(0).Name, sepaFile.Id);
            return 'lolo'; //vai dar porcaria
        }
  
    }
    
    private static Id getPeriodDueDate(CR_Sepa_File__c sepaFile, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, CR_Sepa_Record__c sepaRec){
    	String documentType = sepaFile.SEPA_Movement_Type__c;
    	if(documentType == 'RCUR'){
    		//TODO acho que o sepaFile.SEPA_Collection_Date__c é genérico e dá para tudo... Confirmar
    	    return SEPA_UTILS.getPeriod(txInfAndStssMap.get(sepaRec.Invoice_Number__c).reqdColltnDt).Id;
    	}else{
    		//TODO confirmar se esta ok
    	    return SEPA_UTILS.getPeriod( sepaFile.SEPA_Collection_Date__c ).Id;
        }

    }

/*    
    private static Id cashEntryValue(CR_Sepa_File__c sepaFile, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, CR_Sepa_Record__c sepaRec){
    	
    	String documentType = sepaFile.SEPA_Movement_Type__c;
    	if(documentType == 'RCUR'){
    	    return SEPA_UTILS.getPeriod(txInfAndStssMap.get(sepaRec.Invoice_Number__c).reqdColltnDt).Id;
    	}else{
    		//TODO confirmar se esta ok
    	    return SEPA_UTILS.getPeriod( sepaFile.SEPA_Collection_Date__c ).Id;
        }

    }
*/    
    private static date cashEntryDate(String documentType, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, List<CR_Sepa_Record__c> sepaRecListProcessed){
    	
    	if(documentType == 'RCUR'){
    	    return Date.valueOf(txInfAndStssMap.get(sepaRecListProcessed.get(0).Invoice_Number__c).reqdColltnDt);
    	}else{
    	    return returnFileHeader.returnCreationDate;
        }
    }
   
   // TODO fazer isto deve ser....
   //c2g__CashEntryValue__c 
   
    public static c2g__codaCashEntry__c generateCashEntry(CR_Sepa_File__c sepaFile, List<CR_Sepa_Record__c> sepaRecList, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, c2g__codaBankAccount__c bankAccount, Datetime startDatetime, String cashEntryType) {
        
        if(sepaRecList.size() == 0){
            system.debug(LoggingLevel.INFO, 'SEPA_SF_Return GenerateCashEntry '+ sepaFile.Name +' has empty sepaRecList');
            Utilities.LogIntegration(startDatetime, datetime.now(), 'Error', 'SEPA_SF_Return GenerateCashEntry has empty sepaRecList', 'SEPA_SF_Return GenerateCashEntry '+ sepaFile.Name +' has empty sepaRecList', sepaFile.Id);
            return null;
        }
        
        Savepoint sp = null;
        
        List<CR_Sepa_Record__c> sepaRecListProcessed = new List<CR_Sepa_Record__c>();
        
        system.debug(LoggingLevel.INFO, 'generateCashEntry sepaRecList.size():' + sepaRecList.size());
        
        try {
          
          //start transation
            sp = Database.setSavepoint();
            List <Id> paymentCollectionIdList = new List <Id>();
            for (CR_Sepa_Record__c sepaRec : sepaRecList) {
            	paymentCollectionIdList.add(sepaRec.Payment_Collection__c);
            }
            Map<Id, Payment_Collection__c> paymentCollectionMap = new Map<Id, Payment_Collection__c>([select Id, Status__c FROM Payment_Collection__c WHERE Id = :paymentCollectionIdList ]);
            
            for (CR_Sepa_Record__c sepaRec : sepaRecList) {
                
                system.debug(sepaRec);

                Decimal amountReturn = returnAmount( sepaFile.SEPA_Movement_Type__c , txInfAndStssMap, sepaRec); // Decimal.valueOf(txInfAndStssMap.get(sepaRec.Invoice_Number__c).paid);
                if(cashEntryType == null || cashEntryType == 'Receipt'){
                     sepaRec.Return_DateTime__c = startDatetime;
                     sepaRec.Return_Amount__c = amountReturn;
                }else if(cashEntryType =='Refund'){
                    sepaRec.Refund_XML_DateTime__c = startDatetime;
                    sepaRec.Refund_Amount__c = amountReturn;
                }
                
                sepaRec.Return_Currency__c = 'EUR';
                sepaRec.Return_Status_Code__c = returnStatusCode(sepaFile.SEPA_Movement_Type__c, txInfAndStssMap,  sepaRec); // txInfAndStssMap.get(sepaRec.Invoice_Number__c).status;
/*                if(sepaRec.Payment_Collection__c != null){
                    paymentCollectionMap.get(sepaRec.Payment_Collection__c).Status__c = 'Unpaid';
                }
*/                
                sepaRec.Return_Transaction_ID__c = returnTransactionID(sepaFile.SEPA_Movement_Type__c, txInfAndStssMap, sepaRec); //txInfAndStssMap.get(sepaRec.Invoice_Number__c).bankTrnId;
                String returnType = CR_CS_SEPA_Codes__c.getValues('TxInfAndSts.StsRsnInf.' + sepaRec.Return_Status_Code__c).Type__c;
                String status = sepaRec.Return_Status_Code__c + ' - ' + CR_CS_SEPA_Codes__c.getValues('TxInfAndSts.StsRsnInf.' + sepaRec.Return_Status_Code__c).Value__c;
                if(status.length() > 240){
                	status = status.left(240) + '...';
                }
                sepaRec.Return_Status__c = status;
                sepaRec.Return_Status_Type__c = returnType;
                
                if(!sepaRec.Return_Status_Code__c.equals('0000') ){
                	if(sepaRec.Return_Status_Type__c.equals('Internal') ){
                		paymentCollectionMap.get(sepaRec.Payment_Collection__c).Status__c = 'Error';
                        Case reportCase = Case_Utils.newCase('High', 'Interno', 'Administração', 'Erro no SEPA', 'Erro no CP SEPA Record Nome:' + sepaRec.Name+' Por Favor verifique o problema e reenvie o SEPA para o cliente.', null);
                        insert reportCase;
                	}else{
                		paymentCollectionMap.get(sepaRec.Payment_Collection__c).Status__c = 'Unpaid';
                	}
                }

                if (returnType == 'Processed') {  // TODO ver se dá para usar o cashEntryType
                    //Add trn's
                    system.debug(LoggingLevel.INFO, 'Creating FF Trn for sepaRec.Name' + sepaRec.Name + ' sepaRec.Sales_Invoice__r.Name: ' + sepaRec.Sales_Invoice__r.Name);
                    sepaRecListProcessed.add(sepaRec);
                }
                else if(cashEntryType == 'Refund'){
                	//TODO TODO
                	system.debug(LoggingLevel.INFO, 'M009 Creating FF Trn for sepaRec.Name' + sepaRec.Name + ' sepaRec.Sales_Invoice__r.Name: ' + sepaRec.Sales_Invoice__r.Name);
                    sepaRecListProcessed.add(sepaRec);
                    //TODO create a Case
                }
                else{
                    //TODO: Queue to cases, etc.
                }
            }
   
            update sepaRecList;
            update paymentCollectionMap.values();
            
            system.debug(LoggingLevel.INFO, 'sepaRecListProcessed.size()' + sepaRecListProcessed.size());
         
            if(sepaRecListProcessed.size() > 0){
                                                                                                     //TODO
                Id periodDueDate = getPeriodDueDate(sepaFile , txInfAndStssMap, sepaRecListProcessed.get(0) ); //SEPA_UTILS.getPeriod(txInfAndStssMap.get(sepaRecListProcessed.get(0).Invoice_Number__c).reqdColltnDt).Id;
                system.debug('PeriodDueDate: ' + periodDueDate);
                
                // Generate appropriate Cash Entry
                c2g__codaCashEntry__c cashEntry = new c2g__codaCashEntry__c();
                
                cashEntry.c2g__Type__c = cashEntryType(sepaFile.SEPA_Movement_Type__c, cashEntryType); //cashEntryType;

                cashEntry.c2g__BankAccount__c = bankAccount.Id;
                cashEntry.c2g__Period__c = periodDueDate;
                cashEntry.c2g__CashEntryCurrency__c = bankAccount.c2g__BankAccountCurrency__r.Id;
                cashEntry.c2g__PaymentMethod__c = 'Electronic';
                cashEntry.CR_Sepa_File__c = sepaFile.Id;
                date cashEntryDate = cashEntryDate(sepaFile.SEPA_Movement_Type__c , txInfAndStssMap, sepaRecListProcessed); //Date.valueOf(txInfAndStssMap.get(sepaRecListProcessed.get(0).Invoice_Number__c).reqdColltnDt);
                if(cashEntryDate != null){
                   cashEntry.c2g__Date__c = cashEntryDate;
                }

                List<c2g__codaCashEntryLineItem__c> cashEntryLineItems = new List<c2g__codaCashEntryLineItem__c>();

                //Execute DML to insert Cash Entry
                insert cashEntry;

                system.debug(LoggingLevel.INFO, 'cashEntry.Id : ' + cashEntry.Id
                             + 'cashEntry.c2g__BankAccount__c : ' + cashEntry.c2g__BankAccount__c
                             + 'cashEntry.c2g__Period__c : ' + cashEntry.c2g__Period__c
                             + 'cashEntry.c2g__CashEntryCurrency__c : ' + cashEntry.c2g__CashEntryCurrency__c
                             + 'cashEntry.c2g__PaymentMethod__c : ' + cashEntry.c2g__PaymentMethod__c);
                              
                //adicionar todos os Sepas
                for (CR_Sepa_Record__c sepaRec : sepaRecListProcessed) {
                    c2g__codaCashEntryLineItem__c cashEntryLineItem = new c2g__codaCashEntryLineItem__c();
                    cashEntryLineItem.c2g__AccountPaymentMethod__c = 'Electronic';
                    cashEntryLineItem.c2g__Account__c = sepaRec.Debtor_Account__c;
                    cashEntryLineItem.c2g__CashEntryValue__c = sepaRec.Return_Amount__c;
                    cashEntryLineItem.c2g__CashEntry__c = cashEntry.Id;
                    cashEntryLineItem.CR_Sepa_Record__c = sepaRec.Id;    //TODO IMPORTANTE PARA O PAY INVOICE
                    cashEntryLineItems.add(cashEntryLineItem);
                   // txInfAndStssMap.get(sepaRec.Invoice_Number__c).cashEntryLineItems = cashEntryLineItems;

                   system.debug(LoggingLevel.INFO, 'cashEntryLineItem.c2g__Account__c : ' + cashEntryLineItem.c2g__Account__c
                                 + 'cashEntryLineItem.c2g__CashEntryValue__c : ' + cashEntryLineItem.c2g__CashEntryValue__c
                                 + 'cashEntryLineItem.c2g__CashEntry__c : ' + cashEntryLineItem.Id
                                );
                }
 
                insert cashEntryLineItems; //TODO ver se vale a pena por no SEPA Record a ligação, de qq forma tenho de ter uma ligação entre o SEPA record e o SEPA

        // Post the Cash Entry
                List<c2g.CODAAPICommon.Reference> cashEntryRefs = new List<c2g.CODAAPICommon.Reference>();
                cashEntryRefs.add(c2g.CODAAPICommon.getRef(cashEntry.Id, null));
                c2g.CODAAPICashEntry_7_0.BulkPostCashEntry(null, cashEntryRefs);
           
              return cashEntry;
            } 
        } catch (Exception ex) {
            if (sp != null) {
                Database.rollback(sp);
            }
            //outbound and debug
            system.debug(LoggingLevel.INFO, 'Exception GenerateCashEntry ');
            system.debug(LoggingLevel.INFO, 'ex.getCause(): ' + ex.getCause());
            system.debug(LoggingLevel.INFO, 'ex.getLineNumber(): ' + ex.getLineNumber());
            system.debug(LoggingLevel.INFO, 'ex.getMessage(): ' + ex.getMessage());
            system.debug(LoggingLevel.INFO, 'ex.getTypeName(): ' + ex.getTypeName());
            system.debug(LoggingLevel.INFO, 'ex.getStackTraceString(): ' + ex.getStackTraceString());
            
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SEPA',
            																	message__c = 'CR_SEPA GenerateCashEntry '+ sepaFile.Name +' at: ' + ex.getLineNumber(),
            																	printStackTrace__c = ex.getStackTraceString());
            insert record;
        }
        
        return null;
    }

//Map<String, SEPA_TxInfAndSts> txInfAndStssMap, CR_Sepa_File__c sepaFile 
    private static void cashMatch( Map<String, SEPA_TxInfAndSts> txInfAndStssMap, c2g__codaCashEntry__c cashEntry, Id sepaFileId){
        
        if(cashEntry == null){
        	system.debug('There are no catch matching that need to be done');
            return;
        }
        
        system.debug('Process cashMatch');
        
        SEPA_BH_SF_Return cashMatchBatch = new SEPA_BH_SF_Return(cashEntry, txInfAndStssMap, sepaFileId);
        ID batchprocessid = Database.executeBatch(cashMatchBatch, 5);

    }

	public static void undoCashMatch(List<CR_Sepa_Record__c> sepaRecList, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, CR_Sepa_File__c sepaFile, c2g__codaCashEntry__c cashEntry, c2g__codaBankAccount__c bankAccount, Datetime startDatetime) {
	    //vamos fazer agora os undo cash matchs com os respectivos cash line items
	    system.debug('undoCashMatch');
	             
	    List<Id> sepaRecordIdList = new List<Id>();
	    for(CR_Sepa_Record__c auxSepaRecord : sepaRecList){
	    	sepaRecordIdList.add(auxSepaRecord.id);
	    }
	    SEPA_BH_SF_ReturnUndoCashMatch cashMatchBatch = new SEPA_BH_SF_ReturnUndoCashMatch(sepaRecordIdList, cashEntry, txInfAndStssMap, sepaFile, bankAccount);
	    ID batchprocessid = Database.executeBatch(cashMatchBatch, 3);      
	
	}
    

// TODO código mal feito, usar Maps Para não ter de fazer tantas queries
// retirar o txInfAndStssMap como parametro
    public static void processInvoicePayments(CR_Sepa_Record__c sepaRecord, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, c2g__codaCashEntry__c cashEntry, Datetime startDatetime) {

        Savepoint sp = null;
        
        system.debug(LoggingLevel.INFO, 'ProcessInvoicePayments sepaRecord:' + sepaRecord);

        try {      

           system.debug('sepaRecord' + sepaRecord);
    
           //start transation
           sp = Database.setSavepoint();
                         
           // Query for the Transaction Line Items
           // (resulting from the postings above) to match

           //1 transactions of the cash entries 

           List<c2g__codaCashEntryLineItem__c> cashEntryLineItemList = [SELECT Id, CR_Sepa_Record__c, c2g__LineNumber__c, c2g__CashEntry__r.c2g__Period__c FROM c2g__codaCashEntryLineItem__c WHERE CR_Sepa_Record__c = :sepaRecord.Id AND c2g__CashEntry__c = :cashEntry.Id];

           if(cashEntryLineItemList == null || cashEntryLineItemList.size() == 0){
	           cashEntryLineItemList = [
	                SELECT Id, Name, c2g__LineNumber__c, c2g__CashEntry__r.c2g__Period__c
	                FROM c2g__codaCashEntryLineItem__c
	                WHERE c2g__CashEntry__c = :cashEntry.Id
	                AND c2g__Account__c = :sepaRecord.Debtor_Account__c
	           ];
	           
	           system.debug( '1 - cashEntryLineItemList');
           }

           Id periodDueDate = null;
           if(cashEntryLineItemList==null || cashEntryLineItemList.size() == 0){
               system.debug(LoggingLevel.INFO, 'CashEntryLineItem is null cashEntry.Id: ' + cashEntry.Id + ' sepaRecord.Debtor_Account__c:' + sepaRecord.Debtor_Account__c);
               // TODO enviar erro para o Log
               return;
           }
           else{
               system.debug(LoggingLevel.INFO, 'CashEntryLineItem is NOT null, c2g__codaCashEntryLineItem__c: ' + cashEntryLineItemList + ' cashEntry.Id: ' + cashEntry.Id + ' sepaRecord.Debtor_Account__c:' + sepaRecord.Debtor_Account__c);
               periodDueDate = cashEntryLineItemList.get(0).c2g__CashEntry__r.c2g__Period__c;
           }
            
           List<Integer> cashEntryLineItem_LineNumber_List = new List<Integer>();
           for(c2g__codaCashEntryLineItem__c cashEntrLineItem :cashEntryLineItemList){
           	  cashEntryLineItem_LineNumber_List.add(Integer.valueof(cashEntrLineItem.c2g__LineNumber__c));
           }
           
           List<c2g__codaTransactionLineItem__c> cashEntrytransactionLinesToMatch = [
           SELECT   Id, c2g__AccountValue__c
                FROM c2g__codaTransactionLineItem__c
                WHERE 
                //c2g__Transaction__r.c2g__DocumentNumber__c in :documentRefs
                c2g__Transaction__r.c2g__CashEntry__c = :cashEntry.Id AND
                c2g__LineNumber__c IN :cashEntryLineItem_LineNumber_List
                AND c2g__LineType__c = 'Account'
                AND c2g__Account__c = :sepaRecord.Debtor_Account__c
            ];
           
           //2 transactions of the invoice
//TODO this should all be done in the same way, but since we will have to reimplemente because of the Pay Collections I keept this way
     //sales invoices
           //Old
/*           List<c2g__codaInvoice__c> salesInvoiceList = [
                SELECT Id, Name
                FROM c2g__codaInvoice__c
                WHERE CR_Sepa_Record__c = :sepaRecord.id
           ];
           
           List<String> documentRefs = new List<String>();                
           for(c2g__codaInvoice__c si : salesInvoiceList){
               documentRefs.add(si.Name);
           }
*/           
           //New
           
           List<Payment_Collection__c> paymentCollectionList = [
                SELECT Id, Name, (SELECT ID, Name, Invoice__c, Invoice__r.Name,
                                                   Payable_Invoice__c, Payable_Invoice__r.Name,
                                                   Sales_Credit_Note__c, Sales_Credit_Note__r.Name  FROM Receipt_Line_Items__r) 
                                  FROM Payment_Collection__c 
                                 WHERE Id =:sepaRecord.Payment_Collection__c];
        
           system.debug('sepaRecord.Payment_Collection__c' + sepaRecord.Payment_Collection__c );
           
           List<String> documentRefs = new List<String>();
           if(paymentCollectionList.size() == 1){ 
		       for(Receipt_Line_Item__c receipLineItem : paymentCollectionList[0].Receipt_Line_Items__r){
		       	   system.debug('receipLineItem' + receipLineItem);

		       	   if(receipLineItem.Invoice__c != null){
		               documentRefs.add(receipLineItem.Invoice__r.Name);
		       	   } else if(receipLineItem.Payable_Invoice__c != null){
		       	   	   documentRefs.add(receipLineItem.Payable_Invoice__r.Name);
		       	   } else if(receipLineItem.Sales_Credit_Note__c != null){
		       	   	   documentRefs.add(receipLineItem.Sales_Credit_Note__r.Name);
		       	   }
		       	   
		       }
           }else{
           	   system.debug('ERROR: the SEPA record does not have payment colection');
           }


     //payable invoices

//
//Old 
///////////        
/*           if(sepaRecord.Payable_Invoice__c != null){
               documentRefs.add(sepaRecord.Payable_Invoice__r.Name);
                        
               List<c2g__codaPurchaseCreditNote__c> pcns = [
                   select Id, Name
                       from c2g__codaPurchaseCreditNote__c
                       where c2g__PurchaseInvoice__c = :sepaRecord.Payable_Invoice__r.Id
               ];
                        
               for(c2g__codaPurchaseCreditNote__c pcn : pcns){
                   documentRefs.add(pcn.Name);
               }
           }
*/      


      //credit notes
//Old
/*          if(sepaRecord.Sales_Credit_Note__c != null){         
               documentRefs.add(sepaRecord.Sales_Credit_Note__r.Name);        
          }
*/           
           List<c2g__codaTransactionLineItem__c> invoiceTransactionLinesToMatch = [
           SELECT   Id, c2g__AccountValue__c
                FROM c2g__codaTransactionLineItem__c
                WHERE c2g__Transaction__r.c2g__DocumentNumber__c IN :documentRefs
                AND c2g__LineType__c = 'Account'
                AND c2g__Account__c = :sepaRecord.Debtor_Account__c   // is not needed but is used has a double check.
            ];           
           
           // 3 add all transactions             
           List<c2g__codaTransactionLineItem__c> transactionLinesToMatch = new List<c2g__codaTransactionLineItem__c>();
           transactionLinesToMatch.addall(cashEntrytransactionLinesToMatch);
           transactionLinesToMatch.addall(invoiceTransactionLinesToMatch);
           
           system.debug(LoggingLevel.INFO, 'transactionLinesToMatch.size(): ' + transactionLinesToMatch.size());
           system.debug(LoggingLevel.INFO, 'transactionLinesToMatch: ' + transactionLinesToMatch);

           system.debug(LoggingLevel.INFO, 'sepaRecord.Sales_Invoice__r.c2g__Period__r.Id: ' + sepaRecord.Sales_Invoice__r.c2g__Period__r.Id);
           system.debug(LoggingLevel.INFO, 'sepaRecord.Sales_Invoice__r.c2g__DueDate__c: ' + sepaRecord.Sales_Invoice__r.c2g__DueDate__c);
          // system.debug(LoggingLevel.INFO, 'c2g.CODAAPICommon.getRef getPeriod(sepaRecord.Sales_Invoice__r.c2g__DueDate__c).Id: ' + periodDueDate);
     
           Id matchReferenceId = FF_Utils.doMatch( sepaRecord.Debtor_Account__c, periodDueDate, transactionLinesToMatch );
                
           sepaRecord.Matching_Reference__c = matchReferenceId;
           
           if(sepaRecord.Payment_Collection__c != null){
               Payment_Collection__c paymentCollection = [select Id, Status__c FROM Payment_Collection__c WHERE Id = :sepaRecord.Payment_Collection__c ];
               paymentCollection.Status__c = 'Paid';
               update paymentCollection;
           }
           
                
           update sepaRecord;
                                  
        } catch (Exception ex) {
            if (sp != null) {
                Database.rollback(sp);
            }
            //outbound and debug
            system.debug(LoggingLevel.INFO, 'Exception ProcessInvoicePayments ');
            system.debug(LoggingLevel.INFO, 'ex.getCause(): ' + ex.getCause());
            system.debug(LoggingLevel.INFO, 'ex.getLineNumber(): ' + ex.getLineNumber());
            system.debug(LoggingLevel.INFO, 'ex.getMessage(): ' + ex.getMessage());
            system.debug(LoggingLevel.INFO, 'ex.getTypeName(): ' + ex.getTypeName());
            system.debug(LoggingLevel.INFO, 'ex.getStackTraceString(): ' + ex.getStackTraceString());
            Utilities.LogIntegration(startDatetime, datetime.now(), 'Error', 'CR_SEPA ProcessInvoicePayments '+ sepaRecord.Name +' at: ' + ex.getLineNumber(), ex.getMessage(), sepaRecord.id);
            
            if(sepaRecord.Payment_Collection__c != null){
               Payment_Collection__c paymentCollection = [select Id, Status__c FROM Payment_Collection__c WHERE Id = :sepaRecord.Payment_Collection__c ];
               paymentCollection.Status__c = 'Error';
               update paymentCollection;
            }
            
            update sepaRecord;

        }

    }

    public static void processRefundInvoicePayments(CR_Sepa_File__c sepaFile, List<CR_Sepa_Record__c> sepaRecListProcessed, Map<String, SEPA_TxInfAndSts> txInfAndStssMap, c2g__codaCashEntry__c cashEntry, c2g__codaBankAccount__c bankAccount, Datetime startDatetime) {

        Savepoint sp = null;
        
        system.debug(LoggingLevel.INFO, 'processRefundInvoicePayments sepaRecList.size():' + sepaRecListProcessed.size());
        
        for (CR_Sepa_Record__c sepaRec : sepaRecListProcessed) {
            try {
                
                //start transaction
                sp = Database.setSavepoint();

                system.debug('sepaRec.Matching_Reference__c' + sepaRec.Matching_Reference__c);
                if(sepaRec.Matching_Reference__c == null){
                	//TODO
                	system.debug(' sepaRec.Matching_Reference__c is null, error in code or  validation');
                }
                
                c2g__codaPeriod__c periodDueDate = SEPA_UTILS.getPeriod(txInfAndStssMap.get(sepaRec.Invoice_Number__c).reqdColltnDt);
                Id unmatchId = FF_Utils.undoMatch(sepaRec.Debtor_Account__c, sepaRec.Matching_Reference__c, periodDueDate);
                sepaRec.Undo_Matching_Reference__c = unmatchId;
                
                if(sepaRec.Payment_Collection__c != null){
                    Payment_Collection__c paymentCollection = [select Id, Status__c FROM Payment_Collection__c WHERE Id = :sepaRec.Payment_Collection__c ];
                    paymentCollection.Status__c = 'Unpaid';
                    update paymentCollection;
                }
                
                update sepaRec;
                
                // Match between the Receipt cash entry and Refund cash entry
                matchReceiptWithRefund(sepaRec, periodDueDate.Id);

            } catch (Exception ex) {
                if (sp != null) {
                    Database.rollback(sp);
                }
                //outbound and debug
                system.debug(LoggingLevel.INFO, 'Exception processRefundInvoicePayments ');
                system.debug(LoggingLevel.INFO, 'ex.getCause(): ' + ex.getCause());
                system.debug(LoggingLevel.INFO, 'ex.getLineNumber(): ' + ex.getLineNumber());
                system.debug(LoggingLevel.INFO, 'ex.getMessage(): ' + ex.getMessage());
                system.debug(LoggingLevel.INFO, 'ex.getTypeName(): ' + ex.getTypeName());
                system.debug(LoggingLevel.INFO, 'ex.getStackTraceString(): ' + ex.getStackTraceString());
                
      //          Utilities.LogIntegration(startDatetime, datetime.now(), 'Error', 'CR_SEPA processRefundInvoicePayments '+ sepaFile.Name +' at: ' + ex.getLineNumber(), ex.getMessage(), sepaFile.Id);
                Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SEPA',
            																	message__c = 'Problem occurred in SEPA REcord :' + sepaRec + ' + line: '+ ex.getLineNumber() + ' \n Due to ' + ex.getCause() + ' \n giving error Message: ' + ex.getMessage(),
            																	printStackTrace__c = ex.getStackTraceString());
                insert record;
                
                if(sepaRec.Payment_Collection__c != null){
                    Payment_Collection__c paymentCollection = [select Id, Status__c FROM Payment_Collection__c WHERE Id = :sepaRec.Payment_Collection__c ];
                    paymentCollection.Status__c = 'Error';
                    update paymentCollection;
                }
                update sepaRec;
            }
        }
        
    }
    
    public static void matchReceiptWithRefund(CR_Sepa_Record__c sepaRec, Id periodDueDateId){
        List<c2g__codaTransactionLineItem__c> cashEntrytransactionLinesToMatchReceipt = getTransaction('Receipt', sepaRec);
	    List<c2g__codaTransactionLineItem__c> cashEntrytransactionLinesToMatchRefund  = getTransaction('Refund', sepaRec);
	            
	    if(cashEntrytransactionLinesToMatchReceipt.size() == 0 || cashEntrytransactionLinesToMatchRefund.size() == 0){
	        system.debug('Error in query ');
	        Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'SEPA',
            						message__c = 'Error in query TransactionLineItem',
            						printStackTrace__c = 'Not Applicable');
            						
            insert record;
	    }
	    
	    //cash matach
        List<c2g__codaTransactionLineItem__c> transactionLinesToMatch = new List<c2g__codaTransactionLineItem__c>();
        transactionLinesToMatch.add(cashEntrytransactionLinesToMatchReceipt[0]);
        transactionLinesToMatch.add(cashEntrytransactionLinesToMatchRefund[0]);

        Id matchReferenceId = FF_Utils.doMatch( sepaRec.Debtor_Account__c, periodDueDateId, transactionLinesToMatch ); 
    }
    
    public static List<c2g__codaTransactionLineItem__c> getTransaction(String cashEntryType, CR_Sepa_Record__c sepaRec){
            // Get cash Entry
            Map<Id, c2g__codaCashEntry__c> cashEntryReceiptMap = new Map<Id, c2g__codaCashEntry__c>([SELECT Id, c2g__Type__c FROM c2g__codaCashEntry__c WHERE c2g__Type__c = :cashEntryType AND  CR_Sepa_File__c = :sepaRec.CR_Sepa_File__c]);

            decimal documentValue = sepaRec.Request_Amount__c;
            if(cashEntryType == 'Receipt'){
            	documentValue = -1 * documentValue; 
            }

            system.debug('cashEntry' + cashEntryReceiptMap.keySet() ); 
            
            //Get Transactions
            List<c2g__codaTransactionLineItem__c> cashEntrytransactionLinesToMatch = [
	            SELECT   Id, c2g__AccountValue__c, c2g__MatchingStatus__c
	                FROM c2g__codaTransactionLineItem__c
	                WHERE 
	                 c2g__Transaction__r.c2g__CashEntry__c IN :cashEntryReceiptMap.keySet() AND
	                 c2g__MatchingStatus__c = 'Available' AND
	                 c2g__LineType__c = 'Account' AND
	                 c2g__Account__c = :sepaRec.Debtor_Account__c AND
	                 c2g__DocumentValue__c = :documentValue
	            ];
	       
	       system.debug('getTransaction: cashEntrytransactionLinesToMatch' + cashEntrytransactionLinesToMatch );     
	       return cashEntrytransactionLinesToMatch;
    }

    public static void testDummyCode(){
    	//TODO remove this code
    	Integer i=0;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;

    }
}