//CREATED BY BP - 20/07/17 
//@Apex notation:
//class for reprocess requests which report is updating by Informa DB
global class ReprocessStopDistributionReports implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		List<Application__c> appsToReprocess = [SELECT ID,Name,accClient__c,accClient__r.Updating_Report__c,accClient__r.Nif__c 
												  FROM Application__c 
												 WHERE accClient__r.Updating_Report__c =  true AND Invoice_Payment_Date__c = NULL AND Contract_sent__c = NULL
											   ];
		for(Application__c currentApp : appsToReprocess){//AttendReports(String appId, String clientNif,String cliid)	
			//HP 21/11/2017 -> TODO:Alteração temporario para novo algoritmo esta class necessita de refactoring					   
			//System.enqueueJob(new AttendReports(currentApp.ID,currentApp.accClient__r.Nif__c,currentApp.accClient__c));

			CreditInfoContext  creditCtx = new CreditInfoContext(currentApp.accClient__r.Nif__c, 'PT', currentApp.accClient__c, currentApp.ID);
			CreditInfoProviderRequest creditInfoRequest = new CreditInfoProviderRequest(creditCtx);			
			ID jobID = System.enqueueJob(creditInfoRequest);
        	System.debug('[ReprocessStopDistributionReports] - ReprocessStopDistributionReports jobID: ' + jobID);
        }
	}//end execute method
}//end class