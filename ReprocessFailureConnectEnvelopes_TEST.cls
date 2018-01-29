@isTest (SeeAllData =true)
private class ReprocessFailureConnectEnvelopes_TEST 
{	
	@isTest static void bathchable_TEST()
	{
		String interestDocusigns= 'SELECT dsfs__DocuSign_Envelope_ID__c '						 ; 
        interestDocusigns +=         'FROM dsfs__DocuSign_Status__c ' 							 ;
        interestDocusigns +=        'WHERE Deleted_by_partner__c = false '						 ;
        interestDocusigns +=          'AND dsfs__Envelope_Status__c IN (\'Delivered\',\'Sent\') ';
        interestDocusigns +=          'AND dsfs__DocuSign_Envelope_ID__c!= NULL ' 				 ;
        //interestDocusigns +=          'AND createddate = TODAY ' 								 ;       
        interestDocusigns +=        'ORDER BY createddate desc LIMIT 25'						 ;

		ReprocessFailureConnectEnvelopes reprocess = new ReprocessFailureConnectEnvelopes(interestDocusigns);
      	Database.executebatch(reprocess);
	}
}