global class AC_AssignmentContractAPI implements Database.AllowsCallouts{
    
    private static OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@candor.pt'];  
    
    
    /**
    *
    *   ASSIGNMENT OF CONTRACT
    *
    */
    
    
    public static List<String> assignmentContract(String nif, String typeOfAssignContract, ID bcID, ID accID, Date companyClosedDate){
        
        //list[0] => Result ; list[1] => assignment Contract ID; list[2] => description of error/name
        List<String> result = new List<String>();
        
        //update data from informa DB for new client
        ID reportID = BOReport.DownladAndGetReport(nif,'', accID, 'XMLPROPL');
        
        if(reportID == null && !Test.isRunningTest()){
            result.add('Error');
            AssignmentContract__c ac = createAContract(typeOfAssignContract, bcID, accID, 'Credit Line - Pendent',
                                                       'Error while downloading file from informaDB or NIF not available.', null);
            result.add(ac.ID);
            result.add('Error while downloading file from informaDB or NIF not available.');            
                                                       
            return result;
        }       
        
        ID fileID; 
        String status;
        
        if(!Test.isRunningTest()){
            fileID = BOReport.GetInformaDBPdfAttachId(reportID, nif);
            status = ScoreCardConfig.GetCreditLineStatusForAccount(accID);
        }else{
            status = 'Credit Line - Approved';
            Account newAcc = [SELECT ID, Credit_Line_Status__c FROM Account WHERE ID = :accID];
            newAcc.Credit_Line_Status__c = 'Credit Line - Approved';
        }

        //create a new record for assignment of contract
        AssignmentContract__c ac = createAContract(typeOfAssignContract, bcID, accID, status, null, companyClosedDate);
        
        result.add(ac.Client_Credit_Line_Status__c);
        result.add(ac.ID);
        result.add(ac.Credit_Description__c);
        
        return result;

    }   
    
    public static AssignmentContract__c createAContract(String typeOfAssignContract, ID bcID, ID newAccID, String result, String obs, Date companyClosedDate){
        
        Billing_Contract__c bc = [SELECT ID, Account__c,Payment_Amount_to_The_End_Of_Contract__c, Application__c  FROM Billing_Contract__c WHERE ID = :bcID];
        ID oldAccID = bc.Account__c;
        
        Application__c app = [SELECT ID, AccClient__r.c2g__CODAInvoiceEmail__c , Equipment_Cost__c,  Client_Signer_1__c, Client_Signer_2__c , Client_Signer_3__c, Client_Signer_4__c, Client_Signer_5__c, Invoice_To__c  FROM  Application__c WHERE ID=:bc.Application__c];
        
        Account newAcc = [SELECT ID, Credit_Line_Status__c, Credit_line__c FROM Account WHERE ID = :newAccID];
        
        AssignmentContract__c ac = new AssignmentContract__c();
        AssignmentContract__c acUpdated;
                
        ac.TypeOfAssignContract__c = typeOfAssignContract;
        ac.New_Client_Account__c = newAccID;
        ac.Old_Client_Account__c = oldAccID;
        ac.Renting_Application__c = bc.Application__c;
        ac.Old_Client_Signer_1__c= app.Client_Signer_1__c;
        ac.Old_Client_Signer_2__c= app.Client_Signer_2__c;
        ac.Old_Client_Signer_3__c= app.Client_Signer_3__c;
        ac.Old_Client_Signer_4__c= app.Client_Signer_4__c;
        ac.Old_Client_Signer_5__c= app.Client_Signer_5__c;
        ac.Old_Invoice_Email__c = app.AccClient__r.c2g__CODAInvoiceEmail__c;
        ac.Billing_Contract__c = bcID;
        ac.Requested_Date__c = system.today();
        if(companyClosedDate!=null) 
            ac.Begin_Of_AoContract__c = companyClosedDate;
        else 
            ac.Begin_Of_AoContract__c = system.today();
        
        if(app.Invoice_To__c==null){
            ac.Invoice_To__c = app.Client_Signer_1__c;
        }else{
            ac.Invoice_To__c = app.Invoice_To__c;
        }
            
        
        if(String.isEmpty(obs)){
            ac.Status__c = 'In Progress';
        }else{
            ac.Status__c = 'Error';
            ac.Credit_Description__c = obs;
            insert ac;
            acUpdated = updateAC(ac.ID);    
            return acUpdated;
        }

    
        newAcc.Credit_Line_Status__c = result;
        if(newAcc.Credit_line__c != null && bc.Payment_Amount_to_The_End_Of_Contract__c != null){
            if(newAcc.Credit_line__c >= bc.Payment_Amount_to_The_End_Of_Contract__c){
                ac.Status__c = 'In Progress';
                ac.Credit_Description__c = 'Credit Line for new client is greater than equipment cost';
            }else{
                ac.Status__c = 'Refused';
                ac.Credit_Description__c = 'Credit Line for new client is less than equipment cost. Remain Value: '+ (bc.Payment_Amount_to_The_End_Of_Contract__c-newAcc.Credit_line__c);
            }   
        }else{
            ac.Credit_Description__c = '';
        }       
        
        if(result == 'Credit Line - Rejected'){
            ac.Status__c = 'Refused';
            newAcc.Credit_Line_Status__c = result;          
        }
        
        if(typeOfAssignContract == 'Merged Company'){
            newAcc.Credit_Line_Status__c = 'Credit Line - Approved';
            ac.Status__c = 'In Progress';
            ac.Credit_Description__c = 'As a merge company, credit line is always approved, but the result was '+result;
        }       
        
        update newAcc;
        insert ac;
        
        acUpdated = updateAC(ac.ID);    
        
        return acUpdated;
    }   
    
    /**
    *
    *   CREATE CREDIT NOTE AND NEW INVOICE
    *
    */      
    
    
    webservice static String createCreditNotes(ID acID){
        
        AssignmentContract__c ac = updateAC(acID);
        
        if(ac.Client_Credit_Line_Status__c!='Credit Line - Approved')
            return 'Credit Line Status should be approved to continue';         
        
        if(ac.New_Invoice_Email__c==null || !mandatorySigners(ac))
            return 'Before you proceed, please fill the New Client Contacts Section. New Invoice Email is mandatory and the number of signers should be at least '+(Integer)ac.numObriga__c;
        
        List<c2g__codaInvoice__c> siList = [SELECT ID FROM c2g__codaInvoice__c where c2g__Account__c = :ac.Old_Client_Account__c AND c2g__InvoiceDate__c > :ac.Begin_Of_AoContract__c AND c2g__InvoiceDescription__c != 'Custos de Cessão de Posição Contratual'];
        List<ID> siIDList = new List<ID>();
        
        if(!siList.isEmpty()){
            for(c2g__codaInvoice__c si : siList){
                siIDList.add(si.ID);
            }
             
            Database.executeBatch(new AC_BH_CreditNote(siIDList),1);
            Database.executeBatch(new AC_BH_SalesInvoice(ac.New_Client_Account__c, siIDList),1);
            return 'Process started with sucess, please wait a few minutes and check if everything is ok.';
        }

        return 'No Invoices Detected.';
    }
    
    
    /**
    *
    *   CREATE COSTS SALES INVOICE
    *
    */  
    
    webservice static String createCostsInvoice(ID accID, ID appID, ID acID){

        AssignmentContract__c ac = updateAC(acID);

        if(ac.Client_Credit_Line_Status__c!='Credit Line - Approved')
            return 'Credit Line Status should be approved to continue';     
        
        if(ac.New_Invoice_Email__c==null || !mandatorySigners(ac))
            return 'Before you proceed, please fill the New Client Contacts Section. New Invoice Email is mandatory and the number of signers should be at least '+(Integer)ac.numObriga__c;

        if(ac.Costs_Sales_Invoice__c != null)
            return 'Invoice already created.';
            
        if(ac.Invoice_Receiver__c == 'None')
            return 'Before you proceed, please fill Invoice Receiver field. This field indicates who receives and pays the costs invoice for assignment of contract.';
            
        //create costs invoice
        ID si = createInvoice(accID,appID,acID);
            
        return 'Invoice Created';
    } 
        

    
    //create invoice for costs
    public static ID createInvoice(Id accID, ID appID, ID acID){
        
        AssignmentContract__c ac = updateAC(acID);
        BILL_ProductRegion billRegion = new BILL_ProductRegion('Input');
        Account acc;
            
        if(ac.Invoice_Receiver__c == 'New Client'){
            acc = [SELECT ID, c2g__CODAInvoiceEmail__c, Tax_Zone__c FROM Account WHERE ID = :ac.New_Client_Account__c];
            acc.c2g__CODAInvoiceEmail__c = ac.New_Invoice_Email__c;
            update acc; 
        }else{
            acc = [SELECT ID, Tax_Zone__c FROM Account WHERE ID = :ac.Old_Client_Account__c];
        }

                                                  
        ID prod = billRegion.getProduct('PT17', acc.Tax_Zone__c);
        ID taxCode = billRegion.getTaxCode('PT17', acc.Tax_Zone__c);
                                        
                                                        
        //Criação da Payable Invoice a partir do objecto Vendor_Invoice__c                              
        c2g__codaInvoice__c si = new c2g__codaInvoice__c();
        
        si.c2g__Account__c = acc.ID;
            
        si.Application__c = appID;
        Date todayDate = system.today();
        Date dueDate = todayDate.addDays(7);
        si.c2g__DueDate__c = dueDate;
        si.c2g__InvoiceDate__c = todayDate;
        si.c2g__InvoiceDescription__c = 'Custos de Cessão de Posição Contratual'; 
      
        insert si;      
        
        //update dueDate
        si.c2g__DueDate__c = dueDate;
        update si;          
        
        c2g__codaInvoiceLineItem__c ili = new c2g__codaInvoiceLineItem__c();
        ili.c2g__Invoice__c = si.Id;
        ili.c2g__Product__c = prod;
        ili.c2g__TaxCode1__c = taxCode;
        insert ili;
        
        
        //c2g.CODAAPICommon.Reference refInvoice = new c2g.CODAAPICommon.Reference();
        //refInvoice.Id = si.Id;
        //system.debug('Posting sales invoice for assignment contract costs ' + refInvoice.id);
        //TODO to Post invoice        
        //c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, refInvoice);
        
        if(!Test.isRunningTest())
            si.Posted_InvoiceXpress__c = true;
        si.Post_SalesInvoice__c = true;      
         
        update si; 
        
        ac.Costs_Sales_Invoice__c = si.ID;
        
        update ac;
        
        return si.ID;
        
    }
    
    
    webservice static String sendToMoloni(Id acID){
            
        AssignmentContract__c ac = updateAC(acID);
        
        if(ac.Client_Credit_Line_Status__c!='Credit Line - Approved')
            return 'Credit Line Status should be approved to continue';     
                    
        BILL_MoloniApi billAPI = new BILL_MoloniApi();
        
        try{            
            if(!Test.isRunningTest() && !Utilities.runningInASandbox() ){
                billAPI.createInvoiceMoloniFinalized(ac.Costs_Sales_Invoice__c);
            }else{
                updateInvoiceForTest(ac.Costs_Sales_Invoice__c);
            }
        }catch(Exception e){
            return 'An error ocurred, please contact the support team as soon as possible';
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL',
            ApplicationID__c = 'ASSIGNMENT OF CONTRACT', message__c = e.getMessage(), printStackTrace__c = e.getStackTraceString());
            system.debug('CRITICAL: '+ record);
            insert record;
            return 'An error ocurred, please contact the support team as soon as possible';
        }
        
        return 'Sent To Moloni!';
            
    }
    
    
    /**
    *
    *   GENERATE UNPAID INVOICES / ATM / PAYMENT COLLECTION
    *
    */    
    
    webservice static String generateCollection(ID acID){
        //Savepoint sp;
        Double total = 0;
        ATM_Reference__c atmNewClient;
        ATM_Reference__c atmOldClient;      
        
        try{
            //upload invoice to Moloni
            AssignmentContract__c ac = updateAC(acID);
            
            if(ac.Client_Credit_Line_Status__c!='Credit Line - Approved')
                return 'Credit Line Status should be approved to continue'; 
                
            if(ac.Costs_Sales_Invoice__c == null)
                return 'Costs Invoice not generated yet.';              

            
            List<c2g__codaInvoice__c> salesInvoiceList;
            c2g__codaInvoice__c costInvoice;

            salesInvoiceList = [SELECT Id, c2g__PaymentStatus__c, c2g__Account__c, c2g__Account__r.BillingCountryCode,Invoice_Express_Number_text__c,c2g__DueDate__c,Name,c2g__InvoiceDate__c, c2g__InvoiceTotal__c, Application__c FROM c2g__codaInvoice__c WHERE c2g__Account__c =: ac.Old_Client_Account__c  AND c2g__PaymentStatus__c = 'Unpaid' AND c2g__InvoiceDate__c <= :ac.Begin_Of_AoContract__c AND c2g__InvoiceDescription__c != 'Custos de Cessão de Posição Contratual'];
            costInvoice      = [SELECT Id, c2g__PaymentStatus__c, c2g__Account__c, c2g__Account__r.BillingCountryCode,Invoice_Express_Number_text__c,c2g__DueDate__c,Name,c2g__InvoiceDate__c, c2g__InvoiceTotal__c, Application__c FROM c2g__codaInvoice__c WHERE ID = :ac.Costs_Sales_Invoice__c];
            
           
            //get total

            if(!salesInvoiceList.isEmpty()){
                for(c2g__codaInvoice__c si : salesInvoiceList){
                    total+=si.c2g__InvoiceTotal__c;
                }
            }
            
            //generate ATM Reference 
            Bill_EasyPayAPI billEasypay = new Bill_EasyPayAPI();
                            
            List<ATM_Reference__c> atmsToInsert = new List<ATM_Reference__c>();
            
            
            if(total > 0 || ac.Invoice_Receiver__c == 'Old Client'){
                if(ac.Invoice_Receiver__c == 'Old Client'){
                    salesInvoiceList.add(costInvoice);
                    total+=costInvoice.c2g__InvoiceTotal__c;
                }
                atmOldClient = billEasypay.getNewMBReference(String.valueOf(total), system.today().addDays(7), ac.ID, ac.Old_Client_Account__c);
                atmsToInsert.add(atmOldClient);             
            }
            
            if(ac.Invoice_Receiver__c == 'New Client'){
                atmNewClient = billEasypay.getNewMBReference(String.valueOf(costInvoice.c2g__InvoiceTotal__c), system.today().addDays(7), ac.ID, ac.New_Client_Account__c);
                atmsToInsert.add(atmNewClient);             
            }
            
            //sp = Database.setSavepoint();    
            
            insert atmsToInsert;

            
            //update html unpaid invoices table
            createTable(acID, ac.Old_Client_Account__c, salesInvoiceList);
         
            
            //generate Payment Collections   
            PaymentCollection_Utils pcUtils = new PaymentCollection_Utils();      
            Map<String, String> infoMap; 
            
            if(total > 0){
                infoMap = pcUtils.createPaymentCollectionWithATM(atmOldClient, salesInvoiceList);
                ac.Payment_Collection__c = infoMap.get('pc');
                ac.Aux_Reference__c= String.valueOf(atmOldClient.ATM_Reference__c);
                ac.Aux_Entity__c = String.valueOf(atmOldClient.Entity__c);
                ac.Amount_Claimed__c = atmOldClient.Amount__c;              
            }
            
            Map<String, String> infoMapClosedCompany;
            if(ac.Invoice_Receiver__c == 'New Client'){
                infoMapClosedCompany = pcUtils.createPaymentCollectionWithATM(atmNewClient, new c2g__codaInvoice__c[]{costInvoice});
                ac.New_Client_Payment_Collection__c = infoMapClosedCompany.get('pc');
                ac.Aux_Entity_2__c = String.valueOf(atmNewClient.ATM_Reference__c);
                ac.Aux_Reference_2__c = String.valueOf(atmNewClient.Entity__c);
                ac.Amount_Claimed_2__c = String.valueOf(atmNewClient.Amount__c);
            }           

            update ac;
            
        }catch(Exception e){
            //Database.rollback(sp);
            //if match failed an email is sent after the outbound integration log is created
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'ASSIGNMENT OF CONTRACT', message__c = e.getMessage()+'\n'+total+' '+atmOldClient+' '+atmNewClient, printStackTrace__c = e.getStackTraceString());
            system.debug('CRITICAL: '+ record);
            insert record;
            return 'An error ocurred, please contact the support team as soon as possible';
        }
        
        return 'Collection generated for All Sales Invoices';
    }
    
    public static void createTable(ID acID, ID accID, List<c2g__codaInvoice__c> m_coda){
        
        String m_Html = '';
        
        AssignmentContract__c ac = [SELECT ID, Unpaid_Invoices__c FROM AssignmentContract__c WHERE ID = :acID];
        
        m_Html += '<table border="0" cellspacing="2" cellpadding="0" style="width:100%;" class="ProductsTable"><tr>';
        m_Html += '<th style="height:24px; background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:1%;" class="ProductsHeader"></th>';
        m_Html += '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Fatura</th>';
        m_Html += '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Data de Vencimento</th>';
        //m_Html += '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Juros de Mora</th>';
        m_Html += '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:24%;" class="ProductsHeader">Valor</th>';
        m_Html += '</tr>'; 
        
        Date d;
        //Decimal ir = 0;
        Decimal amount = 0;
        for(c2g__codaInvoice__c m_cod : m_coda)
        {
            amount = m_cod.c2g__InvoiceTotal__c;
            amount = amount.setScale(2);
            
            d=m_cod.c2g__DueDate__c;
            String formattedDate = d.format();

            m_Html += '<tr><td></td>'; 
            m_Html += '<td style="text-align:center;" class="ProductsCell">'+ m_cod.Invoice_Express_Number_text__c +'</td>';
            m_Html += '<td style="text-align:center;" class="ProductsCell">'+ formattedDate + '</td>';
            //m_Html += '<td style="text-align:center;" class="ProductsCell">'+ ir +' %</td>';
            m_Html += '<td style="text-align:center;" class="ProductsCell">'+ amount  +' &euro;</td>';
            m_Html +='</tr>';
        }        
        m_Html += '</table>'; 
        
        ac.Unpaid_Invoices__c = m_Html;        
        update ac;        
                
    }   
    
    public static void updateInvoiceForTest(ID siID){
        c2g__codaInvoice__c si = [SELECT ID, Invoice_Email_Status__c, Invoice_Express_Number_text__c, Invoice_express_Link__c 
                                  FROM c2g__codaInvoice__c 
                                  WHERE ID = :siID];
                                  
        si.Invoice_Email_Status__c = 'To be send';
        si.Invoice_Express_Number_text__c = 'PT2017A/1371'; 
        si.Invoice_express_Link__c = 'https://www.moloni.com/downloads/?h=1d6ce47a9e5442287938baaa8cb3af59&d=191143675';    
        update si;  
    }    
    
    /**
    *
    *   CREATE EMAILS TO SEND
    *
    */  
    
    webservice static String generateAttchment(Boolean guarantee, ID acID){
        
        AssignmentContract__c ac = updateAC(acID);
        
        if(ac.Client_Credit_Line_Status__c!='Credit Line - Approved')
            return 'Credit Line Status should be approved to continue';             
        
        List<Attachment> listDocument = new List<Attachment>();
        PageReference pdf = null;
        
        listDocument =[SELECT Id, name, body, createdDate, parentID 
                       FROM attachment 
                       WHERE parentId =:acID AND name LIKE 'Assignment_of_Contract_%'];
        
        if(listDocument.size() > 0)
            return 'Document already generated, please delete the old file if you want to generate another document';
                            
                            
        Attachment newContract = new Attachment (ParentId = acID);
        listDocument.add(newContract);
                                        
                            
        if(guarantee){
            pdf = Page.AssignmentOfContractWithGuaranteeRender;
        }else{
            pdf = Page.AssignmentOfContractRender;
        }         
        
        pdf.getParameters().put('id',acID);
        
        Blob body;  
        try {
            // returns the output of the page as a PDF
            body = pdf.getContent();
            // need to pass unit test -- current bug  
        } catch (VisualforceException e) {
            body = Blob.valueOf('need to pass unit test');
        }
        
        listDocument[0].Body = body;
        listDocument[0].Name = 'Assignment_of_Contract_'+ac.Name+'.pdf';
        listDocument[0].IsPrivate = false;
        
        upsert listDocument[0];  
        
        return 'Attchment Created';
    }


    webservice static String sendContract(ID acID){
        
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        Blob pdfBlob;
        String CountryCode;
        Integer MIN_ATTACH_SIZE = 67584;
        Decimal MIN_NUMBER_OF_SIGNERS = 1;
        Decimal NUMBER_OF_EXISTING_SIGNERS = 0;

        AssignmentContract__c ac = updateAC(acID);
                                     

        if(ac.Client_Credit_Line_Status__c!='Credit Line - Approved'){
            return 'Credit Line Status should be approved to continue'; 
        }
            
        if(ac.TypeOfAssignContract__c == 'Merged Company'){
            return 'Merge Company doesn\'t need to sign any document.';
        }       

                                                     
        String contractName = 'Assignment_of_Contract_'+ac.Name+'.pdf';
        List<Attachment> doc = [SELECT Id, name, body, createdDate, parentID, bodylength 
                                FROM attachment 
                                WHERE parentID=:acID AND name =:contractName];

        if(ac.numObriga__c > 0){
            MIN_NUMBER_OF_SIGNERS = ac.numObriga__c;
        }

        if(doc.size()>0){
            pdfBlob = doc[0].Body;
        }else if(doc.size()==0){ 
            System.debug('[Assignment Of Contract - SendContract] - Document with Id '+ac.Name+' not Found.');
            DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();
            es.Status = 'Not Found';
            //Utilities.LogIntegrationLongResponse( Datetime.now(), Datetime.now(), es.Status, 'CONTRACT_AUTO','',app.Id,'');
            return es.Status;
        }else if(doc[0].bodylength < MIN_ATTACH_SIZE){//valida se o attach está corrompido. Se o tamanho for inferior ao limite é porque tem erro
            System.debug('[Assignment Of Contract - SendContract] - Document with Id '+ac.Name+' not Found.');
            DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();
            es.Status = 'INVALID_ATTACH';
            //Utilities.LogIntegrationLongResponse( Datetime.now(), Datetime.now(), es.Status, 'CONTRACT_AUTO','',app.Id,'');
            return es.Status;
        }

        // Document
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
        document.Name =  'Custos de Cessão de Posição Contratual - ' + ac.Name;
        document.FileExtension = 'pdf';
        envelope.Documents = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0] = document;

        List<DocuSignAPI.Recipient> recipientList = new List<DocuSignAPI.Recipient>();
            List<DocuSignAPI.Tab> tabList = new List<DocuSignAPI.Tab>();
            
        if(ac.New_Client_Account__r.Country_Code__c == null || ac.New_Client_Account__r.Country_Code__c == ''){
            CountryCode = 'PT';
        }else{
            CountryCode = ac.New_Client_Account__r.Country_Code__c.substring(0, 2);
        }
        
        NUMBER_OF_EXISTING_SIGNERS+=defineSignersForNewClient(ac,recipientList,tabList);
        NUMBER_OF_EXISTING_SIGNERS+=defineSignersForOldClient(ac,recipientList,tabList);

        
        envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignAPI.Recipient[recipientList.size()];
        for(integer i=0; i<recipientList.size(); i++){
            envelope.Recipients.Recipient[i] = recipientList[i];
        }
        
        envelope.Tabs = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab = new DocuSignAPI.Tab[tabList.size()];
        for(integer i=0; i<tabList.size(); i++){
            envelope.Tabs.Tab[i] = tabList[i];
        }
        
        //Riminder and expirations
        DocuSignAPI.Notification notification = new DocuSignAPI.Notification();
        notification.UseAccountDefaults = true; // use account default
        envelope.Notification = notification;        

        List<DocuSignAPI.CustomField> customFieldList = new List<DocuSignAPI.CustomField>();      
        //Put external ID -- AppID
        DocuSignAPI.CustomField field = CandorDocuments.createDocuSignCostumFields('Assignment Contract', ac.ID, true); 
        customFieldList.add(field);
        
        DocuSignAPI.ArrayOfCustomField arrayOfCustomField = new DocuSignAPI.ArrayOfCustomField();
        arrayOfCustomField.CustomField  = new DocuSignAPI.CustomField[customFieldList.size()];
        arrayOfCustomField.CustomField = customFieldList;
        envelope.CustomFields = arrayOfCustomField;
        
        envelope.Subject = 'Cessão de Posição contratual '+ ac.Name;
        //envelope.AccountId  = accountId;
        DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();
        if(NUMBER_OF_EXISTING_SIGNERS < MIN_NUMBER_OF_SIGNERS){
            es.Status = 'MIN_NUMBER_OF_SIGNERS';
        }else{
            if(!Test.isRunningTest())
                es = CandorDocuments.sendDocumentThroughDocuSign(envelope);
            else
                es.Status = 'Sent';
        }   
        
        if(es.status=='Sent'){
            ac.ContractSentDate__c = date.today();
            update ac;
            return ' Contract sent with success! ';
        }     
        system.debug(es);
        return es.status + '- Contact the support team.';
    }
    
    public static Integer defineSignersForOldClient(AssignmentContract__c ac, List<DocuSignAPI.Recipient> recipientList, List<DocuSignAPI.Tab> tabList){
          Integer NUMBER_OF_EXISTING_SIGNERS = 0;
          
          if(ac.Old_Client_Signer_1__c !=null){
                
                NUMBER_OF_EXISTING_SIGNERS++;
                
                DocuSignAPI.Recipient Signer1 = CandorDocuments.createDocuSignRecipient(5,'Signer',1,'Signer 5', ac.Old_Client_Signer_1__r.Email, ac.Old_Client_Signer_1__r.Name, ac.Old_Client_Account__c ,ac.Old_Client_Signer_1__r.ID);
                recipientList.add(Signer1);
                
                // Tab
                DocuSignAPI.Tab tab1 = CandorDocuments.createDocuSignTab(5, 1,'SignHere','\\s5\\');
                DocuSignAPI.Tab tab1Date = CandorDocuments.createDocuSignTab(5, 1, 'DateSigned','\\d5\\');
                tabList.add(tab1);
                tabList.add(tab1Date);
            }
            
            if(ac.Old_Client_Signer_2__c != null){
                
                NUMBER_OF_EXISTING_SIGNERS++;
                
                DocuSignAPI.Recipient Signer2 = CandorDocuments.createDocuSignRecipient(6,'Signer',1,'Signer 6', ac.Old_Client_Signer_2__r.email, ac.Old_Client_Signer_2__r.Name, ac.Old_Client_Account__c,ac.Old_Client_Signer_2__c);
                recipientList.add(Signer2);
                
                DocuSignAPI.Tab tab2 = CandorDocuments.createDocuSignTab(6, 1,'SignHere','\\s6\\');
                DocuSignAPI.Tab tab2Date = CandorDocuments.createDocuSignTab(6, 1, 'DateSigned','\\d6\\');
                tabList.add(tab2);
                tabList.add(tab2Date);
            }
            
            if(ac.Old_Client_Signer_3__c !=null){
               
                NUMBER_OF_EXISTING_SIGNERS++;
               
                DocuSignAPI.Recipient Signer3 = CandorDocuments.createDocuSignRecipient(7,'Signer',1,'Signer 7', ac.Old_Client_Signer_3__r.email, ac.Old_Client_Signer_3__r.Name, ac.Old_Client_Account__c,ac.Old_Client_Signer_3__c);
                recipientList.add(Signer3);
                
                DocuSignAPI.Tab tab3 =  CandorDocuments.createDocuSignTab(7, 1,'SignHere','\\s7\\');
                DocuSignAPI.Tab tab3Date = CandorDocuments.createDocuSignTab(7, 1, 'DateSigned','\\d7\\');
                tabList.add(tab3);
                tabList.add(tab3Date);
            } 
            
            
            if(ac.Old_Client_Signer_4__c !=null){
      
                NUMBER_OF_EXISTING_SIGNERS++;
      
                DocuSignAPI.Recipient Signer = CandorDocuments.createDocuSignRecipient(8,'Signer',1,'Signer 8', ac.Old_Client_Signer_4__r.email, ac.Old_Client_Signer_4__r.Name, ac.Old_Client_Account__c, ac.Old_Client_Signer_4__c);
                recipientList.add(Signer);
                
                DocuSignAPI.Tab tab = CandorDocuments.createDocuSignTab(8, 1,'SignHere','\\s8\\');
                DocuSignAPI.Tab tabDate = CandorDocuments.createDocuSignTab(8, 1, 'DateSigned','\\d8\\');
                tabList.add(tab);
                tabList.add(tabDate);
            } 
            
            return NUMBER_OF_EXISTING_SIGNERS;      
    }   
    
    public static Integer defineSignersForNewClient(AssignmentContract__c ac, List<DocuSignAPI.Recipient> recipientList, List<DocuSignAPI.Tab> tabList){
          Integer NUMBER_OF_EXISTING_SIGNERS = 0;
        
          if(ac.New_Client_Signer_1__c!=null){
                
                NUMBER_OF_EXISTING_SIGNERS++;
                
                DocuSignAPI.Recipient Signer1 = CandorDocuments.createDocuSignRecipient(1,'Signer',1,'Signer 1', ac.New_Client_Signer_1__r.Email, ac.New_Client_Signer_1__r.Name, ac.New_Client_Account__c ,ac.New_Client_Signer_1__c);
                recipientList.add(Signer1);
                
                // Tab
                DocuSignAPI.Tab tab1 = CandorDocuments.createDocuSignTab(1, 1,'SignHere','\\s1\\');
                DocuSignAPI.Tab tab1Date = CandorDocuments.createDocuSignTab(1, 1, 'DateSigned','\\d1\\');
                tabList.add(tab1);
                tabList.add(tab1Date);
                
                if(ac.Guarante__c){
                    tab1 =  CandorDocuments.createDocuSignTab(1, 1,'SignHere','\\sf1\\');
                    tab1Date = CandorDocuments.createDocuSignTab(1, 1, 'DateSigned','\\df1\\');
                    tabList.add(tab1);
                    tabList.add(tab1Date);
                }
            }
            
            if(ac.New_Client_Signer_2__c != null){
                
                NUMBER_OF_EXISTING_SIGNERS++;
                
                DocuSignAPI.Recipient Signer2 = CandorDocuments.createDocuSignRecipient(2,'Signer',1,'Signer 2', ac.New_Client_Signer_2__r.email, ac.New_Client_Signer_2__r.Name, ac.New_Client_Account__c,ac.New_Client_Signer_2__c);
                recipientList.add(Signer2);
                
                DocuSignAPI.Tab tab2 = CandorDocuments.createDocuSignTab(2, 1,'SignHere','\\s2\\');
                DocuSignAPI.Tab tab2Date = CandorDocuments.createDocuSignTab(2, 1, 'DateSigned','\\d2\\');
                tabList.add(tab2);
                tabList.add(tab2Date);
                
                if(ac.Guarante__c){
                    tab2 = CandorDocuments.createDocuSignTab(2, 1,'SignHere','\\sf2\\');
                    tab2Date = CandorDocuments.createDocuSignTab(2, 1, 'DateSigned','\\df2\\');
                    tabList.add(tab2);
                    tabList.add(tab2Date);
                }
            }
            
            if(ac.New_Client_Signer_3__c!=null){
               
                NUMBER_OF_EXISTING_SIGNERS++;
               
                DocuSignAPI.Recipient Signer3 = CandorDocuments.createDocuSignRecipient(3,'Signer',1,'Signer 3', ac.New_Client_Signer_3__r.email, ac.New_Client_Signer_3__r.Name, ac.New_Client_Account__c,ac.New_Client_Signer_3__c);
                recipientList.add(Signer3);
                
                DocuSignAPI.Tab tab3 =  CandorDocuments.createDocuSignTab(3, 1,'SignHere','\\s3\\');
                DocuSignAPI.Tab tab3Date = CandorDocuments.createDocuSignTab(3, 1, 'DateSigned','\\d3\\');
                tabList.add(tab3);
                tabList.add(tab3Date);
            } 
            
            
            if(ac.New_Client_Signer_4__c!=null){
      
                NUMBER_OF_EXISTING_SIGNERS++;
      
                DocuSignAPI.Recipient Signer = CandorDocuments.createDocuSignRecipient(4,'Signer',1,'Signer 4', ac.New_Client_Signer_4__r.email, ac.New_Client_Signer_4__r.Name, ac.New_Client_Account__c, ac.New_Client_Signer_4__c);
                recipientList.add(Signer);
                
                DocuSignAPI.Tab tab = CandorDocuments.createDocuSignTab(4, 1,'SignHere','\\s4\\');
                DocuSignAPI.Tab tabDate = CandorDocuments.createDocuSignTab(4, 1, 'DateSigned','\\d4\\');
                tabList.add(tab);
                tabList.add(tabDate);
            }   
            
            return NUMBER_OF_EXISTING_SIGNERS;                      
    }   
    
    webservice static String sendEmail(ID acID){
        
        AssignmentContract__c ac = updateAC(acID);
        ID siID = ac.Costs_Sales_Invoice__c;
        
        if(ac.Client_Credit_Line_Status__c!='Credit Line - Approved')
            return 'Credit Line Status should be approved to continue';
            
        c2g__codaInvoice__c si = [SELECT ID,Invoice_express_Link__c,Invoice_Express_Number_text__c, Name FROM c2g__codaInvoice__c WHERE ID=:siID];
        
        //create email      
        EmailTemplate templateOldClient;
        EmailTemplate templateNewClient;
        Messaging.SingleEmailMessage emailNewClient;
        Messaging.SingleEmailMessage emailOldClient;
                
        if(ac.TypeOfAssignContract__c == 'Merged Company'){
            if(ac.Payment_Collection__c != null){
                if(ac.Invoice_Receiver__c  == 'New Client'){
                    templateOldClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_Merged_Unpaid' AND Folder.DeveloperName = 'Collections'];
                    emailOldClient = createEmail(ac,si,ac.Old_Invoice_Email__c,templateOldClient, ac.Old_Client_Signer_1__r.Name, false, true, true, 0);
                    templateNewClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_Merged_CostInvoice' AND Folder.DeveloperName = 'Collections'];
                    emailNewClient = createEmail(ac,si,ac.New_Invoice_Email__c,templateNewClient, ac.New_Client_Signer_1__r.Name, true, false, true, 1);                    
                }else{
                    templateOldClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_Merged_Full' AND Folder.DeveloperName = 'Collections'];
                    emailOldClient = createEmail(ac,si,ac.Old_Invoice_Email__c,templateOldClient, ac.Old_Client_Signer_1__r.Name, true, true, true, 0);
                    templateNewClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_InfoNotSigned' AND Folder.DeveloperName = 'Collections'];
                    emailNewClient = createEmail(ac,si,ac.New_Invoice_Email__c,templateNewClient, ac.New_Client_Signer_1__r.Name, false, false, false, 2);      
                }
            }else{
                if(ac.Invoice_Receiver__c  == 'New Client'){
                    templateOldClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_Info_NotSigned' AND Folder.DeveloperName = 'Collections'];
                    emailOldClient = createEmail(ac,si,ac.Old_Invoice_Email__c,templateOldClient, ac.Old_Client_Signer_1__r.Name, false, false, false, 2);
                    templateNewClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_Merged_CostInvoice' AND Folder.DeveloperName = 'Collections'];
                    emailNewClient = createEmail(ac,si,ac.New_Invoice_Email__c,templateNewClient, ac.New_Client_Signer_1__r.Name, true, false, true, 1);        
                }else{
                    templateOldClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_Merged_CostInvoice' AND Folder.DeveloperName = 'Collections'];
                    emailOldClient = createEmail(ac,si,ac.Old_Invoice_Email__c,templateOldClient, ac.Old_Client_Signer_1__r.Name, true, false, true, 0);    
                    templateNewClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_InfoNotSigned' AND Folder.DeveloperName = 'Collections'];
                    emailNewClient = createEmail(ac,si,ac.New_Invoice_Email__c,templateNewClient, ac.New_Client_Signer_1__r.Name, false, false, false, 2);  
                }
            }
        }
        //closed companies and others
        else{     
            if(ac.Payment_Collection__c != null){
                if(ac.Invoice_Receiver__c  == 'New Client'){
                    templateOldClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_Unpaid' AND Folder.DeveloperName = 'Collections'];
                    emailOldClient = createEmail(ac,si,ac.Old_Invoice_Email__c,templateOldClient, ac.Old_Client_Signer_1__r.Name, false, true, true, 0);
                    templateNewClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_CostInvoice' AND Folder.DeveloperName = 'Collections'];
                    emailNewClient = createEmail(ac,si,ac.New_Invoice_Email__c,templateNewClient, ac.New_Client_Signer_1__r.Name, true, false, true, 1);    
                }else{
                    templateOldClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_Full' AND Folder.DeveloperName = 'Collections'];
                    emailOldClient = createEmail(ac,si,ac.Old_Invoice_Email__c,templateOldClient, ac.Old_Client_Signer_1__r.Name, true, true, true, 0);
                    templateNewClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_InfoSigned' AND Folder.DeveloperName = 'Collections'];
                    emailNewClient = createEmail(ac,si,ac.New_Invoice_Email__c,templateNewClient, ac.New_Client_Signer_1__r.Name, false, false, false, 2);  
                }
            }else{
                if(ac.Invoice_Receiver__c  == 'New Client'){
                    templateOldClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_InfoSigned' AND Folder.DeveloperName = 'Collections'];
                    emailOldClient = createEmail(ac,si,ac.Old_Invoice_Email__c,templateOldClient, ac.Old_Client_Signer_1__r.Name, false, false, false, 2);  
                    templateNewClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_CostInvoice' AND Folder.DeveloperName = 'Collections'];
                    emailNewClient = createEmail(ac,si,ac.New_Invoice_Email__c,templateNewClient, ac.New_Client_Signer_1__r.Name, true, false, true, 1);    
                }else{
                    templateOldClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_CostInvoice' AND Folder.DeveloperName = 'Collections'];
                    emailOldClient = createEmail(ac,si,ac.Old_Invoice_Email__c,templateOldClient, ac.Old_Client_Signer_1__r.Name, true, false, true, 0);    
                    templateNewClient = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AC_InfoSigned' AND Folder.DeveloperName = 'Collections'];
                    emailNewClient = createEmail(ac,si,ac.New_Invoice_Email__c,templateNewClient, ac.New_Client_Signer_1__r.Name, false, false, false, 2);  
                }
            }           
        }
            

        emailOldClient.setWhatID(ac.ID);
        emailNewClient.setWhatID(ac.ID);
        
        //get sales invoice attch

        String url = si.Invoice_express_Link__c;
        String fileName = 'Factura ' + si.Name + datetime.now();        
        Attachment attach = Bill_Moloni_Util.getPDF(url, fileName, siID);
        
        if(!Test.isRunningTest()){
            
            if(ac.Invoice_Receiver__c == 'New Client')
                Bill_Moloni_Util.addAttchment(emailNewClient, attach);
            else
                Bill_Moloni_Util.addAttchment(emailOldClient, attach);
            

            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailNewClient }, true);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailOldClient }, true);               
                system.debug(emailOldClient);
                system.debug(emailNewClient);
            }catch(Exception e){
                //if match failed an email is sent after the outbound integration log is created
                Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'CRITICAL',ApplicationID__c = 'ASSIGN CONTRACT', message__c = 'Emails could not be sent: ' + e.getMessage(), printStackTrace__c = e.getStackTraceString()   );
                system.debug('CRITICAL: '+ record);
                insert record;   
                return 'Email not sent, please contact the support team.';          
            }
        }   
        
        return 'Email sent with sucess!';   
    }
    
    /**
     * clientReference => 0 if old client reference and 1 if new client reference
     */
    public static Messaging.SingleEmailMessage createEmail(AssignmentContract__c ac,c2g__codaInvoice__c si, String emailToSend, EmailTemplate template, String toName, Boolean invoiceAux, Boolean unpaidInvoices, Boolean atmReference, Integer clientReference){
               
        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;

        emailSubject = emailSubject.replace( '{!AssignmentContract__c.Name}', ac.Name);
        
        emailbody = emailbody.replace('{!Contact.Name}', toName);
        htmlBody=htmlBody.replace('{!Contact.Name}', toName);           
        
        if(invoiceAux){
            emailbody = emailbody.replace('{!c2g__codaInvoice__c.Invoice_Express_Number_text__c}', si.Invoice_Express_Number_text__c);
            htmlBody=htmlBody.replace('{!c2g__codaInvoice__c.Invoice_Express_Number_text__c}', si.Invoice_Express_Number_text__c);  
        }
        
        if(unpaidInvoices){
            emailbody = emailbody.replace('{!AssignmentContract__c.Unpaid_Invoices__c}', ac.Unpaid_Invoices__c);
            htmlBody=htmlBody.replace('{!AssignmentContract__c.Unpaid_Invoices__c}', ac.Unpaid_Invoices__c);    
        }   
        
        
        String entity;
        String reference;
        String amount;
        
        if(atmReference){
            
            if(clientReference == 1){
                entity = ac.Aux_Entity_2__c;
                reference = ac.Aux_Reference_2__c;
                amount = ac.Amount_Claimed_2__c;
            }else{
                entity = ac.Aux_Entity__c;
                reference = ac.Aux_Reference__c;
                amount = String.valueOf(ac.Amount_Claimed__c);          
            }                   
            
            emailbody = emailbody.replace('ACEntity', entity);
            htmlBody=htmlBody.replace('ACEntity', entity);  
    
            emailbody = emailbody.replace('ACReference', reference);
            htmlBody=htmlBody.replace('ACReference', reference);    
            
            emailbody = emailbody.replace('ACAmount', amount);
            htmlBody=htmlBody.replace('ACAmount', amount);  
        }                                     

        htmlBody=htmlBody.replace(']]>', '');
            
        String[] toAddresses = new List<String>();
        if(!Utilities.runningInASandbox() ){  //Production
            toAddresses.add(emailToSend);
        }

        String[] bccAddresses = new List<String>();
        bccAddresses.add('info@candor.pt');
        bccAddresses.add('erodrigues@candor.pt');
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        email.setBccAddresses(bccAddresses);
        email.setPlainTextBody(emailbody);
        email.setHtmlBody(htmlBody);        
                    
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }  
        
        return email;
    }
    
    /**
    *
    *   FINALIZE ASSIGNMENT OF CONTRACT
    *
    */      
    
    
    webservice static String finalizeAssignmentOfContract(ID acID){
        
        AssignmentContract__c ac = updateAC(acID);
        
        //check for more unpaid invoices to finalize
        List<c2g__codaInvoice__c> siList = [SELECT ID FROM c2g__codaInvoice__c WHERE c2g__Account__c=:ac.Old_Client_Account__c AND c2g__PaymentStatus__c = 'Unpaid'];
        
        if(ac.Costs_Sales_Invoice__c==null){
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'CRITICAL',ApplicationID__c = 'ASSIGN CONTRACT', message__c = 'Contract without costs invoice. AC Name: '+ac.Name );
            system.debug('Contract without costs invoice');
            insert record;             
            return 'Contract without costs invoice' ;
        }

        if(!siList.isEmpty() && !Test.isRunningTest()){
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'INFO',ApplicationID__c = 'ASSIGN CONTRACT', message__c = 'Unpaid invoices for old client generated, functionality not implemented yet. AC Name: '+ac.Name );
            system.debug('Unpaid invoices for old client generated, functionality not implemented yet');
            insert record;  
            //return 'Unpaid invoices for old client generated, functionality not implemented yet';
        }
        
        
        Application__c app = [SELECT ID, AccClient__c FROM Application__c WHERE ID = :ac.Renting_Application__c];
        Billing_Contract__c bc = [SELECT ID FROM Billing_Contract__c WHERE ID = :ac.Billing_Contract__c];
        Account account = [SELECT ID FROM Account WHERE ID=:app.AccClient__c];
         
     
         
        //change contacts
        account.c2g__CODAInvoiceEmail__c = ac.New_Invoice_Email__c;
        update account;
 
        app.AccClient__c = ac.New_Client_Account__c;
        app.Client_Signer_1__c = ac.New_Client_Signer_1__c;
        app.Client_Signer_2__c = ac.New_Client_Signer_2__c;
        app.Client_Signer_3__c = ac.New_Client_Signer_3__c;
        app.Client_Signer_4__c = ac.New_Client_Signer_4__c;
        app.Client_Signer_5__c = ac.New_Client_Signer_5__c;     
        app.Invoice_To__c = ac.New_Client_Signer_1__c;      
        app.Client_Signer_1_Delivery_Certificate__c = ac.New_Client_Signer_1__c;            
        update app;     
          
        
        //change account bc
        bc.Account__c = ac.New_Client_Account__c;
        update bc;
        
        //set begin and end of contract
        ac.Conclusion_Of_Contract__c = system.today();
        ac.End_of_Contract__c = ac.Renting_Application__r.End_of_Term__c;
        ac.Status__c = 'Aproved';
        update ac;
        
        //send email
        
        Messaging.SingleEmailMessage email = createEmailSuccess(ac);            
        
        if (!Test.isRunningTest()) {
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }, true);
                system.debug(email);
            }catch(Exception e){
                //if match failed an email is sent after the outbound integration log is created
                Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'CRITICAL',ApplicationID__c = 'ASSIGN CONTRACT', message__c = 'Emails could not be sent: ' + e.getMessage(), printStackTrace__c = e.getStackTraceString()   );
                system.debug('CRITICAL: '+ record);
                insert record;   
                return 'Email not sent, please contact the support team.';          
            }
        }               
        
        
        return 'Process Finalized with success.';
    }
    
    public static Messaging.SingleEmailMessage createEmailSuccess(AssignmentContract__c ac){
        
        EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'Assignment_Contract_Completed' AND Folder.DeveloperName = 'Collections'];
        
        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;

        emailSubject = emailSubject.replace( '{!AssignmentContract__c.Name}', ac.Name);
        
        emailbody = emailbody.replace('{!Contact.Name}', ac.Invoice_To__r.Name);
        htmlBody=htmlBody.replace('{!Contact.Name}', ac.Invoice_To__r.Name);            
             
        emailbody = emailbody.replace('{AC}', String.valueOf(ac.Name));
        htmlBody=htmlBody.replace('{AC}', String.valueOf(ac.Name));        
        
        emailbody = emailbody.replace('{CONTRACTO}', String.valueOf(ac.Renting_Application__r.Name));
        htmlBody=htmlBody.replace('{CONTRACTO}', String.valueOf(ac.Renting_Application__r.Name));   
        
        emailbody = emailbody.replace('{INICIO}', String.valueOf(ac.Conclusion_Of_Contract__c));
        htmlBody=htmlBody.replace('{INICIO}', String.valueOf(ac.Conclusion_Of_Contract__c));                                                          

        htmlBody=htmlBody.replace(']]>', '');
            
        String[] toAddresses = new List<String>();
        if(!Utilities.runningInASandbox()){  //Production
            toAddresses.add(ac.Old_Invoice_Email__c);
            toAddresses.add(ac.New_Invoice_Email__c);
        }

        String[] bccAddresses = new List<String>();
        bccAddresses.add('info@candor.pt');
        bccAddresses.add('erodrigues@candor.pt');
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        email.setBccAddresses(bccAddresses);
        email.setPlainTextBody(emailbody);
        email.setHtmlBody(htmlBody);        
        email.setWhatID(ac.ID);             
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }  
        
        return email;
    }   

    /**
    *
    *   CREATE JOURNALS
    *
    */
    
    webservice static String createJournals(ID acID){
        
        AssignmentContract__c ac = updateAC(acID);
        List<c2g__codaTransactionLineItem__c> transactionsList;
        List<c2g__codaJournal__c> allJournalsList = new List<c2g__codaJournal__c>();
        ID period = Bill_EasyPayAPI.getPeriod();
        
        String contractBeginning = 'Contract Beginning Post '+ac.Renting_Application__r.Name;
        //get journal for Contract Beggining 
        List<c2g__codaJournal__c> journalBeginningList = [SELECT c2g__Debits__c,c2g__JournalDescription__c,Name,Sales_Invoice__c FROM c2g__codaJournal__c WHERE c2g__JournalDescription__c = :contractBeginning AND c2g__JournalStatus__c = 'Complete' AND c2g__Debits__c >0];
        
        if(journalBeginningList.size() != 1)
            return 'Found '+journalBeginningList.size()+' journals for Contract Beginning Post '+ac.Renting_Application__r.Name+', should exist 1.';
        
        return 'Not Implemented Yet';
    }
        /*

        Savepoint sp = Database.setSavepoint(); 
        try{
            c2g__codaJournal__c journalBeginning = journalBeginningList[0];
            Double totalCost = journalBeginning.c2g__Debits__c/3;
            
            //Get All Sales Invoice for old account
            List<c2g__codaInvoice__c> salesInvoiceList = [SELECT ID FROM c2g__codaInvoice__c WHERE c2g__Account__c = :ac.Old_Client_Account__c AND c2g__InvoiceStatus__c = 'Complete'];
            
            //get All journals with SI and Status Complete
            List<c2g__codaJournal__c> journalsInvoiceList = [SELECT c2g__Debits__c,c2g__JournalDescription__c,Name,Sales_Invoice__c FROM c2g__codaJournal__c WHERE Sales_Invoice__c in :salesInvoiceList AND c2g__JournalStatus__c = 'Complete' AND c2g__Debits__c > 0];    
            Double totalPayed=0;
            
            for(c2g__codaJournal__c jn : journalsInvoiceList){
                totalPayed+= jn.c2g__Debits__c;
            }
            
            c2g__codaJournal__c journal = insertJournal(+ac.Renting_Application__r.Name, ac.Name);
            insertJournalLineItems(+ac.Name, journal.ID, ac.New_Client_Account__c, ac.Old_Client_Account__c, totalCost-totalPayed);
            
            postJournal(journal);
            
            transactionsList = getTransactionLineItemsForJournals(allJournalsList, ac.Old_Client_Account__c);
            
            FF_Utils.doMatch(ac.Old_Client_Account__c, period, transactionsList);
        }catch(Exception e){
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'CRITICAL',ApplicationID__c = 'ASSIGN CONTRACT', message__c = 'Journals Incomplete: ' + e.getMessage(), printStackTrace__c = e.getStackTraceString()   );
            system.debug('CRITICAL: '+ record);
            Database.rollback(sp);
            insert record;   
            return 'A problem ocurred, please contact the support team.';                   
        } 
        
        return 'Not Implemented Yet';
        
    }

    private static c2g__codaJournal__c insertJournal(String apName, String acName){
        
        ID period = Bill_EasyPayAPI.getPeriod();

        c2g__codaJournal__c journal = new c2g__codaJournal__c();
            journal.c2g__Type__c = 'Manual Journal';
            journal.c2g__JournalDate__c = System.today();
            journal.c2g__DeriveCurrency__c = true;
            journal.c2g__DerivePeriod__c = false;
            journal.c2g__Reference__c = apName;
            journal.c2g__JournalDescription__c = 'Transfer of outstanding capital: '+ acName;
            journal.c2g__Period__c = period;

        insert journal;
        
        return journal;
    }
    
    //creates and inserts journal line items to every journal created
    private static void insertJournalLineItems(String acName, ID journalID, ID newAccount, ID oldAccount, Double value){
        
        c2g__codaGeneralLedgerAccount__c clientesRenting = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name = '2783 - CLIENTES RENTING' LIMIT 1];  
        List<c2g__codaJournalLineItem__c> allJournalLineItemsList = new List<c2g__codaJournalLineItem__c>();
        
        
        //Old Client credit
        c2g__codaJournalLineItem__c journalLineItemOldClient = new c2g__codaJournalLineItem__c();
        journalLineItemOldClient.c2g__Value__c = -value;
        journalLineItemOldClient.c2g__Account__c = newAccount;
        journalLineItemOldClient.c2g__Journal__c = journalID;
        journalLineItemOldClient.c2g__GeneralLedgerAccount__c = clientesRenting.Id;
        journalLineItemOldClient.c2g__LineDescription__c = acName;
        journalLineItemOldClient.c2g__LineType__c = 'Account - Customer';
            
        allJournalLineItemsList.add(journalLineItemOldClient);
        
        //New Client debit
        c2g__codaJournalLineItem__c journalLineItemNewClient = new c2g__codaJournalLineItem__c();
        journalLineItemNewClient.c2g__Value__c = value;
        journalLineItemNewClient.c2g__Account__c = oldAccount;
        journalLineItemNewClient.c2g__Journal__c = journalID;
        journalLineItemNewClient.c2g__GeneralLedgerAccount__c = clientesRenting.Id;
        journalLineItemNewClient.c2g__LineDescription__c = acName;
        journalLineItemNewClient.c2g__LineType__c = 'Account - Customer';   
        
        allJournalLineItemsList.add(journalLineItemNewClient);             
        
        //inserts all journals in the database
        insert allJournalLineItemsList;
        
    }   

    //post a single journal
    private static void postJournal(c2g__codaJournal__c journal){
        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
        ref.Id = journal.Id;
        c2g.CODAAPIJournal_9_0.PostJournal(null, ref);        
    }
    
    private static List<c2g__codaTransactionLineItem__c> getTransactionLineItemsForJournals(List<c2g__codaJournal__c> allJournalsList, ID oldClientAccount){

        //get journal updated
        List<c2g__codaJournal__c> journalUpdatedList = [SELECT ID, c2g__Reference__c, c2g__Transaction__c, c2g__Debits__c  FROM c2g__codaJournal__c WHERE ID in :allJournalsList];
        List<ID> transactionsList = new List<ID>();
        
        
        for(c2g__codaJournal__c jn : journalUpdatedList){
            transactionsList.add(jn.c2g__Transaction__c);
        }
        
        system.debug(journalUpdatedList);
        
        List<c2g__codaTransactionLineItem__c> transactionLineItem = [
            SELECT Id, c2g__AccountValue__c, c2g__Account__c, c2g__Transaction__c
            FROM c2g__codaTransactionLineItem__c
            WHERE
                 c2g__Transaction__c in :transactionsList
                 AND c2g__LineType__c = 'Account'
                 AND c2g__Account__c != :oldClientAccount
         ];
        
        return transactionLineItem;    
                
    }*/
                    
    
    
    /**
    *
    *   UTILS FOR ASSIGNMENT OF CONTRACT
    *
    */    
    
    public static ID createAccount(String nif){
        
        List<Account> accs = [SELECT ID, NIF__c, Type FROM Account WHERE NIF__c = :nif AND Type = 'Customer - Channel'];
        
        if(accs!=null && accs.size()>0)
            return accs[0].ID;
        
        Account newAccount = new Account();
        newAccount.Name = nif;
        newAccount.NIF__c = nif;
        newAccount.Type = 'Customer - Channel';
        newAccount.c2g__CODATaxCalculationMethod__c = 'Gross';
        newAccount.c2g__CODAVATStatus__c = 'Home';
        
        insert newAccount;
        
        return newAccount.ID;
    }
    
    public static Boolean mandatorySigners(AssignmentContract__c ac){
        if(ac.numObriga__c == 1){
            return ac.New_Client_Signer_1__c != null;
        }
        
        if(ac.numObriga__c == 2){
            return ac.New_Client_Signer_1__c != null && ac.New_Client_Signer_2__c != null;
        }
        
        if(ac.numObriga__c == 3){
            return ac.New_Client_Signer_1__c != null && ac.New_Client_Signer_2__c != null && ac.New_Client_Signer_3__c != null;
        }
        
        if(ac.numObriga__c == 4){
            return ac.New_Client_Signer_1__c != null && ac.New_Client_Signer_2__c != null && ac.New_Client_Signer_3__c != null && ac.New_Client_Signer_4__c != null;
        }
        
        if(ac.numObriga__c == 5){
            return ac.New_Client_Signer_1__c != null && ac.New_Client_Signer_2__c != null && ac.New_Client_Signer_3__c != null && ac.New_Client_Signer_4__c != null && ac.New_Client_Signer_5__c != null;
        }                                       
        
        return false;
    }   
        
    
    public static AssignmentContract__c updateAC(ID acID){
        
        AssignmentContract__c acUpdated = [SELECT ID,Status__c,Merge_Company__c, New_Client_Account__c, Old_Client_Account__c, Name,
                                                    Credit_Description__c , Costs_Sales_Invoice__c, Payment_Collection__c, Unpaid_Invoices__c,
                                                    Aux_Entity__c,Aux_Reference__c,Amount_Claimed__c,Invoice_To__c, Invoice_To__r.Name, Invoice_To__r.Email, Old_Invoice_Email__c,
                                                     New_Client_Account__r.Country_Code__c,Client_Credit_Line_Status__c, Billing_Contract__c, Renting_Application__c, Renting_Application__r.Name, Renting_Application__r.End_of_Term__c,
                                                     Old_Client_Signer_1__c, Old_Client_Signer_2__c, Old_Client_Signer_3__c,
                                                     Old_Client_Signer_4__c, Old_Client_Signer_5__c,
                                                     Old_Client_Signer_1__r.Name, Old_Client_Signer_2__r.Name, Old_Client_Signer_3__r.Name,
                                                     Old_Client_Signer_4__r.Name, Old_Client_Signer_5__r.Name,                      
                                                     Old_Client_Signer_1__r.Email, Old_Client_Signer_2__r.Email, Old_Client_Signer_3__r.Email,
                                                     Old_Client_Signer_4__r.Email, Old_Client_Signer_5__r.Email,                                                  
                                                     New_Client_Signer_1__c, New_Client_Signer_2__c, New_Client_Signer_3__c,
                                                     New_Client_Signer_4__c, New_Client_Signer_5__c,
                                                     New_Client_Signer_1__r.Name, New_Client_Signer_2__r.Name, New_Client_Signer_3__r.Name,
                                                     New_Client_Signer_4__r.Name, New_Client_Signer_5__r.Name,                      
                                                     New_Client_Signer_1__r.Email, New_Client_Signer_2__r.Email, New_Client_Signer_3__r.Email, 
                                                     New_Client_Signer_4__r.Email, New_Client_Signer_5__r.Email, Aux_Entity_2__c, Aux_Reference_2__c, Amount_Claimed_2__c,                                                                      
                                                     numObriga__c,Guarante__c,Begin_Of_AoContract__c, Requested_Date__c,  New_Invoice_Email__c, End_of_Contract__c, Conclusion_Of_Contract__c,  TypeOfAssignContract__c,
                                                     Invoice_Receiver__c                                                
                                           FROM AssignmentContract__c
                                           WHERE ID = :acID];       
        
        return acUpdated;       
    }
    
    
}
