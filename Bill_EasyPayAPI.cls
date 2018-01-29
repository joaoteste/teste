/**
 * This class allows the system to:
 * 1) Connect to EasyPay - DONE - TESTED
 * 2) From time to time change the (MB Payment Status) from AtmReferences - DONE - TESTED
 * 3) Create a journal to register the money entry and exit - DONE - TESTED
 * 4) Do a cash-matching to Pay off the debt - DONE - TESTED
 */  
public class Bill_EasyPayAPI {
    
    private static Bill_EasyPayAPI instance = null;
    private static Account easyPayAccount = [SELECT Id FROM Account WHERE Name = 'EASYPAY - INSTITUIÇÃO DE PAGAMENTO, LDA' LIMIT 1];  
    private static ID period = getPeriod();

    private String companyId; // should be changed to a custom setting
    private String endpointStart;
    private String s_code;
    private String s_codeMoloni;
    private String ep_cin;
    private String ep_cinMoloni;
    private String ep_user;
    private String ep_entity;
    private String ep_entityValidity;
    private String ep_cinValidity;
    private String STATUS_OK = 'ok0';
    
    //constructor 
    public Bill_EasyPayAPI(){

       Credentials__c credential = Credentials__c.getInstance('EasyPay');
	   Credentials__c credentialMoloni = Credentials__c.getInstance('EasyPayMoloni');
	   Credentials__c credentialValidity = Credentials__c.getInstance('EasyPay 11683');
       system.debug(credential);
       system.debug(this.s_code);
       
       //test production
       if(!Utilities.runningInASandbox()){   
           this.endpointStart = credential.Web_Service_Url__c;
           this.s_code = credential.client_secret_code__c; 
           this.s_codeMoloni = credentialMoloni.client_secret_code__c;
           this.ep_cin = credential.cin__c;
           this.ep_cinMoloni = credentialMoloni.cin__c;
           this.ep_cinValidity = credentialValidity.cin__c;
           this.ep_entityValidity = credentialValidity.AccountID__c;
           this.ep_user = credential.Username__c;
           this.ep_entity = credential.AccountID__c;
       }
        //test http://test.easypay.pt/
        else{
           this.endpointStart = credential.Web_Service_Url_TEST_ENVIRONMENT__c;  
           this.s_code = credential.client_secret_code_TEST_ENVIRONMENT__c; 
           this.s_codeMoloni = credentialMoloni.client_secret_code_TEST_ENVIRONMENT__c;
           this.ep_cinMoloni = credentialMoloni.cin__C;
           this.ep_cin = credential.cin__c;
           this.ep_user = credential.Username__c;
           this.ep_entity = credential.AccountID__c; 
       }
        
    }
    
    //Connects to easypay and creates a new Reference
    public ATM_Reference__c getNewMBReference(String amount, Date limitDate, ID externalId, String typeD, String obs){
    	
    	return getNewMBReference(amount, limitDate, externalId, obs);
    }   
    
 //Connects to easypay and creates a new Reference
    public ATM_Reference__c getNewMBReference(String amount, Date limitDate, ID externalId, String obs){
        Datetime startreq = datetime.now();
                 
        System.debug('getNewMBReference'); 
        
        String cin;
        String entity;
        
        if(!Utilities.runningInASandbox() ){
          cin = ep_cinValidity;
          entity = ep_entityValidity;
        }else{
          cin = ep_cin;
          entity = ep_entity;          
        }
        
        String dateSalesforceFormat = limitDate.format();
        String dateEasypay = Datetime.newInstance(limitDate.year(),limitDate.month(),limitDate.day()).format('yyyy-MM-dd','Europe/Dublin');

        String endpoint = endpointStart + '_s/api_easypay_01BG.php?';
        String ep_ref_type = 'auto';
        String ep_country = 'PT';
        String ep_language = 'PT';
        String ep_partner = ep_user;
        String t_value = amount;
        String o_max_date = dateEasypay;
        String t_key;
        if(externalId != null){
              t_key =  externalId; //Salesforce ID 
        }
    
        String o_obs = obs; //Example, Aplication number, Invoice Number, Dunning Alert etc
         
        endpoint+='s_code='+ s_code +'&';
        endpoint+='ep_cin='+ cin +'&';
        endpoint+='ep_user='+ep_user +'&';
        endpoint+='ep_entity='+entity +'&';
        endpoint+='ep_ref_type='+ep_ref_type +'&';
        endpoint+='ep_country='+ep_country +'&';
        endpoint+='ep_language='+ep_language +'&';
        endpoint+='t_value='+t_value +'&';
        endpoint+='t_key='+t_key +'&';
        endpoint+='o_obs='+o_obs +'&';
        
        if(!Utilities.runningInASandbox()){
          endpoint+= 'o_max_date='+dateEasypay+'&';
          endpoint+= 'ep_partner='+ep_user+'&';
        }
        
    	//cannot make a callout after a post, this is just for testing purposes
        HTTPResponse res;
        if(!Test.isRunningTest()){ 
          res= Rest_Utils.sendGet(endpoint);
        }else{
          res = getMBFake();
        }
        system.debug(res);
        
        if(res == null){
            return null;
        }
        //Process response
        Dom.Document doc = res.getBodyDocument();
        
        //Retrieve the root element for this document.
        Dom.XMLNode address = doc.getRootElement();
        
        String ep_statusRec = address.getChildElement('ep_status', null).getText();
        String ep_cinRec = address.getChildElement('ep_cin', null).getText();
        String ep_referenceRec = address.getChildElement('ep_reference', null).getText();
        // print out specific elements
        System.debug('ep_statusRec: ' + ep_statusRec);
        System.debug('ep_cinRec: ' + ep_cinRec);
        System.debug('ep_referenceRec: ' + ep_referenceRec);
        
        if(ep_statusRec != STATUS_OK){
            System.debug('ERROR: ' + ep_statusRec);
            return null;
        }
      
        ATM_Reference__c atmRef = new ATM_Reference__c();
        atmRef.Entity__c = Integer.valueOf(entity);
        atmRef.MB_Reference__c = Integer.valueOf(ep_referenceRec);
        atmRef.Amount__c =  decimal.valueOf(amount);
        atmRef.Create_Date__c = system.today();
        atmRef.Expiry_date__c = limitDate;
        atmRef.ATM_Reference__c = ep_referenceRec;
        if(externalID != null && String.ValueOf(externalID.getSObjectType()) == 'Dunning_Alert__c')
          atmRef.Dunning_Alert__c = externalId;

        
        //insert atmRef;

        return atmRef;
    }
    
    
    //get all getchMBPayments from 5 days ago that are not processed
    public void getFetchMBPaymentsFixedTime(){
        getFetchMBPayments(System.today()-5);
    }
    
    private  Map<Integer, EasyPayPojo> createMap(HTTPResponse res){
        if(res == null) return null;
        Map<Integer, EasyPayPojo> easyPayMap = new Map<Integer, EasyPayPojo>();
            //Process response
            String docDecoded = toAnsi(res.getBody());
            Dom.Document doc = new Dom.Document();
            system.debug(docDecoded);
            doc.load(docDecoded);
            
            //Retrieve the root element for this document.
            Dom.XMLNode rootXml = doc.getRootElement();
            
            String ep_status = rootXml.getChildElement('ep_status', null).getText();
            String ep_messageA = rootXml.getChildElement('ep_message', null).getText();
            if(ep_messageA.contains('query_with_no_records')){
                System.debug('ep_messageA:  ' + ep_messageA);
                return null;
            }
            String ep_num_recordsA = rootXml.getChildElement('ep_num_records', null).getText();
            
            // print out specific elements
            System.debug('ep_status: ' + ep_status);
            System.debug('ep_messageA: ' + ep_messageA);
            System.debug('ep_num_recordsA: ' + ep_num_recordsA);
            
            if(ep_status != STATUS_OK){
                System.debug('Error in getNewMBReference: ' + ep_messageA);
                return null;
            }
           
            // Alternatively, loop through the child elements.
            // This prints out all the elements of the address
            for(Dom.XMLNode child : rootXml.getChildElements()) {
               System.debug(child.getText());
               System.debug(child.getName());
               System.debug(child.getNamespace());
            }
            
            Dom.XMLNode ref_detailXML = rootXml.getChildElement('ref_detail', null);
            for(Dom.XMLNode child1 : ref_detailXML.getChildren()) {
            	String reference = child1.getChildElement('ep_reference', null).getText();        	
	                EasyPayPojo easyPayAux = new EasyPayPojo();
	                easyPayAux.ep_reference =  Integer.valueOf(reference);
	                easyPayAux.ep_entity = child1.getChildElement('ep_entity', null).getText();
	                easyPayAux.ep_value = child1.getChildElement('ep_value', null).getText();
	                easyPayAux.ep_pay_date = date.valueOf( child1.getChildElement('ep_date_transf', null).getText() );
	                easyPayMap.put(easyPayAux.ep_reference , easyPayAux);
            }
            
            Integer i = 0;
            for(EasyPayPojo aux : easyPayMap.values() ) {
                System.debug('EasyPayPojo' + i);
                System.debug(aux.ep_reference);
                System.debug(aux.ep_entity);
                System.debug(aux.ep_date_transf);
                i++;
            }
        return easyPayMap;
    }
    
    private String createEndpoint(String endpoint, String code, Date timeDay, String cin, String entity){
        
        String o_list_type = 'date';
        String o_ini = String.valueOf(timeDay);
        String  o_last = String.valueOf(system.today());
    
        endpoint+='s_code='+ code +'&';
        endpoint+='ep_cin='+ cin +'&';
        endpoint+='ep_user='+ep_user +'&';
        endpoint+='ep_entity='+ entity +'&';
        endpoint+='o_list_type='+o_list_type +'&';
        endpoint+='o_ini='+o_ini +'&'; 
        endpoint+='o_last='+o_last +'&'; 
		
        System.debug(endpoint);
		return endpoint;        
    } 


    //Fetch all payments
    public void getFetchMBPayments(Date timeDay){ 
        
		System.debug('getNewMBReference');
    
        String endpoint = endpointStart + '_s/api_easypay_040BG1.php?';
    	String endpointMoloni = endpointStart + '_s/api_easypay_040BG1.php?';
    	String endpointValidity = endpointStart + '_s/api_easypay_040BG1.php?';
    
        endpoint = createEndpoint(endpoint, s_code, timeDay, ep_cin, ep_entity);      
        endpointMoloni = createEndpoint(endpointMoloni, s_codeMoloni, timeDay, ep_cinMoloni, ep_entity);   
        endpointMoloni+= 'ep_partner=MOLO160615&s_auth=client&';    
        
        endpointValidity = createEndpoint(endpointValidity, s_code, timeDay, ep_cinValidity, ep_entityValidity);  
        
        System.debug(endpoint);
        System.debug(endpointMoloni);
        System.debug(endpointValidity);  
        
        HTTPResponse res;
        HTTPResponse resMoloni;    
        HTTPResponse resValidity;        
        
        if(Test.isRunningTest()){
            res = getFakeAnswser();
        	resMoloni = getFakeAnswserMoloni();
        	//resValidity = getFakeAnswser(); 
        }
        else{  
            res = Rest_Utils.sendGet(endpoint);
            resMoloni = Rest_Utils.sendGet(endpointMoloni);
            resValidity = Rest_Utils.sendGet(endpointValidity);
        }

        Savepoint sp = Database.setSavepoint();	        
        
        try{
            
            Map<Integer, EasyPayPojo> easyPayMap = createMap(res);
            system.debug(easyPayMap);
            
            Map<Integer, EasyPayPojo> easyPayMoloniMap = createMap(resMoloni); 
            system.debug(easyPayMoloniMap);
            
            Map<Integer, EasyPayPojo> easyPayValidityMap = createMap(resValidity);
            system.debug(easyPayValidityMap);            
            
            //query database to get all references not payed
            List<ATM_Reference__c> atmList = [SELECT id, Name, MB_Reference__c, Payment_Collection__c, MB_Payment_Status__c, Amount__c, Dunning_Alert__c, Dunning_Alert__r.Collection_Case__c, Dunning_Alert__r.Id FROM ATM_Reference__c WHERE MB_Payment_Status__c = 'Not Payed'];        
            system.debug(atmList);
            
            //if exists some paid atm => create journals and do cash match
            if( easyPayMap != null || easyPayMoloniMap != null || easyPayValidityMap != null){
                
                //atmRef ID => Lista<(SI, Double)> 
                Map<ID,List<Map<c2g__codaInvoice__c, Double>>> atmToSalesMap = new Map<ID,List<Map<c2g__codaInvoice__c, Double>>>();
                Map<ID,List<Map<c2g__codaInvoice__c, Double>>> atmToSalesMoloniMap = new Map<ID,List<Map<c2g__codaInvoice__c, Double>>>();
                Map<ID,List<Map<c2g__codaInvoice__c, Double>>> atmToSalesValidityMap = new Map<ID,List<Map<c2g__codaInvoice__c, Double>>>();  

                List<ATM_Reference__c> payedATMList;
                List<ATM_Reference__c> payedATMMoloniList;
                List<ATM_Reference__c> payedATMValidityList;                
                
            	if(easyPayMap  != null){      
                    payedATMList = changeReference(atmList, easyPayMap);
                    if(!payedATMList.isEmpty()){
                        //(AtmReference ID, List<Sales Invoice>)
                        getSalesInvoiceFromPaymentCollection(payedATMList, atmToSalesMap);
                    }      
                }
                          
                
          		if(easyPayMoloniMap != null){
                    payedATMMoloniList = changeReference(atmList, easyPayMoloniMap);
                    system.debug(payedATMMoloniList);  
                    if(!payedATMMoloniList.isEmpty()){
                        //(AtmReference ID, List<Sales Invoice>)
                        getSalesInvoiceFromPaymentCollection(payedATMMoloniList, atmToSalesMoloniMap);
                        system.debug(atmToSalesMoloniMap);  
                        if(payedATMList==null)
                        	payedATMList = new List<ATM_Reference__c>();
                        payedATMList.addAll(payedATMMoloniList);
                    }
                }
                
                system.debug(payedATMList);
                system.debug(atmToSalesMap);
                system.debug(atmToSalesMoloniMap);                
                joinMaps(atmToSalesMap, atmToSalesMoloniMap); 	
                system.debug(atmToSalesMap);
                
            	if(easyPayValidityMap  != null){      
                    payedATMValidityList = changeReference(atmList, easyPayValidityMap);
                    if(!payedATMValidityList.isEmpty()){
                        //(AtmReference ID, List<Sales Invoice>)
                        getSalesInvoiceFromPaymentCollection(payedATMValidityList, atmToSalesValidityMap);
                        system.debug(atmToSalesValidityMap);
						if(payedATMList==null)
                        	payedATMList = new List<ATM_Reference__c>();
                        payedATMList.addAll(payedATMValidityList);                        
                    }      
                }                

			    joinMaps(atmToSalesMap, atmToSalesValidityMap);                
                //(AtmReference ID, Journal)
                if(payedATMList != null && !payedATMList.isEmpty()){
                    Map<ID, c2g__codaJournal__c> atmToJournalsMap = createJournals(atmToSalesMap,payedATMList);
                    system.debug(atmToJournalsMap);  
                    
                    Bill_EasyPay_Batch postAndCashMatchBatch = new Bill_EasyPay_Batch(atmToSalesMap,atmToJournalsMap, period, easyPayAccount);
                    
                    ID batchprocessid = Database.executeBatch(postAndCashMatchBatch, 1);
                }
                
            }
        }catch(Exception e){ 
        	Database.rollback(sp);
            //an email is sent after the outbound integration log is created
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c();
            record.Start__c=system.today();
            record.Code__c = 'CRITICAL';
            record.ApplicationID__c = 'EASYPAY';
            record.message__c = e.getMessage();
            record.printStackTrace__c = e.getStackTraceString();
            system.debug('CRITICAL: '+ record);
            system.debug(e.getStackTraceString());
            insert record;
        }
    }
    
    /***************************************************************************************/
    /*																					   */
 	/*	         						ATM References Code      	      				   */
    /*																					   */
    /***************************************************************************************/
    
    //changes the reference of all atmList that is present on the map return by EasyPay 
    public static List<ATM_Reference__c> changeReference(List<ATM_Reference__c> atmList, Map<Integer, EasyPayPojo> easyPayMap){
        
        List<ATM_Reference__c> atmToUpdateList = new List<ATM_Reference__c>();
        for(ATM_Reference__c atmRef : atmList){
            EasyPayPojo easyPay = easyPayMap.get(Integer.valueOf(atmRef.MB_Reference__c));
            //if atm was paid
            if(easyPay != null && atmRef.Amount__c == Double.valueOf(easyPay.ep_value)){
                //update atmReference with new states
                atmRef.MB_Payment_Status__c = 'Paid';
                atmRef.Pay_date__c = easyPay.ep_date_transf;
                atmRef.Transferency_Date__c = easyPay.ep_pay_date;
                atmToUpdateList.add(atmRef);
            }
        }
        
        update atmToUpdateList;
        return atmToUpdateList;
	}
    

    /***************************************************************************************/
    /*																					   */
 	/*	         				Journals/Finantial Force Code     	      				   */
    /*																					   */
    /***************************************************************************************/
    
    //main method to create journals and journal line items
    public Map<ID, c2g__codaJournal__c> createJournals(Map<ID,List<Map<c2g__codaInvoice__c, Double>>> atmToSalesMap, List<ATM_Reference__c> atmList){

        //(AtmReference ID, Journal)
        Map<ID, c2g__codaJournal__c> allJournalsMap = new Map<ID,c2g__codaJournal__c>();
         
        //create for every atm reference paid one journal 
        insertJournals(atmList, allJournalsMap, atmToSalesMap);        
        
        //associate each journal to its journal line items
        insertJournalLineItems(atmList, allJournalsMap, atmToSalesMap);
         
        return allJournalsMap;

    }
    
    //creates journals and inserts into database; atmReference is the reference of the journal
    private void insertJournals(List<ATM_Reference__c> atmList, Map<ID, c2g__codaJournal__c> allJournalsMap, Map<ID,List<Map<c2g__codaInvoice__c, Double>>> atmToSalesMap){
        system.debug(period);
        
         for(ATM_Reference__c atmRef : atmList){            
                //create journal 
                	system.debug(atmRef + ' id:'+ atmRef.Id);
                    c2g__codaJournal__c journal = new c2g__codaJournal__c();
                    journal.c2g__Type__c = 'Manual Journal';
                    journal.c2g__JournalDate__c = System.today();
                    journal.c2g__DeriveCurrency__c = true;
                    journal.c2g__DerivePeriod__c = false;
                	journal.c2g__Reference__c = atmRef.Name;
             		system.debug('atmRef:'+atmRef.Id);
          			c2g__codaInvoice__c salesInvoiceFromAtmRef = (new List<c2g__codaInvoice__c>(atmToSalesMap.get(atmRef.Id).get(0).keySet())).get(0);
             		system.debug('salesInvoice:'+salesInvoiceFromAtmRef);
             		String apName = salesInvoiceFromAtmRef.Application__r.Name;
             		if(apName!=null){ 
                    	journal.c2g__JournalDescription__c = 'EASYPAY Collection Confirmation: '+ apName;
                    }
                     else{
                     	journal.c2g__JournalDescription__c = 'EASYPAY Collection Confirmation: No AP Defined';    
                    }
             		journal.c2g__Period__c = period;
                        
                //insert into Map
                allJournalsMap.put(atmRef.Id,journal);
       } 
        
		system.debug(allJournalsMap.values());
       
		//inserts all journals into database
		insert allJournalsMap.values();
    }
    
    //creates and inserts journal line items to every journal created
    private void insertJournalLineItems(List<ATM_Reference__c> atmList, Map<ID, c2g__codaJournal__c> allJournalsMap, Map<ID,List<Map<c2g__codaInvoice__c, Double>>> atmToSalesMap){
        
        c2g__codaGeneralLedgerAccount__c clientesNacionais = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name = '21111 - CLIENTES NACIONAIS' LIMIT 1];  
        c2g__codaGeneralLedgerAccount__c outrosDevedores = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name = '2781 - OUTROS DEVEDORES' LIMIT 1];  
        List<c2g__codaJournalLineItem__c> allJournalLineItemsList = new List<c2g__codaJournalLineItem__c>();
        
        for(ATM_Reference__c atmRef : atmList){
            
            //get journal to associate to it's journalLineItems
            c2g__codaJournal__c journal = allJournalsMap.get(atmRef.Id);
            c2g__codaInvoice__c salesInvoice = (new List<c2g__codaInvoice__c>((atmToSalesMap.get(atmRef.Id)).get(0).keySet())).get(0);
                    
            //Client credit
            c2g__codaJournalLineItem__c journalLineItemClient = new c2g__codaJournalLineItem__c();
            journalLineItemClient.c2g__Value__c = -atmRef.Amount__c;
            journalLineItemClient.c2g__Account__c = salesInvoice.c2g__Account__c;
            journalLineItemClient.c2g__Journal__c = journal.Id;
            journalLineItemClient.c2g__GeneralLedgerAccount__c = clientesNacionais.Id;
            journalLineItemClient.c2g__LineDescription__c = atmRef.Name;
            journalLineItemClient.c2g__LineType__c = 'Account - Customer';
            
            allJournalLineItemsList.add(journalLineItemClient);

            
            //EasyPay debt
            c2g__codaJournalLineItem__c journalLineItemEasyPay = new c2g__codaJournalLineItem__c();
            journalLineItemEasyPay.c2g__Value__c = atmRef.Amount__c;
            journalLineItemEasyPay.c2g__Account__c = easyPayAccount.Id;
            journalLineItemEasyPay.c2g__Journal__c = journal.Id;
            journalLineItemEasyPay.c2g__GeneralLedgerAccount__c = outrosDevedores.Id;
            journalLineItemEasyPay.c2g__LineDescription__c = atmRef.Name;
            journalLineItemEasyPay.c2g__LineType__c = 'Account - Vendor';
            
            allJournalLineItemsList.add(journalLineItemEasyPay);

        }
        
        //inserts all journals in the database
        insert allJournalLineItemsList;
        
    } 

    /***************************************************************************************/
    /*																					   */
 	/*	         				Payment Collection Code          	      				   */
    /*																					   */
    /***************************************************************************************/    
    
    
    private void getSalesInvoiceFromPaymentCollection(List<Atm_Reference__c> payedATMMoloniList, Map<ID,List<Map<c2g__codaInvoice__c, Double>>> atmToSalesInvoiceMap){

        //<paymentCollection, AtmReference>
        Map<ID, ID> pcToAtmMap = new Map<ID, ID>();
        
        for(Atm_Reference__c atm : payedATMMoloniList){
            pcToAtmMap.put(atm.Payment_Collection__c, atm.ID); 
        }
         
        List<Receipt_Line_Item__c> receiptLineItemsList = [SELECT ID, Invoice__c, Invoice__r.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c, Payment_Collection__c, Partial_Invoice_Payment__r.Sales_Invoice__c,
                                                           Partial_Invoice_Payment__r.Payment_Schedule__c, Partial_Invoice_Payment__r.Amount__c
                                                           FROM Receipt_Line_Item__c
                                                           WHERE Payment_Collection__c in :pcToAtmMap.keySet()];
        
        //sales invoice ID
        Map<ID, Double> salesInvoiceIDToAmountMap = new Map<ID, Double>();
        //sales Invoice to payment collection
        Map<ID, ID> salesInvoiceIDToPCMap = new Map<ID, ID>();

        for(Receipt_Line_Item__c rli : receiptLineItemsList){
            //pays partial invoice payments
            if(rli.Partial_Invoice_Payment__c != null){
                salesInvoiceIDToPCMap.put(rli.Partial_Invoice_Payment__r.Sales_Invoice__c, rli.Payment_Collection__c);
                salesInvoiceIDToAmountMap.put(rli.Partial_Invoice_Payment__r.Sales_Invoice__c, rli.Partial_Invoice_Payment__r.Amount__c);
            }
            //pays invoices by the remain value
            else{
                salesInvoiceIDToPCMap.put(rli.Invoice__c, rli.Payment_Collection__c);
                salesInvoiceIDToAmountMap.put(rli.Invoice__c, rli.Invoice__r.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c);
            }
        }

        Map<ID, c2g__codaInvoice__c> allSIMap = new Map<ID, c2g__codaInvoice__c>([SELECT ID, c2g__Account__c, Collection_Case__c, Application__r.Name, c2g__CustomerReference__c, Name, c2g__Transaction__c FROM c2g__codaInvoice__c WHERE ID IN :salesInvoiceIDToAmountMap.keyset()]);

           
        for(ID siID : allSIMap.keySet()){ 
            c2g__codaInvoice__c si = allSIMap.get(siID);
            Double amountToPay = salesInvoiceIDToAmountMap.get(siID);
            ID pcID = salesInvoiceIDToPCMap.get(siID);
            ID atmID = pcToAtmMap.get(pcID);

            List<Map<c2g__codaInvoice__c, Double>> salesInvoiceForAtmList;
            if(atmToSalesInvoiceMap.containsKey(atmID)){ 
                salesInvoiceForAtmList = atmToSalesInvoiceMap.get(atmID);
            }else{
                salesInvoiceForAtmList = new List<Map<c2g__codaInvoice__c, Double>>();
                atmToSalesInvoiceMap.put(atmID, salesInvoiceForAtmList); 
            } 
 
            Map<c2g__codaInvoice__c, Double> siToAmountToPayMap = new Map<c2g__codaInvoice__c, Double>();
            siToAmountToPayMap.put(si, amountToPay);
            salesInvoiceForAtmList.add(siToAmountToPayMap);

        }
    }
      
         
    
    //TODO     
    /***************************************************************************************/
    /*																					   */
 	/*	         							UTILS        	    						   */
    /*	      It's supposed to change this code to a new class in later versions	       */
    /***************************************************************************************/
	
    public void joinMaps(Map<ID,List<Map<c2g__codaInvoice__c, Double>>> full, Map<ID,List<Map<c2g__codaInvoice__c, Double>>> toAdd){
         
        if(!toAdd.isEmpty()){            
            List<ID> keys = new List<ID>();
            keys.addAll(toAdd.keySet());
            
            for(ID key : keys){
                full.put(key, toAdd.get(key));
            }
        }
    }
    
    
    //returns the current period ID
    public static ID getPeriod(){      
        Date d = Date.today();
        system.debug(LoggingLevel.INFO, 'c2g__codaPeriod__c getPeriod periodDate' + d.format());
        String periodString = d.format();
        Date periodDate = Date.newInstance(d.year(), d.month(), d.day());
        return getPeriod(periodDate).Id;
    }
    
    //given a date returns the period associated
    public static c2g__codaPeriod__c getPeriod(date periodDate) {
        system.debug(LoggingLevel.INFO, 'c2g__codaPeriod__c getPeriod periodDate' + periodDate);
        c2g__codaPeriod__c currentPeriod = [SELECT ID FROM c2g__codaPeriod__c where c2g__StartDate__c <= :periodDate AND c2g__EndDate__c >= :periodDate];
        return currentPeriod;
    }
    
    //removes all characters that shoulnt be present in a xml file, replaces them for _
    private String toANSI(String xml){
        String finalString = '';
        for(Integer i = 0; i < xml.length()-1; i++){
            String letter = xml.substring(i, i+1);
            Integer value = xml.charAt(i);
                if(((value>=60 && value <=63) || value == 34 || (value>=45 && value <=47) || value == 95 || (value>=48 && value <=57) || (value>=65 && value <=90) || (value>=97 && value <=122))){
                    finalString+=letter;
                } else finalString+='_';
        }
        String finalChar = xml.substring(xml.length()-1, xml.length());
        system.debug(finalString+finalChar);
        return finalString+finalChar;
    }
    
    
    //creates a fake answser
    private HTTPResponse getFakeAnswser(){
        String body; 
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
		body = '<?xml version="1.0"?><get_ref><ep_status>ok0</ep_status><ep_message>ep_country and ep_entity and ep_user and ep_cin ok and validation by code;code ok - query with 5 records</ep_message><ep_num_records>5</ep_num_records>';
        body += '<ref_detail>';
        body += '<ref><ep_cin>6063</ep_cin><ep_user>CARESA030216</ep_user><ep_entity>10611</ep_entity><ep_reference>606300991</ep_reference><ep_value>12.30</ep_value><ep_key>43450</ep_key><t_key></t_key>';
        body += '<ep_doc>MBTEST374566320170206154313</ep_doc><ep_payment_type>MB</ep_payment_type><ep_value_fixed>0.35</ep_value_fixed><ep_value_var>0.2745</ep_value_var><ep_value_tax>0.131145</ep_value_tax>';
        body += '<ep_value_transf>14.494355</ep_value_transf><ep_date_transf>2017-02-09</ep_date_transf><ep_key_read>43450</ep_key_read><ep_date_read>2017-02-06 15:43:29</ep_date_read><ep_status_read>verified</ep_status_read>';
        body += '<ep_status>pago</ep_status><ep_batch_transf></ep_batch_transf><ep_invoice_number></ep_invoice_number><ep_payment_date>2017-02-06 15:43:13</ep_payment_date></ref>';
        body += '</ref_detail></get_ref>';
        res.setBody(body);
        res.setStatusCode(200);

        System.debug('test body: ' + body);
        return res;
    }
    
    //creates a fake answser
    private HTTPResponse getFakeAnswserMoloni(){
        String body; 
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
		body = '<?xml version="1.0"?><get_ref><ep_status>ok0</ep_status><ep_message>ep_country and ep_entity and ep_user and ep_cin ok and validation by code;code ok - query with 5 records</ep_message><ep_num_records>5</ep_num_records>';
        body += '<ref_detail>';
        body += '<ref><ep_cin>509999902</ep_cin><ep_user>CARESA030216</ep_user><ep_entity>10611</ep_entity><ep_reference>509999902</ep_reference><ep_value>12.30</ep_value><ep_key>43444</ep_key><t_key></t_key>';
        body += '<ep_doc>MBTEST374564620170206151549</ep_doc><ep_payment_type>MB</ep_payment_type><ep_value_fixed>0.35</ep_value_fixed><ep_value_var>0.2745</ep_value_var><ep_value_tax>0.131145</ep_value_tax>';
        body += '<ep_value_transf>14.494355</ep_value_transf><ep_date_transf>2017-02-09</ep_date_transf><ep_key_read>43444</ep_key_read><ep_date_read>2017-02-06 15:15:58</ep_date_read><ep_status_read>verified</ep_status_read>';
        body += '<ep_status>pago</ep_status><ep_batch_transf></ep_batch_transf><ep_invoice_number></ep_invoice_number><ep_payment_date>2017-02-06 15:15:49</ep_payment_date></ref>';
        body += '</ref_detail></get_ref>';
        res.setBody(body);
        res.setStatusCode(200);

        System.debug('test body: ' + body);
        return res;
    }    

    public HTTPResponse getMBFake(){
        String body;
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');

          body = '<?xml version="1.0"?><getautoMB>';
          body += '<ep_status>ok0</ep_status>';
          body += '<ep_message>ep_country and ep_entity and ep_user and ep_cin ok and validation by code;code ok - new reference generated - 606300394 - </ep_message>';
          body += '<ep_cin>999800160</ep_cin>';
          body += '<ep_user>CARESA030216</ep_user>';
          body += '<ep_partner>CARESA030216</ep_partner>';
          body += '<ep_entity>11683</ep_entity>';
          body += '<ep_reference>606300394</ep_reference>';
          body += '<ep_value>15.25</ep_value>';
          body += '<t_key></t_key>';
          body += '<ep_link>http://test.easypay.pt/_s/c11.php?e=10611&amp;r=606300394&amp;v=15.25&amp;c=PT&amp;l=PT&amp;t_key=</ep_link>';
          body += '</getautoMB>';
          res.setBody(body);
          res.setStatusCode(200);  

        System.debug('test body: ' + body);
        return res;

    }    
    
    class EasyPayPojo{
        String ep_entity;
        Integer ep_reference; //ep_reference
        String ep_value; //ep_value
        Date ep_date_transf = System.today(); //eep_date_transfp_reference
        Date ep_pay_date;
        
    }
    
}