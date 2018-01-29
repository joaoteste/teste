/**

Author   |Date  | Comments
Vinod    |01/19/2018 | Initial Creation
**/

public class TwilioPlayReceiveCallResponseController{
    public string xmlResponse {get;set;}
    public Contact objContact {get;set;}
    //public Lead objLead {get;set;}
    public Id recordTypeId {get;set;}
    public String fromNumber {get;set;}
    public String toNumber {get;set;}
    public String callSid {get;set;}
    public String callStatus {get;set;}
    public TwilioPlayReceiveCallResponseController(){
        //string trId = ApexPages.currentPage().getParameters().get('trId');
        //Tape_Recording_Line_Item__c li = [select Attachment__c from Tape_Recording_Line_Item__c where id = : trId limit 1];
        fromNumber = ApexPages.currentPage().getParameters().get('From');
        toNumber = '';
        callSid = '';
        callStatus = '';
        objContact = new Contact();
        
        toNumber = ApexPages.currentPage().getParameters().get('To');
        callSid = ApexPages.currentPage().getParameters().get('CallSid');
        callStatus = ApexPages.currentPage().getParameters().get('CallStatus');
        //String recordName = '';
        
        List<RecordType> recordTypeList = [SELECT Id,Name FROM RecordType WHERE DeveloperName = 'Receive_Calls' AND sObjectType = 'Task'];
        if(recordTypeList.size() > 0){
            recordTypeId = recordTypeList[0].Id;
        }
        
        //If got from number of call
        if(fromNumber != null){
            
            // search Lead and Contact phone number fields
            List<List<SObject>> results = [FIND :fromNumber IN PHONE FIELDS RETURNING Contact(FirstName, LastName, MobilePhone, Phone ORDER BY CreatedDate ASC LIMIT 1)];//, Lead(FirstName, LastName, MobilePhone, Phone ORDER BY CreatedDate ASC LIMIT 1)];
        
            // extract the Contact if there’s a match
            if (!results[0].isEmpty()) {
                objContact = (Contact)results[0][0];
                //recordName = objContact.firstName + ' ' + objContact.lastName;
            } /*else if (!results[1].isEmpty()) {
                objLead = (Lead)results[1][0];
                recordName = objLead.FirstName + ' ' + objLead.LastName;
            }*/
        }
        //String str = 'https://qa-candor.cs81.force.com/resource/1510764722000/calls';
        String str = System.URL.getSalesforceBaseUrl().toExternalForm()+'/resource/IncomingRecording';
        xmlResponse = '<Response>'+
                        //'<Say>Hello '+recordName+'</Say>'+
                        '<Play>'+str+'</Play>'+
                      '</Response>';
        
    }
    
    //Method to save save on incoming call to twilio
    public void saveTask() {
        List<Task> insertTaskList = new List<Task>();
        if(fromNumber != null){
            Task objTask = new Task();
            objTask.Subject = 'Received Call To Twilio on '+System.now();
            objTask.Status = 'Completed';
            objTask.Call_From_ReceiveCalls__c = fromNumber;
            objTask.Call_To__c = toNumber;
            objTask.CallSid__c = callSid;
            objTask.Call_Status__c = callStatus;
            objTask.whoid = objContact.Id;
            objTask.RecordTypeId = recordTypeId;
            objTask.ActivityDate = System.today();
            insertTaskList.add(objTask);
        }
        
        if(insertTaskList.size() > 0){
            insert insertTaskList;
        }
        
    }
}