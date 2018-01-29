// SEPA SEPA File to XML
// Test class: SEPA_GL_Web_Services_Test

public class SEPA_SF_to_XML {

	public static String generateXMLFromSepaFile(String sepaFileName) {
		
		Datetime startDatetime = Datetime.now();
		
        system.debug(LoggingLevel.INFO, 'SEPA_SF_to_XML generateXMLFomSepaFile '+ startDatetime +' sepaFileName: ' + sepaFileName);
                
        CR_Sepa_File__c sepaFile = [
                Select Id
                , Name
                , SEPA_Category_Purpose__c
                , SEPA_Collection_Date__c
                , SEPA_Initiating_Party_Name__c
                , SEPA_Movement_Type__c
                , SEPA_Our_Bank_SWIFT_BIC__c
                , SEPA_Our_Bank_IBAN__c
                , SEPA_Our_Bank_Private_Identification__c
                , SEPA_Payment_Method__c
                , Request_DateTime__c
                , Request_Records_Count__c
                , Request_Total_Ammount__c
                , Return_DateTime__c
                , Return_Records_Count__c
                , Return_Total_Amount__c
                , SEPA_Service_Type__c
                , SEPA_Tag_xmlns__c
                , SEPA_Tag_xmlns_xsi__c
                FROM CR_Sepa_File__c
                WHERE Name = :sepaFileName
            ];
        
        List<CR_Sepa_Record__c> sepaRecList = [
            Select
            Id
            , Name
            , Document_Due_Date__c
            , Document_Type__c
            , CR_Sepa_File__c
            , Debtor_Account__c
            , Debtor_Name__c
            , Debtor_Account__r.c2g__CODABankIBANNumber__c
            , IBAN__c   // to update with the must recent value
            , IBAN_Old__c
            , Invoice_Number__c
            , Mandate_Date__c
            , Mandate_Identification__c
            , Request_Count__c
            , Request_Amount__c
            , Request_Currency__c
            , Request_DateTime__c
            , Return_Amount__c
            , Return_Currency__c
            , Return_DateTime__c
            , Swift_Bic__c   // to update with the must recent value
            , Debtor_Account__r.c2g__CODABankSWIFTNumber__c
            FROM CR_Sepa_Record__c
            WHERE
            CR_Sepa_File__c = :sepaFile.Id AND Invalid_Record__c = false
        ];
        
        if (sepaRecList.size() == 0) {
            system.debug(LoggingLevel.WARN, 'SEPA_SF_to_XML generateXMLFromSepaFile no CR_Sepa_Record__c for sepaFile.Id: ' + sepaFile.Id + ' sepaFile.Name: ' + sepaFile.Name);
            Utilities.LogIntegration(startDatetime, datetime.now(), 'Warning', 'SEPA_SF_to_XML generateXMLFromSepaFile', 'SEPA_SF_to_XML generateXMLFromSepaFile no CR_Sepa_Record__c for sepaFile.Id: ' + sepaFile.Id + ' sepaFile.Name: ' + sepaFile.Name, sepaFile.Name);
            return null;
        }

        Map<Id, String> acountOldNibsMaps = getOldNibs(sepaRecList);
        
        Dom.Document doc = new Dom.Document();
        Integer debugCounter = 0;
        
        if(sepaFile.SEPA_Movement_Type__c == 'PaymentsVendors' || sepaFile.SEPA_Movement_Type__c == 'Payments' || sepaFile.SEPA_Movement_Type__c == 'SalesCreditNotes'){
        	debugCounter = addPaymentsXMLtoDocument(doc, sepaFile, sepaRecList, startDatetime);
        } else  if(sepaFile.SEPA_Movement_Type__c == 'FRST' || sepaFile.SEPA_Movement_Type__c == 'RCUR') {
        	debugCounter = addDirectDebitXMLtoDocument(doc, sepaFile, sepaRecList, startDatetime, acountOldNibsMaps);
        } else {
        	system.debug(LoggingLevel.ERROR, 'CR_QE_SEPA_GenerateXMLFromSepaRecords SEPA_Movement_Type__c not recognized: ' + sepaFile.SEPA_Movement_Type__c);
            Utilities.LogIntegration(startDatetime, Datetime.now(), 'Error', 'Queueable_GenerateXMLFromSepaRecords', 'CR_QE_SEPA_GenerateXMLFromSepaRecords SEPA_Movement_Type__c not recognized: ' + sepaFile.SEPA_Movement_Type__c, sepaFile.Name);
        }
        
        system.debug(LoggingLevel.INFO, 'sepaRecList.size(): ' + sepaRecList.size());
        
        if (sepaRecList.size() == 0) {
            system.debug(LoggingLevel.INFO, 'generateXMLFromSepaFile no CR_Sepa_Record__c for sepaFile.Id: ' + sepaFile.Id + ' sepaFile.Name: ' + sepaFile.Name);
            Utilities.LogIntegration(startDatetime, datetime.now(), 'Info', 'CR_SEPA generateXMLFromSepaFile', 'generateXMLFromSepaFile no CR_Sepa_Record__c for sepaFile.Id: ' + sepaFile.Id + ' sepaFile.Name: ' + sepaFile.Name, sepaFile.Name);
            return null;
        }
        
        Utilities.LogIntegration(startDatetime, datetime.now(), 'Info', 'CR_SEPA generateXMLFromSepaFile', 'generateXMLFromSepaFile ' + sepaRecList.size() + ' CR_Sepa_Record__c for sepaFile.Id: ' + sepaFile.Id + ' sepaFile.Name: ' + sepaFile.Name, sepaFile.Name);

        //There are no ADC's
	        if(debugCounter == 0){
	            return null;
	        }
	        
	        system.debug(doc.toXmlString());     
	        system.debug(LoggingLevel.INFO, 'Passing toXmlString to Attachment, sepaFile ID:' + sepaFile.ID + ' Name: ' + sepaFile.Name + '_' + String.valueof(sepaFile.SEPA_Collection_Date__c).substring(0,10) + '_' + sepaFile.SEPA_Movement_Type__c + '.xml' ); 
	        
	        Attachment attach = new Attachment(parentId=sepaFile.ID, Name = sepaFile.Name + '_' + String.valueof(sepaFile.SEPA_Collection_Date__c).substring(0,10) + '_' + sepaFile.SEPA_Movement_Type__c + '.xml', body = Blob.valueOf(doc.toXmlString())); //create the attachment object //.substringAfter('<?xml version="1.0" encoding="UTF-8"?>')
	        
	        Savepoint sp = Database.setSavepoint();
	        
	        try{
	            
	            upsert attach; //insert the attachment
	            update sepaFile;
	            update sepaRecList;
	            
	        }catch(Exception ex){            if(sp != null){ Database.rollback(sp);  }
	            //outbound and debug
	            system.debug(LoggingLevel.ERROR, 'Queueable_GenerateXMLFromSepaRecords updates Failed');
	            system.debug(LoggingLevel.ERROR, 'ex.getCause(): ' + ex.getCause());
	            system.debug(LoggingLevel.ERROR, 'ex.getLineNumber(): ' + ex.getLineNumber());
	            system.debug(LoggingLevel.ERROR, 'ex.getMessage(): ' + ex.getMessage());
	            system.debug(LoggingLevel.ERROR, 'ex.getTypeName(): ' + ex.getTypeName());
	            system.debug(LoggingLevel.ERROR, 'ex.getStackTraceString(): ' + ex.getStackTraceString());
	            Utilities.LogIntegration(startDatetime, Datetime.now(), 'Error', 'Queueable_GenerateXMLFromSepaRecords at: ' + ex.getLineNumber(), ex.getMessage(), sepaFile.Name);
	            return null;
	        }
	        
	        system.debug(LoggingLevel.INFO, 'Attachment added, ID: '+ attach.Id); 
	        
	        system.debug(LoggingLevel.INFO, 'sepaFile updated, ID: '+ sepaFile.ID + ' Request_DateTime__c: ' + startDatetime + ' Request_Records_Count__c: ' + sepaFile.Request_Records_Count__c + ' Request_Total_Ammount__c: ' + sepaFile.Request_Total_Ammount__c );
        
        return attach.Id;
    }
    
    private static Map<Id, String> getOldNibs(List<CR_Sepa_Record__c> sepaRecList){
    	
    	List<Id> accountIdList = new List<Id>();
        //key = account Id
        for(CR_Sepa_Record__c sepaRecord : sepaRecList){
        	sepaRecord.IBAN__c = sepaRecord.Debtor_Account__r.c2g__CODABankIBANNumber__c;
        	sepaRecord.Swift_Bic__c = sepaRecord.Debtor_Account__r.c2g__CODABankSWIFTNumber__c;
        	
        	accountIdList.add(sepaRecord.Debtor_Account__c);
        }


        Id sepaFileId = sepaRecList[0].CR_Sepa_File__c;                                                                                    // TODO change later toCreatedDate
        List <Account> accounts = [SELECT Id, (SELECT IBAN__c FROM 	CR_Sepa_Records__r WHERE Request_DateTime__c != null AND Invalid_Record__c = false AND CR_Sepa_File__c != :sepaFileId ORDER BY Document_Due_Date__c DESC NULLS LAST LIMIT 1) FROM Account WHERE Id IN :accountIdList];

        //key = account Id
        Map<Id, String> acountOldNibsMaps = new Map<Id, String>();
        for(Account acc : accounts){
		    if(acc.CR_Sepa_Records__r.size() == 1){
		    	acountOldNibsMaps.put(acc.Id, acc.CR_Sepa_Records__r[0].IBAN__c);
		    }
		}

		//used for manual change of the SEPA
		for(CR_Sepa_Record__c sepaRecord : sepaRecList){
        	if(sepaRecord.IBAN_Old__c != null){
        		if(sepaRecord.IBAN_Old__c != 'Use Original'){
        	        acountOldNibsMaps.put(sepaRecord.Debtor_Account__c, sepaRecord.IBAN_Old__c);
        		}else{
        			acountOldNibsMaps.remove(sepaRecord.Debtor_Account__c);
        		}
        	}
        }
        return acountOldNibsMaps;
    }
    
    
    public static Integer addPaymentsXMLtoDocument(Dom.Document doc, CR_Sepa_File__c sepaFile, List<CR_Sepa_Record__c> sepaRecList, Datetime startDatetime) {
        //sum
        decimal totalValueSum = 0;
        Dom.Xmlnode rootNode = doc.createRootElement('Document', null, null);
        rootNode.setAttribute('xmlns', sepaFile.SEPA_Tag_xmlns__c);
        rootNode.setAttribute('xmlns:xsi', sepaFile.SEPA_Tag_xmlns_xsi__c);
        Dom.Xmlnode CstmrCdtTrfInitn = rootNode.addChildElement('CstmrCdtTrfInitn', null, null);
        Dom.Xmlnode GrpHdr = CstmrCdtTrfInitn.addChildElement('GrpHdr', null, null);
        Dom.Xmlnode MsgId = GrpHdr.addChildElement('MsgId', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaFile.Name));
        Dom.Xmlnode CreDtTm = GrpHdr.addChildElement('CreDtTm', null, null).addTextNode(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        Dom.Xmlnode NbOfTxs = GrpHdr.addChildElement('NbOfTxs', null, null);
        Dom.Xmlnode CtrlSum = GrpHdr.addChildElement('CtrlSum', null, null);
        Dom.Xmlnode InitgPty = GrpHdr.addChildElement('InitgPty', null, null);
        Dom.Xmlnode Nm = InitgPty.addChildElement('Nm', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaFile.SEPA_Initiating_Party_Name__c)); //mudar company name para este
        Dom.Xmlnode Id = InitgPty.addChildElement('Id', null, null);
        Dom.Xmlnode PrvtId = Id.addChildElement('PrvtId', null, null);
        Dom.Xmlnode Othr = PrvtId.addChildElement('Othr', null, null);
        Dom.Xmlnode OthrId = Othr.addChildElement('Id', null, null).addTextNode(sepaFile.SEPA_Our_Bank_Private_Identification__c);
        Dom.Xmlnode PmtInf = CstmrCdtTrfInitn.addChildElement('PmtInf', null, null);
        Dom.Xmlnode PmtInfId = PmtInf.addChildElement('PmtInfId', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaFile.Name));
        Dom.Xmlnode PmtMtd = PmtInf.addChildElement('PmtMtd', null, null).addTextNode(sepaFile.SEPA_Payment_Method__c);
        Dom.Xmlnode PmtInfNbOfTxs = PmtInf.addChildElement('NbOfTxs', null, null);
        Dom.Xmlnode PmtInfIdCtrlSum = PmtInf.addChildElement('CtrlSum', null, null);
        Dom.Xmlnode PmtTpInf = PmtInf.addChildElement('PmtTpInf', null, null);
        Dom.Xmlnode CtgyPurp = PmtTpInf.addChildElement('CtgyPurp', null, null);
        Dom.Xmlnode CtgyPurpCd = CtgyPurp.addChildElement('Cd', null, null).addTextNode(sepaFile.SEPA_Category_Purpose__c);
        //RequestedExecutionDate
        Dom.Xmlnode ReqdExctnDt = PmtInf.addChildElement('ReqdExctnDt', null, null).addTextNode(String.valueOf(sepaFile.SEPA_Collection_Date__c));
        Dom.Xmlnode Dbtr = PmtInf.addChildElement('Dbtr', null, null);
        Dom.Xmlnode DbtrNm = Dbtr.addChildElement('Nm', null, null).addTextNode(sepaFile.SEPA_Initiating_Party_Name__c);
        Dom.Xmlnode DbtrPstlAdr = Dbtr.addChildElement('PstlAdr', null, null);
        Dom.Xmlnode DbtrPstlAdrCtry = DbtrPstlAdr.addChildElement('Ctry', null, null).addTextNode('PT');
        Dom.Xmlnode DbtrPstlAdrAdrLine = DbtrPstlAdr.addChildElement('AdrLine', null, null).addTextNode('Avenida Dom Joao II, 50, 1990-095 Lisboa, Portugal');
        Dom.Xmlnode DbtrAcct = PmtInf.addChildElement('DbtrAcct', null, null);
        Dom.Xmlnode DbtrAcctId = DbtrAcct.addChildElement('Id', null, null);
        Dom.Xmlnode DbtrAcctIdIBAN = DbtrAcctId.addChildElement('IBAN', null, null).addTextNode(sepaFile.SEPA_Our_Bank_IBAN__c);

        Dom.Xmlnode DbtrAgt = PmtInf.addChildElement('DbtrAgt', null, null);
        Dom.Xmlnode FinInstnId = DbtrAgt.addChildElement('FinInstnId', null, null);
        Dom.Xmlnode BIC = FinInstnId.addChildElement('BIC', null, null).addTextNode(sepaFile.SEPA_Our_Bank_SWIFT_BIC__c);
        
        integer debugCounter = 0;
        
        for (CR_Sepa_Record__c sepaRec : sepaRecList) {
            
            system.debug(sepaRec);
            
            Dom.Xmlnode CdtTrfTxInf = null;
            try {
                CdtTrfTxInf = PmtInf.addChildElement('CdtTrfTxInf', null, null);
                Dom.Xmlnode PmtId = CdtTrfTxInf.addChildElement('PmtId', null, null);
                Dom.Xmlnode EndToEndId = PmtId.addChildElement('EndToEndId', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaRec.Invoice_Number__c));
                Dom.Xmlnode Amt = CdtTrfTxInf.addChildElement('Amt', null, null);
                Dom.Xmlnode InstdAmt = Amt.addChildElement('InstdAmt', null, null);
                InstdAmt.setAttribute('Ccy', sepaRec.Request_Currency__c);
                InstdAmt.addTextNode(String.valueOf(sepaRec.Request_Amount__c < 0 ? sepaRec.Request_Amount__c * -1 : sepaRec.Request_Amount__c));
                
                Dom.Xmlnode CdtrAgt = CdtTrfTxInf.addChildElement('CdtrAgt', null, null);
                Dom.Xmlnode CdtrAgtFinInstnId = CdtrAgt.addChildElement('FinInstnId', null, null);
                Dom.Xmlnode CdtrAgtFinInstnIdBIC = CdtrAgtFinInstnId.addChildElement('BIC', null, null).addTextNode(sepaRec.Swift_Bic__c);
                
                Dom.Xmlnode Cdtr = CdtTrfTxInf.addChildElement('Cdtr', null, null);
                Dom.Xmlnode CdtrNm = Cdtr.addChildElement('Nm', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaRec.Debtor_Name__c, Integer.valueOf(CR_CS_SEPA_Config__c.getValues('MAX_LENGHT_SEPA_PARTY_NAME').Value_String__c)));
                                
                Dom.Xmlnode CdtrAcct = CdtTrfTxInf.addChildElement('CdtrAcct', null, null);
                Dom.Xmlnode CdtrAcctId = CdtrAcct.addChildElement('Id', null, null);
                Dom.Xmlnode CdtrAcctIdIBAN = CdtrAcctId.addChildElement('IBAN', null, null).addTextNode(sepaRec.IBAN__c);
                
                Dom.Xmlnode RmtInf = CdtTrfTxInf.addChildElement('RmtInf', null, null);
                Dom.Xmlnode RmtInfUstrd = RmtInf.addChildElement('Ustrd', null, null).addTextNode(
                    sepaFile.SEPA_Movement_Type__c == 'SalesCreditNotes' ? 'Payment for Credit Note: ' + sepaRec.Mandate_Identification__c : 'Payment for Invoice: ' + sepaRec.Mandate_Identification__c
                );
                
                //identify what was generated
                sepaRec.Request_DateTime__c = startDatetime;
                
                debugCounter++;
                totalValueSum += sepaRec.Request_Amount__c;
                
            } catch (Exception e) {
                system.debug(LoggingLevel.WARN, 'Exception CR_SEPA addPaymentsXMLtoDocument:' + e.getStackTraceString());
                if (CdtTrfTxInf != null) {
                    PmtInf.removeChild(CdtTrfTxInf);
                }
            }
        }
        
        NbOfTxs.addTextNode(String.valueOf(debugCounter));
        CtrlSum.addTextNode(String.valueOf(totalValueSum < 0 ? totalValueSum * -1 : totalValueSum));
        PmtInfNbOfTxs.addTextNode(String.valueOf(debugCounter));
        PmtInfIdCtrlSum.addTextNode(String.valueOf(totalValueSum < 0 ? totalValueSum * -1 : totalValueSum));
        
        CacheSepaFileReturn(sepaFile, startDatetime, debugCounter, totalValueSum);
        
        return debugCounter;
    }
    
    
    public static Integer addDirectDebitXMLtoDocument(Dom.Document doc, CR_Sepa_File__c sepaFile, List<CR_Sepa_Record__c> sepaRecList, Datetime startDatetime, Map<Id, String> acountOldNibsMaps) {
        //sum
        decimal totalValueSum = 0;
        Dom.Xmlnode rootNode = doc.createRootElement('Document', null, null);
        rootNode.setAttribute('xmlns', sepaFile.SEPA_Tag_xmlns__c);
        rootNode.setAttribute('xmlns:xsi', sepaFile.SEPA_Tag_xmlns_xsi__c);
        Dom.Xmlnode CstmrDrctDbtInitn = rootNode.addChildElement('CstmrDrctDbtInitn', null, null);
        Dom.Xmlnode GrpHdr = CstmrDrctDbtInitn.addChildElement('GrpHdr', null, null);
        Dom.Xmlnode MsgId = GrpHdr.addChildElement('MsgId', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaFile.Name));
        Dom.Xmlnode CreDtTm = GrpHdr.addChildElement('CreDtTm', null, null).addTextNode(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        Dom.Xmlnode NbOfTxs = GrpHdr.addChildElement('NbOfTxs', null, null);
        Dom.Xmlnode CtrlSum = GrpHdr.addChildElement('CtrlSum', null, null);
        Dom.Xmlnode InitgPty = GrpHdr.addChildElement('InitgPty', null, null);
        Dom.Xmlnode Nm = InitgPty.addChildElement('Nm', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaFile.SEPA_Initiating_Party_Name__c)); //mudar company name para este
        Dom.Xmlnode Id = InitgPty.addChildElement('Id', null, null);
        Dom.Xmlnode PrvtId = Id.addChildElement('PrvtId', null, null);
        Dom.Xmlnode Othr = PrvtId.addChildElement('Othr', null, null);
        Dom.Xmlnode OthrId = Othr.addChildElement('Id', null, null).addTextNode(sepaFile.SEPA_Our_Bank_Private_Identification__c);
        Dom.Xmlnode PmtInf = CstmrDrctDbtInitn.addChildElement('PmtInf', null, null);
        Dom.Xmlnode PmtInfId = PmtInf.addChildElement('PmtInfId', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaFile.Name));
        Dom.Xmlnode PmtMtd = PmtInf.addChildElement('PmtMtd', null, null).addTextNode(sepaFile.SEPA_Payment_Method__c);
        Dom.Xmlnode PmtInfNbOfTxs = PmtInf.addChildElement('NbOfTxs', null, null);
        Dom.Xmlnode PmtInfIdCtrlSum = PmtInf.addChildElement('CtrlSum', null, null);
        Dom.Xmlnode PmtTpInf = PmtInf.addChildElement('PmtTpInf', null, null);
        Dom.Xmlnode LclInstrm = PmtTpInf.addChildElement('LclInstrm', null, null);
        Dom.Xmlnode LclInstrmCd = LclInstrm.addChildElement('Cd', null, null).addTextNode(sepaFile.SEPA_Service_Type__c);
        Dom.Xmlnode SeqTp = PmtTpInf.addChildElement('SeqTp', null, null).addTextNode(sepaFile.SEPA_Movement_Type__c);
        Dom.Xmlnode CtgyPurp = PmtTpInf.addChildElement('CtgyPurp', null, null);
        Dom.Xmlnode CtgyPurpCd = CtgyPurp.addChildElement('Cd', null, null).addTextNode(sepaFile.SEPA_Category_Purpose__c);
        Dom.Xmlnode ReqdColltnDt = PmtInf.addChildElement('ReqdColltnDt', null, null).addTextNode(String.valueOf(sepaFile.SEPA_Collection_Date__c));
        Dom.Xmlnode Cdtr = PmtInf.addChildElement('Cdtr', null, null);
        Dom.Xmlnode CdtrNm = Cdtr.addChildElement('Nm', null, null).addTextNode(sepaFile.SEPA_Initiating_Party_Name__c);
        Dom.Xmlnode CdtrAcct = PmtInf.addChildElement('CdtrAcct', null, null);
        Dom.Xmlnode CdtrAcctId = CdtrAcct.addChildElement('Id', null, null);
        Dom.Xmlnode IBAN = CdtrAcctId.addChildElement('IBAN', null, null).addTextNode(sepaFile.SEPA_Our_Bank_IBAN__c);
        Dom.Xmlnode CdtrAgt = PmtInf.addChildElement('CdtrAgt', null, null);
        Dom.Xmlnode FinInstnId = CdtrAgt.addChildElement('FinInstnId', null, null);
        Dom.Xmlnode BIC = FinInstnId.addChildElement('BIC', null, null).addTextNode(sepaFile.SEPA_Our_Bank_SWIFT_BIC__c);
        Dom.Xmlnode CdtrSchmeId = PmtInf.addChildElement('CdtrSchmeId', null, null);
        Dom.Xmlnode CdtrSchmeIdId = CdtrSchmeId.addChildElement('Id', null, null);
        Dom.Xmlnode CdtrSchmeIdIdPrvtId = CdtrSchmeIdId.addChildElement('PrvtId', null, null);
        Dom.Xmlnode CdtrSchmeIdIdPrvtIdOthr = CdtrSchmeIdIdPrvtId.addChildElement('Othr', null, null);
        Dom.Xmlnode CdtrSchmeIdIdPrvtIdOthrId = CdtrSchmeIdIdPrvtIdOthr.addChildElement('Id', null, null).addTextNode(sepaFile.SEPA_Our_Bank_Private_Identification__c);
        
        integer debugCounter = 0;
        
        for (CR_Sepa_Record__c sepaRec : sepaRecList) {
            
            system.debug(sepaRec);
            Dom.Xmlnode DrctDbtTxInf = null;
            
            try {
                DrctDbtTxInf = PmtInf.addChildElement('DrctDbtTxInf', null, null);
                Dom.Xmlnode PmtId = DrctDbtTxInf.addChildElement('PmtId', null, null);
                Dom.Xmlnode EndToEndId = PmtId.addChildElement('EndToEndId', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaRec.Invoice_Number__c));
                Dom.Xmlnode InstdAmt = DrctDbtTxInf.addChildElement('InstdAmt', null, null);
                InstdAmt.setAttribute('Ccy', sepaRec.Request_Currency__c);
                InstdAmt.addTextNode(String.valueOf(sepaRec.Request_Amount__c));
                Dom.Xmlnode DrctDbtTx = DrctDbtTxInf.addChildElement('DrctDbtTx', null, null);
                Dom.Xmlnode MndtRltdInf = DrctDbtTx.addChildElement('MndtRltdInf', null, null);
                Dom.Xmlnode MndtId = MndtRltdInf.addChildElement('MndtId', null, null).addTextNode(String.valueOf(sepaRec.Mandate_Identification__c));
                Dom.Xmlnode DtOfSgntr = MndtRltdInf.addChildElement('DtOfSgntr', null, null).addTextNode(String.valueOf(sepaRec.Mandate_Date__c));
                
                String oldNib = acountOldNibsMaps.get(sepaRec.Debtor_Account__c);
                boolean nifWasChanged = false;
                if(oldNib != null && oldNib != sepaRec.Debtor_Account__r.c2g__CODABankIBANNumber__c){
                	nifWasChanged = true;
                	sepaRec.IBAN_Old__c = oldNib;
                }

                if(nifWasChanged){
                	Dom.Xmlnode AmdmntInd = MndtRltdInf.addChildElement('AmdmntInd', null, null).addTextNode('true');
                	Dom.Xmlnode amdmntInfDtls = MndtRltdInf.addChildElement('AmdmntInfDtls', null, null);
                	Dom.Xmlnode orgnlDbtrAcct = amdmntInfDtls.addChildElement('OrgnlDbtrAcct', null, null);
                	Dom.Xmlnode id_xml = orgnlDbtrAcct.addChildElement('Id', null, null);
                	//if Same bank not used, but never know...
                	// Dom.Xmlnode iban_xml = id_xml.addChildElement('IBAN', null, null).addTextNode(oldNib);
                	//If diferent bank
                	Dom.Xmlnode othr_NifChange = id_xml.addChildElement('Othr', null, null);
                	Dom.Xmlnode id2_NifChange = othr_NifChange.addChildElement('Id', null, null).addTextNode('SMNDA');
                }else{
                	Dom.Xmlnode AmdmntInd = MndtRltdInf.addChildElement('AmdmntInd', null, null).addTextNode('false');
                }

                Dom.Xmlnode DbtrAgt = DrctDbtTxInf.addChildElement('DbtrAgt', null, null);
                Dom.Xmlnode DbtrAgtFinInstnId = DbtrAgt.addChildElement('FinInstnId', null, null);
                Dom.Xmlnode DbtrAgtFinInstnIdBIC = DbtrAgtFinInstnId.addChildElement('BIC', null, null).addTextNode(sepaRec.Swift_Bic__c);
                Dom.Xmlnode Dbtr = DrctDbtTxInf.addChildElement('Dbtr', null, null);
                Dom.Xmlnode DbtrNm = Dbtr.addChildElement('Nm', null, null).addTextNode(SEPA_UTILS.SepaCharacterCompliance(sepaRec.Debtor_Name__c, Integer.valueOf(CR_CS_SEPA_Config__c.getValues('MAX_LENGHT_SEPA_PARTY_NAME').Value_String__c)));
                Dom.Xmlnode DbtrAcct = DrctDbtTxInf.addChildElement('DbtrAcct', null, null);
                Dom.Xmlnode DbtrAcctId = DbtrAcct.addChildElement('Id', null, null);
                Dom.Xmlnode DbtrAcctIdIBAN = DbtrAcctId.addChildElement('IBAN', null, null).addTextNode(sepaRec.IBAN__c);
                
                //identify what was generated
                sepaRec.Request_DateTime__c = startDatetime;
                //                system.debug(LoggingLevel.INFO, 'CR_SEPA addPaymentsXMLtoDocument sepaRec.Request_DateTime__c:' + sepaRec.Request_DateTime__c);  
                
                debugCounter++;
                totalValueSum += sepaRec.Request_Amount__c;
                
            } catch (Exception e) {
                system.debug(LoggingLevel.INFO, 'Exception CR_SEPA addPaymentsXMLtoDocument:' + e.getStackTraceString());
                if (DrctDbtTxInf != null) {
                    PmtInf.removeChild(DrctDbtTxInf);
                }
            }
        }
        
        NbOfTxs.addTextNode(String.valueOf(debugCounter));
        CtrlSum.addTextNode(String.valueOf(totalValueSum));
        PmtInfNbOfTxs.addTextNode(String.valueOf(debugCounter));
        PmtInfIdCtrlSum.addTextNode(String.valueOf(totalValueSum));
        
        CacheSepaFileReturn(sepaFile, startDatetime, debugCounter, totalValueSum);
        return debugCounter;
    }

    public static void CacheSepaFileReturn(CR_Sepa_File__c sepaFile, Datetime startDatetime, integer debugCounter, decimal totalValueSum) {
        
        sepaFile.Request_DateTime__c = startDatetime;
        
        if (sepaFile.Request_Records_Count__c != null) {
            sepaFile.Request_Records_Count__c += debugCounter;
        } else {
            sepaFile.Request_Records_Count__c = debugCounter;
        }
        if (sepaFile.Request_Total_Ammount__c != null) {
            sepaFile.Request_Total_Ammount__c += totalValueSum;
        } else {
            sepaFile.Request_Total_Ammount__c = totalValueSum;
        }
        
        system.debug(LoggingLevel.INFO, 'sepaFile.Name: ' + sepaFile.Name);
        system.debug(LoggingLevel.INFO, 'sepaFile.Request_DateTime__c: ' + sepaFile.Request_DateTime__c);
        system.debug(LoggingLevel.INFO, 'sepaFile.Request_Records_Count__c: ' + sepaFile.Request_Records_Count__c);
        system.debug(LoggingLevel.INFO, 'sepaFile.Request_Total_Ammount__c: ' + sepaFile.Request_Total_Ammount__c);
    }
}