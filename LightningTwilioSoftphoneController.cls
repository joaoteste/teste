/**

Author   |Date  | Comments
Vinod    |01/15/2018 | Initial Creation
**/

public class LightningTwilioSoftphoneController{
    public string twilioToken{get;set;}
    public string twilioWorkerToken{get;set;}
    public string fromNumber{get;set;}
    public string callStatusURL{get;set;}
    public string callRecordTypeId{get;set;}
    
    public LightningTwilioSoftphoneController(){
        Twilio_Setting__c setting;
        callStatusURL = '';
        callRecordTypeId = '';
        
        //Get Twillo login credentilas
        List<Twilio_Setting__c> settingList = [SELECT Id, Name, AccountId__c, Auth_Token__c, Caller_Id__c, Call_From__c, From_Number__c, Status_Callback_URL__c, Call_Status_Url__c, Twilio_AppId__c, Twilio_WorkspaceId__c, Twilio_WorkerId__c FROM Twilio_Setting__c WHERE Name = 'Twilio Account' LIMIT 1];
        List<RecordType> taskRecordTypeList = new List<RecordType>([SELECT Id,Name FROM RecordType WHERE sObjectType = 'Task' AND DeveloperName = 'Call']);
        
        //Record Type of task to save
        if(taskRecordTypeList.size() > 0){
            callRecordTypeId = taskRecordTypeList[0].Id;
        }
        
        //Get custom setting for twilio
        if(settingList.size() > 0){
            setting = settingList[0];
        }
        
        //Set from number from twilio custom setting
        fromNumber = setting.Call_From__c;
        if(setting.Call_Status_Url__c != null){
            callStatusURL = setting.Call_Status_Url__c;
        }
        System.debug('setting '+setting);
        
        //Get current logged in user
        User objUser = [SELECT Id, UserName FROM User WHERE Id = :UserInfo.getUserId()];
        
        /*TwilioTRRestClient trClient = new TwilioTRRestClient(setting.AccountId__c,setting.Auth_Token__c);
        TwilioTRWorkspaceList workersList = trClient.getWorkspaces();
        System.debug('workersList '+workersList);*/
        
        //Getting Token 
        TwilioCapability capability = new TwilioCapability(setting.AccountId__c,setting.Auth_Token__c);
        capability.allowClientOutgoing(setting.Twilio_AppId__c);
        capability.allowClientIncoming(objUser.UserName.replace('@','AT').replace('.','DOT'));
        twilioToken = capability.generateToken();
        System.debug('twilioToken '+twilioToken);
        
        //Getting Worker Token
        TwilioTRCapability trcapability = new TwilioTRCapability(setting.AccountId__c,setting.Auth_Token__c, setting.Twilio_WorkspaceId__c, setting.Twilio_WorkerId__c);
        trcapability.allowWorkerActivityUpdates();
        trcapability.allowTaskReservationUpdates();
        trcapability.allowWorkerReservationFetch();
        trcapability.allowWorkerFetch();
        twilioWorkerToken = trcapability.generateToken();
        System.debug('twilioWorkerToken '+twilioWorkerToken);
        
    } 
}