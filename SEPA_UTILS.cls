//TODO check test Classes: 
//SEPA_GL_Web_Services_Test, SEPA_ImportSentRequestFiles_Test, SEPA_PI_to_SR_TEST, SEPA_SCN_to_SR_TEST,SEPA_SE_SR_to_SF_Test, SEPA_SF_Return_Test, SEPA_SI_to_SR_TEST, SEPA_UTILS_TEST, SEPA_QE_SF_Return_SepaFileUpdate_TEST
//SEPA_BH_SF_ReturnUndoCashMatchTest ,SEPA_QE_SF_Return_ProcessUndoCashMatTest
public class SEPA_UTILS {


/*    
    //TODO PARA APAGAR NÃO SERVE PARA NADA ESTE CÓDIGO
    public static void outputSepaRec(CR_Sepa_Record__c sepaRec) {
        outputSepaRec(Test.isRunningTest() ? LoggingLevel.DEBUG : LoggingLevel.Fine, sepaRec);
    }
*/    
    
    public static void outputSepaFile(CR_Sepa_File__c sepaFile, LoggingLevel level) {
        
        system.debug(level, 'sepaFile.Id: ' + sepaFile.Id
                     + '\nsepaFile.Name: ' + sepaFile.Name
                     + '\nsepaFile.SEPA_Category_Purpose__c: ' + sepaFile.SEPA_Category_Purpose__c
                     + '\nsepaFile.SEPA_Collection_Date__c: ' + sepaFile.SEPA_Collection_Date__c
                     + '\nsepaFile.SEPA_Initiating_Party_Name__c: ' + sepaFile.SEPA_Initiating_Party_Name__c
                     + '\nsepaFile.SEPA_Movement_Type__c: ' + sepaFile.SEPA_Movement_Type__c
                     + '\nsepaFile.SEPA_Our_Bank_SWIFT_BIC__c: ' + sepaFile.SEPA_Our_Bank_SWIFT_BIC__c
                     + '\nsepaFile.SEPA_Our_Bank_IBAN__c: ' + sepaFile.SEPA_Our_Bank_IBAN__c
                     + '\nsepaFile.SEPA_Our_Bank_Private_Identification__c: ' + sepaFile.SEPA_Our_Bank_Private_Identification__c
                     + '\nsepaFile.SEPA_Payment_Method__c: ' + sepaFile.SEPA_Payment_Method__c
                     + '\nsepaFile.Request_DateTime__c: ' + sepaFile.Request_DateTime__c
                     + '\nsepaFile.Request_Records_Count__c: ' + sepaFile.Request_Records_Count__c
                     + '\nsepaFile.Request_Total_Ammount__c: ' + sepaFile.Request_Total_Ammount__c
                     + '\nsepaFile.Return_DateTime__c: ' + sepaFile.Return_DateTime__c
                     + '\nsepaFile.Return_Records_Count__c: ' + sepaFile.Return_Records_Count__c
                     + '\nsepaFile.Return_Total_Amount__c: ' + sepaFile.Return_Total_Amount__c
                     + '\nsepaFile.SEPA_Service_Type__c: ' + sepaFile.SEPA_Service_Type__c
                     + '\nsepaFile.SEPA_Tag_xmlns__c: ' + sepaFile.SEPA_Tag_xmlns__c
                     + '\nsepaFile.SEPA_Tag_xmlns_xsi__c: ' + sepaFile.SEPA_Tag_xmlns_xsi__c
                    );
    }
		    
		    
    public static void outputSepaFile(CR_Sepa_File__c sepaFile) {
        outputSepaFile(sepaFile, Test.isRunningTest() ? LoggingLevel.DEBUG : LoggingLevel.Fine);
    }
    
    
    public static string SepaCharacterCompliance(string input) {
        if (input == null) {
            integer origin = getCodeLineFromStack(2);
            system.debug(LoggingLevel.INFO, 'SEPA_UTILS SepaCharacterCompliance input is null, origin:' + origin);
            if (Test.isRunningTest()) {
                input = SepaCharacterCompliance(CR_Randomizer.getPlaceholderText(10));system.debug(LoggingLevel.INFO, 'SEPA_UTILS SepaCharacterCompliance isRunningTest(), returning :' + input);
                return input;
            }
            Utilities.LogIntegration(datetime.now(), datetime.now(), 'Warning', 'SEPA_UTILS SepaCharacterCompliance input is null', 'origin:' + origin, 'SepaCharacterCompliance');
            return input;
        }
        String output = input;
        while (output.contains('//')) {
            output = output.replace(('//'), '/');
        }
        output = output.removeStart('/').removeEnd('/').replace('€', 'E').replace('&', '+').replace('_', '-').replace('@', '(at)').replaceAll(('[^a-zA-Z0-9 /\\-?:().,\'+]'), '?');

        return output;
    }
    
    
    public static string SepaCharacterCompliance(String input, integer lenght) {
        return SepaCharacterCompliance(input).left(lenght);
    }
    
    
    private static integer getCodeLineFromStack(integer deep) {
        try {
            throw new CR_EN_GetCodeLineFromStack_Exception();
        } catch (HandledException e) {
            system.debug(LoggingLevel.INFO, e.getStackTraceString());String line = e.getStackTraceString().split('\n')[deep];Pattern patt = Pattern.compile('([a-z0-9_.]+): line (\\d+)');Matcher match = patt.matcher(line);match.find();
            return Integer.valueOf(match.group(2));
        }
    }


	public static c2g__codaBankAccount__c getBankAccountFromIBAN(string iban) {
        system.debug(LoggingLevel.INFO, 'CR_SEPA getBankAccountFromIBAN for iban: ' + iban);
        c2g__codaBankAccount__c BankAccount = [SELECT ID, Name, c2g__IBANNumber__c, c2g__OwnerCompany__c, c2g__BankAccountCurrency__r.Id FROM c2g__codaBankAccount__c where c2g__IBANNumber__c = :iban];
        return BankAccount;
    }
    
    
    public static c2g__codaPeriod__c getPeriod(String periodString) {
        system.debug(LoggingLevel.INFO, 'c2g__codaPeriod__c getPeriod periodDate' + periodString);
        Date periodDate = Date.newInstance(Integer.valueOf(periodString.substring(0, 4)), Integer.valueOf(periodString.substring(5, 7)), Integer.valueOf(periodString.substring(8, 10)));
        return getPeriod(periodDate);
    }
    
    
    public static c2g__codaPeriod__c getPeriod(date periodDate) {
        system.debug(LoggingLevel.INFO, 'c2g__codaPeriod__c getPeriod periodDate' + periodDate);
        c2g__codaPeriod__c period = [SELECT ID FROM c2g__codaPeriod__c where c2g__StartDate__c <= :periodDate AND c2g__EndDate__c >= :periodDate and c2g__Description__c = 'Trading Period'];
        return period;
    }
    
    
    public static Map<String, String> getBicFromIbanMap() {
        List<Bank_Codes__c> Bank_Codes_List = [SELECT Bank_Code__c, BIC__c FROM Bank_Codes__c];
        Map<String, String> bicFromIbanMap = new Map<String, String>();
        for (Bank_Codes__c bc : Bank_Codes_List) {
            bicFromIbanMap.put(bc.Bank_Code__c, bc.BIC__c);
        }
        system.debug(LoggingLevel.INFO, 'bicFromIbanMap.size(): ' + bicFromIbanMap.size());
        return bicFromIbanMap;
    }
    
    public static Map<String, String> getCurrencyISOFromIdMap() {
        List<c2g__codaAccountingCurrency__c> accountingCurrency_List = [SELECT id, Name, c2g__OwnerCompany__c FROM c2g__codaAccountingCurrency__c];
        Map<String, String> currencyISOFromIdMap = new Map<String, String>();
        for (c2g__codaAccountingCurrency__c ac : accountingCurrency_List) {
            currencyISOFromIdMap.put(ac.id, ac.Name);
        }
        
        system.debug(LoggingLevel.INFO, 'currencyISOFromIdMap.size(): ' + currencyISOFromIdMap.size());
        return currencyISOFromIdMap;
    }

    public static List<String> getDocumentTypesForPI(){
    	
    	return new List<String>{'Payments','PaymentsVendors'};

    }
    
    public static String getDocumentTypeAPIName(SObject ffObject){
    	if(ffObject instanceof c2g__codaInvoice__c){
            return 'RCUR';
        }
        if(ffObject instanceof c2g__codaPurchaseInvoice__c){
        	if(((c2g__codaPurchaseInvoice__c)ffObject).c2g__Account__r.Type == 'Channel Partner / Vendor'){
	        	return 'PaymentsVendors';
        	}
        	return 'Payments';
        }
        if(ffObject instanceof c2g__codaCreditNote__c){
            return 'SalesCreditNotes';
        }
        return null;
    }
    
       
    public static CR_Sepa_Admin__c getSepaAdmin(SObject ffObject){

		return getSepaAdmin(getDocumentTypeAPIName(ffObject));

    }
    
    
    /**
    * Segunda = 0 ; Quarta = 2 ; Domingo = 6
    */
    public static Integer getWeekDay(Date dateTemp){

	    Date monday = Date.newInstance(1900, 1, 1);
	
		return Math.mod(monday.daysBetween(dateTemp), 7);
        
    }
    
    public static CR_Sepa_Admin__c getSepaAdmin(String Movement_Type){
    	
    	system.debug(LoggingLevel.INFO, 'getSepaAdmin for Movement_Type: ' + Movement_Type);
    
    	CR_Sepa_Admin__c sepaAdmin = [
                Select Id
                , Name
                , Activation_Date__c
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
                , Preferred_Weekday__c
                FROM CR_Sepa_Admin__c
                WHERE SEPA_Movement_Type__c = :Movement_Type
            ];

		return sepaAdmin;
    }
    
/*	
	public static CR_Sepa_Record__c createNewSepaRecord(Date Document_Due_Date, String Document_Type, Date Activation_Date, ID opId, String opName, String opIBAN, String opInvoiceNumber, Date opMandateDate, String opMandateIdentification, decimal opRequestAmount, String opRequestCurrency, String opSwiftBic, 
	                                                    SObject ffObject, Date paymentDate) {
        
        CR_Sepa_Record__c sepaRec = new CR_Sepa_Record__c();

		//activation day ]e feriado? se sim ver o dia anterior enquanto for maior ou igual a today.
//TODO Este código nunca devia estar aqui!!!!!!!!!!!! WTF
		String BusinessHoursId = CR_CS_SEPA_Config__c.getValues('SEPA_SI_BusinessHoursID').Value_String__c;
		while(!BusinessHours.isWithin(BusinessHoursId, Activation_Date) && Activation_Date > Date.Today()){
			Activation_Date = Activation_Date.addDays(-1);
		}

        sepaRec.Document_Due_Date__c = Document_Due_Date;
        sepaRec.Document_Type__c = Document_Type;
        sepaRec.Activation_Date__c = Activation_Date;
        sepaRec.Debtor_Account__c = opId;
        sepaRec.Debtor_Name__c = opName.left(70);
        sepaRec.IBAN__c = opIBAN;
        sepaRec.Invoice_Number__c = opInvoiceNumber;
        sepaRec.Mandate_Date__c = opMandateDate;
        sepaRec.Mandate_Identification__c = opMandateIdentification.left(35);
        sepaRec.Request_Count__c = 1;
        sepaRec.Request_Amount__c = opRequestAmount;
        sepaRec.Request_Currency__c = opRequestCurrency;
        sepaRec.Payment_Date__c = paymentDate;
        //Request_DateTime__c eh adicionado quando se cria XML
        //sepaRec.Request_DateTime__c = opRequestDateTime;
        sepaRec.Swift_Bic__c = opSwiftBic;
        
        //TODO ?to be removed after Payment Collection is implemented?
        if(ffObject instanceof c2g__codaInvoice__c){
            sepaRec.Sales_Invoice__c = ((c2g__codaInvoice__c)ffObject).Id;
        }
        if(ffObject instanceof c2g__codaPurchaseInvoice__c){
            sepaRec.Payable_Invoice__c = ((c2g__codaPurchaseInvoice__c)ffObject).Id;
        }
        if(ffObject instanceof c2g__codaCreditNote__c){
            sepaRec.Sales_Credit_Note__c = ((c2g__codaCreditNote__c)ffObject).Id;
        }
        
        outputSepaRec(sepaRec);
        
        return sepaRec;
    }
*/    
    //TODO check where is used
    public static CR_Sepa_File__c getSepaFile(Date dueDate, String Movement_Type, Boolean resetRequestDateTime, Datetime startDatetime) {
        system.debug(LoggingLevel.INFO, 'GetSepaFile for ' + dueDate + ' Movement_Type ' + Movement_Type);
        
        CR_Sepa_File__c sepaFile = null;
        
        try {
            sepaFile = [
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
                WHERE SEPA_Collection_Date__c = :dueDate
                AND SEPA_Movement_Type__c = :Movement_Type
                AND Creation_DateTime__c = :startDatetime
                AND Return_DateTime__c = null
            ];
            
            outputSepaFile(sepaFile);
            
            if(resetRequestDateTime){
                system.debug(LoggingLevel.INFO, 'resetRequestDateTime: ' + resetRequestDateTime + ', Resetting Request_DateTime__c.');
                sepaFile.Request_DateTime__c = null;
                update sepaFile;
            }
            
        } Catch (Exception e) {
            List<CR_Sepa_Admin__c> sepaAdmins = [
                Select Id, Name
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
                WHERE SEPA_Movement_Type__c = :Movement_Type
            ];
            
            if (sepaAdmins.size() == 0) {
                system.debug('Error');
                return null;
            }
            
            CR_Sepa_Admin__c sepaAdmin = sepaAdmins[0];
            
            sepaFile = new CR_Sepa_File__c();
            sepaFile.SEPA_Category_Purpose__c = sepaAdmin.SEPA_Category_Purpose__c;
            sepaFile.SEPA_Collection_Date__c = dueDate;
            sepaFile.SEPA_Initiating_Party_Name__c = sepaAdmin.SEPA_Initiating_Party_Name__c;
            sepaFile.SEPA_Movement_Type__c = Movement_Type;
            sepaFile.SEPA_Our_Bank_SWIFT_BIC__c = sepaAdmin.SEPA_Our_Bank_SWIFT_BIC__c;
            sepaFile.SEPA_Our_Bank_IBAN__c = sepaAdmin.SEPA_Our_Bank_IBAN__c;
            sepaFile.SEPA_Our_Bank_Private_Identification__c = sepaAdmin.SEPA_Our_Bank_Private_Identification__c;
            sepaFile.SEPA_Payment_Method__c = sepaAdmin.SEPA_Payment_Method__c;
            sepaFile.SEPA_Service_Type__c = sepaAdmin.SEPA_Service_Type__c;
            sepaFile.SEPA_Tag_xmlns__c = sepaAdmin.SEPA_Tag_xmlns__c;
            sepaFile.SEPA_Tag_xmlns_xsi__c = sepaAdmin.SEPA_Tag_xmlns_xsi__c;
            sepaFile.Creation_DateTime__c  = startDatetime;
            
            outputSepaFile(sepaFile);
            
            insert sepaFile;
        }
        
        system.debug(LoggingLevel.INFO, 'sepaFile.Id: ' + sepaFile.Id + 'sepaFile.Name: ' + sepaFile.Name);
        
        //TODO: get account managers
        string address = 'fapostolo@candor.pt';
        string content = 'content';
        string subject = 'subject';
        //Utilities.SendEmail(address, content, subject);
        
        return sepaFile;
    }
    
    /* // Only Used for test   
    public static void processActivationDateTest(){
    	

    	ID sepaId = 'a6q9E0000004DcB';
    	
    	CR_Sepa_Record__c sr = [
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
            , Sales_Invoice__c
            , Payable_Invoice__c
            , Swift_Bic__c
            FROM CR_Sepa_Record__c
            WHERE Id = :sepaId
            ];
               
        system.debug('sr' + sr);
             
        CR_Sepa_Admin__c sepaAdmin = [
                  Select Id
                  , Name
                  , Activation_Date__c
                  , SEPA_Category_Purpose__c
                  , SEPA_Initiating_Party_Name__c
                  , SEPA_Our_Bank_SWIFT_BIC__c
                  , SEPA_Our_Bank_IBAN__c
                  , SEPA_Our_Bank_Private_Identification__c
                  , SEPA_Movement_Type__c
                  , SEPA_Payment_Method__c
                  , SEPA_Service_Type__c
                  , SEPA_Tag_xmlns__c
                  , SEPA_Tag_xmlns_xsi__c
                  , Preferred_Weekday__c
                  FROM CR_Sepa_Admin__c
                  WHERE SEPA_Movement_Type__c = :sr.Document_Type__c
              ];
              
        system.debug('sepaAdmin' + sepaAdmin);
    	date activationDate = processActivationDate(sepaAdmin, sr.Document_Due_Date__c);
    	
    	sr.Activation_Date__c = activationDate;
    	update sr;
    }
*/    
  
    public static date processExecutionDate(CR_Sepa_Admin__c sa, date activationDate){
    	Integer workingDaysForDD = Integer.valueOf(CR_CS_SEPA_Config__c.getValues('BankSubmitWorkingDaysBefore_SI_DueDate').Value_Number__c);
     	date executionDate = activationDate;
     	if(sa.SEPA_Payment_Method__c == 'DD'){
        	executionDate = addBusinesshour(activationDate, workingDaysForDD);
        }
        
        return executionDate;
    }
    
    public static date processActivationDate(CR_Sepa_Admin__c sa, Date dueDate){
    	
    	    Id BusinessHoursId = CR_CS_SEPA_Config__c.getValues('SEPA_SI_BusinessHoursID').Value_String__c;
            Integer workingDaysForDD = Integer.valueOf(CR_CS_SEPA_Config__c.getValues('BankSubmitWorkingDaysBefore_SI_DueDate').Value_Number__c);
            Date activationDate = dueDate;

            system.debug('activationDate' + activationDate);
        	system.debug(LoggingLevel.INFO, 'SEPA_UTILS processActivationDate document_Due_Date__c: ' + dueDate);
      	
        	if(sa.Preferred_Weekday__c == 'DocumentDueDate'){
        		
        		activationDate = dueDate;

        		activationDate = addBusinesshour(activationDate, Integer.valueOf(sa.Activation_Date__c));
   
        	} else if (sa.Preferred_Weekday__c == 'SameDay'){
        		
        		activationDate = date.Today();
        		
        		//Preferred_Weekday__c = weekek days Monday to Sunday
        	}else {
                //Remove working days as especified in SEPA Admin
        		activationDate = addBusinesshour(dueDate, Integer.valueOf(sa.Activation_Date__c));
        		
                Integer preferredWeekday = Integer.valueOf(sa.Preferred_Weekday__c);
        		activationDate = previousPreferredWeekDay( preferredWeekday, activationDate );
        	}

        	if(activationDate < Date.today()){
	    	    activationDate = Date.today();
	        }

        	system.debug('activationDate' + activationDate);
        	for(Integer i = 0 ; !BusinessHours.isWithin(BusinessHoursId, activationDate) && i<9 ; i++){
				activationDate = activationDate.addDays(1);
			}

        	system.debug(LoggingLevel.INFO, 'SEPA_UTILS processActivationDate activationDate: ' + activationDate);
        
        return activationDate;
    }
    
    private static date previousPreferredWeekDay(Integer  preferredWeekday, date activationDate){

	    Integer dateWeekday = SEPA_UTILS.getWeekDay(activationDate);

	    if( dateWeekday > preferredWeekday ){
	    	activationDate = activationDate.addDays(preferredWeekday - dateWeekday);
	    }else{
	    	activationDate = activationDate.addDays(preferredWeekday - dateWeekday - 7);
	    }

    	return activationDate;
    }
/*    
    private static date addBusinesshour(date baseDate, Integer daysToAdd){
    	Id BusinessHoursId = CR_CS_SEPA_Config__c.getValues('SEPA_SI_BusinessHoursID').Value_String__c;
        Long daysToAddMillisecond = 1000*60*60*24 * Integer.valueOf(daysToAdd);
        Datetime  dT = BusinessHours.add(BusinessHoursId, baseDate, daysToAddMillisecond);
        date recalculatedBusiHour = date.newinstance(dT.year(), dT.month(), dT.day());
        
        return recalculatedBusiHour;
    } 
*/
    // This method was made that way because BusinessHours.add was not working properly 
    public static Date addBusinesshour(Date baseDate, Integer daysToAdd){
    	system.debug('addBusinesshour baseDate: ' + baseDate);
    	if(daysToAdd == 0){
    		return baseDate;
    	}
    	
        Id BusinessHoursId = CR_CS_SEPA_Config__c.getValues('SEPA_SI_BusinessHoursID').Value_String__c;
        Datetime baseDateTime = Datetime.newInstance(baseDate.year(), baseDate.month(),baseDate.day(), 6,0,0);

        Integer auxDaysToAdd = daysToAdd;
        Integer signal = (daysToAdd / math.abs(daysToAdd)) ;  //the signal, -1 if are days to remove +1 if are days to add

        while(auxDaysToAdd != 0){
        	        	
        	baseDateTime = baseDateTime.addDays(signal);
        	Boolean isWithinaux = BusinessHours.isWithin(BusinessHoursId, baseDateTime);

        	if(isWithinaux){
                auxDaysToAdd = auxDaysToAdd + ( -1 * signal);
        	}

        }

        Date returnDate = Date.newInstance(baseDateTime.year(), baseDateTime.month(),baseDateTime.day() );
        
        system.debug('addBusinesshour returnDate: ' + returnDate);
        return returnDate;
    }
    
    public static void updatePCFromSepaStatus( List<CR_Sepa_Record__c> sepaInactiveStatusChangedList){
    	system.debug('sepaInactiveStatusChangedList' + sepaInactiveStatusChangedList);
    	
    	List<Id> paymentCollectionIdList = new List<Id>();
    	for(CR_Sepa_Record__c sepa : sepaInactiveStatusChangedList){
    		paymentCollectionIdList.add(sepa.Payment_Collection__c);
    	}
    	
    	Map<Id, Payment_Collection__c> paymentCollectionMap = new Map<Id, Payment_Collection__c>([SELECT Id, Status__c FROM Payment_Collection__c WHERE Id IN :paymentCollectionIdList ]);
    	for(CR_Sepa_Record__c sepa : sepaInactiveStatusChangedList){
    		if(sepa.Payment_Collection__c != null){
	    		if(sepa.Invalid_Record__c == true ){
	    			paymentCollectionMap.get(sepa.Payment_Collection__c).Status__c = 'Canceled';
	    		}else if(sepa.Invalid_Record__c == false && sepa.Return_Status_Code__c == null){
	    			paymentCollectionMap.get(sepa.Payment_Collection__c).Status__c = 'In Payment';
	    		}else if(sepa.Invalid_Record__c == false && sepa.Return_Status_Code__c == '0000'){
	    			paymentCollectionMap.get(sepa.Payment_Collection__c).Status__c = 'Paid';
	    		}else{
	    			paymentCollectionMap.get(sepa.Payment_Collection__c).Status__c = 'Error';
	    		}
    		}
    	}
    	
    	update paymentCollectionMap.values();
    }
    
}