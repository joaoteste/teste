/*

Author   |Date  | Comments
Vinod    |11/02/2017 | Initial Creation

*/

public class UpdateMessageStatusController {

    // Set instance variables to capture the To, From, and Body Parameters that Twilio sends in the HTTP request
    public String taskId ;//= ApexPages.currentPage().getParameters().get('Sid');
    public String taskStatus ;// = ApexPages.currentPage().getParameters().get('Status');
    
    // This is the initial method that gets called when the TwilioResponse page loads
    public PageReference init(){
        try{
            taskId = ApexPages.currentPage().getParameters().get('MessageSid');
            taskStatus = ApexPages.currentPage().getParameters().get('MessageStatus');
            
            //To convert first aplhabet capital
            if(taskStatus.length() > 1){
                taskStatus = taskStatus.substring(0,1).toUpperCase() + taskStatus.substring(1,taskStatus.length());
            }
            
            // If we capture all of the parameters successfully, call the updateMessageStatus() method 
            if(taskId != null){
                updateMessageStatus();
            }
            return null;
        }catch(Exception e){
            return null;
        }
    }
    
    //Method to track task with message sid and update task for message
    public void updateMessageStatus(){
        
        // Query the Task which matches with the message sid
        List<Task> taskList = [SELECT Id, Message_Status__c, MessageSid__c FROM Task WHERE MessageSid__c =: taskId limit 1];
        
        // Update task with the updated status 
        for (Task objTask : taskList){
            objTask.Message_Status__c = taskStatus;
        }
        
        // Update
        if(taskList.size() > 0){
            update taskList;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Updated Successfully');
            ApexPages.addMessage(myMsg);
        }
    }
}