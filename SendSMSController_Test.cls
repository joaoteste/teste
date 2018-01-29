/**

Author   |Date  | Comments
Vinod    |10/31/2017 | Initial Creation

**/
@isTest
public class SendSMSController_Test{
    public static testMethod void validateSendSms(){
        
        //Insert Contact
        Contact objContact = new Contact(FirstName = 'test1',LastName = 'testLast', Phone = '1236547890', MobilePhone = '9876543210', HomePhone = '1236547891', OtherPhone = '1213654987');
        insert objContact;
        
        system.assertEquals(true,objContact.id!=null);
        
        //Task assigned to contact
        Task objTask = new TasK(Priority = 'Low', Status = 'In Progress', WhoId = objContact.Id);
        insert objTask;
        
        //List of contact numbers
        List<String> numberList = new List<String>();
        numberList.add(objContact.Phone);
        numberList.add(objContact.MobilePhone);
        numberList.add(objContact.HomePhone);
        numberList.add(objContact.OtherPhone);
        
        //Custom setting to store Twilio credentials for authorization
        Twilio_Setting__c objTwilioSetting = new Twilio_Setting__c();
        objTwilioSetting.From_Number__c = '+14578965412';
        objTwilioSetting.Auth_Token__c = 'MSADJDJASJDJAS';
        objTwilioSetting.AccountId__c = 'dsfsf646132v';
        objTwilioSetting.Name = 'Twilio Account';
        insert objTwilioSetting;
        
        //Set contact id to current page
        ApexPages.currentPage().getParameters().put('Id',objContact.Id);
        
        //Default constructor
        SendSMSController objSendSMSControllerDefault = new SendSMSController();
        
        //Parameterized constructor
        SendSMSController objSendSMSController = new SendSMSController(new ApexPages.StandardController(objContact));
        objSendSMSController.toNumberList = numberList;
        objSendSMSController.toNumber = '9876543210';
        objSendSMSController.body = 'Testing';
        objSendSMSController.getContactNames();
        //objSendSMSController.sendSms();
        SendSMSController.getMessages(objContact.Id);
        objSendSMSController.Back();
    }
}