@isTest
public class DialController_Test {
    public static testmethod void testDailController(){
        Twilio_Setting__c objSetting = new Twilio_Setting__c();
        objSetting.Name = 'Twilio Account';
        objSetting.AccountId__c = 'AC0092fdb194cdb4e7bfd439d34781b2dc';
        objSetting.Auth_Token__c = '00d9936ff1ec944b942fcb74ded1f8ff';
        objSetting.Call_From__c = '+351927529850';
        objSetting.Caller_Id__c = '+351967070202';
        objSetting.Status_Callback_URL__c = 'http://qa-candor.cs81.force.com/UpdateMessageStatus';
        objSetting.Call_Status_Url__c = 'http://qa-candor.cs81.force.com/TwilioCallStatus';
        insert objSetting;
        
        DialController objDialController = new DialController();
        Test.setCurrentPageReference(new PageReference('Page.Test'));
        System.currentPageReference().getParameters().put('PhoneNumber', '+351927529850');
        objDialController.getDial();
        objDialController.uname = 'Test';
        
        
    }
}