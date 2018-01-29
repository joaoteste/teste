@isTest
public class TwilioScheduleCallController_Test{
    public static testMethod void validateCall(){
        
        //Insert Contact
        Contact objContact = new Contact(FirstName = 'test1',LastName = 'testLast', Phone = '1236547890', MobilePhone = '9876543210', HomePhone = '1236547891', OtherPhone = '1213654987');
        insert objContact;
        
        //Custom setting to store Twilio credentials for authorization
        Twilio_Setting__c objTwilioSetting = new Twilio_Setting__c();
        objTwilioSetting.From_Number__c = '+14578965412';
        objTwilioSetting.Auth_Token__c = 'MSADJDJASJDJAS';
        objTwilioSetting.AccountId__c = 'dsfsf646132v';
        objTwilioSetting.Name = 'Twilio Account';
        objTwilioSetting.Status_Callback_URL__c = 'http://test.com/messageResponse';
        objTwilioSetting.Call_Response_Url__c = 'http://test.com/CallResponse';
        objTwilioSetting.Call_Status_Url__c = 'http://test.com/CallBackStatus';
        objTwilioSetting.Caller_Id__c = '+14578965412';
        insert objTwilioSetting;
        
        Tape_Recording__c rec = new Tape_Recording__c();
        rec.Description__c = 'Test Recording';
        insert rec;
        
        Tape_Recording_Line_Item__c recLI = new Tape_Recording_Line_Item__c();
        recLI.Transcription__c = 'Test transcription';
        recLI.Tape_Recording__c = rec.Id;
        recLI.Attachment__c = 'http://test.com/test.mp3';
        insert recLI;        
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(objContact);
        TwilioScheduleCallController con = new TwilioScheduleCallController(stdCon);
        con.getItems();
        con.onSelectTime();
        con.objTask.Tape_Recording_Line_Item__c = recLi.Id;
        con.objTask.Description = 'Test Desc';
        con.objTask.Call_From__c = '+351967070202';
        con.makeCall();
        con.objTask.Id = null;
        con.selectTime = 'Schedule';
        con.objTask.Call_Time__c = system.now().addHours(2);
        con.saveTask();
        con.objTask.Call_Status__c = 'In Progress';
        update con.objTask;
        
        Apexpages.currentPage().getParameters().put('trId',recLI.Id);
        TwilioCallResponseController resCon = new TwilioCallResponseController();
        
        Apexpages.currentPage().getParameters().put('taskId',con.objTask.Id);
        TwilioCallStatusController statusCon = new TwilioCallStatusController();
        statusCon.updateStatus();
        
    }
}