/**

Author   |Date  | Comments
Vinod    |10/31/2017 | Initial Creation

**/

@isTest
public class SMSUtil_Test{
    public static testMethod void validateSendSms(){
        
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
        insert objTwilioSetting;
        
        SMSUtil objSMSUtil = new SMSUtil();
        //objSMSUtil.sendSms(objContact.MobilePhone,'Testing',objContact.Id);
        SMSUtil.sendSms(objContact.MobilePhone,'+919876543210','Testing',objContact.Id);
    }
}
