/*

Author   |Date  | Comments
Vinod    |10/16/2017 | Initial Creation

*/

public class ReceiveTwilioMessageController {

    // Set instance variables to capture the To, From, and Body Parameters that Twilio sends in the HTTP request
    public String fromNumber = ApexPages.currentPage().getParameters().get('From');
    public String toNumber = ApexPages.currentPage().getParameters().get('To');
    public String body = ApexPages.currentPage().getParameters().get('Body'); 
    
    // This is the initial method that gets called when the TwilioResponse page loads
    public PageReference init()
    {
        // Helpful with debugging
        System.debug('FROM: ' + fromNumber);
        System.debug('TO: ' + toNumber);
        System.debug('BODY: ' + body);

        // If we capture all of the parameters successfully, call the saveIncomingText() method
        if(fromNumber != null && toNumber != null && body != null)
        {
            saveIncomingText();
            return null;
        }
        return null;
    }

    Public void saveIncomingText()
    {
        // Call the method to clean the incoming phone number
        String cleanFromNumber = formatPhone(fromNumber);
        String fromNumberWithoutSpace = formatPhoneWithoutSpace(fromNumber);
        
        // Query the Contact whose phone number matches the incoming phone number
        List <Contact> contactList = [SELECT Id FROM Contact WHERE MobilePhone =:cleanFromNumber or MobilePhone=:fromNumber or MobilePhone=:fromNumberWithoutSpace limit 1];
        
        // List of task to insert on receiving messages
        List<Task> taskList = new List<Task>();
        
        // Move forward only if we find at least one match.
        // Insert the Incoming Text object           
        try
        {
            for (Contact objContact : contactList){                                            
                Task objTask = getMessage();
                objTask.whoId = objContact.id;
                taskList.add(objTask);
            }
            
            if(taskList.size() > 0){
                insert taskList;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Saved Successfully');
                ApexPages.addMessage(myMsg);
            }
        }
        catch(DmlException e)
        {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+e.getMessage());
          ApexPages.addMessage(myMsg);
        }
    }
    //Method to compose SMS Record
    public Task getMessage(){
            // Create a new SMS Message to store the record of the incoming text, then attach it to the appropriate Contact
            Task msg = new Task();
            List<RecordType> smsRecordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE sObjectType = 'Task' AND DeveloperName = 'SMS'];
            if(smsRecordTypeList.size() > 0){
                msg.RecordTypeId = smsRecordTypeList[0].Id;
            }
            
            msg.Message_Date__c = Datetime.now();
            msg.Message__c = body ;
            msg.From__c = fromNumber;
            msg.To__c = toNumber ;
            msg.Message_Status__c = 'Recieved';
            msg.Type__c = 'Incoming';
            msg.Status = 'Completed';
            msg.Subject = 'Incoming Message';
            return msg;
    }    
    
    // Twilio sends the phone number as +15555551234.  We have to reformat the string to (555) 555-1234
    private String formatPhone(String fromNumber)
    {
        String areaCode = fromNumber.substring(2,5);
        String prefix = fromNumber.substring(5,8);
        String last4 = fromNumber.substring(8);
        String formattedPhone = '(' + areaCode +')' + ' ' + prefix + '-' + last4;
        System.debug('FORMATTED PHONE IS: ' + formattedPhone);
        return formattedPhone;
    }
    
    private String formatPhoneWithoutSpace(String fromNumber){
       
        String areaCode = fromNumber.substring(2,5);
        String prefix = fromNumber.substring(5,8);
        String last4 = fromNumber.substring(8);
        String formattedPhone = '(' + areaCode +')' +prefix + '-' + last4;
        System.debug('FORMATTED PHONE IS: ' + formattedPhone);
        return formattedPhone;
    }
    
    
}