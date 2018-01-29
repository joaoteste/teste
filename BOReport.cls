global class BOReport {
    /* Class used to Get report in BackOffice*/
    webservice static string GetInformaDBPdfAttachId( string reportId, string Nif)
    {
        try{
            Attachment file =[Select Id From Attachment where Name=:Nif + '.pdf' and ParentId=: reportId]; 
            string fileId=file.Id;
            return fileId;
        }
        catch (Exception e) {
           System.Debug('DBInfoXML GetInformaDBPdfAttachId - Error *** fileId for pdf report does not exists!');
           system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
           return null; 
        }
    }
     webservice static string DownladAndGetReport (string nome, string ClientType, string id, string CodRel){
        try{
            string xml;
            Blob Pdf=null;
            ReportDB__c report;
            Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
             Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();
            if (!Test.isRunningTest())
            {
                outInt=DBInfoXML.InformadbGetReport( nome , CodRel, 'Xml', ClientType); 
                xml=outInt.xml;
                outIntPdf=DBInfoXML.InformadbGetPdfReport(nome, CodRel);
                pdf=outIntPdf.pdf;

            }  else {
                // test WebService CallOut
                StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
                mock.setStaticResource('testreport');
                mock.setStatusCode(200);
                mock.setHeader('Content-Type', 'text/xml');
                Test.setMock(HttpCalloutMock.class, mock);
                HttpRequest req = new HttpRequest();
                req.setEndpoint('http://api.salesforce.com/foo/bar');
                req.setMethod('GET');
                Http h = new Http();
                HttpResponse res = h.send(req);
                xml=res.getbody();
            }
            if(xml!='Error - InformaDB is down' && xml!=''){
                DBProp dbprop=DBInfoXML.parseDBXML(xml);    
                report=DBInfoXML.UpdateReport(dbprop, ClientType, id, Pdf); 
                Utilities.LogIntegration(outInt.startReq, outInt.endReq, outInt.status, outInt.code, outInt.response, outInt.identifierReq);
                Utilities.LogIntegration(outIntPdf.startReq, outIntPdf.endReq, outIntPdf.status, outIntPdf.code, outIntPdf.response, outIntPdf.identifierReq);
                return report.Id;  
            } else {
                Utilities.LogIntegration(outInt.startReq, outInt.endReq, outInt.status, outInt.code, outInt.response, outInt.identifierReq);
                Utilities.LogIntegration(outIntPdf.startReq, outIntPdf.endReq, outIntPdf.status, outIntPdf.code, outIntPdf.response, outIntPdf.identifierReq);
                return '';
            }
            
        }
      catch (Exception e) {
           System.Debug('Error *** Report InformaDB was not downloaded!');
           system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
          return null;
      }
  }
    
    webservice static String GetRentCalc(string appId, decimal equipCost){
        application__c app=[select Output_Ins_Manager__c, Output_Rate_Manager__c from application__c where id= :appId];
        app.Output_Ins_Manager__c='';
    app.Output_Rate_Manager__c='';
       update app;
        string msg=ScoreCardConfig.GetScoreCardRate(appId, equipCost);
        return msg;
    }
  
    webservice static string ImportReceipt( string appId, string clientId){
        string msg= OCR_API.OCRParse_Api(appId, clientId);
        return 'Facura foi processada: \n' + msg;
    }
    
    webservice static String SettleContract(string appId){
        
        string msg=SettleContract.validateContract(appId);
        return msg;
    }
 
    webservice static string finalizedInvoiceExpress(string invoiceID){
        if(invoiceID.length() != 15) return 'Choose only one record';
        String msg=(new BILL_MoloniApi()).createInvoiceMoloniFinalized(invoiceID);
        
        return msg;
    }
    
    webservice static string createCreditNote(Id creditNoteID){
        
        String msg=(new BILL_MoloniApi()).createCreditNote(creditNoteID);

        return msg;
    }
    
    webservice static string sendEmailwithInvoice(Id invoiceID){
        
        String msg=(new BILL_MoloniApi()).sendEmailwithInvoice(invoiceID);

        return msg;
    }
    
       
    webservice static string CM_sendEmailTemplate(String toRecipient, String templateApiName, ID targetObjId, Id whatId, Boolean saveAsActivity){
       
            List<string> toRecipients=new List<string>();
            toRecipients.add(toRecipient);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            id orgWideEmailId =[select id, DisplayName, Address from OrgWideEmailAddress where address='info@candor.pt' limit 1].id;
            Id templateId;  
            try {
                templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
            }
            catch (Exception e) {
              System.debug('Unable to locate EmailTemplate using name: ' + templateApiName);
            }
        
        
            email.setToAddresses(toRecipients);
            //email.setCcAddresses(ccRecipients);
            email.setTargetObjectId(targetObjId);
            email.setWhatId(whatId);
            email.setorgWideEmailAddressId(orgWideEmailId);
            email.setTemplateId(templateId);
            email.setSaveAsActivity(saveAsActivity);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users
            
            
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                return 'False';
            }
            catch (EmailException e) { 
                System.debug(' sendTemplatedEmail error. ' + e.getMessage());
                Return 'False';
            }
      
     
          //  Utilities.sendTemplatedEmail(toRecipients, templateApiName,targetObjId, whatId, saveAsActivity);
            CM_ContractManagement CM = New CM_ContractManagement();
            CM.ChangeInvoiceDate(whatId);
            return 'Success';
       
     }


      webservice static string cm_ET_AcceptOffer(Id CMRec){
        try{
            List<Contract_Management__c> CMList=[select CMS_Status__c,Account_Tax_Zone__c, Advanced_Expired_Payments_Amount__c, Billing_contract__c, Billing_contract__r.Application__r.Price_Book__c, Residual_Value_Amount__c from Contract_Management__c where id =: CMRec Limit 1];
            system.debug(CMList);
            CMList[0].CMS_Status__c='Accepted';
           
            CM_ContractManagement CM = New CM_ContractManagement();
            Map <string, string> result =new Map<string, string>(CM.ET_InactivateOldAndCreateNewBCLI(CMList ));
            if(result.get('Result')=='Success'){
                update CMList;
                return 'Success';
            }
            else {
                return result.get('Error');
            }
            
        }
        catch(exception e){
            return 'False';
        }
        
     }

     webservice static List<String> cm_BillContract_EarlyTermination( Billing_contract__c BillContract){
        list<String> listresult= New List<String>();
        try{
            system.debug(BillContract);
            map<string, string> Result=New map<string, string> ();
            List<Collection_Case__c> collCaseExists =[Select id, name from Collection_Case__c where Billing_Contract__c =: billContract.id and Status__C!='Closed' Limit 1];
           if(collCaseExists.size()!=0){
            listresult.add('Error');
            listresult.add('Client has unpaid Invoices - ' + collCaseExists[0].name + '- that must be paid before you can proceed.' );
            return listresult;
            }
         
         //   disableButton = false;
            CM_ContractManagement CM=New CM_ContractManagement();
            Result = CM.EarlyTermination(BillContract);
            if (result != null) {
                if(result.get('Result')=='Success'){ 
                     listresult.add('Success');
                      listresult.add(result.get('Id'));
                    return listresult;
                }else{
                     listresult.add('Error');
                      listresult.add(result.get('Error'));
                    return listresult;
                    
                }
            }

            return listresult;
       }
       catch(Exception e){
          //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getLineNumber() + ' ' + e.getMessage()));
            //disableButton = false;
            listresult.add('Error');
            listresult.add(e.getLineNumber() + ' ' + e.getMessage());
            return listresult;
       } 
    } 
}
