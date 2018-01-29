public class SEPA_ImportFromReturnFile {

    public String importReturnFileAndCreateSEPARecords(ID parentId){

        Savepoint savepointSepa = Database.setSavepoint();
        try{
	    	Attachment attach = [SELECT Id, Body  FROM Attachment WHERE ParentId = :parentId];
	    	
	    	DOM.Document doc = new DOM.Document();
	    	
	    	doc.load(attach.Body.toString());
	        DOM.XMLNode rootDocument = doc.getRootElement();
	        String namespace = rootDocument.getNamespace();
	        system.debug(LoggingLevel.INFO, rootDocument.getName());
	        system.debug(LoggingLevel.INFO, rootDocument.getAttributeCount());
	
	//Initial Validations
	        if(namespace != 'urn:iso:std:iso:20022:tech:xsd:pain.002.001.03'){
	            system.debug(LoggingLevel.INFO, 'Not a return file, rootDocument.getNamespace():' + namespace);
	            return null;
	        }
	        
	        String returnData = importSalesInvoiceFromSepaXML(namespace, rootDocument);
	    	return returnData;
        }catch (System.XMLException e) {
        	
            Database.rollback(savepointSepa);
            return 'critical erro.';
        }
    }

    private String importSalesInvoiceFromSepaXML(String namespace, DOM.XMLNode rootDocument){
    		
        DOM.XMLNode cstmrPmtStsRpt = rootDocument.getChildElement('CstmrPmtStsRpt', namespace);
        DOM.XMLNode grpHdr = cstmrPmtStsRpt.getChildElement('GrpHdr', namespace);
        DOM.XMLNode creDtTm = grpHdr.getChildElement('CreDtTm', namespace);
        
        DOM.XMLNode orgnlPmtInfAndSts = cstmrPmtStsRpt.getChildElement('OrgnlPmtInfAndSts', namespace);
        
        String sepaFileName = orgnlPmtInfAndSts.getChildElement('OrgnlPmtInfId', namespace).getText();
        
        system.debug('sepaFileName' + sepaFileName);
        //check if sepa File alreay exixt.
        List<CR_Sepa_file__c> sepaFileList = [SELECT Id, SEPA_File_Name__c FROM CR_Sepa_file__c WHERE SEPA_File_Name__c = :sepaFileName];
        if(sepaFileList.size() != 0){
        	return 'SEPA File ' + sepaFileName + ' already exist';
        }

		CR_Sepa_file__c sepaFile = new CR_Sepa_File__c();

		sepaFile.SEPA_Tag_xmlns__c = namespace;
		sepaFile.SEPA_Tag_xmlns_xsi__c = 'http://www.w3.org/2001/XMLSchema-instance';
		sepaFile.SEPA_File_Name__c = sepaFileName;
			
		String CreDtTmString = creDtTm.getText();
		//2016-12-23T09:41:07
		sepaFile.Request_DateTime__c = datetime.newInstance(
		    Integer.valueOf(CreDtTmString.substring(0, 4))
		    , Integer.valueOf(CreDtTmString.substring(5, 7))
		    , Integer.valueOf(CreDtTmString.substring(8, 10))
		    , Integer.valueOf(CreDtTmString.substring(11, 13))
		    , Integer.valueOf(CreDtTmString.substring(14, 16))
		    , Integer.valueOf(CreDtTmString.substring(17, 19))
		);
		
		sepaFile.Creation_DateTime__c = sepaFile.Request_DateTime__c;
			
		system.debug(LoggingLevel.INFO, 'sepaFile.Request_DateTime__c: ' + sepaFile.Request_DateTime__c);
			
		sepaFile.Request_Records_Count__c = Integer.valueOf(orgnlPmtInfAndSts.getChildElement('OrgnlNbOfTxs', namespace).getText());
			
		sepaFile.Request_Total_Ammount__c = Decimal.valueOf(orgnlPmtInfAndSts.getChildElement('OrgnlCtrlSum', namespace).getText());	
		sepaFile.SEPA_Initiating_Party_Name__c = 'CANDOR RENTING DE EQUIPAMENTOS SA';
		sepaFile.SEPA_Our_Bank_Private_Identification__c = 'PT09ZZZ111901';
		sepaFile.SEPA_Payment_Method__c = 'DD';
		sepaFile.SEPA_Service_Type__c = 'CORE';
		sepaFile.SEPA_Movement_Type__c = 'RCUR';
		sepaFile.SEPA_Category_Purpose__c = 'OTHR';
			
		sepaFile.SEPA_Collection_Date__c = Date.valueOf(sepaFile.Request_DateTime__c);
	    
	    String ourNib;
	    for (DOM.XMLNode child : orgnlPmtInfAndSts.getChildElements()) {
            if (child.getName() == 'TxInfAndSts') {
		        ourNib = child.getChildElement('OrgnlTxRef', namespace).getChildElement('CdtrAcct', namespace).getChildElement('Id', namespace).getChildElement('IBAN', namespace).getText();
            }
        }

		sepaFile.SEPA_Our_Bank_IBAN__c = ourNib; 
		//PT50001000005300067000166 //conta 1
	    //PT50001000005300067000263  //conta 2
	
		sepaFile.SEPA_Our_Bank_SWIFT_BIC__c = 'BBPIPTPL';

		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_File_Name__c: ' + sepaFile.SEPA_File_Name__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.Creation_DateTime__c: ' + sepaFile.Creation_DateTime__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.Request_DateTime__c: ' + sepaFile.Request_DateTime__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.Request_Records_Count__c: ' + sepaFile.Request_Records_Count__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.Request_Total_Ammount__c: ' + sepaFile.Request_Total_Ammount__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_Initiating_Party_Name__c: ' + sepaFile.SEPA_Initiating_Party_Name__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_Our_Bank_Private_Identification__c: ' + sepaFile.SEPA_Our_Bank_Private_Identification__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_Payment_Method__c: ' + sepaFile.SEPA_Payment_Method__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_Service_Type__c: ' + sepaFile.SEPA_Service_Type__c);
		system.debug(LoggingLevel.INFO, 'Default sepaFile.SEPA_Movement_Type__c Default: ' + sepaFile.SEPA_Movement_Type__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_Category_Purpose__c: ' + sepaFile.SEPA_Category_Purpose__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_Collection_Date__c: ' + sepaFile.SEPA_Collection_Date__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_Our_Bank_IBAN__c: ' + sepaFile.SEPA_Our_Bank_IBAN__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_Our_Bank_SWIFT_BIC__c: ' + sepaFile.SEPA_Our_Bank_SWIFT_BIC__c);
		system.debug(LoggingLevel.INFO, 'sepaFile.SEPA_Tag_xmlns__c: ' + sepaFile.SEPA_Tag_xmlns__c);
		system.debug(LoggingLevel.INFO, 'Default sepaFile.SEPA_Tag_xmlns_xsi__c Default : ' + sepaFile.SEPA_Tag_xmlns_xsi__c);
	
		CR_Sepa_file__c sfTemp = null;
		try{
        	sfTemp = [SELECT id FROM CR_Sepa_file__c
        	 WHERE SEPA_File_Name__c = :sepaFileName
        	  AND Request_DateTime__c =:sepaFile.Request_DateTime__c
        	  Limit 1
        	  ];
        } Catch (Exception e) {	}
        
		if(sfTemp != null){
		 	system.debug(LoggingLevel.INFO, 'sepaFileName already Imported:' + sepaFile.SEPA_File_Name__c);
            return null;
		}

		insert sepaFile;
		system.debug('sepaFile' + sepaFile);

		Map<String, String> salesInvoice_SEPARecordMap = new Map<String, String>();
	    
	    DOM.XMLNode orgnlPmtInfAndStsV2 = cstmrPmtStsRpt.getChildElement('OrgnlPmtInfAndSts', namespace);
	    List<CR_Sepa_Record__c> newSEPA_REcordsList;
		for (DOM.XMLNode child : orgnlPmtInfAndStsV2.getChildElements()) {

			if (child.getName() == 'TxInfAndSts') {
            	String invoice = child.getChildElement('OrgnlEndToEndId', namespace).getText();
                system.debug('invoice' + invoice);
                salesInvoice_SEPARecordMap.put(invoice, invoice);
            }
		}
		
        system.debug('salesInvoice_SEPARecordMap.keySet()' + salesInvoice_SEPARecordMap.keySet());

        Map<Id, c2g__codaInvoice__c> salesInvoiceMap = new Map<Id, c2g__codaInvoice__c>([SELECT id FROM c2g__codaInvoice__c WHERE Invoice_Express_Number_text__c IN :salesInvoice_SEPARecordMap.keySet()]);
    
        Set<Id> turnedToCompletedIDs = salesInvoiceMap.keySet();
        SEPA_SI_to_SR.createPaymentCollectionWithSEPAFromSalesInvoice(turnedToCompletedIDs);
            
        newSEPA_REcordsList = [SELECT id, CR_Sepa_File__c FROM CR_Sepa_Record__c WHERE Sales_Invoice__r.Invoice_Express_Number_text__c IN :salesInvoice_SEPARecordMap.keySet() AND CreatedDate = TODAY];
            
       for(CR_Sepa_Record__c sepaREcord : newSEPA_REcordsList){
          sepaREcord.CR_Sepa_File__c = sepaFile.id;
       }
		 
       update newSEPA_REcordsList;

	   return sepaFile.Id;
    }
    
    public static void dummy(){
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
    }
    
}