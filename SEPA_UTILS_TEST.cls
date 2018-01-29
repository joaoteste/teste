@isTest (SeeAllData=true)
public class SEPA_UTILS_TEST {

    @isTest (SeeAllData=true)
    public static void testNullSepaCharacterCompliance() {
        try{
            SEPA_UTILS.SepaCharacterCompliance(null);
        } catch (exception e){
            system.debug(LoggingLevel.INFO, 'testNullSepaCharacterCompliance: ' + e.getStackTraceString());
        }
    }
   
    @isTest (SeeAllData=true)
    public static void test_getBicFromIbanMap() {
        SEPA_UTILS.getBicFromIbanMap();
    }
    
    @isTest (SeeAllData=true)
    public static void test_getWeekDay() {
        Date data = Date.newInstance(1977, 11, 3);
        SEPA_UTILS.getWeekDay(data);
    }
    
    @isTest (SeeAllData=true)
    public static void test_GetSepaFile() {
        Date data = Date.newInstance(2017, 1, 2);
        SEPA_UTILS.GetSepaFile(data, 'RCUR', true, Datetime.now());
    }
    
    public static void createCustomSettingSEPAValues(){
//TODO other values
    	CR_Sepa_Admin__c sepaAdmin = new CR_Sepa_Admin__c(
                 Name =  'Collections - Direct Debit'
                , Activation_Date__c = -2
                , SEPA_Movement_Type__c = 'RCUR'
                , SEPA_Category_Purpose__c = 'OTHR'
                , SEPA_Initiating_Party_Name__c = 'CANDOR RENTING DE EQUIPAMENTOS SA'
                , SEPA_Our_Bank_SWIFT_BIC__c = 'BBPIPTPL'
                , SEPA_Our_Bank_IBAN__c = 'PT50001000005300067000263'
                , SEPA_Our_Bank_Private_Identification__c = 'PT09ZZZ111901'
                , SEPA_Payment_Method__c = 'DD'
                , SEPA_Service_Type__c = 'CORE'
                , SEPA_Tag_xmlns__c = 'urn:iso:std:iso:20022:tech:xsd:pain.008.001.02'
                , SEPA_Tag_xmlns_xsi__c = 'http://www.w3.org/2001/XMLSchema-instance'
                , Preferred_Weekday__c = 'DocumentDueDate'
                );

         insert sepaAdmin;
         
         List<CR_CS_SEPA_Config__c> sepaConfigList = new List<CR_CS_SEPA_Config__c>();
         CR_CS_SEPA_Config__c sepaConfig = new CR_CS_SEPA_Config__c(
         Name = 'SEPA_SI_BusinessHoursID',
         Value_String__c = '01m240000008Q95');
         
         sepaConfigList.add(sepaConfig);
         
         sepaConfig = new CR_CS_SEPA_Config__c(
         Name = 'BankSubmitWorkingDaysBefore_SI_DueDate',
         Value_Number__c = 2);
         
         sepaConfigList.add(sepaConfig);
         
         insert sepaConfigList;
         
    }
}