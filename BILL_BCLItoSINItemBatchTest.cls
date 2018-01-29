@isTest (SeeAllData = true)
public class BILL_BCLItoSINItemBatchTest {
    
    @isTest
    public static void testSomeAppBatch(){
        List<String> contractStatusList = new List<String>();
        contractStatusList.add('Contract - Running');
        contractStatusList.add('Contract - Arreas');
        contractStatusList.add('Contract - Arrears');
        contractStatusList.add('Contract - Closed');
        contractStatusList.add('Contract - Lawsuit');
        contractStatusList.add('Contract - Payment Plan');
        contractStatusList.add('Contract Early Termination');
        contractStatusList.add('Contract - Cancelled');
        
        List<Application__c> appList = new List<Application__C>([Select Id,Name from Application__c where Status__c in :contractStatusList ]);
        List<String> appNameList = new List<String>();

        for(Application__c app :appList){
            appNameList.add(app.Name);
        }
        
        Database.executeBatch(new BILL_BCLItoSINItemBatch(appNameList), 1);
    }
    
    @isTest
    public static void testBatch(){
        Database.executeBatch(new BILL_BCLItoSINItemBatch(), 1);
    }
    
    @isTest
    public static void testBatch2(){
        List<Application__c> appList = new List<Application__C>([Select Id,Name from Application__c where id = 'a012400000gIZLg']);
        
        List<String> appNameList = new List<String>();

        for(Application__c app :appList){
            appNameList.add(app.Name);
        }
        
        Database.executeBatch(new BILL_BCLItoSINItemBatch(appNameList), 1);

    }
}