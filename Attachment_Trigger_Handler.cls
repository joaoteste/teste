global class Attachment_Trigger_Handler extends TriggerHandler{

    public static void handleAfterInsertInjunction(List<Attachment> newAtts){
        Map<Id, Attachment> objectAtts = new Map<Id, Attachment>();
        
        //associate the attachment to the object
        for(Attachment att: newAtts){
            //2 attachments added will be crushed but should never happen because is manual upload from the bank...
            objectAtts.put(att.ParentId, att);
            system.debug('attch inserted Id: ' + att.Id + ' For parent.Id: ' + att.ParentId);
        }
        
        //get injunctions which had an attachment uploaded
        
        List<Injunction_Procedure__c> injs = [SELECT Injunction_Submission_Date__c
                                                 FROM Injunction_Procedure__c
                                                 WHERE Id IN :objectAtts.keySet()];
        
        system.debug('injs.size(): ' + injs.size());
        
        //update injunction submission date
        for(Injunction_Procedure__c injunction : injs){
            Date submissionDate = Date.today();
            injunction.Injunction_Submission_Date__c = submissionDate;
            injunction.Injuction_Procedure_Status__c = 'Submitted';
        }
        
        update injs;
    }
    
    
    public static void handleAfterInsertSEPARecords(List<Attachment> newAtts){
        Map<Id, Attachment> objectAtts = new Map<Id, Attachment>();
        
        //associate the attachment to the object
        for(Attachment att: newAtts){
            //2 attachments added will be crushed but should never happen because is manual upload from the bank...
            objectAtts.put(att.ParentId, att);
            system.debug('attch inserted Id: ' + att.Id + ' For parent.Id: ' + att.ParentId);
        }
        
        //get sepas which had an attachment uploaded
        Map<Id, CR_Sepa_File__c> sfs = new Map<Id, CR_Sepa_File__c>([select
                                                                     id,
                                                                     Name,
                                                                     Return_DateTime__c,
                                                                     Return_Records_Count__c,
                                                                     Return_Total_Amount__c,
                                                                     SEPA_Movement_Type__c,
                                                                     SEPA_Our_Bank_IBAN__c,
                                                                     Original_Group_Status__c,
                                                                     Original_Payment_Status__c,
                                                                     Refund_XML_DateTime__c,
                                                                     Refund_Record_Count__c,
                                                                     Refund_Total_Amount__c,
                                                                     Request_Total_Ammount__c,
                                                                     SEPA_File_Name__c,
                                                                     SEPA_Collection_Date__c
                                                                     from CR_Sepa_File__c
                                                                     where
                                                                     Request_Records_Count__c > 0
                                                                     AND
                                                                     Id IN :objectAtts.keySet()
                                                                    ]);
        
        system.debug('sfs.size(): ' + sfs.size());
        
        //process SEPA return files
        //TODO why is one by one ??
        for(Id key: sfs.keySet()){
            system.debug('Calling readReturnXMLforSepaFile for CR_Sepa_File__c.Id: ' + key);
            Datetime startDatetime = Datetime.now();
            SEPA_SF_Return.readReturnXMLforSepaFile(sfs.get(key), objectAtts.get(key), startDatetime);
        }

    }    
}