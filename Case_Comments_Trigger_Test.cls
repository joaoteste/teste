@isTest(SeeAllData = true)
private class Case_Comments_Trigger_Test {
	
	private static Integer nifCounter = 100000000;
	private static String typeCustomer = 'Customer - Channel';
	
	private static String priority = 'High';
	private static String type = 'Cliente';
	private static String category = 'Contrato';
	private static String reason = 'Reenvio do Contrato';
	private static String description = 'mas que grande descrição';
	private static String commentText = 'mas que grande comentario';
	
    private static Account testClient;
	private static Contact testContact;
	private static Case testCase;
	private static CaseComment testCaseComment;

    static testMethod void shouldUpdateParentCase() {
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testContact = ClientAppService_TestUtils.createContact(testClient, null);
        testCase = Case_Utils.newCase(priority, type, category, reason, description, testClient.Id);
        insert testCase;
        
        Test.startTest();
        testCaseComment = Case_Utils.newCaseComment(''+testCase.Id, commentText);
        insert testCaseComment;
        Test.stopTest();
        
        
        Case aux = [SELECT Last_Comment_Text__c, New_Comment__c FROM Case WHERE Id = :testCase.Id];
        //system.assert(aux.New_Comment__c , 'Didnt set the new comment checkbox to TRUE in case');
        system.assert(aux.Last_Comment_Text__c != null, 'Didnt set the last comment text in case');
        system.assertEquals(commentText, aux.Last_Comment_Text__c, 'Didnt set the correct last comment text in case');
    }
}