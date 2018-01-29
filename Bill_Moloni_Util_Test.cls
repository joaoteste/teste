@isTest
public class Bill_Moloni_Util_Test {
	
	
	@isTest
	public static void getPDF_Test(){
		
		ID parentID = 'a2y24000001LZmR';
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		 
		Test.startTest();
		Attachment att = Bill_Moloni_Util.getPDF('https://www.moloni.com/downloads/?h=98c7ef90097e57380732398e083348e5&d=189548629', 'test', parentID);
		Bill_Moloni_Util.addAttchment(email, att);
		Test.stopTest();	
			
	}
	    
}