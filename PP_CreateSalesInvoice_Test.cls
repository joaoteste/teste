@isTest(SeeAllData=true)
public class PP_CreateSalesInvoice_Test {
	
	@isTest
	public static void test(){
    	Map<String, ID> infoMap = AC_AssignmentContractAPI_Test.setData();     
    	PP_CreateSalesInvoice.createInvoice(infoMap.get('client'), system.today(), infoMap.get('appID'));
	} 
    
	@isTest
	public static void testInterest(){
    	Map<String, ID> infoMap = AC_AssignmentContractAPI_Test.setData();     
    	PP_CreateSalesInvoice.createInvoiceWithInterest(infoMap.get('client'), system.today(), infoMap.get('appID'),100, true);
	}

	@isTest
	public static void testFull(){
    	Map<String, ID> infoMap = AC_AssignmentContractAPI_Test.setData();     
    	PP_CreateSalesInvoice.createInvoiceFull(infoMap.get('client'), system.today(), infoMap.get('appID'),100,100, true);
	}    
    
	@isTest
	public static void testCost(){
    	Map<String, ID> infoMap = AC_AssignmentContractAPI_Test.setData();     
    	PP_CreateSalesInvoice.getCost(infoMap.get('client'));
	}      
}