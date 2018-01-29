public with sharing class BO_CustomController {
   
    public List<Application__c> getApps(){
        List<Application__c> apps=new List<Application__c>();
         apps = [SELECT Name, CreatedDate FROM Application__c where AccCLient__c= :ApexPages.currentPage().getParameters().get('id') order by createdDate desc];
        return apps;
    }

    @RemoteAction
    public static string ReAnalyseCreditInfo( string clientId, string appnum){
        string msg='';
        appnum=appnum.trim();
         string appId='';
        List<Application__c> app= new List<Application__c>([select id from application__c where name = :appnum and AccClient__c= :clientId]);
      
        if(app.size()!= 0){
            appId=app[0].id;
        }
        else{
            msg='Application Number does not exist for this Client!';            return msg;
        }
        
       
        // validates if report info is all filled in
        ReportDB__C report = [select CAE__c, DataConstituicao__c, FormaObrigarToNr__c, ResultLiqUltimoAno__c, Sales__c, Activitycode__c, recordtype.Name , PercentilScore__c, 
                                        grossincome__c, codigoPostal__c, RiscoInforma__c, IndicadorRisco__c, AttachB__c, AttachC__c , Estado__c, TotIncidentes__c, Ano_Ultimo_Balanco__c,
                                        yearincome__c, FormaJuridica__c, FormaObrigar__c From reportDB__c where vendor__c=: clientId ];
        if(report.RecordType.Name!='ENI'){
            if( report.DataConstituicao__c==null ){                 msg='Date Of Establishment is not filled in! \n'; 
            }
            if(report.Sales__c== 0 || report.Sales__c==null){                 msg=msg+ 'Sales value is not filled in! \n';
            }
            if(report.Ano_Ultimo_Balanco__c== 0 || report.Ano_Ultimo_Balanco__c==null){                 msg=msg+ 'Year of Financial Statement is not filled in! \n';
            }
            
        }
        else{ 
            if(report.grossincome__c== 0 || report.grossincome__c==null){                 msg=msg+ 'Sales value is not filled in! \n';
            }
            
             if(report.yearincome__c== 0 || report.yearincome__c==null){                 msg=msg+ 'Year of Financial Statement is not filled in! \n';
            }   
        }
        
        
        if(report.FormaObrigarToNr__c== 0 || report.FormaObrigarToNr__c==null){             msg=msg+ 'Binding Power is not filled in! \n';
        }
       
     
        // Analyse credit
        if(msg==''){
            msg=ScoreCardConfig.GetCreditLineStatus(clientId, appId);
            return 'Credit Info Analysed successfully: ' + msg;
        } 
        else{
            return 'The following information is missing in Credit Info: \n' + msg;
        }
        
        
    }
}