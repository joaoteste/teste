/*

Author   |Date  | Comments
Vinod    |10/16/2017 | Initial Creation

*/

@isTest
public class ReceiveTwilioMessageController_Test{
    public static testMethod void validateReceiveMessage(){
        
        //Insert Contact
        Contact objContact = new Contact(FirstName = 'test1',LastName = 'testLast', Phone = '1236547890', MobilePhone = '9876543210', HomePhone = '1236547891', OtherPhone = '1213654987');
        insert objContact;
        
        //Set receive message parameters to current page
        ApexPages.currentPage().getParameters().put('From',objContact.MobilePhone);
        ApexPages.currentPage().getParameters().put('To','+913766895632');
        ApexPages.currentPage().getParameters().put('Body','Testing');
        
        ReceiveTwilioMessageController objReceiveTwilioMessageController = new ReceiveTwilioMessageController();
        objReceiveTwilioMessageController.init();
    }
}