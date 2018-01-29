@isTest
public class TwilioCallStatusController_Test {
    
    public static testMethod void validateTwilioCallStatus(){
        
        Task objTask = new Task();
        objTask.Subject='test';
        objTask.Status='Not Started';
        objTask.Priority='Normal';
        objTask.Number_Of_Tries__c='2';
        objTask.Call_Time__c = System.today();
        insert objTask;       
        
        Apexpages.currentPage().getParameters().put('taskId', objTask.Id);
        Apexpages.currentPage().getParameters().put('CallStatus', 'no-answer');
        //Apexpages.currentPage().getParameters().put('taskId', objTask.Id);
        TwilioCallStatusController objTwilioCallStatusController = new TwilioCallStatusController();
        objTwilioCallStatusController.updateStatus();
        TwilioCallStatusController.nextScheduleDate(16,System.now());
    }
    
    public static testMethod void validateTwilioCallStatusCompleted(){
        
        Task objTask = new Task();
        objTask.Subject='test';
        objTask.Status='Not Started';
        objTask.Priority='Normal';
        insert objTask;       
        
        Apexpages.currentPage().getParameters().put('taskId', objTask.Id);
        Apexpages.currentPage().getParameters().put('CallStatus', 'completed');
        TwilioCallStatusController objTwilioCallStatusController = new TwilioCallStatusController();
        objTwilioCallStatusController.updateStatus();
    }
}