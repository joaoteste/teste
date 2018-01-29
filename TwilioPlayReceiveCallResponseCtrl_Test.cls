@isTest
public class TwilioPlayReceiveCallResponseCtrl_Test{
    public static testmethod void testTwilioPlayReceiveCallResponse(){
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test';
        objContact.FirstName = 'Test';
        objContact.MobilePhone = '+918149060864';
        objContact.Phone = '+918149060864';
        insert objContact;
        
        ApexPages.currentPage().getParameters().put('From', '+918149060864');
        ApexPages.currentPage().getParameters().put('To', '+351927529850');
        ApexPages.currentPage().getParameters().put('CallSid', '+sdgsdgsgsdg45445sdg454sdgsdgf');
        ApexPages.currentPage().getParameters().put('CallStatus', 'Received');
        
        TwilioPlayReceiveCallResponseController objPlayReceived = new TwilioPlayReceiveCallResponseController();
        objPlayReceived.saveTask();
        
    }
}