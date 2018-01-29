@isTest(SeeAllData=true)
public class AC_AssignmentContractAPI_Test {
	
	@isTest
	public static void testAssignmentContract(){
		Map<String, String> infoMap = setData();
		Test.startTest(); 
			AC_AssignmentContractAPI.assignmentContract('123456789', 'Merged Company', infoMap.get('bcID'), infoMap.get('client'), null);
		Test.stopTest();
	}
	
	@isTest
	public static void testCreateCostsInvoice(){
		Map<String, String> infoMap = setData();
		Test.startTest();
			AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));
		Test.stopTest();
	}
	
	@isTest
	public static void testSendToMoloni(){
		Map<String, String> infoMap = setData();
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));
		Test.startTest();
			AC_AssignmentContractAPI.sendToMoloni(infoMap.get('acID'));   
		Test.stopTest();
	}		

	@isTest
	public static void testGenerateCollection(){
		Map<String, String> infoMap = setData();
        AC_AssignmentContractAPI_Test.changeTypeOfAC('Closed Company', infoMap.get('acID'));
        
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AC_AssignmentContractAPI.sendToMoloni(infoMap.get('acID'));

		Test.startTest();
			AC_AssignmentContractAPI.generateCollection(infoMap.get('acID'));
		Test.stopTest();
	}			
	
	@isTest
	public static void testGenerateCollectionOldClient(){
		Map<String, String> infoMap = setData();
        AC_AssignmentContractAPI_Test.changeTypeOfAC('Closed Company', infoMap.get('acID'));
        AC_AssignmentContractAPI_Test.changeClientReceiver('Old Client', infoMap.get('acID'));
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AC_AssignmentContractAPI.sendToMoloni(infoMap.get('acID'));

		Test.startTest();
			AC_AssignmentContractAPI.generateCollection(infoMap.get('acID'));
		Test.stopTest();
	}		
	
	@isTest
	public static void testGenerateAttachment(){
		Map<String, String> infoMap = setData();
        AC_AssignmentContractAPI_Test.changeTypeOfAC('Merged Company', infoMap.get('acID'));
        
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AC_AssignmentContractAPI.sendToMoloni(infoMap.get('acID'));
		AC_AssignmentContractAPI.generateCollection( infoMap.get('acID'));
		Test.startTest();
			AC_AssignmentContractAPI.generateAttchment(false, infoMap.get('acID'));
		Test.stopTest();
	}	
	
	@isTest
	public static void testSendContract(){
		Map<String, String> infoMap = setData();
        AC_AssignmentContractAPI_Test.changeTypeOfAC('Closed Company', infoMap.get('acID'));
        
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AC_AssignmentContractAPI.sendToMoloni(infoMap.get('acID'));
		AC_AssignmentContractAPI.generateCollection(infoMap.get('acID'));
		AC_AssignmentContractAPI.generateAttchment(false, infoMap.get('acID'));
		Test.startTest();
			AC_AssignmentContractAPI.sendContract(infoMap.get('acID'));
		Test.stopTest();
	}
	
	@isTest
	public static void testSendEmail(){
		Map<String, String> infoMap = setData();
        AC_AssignmentContractAPI_Test.changeTypeOfAC('Closed Company', infoMap.get('acID'));
        
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AC_AssignmentContractAPI.sendToMoloni(infoMap.get('acID'));
		AC_AssignmentContractAPI.generateCollection(infoMap.get('acID'));
		Test.startTest();
			AC_AssignmentContractAPI.sendEmail(infoMap.get('acID'));
		Test.stopTest();
	}		
	
	@isTest
	public static void testfinalizeAssignmentOfContract(){
		Map<String, String> infoMap = setData();
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AC_AssignmentContractAPI.sendToMoloni(infoMap.get('acID'));
		AC_AssignmentContractAPI.generateCollection(infoMap.get('acID'));
		Test.startTest();
			AC_AssignmentContractAPI.finalizeAssignmentOfContract(infoMap.get('acID'));
		Test.stopTest();
	}	
	
	@isTest
	public static void testMandatorySigners(){
		Map<String, String> infoMap = setData();
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AC_AssignmentContractAPI.sendToMoloni(infoMap.get('acID'));
		AC_AssignmentContractAPI.generateCollection(infoMap.get('acID'));
		Test.startTest();
			AC_AssignmentContractAPI.mandatorySigners(AC_AssignmentContractAPI.updateAC(infoMap.get('acID')));
		Test.stopTest();
	}
	 
	@isTest
	public static void testCreateAccount(){
		Test.startTest();
			AC_AssignmentContractAPI.createAccount('123456789');
		Test.stopTest();
	}	
	
	@isTest
	public static void testCreateAccount2(){
		Test.startTest();
			AC_AssignmentContractAPI.createAccount('99663388');
		Test.stopTest();
	}		
    
	@isTest
	public static void testSalesInvoices(){
        Map<String, String> infoMap = setData();
        ID clientID = infoMap.get('client');
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AssignmentContract__c ac = [SELECT ID, Costs_Sales_Invoice__c FROM AssignmentContract__c WHERE ID = :infoMap.get('acID') ];  
        ID invoiceID = ac.Costs_Sales_Invoice__c;
        system.debug(invoiceID);
		Test.startTest();
        	Database.executeBatch(new AC_BH_SalesInvoice(clientID, new ID[] {invoiceID}));
		Test.stopTest();
	}	

	@isTest
	public static void testCreditNotes(){
        Map<String, String> infoMap = setData();        
        ID clientID = infoMap.get('client');
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AssignmentContract__c ac = [SELECT ID, Costs_Sales_Invoice__c FROM AssignmentContract__c WHERE ID = :infoMap.get('acID') ];  
        ID invoiceID = ac.Costs_Sales_Invoice__c;
        system.debug(invoiceID);
		Test.startTest();
			AC_AssignmentContractAPI.createCreditNotes(infoMap.get('acID'));
        	//Database.executeBatch(new AC_BH_CreditNote(new ID[] {invoiceID}));
		Test.stopTest();
	}    

	@isTest
	public static void testCreditNotesBtach(){
        Map<String, String> infoMap = setData();        
        ID clientID = infoMap.get('client');
		AC_AssignmentContractAPI.createCostsInvoice(infoMap.get('client'), infoMap.get('appID'), infoMap.get('acID'));	
		AssignmentContract__c ac = [SELECT ID, Costs_Sales_Invoice__c FROM AssignmentContract__c WHERE ID = :infoMap.get('acID') ];  
        ID invoiceID = ac.Costs_Sales_Invoice__c;
        system.debug(invoiceID);
		Test.startTest();
        	Database.executeBatch(new AC_BH_CreditNote(new ID[] {invoiceID}));
		Test.stopTest();
	} 
	
	@isTest
	public static void testCreateJournals(){
		Map<String, String> infoMap = setData();
		Test.startTest();
			AC_AssignmentContractAPI.createJournals(infoMap.get('acID'));
		Test.stopTest();
	}			
		
	public static Map<String, ID> setData(){
        Map<String, ID> infoMap = new Map<String,String>();
        Account client = RentingApplication_Util_Test.createAccount('Joao','Customer - Channel','123456777');
        	infoMap.put('client', client.Id);
        Account vendor = RentingApplication_Util_Test.createAccount('Bricolage','Channel Partner / Vendor','123456666');
        	infoMap.put('vendor', vendor.Id);
        ID appID = RentingApplication_Util_Test.createApplication(client,vendor);
        	infoMap.put('appID', appID);
        ID bcID = RentingApplication_Util_Test.createBillingContract('AP-000123', client.ID, vendor.ID, appID);
        	infoMap.put('bcID', bcID);
        AssignmentContract__c ac = RentingApplication_Util_Test.createAssignmentOfContract(client.ID, vendor.ID, appID, bcID);
        	infoMap.put('acID', ac.ID); 
        	
        return infoMap;        	     			        			
	}
    
    public static void changeTypeOfAC(String typeOfAC, ID acID){
        AssignmentContract__c ac = [SELECT ID FROM AssignmentContract__c WHERE ID = :acID];
        ac.TypeOfAssignContract__c = typeOfAC;
        update ac;
    }
    
    public static void changeClientReceiver(String client, ID acID){
        AssignmentContract__c ac = [SELECT ID FROM AssignmentContract__c WHERE ID = :acID];
        ac.Invoice_Receiver__c = client;
        update ac;    	
    }

	
    
}