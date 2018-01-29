@isTest
public class CallCenterUtil_Test {

    public static testmethod void testCallCenterUtil(){
        Contact onjContact = new Contact();
        onjContact.LastName = 'Test';
        onjContact.MobilePhone = '+918149060864';
        insert onjContact;
        CallCenterUtil objCallCenter = new CallCenterUtil();
        CallCenterUtil.getUserInfo();
        CallCenterUtil.searchContact('+918149060864');
    }
    
    public static testmethod void testCallCenterUtilWithDefaults(){
        CallCenterUtil objCallCenter = new CallCenterUtil();
        CallCenterUtil.getUserInfo();
        CallCenterUtil.searchContact('');
    }
}