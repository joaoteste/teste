public class CancelApplications implements Schedulable{
    
    //public static String CRON_EXP = '0 0 4 * * ?';
    
    /**
    * Static method used to schedule applications cancellations
    *
    * @return The jobId from the scheduled run
    */
    public static String scheduleIt(String CRON_EXP) {
        CancelApplications ca = new CancelApplications();
        if(!test.isRunningTest()){
            return System.schedule('Cancel Applications', CRON_EXP, ca);
        } else {
            return System.schedule('Cancel Applications Test', CRON_EXP, ca);
        }
        return null;
    }
    
    public void execute(SchedulableContext sc) {

        datetime limitDate = null;

        if(Test.isRunningTest()){
            limitDate = System.today().addDays(-1 * Integer.ValueOf(0));
        }else{ 
            List<scoreCard_Config__c> daysToCancel =[ select id, Matching_Value_To_Nr__c from scoreCard_Config__c where RecordType.Name='Score Card' and RelatedObject__c='Application' and FieldName__c='Days Until Cancel Application']; 
            limitDate = System.today().addDays(-1 * Integer.ValueOf(daysToCancel[0].Matching_Value_To_Nr__c));
        }
        
        List<ID> failureID = new List<ID>();
        List<Application__c> applications = [SELECT ID, Cancelled__c, Status__c, CreatedDate 
                                             FROM Application__c 
                                             WHERE (Status__c = 'Application - Approved' OR 
                                                    Status__c = 'Application - Pendent' OR 
                                                    Status__c = '') AND 
                                                    Contract_Sent__c = NULL AND
                                                    Cancelled__c = False AND 
                                                    CreatedDate <=: limitDate];
        if(applications.size()>0){
            
            for(Application__c app : applications){
                app.Cancelled__c = True;
            }
            
            if (applications.size() + Limits.getDMLRows() > Limits.getLimitDMLRows()) {
                System.debug('Trying to update ' + applications.size() + ' applications but governor limits will only allow ' + Limits.getLimitDMLRows());
            }else{
                System.debug('Going to update ' + applications.size() + ' applications and governor limits will allow ' + Limits.getLimitDMLRows());
                
                Database.SaveResult[] lsr = Database.update(applications, false);
                
                for(Database.SaveResult sr : lsr){ 
                    if (!sr.isSuccess()) { 
                       failureID.add(sr.getId());
                    }
                }
                System.debug('CancelApplications failed to update' + failureID.size() + 'records: ' + failureID);
            }
        }
    }
}