// Test class: SEPA_SE_SR_to_SF_Test
//SEPA records to SEPA File
public class SEPA_SR_to_SF {
	    
    private static Integer MAX_NUMBER_SEPA_RECORDS_IN_SEPA_FILE = 100;
    
    public static void makeSepaFilesOfAllDocumentTypes(){
    	
    	List <CR_Sepa_Admin__c> sas = [
                Select Id
                , Name
                , Activation_Date__c
                , Preferred_Weekday__c
                , SEPA_Movement_Type__c
                , SEPA_Category_Purpose__c
                , SEPA_Initiating_Party_Name__c
                , SEPA_Our_Bank_SWIFT_BIC__c
                , SEPA_Our_Bank_IBAN__c
                , SEPA_Our_Bank_Private_Identification__c
                , SEPA_Payment_Method__c
                , SEPA_Service_Type__c
                , SEPA_Tag_xmlns__c
                , SEPA_Tag_xmlns_xsi__c
                FROM CR_Sepa_Admin__c
        ];
        
        for(CR_Sepa_Admin__c sa : sas){
        	makeSepaFilesOfActivationDay(sa);
        }
    }
    
    public static void makeSepaFilesOfActivationDay(CR_Sepa_Admin__c sa){
        
        Datetime startDatetime = Datetime.now();
        
        List<CR_Sepa_Record__c> srs = [
            SELECT
            Id,
            Name
            , Document_Due_Date__c
            , Document_Type__c
            , Activation_Date__c
            , CR_Sepa_File__c
            , Debtor_Account__c
            , Debtor_Name__c
            , IBAN__c
            , Invoice_Number__c
            , Mandate_Date__c
            , Mandate_Identification__c
            , Request_Count__c
            , Request_Amount__c
            , Request_Currency__c
            , Request_DateTime__c
            , Return_Amount__c
            , Return_Currency__c
            , Return_DateTime__c
            , Swift_Bic__c
            FROM CR_Sepa_Record__c
            WHERE
            CR_Sepa_File__c = null
            AND Activation_Date__c != null
            AND Document_Type__c = :sa.SEPA_Movement_Type__c
            AND Invalid_Record__c = false
            AND Request_Amount__c != 0
        ];
        
        system.debug(LoggingLevel.INFO, 'SEPA_SR_to_SF makeSepaFilesOfActivationDay Activation_Date: ' + Date.today() + ' sa.SEPA_Movement_Type__c: ' + sa.SEPA_Movement_Type__c + ' srs.size(): ' + srs.size());
 
        if(srs.size() == 0){
        	system.debug(LoggingLevel.WARN, 'SEPA_SR_to_SF makeSepaFilesOfActivationDay CR_Sepa_Record__c not found for Activation_Date: ' + Date.Today() + ' sa.SEPA_Movement_Type__c: ' + sa.SEPA_Movement_Type__c );
        	return;
        }

		List<List<CR_Sepa_Record__c>> sepaRecordsListList =  getSepaRecordsBySalesAdmin(sa, srs);
            
        List<CR_Sepa_File__c> sfs = new List<CR_Sepa_File__c>();
       
        for(List<CR_Sepa_Record__c> sepaRecordsList : sepaRecordsListList){
	
			CR_Sepa_File__c sf = new CR_Sepa_File__c();
			sf.SEPA_Category_Purpose__c = sa.SEPA_Category_Purpose__c;
	        sf.SEPA_Collection_Date__c = SEPA_UTILS.processExecutionDate(sa, Date.Today() ) ;
	        sf.Activation_Date__c = Date.Today();
	        sf.SEPA_Initiating_Party_Name__c = sa.SEPA_Initiating_Party_Name__c;
	        sf.SEPA_Movement_Type__c = sa.SEPA_Movement_Type__c;
	        sf.SEPA_Our_Bank_SWIFT_BIC__c = sa.SEPA_Our_Bank_SWIFT_BIC__c;
	        sf.SEPA_Our_Bank_IBAN__c = sa.SEPA_Our_Bank_IBAN__c;
	        sf.SEPA_Our_Bank_Private_Identification__c = sa.SEPA_Our_Bank_Private_Identification__c;
	        sf.SEPA_Payment_Method__c = sa.SEPA_Payment_Method__c;
	        sf.SEPA_Service_Type__c = sa.SEPA_Service_Type__c;
	        sf.SEPA_Tag_xmlns__c = sa.SEPA_Tag_xmlns__c;
	        sf.SEPA_Tag_xmlns_xsi__c = sa.SEPA_Tag_xmlns_xsi__c;
	        sf.Creation_DateTime__c  = startDatetime;
        
        	SEPA_UTILS.outputSepaFile(sf);
        	
        	sfs.add(sf);
		}
                
        insert sfs;
        
        sfs = [
                Select Id
                , Name
                , SEPA_Category_Purpose__c
                , SEPA_Collection_Date__c
                , SEPA_Initiating_Party_Name__c
                , SEPA_Movement_Type__c
                , SEPA_Our_Bank_SWIFT_BIC__c
                , SEPA_Our_Bank_IBAN__c
                , SEPA_Our_Bank_Private_Identification__c
                , SEPA_Payment_Method__c
                , Request_DateTime__c
                , Request_Records_Count__c
                , Request_Total_Ammount__c
                , Return_DateTime__c
                , Return_Records_Count__c
                , Return_Total_Amount__c
                , SEPA_Service_Type__c
                , SEPA_Tag_xmlns__c
                , SEPA_Tag_xmlns_xsi__c
                FROM CR_Sepa_File__c
                WHERE Id IN :sfs
            ];

        //add name to SF and sf.Id to sepa recs of its due date
        for(Integer i = 0; i < sfs.size(); i++ ){

        	sfs.get(i).SEPA_File_Name__c = sfs.get(i).Name;
        	for(CR_Sepa_Record__c sr : sepaRecordsListList.get(i)){
				sr.CR_Sepa_File__c = sfs.get(i).Id;
			}
			
        }
        
		update sfs;			
		update srs;        
    }

    // get the records of the respective SalesAdmin split by MAX_NUMBER_SEPA_RECORDS_IN_SEPA_FILE 
    // (no SEPA file should have more than MAX_NUMBER_SEPA_RECORDS_IN_SEPA_FILE SEPA records because of some limitations in cash matching in Financial Force)
    private static List<List<CR_Sepa_Record__c>> getSepaRecordsBySalesAdmin(CR_Sepa_Admin__c sa, List<CR_Sepa_Record__c> sepaRecordList){
    	List<List<CR_Sepa_Record__c>> srsByListList = new List<List<CR_Sepa_Record__c>>();
    	List<CR_Sepa_Record__c> srsByList;
    	Datetime startDatetime = Datetime.now();
   
        Integer countSR = 0;
    	for(CR_Sepa_Record__c sr : sepaRecordList){

        	system.debug(LoggingLevel.INFO, 'SEPA_SR_to_SF makeSepaFilesOfActivationDay sr.Document_Due_Date__c: ' + sr.Document_Due_Date__c + ' sr.Name: ' + sr.Name + ' sr.Debtor_Account__c: ' + sr.Debtor_Account__c );

            Date activationDate = SEPA_UTILS.processActivationDate(sa, sr.Document_Due_Date__c);  //TODO If we don't want to recalculate use sr.activationDate and value < TODAY
            if(activationDate == Date.Today()){

				Integer remainder = math.mod(countSR, MAX_NUMBER_SEPA_RECORDS_IN_SEPA_FILE);
				
				if(remainder == 0){
					srsByList = new List<CR_Sepa_Record__c>();
					srsByListList.add(srsByList); 
				}
				srsByList.add(sr);
				
				countSR++;
            }
        }
        
        return srsByListList;
    }
    
}