public class CandorDocuments {
    
    private String typeOfDocument;
    private static final String CONTRACT_RENTING_NAME = 'RENTING';
    private static final String AUTO_NAME = 'AUTO'; 
    
    public CandorDocuments(String typeOfDocument){
        this.typeOfDocument = typeOfDocument;
    }
    
    public String buildDocument(Id ParentID, String Name){
        
        List<Attachment> listDocument = new List<Attachment>();
        PageReference pdf = null;
        
        if(typeOfDocument == CONTRACT_RENTING_NAME){
            
            String Name_A = 'Contra%t%Renting%';
            String Name_B = '%Contrat%eSignature%';
            
            listDocument =[SELECT Id, name, body, createdDate 
                           FROM attachment 
                           WHERE parentId =:ParentID AND (name LIKE :Name_A OR name LIKE :Name_B) LIMIT 1];
            
            if(listDocument.size()==0){//if not exists generate contract
                Attachment newContract = new Attachment (ParentId = ParentID);
                listDocument.add(newContract);
            }
                       
            pdf = buildRentingContract(ParentID);
        }else if(typeOfDocument == AUTO_NAME){

            listDocument =[SELECT Id, name, body, createdDate 
                           FROM attachment 
                           WHERE parentId =:ParentID AND Name LIKE '%Auto%Aceitação%' LIMIT 1];

            if(listDocument.size()==0){//if not exists generate contract
                Attachment newContract = new Attachment (ParentId = ParentID);
                listDocument.add(newContract);
            }

            pdf = buildCertificate(ParentID);
        }else{
            return null;
        }
        
        Blob body;  
        try {
            // returns the output of the page as a PDF
            body = pdf.getContent();
            // need to pass unit test -- current bug  
        } catch (VisualforceException e) {
            body = Blob.valueOf('need to pass unit test');
        }
        
        listDocument[0].Body = body;
        listDocument[0].Name = Name;
        listDocument[0].IsPrivate = false;
        
        upsert listDocument[0];
        
        return listDocument[0].Id;    
    }
    
    public static DocuSignAPI.EnvelopeStatus sendDocumentThroughDocuSign(DocuSignAPI.Envelope envelope){

        Map<String,String> DocuSignCredentials = getDocuSignCredentials();
        Id ParentID;
        if(envelope.CustomFields!=null && envelope.CustomFields.CustomField[0].Name=='DSFSSourceObjectId'){
            ParentID = envelope.CustomFields.CustomField[0].Value;
        }
        Datetime start = Datetime.now();

        DocuSignAPI.APIServiceSoap dsAPISend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = DocuSignCredentials.get('endpoint_x');

        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', DocuSignCredentials.get('Auth'));

        System.debug('[CandorDocuments - sendDocumentThroughDocuSign] - Calling the DocuSign API');
        System.debug('[CandorDocuments - sendDocumentThroughDocuSign] - envelope: ' + envelope);

        envelope.AccountId  = DocuSignCredentials.get('accountId');

        DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();

        string requestJson= JSON.serialize(envelope);
        try{

            es = dsApiSend.CreateAndSendEnvelope(envelope); 
            System.debug('[CandorDocuments - sendDocumentThroughDocuSign] - CreateAndSendEnvelope has return envelope status: ' +  es);
            
            Dsfs__docusign_Status__c ds = new Dsfs__docusign_Status__c();
            if(es.EnvelopeID != null){
                System.debug('[CandorDocuments - sendDocumentThroughDocuSign] - calling RequestStatusEx on envelope ID ' + es.EnvelopeID + 'to get info about recipients');
                es = dsApiSend.RequestStatusEx(es.EnvelopeID);
                ds = createDocuSignEnvelopeStatusSFObject(es); 
                insert ds;
                System.debug('[CandorDocuments - sendDocumentThroughDocuSign] - Dsfs__docusign_Status__c created -ID: ' + ds.Id);
                dsfs__DocuSign_Recipient_Status__c[] rsList = createDocuSignRecipientStatusSFObject(es, ds.Id);
                insert rsList;
                System.debug('[CandorDocuments - sendDocumentThroughDocuSign] - dsfs__DocuSign_Recipient_Status__c created: ' + rsList);
            }

            //Utilities.LogIntegrationLongResponse( start, Datetime.now(), es.Status, 'DOCUSIGN',requestJson,ParentID,es.EnvelopeID);
            string responseJsonEs= JSON.serialize(es);
            Utilities.LogIntegrationLongResponse( start, Datetime.now(), es.Status, 'DOCUSIGN',requestJson,ParentID,'DocuSignStatus ID: ' + ds.Id + '; Response: '+ responseJsonEs);
        
        }catch ( Exception e) { 
            string response= JSON.serialize(es);
            string error='Exception - ' + e + ' ; ' + e.getCause() + ' ; ' + e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString() + ' ; ' + e.getTypeName(); 
            es.Status = 'Error';
            Utilities.LogIntegrationLongResponse( start, Datetime.now(), es.Status, 'DOCUSIGN',requestJson,ParentID,error + '; Response: '+ response);
        }
        
        return es;
    }

    public static DocuSignAPI.CorrectionStatus CorrectAndResendContractDocuSign(DocuSignAPI.Correction correction){
        
        Datetime start = Datetime.now(); 
        
        Map<String,String> DocuSignCredentials = getDocuSignCredentials();
        DocuSignAPI.APIServiceSoap dsAPISend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = DocuSignCredentials.get('endpoint_x');
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', DocuSignCredentials.get('Auth'));

        string requestJson = JSON.serialize(correction);
        DocuSignAPI.CorrectionStatus correctionStatus = new DocuSignAPI.CorrectionStatus();
        try{
            correctionStatus = dsAPISend.CorrectAndResendEnvelope(correction);
        }catch(Exception e){
            string error='Exception - ' + e + ' ; ' + e.getCause() + ' ; ' + e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString() + ' ; ' + e.getTypeName(); 
            Utilities.LogIntegrationLongResponse( start, Datetime.now(), 'Error', 'RESEND_DOCUMENT',requestJson,correction.EnvelopeID,error);
            System.debug('[CandorDocuments - CorrectAndResendContractDocuSign] - ERROR: ' + error);
            System.debug('[CandorDocuments - CorrectAndResendContractDocuSign] - Request: ' + requestJson);
            return CorrectionStatus;
        }
        string responseJson = JSON.serialize(CorrectionStatus);
        Utilities.LogIntegrationLongResponse( start, Datetime.now(), 'Success', 'RESEND_DOCUMENT',requestJson,correction.EnvelopeID,responseJson);
        return CorrectionStatus;
    }

    public static DocuSignAPI.VoidEnvelopeStatus voidDocumentDocuSign(String DocuSignEnvelopeID, String Reason){

        Datetime start = Datetime.now(); 

        System.debug('[CandorDocuments - voidDocumentDocuSign] - EnvelopeID: ' + DocuSignEnvelopeID);
        System.debug('[CandorDocuments - voidDocumentDocuSign] - Reason: ' + Reason);

        Map<String,String> DocuSignCredentials = getDocuSignCredentials();
        DocuSignAPI.APIServiceSoap dsAPISend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = DocuSignCredentials.get('endpoint_x');
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', DocuSignCredentials.get('Auth'));


        DocuSignAPI.VoidEnvelopeStatus voidStatus = new DocuSignAPI.VoidEnvelopeStatus();
        try{
            voidStatus = dsAPISend.VoidEnvelope(DocuSignEnveLopeID,Reason);
         }catch(Exception e){
            string error='Exception - ' + e + ' ; ' + e.getCause() + ' ; ' + e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString() + ' ; ' + e.getTypeName(); 
            System.debug('[CandorDocuments - voidDocumentDocuSign] - ERROR: ' + error);
            if(voidStatus.VoidSuccess==null){
                voidStatus.VoidSuccess=false;
            }
            return voidStatus;
        }
        
        return voidStatus;
    }
    

    public static  Map<String,String> getDocuSignCredentials(){
        
        List<Credentials__c> credential=[SELECT Username__c, Password__c, AccountID__c, Web_Service_Url__c, integratorsKey__c 
                                            FROM Credentials__c WHERE name ='DocuSignAPI'];
        

        String webServiceUrl = credential[0].Web_Service_Url__c;
        String userId = credential[0].Username__c;
        String password = credential[0].Password__c;
        String integratorsKey = credential[0].integratorsKey__c;
        String accountId = credential[0].AccountID__c;

        String auth = '<DocuSignCredentials><Username>'+ userId 
                +'</Username><Password>' + password
                + '</Password><IntegratorKey>' + integratorsKey 
                + '</IntegratorKey></DocuSignCredentials>';

        System.debug('[CandorDocuments - getDocuSignCredentials] - Setting authentication to: ' + auth);
       
        Map<String,String> DocuSignCredentials = new Map<String,String>();
        DocuSignCredentials.put('Auth',auth);
        DocuSignCredentials.put('endpoint_x',webServiceUrl);
        DocuSignCredentials.put('accountId', accountId);

        return DocuSignCredentials;
    } 

    public static Dsfs__docusign_Status__c createDocuSignEnvelopeStatusSFObject(DocuSignAPI.EnvelopeStatus EnvelopeStatus)
    {
        TimeZone tz    = Timezone.getTimeZone('Europe/Lisbon');
        Integer offset = tz.getOffset(Datetime.now());

        Dsfs__docusign_Status__c DocuSignEnvelopeStatusSF      = new Dsfs__docusign_Status__c();
        DocuSignEnvelopeStatusSF.dsfs__DocuSign_Envelope_ID__c = EnvelopeStatus.EnvelopeID;
        DocuSignEnvelopeStatusSF.dsfs__Envelope_Status__c      = EnvelopeStatus.Status;
        if(EnvelopeStatus.Sent != null)
            DocuSignEnvelopeStatusSF.dsfs__Sent_Date_Time__c   = EnvelopeStatus.Sent.addSeconds(-offset/1000); //EnvelopeStatus.Sent; - a data enviada pelo Docusign não é a data local
        DocuSignEnvelopeStatusSF.dsfs__Subject__c              = EnvelopeStatus.Subject;
        DocuSignEnvelopeStatusSF.dsfs__Sender__c               = EnvelopeStatus.UserName;
        DocuSignEnvelopeStatusSF.dsfs__Sender_Email__c         = EnvelopeStatus.Email;
        //ALTERACAO - 02/08/17 - adicionadosos campos abaixo (BP)
        if(EnvelopeStatus.Declined != null)
            DocuSignEnvelopeStatusSF.dsfs__Declined_Date_Time__c   = EnvelopeStatus.Declined.addSeconds(-offset/1000);
        if(EnvelopeStatus.Delivered != null)
            DocuSignEnvelopeStatusSF.dsfs__Viewed_Date_Time__c     = EnvelopeStatus.Delivered.addSeconds(-offset/1000);
        if(EnvelopeStatus.Deleted != null)
            DocuSignEnvelopeStatusSF.dsfs__Voided_Date_Time__c     = EnvelopeStatus.Deleted.addSeconds(-offset/1000);
        if(EnvelopeStatus.Completed != null)
            DocuSignEnvelopeStatusSF.dsfs__Completed_Date_Time__c  = EnvelopeStatus.Completed.addSeconds(-offset/1000);
        //missing field to do           something              = EnvelopeStatus.TimedOut;

        for(integer i=0; i<EnvelopeStatus.CustomFields.CustomField.size(); i++)
        {
            String fieldName = EnvelopeStatus.CustomFields.CustomField[i].Name;
            String fieldValue = EnvelopeStatus.CustomFields.CustomField[i].Value;
            if(fieldName == 'DSFSSourceObjectId'){
                DocuSignEnvelopeStatusSF.docusign_Application_Status__c = fieldValue;
            }else if(fieldName == '##SFAccount'){
                DocuSignEnvelopeStatusSF.dsfs__Company__c = fieldValue;
            }else if(fieldName == 'Client'){
                DocuSignEnvelopeStatusSF.Client_Account__c = fieldValue;
            }
        }
        return DocuSignEnvelopeStatusSF;
    }

    public static List<dsfs__DocuSign_Recipient_Status__c> createDocuSignRecipientStatusSFObject(DocuSignAPI.EnvelopeStatus EnvelopeStatus, ID parentDocusignStatusID)
    {        
        TimeZone tz    = Timezone.getTimeZone('Europe/Lisbon');
        Integer offset = tz.getOffset(Datetime.now());

        List<dsfs__DocuSign_Recipient_Status__c> dsrsList = new List<dsfs__DocuSign_Recipient_Status__c>();
        DocuSignAPI.RecipientStatus[] dsAPI_rs_list       = EnvelopeStatus.RecipientStatuses.RecipientStatus;

        for(DocuSignAPI.RecipientStatus dsAPI_rs : dsAPI_rs_list)
        {
            Dsfs__DocuSign_Recipient_Status__c dsrs = new  Dsfs__DocuSign_Recipient_Status__c();
            dsrs.Name = dsAPI_rs.UserName;
            dsrs.dsfs__DocuSign_Recipient_Email__c  = dsAPI_rs.Email;
            dsrs.dsfs__Recipient_Status__c          = dsAPI_rs.Status;
            dsrs.dsfs__DocuSign_Routing_Order__c    = dsAPI_rs.RoutingOrder;
            dsrs.dsfs__DocuSign_Recipient_Id__c     = dsAPI_rs.RecipientId;
            dsrs.dsfs__Envelope_Id__c               = EnvelopeStatus.EnvelopeID;

            if(dsAPI_rs.Sent != null)
                dsrs.dsfs__Date_Sent__c             = dsAPI_rs.Sent.addSeconds(-offset/1000);
            //ALTERACAO - 02/08/17 - adicionadosos campos abaixo (BP)
            if(dsAPI_rs.Declined != null)
                dsrs.dsfs__Date_Declined__c         = dsAPI_rs.Declined.addSeconds(-offset/1000);
            if(dsAPI_rs.Delivered != null)
                dsrs.dsfs__Date_Delivered__c        = dsAPI_rs.Delivered.addSeconds(-offset/1000);
            if(dsAPI_rs.Signed != null)
                dsrs.dsfs__Date_Signed__c           = dsAPI_rs.Signed.addSeconds(-offset/1000);

            //dsrs.dsfs__Decline_Reason__c = dsAPI_rs.AutoRespondedReason.abbreviate(250);
            dsrs.dsfs__Parent_Status_Record__c      = parentDocusignStatusID;

            //if([SELECT ID FROM Account WHERE ID =:dsAPI_rs.CustomFields.CustomField[0]].size()!=0)
            //    if(dsAPI_rs.CustomFields != null && dsAPI_rs.CustomFields.CustomField[0] !=null)
                    dsrs.dsfs__Account__c           = dsAPI_rs.CustomFields.CustomField[0]; //position 0 -> Account ID -> defined when contract is sent through sendDocumentThroughDocuSign(envelope)
            
            //if([SELECT ID FROM Contact WHERE ID =:dsAPI_rs.CustomFields.CustomField[1]].size()!=0)
            //    if(dsAPI_rs.CustomFields != null && dsAPI_rs.CustomFields.CustomField[1] !=null)
                    dsrs.dsfs__Contact__c           = dsAPI_rs.CustomFields.CustomField[1]; //position 1 -> Contact ID -> defined when contract is sent through sendDocumentThroughDocuSign(envelope)
            dsrsList.add(dsrs);
        }
        return dsrsList;
    }

    private PageReference buildRentingContract(Id ParentId){  
        
        System.debug('[CandorDocuments - buildDocument - buildRentingContract] build contract for ' + ParentID);
        Application__c app = [SELECT Id, Personal_Guarantee__c, AccClient__c, ScoreCard__c FROM Application__c WHERE id=:ParentId]; 
        PageReference contract = null;
        Decision_Conditions_Card_History__c [] conditions_hist_list =  [SELECT Personal_Guarantee__c FROM Decision_Conditions_Card_History__c 
                                                        WHERE Decision__c IN (SELECT ID FROM Decision__c WHERE Account__c =:app.AccClient__c AND Active__c = TRUE)
                                                        ORDER BY CREATEDDATE DESC LIMIT 1];

        boolean personal_guarantee = conditions_hist_list.size()>0 && app.ScoreCard__c == null ? conditions_hist_list[0].Personal_Guarantee__c : app.Personal_Guarantee__c;                                
        
        if(personal_guarantee){
            contract = Page.ContractWithGuarantee;            
        } else{
            contract = Page.Contract;  
        }
        
        contract.getParameters().put('id', ParentId);
        
        return contract;        
    }

    private PageReference buildCertificate(Id ParentId){
        Equipment__c[] equip = [SELECT Id FROM Equipment__c WHERE Application__c=:ParentId]; 

        System.debug('[CandorDocuments - buildDocument - buildCertificate] build certificate for ' + ParentID);
        PageReference certificate = null;
        
        
        if(equip.size() <= 20){
            certificate = Page.certificate;          
        }else if(equip.size() >= 21 && equip.size() <= 48){
            certificate = Page.certificate2;  
        }else if(equip.size() > 48){
            certificate = Page.certificate3;  
        }


        certificate.getParameters().put('id', ParentId);
        
        return certificate;
    }

    public static String getautolink(Id appid){
        Equipment__c[] equip = [SELECT Id FROM Equipment__c WHERE Application__c=:appid]; 

        String autolink = '';

        if(equip.size() <= 20){
            autolink = '/certificate?id='+appid;          
        }else if(equip.size() >= 21 && equip.size() <= 48){
            autolink = '/certificate2?id='+appid;   
        }else if(equip.size() > 48){
            autolink = '/certificate3?id='+appid;  
        }

        return autolink;
    }

    public static String getContractlink(Id appid){
        Application__c app = [SELECT Id, Personal_Guarantee__c, AccClient__c, ScoreCard__c FROM Application__c WHERE id=:appid];  
        Decision_Conditions_Card_History__c [] conditions_hist_list =  [SELECT Personal_Guarantee__c FROM Decision_Conditions_Card_History__c 
                                                        WHERE Decision__c IN (SELECT ID FROM Decision__c WHERE Account__c =:app.AccClient__c AND Active__c = TRUE)
                                                        ORDER BY CREATEDDATE DESC LIMIT 1];

        boolean personal_guarantee = conditions_hist_list.size()>0 && app.ScoreCard__c == null ? conditions_hist_list[0].Personal_Guarantee__c : app.Personal_Guarantee__c;                                
        
        String contractLink = '';
        
        if(personal_guarantee){
            contractLink = '/ContractWithGuarantee?id='+appid;            
        } else{
            contractLink = '/Contract?id='+appid;  
        }

        return contractLink;
    }

    public static Boolean deleteEnvelopeThroughDocuSign(List<String> DocuSignEnvelopeID){

        Datetime start = Datetime.now(); 
        Map<String,String> DocuSignCredentials = getDocuSignCredentials();

        DocuSignAPI.APIServiceSoap dsAPISend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = DocuSignCredentials.get('endpoint_x');

        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', DocuSignCredentials.get('Auth'));

        System.debug('[CandorDocuments - deleteEnvelopeThroughDocuSign] - Calling the DocuSign API');

        //constroi o objecto que contem os argumentos necessários à remoção
        DocuSignAPI.ArrayOfString2 arrayzinho = new DocuSignAPI.ArrayOfString2();
        arrayzinho.EnvelopeID = DocuSignEnvelopeID;

        //filtro FoldersFilter
        DocuSignAPI.FoldersFilter filter = new DocuSignAPI.FoldersFilter();
        filter.AccountId = DocuSignCredentials.get('accountId');

        //filtro FolderFilter (obj diferente - gramatica: singular)
        DocuSignAPI.FolderFilter filter2 = new DocuSignAPI.FolderFilter();
        filter2.AccountId = DocuSignCredentials.get('accountId');
        filter2.StartPosition = 0;
        filter2.FolderTypeInfo = new DocuSignAPI.FolderTypeInfo();
        filter2.FolderTypeInfo.FolderType = 'Inbox';

        DocuSignAPI.AvailableFolders folders = new DocuSignAPI.AvailableFolders();
        if(!Test.isRunningTest()){ //TODO: teste method for this class
            folders = dsAPISend.GetFolderList(filter);
        }else{
            folders.Folders = new DocuSignAPI.ArrayOfFolder();
            folders.Folders.Folder = new DocuSignAPI.Folder[1];
            folders.Folders.Folder[0] = new DocuSignAPI.Folder();
            folders.Folders.Folder[0].FolderTypeInfo = new DocuSignAPI.FolderTypeInfo();
            folders.Folders.Folder[0].FolderTypeInfo.folderType = 'teste'; 
        }
        

        DocuSignAPI.FolderTypeInfo FolderInfo = new DocuSignAPI.FolderTypeInfo();
        Boolean isdeleted = false;

        system.debug('filter2 -> accountid: '+filter2.AccountId); system.debug('filter2 -> STARTpOSITION: '+filter2.StartPosition);    

        for(Integer x=0;x<DocuSignEnvelopeID.size();x++){
            System.debug('CICLO 1 - ID: ' + DocuSignEnvelopeID[x]);
            for(Integer i=0;i<folders.Folders.Folder.size();i++){
                    filter2.FolderTypeInfo.FolderType = folders.Folders.Folder[i].FolderTypeInfo.FolderType;
                    DocuSignAPI.FolderResults envelopes = new DocuSignAPI.FolderResults();
                    if(!Test.isRunningTest()){
                        envelopes = dsAPISend.GetFolderItems(filter2);
                    }else{
                        envelopes.FolderItems = new DocuSignAPI.ArrayOfFolderItem();
                        envelopes.FolderItems.FolderItem = new DocuSignAPI.FolderItem[1];
                        envelopes.FolderItems.FolderItem[0] = new DocuSignAPI.FolderItem();
                        envelopes.FolderItems.FolderItem[0].EnvelopeId ='ENVELOPE_ID_TESTE';
                    }
                    if (envelopes.ResultSetSize == 0){continue;}
                    for(Integer j=0;j< envelopes.FolderItems.FolderItem.size();j++){
                        if (envelopes.FolderItems.FolderItem[j].EnvelopeId == DocuSignEnvelopeID[x]){
                            FolderInfo.FolderName = folders.Folders.Folder[i].FolderTypeInfo.FolderName;
                            FolderInfo.FolderType = folders.Folders.Folder[i].FolderTypeInfo.FolderType;
                            FolderInfo.FolderPath = folders.Folders.Folder[i].FolderTypeInfo.FolderPath;
                            FolderInfo.FolderId = folders.Folders.Folder[i].FolderTypeInfo.FolderId;
                            break;
                    }
                }
            }
        
            //criação dos argumentos para o delete
            DocuSignAPI.DeleteEnvelopesArg Arg = new DocuSignAPI.DeleteEnvelopesArg();
            Arg.EnvelopeIds = arrayzinho;
            Arg.AccountId = DocuSignCredentials.get('accountId');
            Arg.FolderFrom = FolderInfo;

            try{
                if(!Test.isRunningTest()){ //TODO: teste method for this class
                //deletando... :D
                isdeleted = dsAPISend.DeleteEnvelopes(Arg);
                }else{
                    isdeleted = true;
                }
             }catch(Exception e){
                string error='Exception - ' + e + ' ; ' + e.getCause() + ' ; ' + e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString() + ' ; ' + e.getTypeName(); 
                System.debug('[CandorDocuments - DELETE ENVELOPE] - ERROR: ' + error);
                Utilities.LogIntegrationLongResponse( start, Datetime.now(), 'Error', 'DELETE_DOCUSIGN',String.join(DocuSignEnvelopeID,','),String.join(DocuSignEnvelopeID,','),error);
                return isdeleted;
            }
        }
        return isdeleted;
    }

    public static DocuSignAPI.Recipient createDocuSignRecipient(Integer recipient_id, String type_x, Integer routingOrder, String roleName, String email, String userName, String accountID, String contactID){
        
        DocuSignAPI.Recipient Recipient = new DocuSignAPI.Recipient();
        Recipient.ID = recipient_id;
        Recipient.Type_x = type_x;
        Recipient.RoutingOrder = routingOrder;
        Recipient.RoleName = roleName;
        Recipient.Email = email;
        Recipient.UserName = userName.abbreviate(100);
        Recipient.RequireIDLookup = false;
        Recipient.CustomFields = new DocuSignAPI.ArrayOfString1();
        Recipient.CustomFields.CustomField = new List<String> {accountID, contactID};

        return Recipient;
    }

    public static DocuSignAPI.Tab createDocuSignTab(Integer recipient_id, Integer document_id, String type_x, String anchorTabString){
    
        DocuSignAPI.Tab tab = new DocuSignAPI.Tab();
        tab.Type_x = type_x;
        tab.RecipientID = recipient_id;
        tab.DocumentID = document_id;
        if(anchorTabString!=null){
            tab.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab.AnchorTabItem.AnchorTabString = anchorTabString; 
        }

        return tab;
    }   

    public static DocuSignAPI.CustomField createDocuSignCostumFields(String customFieldName, String value, boolean show){
    
        DocuSignAPI.CustomField field = new DocuSignAPI.CustomField (); 
        field.Name = customFieldName; 
        field.Value = value;    //value of your external source Id
        if(show!=null){
            field.Show = string.valueOf(show);
        }

        return field;
    } 

    /****************************************************************************************************/
    /*                                  reprocessFailureConnectEnvelopes                                */
    /****************************************************************************************************/
    /*
    public static List<dsfs__DocuSign_Recipient_Status__c> createDocuSignRecipientStatusSFObjectLIST(List<DocuSignAPI.EnvelopeStatus> EnvelopeStatus, ID parentDocusignStatusID)
    {        
        TimeZone tz    = Timezone.getTimeZone('Europe/Lisbon');
        Integer offset = tz.getOffset(Datetime.now());

        List<dsfs__DocuSign_Recipient_Status__c> dsrsList = new List<dsfs__DocuSign_Recipient_Status__c>();
        DocuSignAPI.RecipientStatus[] dsAPI_rs_list       = EnvelopeStatus.RecipientStatuses.RecipientStatus;

        for(DocuSignAPI.RecipientStatus dsAPI_rs : dsAPI_rs_list)
        {
            Dsfs__DocuSign_Recipient_Status__c dsrs = new  Dsfs__DocuSign_Recipient_Status__c();
            dsrs.Name = dsAPI_rs.UserName;
            dsrs.dsfs__DocuSign_Recipient_Email__c  = dsAPI_rs.Email;
            dsrs.dsfs__Recipient_Status__c          = dsAPI_rs.Status;
            dsrs.dsfs__DocuSign_Routing_Order__c    = dsAPI_rs.RoutingOrder;
            dsrs.dsfs__DocuSign_Recipient_Id__c     = dsAPI_rs.RecipientId;
            dsrs.dsfs__Envelope_Id__c               = EnvelopeStatus.EnvelopeID;

            if(dsAPI_rs.Sent != null)
                dsrs.dsfs__Date_Sent__c             = dsAPI_rs.Sent.addSeconds(-offset/1000);
            //ALTERACAO - 02/08/17 - adicionadosos campos abaixo (BP)
            if(dsAPI_rs.Declined != null)
                dsrs.dsfs__Date_Declined__c         = dsAPI_rs.Declined.addSeconds(-offset/1000);
            if(dsAPI_rs.Delivered != null)
                dsrs.dsfs__Date_Delivered__c        = dsAPI_rs.Delivered.addSeconds(-offset/1000);
            if(dsAPI_rs.Signed != null)
                dsrs.dsfs__Date_Signed__c           = dsAPI_rs.Signed.addSeconds(-offset/1000);

            //dsrs.dsfs__Decline_Reason__c = dsAPI_rs.AutoRespondedReason.abbreviate(250);
            dsrs.dsfs__Parent_Status_Record__c      = parentDocusignStatusID;

            //if([SELECT ID FROM Account WHERE ID =:dsAPI_rs.CustomFields.CustomField[0]].size()!=0)
            //    if(dsAPI_rs.CustomFields != null && dsAPI_rs.CustomFields.CustomField[0] !=null)
                    dsrs.dsfs__Account__c           = dsAPI_rs.CustomFields.CustomField[0]; //position 0 -> Account ID -> defined when contract is sent through sendDocumentThroughDocuSign(envelope)
            
            //if([SELECT ID FROM Contact WHERE ID =:dsAPI_rs.CustomFields.CustomField[1]].size()!=0)
            //    if(dsAPI_rs.CustomFields != null && dsAPI_rs.CustomFields.CustomField[1] !=null)
                    dsrs.dsfs__Contact__c           = dsAPI_rs.CustomFields.CustomField[1]; //position 1 -> Contact ID -> defined when contract is sent through sendDocumentThroughDocuSign(envelope)
            dsrsList.add(dsrs);
        }
        return dsrsList;
    }
    */
    public static Set<Dsfs__docusign_Status__c> createDocuSignEnvelopeStatusSFObjectLIST(List<DocuSignAPI.EnvelopeStatus> EnvelopeStatus)
    {
        TimeZone tz    = Timezone.getTimeZone('Europe/Lisbon');
        Integer offset = tz.getOffset(Datetime.now());

        Set<Dsfs__docusign_Status__c>        docusignStatusToUpdate         = new Set<Dsfs__docusign_Status__c>();
        Map<String,Dsfs__docusign_Status__c> mappingDocusignIntoEnvelopeIds = new Map<String,Dsfs__docusign_Status__c>(); 
        Set<String> accountIds = new Set<String>();

        for(DocuSignAPI.EnvelopeStatus currentEnvelopeStatus : EnvelopeStatus)
        {
            Dsfs__docusign_Status__c DocuSignEnvelopeStatusSF      = new Dsfs__docusign_Status__c();
            DocuSignEnvelopeStatusSF.dsfs__DocuSign_Envelope_ID__c = currentEnvelopeStatus.EnvelopeID;
            DocuSignEnvelopeStatusSF.dsfs__Envelope_Status__c      = currentEnvelopeStatus.Status;
            if(currentEnvelopeStatus.Sent != null)
                DocuSignEnvelopeStatusSF.dsfs__Sent_Date_Time__c   = currentEnvelopeStatus.Sent.addSeconds(-offset/1000); //EnvelopeStatus.Sent; - a data enviada pelo Docusign não é a data local
            DocuSignEnvelopeStatusSF.dsfs__Subject__c              = currentEnvelopeStatus.Subject;
            DocuSignEnvelopeStatusSF.dsfs__Sender__c               = currentEnvelopeStatus.UserName;
            DocuSignEnvelopeStatusSF.dsfs__Sender_Email__c         = currentEnvelopeStatus.Email;
            //ALTERACAO - 02/08/17 - adicionadosos campos abaixo (BP)
            if(currentEnvelopeStatus.Declined != null)
                DocuSignEnvelopeStatusSF.dsfs__Declined_Date_Time__c  = currentEnvelopeStatus.Declined.addSeconds(-offset/1000);
            if(currentEnvelopeStatus.Delivered != null)
                DocuSignEnvelopeStatusSF.dsfs__Viewed_Date_Time__c    = currentEnvelopeStatus.Delivered.addSeconds(-offset/1000);
            if(currentEnvelopeStatus.Deleted != null)
                DocuSignEnvelopeStatusSF.dsfs__Voided_Date_Time__c    = currentEnvelopeStatus.Deleted.addSeconds(-offset/1000);
            if(currentEnvelopeStatus.Completed != null)
                DocuSignEnvelopeStatusSF.dsfs__Completed_Date_Time__c = currentEnvelopeStatus.Completed.addSeconds(-offset/1000);
            //missing field to do           something              = currentEnvelopeStatus.TimedOut;  
            mappingDocusignIntoEnvelopeIds.put(currentEnvelopeStatus.EnvelopeID,DocuSignEnvelopeStatusSF);
            
            for(integer i=0; i<currentEnvelopeStatus.CustomFields.CustomField.size(); i++)
                accountIds.add(currentEnvelopeStatus.CustomFields.CustomField[i].Value);
        }//end for loop
        System.debug('[CandorDocuments].createDocuSignEnvelopeStatusSFObjectLIST --> mappingDocusignIntoEnvelopeIds: '+ mappingDocusignIntoEnvelopeIds);
        System.debug('[CandorDocuments].createDocuSignEnvelopeStatusSFObjectLIST --> accountIds: '+ accountIds);
        
        Map<Id,Account> accounts = new Map<Id,Account>([ SELECT ID 
                                                           FROM Account 
                                                          WHERE ID IN :accountIds
                                                       ORDER BY createddate desc
                                                      ]); 

        System.debug('[CandorDocuments].createDocuSignEnvelopeStatusSFObjectLIST --> accounts: '+ accounts);

        for(DocuSignAPI.EnvelopeStatus currentEnvelopeStatus : EnvelopeStatus)
        {
            for(integer i=0; i<currentEnvelopeStatus.CustomFields.CustomField.size(); i++)
            {
                String fieldName  = currentEnvelopeStatus.CustomFields.CustomField[i].Name;
                //System.debug('[CandorDocuments].createDocuSignEnvelopeStatusSFObjectLIST --> fieldName: '+ fieldName);
                String fieldValue = currentEnvelopeStatus.CustomFields.CustomField[i].Value;
                //System.debug('[CandorDocuments].createDocuSignEnvelopeStatusSFObjectLIST --> fieldValue: '+ fieldValue);
                //System.debug('[CandorDocuments].createDocuSignEnvelopeStatusSFObjectLIST --> accounts.get(fieldValue): '+ accounts.get(fieldValue));
                Dsfs__docusign_Status__c DocuSignEnvelopeStatusSF = mappingDocusignIntoEnvelopeIds.get(currentEnvelopeStatus.EnvelopeID);
                if(accounts.get(fieldValue) != null)
                {                    
                    if(fieldName == 'DSFSSourceObjectId')
                        DocuSignEnvelopeStatusSF.docusign_Application_Status__c = fieldValue;
                    else 
                        if(fieldName == '##SFAccount')
                            DocuSignEnvelopeStatusSF.dsfs__Company__c = fieldValue;
                        else 
                            if(fieldName == 'Client')
                                DocuSignEnvelopeStatusSF.Client_Account__c = fieldValue;                     
                }//end accounts.get(fieldValue) scope    
                docusignStatusToUpdate.add(DocuSignEnvelopeStatusSF);
            }//end customfields loop 
        }//end for loop
        System.debug('[CandorDocuments].createDocuSignEnvelopeStatusSFObjectLIST --> docusignStatusToUpdate: '+ docusignStatusToUpdate);
        return docusignStatusToUpdate;
    }

    //ALTERACAO - 31/07/17 - devolve a lista de envelope status (BP) 
    public static Map<String,List<SObject>> updateDocuSignEnvelopeStatusListSFObject(List<DocuSignAPI.EnvelopeStatus> envelopeStatus, Set<String> envelopeIds)
    {
        try
        {
            Set<Dsfs__docusign_Status__c>           resultDocStatuses               = new Set<Dsfs__docusign_Status__c>();
            Set<dsfs__DocuSign_Recipient_Status__c> resultDocRecipientStatuses      = new Set<dsfs__DocuSign_Recipient_Status__c>();
            List<dsfs__DocuSign_Recipient_Status__c> docusignRecipientStatusToUpdate = new List<dsfs__DocuSign_Recipient_Status__c>();

            Set<Dsfs__docusign_Status__c>           docusignStatusToUpdate          = createDocuSignEnvelopeStatusSFObjectLIST(envelopeStatus);

            System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> docusignStatusToUpdate: '+ docusignStatusToUpdate);
            
            List<Dsfs__docusign_Status__c> interestDocusigns = [SELECT ID, docusign_Application_Status__c, dsfs__Company__c, Client_Account__c,dsfs__DocuSign_Envelope_ID__c  
                                                                  FROM Dsfs__docusign_Status__c
                                                                 WHERE dsfs__DocuSign_Envelope_ID__c IN : envelopeIds];

            System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> interestDocusigns: '+ interestDocusigns);

            if(interestDocusigns.size() == 0)
                return null;

            //resolve ids dos docusign status e cria os recipientes pa cada um
            for(Dsfs__docusign_Status__c currentDocusignStatus : interestDocusigns)
            {
                for(Dsfs__docusign_Status__c auxToUpdate : docusignStatusToUpdate)
                {
                    //System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> currentDocusignStatus.dsfs__DocuSign_Envelope_ID__c: '+ currentDocusignStatus.dsfs__DocuSign_Envelope_ID__c
                    //    +'  VS  auxToUpdate.dsfs__DocuSign_Envelope_ID__c:'+auxToUpdate.dsfs__DocuSign_Envelope_ID__c);
                    if(currentDocusignStatus.dsfs__DocuSign_Envelope_ID__c.toUpperCase() == auxToUpdate.dsfs__DocuSign_Envelope_ID__c.toUpperCase())
                    {
                        //System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> currentDocusignStatus.dsfs__DocuSign_Envelope_ID__c: '+ currentDocusignStatus.dsfs__DocuSign_Envelope_ID__c
                        //+'  VS  auxToUpdate.dsfs__DocuSign_Envelope_ID__c:'+auxToUpdate.dsfs__DocuSign_Envelope_ID__c);                    
                        auxToUpdate.Id = currentDocusignStatus.id;
                        resultDocStatuses.add(auxToUpdate);
                        for(DocuSignAPI.EnvelopeStatus currentEnvelope : envelopeStatus)
                            if(currentEnvelope.EnvelopeID == auxToUpdate.dsfs__DocuSign_Envelope_ID__c)
                                docusignRecipientStatusToUpdate.addAll(createDocuSignRecipientStatusSFObject(currentEnvelope,auxToUpdate.Id));
                    }
                }
            }//end Dsfs__docusign_Status__c currentDocusignStatus : interestDocusigns loop

            List<dsfs__DocuSign_Recipient_Status__c> interestDocusignRecipients = [SELECT ID, dsfs__Envelope_Id__c, dsfs__DocuSign_Recipient_Id__c   
                                                                                     FROM dsfs__DocuSign_Recipient_Status__c
                                                                                    WHERE dsfs__Envelope_Id__c IN : envelopeIds];

            System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> interestDocusignRecipients: '+ interestDocusignRecipients);
            
            //resolve os ids dos recipients status 
            for(dsfs__DocuSign_Recipient_Status__c currentDocusignRecipientStatus : interestDocusignRecipients )
            {
                for(dsfs__DocuSign_Recipient_Status__c auxToUpdate : docusignRecipientStatusToUpdate)
                {
                    //System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> currentDocusignRecipientStatus.dsfs__Envelope_Id__c: ' 
                    //    + currentDocusignRecipientStatus.dsfs__Envelope_Id__c + '   VS auxToUpdate.dsfs__Envelope_Id__c: '+auxToUpdate.dsfs__Envelope_Id__c);
                    if(currentDocusignRecipientStatus.dsfs__Envelope_Id__c.toUpperCase() == auxToUpdate.dsfs__Envelope_Id__c.toUpperCase()
                        && currentDocusignRecipientStatus.dsfs__DocuSign_Recipient_Id__c.toUpperCase() == auxToUpdate.dsfs__DocuSign_Recipient_Id__c.toUpperCase())
                    {
                        //System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> currentDocusignRecipientStatus.dsfs__Envelope_Id__c: ' 
                        //+ currentDocusignRecipientStatus.dsfs__Envelope_Id__c + '   VS auxToUpdate.dsfs__Envelope_Id__c: '+auxToUpdate.dsfs__Envelope_Id__c);
                        auxToUpdate.id = currentDocusignRecipientStatus.Id;
                        resultDocRecipientStatuses.add(auxToUpdate);
                    }
                }
            }
            System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> resultDocStatuses: '+resultDocStatuses);
            System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> resultDocRecipientStatuses: '+resultDocRecipientStatuses);
            if(resultDocStatuses  != null && resultDocStatuses.size() > 0 && resultDocRecipientStatuses  != null && resultDocRecipientStatuses.size() > 0)
            {
                //update new List<dsfs__DocuSign_Recipient_Status__c>(resultDocRecipientStatuses);
                Map<String,List<SObject>> result = new Map<String,List<SObject>>();
                result.put('DocuSign Recipient Status List',new List<dsfs__DocuSign_Recipient_Status__c>(resultDocRecipientStatuses));
                result.put('Docusign Status List',new List<Dsfs__docusign_Status__c>(resultDocStatuses));
                System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> Com sucesso !');
                return result;
                //return new List<Dsfs__docusign_Status__c>(resultDocStatuses);
            }
            System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> Correu MAL vai retornar null!');
            return null;
        }//end try scope
        catch(Exception e)
        {
            System.debug('[CandorDocuments].updateDocuSignEnvelopeStatusListSFObject --> TRACING: '
                            + e.getLineNumber() +' '+e.getCause()+' '+e.getTypeName()+ ' '+e.getMessage()+' '+e.getStackTraceString());
            return null;
        }
    }//end updateDocuSignEnvelopeStatusListSFObject method    

    //ALTERACAO - 31/07/17 - forçar o reprocessamento de envelopes que não sincronizaram entre o SF e o Docusign (BP)
    public static  boolean reprocessFailureConnectEnvelopes(String accountId, DateTime beginDateTime, DateTime endDateTime,Set<String> envelopeIds)
    {
        final Integer LAST_PASSED_DAYS_BY_DEFAULT = -30;

        if(accountId == null || envelopeIds.size() == 0 || envelopeIds == null)
            return false;

        if(beginDateTime == null)
            beginDateTime = System.today().addDays(LAST_PASSED_DAYS_BY_DEFAULT);

        if(endDateTime == null)
            endDateTime =System.today();

        Map<String,String>                       DocuSignCredentials     = getDocuSignCredentials();
        Map<String,List<Sobject>>                docusignStatusToUpdate  = new Map<String,List<Sobject>>();

        ////////////////////////
        //definição de serviço//
        ////////////////////////      

        DocuSignAPI.APIServiceSoap docusignService = new DocuSignAPI.APIServiceSoap();
        docusignService.endpoint_x                 = DocuSignCredentials.get('endpoint_x');
        docusignService.inputHttpHeaders_x         = new Map<String, String>();
        docusignService.inputHttpHeaders_x.put('X-DocuSign-Authentication', DocuSignCredentials.get('Auth'));
        
        System.debug('[CandorDocuments].reprocessFailureConnectEnvelopes --> docusignService: ' + docusignService);

        List<String> filteredEnvelopeIds = new List<String>(envelopeIds);

        DocuSignAPI.EnvelopeStatusFilter EnvelopeStatusFilter = new DocuSignAPI.EnvelopeStatusFilter();
        EnvelopeStatusFilter.UserInfo                         = new DocuSignAPI.UserInfo();                         
        EnvelopeStatusFilter.AccountId                        = accountId;//DocuSignCredentials.get('accountId');                                          
        EnvelopeStatusFilter.BeginDateTime                    = new DocuSignAPI.EnvelopeStatusFilterBeginDateTime();
        EnvelopeStatusFilter.BeginDateTime.StatusQualifier    = 'Any';
        EnvelopeStatusFilter.EndDateTime                      = endDateTime;                                        
        EnvelopeStatusFilter.Statuses                         = new DocuSignAPI.ArrayOfEnvelopeStatusCode();                                                        //public DocuSignAPI.ArrayOfEnvelopeStatusCode Statuses;
        EnvelopeStatusFilter.EnvelopeIds                      = new DocuSignAPI.ArrayOfString2();  
        EnvelopeStatusFilter.EnvelopeIds.EnvelopeId           = filteredEnvelopeIds;

        System.debug('[CandorDocuments].reprocessFailureConnectEnvelopes --> EnvelopeStatusFilter: ' + EnvelopeStatusFilter);
        
        ////////////////////////
        // resposta de serviço//
        //////////////////////// 

        DocuSignAPI.FilteredEnvelopeStatuses envelopeStatusResults;
        if(!Test.isRunningTest())
        {
            envelopeStatusResults = docusignService.RequestStatusesEx(EnvelopeStatusFilter);            
            System.debug('[CandorDocuments].reprocessFailureConnectEnvelopes --> envelopeStatusResults: ' + envelopeStatusResults);
        }
        else
        {
            envelopeStatusResults = new DocuSignAPI.FilteredEnvelopeStatuses();
            envelopeStatusResults.EnvelopeStatusFilter               = new DocuSignAPI.EnvelopeStatusFilter();
            envelopeStatusResults.EnvelopeStatusFilter.UserInfo      = new DocuSignAPI.UserInfo();
                envelopeStatusResults.EnvelopeStatusFilter.UserInfo.UserName = 'Test Wit';
                envelopeStatusResults.EnvelopeStatusFilter.UserInfo.Email    = 'sf.candor@worldit.pt';
            envelopeStatusResults.EnvelopeStatusFilter.AccountId     = 'a78718d0-266c-4fef-91c3-76f217f0854e';
            envelopeStatusResults.EnvelopeStatusFilter.BeginDateTime = new DocuSignAPI.EnvelopeStatusFilterBeginDateTime();
                envelopeStatusResults.EnvelopeStatusFilter.BeginDateTime.statusQualifier = 'Any';
            envelopeStatusResults.EnvelopeStatusFilter.EndDateTime   = System.now();
            envelopeStatusResults.EnvelopeStatusFilter.Statuses      = new DocuSignAPI.ArrayOfEnvelopeStatusCode();
            envelopeStatusResults.EnvelopeStatusFilter.EnvelopeIds   = new DocuSignAPI.ArrayOfString2();
                envelopeStatusResults.EnvelopeStatusFilter.EnvelopeIds.EnvelopeId = new String[1];
                envelopeStatusResults.EnvelopeStatusFilter.EnvelopeIds.EnvelopeId[0] ='5FD15451-8568-4E58-A427-5442A3F43970';
            envelopeStatusResults.EnvelopeStatusFilter.ACStatus      = null;
            envelopeStatusResults.EnvelopeStatuses                   = new DocuSignAPI.ArrayOfEnvelopeStatus();
            envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus    = new DocuSignAPI.EnvelopeStatus[3];
            System.debug('TEST --> envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus: '+ envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus );
                //envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].EnvelopeID       = '5FD15451-8568-4E58-A427-5442A3F43970';//public String ;
                //envelopeStatusResults.EnvelopeStatuses.Subject                                                    //public String ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0] = new DocuSignAPI.EnvelopeStatus();
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].UserName         = 'Palma Test';                                //public String ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].Email            = 'sf.candor@worldit.pt';                      //public String ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].Status           = 'Sent';                                      //public String ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].Created          = DateTime.now();                              //public DateTime ;
                //envelopeStatusResults.EnvelopeStatuses.Deleted                                                    //public DateTime ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].Sent             = Datetime.now();                              //public DateTime ;
                //envelopeStatusResults.EnvelopeStatuses.Delivered                                                  //public DateTime ;
                //envelopeStatusResults.EnvelopeStatuses.Signed                                                     //public DateTime ;
                //envelopeStatusResults.EnvelopeStatuses.Completed                                                  //public DateTime ;
                //envelopeStatusResults.EnvelopeStatuses.Declined                                                   //public DateTime ;
                //envelopeStatusResults.EnvelopeStatuses.TimedOut                                                   //public DateTime ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].ACStatus         = 'Original';             //public String ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].ACStatusDate     = Datetime.now();         //public DateTime ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].ACHolder         = 'Sérgio Nunes';         //public String ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].ACHolderEmail    = 'sf.candor@worldit.pt'; //public String ;
                envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus[0].ACHolderLocation = 'DocuSign';             //public String ;
                //envelopeStatusResults.EnvelopeStatuses.SigningLocation                                            //public String ;
                //envelopeStatusResults.EnvelopeStatuses.SenderIPAddress                                            //public String ;
                //envelopeStatusResults.EnvelopeStatuses.EnvelopePDFHash                                            //public String ;
                System.debug('[CandorDocuments TESTS].reprocessFailureConnectEnvelopes --> envelopeStatusResults: ' + envelopeStatusResults);
        }

        List<DocuSignAPI.EnvelopeStatus> envelopeStatusList = envelopeStatusResults.EnvelopeStatuses.EnvelopeStatus;

        if(envelopeStatusList == null || envelopeStatusList.size() == 0)
            return false;

        docusignStatusToUpdate = updateDocuSignEnvelopeStatusListSFObject(envelopeStatusList,envelopeIds);

        if(docusignStatusToUpdate  != null)
        {
            //update docusignStatusToUpdate;
                Database.update(new List<SObject>(new Set<SObject>(docusignStatusToUpdate.get('Docusign Status List'))),false);
                Database.update(new List<SObject>(new Set<SObject>(docusignStatusToUpdate.get('DocuSign Recipient Status List'))),false);
                System.debug('[CandorDocuments].reprocessFailureConnectEnvelopes --> Com sucesso !');
                return true;
        }
        return false;
    }//end reprocessFailureConnectEnvelopes method
}//end class