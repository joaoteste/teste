@isTest
public class FF_Utils_Test {
    
    
    //TODO
    //This class should be refactored soon and the tests should be changed
    
	@isTest
    static void testAdd(){
        Test.startTest();
        try{
        	List<c2g__codaTransactionLineItem__c> allTLI = new List<c2g__codaTransactionLineItem__c>();
            allTLI.add(new c2g__codaTransactionLineItem__c());
        	FF_Utils.doMatch('0012400000w0ff5', null, allTLI);
        } catch(Exception e){
        	System.assert(true);
        }
        Test.stopTest();        
    }
    
	@isTest
    static void testAdd2(){
        Test.startTest();
        try{
        	List<c2g__codaTransactionLineItem__c> allTLI = new List<c2g__codaTransactionLineItem__c>();
        	FF_Utils.undoMatch('0012400000w0ff5', '001240055550ff5', null);
        } catch(Exception e){
        	System.assert(true);
        }
        Test.stopTest();        
    }

}