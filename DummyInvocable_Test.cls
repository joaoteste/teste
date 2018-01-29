@isTest
public with sharing class DummyInvocable_Test {
	
    public static testMethod  void TestgetApplicationsInvoicese(){
        
        Test.startTest();
        
        DummyInvocable.dummyMethod();
        
        Test.stopTest();
    }
    
}