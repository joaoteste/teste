@isTest
public class LightningTwilioSoftphoneController_Test {
    
    public static testMethod void validateLightningTwilioSoftphoneController(){
        
        Twilio_Setting__c objTwilioSetting = new Twilio_Setting__c();
        objTwilioSetting.Call_From__c = '+3569876543210';
        objTwilioSetting.Call_Status_Url__c = 'http://twilio.candor.com';
        objTwilioSetting.AccountId__c = 'as1df4sd6f4df6g4df5';
        objTwilioSetting.Auth_Token__c = 'sda25sd4g6sd54g4sdg';
        objTwilioSetting.Twilio_WorkspaceId__c = 'WS21asf1asf13f131df3d';
        objTwilioSetting.Twilio_WorkerId__c = 'WA516sd4gdsf46dsf54sd';
        objTwilioSetting.Twilio_AppId__c = 'AP5161sd54sdf4dsf54sd';
        objTwilioSetting.Name = 'Twilio Account';
        insert objTwilioSetting;       
        
        LightningTwilioSoftphoneController objLightningTwilioSoftphoneController = new LightningTwilioSoftphoneController();
    }
}