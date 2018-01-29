// SEPA Schedulable SEPA Record to SEPA File
public class SEPA_SE_SR_to_SF implements Schedulable{

    //public static String CRON_EXP = '0 0 4 * * ?';
    
    public static String scheduleIt(String scheduleName, String CRON_EXP) {
        
        SEPA_SE_SR_to_SF se = new SEPA_SE_SR_to_SF();
        if(String.isBlank(scheduleName)){ scheduleName = 'SEPA_SE_SR_to_SF_' + Datetime.now().format('yyyy-MM-dd_hh:mm:ss');
        }
        return System.schedule(scheduleName, CRON_EXP, se);
    }
    
    public void execute(SchedulableContext SC) {
        
        SEPA_SR_to_SF.makeSepaFilesOfAllDocumentTypes();
        
    }
}