//CREATED BY BP - 03/08/17 
//@Apex notation:
//class for resync sf docusign objects with Docusign
global class ReSyncDocusigns implements Schedulable, Database.AllowsCallouts 
{
	global void execute(SchedulableContext sc) 
	{		
		String interestDocusigns= 'SELECT dsfs__DocuSign_Envelope_ID__c '						 ; 
        interestDocusigns +=         'FROM dsfs__DocuSign_Status__c ' 							 ;
        interestDocusigns +=        'WHERE Deleted_by_partner__c = false '						 ;
        interestDocusigns +=          'AND dsfs__Envelope_Status__c IN (\'Delivered\',\'Sent\') ';
        interestDocusigns +=          'AND dsfs__DocuSign_Envelope_ID__c!= NULL ' 				 ;
        //interestDocusigns +=          'AND createddate = TODAY ' 								 ;       
        interestDocusigns +=        'ORDER BY createddate desc'								 	 ;

		ReprocessFailureConnectEnvelopes reprocess = new ReprocessFailureConnectEnvelopes(interestDocusigns);
      	Database.executebatch(reprocess);
	}//end execute method
}//end ReSyncDocusigns class