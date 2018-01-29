//CREATED BY BP - 04/08/17
global class ReprocessFailureConnectEnvelopes implements Database.Batchable<sObject>,Database.AllowsCallouts 
{		
	final 	Integer DAYS_IN_A_WEEK = 7;
	final 	Integer DOCUSIGN_ID_LENGTH = 36;
	private String 	accountId;
	private String query; 
	private DateTime endDateTime;
	private DateTime beginDateTime;
	
	global ReprocessFailureConnectEnvelopes(String query)
	{
		this.query    = query;
		accountId     = CandorDocuments.getDocuSignCredentials().get('accountId');
		endDateTime   = System.now();
		beginDateTime = endDateTime.addDays(-DAYS_IN_A_WEEK);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		System.debug('[ReprocessFailureConnectEnvelopes] --> Batch is starting at (' + endDateTime + ')  Start batch query: ' + query);
		//System.debug('[ReprocessFailureConnectEnvelopes] --> Will run for '+ Database.countQuery(query)+' records...');
		return Database.getQueryLocator(query);
	}//end start method

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{		
		Set<String> envelopeIds = new Set<String>();

		for(dsfs__DocuSign_Status__c curr : (List<dsfs__DocuSign_Status__c>) scope)
			if(curr.dsfs__DocuSign_Envelope_ID__c.length() == DOCUSIGN_ID_LENGTH)
				envelopeIds.add(curr.dsfs__DocuSign_Envelope_ID__c);

		CandorDocuments.reprocessFailureConnectEnvelopes(accountId,beginDateTime,endDateTime,envelopeIds);
	}//end execute method
	
	global void finish(Database.BatchableContext BC)
	{
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email,ExtendedStatus,JobType,CompletedDate
						    FROM AsyncApexJob 
						   WHERE Id =:BC.getJobId()
						 ];

		Utilities.LogIntegration(endDateTime, Datetime.now(), a.Status, 'REPROCESS_FAILURE_CONNECT_ENVELOPES', 'JobId: ' + a.Id 
								 + ' || JobType: '+ a.JobType +' || Number of errors: ' + a.NumberOfErrors +  ' || Total Job items: ' + a.TotalJobItems 
								 + '|| Job Items Processed: ' + a.JobItemsProcessed +' || Extended Status: '+a.ExtendedStatus,'');
	
		if(a.NumberOfErrors > 0 && ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox)
		{
			String[] toAddresses = new List<String>();toAddresses.add('sf.candor@worldit.pt');
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setSubject('There was a problem running ReprocessFailureConnectEnvelopes');email.setToAddresses(toAddresses);
			email.setPlainTextBody('[ReSync Docusigns Schedule] --> ReprocessFailureConnectEnvelopes: \nJobId: ' + a.Id + '\nCompletedDate: ' + a.CompletedDate + '\nStatus: '+ a.Status + '\nTotal Job items: ' + a.TotalJobItems 
									+ '\nJob Items Processed: ' + a.JobItemsProcessed + '\nNumber of errors: ' + a.NumberOfErrors + '\nExtended Status: '+a.ExtendedStatus);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		}
	 	System.debug('[ReprocessFailureConnectEnvelopes] --> ReprocessFailureConnectEnvelopes Finished - jobId: ' + 'JobId: ' 
	 				+ a.Id + ' || Number of errors: ' + a.NumberOfErrors +  ' || Total Job items: ' + a.TotalJobItems 
	 				+ '|| Job Items Processed: ' + a.JobItemsProcessed);	
	}//end finish method	
}// end ReprocessFailureConnectEnvelopes class