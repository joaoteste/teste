@isTest(SeeAllData=true)
public class SC_UTIL_Test {

/*
    public static void createConfigurationData() {
        
        Scorecard__c scoreCard = new Scorecard__c();
        insert scoreCard;
        
        Scorecard_Line_Item__c scoreCardLineItem1 = new Scorecard_Line_Item__c(Field_API_Name__c='PercentilScore__c'
                                                                                         ,Field_Name__c= 'Failure Score'
                                                                                         ,Matching_Type__c= '<='
                                                                                         ,Matching_Value__c= 5
                                                                                    //     ,Max_Value__c= ''
                                                                                    //     ,Min_Value__c= ''
                                                                                         ,Query_Filter__c= 'Vendor__c = :accountId ORDER BY CreatedDate DESC LIMIT 1'
                                                                                         ,Related_Object__c= 'Credit Report'
                                                                                         ,Related_Object_API_Name__c= 'ReportDB__c'
                                                                                         ,Scorecard__c= scoreCard.Id
                                                                                         ,Value__c= 10);
        
        insert scoreCardLineItem1;
        
        Score_Card_Field_Weight__c scoreCardFieldWeight = new Score_Card_Field_Weight__c(Field_API_Name__c='PercentilScore__c'
                                                                                         ,Field_Name__c= 'Failure Score'
                                                                                         ,Related_Object__c= 'Credit Report'
                                                                                         ,Related_Object_API_Name__c= 'ReportDB__c'
                                                                                         ,Scorecard__c= scoreCard.Id
                                                                                         ,Weight__c = 1 );
          
        Grade_Card__c gradeCard = new Grade_Card__c();
        insert gradeCard;
       
        Grade_Card_Line_Item__c gradeCardLineItem = new Grade_Card_Line_Item__c(Decison_Status__c= 'Approved'
                                                                                ,Grade__c= 'A'
                                                                                ,Gradecard__c= gradeCard.Id
                                                                                ,Max_Value__c= 100
                                                                                ,Min_Value__c= 90
                                                                         //       ,Sub_Grade__c = '1'
                                                                                 );
        insert gradeCardLineItem;
    }
*/
/*    
    public static Account createAccountWithReportInfo() {
//      Account accountclient = RentingApplication_Util_Test.createAccount('Joao','Customer - Channel','123456777');
        Account accountclient = createAccount('Joao','Customer - Channel','123456777');
        
        ReportDB__c report1 = new ReportDB__c(Vendor__c = accountclient.id, Name = '500659931', n_dependents__c = 3, CAE__c = '16101'
                                            ,Estado_Civil__c = 'Outro', yearincome__c = 2002, EnderecoPostal__c = 'FEBRES', Localidade__c = 'xxxxx', CodigoPostal__c = '3060-318'
                                            ,AttachB__c = true, PercentilScore__c = 4, RecordTypeId = '012240000006iFx' );
        insert report1;
        
        return accountclient;
    }
*/    
    // Inactive Companies
    //TODO
    public static Account createAccountInactiveCompanies() {

        Account accountclient = createAccount('Joao','Customer - Channel','123456777');
        
        ReportDB__c report1 = new ReportDB__c(Estado__c = 'Liquidação' , Vendor__c = accountclient.id, Name = '500659931', n_dependents__c = 3, CAE__c = '16101'
                                            ,Estado_Civil__c = 'Outro', yearincome__c = 2002, EnderecoPostal__c = 'FEBRES', Localidade__c = 'xxxxx', CodigoPostal__c = '3060-318'
                                            ,AttachB__c = true, PercentilScore__c = 4, RecordTypeId = '012240000006iFx' );
        insert report1;
        
        return accountclient;
    }
    
    // Societies and Corporations >= Cut-Off
    public static Account createAccountSocietiesAndCorporationsMCutOff() {
        Account accountclient = createAccount('Joao','Customer - Channel','123456777');

        Date dataConstituicao = Date.newInstance(1960, 2, 17);
        ReportDB__c report1 = new ReportDB__c(Estado__c = 'Ativa', FormaJuridica__c = 'SA', DataConstituicao__c = dataConstituicao , Vendor__c = accountclient.id, Name = '500659931', n_dependents__c = 3, CAE__c = '16101'
                                            ,Estado_Civil__c = 'Outro', Sales__c = 1000000, yearincome__c = 2002, EnderecoPostal__c = 'FEBRES', Localidade__c = 'xxxxx', CodigoPostal__c = '3060-318'
                                            ,AttachB__c = true, PercentilScore__c = 70, RecordTypeId = '012240000006iFx' );
        insert report1;
        
        return accountclient;
    }   
    
    static public Account createAccount(String clientName, String accountType, String nif){
        Account account = new Account();
        account.Name = clientName; 
        account.Type = accountType;
        account.BillingCity = 'Lx';
        account.BillingPostalCode = '1000-423';
        account.NIF__c = nif;
        
        if (UTIL_PostCode.getRegionFromPostCode(account.BillingPostalCode) == null){
            RentingApplication_Util_Test.createRegion();
        }
        
        account.BillingStreet = 'BillingStreet';
        account.Website = 'webSite';
        account.Phone = '00351964639755';
        account.Fax = '00351964639755';
        account.FormaObrigar_Val__c = 1;
        account.Credit_Line_Status__c = 'Credit Line - Approved';
        account.c2g__CODAAccountTradingCurrency__c = 'EUR';
        account.c2g__CODAInvoiceEmail__c = 'emailTest@test.com';
        account.c2g__CODATaxCalculationMethod__c = 'Gross';

        account.c2g__CODABankIBANNumber__c = 'PT50004563904014640899590';
    //    c2g__codaTaxCode__c taxCode = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'VCONT23'];
    //    account.c2g__CODAInputVATCode__c = taxCode.id; //'a3e24000000HWMt';        
        
        insert account;
        return account;
    }

    static public Account createAccountWithCreditReport(String clientName, String accountType, String nif){
        
        Account acc = SC_UTIL_Test.createAccount(clientName, accountType,nif);
        Date dataConstituicao = Date.newInstance(1960, 2, 17);
        ReportDB__c report = new ReportDB__c(Estado__c = 'Ativa', FormaJuridica__c = 'SA', DataConstituicao__c = dataConstituicao , Vendor__c =acc.id, Name = acc.Name, n_dependents__c = 3, CAE__c = '16101'
                                            ,Estado_Civil__c = 'Outro', Sales__c = 1000000, yearincome__c = 2002, EnderecoPostal__c = 'FEBRES', Localidade__c = 'xxxxx', CodigoPostal__c = '3060-318'
                                            ,AttachB__c = true, PercentilScore__c = 70, RecordTypeId = '012240000006iFx' );
        insert report;

        return acc;

    }
}