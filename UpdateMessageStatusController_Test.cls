/*

Author   |Date  | Comments
Vinod    |11/03/2017 | Initial Creation

*/

@isTest
public class UpdateMessageStatusController_Test{
    public static testMethod void validateUpdateMessageStatus(){
        
        //Insert Contact
        Contact objContact = new Contact(FirstName = 'test1',LastName = 'testLast', Phone = '1236547890', MobilePhone = '9876543210', HomePhone = '1236547891', OtherPhone = '1213654987');
        insert objContact;
        
        //Insert Task
        Task objTask = new Task(MessageSid__c = 'snisdfs54f5ds54gfhb54fg',Message_Status__c = 'Queued',WhoId = objContact.Id);
        insert objTask;
        
        //Set receive message parameters to current page
        ApexPages.currentPage().getParameters().put('MessageSid',objTask.MessageSid__c);
        ApexPages.currentPage().getParameters().put('MessageStatus','Delivered');
        
        UpdateMessageStatusController objUpdateMessageStatusController = new UpdateMessageStatusController();
        objUpdateMessageStatusController.init();
    }
}