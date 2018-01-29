@isTest
public class ContactTrigger_test {
	
	private static Integer nifCounter = 100000000;
	private static String testUsername = 'email@email.com';
	private static String testPass = 'amazingPass';
	
	private static String typeCustomer = 'Customer - Channel';
	
 	@isTest
    static void ContactTrigger_test(){
            Account acc = new Account(name='accountqqr',phone='phoneqqr', type='Customer - Channel', NIF__c='175253999');
            insert acc;
            Contact cont = new Contact(FirstName='anto', LastName='ola', Email = 'a@a.pt', phone='934213432',AccountID=acc.id, Send_Invoice__c = true);
            insert cont;
            Contact cont2 = new Contact(FirstName='anto', LastName='ola', Email = 'as@a.pt', phone='93423432',AccountID=acc.id, Send_Invoice__c = false);
            insert cont2;
			cont.Send_Invoice__c = false;
        try{
            update cont;
            System.assert(false, 'Test failed, the trigger didn\'t prevent the removal of all contacts with Send_Invoice__c field active');
        }
        catch(exception e){
            System.assert(true);
        }
        try{
          	Contact cont3 = new Contact(FirstName='anto', LastName='ola', Email = 'as@a.pt', phone='93423432',AccountID=acc.id, Send_Invoice__c = false);
            insert cont3;
            update cont3;
            System.assert(true);
        }
        catch(exception e){
            System.assert(false, 'Test failed, the trigger prevent a case that wasn\'t supposed to stop work');
        }
 
    }
    
    static testMethod void shouldUpdateLoginEmail(){
    	//setup
    	Account testClient = ClientAppService_TestUtils.createAccount(typeCustomer,''+nifCounter++);
        Login__c testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        Contact testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        
    	//test
    	Test.startTest();
    	testContact.Email = 'another@email.com';
    	update testContact;
    	Test.stopTest();
    	
    	//assert
    	Contact aux = [SELECT Login__r.Email__c, Login__r.Username__c FROM Contact WHERE Id = :testContact.Id];
    	system.assertEquals('another@email.com', aux.Login__r.Email__c,'Didnt update the login\'s email');
    	system.assertEquals('another@email.com', aux.Login__r.Username__c,'Didnt update the login\'s username');
    }
}