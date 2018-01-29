@isTest(SeeAllData=true)
public class PC_CreateATM_Test {
    
    @isTest
    public static void test(){
      Account  accTest = new Account();
      accTest.NIF__c = '533999999';
        accTest.Name = 'TestCenas'; 
        accTest.Type = 'Customer - Channel';      
        insert accTest;
        
        Contact c = new Contact(LastName = 'test', Email = 'test@test.pt', Send_Invoice__c = true, AccountID = accTest.ID);
        insert c;
        
      Payment_Collection__c pc = new Payment_Collection__c();  
      pc.Expiry_Date__c = system.today();
      pc.Account__c = accTest.ID;
      insert pc;    
      
      Test.startTest();  
        PC_CreateATM.getNewMBReference('20', null, null, pc.ID);
      Test.stopTest();   
    } 
}