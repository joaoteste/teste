@isTest (SeeAllDAta = True)
public class AccountNifRecordTypeTest {
    
  /*  @testSetup
    static void createAccounts(){
        
        //First Accounts
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name ='John',Type='Channel Partner / Vendor',NIF__c='111111111');
        accountList.add(acc1);
        Account acc2 = new Account(Name ='Mary',Type='Channel Partner / Vendor',NIF__c='222222222');
        accountList.add(acc2);
        Account acc3 = new Account(Name ='Rachel',Type='Customer - Channel',NIF__c='111111111');
        accountList.add(acc3);
        Account acc4 = new Account(Name ='Kate',Type='Customer - Channel',NIF__c='222222222');
        accountList.add(acc4);
        Account acc5 = new Account(Name ='Peter',Type='Channel Partner / Vendor',NIF__c='333333333');
        accountList.add(acc5);
        insert accountList;
    }
    */
    @isTest()
    static void insertAccountSameNifRecordType(){
        try{
            System.debug('Beggin insertAccountSameNifRecordType test');
            List<Account> accountList = new List<Account>();
            //Add Account: same nif but diferent RecordType ->
            Account acc1 = new Account(Name ='Lincoln',Type='Customer - Channel',NIF__c='333333333');
            accountList.add(acc1);  
            
            //Add Account. Nif;RecordType AlreadyExists -> ERROR
            Account accToAdd = new Account(Name ='Michael',Type='Channel Partner / Vendor',NIF__c='0510663532'); //Nif/RecordType is the same as Account 00124000012vcys
            accountList.add(accToAdd);
            
            /*List<Account> accountListRecordTypeUpdated = new List<Account>();
            accountListRecordTypeUpdated.addAll(AccountTriggerClass.recordTypeWorkfow(accountList));
            AccountTriggerClass.checkNIFRecordType(accountListRecordTypeUpdated);*/
            insert accountList;
        }catch(Exception e){
         //   Boolean expectedExceptionThrown =  e.getMessage().contains('')) ? true : false;
         //   System.AssertEquals(expectedExceptionThrown, true);
              System.debug('Exception: '+e);
        }

    }
    
     @isTest()
    static void insert2IdenticalAccounts(){
        System.debug('Beggin insert2IdenticalAccounts test');
        try{
            List<Account> accountList = new List<Account>();
            //Add Account: same nif but diferent RecordType ->
            Account acc1 = new Account(Name ='Lincoln',Type='Channel Partner / Vendor',NIF__c='333333333');
            accountList.add(acc1);  
            
            //Add Account. Nif;RecordType AlreadyExists -> ERROR
            Account acc2 = new Account(Name ='Michael',Type='Channel Partner / Vendor',NIF__c='333333333');
            accountList.add(acc2);

           /* List<Account> accountListRecordTypeUpdated = new List<Account>();
            accountListRecordTypeUpdated.addAll(AccountTriggerHandler.recordTypeWorkfow(accountList));
            AccountTriggerHandler.checkNIFRecordType(accountListRecordTypeUpdated);*/
            insert accountList;
        }catch(Exception e){
         //   Boolean expectedExceptionThrown =  e.getMessage().contains('')) ? true : false;
         //   System.AssertEquals(expectedExceptionThrown, true);
              System.debug('Exception: '+e);
        }
    }
    
    @isTest()
    static void updateAccountSameNifRecordType(){
        System.debug('Beggin updateAccountSameNifRecordType test');
        try{
            List<Account> accountList = new List<Account>();
            //Add Account: same nif but diferent RecordType ->
            Account accToAdd = new Account(Name ='Lincoln',Type ='Channel Partner / Vendor',NIF__c ='222222222');
            accountList.add(accToAdd);  
            
            //Update Account: Nif;RecordType AlreadyExists -> ERROR
            Account accToUpdate = [Select Id, NIF__c, RecordTypeID From Account where Account.ID= '00124000012vcys'];  //OLD NIF: 0510663532
            accToUpdate.NIF__c = '504279670';
            accountList.add(accToUpdate);
            
          /*  List<Account> accountListRecordTypeUpdated = new List<Account>();
            accountListRecordTypeUpdated.addAll(AccountTriggerHandler.recordTypeWorkfow(accountList));
            AccountTriggerHandler.checkNIFRecordType(accountListRecordTypeUpdated);*/
            upsert accountList;
        }catch(Exception e){
           // Boolean expectedExceptionThrown =  e.getMessage().contains('ERRO') ? true : false;
          //  System.AssertEquals(expectedExceptionThrown, true);
            System.debug('Exception: '+e);
        }
    }
    
   @isTest()
    static void insertUpdateAccountSameNifRecordType(){
        System.debug('Beggin insertUpdateAccountSameNifRecordType test');
        try{
            List<Account> accountList = new List<Account>();
            //Add Account: same nif but diferent RecordType ->
            Account accToAdd = new Account(Name ='Lincoln',Type ='Channel Partner / Vendor',NIF__c ='333333333');
            accountList.add(accToAdd);  
            
            //Update Account: Nif;RecordType AlreadyExists -> ERROR
            Account accToUpdate = [Select Id, NIF__c, RecordTypeID From Account where Account.ID= '00124000012vcys'];  //OLD NIF: 0510663532
            accToUpdate.NIF__c = '333333333';
            accountList.add(accToUpdate);

           /* List<Account> accountListRecordTypeUpdated = new List<Account>();
            accountListRecordTypeUpdated.addAll(AccountTriggerHandler.recordTypeWorkfow(accountList));
            AccountTriggerHandler.checkNIFRecordType(accountListRecordTypeUpdated);*/
            upsert accountList;
        }catch(Exception e){
           // Boolean expectedExceptionThrown =  e.getMessage().contains('ERRO') ? true : false;
          //  System.AssertEquals(expectedExceptionThrown, true);
            System.debug('Exception: '+e);
        }
    }
    
    @isTest()
    static void changeNIFRecordTypeTwoAccount(){
        System.debug('Beggin changeNIFRecordTypeTwoAccount test');
        try{
            List<Account> accountList = new List<Account>();
                    
            //Add Account: same nif but diferent RecordType -> 
            Account accToUpdate = [Select Id, NIF__c, RecordTypeID From Account where Account.ID = '0012400000ssQ3y'];
            accToUpdate.NIF__c = '0510663532';
            accountList.add(accToUpdate);
            //Update Account: Nif;RecordType AlreadyExists -> 
            Account accToUpdate2 = [Select Id, NIF__c, RecordTypeID From Account where Account.ID= '00124000012vcys'];
            accToUpdate2.NIF__c = '504279670';
            accountList.add(accToUpdate2);

            /*List<Account> accountListRecordTypeUpdated = new List<Account>();
            accountListRecordTypeUpdated.addAll(AccountTriggerHandler.recordTypeWorkfow(accountList));
            Account;TriggerHandler.checkNIFRecordType(accountListRecordTypeUpdated);*/
            update accountList;
        }catch(Exception e){
            // Boolean expectedExceptionThrown =  e.getMessage().contains('')) ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
            System.debug('ExceptionChangeNifRecord2Account: '+e);
        }
    }
    
}