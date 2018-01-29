public with sharing class TwilioScheduleCallController {
    
    public Task objTask {get;set;}
    public Id contactId {get;set;}
    public string phoneNumber{get;set;}
    public string selectTime {get;set;}
    public string description{get;set;}
    
    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Now','Now'));
        options.add(new SelectOption('Schedule','Schedule'));
        return options;
    }
    
    public TwilioScheduleCallController(ApexPages.StandardController controller) {
        if (!Test.isRunningTest())
            controller.addFields(new List<string>{'MobilePhone'});
        contactId = controller.getRecord().Id;        
        phoneNumber = ((Contact)controller.getRecord()).MobilePhone; 
        objTask = new Task();
        selectTime = 'Now';
        system.debug('>>'+phoneNumber);       
    }
    
    public pageReference saveTask(){
        objTask.Subject = description;
        RecordType rt = [select id from RecordType where DeveloperName = 'Call' and sobjecttype='Task' limit 1];
        objTask.RecordTypeId = rt.id;
        objTask.Type = 'Call';
        objTask.WhoId = contactId;
        objTask.Status='Completed';
        objTask.Call_Status__c = 'Queued';
        objTask.Call_To__c = phoneNumber;
        objTask.Is_Scheduled__c = true; 
        //if(selectTime=='Schedule')
            //objTask.Call_Time__c =  objTask.Call_Time__c.addHours(1);      
        insert objTask;        
        return new PageReference('/'+contactId);
    }
    
    public pageReference makeCall(){        
        try{
            Call.makeCall(objTask.Call_From__c,phoneNumber,description,objTask.Tape_Recording_Line_Item__c,contactId);
            return new PageReference('/'+contactId);
        }
        catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public pageReference onSelectTime(){
        return null;
    }
}
