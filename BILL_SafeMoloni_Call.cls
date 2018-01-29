//Tests: BILL_QE_MoloniUpdateClientTest
public class BILL_SafeMoloni_Call{
	

    // In this method, which you'll note is not given the @future annotation, you'll
    //   place the code that you have in your current, not-as-safe, @future method
    private static void queueMoloniUpdateClient(List<Id> accountIdList){
    //    List<Contact> ContactUpdate = [SELECT id  FROM Contact where Id IN :accountIdList];
    
        ID jobID = System.enqueueJob(new BILL_QE_MoloniUpdateClient(accountIdList));
        system.debug('jobID' + jobID);
    }

    // This method doesn't look like it does too much, it's all we need to do to
    //   execute the 'doNormal' method above in an @future context.
    @future(callout=true)
    private static void doFutureMoloniUpdateClient(List<Id> accountIdList){
        queueMoloniUpdateClient( accountIdList);
    }

    // This is where the magic happens
    public static void executeMoloniUpdateClient(List<Id> accountIdList){
        if(System.isFuture() || System.isBatch()){
            // If we're in an async context that doesn't allow @future callouts,
            //   we can just simply call the non-@future version of the method.
            // This avoids the "can't call @future from @future" error.
            queueMoloniUpdateClient(accountIdList);
        } else {
            // If we're not in an async context, we can call the @future version
            //   (provided you haven't hit the limit yet)
            if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                doFutureMoloniUpdateClient(accountIdList);
            } else {
                // place some code in here to explicitly notify you that your request
                //   to run an @future method was denied.
                
                Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'MOLONI',
            																	message__c = 'Problem occurred in BILL_SafeMoloni_Call:' + accountIdList);
                insert record;
	            system.debug('CRITICAL: '+ record);

            }
        }
        
    }
    
}