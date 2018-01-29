@isTest(SeeAllData=true)
public class CC_BH_CreateCollectionCase_Test {

    @isTest
    public static void createCollectionCase(){
        Map<String, String> infoMap = environment1();
        List<ID> idsList = new List<ID>();
        idsList.add(infoMap.get('client'));
        
        Test.startTest();        
        	Database.executeBatch(new CC_BH_CreateCollectionCase(idsList), 1);
        Test.stopTest();
        
        c2g__codainvoice__c si = [SELECT ID,Collection_Case__c FROM c2g__codainvoice__c WHERE ID = :infoMap.get('salesInvoice') LIMIT 1]  ;                        
                                  
        System.assert(si.Collection_Case__c != null);
    }
    
    @isTest
    public static void updateCollectionCase(){
        Map<String, String> infoMap = environment2();
        List<ID> idsList = new List<ID>();
        idsList.add(infoMap.get('client'));
        
        Test.startTest();        
        	Database.executeBatch(new CC_BH_CreateCollectionCase(idsList), 1);
        Test.stopTest();
        
        c2g__codainvoice__c si = [SELECT ID,Collection_Case__c FROM c2g__codainvoice__c WHERE ID = :infoMap.get('salesInvoice') LIMIT 1]  ;                        
                                  
        System.assert(si.Collection_Case__c != null);
    }
    
    @isTest
    public static void updateCollectionCaseDunning(){
        Map<String, String> infoMap = environment3();
        List<ID> idsList = new List<ID>();
        idsList.add(infoMap.get('client'));
        
        Test.startTest();        
        	Database.executeBatch(new CC_BH_CreateCollectionCase(idsList), 1);
        Test.stopTest();
        
        c2g__codainvoice__c si = [SELECT ID,Collection_Case__c FROM c2g__codainvoice__c WHERE ID = :infoMap.get('salesInvoice') LIMIT 1]  ;                        
                                  
        System.assert(si.Collection_Case__c != null);
    }    
        
    
    
    public static Map<String, String> environment1(){
        RentingApplication_Util_Test rUtils = new RentingApplication_Util_Test ();
        
  		Map<String, String> infoMap = new Map<String,String>();
        Account client = RentingApplication_Util_Test.createAccount('Manuel','Customer - Channel','123465789', null);
            infoMap.put('client', client.Id);
        system.debug(Limits.getQueries());
        
        Account vendor = RentingApplication_Util_Test.createAccount('Informatica','Channel Partner / Vendor','123456788', null);
            infoMap.put('vendor', vendor.Id);
        system.debug(Limits.getQueries());  
        
        String appID = RentingApplication_Util_Test.createApplication(client,vendor);
            infoMap.put('appID', appID);
    
        String bcID = RentingApplication_Util_Test.createBillingContract('AP-00250', client.ID, vendor.ID, appID, null);
            infoMap.put('bcID', bcID);    
        system.debug(Limits.getQueries());        
        
        c2g__codainvoice__c salesInvoice = FinancialForce_Util_Test.createInvoice(null, client.Id, appID);   
        	infoMap.put('salesInvoice', salesInvoice.ID);
        system.debug(Limits.getQueries());              
        
        return infoMap;
    }
    
    
    public static Map<String, String> environment2(){
        RentingApplication_Util_Test rUtils = new RentingApplication_Util_Test ();
        
  		Map<String, String> infoMap = new Map<String,String>();
        Account client = RentingApplication_Util_Test.createAccount('Manuel','Customer - Channel','123465789', null);
            infoMap.put('client', client.Id);
        system.debug(Limits.getQueries());
        
        Account vendor = RentingApplication_Util_Test.createAccount('Informatica','Channel Partner / Vendor','123456788', null);
            infoMap.put('vendor', vendor.Id);
        system.debug(Limits.getQueries());  
        
        String appID = RentingApplication_Util_Test.createApplication(client,vendor);
            infoMap.put('appID', appID);
    
        String bcID = RentingApplication_Util_Test.createBillingContract('AP-00250', client.ID, vendor.ID, appID, null);
            infoMap.put('bcID', bcID);    
        system.debug(Limits.getQueries());
        
        Collection_Case__c cc = new Collection_Case__c ();
        cc.Account__c = client.id;
        cc.Status__c = 'Open';
        insert cc;
        
        c2g__codainvoice__c salesInvoice = FinancialForce_Util_Test.createInvoice(null, client.Id, appID);   
        	infoMap.put('salesInvoice', salesInvoice.ID);
        system.debug(Limits.getQueries());              
        
        return infoMap;
    }    
    
    public static Map<String, String> environment3(){
        RentingApplication_Util_Test rUtils = new RentingApplication_Util_Test ();
        
  		Map<String, String> infoMap = new Map<String,String>();
        Account client = RentingApplication_Util_Test.createAccount('Manuel','Customer - Channel','123465789', null);
            infoMap.put('client', client.Id);
        system.debug(Limits.getQueries());
        
        Account vendor = RentingApplication_Util_Test.createAccount('Informatica','Channel Partner / Vendor','123456788', null);
            infoMap.put('vendor', vendor.Id);
        system.debug(Limits.getQueries());  
        
        String appID = RentingApplication_Util_Test.createApplication(client,vendor);
            infoMap.put('appID', appID);
    
        String bcID = RentingApplication_Util_Test.createBillingContract('AP-00250', client.ID, vendor.ID, appID, null);
            infoMap.put('bcID', bcID);    
        system.debug(Limits.getQueries());
        
        Collection_Case__c cc = new Collection_Case__c ();
        cc.Account__c = client.id;
        cc.Status__c = 'Open';
        insert cc;
        
        Dunning_Alert__c da = new Dunning_Alert__c();
        da.Collection_Case__c = cc.ID;
        da.Status__c = 'Open';
        da.Dunning_Level__c = '3rd Reminder';
        insert da;
        
        c2g__codainvoice__c salesInvoice = FinancialForce_Util_Test.createInvoice(null, client.Id, appID);   
        	infoMap.put('salesInvoice', salesInvoice.ID);
        system.debug(Limits.getQueries());              
        
        return infoMap;
    }      
}