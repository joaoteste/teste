@isTest
public class ACT_BH_CreateParentAccount_Test {

    @isTest
    public static void test(){
        Account a = new Account();
        a.NIF__c = '513000125';
        a.Name = 'TestCompany';
        a.Type = 'Customer - Channel';
        insert a;
        
        Account b = new Account();
        b.NIF__c = '513000125';
        b.Name = 'TestCompany3';
        b.Type = 'Channel Partner / Vendor';
        insert b;   
        
        Account c = new Account();
        c.NIF__c = '513050125';
        c.Name = 'TestCompany';
        c.Type = 'Channel Partner / Vendor';
        insert c; 
        
        Contact ac = new Contact();
        ac.LastName = 'Test';
        ac.AccountId = a.ID;
        insert ac;
        
        List<ID> accountsID = new List<ID>{a.ID, b.ID, c.ID};
        Test.startTest();
        	Database.executeBatch(new ACT_BH_CreateParentAccount(accountsID),5);
        Test.stopTest();
        
        List<Account> acc1 = [select id, parentID from account where id = :a.ID];
        List<Account> acc2 = [select id, parentID from account where id = :b.ID];
        List<Account> acc3 = [select id, parentID from account where id = :c.ID];        
        
        system.assert(acc1[0].ParentID == acc2[0].ParentID);
        system.assert(acc1[0].ParentID != null);
        system.assert(acc3[0].ParentID != null);        
    }
    
    @isTest
    public static void testMoveContacts(){
        Account a = new Account();
        a.NIF__c = '513000125';
        a.Name = 'TestCompany';
        a.Type = 'Customer - Channel';
        insert a;
        
        
        Contact ac = new Contact();
        ac.LastName = 'Test';
        ac.AccountId = a.ID;
        insert ac;
        
        List<ID> accountsID = new List<ID>{a.ID};
        Test.startTest();
        	Database.executeBatch(new ACT_BH_MoveContacts(accountsID),5);
        Test.stopTest();
        
        List<Account> acc1 = [select id, parentID from account where id = :a.ID];
        List<Contact> ccList = [select id,AccountId  from contact where id = :ac.ID];
        
        system.assert(ccList[0].AccountId == acc1[0].ParentID);
    
    }    
    
}