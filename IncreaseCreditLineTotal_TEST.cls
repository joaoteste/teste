//CREATED BY BP - 04/05/17
@isTest (SeeAllData = true)
public class IncreaseCreditLineTotal_TEST 
{
	@isTest static void updatedCreditLineTotal_test()
    {
        Test.startTest();
        Account clientTest 					= new Account();
        clientTest.Name						='Client Test';
        clientTest.NIF__c					= '999999999';
        clientTest.Credit_line__c 			= 50000;
        clientTest.Available_Credit_Line__c = 20000;
        clientTest.Used_credit_line__c 		= 30000;
        insert clientTest;

        clientTest.Credit_line__c = 60000;
        update clientTest;

        try
        {
            clientTest.Credit_line__c = 20000;            
            update clientTest;   
        }
        catch(Exception e)
        {
    		Test.stopTest();   
    	}
        //Test.stopTest(); 
    }//end updatedCreditLineTotal_test method

    @isTest static void updatedCreditLineTotal_test1_COVER_REJECTLINES()
    {
        Test.startTest();
        List<Account> listClientTest = [SELECT ID,Name,Nif__c,Credit_line__c,Available_Credit_Line__c,Used_credit_line__c 
                                          FROM Account 
                                         WHERE Nif__c='999999999'];
        
        if(listClientTest.size()==0)
        {
            Account clientTest                  = new Account();
            clientTest.Name                     = 'Client Test';
            clientTest.NIF__c                   = '999999999';
            clientTest.Credit_line__c           = 50000;
            clientTest.Available_Credit_Line__c = 20000;
            clientTest.Used_credit_line__c      = 30000;
            listClientTest.add(clientTest);
            insert listClientTest;
        }
        try
        {
           listClientTest[0].Credit_line__c        = 25000;
           update listClientTest; 
        }
        catch(Exception e)
        {
            Test.stopTest();    
        }       
    }//end updatedCreditLineTotal_test1_COVER_REJECTLINES method   

    @isTest static void updatedCreditLineTotal_test2_COVER_REJECTLINES()
    {
        List<Account> listClientTest = [SELECT ID,Name,Nif__c,Credit_line__c,Available_Credit_Line__c,Used_credit_line__c 
                                          FROM Account 
                                         WHERE Nif__c='999999999'];
        
        if(listClientTest.size()==0)
        {
            Account clientTest                  = new Account();
            clientTest.Name                     = 'Client Test';
            clientTest.NIF__c                   = '999999999';
            clientTest.Credit_line__c           = 50000;
            clientTest.Available_Credit_Line__c = 20000;
            clientTest.Used_credit_line__c      = 30000;
            listClientTest.add(clientTest);
            insert listClientTest;
        }
        listClientTest[0].Credit_line__c        = 30499;
        update listClientTest;
    }//end updatedCreditLineTotal_test2_COVER_REJECTLINES method  

    @isTest static void updatedCreditLineTotal_COVER_undeleteCreditLineTotal()
    {
        Test.startTest();
        List<Account> listClientTest = [SELECT ID,Name,Nif__c,Credit_line__c,Available_Credit_Line__c,Used_credit_line__c 
                                          FROM Account 
                                         WHERE Nif__c='999999999'];
        
        if(listClientTest.size()==0)
        {
            Account clientTest                  = new Account();
            clientTest.Name                     = 'Client Test';
            clientTest.NIF__c                   = '999999999';
            clientTest.Credit_line__c           = 50000;
            clientTest.Available_Credit_Line__c = 20000;
            clientTest.Used_credit_line__c      = 30000;
            listClientTest.add(clientTest);
            insert listClientTest;
        }
        listClientTest[0].Credit_line__c        = 0;
        try
        {
            update listClientTest;  
        }
        catch(Exception e)
        {
            Test.stopTest();    
        }       
    }//end updatedCreditLineTotal_COVER_undeleteCreditLineTotal method  

}//end class