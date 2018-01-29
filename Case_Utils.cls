//TestClass: VendorInvoiceTriggerHandlerTest
global class Case_Utils {
    
    //create a case when doens't exist a parser associate to that account
    public static void createCaseDocParser(Account acc){
        
        String subject = 'Account '+acc.Name + ' has no associated Parser';
        String description = 'The ' + acc.Type + ' ' + acc.Name + ' has no associated Parser. For future contracts is necessary to create a Parser on DocParser and associate the parser\'s id on Account';
        Case noDocParserCase = newCase('','Interno', 'Administração', 'Docparser', description, acc.ID);

        insert noDocParserCase;     
        
    }
    
    public static Case newCase(String priority, String type, String category, String reason, String description, Id accountID){
        Case newCase = new Case();
        if(priority!= null && priority != ''){
            newCase.Priority = priority;
        }
        newCase.Status = 'New';   
        newCase.AccountId = accountID;
        newCase.type = type;
        newCase.Category__c = category;
        newCase.Reason__c = reason;
        newCase.Description = description;
        return newCase;
    }
    //Keys => ID, caseNumber, topic, subject, priority, createdDate, message, status, atributedTo
    public static Map<String,String> caseToMap(case caseToMap){
        Map<String, String> caseMap = new Map<String, String>();
        caseMap.put('id',caseToMap.id);
        caseMap.put('caseNumber',caseToMap.CaseNumber);
        caseMap.put('reason',caseToMap.Reason__c);
        caseMap.put('type',caseToMap.Type);
        caseMap.put('category',caseToMap.Category__c);
        caseMap.put('subject',caseToMap.Subject);
        caseMap.put('priority',caseToMap.Priority);
        caseMap.put('createdDate',''+caseToMap.CreatedDate);
        caseMap.put('message',caseToMap.Description);
        caseMap.put('status',caseToMap.Status);
        String AttributedTo = caseToMap.Owner.FirstName +' '+ caseToMap.Owner.LastName;
        caseMap.put('attributedTo', AttributedTo); 
        return caseMap;
    }
    
    public static CaseComment newCaseComment(String caseId,  String message){
        CaseComment newCaseComm  = new CaseComment(CommentBody = message, ParentId = caseID, isPublished = true);
        return newCaseComm;   
    }
    public static list<Attachment> getCaseAttachments(String caseId){
        return [SELECT Body, Name FROM Attachment WHERE ParentID =:caseId]; 
    }
    
    
    
}