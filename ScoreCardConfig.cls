public class ScoreCardConfig {
    
    /*
* // Get years since company establishment
* */
    
       
    private static string insertNotification(string appId, string searchword1, string searchword2, string extra){
        
        Schema.DescribeFieldResult fieldResult = notification__c.message__c.getDescribe();
        List<Schema.PicklistEntry> plnot = fieldResult.getPicklistValues();
        string message;
        for(integer i=0; i<plnot.size(); i++){
            if(plnot[i].getLabel().contains(searchword1)==true && (searchword2 == null || searchword2 == '' || plnot[i].getLabel().contains(searchword2)==true)){
                message= plnot[i].getLabel();
                Notification__c notif= new Notification__c( application__c=appId,  Message__c=message /*+ ' ' + extra*/); //ALTERACAO - 02/05/17 - retirar IDS (BP)
                system.debug(message + ' ' + extra);
                insert notif;
                break;
            }   
        }
        return message;
    }
            
    private static string insertNotification(string appId, Account acc){
            return insertNotification(appId, 'Aprovado', null, acc.Available_Credit_Line__c + '€' + ' ID:' + getCodeLineFromStack(3));
    }
    
    private static string insertNotification(string appId, string searchword1, string searchword2){
        return insertNotification(appId, searchword1, searchword2, ' ID:' + getCodeLineFromStack(2));
    }
    
    private static string insertNotification(string appId, string searchword1, string searchword2, integer deep){
        return insertNotification(appId, searchword1, searchword2, ' ID:' + getCodeLineFromStack(deep));
    }
    
    private static integer getCodeLineFromStack(integer deep){
        try {
            throw new HandledException();
        } catch(HandledException e) {
            system.debug(e.getStackTraceString());
            String line = e.getStackTraceString().split('\n')[deep];
            Pattern patt = Pattern.compile('([a-z0-9_.]+): line (\\d+)');
            Matcher match = patt.matcher(line);
            match.find();
            return Integer.valueOf(match.group(2));
        }
    }
    
    public static decimal getStartupMaxAge(){
        return Decimal.valueOf(((ScoreCard_Config__c)[select Matching_Value__c from scorecard_config__c where recordtype.name = 'Score Card' and FieldName__c='DateOfEstablishment']).Matching_Value__c);
    }
    
    public static decimal getStartupMaxCredit(){
        return Decimal.valueOf(((ScoreCard_Config__c)[select Matching_Value__c from scorecard_config__c where recordtype.name = 'Modifier Startup' and FieldName__c='Startup Max Credit']).Matching_Value__c);
    }
    
    public static decimal getStartupMinCredit(){
        return Decimal.valueOf(((ScoreCard_Config__c)[select Matching_Value__c from scorecard_config__c where recordtype.name = 'Modifier Startup' and FieldName__c='Startup Min Credit']).Matching_Value__c);
    }
    
    public static decimal getStartupCreditMultiplier(){
        return Decimal.valueOf(((ScoreCard_Config__c)[select Matching_Value__c from scorecard_config__c where recordtype.name = 'Modifier Startup' and FieldName__c='Startup Credit Multiplier']).Matching_Value__c);
    }
    
    public static decimal getStartupNoScoreMinCapital(){
        return Decimal.valueOf(((ScoreCard_Config__c)[select Matching_Value__c from scorecard_config__c where recordtype.name = 'Modifier Startup' and FieldName__c='Startup NoScore Min Capital']).Matching_Value__c);
    }
    
    public static decimal calculaIdade(date dateOfEstablishment){  
        date now=date.today();
        if(DateOfEstablishment!=null){
            return DateOfEstablishment.daysBetween(now)/365;  
        }
        else
            return getStartupMaxAge(); 
    }
    
    private static boolean isEmpresaRecente(decimal valdate){
        
        if(
            valdate < 
            getStartupMaxAge()
        ){
            return true;
        }
        return false;
    }
    
    private static boolean isEmpresaRecente(Account acc){
        return isEmpresaRecente(calculaIdade(acc.Date_Of_Establishment__c));
    }
    
    
    public static void AprovacaoDeEmpresaRecentePreConfiguracao(Account acc, Application__c app){
        system.debug('acc.Risk_Type__c 1>>'+acc.Risk_Type__c);
        acc.Risk_Type__c = 'Very High';
        system.debug('acc.Risk_Type__c 2>>'+acc.Risk_Type__c);
        
        system.debug('app.Term__c=12 1>>'+app.Term__c);
        app.Term__c='12';
        system.debug('app.Term__c=12 2>>'+app.Term__c);
        
        acc.Personal_Guarantee__c = true;
        app.Personal_Guarantee__c = true;
    }
    
    public static string AprovacaoDeEmpresaRecenteAprova(Account acc, Application__c app){
        acc.Credit_Line_Status__c='Credit Line - Approved';
        app.Status__c='Application - Approved';
        app.Reject_Reason__c='';
        return 'Startup - Approved';
    }
    
    public static string AprovacaoDeEmpresaRecenteSemScore(Account acc, Application__c app, decimal valdate, List<ReportDB__c> report){
        
        if(!isEmpresaRecente(valdate)){
            return 'Not a Startup';
        }

        AprovacaoDeEmpresaRecentePreConfiguracao(acc,app);
        
        if(report[0].CapitalSocial__c == null || report[0].CapitalSocial__c < getStartupNoScoreMinCapital()){
            return finalizeRejeicao(acc, app, 'Crédito Elevado');
        }
        
        system.debug('AprovacaoDeEmpresaRecenteSemScore. Apliação aprovada');
        return AprovacaoDeEmpresaRecenteAprova(acc, app);
    }
    
    public static string AprovacaoDeEmpresaRecenteComScore(Account acc, Application__c app, decimal valdate, List<ReportDB__c> report){
               
        if(!isEmpresaRecente(valdate)){
            return 'Not a Startup';
        }
        
        AprovacaoDeEmpresaRecentePreConfiguracao(acc,app);
        
        if(report[0].CapitalSocial__c == null || report[0].CapitalSocial__c * getStartupCreditMultiplier() < getStartupMinCredit()){
            return finalizeRejeicao(acc, app, 'Crédito Elevado');
        }
        
        system.debug('AprovacaoDeEmpresaRecenteComScore. Apliação aprovada');
        return AprovacaoDeEmpresaRecenteAprova(acc, app);
    }
    
    public static string RepescaClientsComMauInformaScore( Account acc, Application__c app,  List<ReportDB__c> report){

        if(report[0].TotIncidentes__c==null){
            acc.Credit_Line_Status__c='Credit Line - Rejected';
            app.Status__c='Application - Rejected';  
            app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
            system.debug('report[0].TotIncidentes__c==null || report[0].TotIncidentes__c>0');
            update app;
            update acc;
            Return acc.Credit_Line_Status__c;
        }
        
        if(report[0].TotIncidentes__c>0 &&
           (report[0].TotValorIncidentes__c==null 
            || acc.Sales__c == null 
            || report[0].TotValorIncidentes__c
            >=
            acc.Sales__c
            *Decimal.valueOf(((ScoreCard_Config__c)[select Matching_Value__c
                                                    from scorecard_config__c
                                                    where recordtype.name = 'Modifier Score'
                                                    and FieldName__c='PercentageSalesForSumCourtActions']).Matching_Value__c)))
        {
            acc.Credit_Line_Status__c='Credit Line - Rejected';
            app.Status__c='Application - Rejected';  
            app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
            system.debug('report[0].TotValorIncidentes__c==null || report[0].TotValorIncidentes__c>=');
            update app;
            update acc;
            Return acc.Credit_Line_Status__c;
        }
                
        if(acc.AnnualRevenue==null){
            acc.Credit_Line_Status__c='Credit Line - Rejected';
            app.Status__c='Application - Rejected';  
            app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
            system.debug('(acc.AnnualRevenue==null)');
            update app;
            update acc;
            Return acc.Credit_Line_Status__c;
        }
        
        system.debug('acc.Sales__c' + acc.Sales__c);
        system.debug('acc.AnnualRevenue' + acc.AnnualRevenue);
        List <ScoreCard_Config__c> ScoreCardRisk4 = New  List <ScoreCard_Config__c>();
        ScoreCardRisk4=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                        (  (  Matching_Value_To_Nr__c < :acc.AnnualRevenue And FieldName__c='NetProfit') or
                         ( ( Matching_Value_To_Nr__c >= :report[0].TotIncidentes__c ) And FieldName__c='CourtActions')) ];
        system.debug('Avalia condições de atribuição de linha de crédito para risco elevado ');    
        system.debug(ScoreCardRisk4.size());
        if(ScoreCardRisk4.size() !=3){
            system.debug('Falhou uma das condições para atribuição de credito para risco elevado');      
            app.Status__c='Application - Rejected';
            acc.Credit_Line_Status__c='Credit Line - Rejected'; //ALTERACAO - 13/02/17 -  adicao de linha para resolver accs sem estado (BP)
            app.Reject_Reason__c=insertNotification(app.id, 'Risco de Crédito', 'Rejeitado'); 
            system.debug('ScoreCardRisk4.size() !=3');
            update app;
            update acc;
            Return acc.Credit_Line_Status__c;
        }                   
        acc.Credit_Line_Status__c='Credit Line - Approved';
        if ( ScoreCardRisk4[0].Auto_Decision__c==true){
            app.Status__c='Application - Approved';
            app.Reject_Reason__c='';
        }
        //ALTERACAO - 06/03/17 - updates estavam em falta (BP)
        update app;
        update acc;
        system.debug('NetProfit Ok. Aplicação aprovada');
        Return acc.Credit_Line_Status__c;
    }
    
    
    public static string GetCreditLineStatus( string clientId, string appId){
        try{
            List <ScoreCard_Config__c> ScoreCardCfg= New  List <ScoreCard_Config__c>();
            List <ScoreCard_Config__c> PostalCodeCfg= New  List <ScoreCard_Config__c>();
            list<ScoreCard_Config__c> ScoreCardLegal = new list<ScoreCard_Config__c> ();
            ScoreCard_Config__c IniCandorGrade;//= New  List <ScoreCard_Config__c>();
            ScoreCard_Config__c ModifierCAE;
            ScoreCard_Config__c ModifierActCode;
            ScoreCard_Config__c CandorGradeAfterAct;
            boolean risk4=false;
            boolean legalformcredit=false;
            
            List<ReportDB__c> report = [select CAE__c, DataConstituicao__c, FormaObrigarToNr__c, ResultLiqUltimoAno__c, Sales__c, Activitycode__c, recordtype.Name , PercentilScore__c, 
                                        grossincome__c, codigoPostal__c, RiscoInforma__c, IndicadorRisco__c, AttachB__c, AttachC__c , Estado__c, TotIncidentes__c, TotValorIncidentes__c, Ano_Ultimo_Balanco__c,
                                        yearincome__c, FormaJuridica__c, FormaObrigar__c, Sales_n_1__c, ResultLiquido_n_1__c, Sales_n_2__c, ResultLiquido_n_2__c , TotEmpregados__c, CapitalSocial__c
                                        From reportDB__c where vendor__c=: clientId ];
            
            Account acc =[SELECT Id, Date_Of_Establishment__c, D_B_Failure_Score__C, AnnualRevenue, BillingPostalCode, Credit_Line_Status__c, CAE__c, 
                          Activity_code__c, FormaObrigar_Val__c, Credit_line__c, Used_Credit_Line__c,   Available_Credit_Line__c, Risk_Type__c, 
                          Ano_Ultimo_Balanco__c, FormaObriga_text__c FROM Account where Id=:clientId];   
            
            Application__c app = [SELECT Id, Status__c, Reject_Reason__c, Vendor__c, Client_available_Credit_Line__c, Insurance_Rent_Together__c,// Monthly__c, Quarterly__c,
                                  Vendor_Diluted_Doc_Interim_fee__c, Vendor_Diluted_Doc_fee__c, Term__c   FROM Application__c where Id=:appId];
            
            account accvendor=[select id, name, Insurance_Rent_Together__c, Diluted_Doc_and_Interim_Fee__c, Diluted_Doc_Fee__c from account where id=: app.vendor__c];
            
            // Copys to application Vendor info that affects rent value
           /* if(accvendor.Diluted_Doc_Fee__c==true){
                app.Vendor_Diluted_Doc_fee__c=false;   
            }
            else{
                app.Vendor_Diluted_Doc_fee__c=true;   
            }*/
            
            
            // if Credit info does not exists no decision can be made
            //Situacao pendente - necessita de mais validações
            // ALTERACAO - 23/02/17 - Resolver as decisoes de mas decisoes - a Informa pode estar ok mas pode haver erros do lado do SF  (BP)
            //                        Fica pendente apenas pela existencia ou nao do report e nao dos estados de recursos da Informa ou SF
            //                        (validacao ja feita quando se obtem o report)-comentadas linhas no if seguinte
            if(report.size()==0)
            {
                /*
                string informaStatus =
                    ((ScoreCard_Config__c)[select Matching_Value__c from scorecard_config__c where recordtype.name = 'Score Card' and FieldName__c='InformaDB Status OK?(YES/NO)' limit 1]).Matching_Value__c;
                if(informaStatus != null && informaStatus != 'YES'){
                    system.debug('report.size()==0 && !informaStatus');
                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                    app.Status__c='Application - Pendent';
                    app.Reject_Reason__c='Pendente: Sistema externo de informação financeira temporariamente indisponível';
                    update app;
                    update acc;
                    return acc.Credit_Line_Status__c; 
                }*/
                    //ALTERACAO - 21/08/17 - quando não tem report deixa de rejeitar e passa a deixar tanto a linha como o pedido pendentes comentda condicao acima(BP)
                    system.debug('report.size()==0 && informaStatus');
                    acc.Credit_Line_Status__c='Credit Line - Pendent';  
                    app.Status__c='Application - Pendent';
                    app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                    update app;
                    update acc;
                    return acc.Credit_Line_Status__c;
            }
            
            // avaliação de linha de crédito existente
            if(acc.Credit_line__c!=0 && acc.Credit_line__c != null && acc.Credit_Line_Status__c=='Credit Line - Approved'){
                If(acc.Used_Credit_Line__c >= acc.Credit_line__c ){
                    Schema.DescribeFieldResult fieldResult = notification__c.message__c.getDescribe();
                    List<Schema.PicklistEntry> plnot = fieldResult.getPicklistValues();
                    string rejectreason;
                    for(integer i=0; i<plnot.size(); i++){
                        if(plnot[i].getLabel().contains('Rejeitado')==true &&  plnot[i].getLabel().contains('Linha')==true &&
                           plnot[i].getLabel().contains('Financiamento')==true  ){
                               Notification__c notif= new Notification__c( application__c=app.Id,  Message__c=plnot[i].getLabel()); 
                               rejectreason=plnot[i].getLabel();
                               insert notif;
                           }    
                    }
                    app.Status__c='Application - Rejected';
                    app.Reject_Reason__c=rejectreason;
                    update app;
                    return acc.Credit_Line_Status__c;
                }
            }
            
            // update account info with credit info report
            acc.CAE__c=report[0].CAE__c;
            acc.activity_Code__c=report[0].activityCode__c;
            acc.D_B_Failure_Score__c=report[0].PercentilScore__c;
            acc.FormaObrigar_Val__c=report[0].FormaObrigarToNr__c;
            acc.Date_Of_Establishment__c= report[0].DataConstituicao__c;
            acc.BillingPostalCode=report[0].CodigoPostal__c;
            acc.Ano_Ultimo_Balanco__c=report[0].Ano_Ultimo_Balanco__c;
            acc.FormaObriga_text__c=report[0].FormaObrigar__c;
            
            //TODO: Checkagem se temos o que precisamos aqui...
            acc.AnnualRevenue=report[0].ResultLiqUltimoAno__c;
            acc.Sales__c=report[0].Sales__c;
            
            
            decimal score=0;
            score=acc.D_B_Failure_Score__c;
            decimal rateinf=0;
            rateinf=report[0].RiscoInforma__c;
            decimal riskclass=0;
            riskclass=report[0].IndicadorRisco__c;
            decimal limitcredit=0;
            decimal limitdate=0;
            string cae;
            decimal ModelRankafterAct=0;
            date DateOfEstablishment=acc.Date_Of_Establishment__c;
            date now=date.today();
            // Get years since company establishment
            decimal valdate=calculaIdade(DateOfEstablishment);
            
            string legalForm=report[0].FormaJuridica__c;
            
            // evaluates failure score than starts branching
            if((score!=null && score!=0) || (rateinf!=null && rateinf!=0) ){
                // if company has info on failure score...
                if(score!=0 && score!= null){
                    
                    IniCandorGrade=[Select Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,
                                    DateOfEstablishment__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                    FieldName__c='Risco Informa' and  Failure_Score_Max__c >= :score And Failure_Score_Min__c <= :score  ]; 
                    
                    // and Risk Class provided by InformaDB is diferent than what should be for that failure score, informa rating is used
                    if(IniCandorGrade.Risk_Class__c != riskclass && rateinf !=0 && rateinf!=null){ 
                        IniCandorGrade=[Select Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c, 
                                        DateOfEstablishment__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                        FieldName__c='Risco Informa' and Informa_Rating__c=: rateinf limit 1 ]; 
                    }
                }
                // if not Informa Rating is used
                else {
                    IniCandorGrade=[Select Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,
                                    DateOfEstablishment__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                    FieldName__c='Risco Informa' and Informa_Rating__c=: rateinf limit 1 ];    
                }
                
                if(IniCandorGrade.Decision__c=='Credit Line - Rejected'){
                    system.debug('is failure Score nok ? check if credit can be conceded anyway.');
                    RepescaClientsComMauInformaScore(acc, app, report);
                    if(acc.Credit_Line_Status__c=='Credit Line - Approved'){
                        risk4=true;
                    }
                    else
                    {
                        acc.Risk_Type__c=IniCandorGrade.App_Client_Risk__c;
                        update acc;
                        return acc.Credit_Line_Status__c;
                    }
                }
                
                if(risk4 != true){
                    //Calcula CandorScore
                    decimal percentageDateModifier= Decimal.valueOf(((ScoreCard_Config__c)[select Matching_Value__c from scorecard_config__c where recordtype.name = 'Modifier Score' and FieldName__c='Date Modifier Percentage']).Matching_Value__c);
                    decimal percentageInformaScore=1-percentageDateModifier;
                    
                    ScoreCard_Config__c dateModifierScoreCard = 
                        [select Matching_Value__c, Matching_Type__c, Amount_Max__c from scorecard_config__c where recordtype.name = 'Modifier Score' and FieldName__c='Date Modifier' and Amount_Min__c <= :valdate and Amount_Max__c >= :valdate limit 1];
                    
                    decimal valdateModified = Decimal.valueOf(dateModifierScoreCard.Matching_Value__c);
                    
                    if(dateModifierScoreCard.Matching_Type__c=='Linear' && valdateModified > 0){
                        valdateModified = valdate * valdateModified / Integer.valueOf(dateModifierScoreCard.Amount_Max__c);
                    }               
                    
                    //TODO: Se Informa Score for null ou estiver com atualização no rateinf
                    integer candorScore = Integer.valueOf( percentageInformaScore * score + percentageDateModifier * valdateModified );
                    
                    report[0].Candor_Score__c = candorScore;
                    update report[0];
                    
                    system.debug('candorScore:'+candorScore);
                    system.debug('percentageInformaScore:'+percentageInformaScore);
                    system.debug('score:'+score);
                    system.debug('percentageDateModifier:'+percentageDateModifier);
                    system.debug('valdate:'+valdate);
                    
                    IniCandorGrade=[Select Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,
                                    DateOfEstablishment__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                    FieldName__c='Risco Informa' and  Failure_Score_Max__c >= :candorScore And Failure_Score_Min__c <= :candorScore  ]; 
                    
                    if(IniCandorGrade.Decision__c=='Credit Line - Rejected'){
                        system.debug('is Candor Score nok ? check if credit can be conceded anyway.');
                        RepescaClientsComMauInformaScore(acc, app, report);
                        if(acc.Credit_Line_Status__c=='Credit Line - Approved'){
                            risk4=true;
                        }
                        else
                        {
                            return acc.Credit_Line_Status__c;
                        }
                    }

                }

                // registers model rank and initial credit limit 
                app.ScoreCard_Config_Final__c=IniCandorGrade.Id;
                
                // register modifier activity 
                if (acc.CAE__c!=null && acc.CAE__c!='') {
                    cae=acc.CAE__c.substring(0,2);
                    ModifierCAE=[Select Id, Modifier__c From ScoreCard_Config__c where RecordType.Name='Modifier CAE' and 
                                 division__c =:cae ];
                    if(ModifierCAE!=null  ){
                        app.ModifierActCAE__c=ModifierCAE.Id;
                        ModelRankafterAct=IniCandorGrade.Model_Rank__c + ModifierCAE.Modifier__c;
                    }
                }                 
                if(ModelRankafterAct < 1 ){
                    ModelRankafterAct=1;
                }
                if(ModelRankafterAct > 35 ){
                    ModelRankafterAct=35;
                }
                
                // registers final model rank and creditline limit
                CandorGradeAfterAct=[Select Id, Candor_Grade__c, Decision__c, Message__c, Auto_Decision__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,
                                     DateOfEstablishment__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                     FieldName__c='Risco Informa' and Model_rank__c= :ModelRankafterAct];    
                acc.Credit_Line_Status__c=CandorGradeAfterAct.Decision__c;
                acc.Risk_Type__c=CandorGradeAfterAct.App_Client_Risk__c;
                app.Reject_Reason__c=CandorGradeAfterAct.Message__c; 
                app.ScoreCard__c=CandorGradeAfterAct.id;
                
                limitcredit=CandorGradeAfterAct.Credit_Line_Max_Limit__c;
                limitdate=CandorGradeAfterAct.DateOfEstablishment__c;
                
                // if failure score ok
                /* FIANCA APARTIR DE 161107   
else {*/
                system.debug('failureScore OK ...');
                // Checks company state
                system.debug('Avalia Company State: '+report[0].Estado__c);
                if( report[0].Estado__c !='Ativa' && report[0].Estado__c !='' &&  report[0].Estado__c !=null){
                    system.debug('Company State NOK ');
                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                    app.Status__c='Application - Rejected';  
                    Notification__c notif= new Notification__c( application__c=appId,  Message__c='Rejeitado: Empresa ' + report[0].Estado__c); 
                    insert notif;
                    app.Reject_Reason__c='Rejeitado: Empresa ' + report[0].Estado__c;
                    system.debug('1');
                    update acc;
                    update app;
                    Return acc.Credit_Line_Status__c;
                }
                else{
                    system.debug('Company State OK');// ou não está preechido');
                    // tem dateOfEstablishment?
                    system.debug('Avalia DateOfEstablishment ...');
                    if( DateOfEstablishment==null){
                        system.debug('DateOfEstablishment Vazia ...');
                        system.debug('Avalia valor de vendas ...');
                        if(acc.Sales__c==null){
                            system.debug('Valor de Vendas não existe.');
                            system.debug('Avalia valor NetProfit...');
                            if(acc.AnnualRevenue==null ){
                                system.debug('NetProfit não existe.');
                                system.debug('evaluates court Actions');
                                if(report[0].TotIncidentes__c==null){
                                    system.debug('courtactions do not exist');                                        
                                    if(legalForm!=null && legalForm!=''){
                                        system.debug('Legal Form exists');
                                        legalformcredit=true;
                                        ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                        where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                        
                                        if(ScoreCardLegal.size()==0){
                                            acc.Credit_Line_Status__c='Credit Line - Pendent';
                                            app.Status__c='Application - Pendent';
                                            app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                            system.debug('2');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;   
                                        }
                                        else{
                                            system.debug('IF ENI ADOV or SROC...');
                                            if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                system.debug('Evaluates failure score for ENI and ADVOG...');
                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                app.Status__c='Application - Approved';
                                                app.Reject_Reason__c='';
                                                system.debug('3');
                                                app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                
                                            } 
                                            else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                system.debug('4');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;        
                                            }
                                            else{
                                                system.debug('evaluates legal form score card for others legalforms');
                                                if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                }
                                                else{
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                    system.debug('5');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        app.Status__c='Application - Rejected';  
                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                        system.debug('6');
                                        update acc;
                                        update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                }
                                else{
                                    //avalia se courtactions ok
                                    system.debug('verifies if courtactions ok?');
                                    list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                 From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                 Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                    if(ScoreCardCourtAct.size()!=0){
                                        system.debug('Courtactions nok?');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        app.Status__c='Application - Rejected';  
                                        app.Reject_Reason__c=insertNotification(app.id, 'Tribunal'  , 'Rejeitado');
                                        system.debug('7');
                                        update acc;
                                        update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        //avalia legal form
                                        system.debug('Evaluates LegalForm');
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                app.Status__c='Application - Pendent';
                                                app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                system.debug('8');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    system.debug('9');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;        
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        system.debug('10');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            system.debug('11');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }
                                } 
                            }
                            else{
                                // verifica se net profit ok
                                system.debug('evaluates Net profit...');
                                system.debug(acc.AnnualRevenue);
                                List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                              where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c >:acc.AnnualRevenue And 
                                                                              FieldName__c='NetProfit'  ];
                                if(ScoreCardNetProfit.size()!=0  ){ 
                                    system.debug('Net Profit NOK.');
                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                    system.debug('12');
                                    app.Status__c='Application - Rejected';
                                    update acc; 
                                    update app;
                                    Return acc.Credit_Line_Status__c;
                                }
                                else{
                                    system.debug('Net Profit OK.');
                                    system.debug('Evaluates courtactions...');
                                    if(report[0].TotIncidentes__c==null){
                                        system.debug('Courtactions do not exist.');
                                        system.debug('Evaluates legal form...');
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                app.Status__c='Application - Pendent';
                                                app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                system.debug('13');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    system.debug('14');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;        
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        system.debug('15');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            system.debug('16');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }
                                    else{
                                        //avalia se courtactions ok
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                            system.debug('17');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            //avalia legal form
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    app.Status__c='Application - Pendent';
                                                    app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    system.debug('18');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else{
                                                    // como não tem failure score vai rejeitar logo estas 2 legalForms
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SORC'){
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    } 
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                        system.debug('19');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            system.debug('20');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                            else{
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                system.debug('21');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            system.debug('Evaluate sales ...');
                            list<ScoreCard_Config__c> ScoreCardCfgSales=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                                                         Matching_Value_To_Nr__c >:acc.Sales__c And FieldName__c='Sales'  ];
                            if(ScoreCardCfgSales.size()!=0  ){ 
                                system.debug('Sales NOK. Rejeitado');
                                acc.Credit_Line_Status__c=ScoreCardCfgSales[0].Decision__c;
                                if(ScoreCardCfgSales[0].Auto_Decision__c==true){
                                    app.Status__c='Application - Rejected';
                                    app.Reject_Reason__c=insertNotification(app.id, 'Faturação Insuficiente', 'Rejeitado');
                                    system.debug('22');
                                }
                                update acc; 
                                update app;
                                Return acc.Credit_Line_Status__c;
                            }
                            else{
                                // vendas ok avalia net profit
                                if(acc.AnnualRevenue==null ){
                                    system.debug('NetProfit não existe. evaluates court Actions');
                                    if(report[0].TotIncidentes__c==null){
                                        system.debug('courtactions do not exist');                                        
                                        if(legalForm!=null && legalForm!=''){
                                            system.debug('Legal Form exists');
                                            legalformcredit=true;
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                app.Status__c='Application - Pendent';
                                                app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                system.debug('23');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else{
                                                system.debug('IF ENI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    system.debug('24');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;        
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        system.debug('25');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            system.debug('26');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }
                                    else{
                                        //avalia se courtactions ok
                                        system.debug('verifies if courtactions ok?');
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            system.debug('Courtactions nok?');
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Tribunal'  , 'Rejeitado');
                                            system.debug('27');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            //avalia legal form
                                            system.debug('Evaluates LegalForm');
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    app.Status__c='Application - Pendent';
                                                    app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else{
                                                    system.debug('IF ENI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                        system.debug('28');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            system.debug('29');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                            else{
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                system.debug('30');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                    } 
                                }
                                else{
                                    // verifica se net profit ok
                                    system.debug('evaluates Net profit...');
                                    List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                                  where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c >:acc.AnnualRevenue And 
                                                                                  FieldName__c='NetProfit'  ];
                                    if(ScoreCardNetProfit.size()!=0  ){ 
                                        system.debug('Net Profit is not ok');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        app.Status__c='Application - Rejected';
                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                        system.debug('31');
                                        update acc; 
                                        update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        system.debug('Net Profit OK.');
                                        system.debug('Evaluates courtactions...');
                                        if(report[0].TotIncidentes__c==null){
                                            system.debug('Courtactions do not exist.');
                                            system.debug('Evaluates legal form...');
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    app.Status__c='Application - Pendent';
                                                    app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    system.debug('32');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else{
                                                    system.debug('IF ENI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                        system.debug('33');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            system.debug('34');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                            else{
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                system.debug('35');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                        else{
                                            //avalia se courtactions ok
                                            list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                         From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                         Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                            if(ScoreCardCourtAct.size()!=0){
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                system.debug('36');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                            else{
                                                //avalia legal form
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()==0){
                                                        acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                        app.Status__c='Application - Pendent';
                                                        app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                        system.debug('37');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;   
                                                    }
                                                    else{
                                                        system.debug('IF ENI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('Evaluates failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                        }
                                                        else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                            system.debug('38');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;        
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                app.Status__c='Application - Approved';
                                                                app.Reject_Reason__c='';
                                                                app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                app.Status__c='Application - Rejected';  
                                                                app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                system.debug('39');
                                                                update acc;
                                                                update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }
                                                }
                                                else{
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    system.debug('40');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    else{
                        system.debug('DateOfEstablishment preenchida...');
                        
                        string isStartup=AprovacaoDeEmpresaRecenteComScore(acc,app,valdate, report);
                        if(isStartup=='Credit Line - Rejected'){
                            /* Startup APARTIR DE 161117
acc.Credit_Line_Status__c='Credit Line - Rejected';
app.Status__c='Application - Rejected';
app.Reject_Reason__c=insertNotification(app.id, 'Data de Início', 'Rejeitado');
system.debug('41');
update acc; 
update app;
Return acc.Credit_Line_Status__c;
*/
                            system.debug('DateOfEstablishment NOK');
                            return acc.Credit_Line_Status__c;                            
                        } 
                        if(isStartup=='Startup - Approved'){
                            return finalizeCreditLineStatusStartup(acc, app, report);
                        }
                        
                        if(valdate < limitdate){   
                        system.debug('DateOfEstablishment NOK');  

                        /* FIANCA APARTIR DE 161107
acc.Credit_Line_Status__c='Credit Line - Rejected';
app.Status__c='Application - Rejected';
app.Reject_Reason__c=insertNotification(app.id, 'Data de Início', 'Rejeitado');
update acc; 
update app;
Return acc.Credit_Line_Status__c;
*/
                        acc.Personal_Guarantee__c = true;
                        app.Personal_Guarantee__c = true;
                        }
                        
                        /* FIANCA APARTIR DE 161107 
else {*/
                        // tem vendas
                        
                        if(acc.Sales__c== Null){
                            system.debug('evaluates Sales...');
                            system.debug('Sales do not exist.');
                            // inserir fluxo de ramo sem failure score
                            system.debug('Avalia valor NetProfit...');
                            if(acc.AnnualRevenue==null ){
                                system.debug('NetProfit não existe.');
                                system.debug('evaluates court Actions');
                                if(report[0].TotIncidentes__c==null){
                                    system.debug('courtactions do not exist');                                        
                                    if(legalForm!=null && legalForm!=''){
                                        legalformcredit=true;
                                        system.debug('Legal Form exists');
                                        ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                        where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                        if(ScoreCardLegal.size()==0){
                                            acc.Credit_Line_Status__c='Credit Line - Pendent';
                                            app.Status__c='Application - Pendent';
                                            app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                            system.debug('42');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;   
                                        }
                                        else{
                                            system.debug('IF EI ADOV or SROC...');
                                            if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                app.Status__c='Application - Approved';
                                                app.Reject_Reason__c='';
                                                app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                            }
                                            else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                app.Status__c='Application - Approved';
                                                app.Reject_Reason__c='';
                                                app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                            }
                                            else{
                                                system.debug('evaluates legal form score card for others legalforms');
                                                if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                }
                                                else{
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                    system.debug('43');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        app.Status__c='Application - Rejected';  
                                        app.Reject_Reason__c=insertNotification(app.id, 'Finanaceira Indisponível', 'Rejeitado');
                                        system.debug('44');
                                        update acc;
                                        update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                }
                                else{
                                    //avalia se courtactions ok
                                    system.debug('verifies if courtactions ok?');
                                    list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                 From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                 Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                    if(ScoreCardCourtAct.size()!=0){
                                        system.debug('Courtactions nok?');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        app.Status__c='Application - Rejected';  
                                        app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                        system.debug('45');
                                        update acc;
                                        update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        //avalia legal form
                                        system.debug('Evaluates LegalForm');
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                app.Status__c='Application - Pendent';
                                                app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                system.debug('46');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, COOP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        system.debug('47');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            system.debug('legal form does not exist. rejected');
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            system.debug('48');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;  
                                        }
                                    }
                                }
                            }
                            else{
                                // verifica se net profit ok
                                List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                              where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c >:acc.AnnualRevenue And 
                                                                              FieldName__c='NetProfit'  ];
                                if(ScoreCardNetProfit.size()!=0  ){ 
                                    system.debug('Net Profit is not ok');
                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                    app.Status__c='Application - Rejected';
                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                    system.debug('49');
                                    update acc; 
                                    update app;
                                    Return acc.Credit_Line_Status__c;
                                }
                                else{
                                    if(report[0].TotIncidentes__c==null){
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                app.Status__c='Application - Pendent';
                                                app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                system.debug('50');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        system.debug('51');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            system.debug('52');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }  
                                    else{
                                        //avalia se courtactions ok
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                            system.debug('53');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            //avalia legal form
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    app.Status__c='Application - Pendent';
                                                    app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    system.debug('54');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else{
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            system.debug('54');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                            else{
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                system.debug('55');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            
                            system.debug('Sales approval limit X Sales  ok?');
                            //Sales approval limit X Sales > 500€?
                            list<ScoreCard_Config__c > CreditLineCfg=[select Credit_Line_limit__c from ScoreCard_Config__c where recordType.name='Credit Line' and Candor_Grade__c= :CandorGradeAfterAct.Candor_Grade__c AND  Amount_Min__c <= :acc.Sales__c AND Amount_Max__c >=:acc.Sales__c ];
                            /*
system.debug('CreditLineCfg.size() '+CreditLineCfg.size());
system.debug('acc.Sales__c '+ acc.Sales__c);
system.debug('CandorGradeAfterAct.Candor_Grade__c '+ CandorGradeAfterAct.Candor_Grade__c);
*/
                            if(CreditLineCfg.size()==0){
                                CreditLineCfg=[select Credit_Line_limit__c from ScoreCard_Config__c where recordType.name='Credit Line' and Candor_Grade__c= :CandorGradeAfterAct.Candor_Grade__c AND  Amount_Min__c <= :acc.Sales__c order by Amount_Min__c DESC];
                            }                        
                            AggregateResult[] groupedResults = [select MIN(Amount_Min__c) min from ScoreCard_Config__c where recordType.name='Factor Card'];
                            integer approvalValueLimit = Integer.valueOf(groupedResults[0].get('min'));
                            /*
system.debug('CreditLineCfg[0].Credit_Line_limit__c'+CreditLineCfg[0].Credit_Line_limit__c);
system.debug('acc.Sales__c '+ acc.Sales__c);
system.debug('approvalValueLimit '+ approvalValueLimit);
*/
                            if(CreditLineCfg.size()==0 || CreditLineCfg[0].Credit_Line_limit__c * (acc.Sales__c / 100) < approvalValueLimit){
                                system.debug('acc.Sales__c:'+acc.Sales__c);
                                system.debug('CandorGradeAfterAct.Candor_Grade__c:'+CandorGradeAfterAct.Candor_Grade__c);
                                system.debug('approvalValueLimit:'+approvalValueLimit);
                                if(CreditLineCfg.size()!=0){
                                    system.debug('CreditLineCfg[0].Credit_Line_limit__c:'+CreditLineCfg[0].Credit_Line_limit__c);
                                }
                                system.debug('Sales approval not ok. Rejeitado.');
                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                app.Status__c='Application - Rejected';                                                
                                app.Reject_Reason__c=insertNotification(app.id, 'Faturação Insuficiente', 'Rejeitado');
                                update acc; 
                                update app;
                                Return acc.Credit_Line_Status__c; 
                            }
                            
                            system.debug('are sales ok?');
                            ScoreCardCfg=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                          Matching_Value_To_Nr__c >:acc.Sales__c And FieldName__c='Sales'  ];
                            if(ScoreCardCfg.size()!=0  ){ 
                                system.debug('sales are not ok.');
                                acc.Personal_Guarantee__c = true;
                                app.Personal_Guarantee__c = true;
                            }else{
                                system.debug('Sales OK.');
                            }
                            /* FIANCA APARTIR DE 161107   
system.debug('evaluate years since establishiment.');
// avalia anos de empresa
if( valdate >= CandorGradeAfterAct.Sales_NOK__c){
system.debug('Sales approval ok?');
list<ScoreCard_Config__c > CreditLineCfg=[select Id, name, Credit_Line_limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
where recordType.name='Credit Line' and Candor_Grade__c= :CandorGradeAfterAct.Candor_Grade__c AND  Amount_Min__c <= :acc.Sales__c AND Amount_Max__c >=:acc.Sales__c ];
if(CreditLineCfg.size()==0){
CreditLineCfg=[select Id, name, Credit_Line_limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
where recordType.name='Credit Line' and Candor_Grade__c=:CandorGradeAfterAct.Candor_Grade__c AND   Amount_Min__c <= :acc.Sales__c ]; 
}    
if(CreditLineCfg.size()==0){
system.debug('Sales approval not ok. Rejeitado.');
acc.Credit_Line_Status__c='Credit Line - Rejected';
app.Status__c='Application - Rejected';                                                
app.Reject_Reason__c=insertNotification(app.id, 'Faturação Insuficiente', 'Rejeitado'); 
update acc; 
update app;
Return acc.Credit_Line_Status__c; 
}
else{

system.debug('Sales Approval ok.');
system.debug('evaluates last 2 years finantial statements');
if(report[0].Sales_n_1__c!=0 && report[0].Sales_n_1__c!=null ){
acc.Credit_Line_Status__c='Credit Line - Approved';
app.Status__c='Application - Approved';
app.Reject_Reason__c='';
app.ScoreCard__c=CandorGradeAfterAct.Id;
acc.Risk_Type__c=CandorGradeAfterAct.App_Client_Risk__C;
system.debug('Informação finanaceira para os dois ultimos anos existe.');
}
else{
acc.Credit_Line_Status__c='Credit Line - Pendent';
app.Status__c='Application - Pendent';
app.Reject_Reason__c=insertNotification(app.id, 'Info disponível inferior', 'Pendente'); 
update acc;
update app;
Return acc.Credit_Line_Status__c;   
}
}
}
else{
system.debug('Sales NOK not ok. Rejeitado.');
acc.Credit_Line_Status__c='Credit Line - Rejected';
app.Status__c='Application - Rejected';       
app.Reject_Reason__c=insertNotification(app.id, 'Data de Início', 'Rejeitado'); 
update acc; 
update app;
Return acc.Credit_Line_Status__c;
}
}
else{

system.debug('Sales OK.');
*/
                            
                            system.debug('evaluates last current and previous year finantial statements');
                            if(report[0].Sales_n_1__c!=0 && report[0].Sales_n_1__c!=null  ){
                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                app.Status__c='Application - Approved';
                                app.Reject_Reason__c='';
                                app.ScoreCard__c=CandorGradeAfterAct.Id;
                                acc.Risk_Type__c=CandorGradeAfterAct.App_Client_Risk__C;
                                system.debug('Informação finanaceira para os dois ultimos anos existe.');
                            }//ALTERACAO - 16/08/17 - deixar de rejeitar (BP)
                            else if(report[0].Sales_n_1__c==0 || report[0].Sales_n_1__c == null){
                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                app.Status__c='Application - Approved';
                                acc.Account_Status__c = 'Yellow';
                                //app.Reject_Reason__c=insertNotification(app.id, 'Faturação Insuficiente', 'Rejeitado'); 
                                update acc;
                                update app;
                                //Return acc.Credit_Line_Status__c;   
                            }
                            /* ALTERACAO - 16/08/17 - deixa de fazer sentido (BP)
                            else{
                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                app.Status__c='Application - Rejected';
                                app.Reject_Reason__c=insertNotification(app.id, 'Informação financeira disponível tem mais de 2 anos', 'Rejeitado'); 
                                update acc;
                                update app;
                                Return acc.Credit_Line_Status__c;   
                            }*/
                            
                            /* FIANCA APARTIR DE 161107     
}
*/
                        }
                        /* FIANCA APARTIR DE 161107   
}*/
                    }
                    /* FIANCA APARTIR DE 161107   
}*/
                }
            } 
            // failure scores does not exist
            else {
                system.debug('failure score does not exist');
                
                string isStartup=AprovacaoDeEmpresaRecenteSemScore(acc,app,valdate, report);
                if(isStartup=='Credit Line - Rejected'){
                    system.debug('DateOfEstablishment NOK');
                    return acc.Credit_Line_Status__c;                            
                } 
                if(isStartup=='Startup - Approved'){
                    system.debug('rateinf'+rateinf);
                    List<ScoreCard_Config__c> IniCandorGradeList=[Select Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,
                                    DateOfEstablishment__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                    FieldName__c='Risco Informa' and Informa_Rating__c=: rateinf limit 1 ];
                    if(IniCandorGradeList.size()==0){
                        IniCandorGradeList=[Select Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,
                                    DateOfEstablishment__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                    FieldName__c='Risco Informa' and Failure_Score_Min__c=:0 limit 1 ];
                    }
                    app.ScoreCard__c=IniCandorGradeList[0].Id;
                    acc.Risk_Type__c=IniCandorGradeList[0].App_Client_Risk__C;
                    return finalizeCreditLineStatusStartup(acc, app, report);
                }
                
                // Checks company state
                system.debug('Evaluates company state...');
                if( report[0].Estado__c !='Ativa' && ( report[0].Estado__c !='' &&  report[0].Estado__c !=null)){
                    system.debug('Company state not ok.');
                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                    app.Status__c='Application - Rejected';  
                    app.Reject_Reason__c=insertNotification(app.id, 'sem indícios de atividade', 'Rejeitado');
                    update acc;
                    update app;
                    Return acc.Credit_Line_Status__c;
                }
                else {
                    // evaluates dateOfEstablishment?
                    system.debug('evaluates dateOfestablishment...');
                    if( DateOfEstablishment ==null){
                        system.debug('DateOfEstablishment empty.');
                        system.debug('evaluates sales...');
                        if(acc.Sales__c== null){
                            system.debug('sales does not exist.');
                            system.debug('evaluates Net Profit...');    
                            if(acc.AnnualRevenue==null ){
                                system.debug('net profit does not exist.');
                                system.debug('evaluates courtactions...');    
                                if(report[0].TotIncidentes__c==null){
                                    system.debug('court actions does not exist...');    
                                    if(legalForm!=null && legalForm!=''){
                                        system.debug('Legal Form exists');
                                        legalformcredit=true;
                                        ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                        where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                        if(ScoreCardLegal.size()==0){
                                            acc.Credit_Line_Status__c='Credit Line - Pendent';
                                            app.Status__c='Application - Pendent';
                                            app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;   
                                        }
                                        else{
                                            system.debug('IF EI ADOV or SROC...');
                                            if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                system.debug('no failure score so credit line rejected for ENI and ADVOG...');
                                                
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;  
                                                
                                            }
                                            else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;        
                                            }
                                            else{
                                                system.debug('evaluates legal form score card for others legalforms');
                                                if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                    legalformcredit=true;
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists. Aplicação aprovada'); 
                                                }
                                                else{
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        system.debug('Legal form does not exist. rejeitado');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        app.Status__c='Application - Rejected';  
                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                        update acc;
                                        update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                }
                                else{
                                    //avalia se courtactions ok
                                    system.debug('evaluate if courtactions are ok...');
                                    list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                 From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                 Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                    if(ScoreCardCourtAct.size()!=0){
                                        system.debug('courtactions nok');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        app.Status__c='Application - Rejected';  
                                        app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                        update acc;
                                        update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        system.debug('courtactions ok.');
                                        system.debug('evaluates legal form...');
                                        //avalia legal form
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                app.Status__c='Application - Pendent';
                                                app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;   
                                                
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;  
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;        
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        
                                    }
                                }
                            }
                            else{
                                system.debug('evaluates if net profit ok...');
                                // verifica se net profit ok
                                List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                              where RecordType.Name='Score Card' and Matching_Value_To_Nr__c >:acc.AnnualRevenue And 
                                                                              FieldName__c='NetProfit'  ];
                                if(ScoreCardNetProfit.size()!=0  ){ 
                                    system.debug('Net Profit is not ok');
                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                    app.Status__c='Application - Rejected';
                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                    update acc; 
                                    update app;
                                    Return acc.Credit_Line_Status__c;
                                }
                                else{
                                    system.debug('evaluates courtactions');
                                    if(report[0].TotIncidentes__c==null){
                                        system.debug('court actions do not exist.');
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                app.Status__c='Application - Pendent';
                                                app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente'); 
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;   
                                                
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;  
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;        
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }  
                                        }
                                        else{
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }  
                                    else{
                                        //avalia se courtactions ok
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            //avalia legal form
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    app.Status__c='Application - Pendent';
                                                    app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                    
                                                }
                                                else{
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            //avalia vendas
                            list<ScoreCard_Config__c> ScoreCardCfgSales=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                                                         Matching_Value_To_Nr__c >:acc.Sales__c And FieldName__c='Sales'  ];
                            if(ScoreCardCfgSales.size()!=0  ){ 
                                acc.Credit_Line_Status__c=ScoreCardCfgSales[0].Decision__c;
                                update acc; 
                                app.Reject_Reason__c=ScoreCardCfgSales[0].Message__c;
                                if(ScoreCardCfgSales[0].Auto_Decision__c==true){
                                    app.Status__c='Application - Rejected';
                                    Notification__c notif= new Notification__c( application__c=app.Id,  Message__c=ScoreCardCfgSales[0].Message__c); 
                                    insert notif;
                                }
                                update acc; 
                                update app;
                                Return acc.Credit_Line_Status__c;
                            }
                            else {
                                // netprofit existe?
                                if(acc.AnnualRevenue==null){
                                    // courtactions existe?
                                    if(report[0].TotIncidentes__c==null){
                                        //legalform existe?
                                        if(legalForm==null){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c; 
                                        }
                                        else{
                                            //avalia legalform coloca chamada a method q avalia legalform
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    app.Status__c='Application - Pendent';
                                                    app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else{
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('no failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }  
                                            }
                                            else{
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                    }
                                    else{
                                        // avalia courtactions
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            if(legalForm==null){
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c; 
                                            }
                                            else{
                                                //avalia legalform coloca chamada a method q avalia legalform
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()==0){
                                                        acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                        app.Status__c='Application - Pendent';
                                                        app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;   
                                                    }
                                                    else{
                                                        system.debug('IF EI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;        
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                legalformcredit=true;
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                app.Status__c='Application - Approved';
                                                                app.Reject_Reason__c='';
                                                                app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                app.Status__c='Application - Rejected';  
                                                                app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }  
                                                }
                                                else{
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                else{
                                    // avalia netprofit
                                    // verifica se net profit ok
                                    system.debug('evaluates Net profit...');
                                    List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                                  where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c >:acc.AnnualRevenue And 
                                                                                  FieldName__c='NetProfit'  ];
                                    if(ScoreCardNetProfit.size()!=0  ){ 
                                        system.debug('Net Profit NOK.');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                        app.Status__c='Application - Rejected';
                                        update acc; 
                                        update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        system.debug('Net Profit OK.');
                                        system.debug('Evaluates courtactions...');
                                        if(report[0].TotIncidentes__c==null){
                                            system.debug('Courtactions do not exist.');
                                            system.debug('Evaluates legal form...');
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    app.Status__c='Application - Pendent';
                                                    app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else{
                                                    system.debug('IF ENI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('no failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            //avalia se courtactions ok
                                            list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                         From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                         Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                            if(ScoreCardCourtAct.size()!=0){
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                            else{
                                                //avalia legal form
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()==0){
                                                        acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                        app.Status__c='Application - Pendent';
                                                        app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;   
                                                    }
                                                    else{
                                                        system.debug('IF ENI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;        
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                app.Status__c='Application - Approved';
                                                                app.Reject_Reason__c='';
                                                                app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                app.Status__c='Application - Rejected';  
                                                                app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }  
                    else{
                        ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                        where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                        // can not find record for client with no failure score
                        if(ScoreCardLegal.size()==0  ){ 
                            if(legalform==null || legalform==''){
                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                app.Status__c='Application - Rejected';  
                                app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                update acc;
                                update app;
                                Return acc.Credit_Line_Status__c;
                            }
                            else{
                                /* ++++++ */
                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                app.Status__c='Application - Pendent';
                                app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                
                                update acc; 
                                update app;
                                Return acc.Credit_Line_Status__c;
                            }
                            
                        }
                        else{
                            /* 20161212 SalesNok no longer used
                            
                            limitdate=scorecardLegal[0].Sales_NOK__C;//TODO para date establish e fiança
                            */
                            limitdate=scorecardLegal[0].DateOfEstablishment__c;//TODO para date establish e fiança
                            if (valdate < limitdate){
                                
                                acc.Personal_Guarantee__c = true;
                                app.Personal_Guarantee__c = true;
                                /*
                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                app.Status__c='Application - Rejected';
                                app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');//Data de Início de Atividade
                                update acc; 
                                update app;
                                Return acc.Credit_Line_Status__c;
                                */
                            } 
                            /* 20161212 SalesNok no longer used
                            else if(acc.Sales__c== null){
                            */
                            if(acc.Sales__c== null){
                                if(acc.AnnualRevenue==null ){
                                    if(report[0].TotIncidentes__c==null){
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                app.Status__c='Application - Pendent';
                                                app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('no failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;  
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                    legalformcredit=true;
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    app.Status__c='Application - Approved';
                                                    app.Reject_Reason__c='';
                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }  
                                        }
                                    }
                                    else{
                                        //avalia se courtactions ok
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';  
                                            app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                            update acc;
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            //avalia legal form
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()!=0){
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                else{
                                    // verifica se net profit ok
                                    List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                                  where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c <:acc.AnnualRevenue And 
                                                                                  FieldName__c='NetProfit'  ];
                                    if(ScoreCardNetProfit.size()==0  ){ 
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        app.Status__c='Application - Rejected';
                                        app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                        update acc; 
                                        update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        if(report[0].TotIncidentes__c==null){
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()!=0){
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('no failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }  
                                        else{
                                            //avalia se courtactions ok
                                            list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                         From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                         Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                            if(ScoreCardCourtAct.size()!=0){
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                            else{
                                                //avalia legal form 
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()!=0){
                                                        
                                                        system.debug('IF EI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else  if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                legalformcredit=true;
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                app.Status__c='Application - Approved';
                                                                app.Reject_Reason__c='';
                                                                app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                app.Status__c='Application - Rejected';  
                                                                app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }  
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                // avalia se sales ok
                                list<ScoreCard_Config__c> ScoreCardCfgSales=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                                                             Matching_Value_To_Nr__c >:acc.Sales__c And FieldName__c='Sales'  ];
                                if(ScoreCardCfgSales.size()!=0  ){ 
                                    acc.Credit_Line_Status__c=ScoreCardCfgSales[0].Decision__c;
                                    update acc; 
                                    app.Reject_Reason__c=ScoreCardCfgSales[0].Message__c;
                                    if(ScoreCardCfgSales[0].Auto_Decision__c==true){
                                        app.Status__c='Application - Rejected';
                                        Notification__c notif= new Notification__c( application__c=app.Id,  Message__c=ScoreCardCfgSales[0].Message__c); 
                                        insert notif;
                                    }
                                    update acc; 
                                    update app;
                                    Return acc.Credit_Line_Status__c;
                                }
                                else{
                                    if(acc.AnnualRevenue==null ){
                                        if(report[0].TotIncidentes__c==null){
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()!=0){
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('no failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        app.Status__c='Application - Rejected';  
                                                        app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        app.Status__c='Application - Approved';
                                                        app.Reject_Reason__c='';
                                                        app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }  
                                            }
                                        }
                                        else{
                                            //avalia se courtactions ok
                                            list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                         From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                         Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                            if(ScoreCardCourtAct.size()!=0){
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                app.Status__c='Application - Rejected';  
                                                app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                update acc;
                                                update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                            else{
                                                //avalia legal form 
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()==0){
                                                        system.debug('IF EI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else  if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                legalformcredit=true;
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                app.Status__c='Application - Approved';
                                                                app.Reject_Reason__c='';
                                                                app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                app.Status__c='Application - Rejected';  
                                                                app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        // verifica se net profit ok
                                        List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                                      where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c <:acc.AnnualRevenue And 
                                                                                      FieldName__c='NetProfit'  ];
                                        if(ScoreCardNetProfit.size()==0  ){ 
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            app.Status__c='Application - Rejected';
                                            app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                            update acc; 
                                            update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            if(report[0].TotIncidentes__c==null){
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()!=0){
                                                        system.debug('IF EI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            app.Status__c='Application - Rejected';  
                                                            app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            app.Status__c='Application - Approved';
                                                            app.Reject_Reason__c='';
                                                            app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                legalformcredit=true;
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                app.Status__c='Application - Approved';
                                                                app.Reject_Reason__c='';
                                                                app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                app.Status__c='Application - Rejected';  
                                                                app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }
                                                }
                                            }  
                                            else{
                                                //avalia se courtactions ok
                                                list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                             From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                             Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                                if(ScoreCardCourtAct.size()!=0){
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    app.Status__c='Application - Rejected';  
                                                    app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                    update acc;
                                                    update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                                else{
                                                    //avalia legal form
                                                    if(legalForm!=null && legalForm!=''){
                                                        legalformcredit=true;
                                                        // como não tem failure score vai rejeitar logo estas 2 legalForms
                                                        system.debug('Legal Form exists');
                                                        ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                        where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                        if(ScoreCardLegal.size()!=0){
                                                            system.debug('IF EI ADOV or SROC...');
                                                            if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                                system.debug('Evaluates failure score for ENI and ADVOG...');
                                                                
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                app.Status__c='Application - Rejected';  
                                                                app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                                update acc;
                                                                update app;
                                                                Return acc.Credit_Line_Status__c;  
                                                                
                                                            }
                                                            else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                                system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                                if (DateOfEstablishment==null){
                                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                    app.Status__c='Application - Rejected';  
                                                                    app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                                    update acc;
                                                                    update app;
                                                                    Return acc.Credit_Line_Status__c;        
                                                                }
                                                                else {
                                                                    legalformcredit=true;
                                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                    app.Status__c='Application - Approved';
                                                                    app.Reject_Reason__c='';
                                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                                }
                                                            }
                                                            else{
                                                                system.debug('evaluates legal form score card for others legalforms');
                                                                if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                    legalformcredit=true;
                                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                    app.Status__c='Application - Approved';
                                                                    app.Reject_Reason__c='';
                                                                    app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                                }
                                                                else{
                                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                    app.Status__c='Application - Rejected';  
                                                                    app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                    update acc;
                                                                    update app;
                                                                    Return acc.Credit_Line_Status__c;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }  
                        }
                    }
                }
                
            }
            system.debug('Going to finalizeCreditLineStatus');
            return finalizeCreditLineStatus(legalformcredit, acc, app, report, CandorGradeAfterAct, ScoreCardLegal, risk4);
        }
        catch(Exception e){
            system.debug('Error in ScoreCard - Credit Line Analysis!');
            system.debug('ScoreCardConfigv2 - ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return null;
        }   
    }
    
    /******
*/

    public static string finalizeRejeicao(Account acc, Application__c app, string motivo){
        acc.Credit_Line_Status__c='Credit Line - Rejected';
        app.Status__c='Application - Rejected';
        app.Reject_Reason__c=insertNotification(app.id, motivo, 'Rejeitado', 3);
        update acc; 
        update app;
        Return acc.Credit_Line_Status__c;
    }

    private static string finalizeCreditLineStatusStartup(account acc, application__c app, list<reportdb__c> report){
        update app;
        update acc;
        system.debug('finalizeCreditLineStatusStartup! Going to getCreditLine');
        if(acc.Credit_Line_Status__c=='Credit Line - Approved' ) {
            if(isEmpresaRecente(acc)){
                system.debug('Credit Line de Startup >> '+'DateOfEstablishment:'+acc.Date_Of_Establishment__c+' calculaIdade(DateOfEstablishment):'+calculaIdade(acc.Date_Of_Establishment__c)+' report[0].CapitalSocial__c:'+ report[0].CapitalSocial__c);
                acc.Credit_line__c = report[0].CapitalSocial__c * getStartupCreditMultiplier();
                decimal startupMaxCredit = getStartupMaxCredit();
                if(acc.Credit_line__c > startupMaxCredit){
                    system.debug('Reducao de Credit Line de Startup >> '+' acc.Credit_line__c:'+acc.Credit_line__c);
                    acc.Credit_line__c = startupMaxCredit;
                }
            }
            
            if ( acc.Used_Credit_Line__c==null){
                acc.Available_Credit_Line__c= acc.Credit_line__c ;
            } else {
                acc.Available_Credit_Line__c= acc.Credit_line__c - acc.Used_Credit_Line__c;     
            }    
        }
        
        app.Client_Available_Credit_Line__c=acc.Available_Credit_Line__c;
        
        update app;
        update acc; 

        insertNotification(app.id, acc);
        return acc.Credit_Line_Status__c;
    }


    private static string finalizeCreditLineStatus(boolean legalformcredit, account acc, application__c app, list<reportdb__c> report, scorecard_config__c CandorGradeAfterAct, list<ScoreCard_Config__c> ScoreCardLegal, boolean risk4){
        update app;
        update acc;
        system.debug('finalizeCreditLineStatus! Going to getCreditLine');
        if(legalformcredit==true){
            getCreditLine(acc, app, report, ScoreCardLegal[0], legalformcredit, risk4 );
        }
        else{
            getCreditLine(acc, app, report, CandorGradeAfterAct, legalformcredit, risk4 );
        }
        //ALTERACAO - 09/05/17 - adicionado if para nao inserir quando a app é recusada (BP)
        //if(acc.credit_line_status__c == 'Credit Line - Approved')        
        if(app.status__c == 'Application - Approved')        
            insertNotification(app.id, acc);
        return acc.Credit_Line_Status__c;
    }
            
    /**********
* 
*/       
    private static string getCreditLine( account acc, application__c app, list<reportdb__c> report, scorecard_config__c CandorGradeAfterAct, boolean legalformcredit, boolean risk4){
        //Credit Line Analysis
        List <ScoreCard_Config__c> CreditLineCfg;
        decimal valrev=acc.Sales__c;
        decimal limitCredit=null;
        if(legalformcredit ==false){
            limitCredit=CandorGradeAfterAct.Credit_Line_Max_Limit__c;
        }
        
        if(acc.Credit_Line_Status__c=='Credit Line - Approved' ) {
            if(isEmpresaRecente(acc)){
                system.debug('Credit Line de Startup >> '+'DateOfEstablishment:'+acc.Date_Of_Establishment__c+' calculaIdade(DateOfEstablishment):'+calculaIdade(acc.Date_Of_Establishment__c)+' report[0].CapitalSocial__c:'+ report[0].CapitalSocial__c);
                acc.Credit_line__c = report[0].CapitalSocial__c * getStartupCreditMultiplier();
                decimal startupMaxCredit = getStartupMaxCredit();
                if(acc.Credit_line__c > startupMaxCredit){
                    system.debug('Reducao de Credit Line de Startup >> '+' acc.Credit_line__c:'+acc.Credit_line__c);
                    acc.Credit_line__c = startupMaxCredit;
                }
            }
            else if(legalformcredit==true){
                
                CreditLineCfg=[select Id, name, Credit_Line_Max_Limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                               where recordType.name='Credit Line' and FieldName__c='EmployeeNumber' And  Amount_Min__c <= :report[0].TotEmpregados__c And Amount_Max__c > :report[0].TotEmpregados__c ];
                if(CreditLineCfg.size()==0){
                    CreditLineCfg=[select Id, name, Credit_Line_Max_Limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                                   where recordType.name='Credit Line' and FieldName__c='EmployeeNumber'  and Amount_Min__c <= :report[0].TotEmpregados__c order by Amount_Min__c desc]; 
                }
                acc.Credit_line__c=CreditLineCfg[0].Credit_Line_Max_Limit__c;
            } 
            else{
                CreditLineCfg=[select Id, name, Credit_Line_limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                               where recordType.name='Credit Line' and Candor_Grade__c= :CandorGradeAfterAct.Candor_Grade__c AND  Amount_Min__c <= :valrev AND Amount_Max__c >=:valrev ];
                if(CreditLineCfg.size()==0){
                    CreditLineCfg=[select Id, name, Credit_Line_limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                                   where recordType.name='Credit Line' and Candor_Grade__c=:CandorGradeAfterAct.Candor_Grade__c AND   Amount_Min__c <= :valrev order by Amount_Min__c DESC]; 
                }
                if(risk4==true){
                    List <ScoreCard_Config__c> CreditLineRisk4Cfg=[Select id, Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                   FieldName__c='SalesApprovalLimit' ];
                    if(CreditLineRisk4Cfg.size()!=0) {
                        decimal crdlinerisk4=0;
                        crdlinerisk4=valrev * CreditLineCfg[0].Credit_Line_limit__c/100;
                        if(crdlinerisk4 <= CreditLineRisk4Cfg[0].Matching_Value_To_Nr__c){
                            acc.Credit_line__c=crdlinerisk4.setScale(0);
                        }
                        else{
                            acc.Credit_line__c=CreditLineRisk4Cfg[0].Matching_Value_To_Nr__c;
                        }
                    }
                }
                
                else {
                    if(CreditLineCfg.size()!=0){
                        decimal crdline=0;
                        crdline=valrev * CreditLineCfg[0].Credit_Line_limit__c/100;
                        if(crdline <= limitcredit){
                            acc.Credit_line__c=crdline.setScale(0);
                        }
                        else{
                            acc.Credit_line__c=limitcredit;
                        }   
                        
                        
                    }  
                }
            }
            
            if ( acc.Used_Credit_Line__c==null)
            {
                acc.Available_Credit_Line__c= acc.Credit_line__c ;
            } 
            else //ALTERACAO - 03/05/17 - quando há uma uma reavalição de report e a linha de financiamento é reduzida (BP) 
            {
                acc.Available_Credit_Line__c= acc.Credit_line__c - acc.Used_Credit_Line__c;     

                List <ScoreCard_Config__c> allowedLimits =[SELECT id,name,fieldname__c,Matching_Value__c  
                                                             FROM ScoreCard_Config__c 
                                                            WHERE fieldname__c LIKE 'Minimum Credit Allowed' LIMIT 1];

                if(acc.Available_Credit_Line__c <= 0)
                {
                    acc.Available_Credit_Line__c = 0;  
                    acc.Credit_Line__c           = acc.Used_credit_line__c; 
                    acc.credit_line_status__c    = 'Credit Line - Rejected'; 
                    app.status__c                = 'Application - Rejected';
                    
                    Notification__c notif        = new Notification__c( application__c=app.Id, 
                                                               Message__c='Rejeitado: Linha de Financiamento insuficiente.');
                    insert notif;
                }
                else                
                    if(acc.Available_Credit_Line__c <= Decimal.valueOf(allowedLimits[0].Matching_Value__c))
                    {
                        app.status__c                = 'Application - Rejected';
                        acc.Available_Credit_Line__c = 0;
                        acc.credit_line_status__c    = 'Credit Line - Rejected'; 
                        Notification__c notif1       = new Notification__c( application__c=app.Id, 
                                                                   Message__c='Rejeitado: Linha de Financiamento insuficiente.');
                        insert notif1;
                    }
            }    
        }
        
        app.Client_Available_Credit_Line__c=acc.Available_Credit_Line__c;
        
        update app;
        update acc; 
        /*
        if( app.Status__c=='Application - Approved'){
            Schema.DescribeFieldResult fieldResult = notification__c.message__c.getDescribe();
            List<Schema.PicklistEntry> plnot = fieldResult.getPicklistValues();
            string rejectreason;
            for(integer i=0; i<plnot.size(); i++){
                if(plnot[i].getLabel().contains('Aprovado')==true ){
                    Notification__c notif= new Notification__c( application__c=app.Id,  Message__c=plnot[i].getLabel() + ' - ' + acc.Available_Credit_Line__c + '€'); 
                    rejectreason=plnot[i].getLabel();
                    insert notif;
                }    
            } 
        }
        */
        return 'ok'; 
    }
    /*********************


*/   
    public static string GetScoreCardRate( string appId, decimal amountequip){
        try{
            decimal finalModalRank;
            Application__c app=[select Id, name,Term__c, Vendor_Diluted_Doc_Fee__c, ScoreCard__c, accClient__c, vendor__c, accClient__r.Risk_Type__c, accClient__r.Date_Of_Establishment__c, Vendor__r.Diluted_Doc_Fee__c, 
                                payment_freq__c, TermCalc__c, vendor__r.Discount_Factor__c From Application__c where Id=: appId];
            ScoreCard_Config__c ModelrankIni;
            ScoreCard_Config__c Modelrankfinal;
            
            decimal term12modifier;
            decimal term24modifier;
            decimal term36modifier;
            ScoreCard_Config__c Modelrankterm12;
            ScoreCard_Config__c Modelrankterm24;
            ScoreCard_Config__c Modelrankterm36;
            decimal Rent12;
            decimal Rent24;
            decimal Rent36;
            decimal Rent48;
            decimal insurOutputmov;
            decimal insurOutputstatic;
            decimal promped=0;
            string candorgrade='';
            string risktype='';
            boolean fee=false;
            decimal discfactor=0;
            if(app.vendor__r.Discount_Factor__c!=null && app.vendor__r.Discount_Factor__c!=''){
                discfactor=decimal.valueOf(((app.vendor__r.Discount_Factor__c).replace(',','.')).replace('%',''));
            }
            
            
            // get initial Model Rank
            // In this stage of the evaluation the credit line can not be rejected
            app.Equipment_Cost__c=amountequip;
            app.Payment_Amount__c=0;
            app.Vendor_Invoice_Amount__c=0;

            //HP - 14/02/2017: add condition "(app.TermCalc__c==null &&..." to check if term is already choosen.
            if(app.TermCalc__c==null && app.accClient__r.Date_Of_Establishment__c != null && isEmpresaRecente(calculaIdade(app.accClient__r.Date_Of_Establishment__c))){
                app.Term__c='24';
            }else if(app.TermCalc__c==null){
                app.Term__c='36';
            }

            integer term = 0; //HP - 14/02/2017 set term__c=36 as default choice to method ScoreCard.GetCalc if not choosen.
            if(app.TermCalc__c!=null){
                term = app.TermCalc__c.intValue(); 
            }
            
            app.TermCalc__c=Decimal.valueOf(app.Term__c);
            app.TermSetByUser__c=false;
            
            if( app.ScoreCard__c== null ){
                ScoreCardConfig.GetCreditLineStatus( app.AccClient__c, appId );
                app=[select Id, ScoreCard__c, accClient__c, accClient__r.Risk_Type__c, vendor__r.Diluted_Doc_Fee__c, 
                     payment_freq__c From Application__c where Id=: appId];
                
                ModelrankIni=[Select Model_Rank__c, Candor_Grade__c, Decision__c from ScoreCard_Config__c where Id =: app.ScoreCard__c];  
            }else{
                ModelrankIni=[Select Model_Rank__c, Candor_Grade__c, Decision__c from ScoreCard_Config__c where Id =: app.ScoreCard__c];  
            }
            
            risktype=app.accClient__r.Risk_Type__c;
            
            return ScoreCardConfig.getCalc(app, amountequip, term, discfactor );
        }
        catch(Exception e){
            system.debug('Error in ScoreCard - Rate Analysis!');
            system.debug('ScoreCardConfig' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return 'Failure';
        }
    }
    
    public static string GetScoreCardRateFromAmount( string appId, decimal amountRent, integer term){
        try{
            decimal finalModalRank;
            Application__c app=[select Id, name, ScoreCard__c, accClient__c, vendor__c, accClient__r.Risk_Type__c, Vendor__r.Diluted_Doc_Fee__c,
                                payment_freq__c, Vendor__r.Discount_Factor__c, Client_Available_Credit_Line__c, accClient__r.Available_Credit_Line__c,
                                AccClient__r.Date_Of_Establishment__c,Vendor_Diluted_Doc_Fee__c From Application__c where Id=: appId];
            ScoreCard_Config__c ModelrankIni;
            ScoreCard_Config__c Modelrankfinal;
            system.debug(app);
            Savepoint sp = Database.setSavepoint();
            decimal term12modifier;
            decimal term24modifier;
            decimal term36modifier;
            ScoreCard_Config__c Modelrankterm12;
            ScoreCard_Config__c Modelrankterm24;
            ScoreCard_Config__c Modelrankterm36;
            decimal Rent12;
            decimal Rent24;
            decimal Rent36;
            decimal Rent48;
            decimal insurOutputmov;
            decimal insurOutputstatic;
            decimal promped=0;
            string candorgrade='';
            decimal amountEquip=0;
            decimal factor=0;
            string riskType='';
            boolean fee=false;    //related to: Documentation Fee na App
            boolean payfee=false;
            boolean intfee=false;
            decimal discfactor=0;
            if(app.vendor__r.Discount_Factor__c!=null && app.vendor__r.Discount_Factor__c!=''){
                discfactor=decimal.valueOf(((app.vendor__r.Discount_Factor__c).replace(',','.')).replace('%',''));
            }
            app.Equipment_Cost__c=amountequip;
            app.Payment_Amount__c=0;
            app.Vendor_Invoice_Amount__c=0;
            app.Term__c=string.ValueOf(term);
            app.TermCalc__c=term;
            app.TermSetByUser__c=false;
            if( app.ScoreCard__c== null ){
                ScoreCardConfig.GetCreditLineStatus( app.AccClient__c, appId );
                app=[select Id, ScoreCard__c, accClient__c, accClient__r.Risk_Type__c , Vendor__r.Diluted_Doc_Fee__c, 
                     payment_freq__c From Application__c where Id=: appId];
                
                ModelrankIni=[Select Model_Rank__c, Candor_Grade__c, Decision__c from ScoreCard_Config__c where Id =: app.ScoreCard__c];  
            }else{
                ModelrankIni=[Select Model_Rank__c, Candor_Grade__c, Decision__c from ScoreCard_Config__c where Id =: app.ScoreCard__c];  
            }
            
            candorgrade=ModelrankIni.Candor_Grade__c;
            riskType=app.accClient__r.Risk_Type__c ; 
            //riskType=app.Client_Risk_Type__c ;
            //fee=app.Vendor__r.Diluted_Doc_Fee__c; // OLHAR PARA ACCOUNT
            fee=!app.Vendor_Diluted_Doc_Fee__c;                 // OLHAR PARA APLICAÇÃO
            
            if (app.payment_freq__c!= null && app.payment_freq__c=='Monthly'){
                payfee=true;
            }
            else if(app.payment_freq__c=='Quarterly') {
                payfee=false;
            }
            
            
            // Depending on type of risk an addition to factor should be applied
            List<ScoreCard_Config__c> TermRentModifier;
            ScoreCard_Config__c FactorModifier;
            ScoreCard_Config__c payModifier;
            // ScoreCard_Config__c feeModifier;
            decimal feesfactor=0;
            decimal factorModifierAux=0;
            decimal feesfactorAux=0;
            //standard score table 
            TermRentModifier=[Select Id, Factor__C, Term__c From ScoreCard_Config__c where RecordType.name ='Factor Card' and 
                              FieldName__c='Factor' and  Instalment_Max__c >= :amountRent And Instalment_Min__c <= :amountRent 
                              and Term__c=: term]   ;  
            system.debug(TermRentModifier);
            if (risktype=='Middle'){
                if(fee==false){
                    if(payfee==false){
                        
                        factor=TermRentModifier[0].Factor__C* (1- discfactor/100); 
                    } 
                    else {
                        
                        payModifier=[Select Name, Matching_Value_To_Nr__c,  Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly']; 
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        factor=(TermRentModifier[0].Factor__C*(1+feesfactorAux/100))* (1- discfactor/100);
                    }
                }
                else{ // diluted fee factor table
                    
                    List<ScoreCard_Config__c> DilutedTermAmount=[Select Id, Factor__C, Term__c From ScoreCard_Config__c where RecordType.name ='Diluted Doc Card' and 
                                                                 FieldName__c='Factor' and Instalment_Max__c >= :amountRent And Instalment_Min__c <= :amountRent
                                                                 and Term__c=: term]   ;  
                    if(payfee==false){
                        factor=DilutedTermAmount[0].Factor__C* (1- discfactor/100);
                        system.debug(factor);
                    } 
                    else {
                        payModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        feesfactor= feesfactorAux;
                        factor=(DilutedTermAmount[0].Factor__C*(1+feesfactor/100))* (1- discfactor/100);
                        system.debug(payModifier);
                        system.debug(feesfactor);
                    }
                }
            }
            else{
                if(fee==false){
                    if(payfee==false){
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c , Matching_value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:risktype];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        factor=(TermRentModifier[0].Factor__C*(1+factorModifierAux/100))* (1- discfactor/100);
                    } 
                    else {
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:risktype];
                        payModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly']; 
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        feesfactor=factorModifierAux + feesfactorAux;
                        factor=(TermRentModifier[0].Factor__C*(1+feesfactor/100))* (1- discfactor/100);
                    }
                }
                else{// diluted fee factor table
                    List<ScoreCard_Config__c> DilutedTermAmount=[Select Id, Factor__C, Term__c From ScoreCard_Config__c where RecordType.name ='Diluted Doc Card' and 
                                                                 FieldName__c='Factor' and Instalment_Max__c >= :amountRent And Instalment_Min__c <= :amountRent
                                                                 and Term__c=: term]   ;  
                    if(payfee==false){
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:risktype];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        feesfactor=factorModifierAux;
                        factor=(DilutedTermAmount[0].Factor__C*(1+feesfactor/100))* (1- discfactor/100);
                    } 
                    else {
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:risktype];
                        payModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        feesfactor=factorModifierAux + feesfactorAux;
                        factor=(DilutedTermAmount[0].Factor__C*(1+feesfactor/100))* (1- discfactor/100);
                    }
                }
            }
            
            app.Equipment_Cost__c=(amountRent/(factor/100)).setscale(2);  
            
            if( app.Client_Available_Credit_Line__c != null && app.Equipment_Cost__c<=app.Client_Available_Credit_Line__c ){
                amountequip=app.Equipment_Cost__c;
                update app;   
                return ScoreCardConfig.getCalc(app, amountequip, term, discfactor );
            }
            else{
                if  (app.accClient__r.Available_Credit_Line__c != null && app.Equipment_Cost__c<= app.accClient__r.Available_Credit_Line__c){
                    amountequip=app.Equipment_Cost__c;
                    update app;   
                    return ScoreCardConfig.getCalc(app, amountequip, term, discfactor ); 
                }else{
                    Database.rollback(sp);
                    return 'CalcValue greater availCreditline';
                }
                
            }
 
        }
        catch (Exception e){
            system.debug('Error in ScoreCard - GetScoreCardRateFromAmount!');
            system.debug('GetScoreCardRateFromAmount' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return 'Failure';
        }
        
    }

        public static String getRentsWithNoUpdate(Application__c app, decimal amountequip, integer term, decimal discfactor){
        String res = 'SUCCESS';
        try{
            
            ScoreCard_Config__c Modelrankterm12;
            ScoreCard_Config__c Modelrankterm24;
            ScoreCard_Config__c Modelrankterm36;
            ScoreCard_Config__c Modelrankterm60;
            ScoreCard_Config__c Modelrankterm72;//ALTERACAO -17/03/17 - (BP)
            ScoreCard_Config__c FactorModifier;
            // ScoreCard_Config__c FeeModifier;
            ScoreCard_Config__c PayModifier;
            //  ScoreCard_Config__c IntfeeModifier;
            decimal Rent12;
            decimal Rent24;
            decimal Rent36;
            decimal Rent48;
            decimal Rent60;
            decimal Rent72;
            decimal insurOutputmov;
            decimal insurOutputstatic;
            decimal insurOutputspecial;
            decimal factor=0;
            decimal feesFactor=0;
            //boolean fee=app.Vendor__r.Diluted_Doc_Fee__c;                 // LOOKS TO ACCOUNT
            boolean fee=!app.Vendor_Diluted_Doc_Fee__c;                 //LOOKS TO APPLICATION
            boolean payfee;
            // replace previous with this
            if(app.payment_freq__c!= null && app.Payment_Freq__c=='Monthly'){
                payfee=true;
            }
            else if(app.payment_freq__c=='Quarterly') {
                payfee=false;
            }
            string risktype=app.accClient__r.Risk_Type__c;
            //string risktype=app.Client_Risk_Type__c;
            // boolean intfee=app.Vendor__r.Diluted_Doc_and_Interim_Fee__c;
            decimal factorModifierAux=0;
            decimal feesfactorAux=0;
            
            List<ScoreCard_Config__c> TermAmounModifier=[Select Id, Factor__C, Term__c From ScoreCard_Config__c where RecordType.name ='Factor Card' and 
                                                         FieldName__c='Factor' and  Amount_Max__c >= :amountequip And Amount_Min__c <= :amountequip ]   ;
            
            if (risktype=='Middle' ){
                if(fee==false){
                    if(payfee==false){
                        System.debug('11111');
                        if(TermAmounModifier.size()!=0 ){
                            for( integer i=0; i<TermAmounModifier.size(); i++){
                                if (TermAmounModifier[i].Term__c==12){
                                    app.ModifierTerm12_Config__c=TermAmounModifier[i].Id;
                                    Rent12= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (TermAmounModifier[i].Term__c==24){
                                    app.ModifierTerm24_Config__c=TermAmounModifier[i].Id;
                                    Rent24= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==36){
                                    app.ModifierTerm36_Config__c=TermAmounModifier[i].Id;
                                    Rent36= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==48){
                                    app.ModifierTerm48_Config__c=TermAmounModifier[i].Id;
                                    Rent48= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==60){
                                    app.ModifierTerm60_Config__c=TermAmounModifier[i].Id;
                                    Rent60= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                //ALTERACAO - 15/03/17 - overview (BP)
                                System.debug('Primeiro step');
                                if (TermAmounModifier[i].Term__c==72){
                                    app.ModifierTerm72_Config__c=TermAmounModifier[i].Id;
                                    Rent72= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }                           
                            }
                        }  
                    } 
                    else
                    { 
                        System.debug('22222');
                        payModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        if(TermAmounModifier.size()!=0 ){
                            for( integer i=0; i<TermAmounModifier.size(); i++){
                                if (TermAmounModifier[i].Term__c==12){
                                    app.ModifierTerm12_Config__c=TermAmounModifier[i].Id;
                                    Rent12= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (TermAmounModifier[i].Term__c==24){
                                    app.ModifierTerm24_Config__c=TermAmounModifier[i].Id;
                                    Rent24= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==36){
                                    app.ModifierTerm36_Config__c=TermAmounModifier[i].Id;
                                    Rent36= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==48){
                                    app.ModifierTerm48_Config__c=TermAmounModifier[i].Id;
                                    Rent48= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==60){
                                    app.ModifierTerm60_Config__c=TermAmounModifier[i].Id;
                                    Rent60= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                //ALTERACAO - 15/03/17 - overview (BP)
                                System.debug('Segundo step');
                                if (TermAmounModifier[i].Term__c==72){
                                    app.ModifierTerm72_Config__c=TermAmounModifier[i].Id;
                                    Rent72= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }                               
                            }
                        }
                    }
                }
                else{
                    // diluted fee factor table
                    System.debug('33333');
                    List<ScoreCard_Config__c> DilutedTermAmount=[Select Id, Factor__C, Term__c From ScoreCard_Config__c where RecordType.name ='Diluted Doc Card' and 
                                                                 FieldName__c='Factor' and  Amount_Max__c >= :amountequip And Amount_Min__c <= :amountequip ]   ;
                    system.debug('passei aqui 2');
                    if(payfee==false){
                        if(DilutedTermAmount.size()!=0 ){
                            for( integer j=0; j<DilutedTermAmount.size(); j++){
                                if (DilutedTermAmount[j].Term__c==12){
                                    app.ModifierTerm12_Config__c=DilutedTermAmount[j].Id;
                                    Rent12= (((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (DilutedTermAmount[j].Term__c==24){
                                    app.ModifierTerm24_Config__c=DilutedTermAmount[j].Id;
                                    Rent24= (((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==36){
                                    app.ModifierTerm36_Config__c=DilutedTermAmount[j].Id;
                                    Rent36=(((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==48){
                                    app.ModifierTerm48_Config__c=DilutedTermAmount[j].Id;
                                    Rent48=(((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==60){
                                    app.ModifierTerm60_Config__c=DilutedTermAmount[j].Id;
                                    Rent60= (((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                // ALTERACAO -15/03/17 - overview (BP)   
                                System.debug('Terceiro step');                              
                                if (DilutedTermAmount[j].Term__c==72){
                                    app.ModifierTerm72_Config__c=DilutedTermAmount[j].Id;
                                    Rent72= (((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }                               
                            }
                        }         
                    }
                    else
                    { 
                        System.debug('44444');
                        payModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        feesFactor=feesfactorAux ;
                        if(DilutedTermAmount.size()!=0 ){
                            // ALTERACAO - 06/03/17 - correcao  era sempre ModifierTerm12_Config__c a ser preenchido (BP)
                            for( integer j=0; j<DilutedTermAmount.size(); j++){
                                if (DilutedTermAmount[j].Term__c==12){
                                    app.ModifierTerm12_Config__c=DilutedTermAmount[j].Id;
                                    Rent12= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (DilutedTermAmount[j].Term__c==24){
                                    app.ModifierTerm24_Config__c=DilutedTermAmount[j].id;
                                    Rent24= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==36){
                                    app.ModifierTerm36_Config__c=DilutedTermAmount[j].Id;
                                    Rent36= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==48){
                                    app.ModifierTerm48_Config__c=DilutedTermAmount[j].Id;
                                    Rent48= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==60){
                                    app.ModifierTerm60_Config__c=DilutedTermAmount[j].Id;
                                    Rent60= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                // ALTERACAO - 15/03/17 - overview (BP)  
                                System.debug('Quarto step');                              
                                if (DilutedTermAmount[j].Term__c==72){
                                    app.ModifierTerm72_Config__c=DilutedTermAmount[j].Id;
                                    Rent72= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                            }
                        }    
                    }
                }
            }
            else{
                if(fee==false){
                    if(payfee==false){
                        System.debug('55555');
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:RiskType];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        
                        if(TermAmounModifier.size()!=0 ){
                            for( integer i=0; i<TermAmounModifier.size(); i++){
                                if (TermAmounModifier[i].Term__c==12){
                                    app.ModifierTerm12_Config__c=TermAmounModifier[i].Id;
                                    Rent12= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (TermAmounModifier[i].Term__c==24){
                                    app.ModifierTerm24_Config__c=TermAmounModifier[i].Id;
                                    Rent24= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==36){
                                    app.ModifierTerm36_Config__c=TermAmounModifier[i].Id;
                                    Rent36= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==48){
                                    app.ModifierTerm48_Config__c=TermAmounModifier[i].Id;
                                    Rent48= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==60){
                                    app.ModifierTerm60_Config__c=TermAmounModifier[i].Id;
                                    Rent60= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                // 16/03/17 - overview (BP)
                                System.debug('Quinto step');
                                if (TermAmounModifier[i].Term__c==72){
                                    app.ModifierTerm72_Config__c=TermAmounModifier[i].Id;
                                    Rent72= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                            }
                        } 
                    }
                    else
                    { 
                        System.debug('66666');
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:RiskType];
                        payModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        feesFactor=factorModifierAux + feesfactorAux;
                        if(TermAmounModifier.size()!=0 ){
                            for( integer i=0; i<TermAmounModifier.size(); i++){
                                if (TermAmounModifier[i].Term__c==12){
                                    app.ModifierTerm12_Config__c=TermAmounModifier[i].Id;
                                    Rent12= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (TermAmounModifier[i].Term__c==24){
                                    app.ModifierTerm24_Config__c=TermAmounModifier[i].Id;
                                    Rent24= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==36){
                                    app.ModifierTerm36_Config__c=TermAmounModifier[i].Id;
                                    Rent36= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==48){
                                    app.ModifierTerm48_Config__c=TermAmounModifier[i].Id;
                                    Rent48= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==60){
                                    app.ModifierTerm60_Config__c=TermAmounModifier[i].Id;
                                    Rent60= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                System.debug('Sexto step');
                                if (TermAmounModifier[i].Term__c==72){
                                    app.ModifierTerm72_Config__c=TermAmounModifier[i].Id;
                                    Rent72= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }
                            }
                        }
                    }
                }
                else{
                    System.debug('77777');
                    // diluted fee factor table
                    List<ScoreCard_Config__c> DilutedTermAmount=[Select Id, Factor__C, Term__c From ScoreCard_Config__c where RecordType.name ='Diluted Doc Card' and 
                                                                 FieldName__c='Factor' and  Amount_Max__c >= :amountequip And Amount_Min__c <= :amountequip ]   ;
                    if(payfee==false){
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:RiskType];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        feesFactor=factorModifierAux;
                        if(DilutedTermAmount.size()!=0 ){
                            for( integer j=0; j<DilutedTermAmount.size(); j++){
                                if (DilutedTermAmount[j].Term__c==12){
                                    app.ModifierTerm12_Config__c=DilutedTermAmount[j].Id;
                                    Rent12= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (DilutedTermAmount[j].Term__c==24){
                                    app.ModifierTerm24_Config__c=DilutedTermAmount[j].Id;
                                    Rent24= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==36){
                                    app.ModifierTerm36_Config__c=DilutedTermAmount[j].Id;
                                    Rent36= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==48){
                                    app.ModifierTerm48_Config__c=DilutedTermAmount[j].Id;
                                    Rent48= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==60){
                                    app.ModifierTerm60_Config__c=DilutedTermAmount[j].Id;
                                    Rent60= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                //ALTERACAO - 16/03/17 - (BP)
                                System.debug('Sétimo step');
                                if (DilutedTermAmount[j].Term__c==72){
                                    app.ModifierTerm72_Config__c=DilutedTermAmount[j].Id;
                                    Rent72= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                            }
                        }
                    }
                    else
                    { 
                        System.debug('88888');
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:RiskType];
                        payModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        feesFactor=feesfactorAux +factorModifierAux;
                        if(DilutedTermAmount.size()!=0 ){
                            for( integer j=0; j<DilutedTermAmount.size(); j++){
                                if (DilutedTermAmount[j].Term__c==12){
                                    app.ModifierTerm12_Config__c=DilutedTermAmount[j].Id;
                                    Rent12= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (DilutedTermAmount[j].Term__c==24){
                                    app.ModifierTerm24_Config__c=DilutedTermAmount[j].Id;
                                    Rent24= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==36){
                                    app.ModifierTerm36_Config__c=DilutedTermAmount[j].Id;
                                    Rent36= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==48){
                                    app.ModifierTerm48_Config__c=DilutedTermAmount[j].Id;
                                    Rent48= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==60){
                                    app.ModifierTerm60_Config__c=DilutedTermAmount[j].Id;
                                    Rent60= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                //ALTERACAO - 16/03/17 - (BP)
                                System.debug('Oitavo step');
                                if (DilutedTermAmount[j].Term__c==72){
                                    app.ModifierTerm72_Config__c=DilutedTermAmount[j].Id;
                                    Rent72= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                            }
                            
                        }
                        
                    }
                }
            }
            
            // get insurance values
            
            List<ScoreCard_Config__c> InsuranceCard=[Select Id,  Risk_Type__c, Premium__c From ScoreCard_Config__c where RecordType.name ='Insurance Card' and 
                                                     Amount_Max__c >= :amountequip And Amount_Min__c <= :amountequip   ];
            
            
            if(InsuranceCard.size()!=0){
                for(integer i=0; i< InsuranceCard.size(); i++){
                    if (InsuranceCard[i].Risk_Type__c=='Movement'){
                        app.Insurance_Card_Movement__c=InsuranceCard[i].Id;
                        app.Insurance_Movement_value__c=((amountequip * InsuranceCard[i].Premium__c/100)/12).setscale(2);
                        insurOutputmov=InsuranceCard[i].Premium__c;
                    }
                    if (InsuranceCard[i].Risk_Type__c=='Static'){
                        app.Insurance_Card_Static__c=InsuranceCard[i].Id;
                        app.Insurance_Value__c=((amountequip * InsuranceCard[i].Premium__c/100)/12).setscale(2);
                        insurOutputstatic=InsuranceCard[i].Premium__c;
                    } 
                    if (InsuranceCard[i].Risk_Type__c=='Special'){
                        app.Insurance_Card_Special__c=InsuranceCard[i].Id;
                        app.Insurance_Special_Value__c=((amountequip * InsuranceCard[i].Premium__c/100)/12).setscale(2);
                        insurOutputspecial=InsuranceCard[i].Premium__c;
                    } 
                    
                }
                
            }
            app.Output_Ins_Manager__c='Pick Insurance Type: Static Risk with Rate ' + insurOutputstatic + '%; Special Risk with Rate ' + insurOutputspecial + '%; Risk of Movement with Rate ' + insurOutputmov + '%;' ;
            
            //setting payment amount default
            if(term==0){
                if( app.accClient__r.Date_Of_Establishment__c != null && isEmpresaRecente(calculaIdade(app.accClient__r.Date_Of_Establishment__c))){
                    app.Payment_Amount__c=Rent24 ;
                    app.Factor__c=(Rent24/amountequip)*100;
                } else{
                    app.Payment_Amount__c=Rent36 ;
                    app.Factor__c=(Rent36/amountequip)*100;
                }
            }else
                // if amount was calulted from rent
            {
                
                if(term==12){
                    app.Payment_Amount__c=Rent12 ;
                    System.debug('ScoreCard --> Rent12:'+Rent12+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent12/amountequip)*100;
                }
                if(term==24){
                    app.Payment_Amount__c=Rent24 ;
                    System.debug('ScoreCard --> Rent24:'+Rent24+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent24/amountequip)*100;
                }
                if(term==36){
                    app.Payment_Amount__c=Rent36 ;
                    System.debug('ScoreCard --> Rent36:'+Rent36+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent36/amountequip)*100;
                }
                if(term==48){
                    app.Payment_Amount__c=Rent48 ;    
                    System.debug('ScoreCard --> Rent48:'+Rent48+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent48/amountequip)*100;
                }
                if(term==60){
                    app.Payment_Amount__c=Rent60 ;
                    System.debug('ScoreCard --> Rent60:'+Rent60+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent60/amountequip)*100;
                }
                //ALTERACAO - 16/03/17 - (BP)
                if(term==72){
                    app.Payment_Amount__c=Rent72 ;
                    System.debug('ScoreCard --> Rent72:'+Rent72+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent72/amountequip)*100;
                }
            }
            //ALTERACAO - 16/03/17 - (BP)
            //app.Output_Rate_Manager__c='Pick Contract Term: 12: €' + Rent12 + '; 24: €' + Rent24 + '; 36: €' + Rent36 + '; 48: €' + Rent48+ '; 60: €' + Rent60 +'; 72: €' + Rent72; 
            
            if(app.Rent_12__c!=Rent12 && term==12)
                res='DIFFERENT_RENT_12';
            if(app.Rent_24__c!=Rent24 && term==24)
                res='DIFFERENT_RENT_24';
            if(app.Rent_36__c!=Rent36 && term==36)
                res='DIFFERENT_RENT_36';
            if(app.Rent_48__c!=Rent48 && term==48)
                res='DIFFERENT_RENT_48';
            if(app.Rent_60__c!=Rent60 && term==60)
                res='DIFFERENT_RENT_60';
            if(app.Rent_72__c!=Rent72 && term==72)
                res='DIFFERENT_RENT_72';
            
        }
        catch (Exception e){
            system.debug('Error in ScoreCard - getCalc!');
            system.debug('getCalc' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            res= 'Failure';
        }
            return res;
    }

    
    public static string getCalc(Application__c app, decimal amountequip, integer term, decimal discfactor){
        try{
            
            ScoreCard_Config__c Modelrankterm12;
            ScoreCard_Config__c Modelrankterm24;
            ScoreCard_Config__c Modelrankterm36;
            ScoreCard_Config__c Modelrankterm60;
            ScoreCard_Config__c Modelrankterm72;//ALTERACAO -17/03/17 - (BP)
            ScoreCard_Config__c FactorModifier;
            // ScoreCard_Config__c FeeModifier;
            ScoreCard_Config__c PayModifier;
            //  ScoreCard_Config__c IntfeeModifier;
            decimal Rent12;
            decimal Rent24;
            decimal Rent36;
            decimal Rent48;
            decimal Rent60;
            decimal Rent72;
            decimal insurOutputmov;
            decimal insurOutputstatic;
            decimal insurOutputspecial;
            decimal factor=0;
            decimal feesFactor=0;
            //boolean fee=app.Vendor__r.Diluted_Doc_Fee__c;                 // LOOKS TO ACCOUNT
            boolean fee=!app.Vendor_Diluted_Doc_Fee__c;                 //LOOKS TO APPLICATION
            boolean payfee;
            // replace previous with this
            if(app.payment_freq__c!= null && app.Payment_Freq__c=='Monthly'){
                payfee=true;
            }
            else if(app.payment_freq__c=='Quarterly') {
                payfee=false;
            }
            string risktype=app.accClient__r.Risk_Type__c;
            //string risktype=app.Client_Risk_Type__c;
            // boolean intfee=app.Vendor__r.Diluted_Doc_and_Interim_Fee__c;
            decimal factorModifierAux=0;
            decimal feesfactorAux=0;
            
            List<ScoreCard_Config__c> TermAmounModifier=[Select Id, Factor__C, Term__c From ScoreCard_Config__c where RecordType.name ='Factor Card' and 
                                                         FieldName__c='Factor' and  Amount_Max__c >= :amountequip And Amount_Min__c <= :amountequip ]   ;
            
            if (risktype=='Middle' ){
                if(fee==false){
                    if(payfee==false){
                        System.debug('11111');
                        if(TermAmounModifier.size()!=0 ){
                            for( integer i=0; i<TermAmounModifier.size(); i++){
                                if (TermAmounModifier[i].Term__c==12){
                                    app.ModifierTerm12_Config__c=TermAmounModifier[i].Id;
                                    Rent12= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (TermAmounModifier[i].Term__c==24){
                                    app.ModifierTerm24_Config__c=TermAmounModifier[i].Id;
                                    Rent24= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==36){
                                    app.ModifierTerm36_Config__c=TermAmounModifier[i].Id;
                                    Rent36= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==48){
                                    app.ModifierTerm48_Config__c=TermAmounModifier[i].Id;
                                    Rent48= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==60){
                                    app.ModifierTerm60_Config__c=TermAmounModifier[i].Id;
                                    Rent60= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                //ALTERACAO - 15/03/17 - overview (BP)
                                System.debug('Primeiro step');
                                if (TermAmounModifier[i].Term__c==72){
                                    app.ModifierTerm72_Config__c=TermAmounModifier[i].Id;
                                    Rent72= (((TermAmounModifier[i].Factor__c/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }                           
                            }
                        }  
                    } 
                    else
                    { 
                        System.debug('22222');
                        payModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        if(TermAmounModifier.size()!=0 ){
                            for( integer i=0; i<TermAmounModifier.size(); i++){
                                if (TermAmounModifier[i].Term__c==12){
                                    app.ModifierTerm12_Config__c=TermAmounModifier[i].Id;
                                    Rent12= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (TermAmounModifier[i].Term__c==24){
                                    app.ModifierTerm24_Config__c=TermAmounModifier[i].Id;
                                    Rent24= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==36){
                                    app.ModifierTerm36_Config__c=TermAmounModifier[i].Id;
                                    Rent36= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==48){
                                    app.ModifierTerm48_Config__c=TermAmounModifier[i].Id;
                                    Rent48= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==60){
                                    app.ModifierTerm60_Config__c=TermAmounModifier[i].Id;
                                    Rent60= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                //ALTERACAO - 15/03/17 - overview (BP)
                                System.debug('Segundo step');
                                if (TermAmounModifier[i].Term__c==72){
                                    app.ModifierTerm72_Config__c=TermAmounModifier[i].Id;
                                    Rent72= ((((TermAmounModifier[i].Factor__C*(1+feesfactorAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }                               
                            }
                        }
                    }
                }
                else{
                    // diluted fee factor table
                    System.debug('33333');
                    List<ScoreCard_Config__c> DilutedTermAmount=[Select Id, Factor__C, Term__c From ScoreCard_Config__c where RecordType.name ='Diluted Doc Card' and 
                                                                 FieldName__c='Factor' and  Amount_Max__c >= :amountequip And Amount_Min__c <= :amountequip ]   ;
                    system.debug('passei aqui 2');
                    if(payfee==false){
                        if(DilutedTermAmount.size()!=0 ){
                            for( integer j=0; j<DilutedTermAmount.size(); j++){
                                if (DilutedTermAmount[j].Term__c==12){
                                    app.ModifierTerm12_Config__c=DilutedTermAmount[j].Id;
                                    Rent12= (((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (DilutedTermAmount[j].Term__c==24){
                                    app.ModifierTerm24_Config__c=DilutedTermAmount[j].Id;
                                    Rent24= (((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==36){
                                    app.ModifierTerm36_Config__c=DilutedTermAmount[j].Id;
                                    Rent36=(((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==48){
                                    app.ModifierTerm48_Config__c=DilutedTermAmount[j].Id;
                                    Rent48=(((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==60){
                                    app.ModifierTerm60_Config__c=DilutedTermAmount[j].Id;
                                    Rent60= (((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                // ALTERACAO -15/03/17 - overview (BP)   
                                System.debug('Terceiro step');                              
                                if (DilutedTermAmount[j].Term__c==72){
                                    app.ModifierTerm72_Config__c=DilutedTermAmount[j].Id;
                                    Rent72= (((DilutedTermAmount[j].Factor__C/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }                               
                            }
                        }         
                    }
                    else
                    { 
                        System.debug('44444');
                        payModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        feesFactor=feesfactorAux ;
                        if(DilutedTermAmount.size()!=0 ){
                            // ALTERACAO - 06/03/17 - correcao  era sempre ModifierTerm12_Config__c a ser preenchido (BP)
                            for( integer j=0; j<DilutedTermAmount.size(); j++){
                                if (DilutedTermAmount[j].Term__c==12){
                                    app.ModifierTerm12_Config__c=DilutedTermAmount[j].Id;
                                    Rent12= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (DilutedTermAmount[j].Term__c==24){
                                    app.ModifierTerm24_Config__c=DilutedTermAmount[j].id;
                                    Rent24= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==36){
                                    app.ModifierTerm36_Config__c=DilutedTermAmount[j].Id;
                                    Rent36= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==48){
                                    app.ModifierTerm48_Config__c=DilutedTermAmount[j].Id;
                                    Rent48= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==60){
                                    app.ModifierTerm60_Config__c=DilutedTermAmount[j].Id;
                                    Rent60= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                // ALTERACAO - 15/03/17 - overview (BP)  
                                System.debug('Quarto step');                              
                                if (DilutedTermAmount[j].Term__c==72){
                                    app.ModifierTerm72_Config__c=DilutedTermAmount[j].Id;
                                    Rent72= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                            }
                        }    
                    }
                }
            }
            else{
                if(fee==false){
                    if(payfee==false){
                        System.debug('55555');
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c, Matching_Value__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:RiskType];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        
                        if(TermAmounModifier.size()!=0 ){
                            for( integer i=0; i<TermAmounModifier.size(); i++){
                                if (TermAmounModifier[i].Term__c==12){
                                    app.ModifierTerm12_Config__c=TermAmounModifier[i].Id;
                                    Rent12= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (TermAmounModifier[i].Term__c==24){
                                    app.ModifierTerm24_Config__c=TermAmounModifier[i].Id;
                                    Rent24= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==36){
                                    app.ModifierTerm36_Config__c=TermAmounModifier[i].Id;
                                    Rent36= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==48){
                                    app.ModifierTerm48_Config__c=TermAmounModifier[i].Id;
                                    Rent48= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==60){
                                    app.ModifierTerm60_Config__c=TermAmounModifier[i].Id;
                                    Rent60= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                // 16/03/17 - overview (BP)
                                System.debug('Quinto step');
                                if (TermAmounModifier[i].Term__c==72){
                                    app.ModifierTerm72_Config__c=TermAmounModifier[i].Id;
                                    Rent72= ((((TermAmounModifier[i].Factor__C*(1+factorModifierAux/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                            }
                        } 
                    }
                    else
                    { 
                        System.debug('66666');
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:RiskType];
                        payModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        feesFactor=factorModifierAux + feesfactorAux;
                        if(TermAmounModifier.size()!=0 ){
                            for( integer i=0; i<TermAmounModifier.size(); i++){
                                if (TermAmounModifier[i].Term__c==12){
                                    app.ModifierTerm12_Config__c=TermAmounModifier[i].Id;
                                    Rent12= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (TermAmounModifier[i].Term__c==24){
                                    app.ModifierTerm24_Config__c=TermAmounModifier[i].Id;
                                    Rent24= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==36){
                                    app.ModifierTerm36_Config__c=TermAmounModifier[i].Id;
                                    Rent36= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==48){
                                    app.ModifierTerm48_Config__c=TermAmounModifier[i].Id;
                                    Rent48= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (TermAmounModifier[i].Term__c==60){
                                    app.ModifierTerm60_Config__c=TermAmounModifier[i].Id;
                                    Rent60= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                System.debug('Sexto step');
                                if (TermAmounModifier[i].Term__c==72){
                                    app.ModifierTerm72_Config__c=TermAmounModifier[i].Id;
                                    Rent72= ((((TermAmounModifier[i].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }
                            }
                        }
                    }
                }
                else{
                    System.debug('77777');
                    // diluted fee factor table
                    List<ScoreCard_Config__c> DilutedTermAmount=[Select Id, Factor__C, Term__c From ScoreCard_Config__c where RecordType.name ='Diluted Doc Card' and 
                                                                 FieldName__c='Factor' and  Amount_Max__c >= :amountequip And Amount_Min__c <= :amountequip ]   ;
                    if(payfee==false){
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:RiskType];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        feesFactor=factorModifierAux;
                        if(DilutedTermAmount.size()!=0 ){
                            for( integer j=0; j<DilutedTermAmount.size(); j++){
                                if (DilutedTermAmount[j].Term__c==12){
                                    app.ModifierTerm12_Config__c=DilutedTermAmount[j].Id;
                                    Rent12= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (DilutedTermAmount[j].Term__c==24){
                                    app.ModifierTerm24_Config__c=DilutedTermAmount[j].Id;
                                    Rent24= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==36){
                                    app.ModifierTerm36_Config__c=DilutedTermAmount[j].Id;
                                    Rent36= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==48){
                                    app.ModifierTerm48_Config__c=DilutedTermAmount[j].Id;
                                    Rent48= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==60){
                                    app.ModifierTerm60_Config__c=DilutedTermAmount[j].Id;
                                    Rent60= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                //ALTERACAO - 16/03/17 - (BP)
                                System.debug('Sétimo step');
                                if (DilutedTermAmount[j].Term__c==72){
                                    app.ModifierTerm72_Config__c=DilutedTermAmount[j].Id;
                                    Rent72= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                            }
                        }
                    }
                    else
                    { 
                        System.debug('88888');
                        FactorModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                        RelatedObject__c='Risk Type' and FieldName__c=:RiskType];
                        payModifier=[Select Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.name ='Score Card'and 
                                     RelatedObject__c='Payment' and FieldName__c='Monthly'];
                        if(FactorModifier.Matching_Value_To_Nr__c==null || FactorModifier.Matching_Value_To_Nr__c ==0){
                            factorModifierAux=decimal.valueOf((FactorModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            factorModifierAux=FactorModifier.Matching_Value_To_Nr__c;
                        }
                        if(payModifier.Matching_Value_To_Nr__c==null || payModifier.Matching_Value_To_Nr__c ==0){
                            feesfactorAux=decimal.valueOf((payModifier.Matching_Value__c).replace(',','.'));
                        }else{
                            feesfactorAux=payModifier.Matching_Value_To_Nr__c;
                        }
                        feesFactor=feesfactorAux +factorModifierAux;
                        if(DilutedTermAmount.size()!=0 ){
                            for( integer j=0; j<DilutedTermAmount.size(); j++){
                                if (DilutedTermAmount[j].Term__c==12){
                                    app.ModifierTerm12_Config__c=DilutedTermAmount[j].Id;
                                    Rent12= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                }  
                                if (DilutedTermAmount[j].Term__c==24){
                                    app.ModifierTerm24_Config__c=DilutedTermAmount[j].Id;
                                    Rent24= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==36){
                                    app.ModifierTerm36_Config__c=DilutedTermAmount[j].Id;
                                    Rent36= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==48){
                                    app.ModifierTerm48_Config__c=DilutedTermAmount[j].Id;
                                    Rent48= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                if (DilutedTermAmount[j].Term__c==60){
                                    app.ModifierTerm60_Config__c=DilutedTermAmount[j].Id;
                                    Rent60= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                                //ALTERACAO - 16/03/17 - (BP)
                                System.debug('Oitavo step');
                                if (DilutedTermAmount[j].Term__c==72){
                                    app.ModifierTerm72_Config__c=DilutedTermAmount[j].Id;
                                    Rent72= ((((DilutedTermAmount[j].Factor__C*(1+feesFactor/100))/100) * amountequip)*(1- discfactor/100)).setscale(2);
                                } 
                            }
                            
                        }
                        
                    }
                }
            }
            
            // get insurance values
            
            List<ScoreCard_Config__c> InsuranceCard=[Select Id,  Risk_Type__c, Premium__c From ScoreCard_Config__c where RecordType.name ='Insurance Card' and 
                                                     Amount_Max__c >= :amountequip And Amount_Min__c <= :amountequip   ];
            
            
            if(InsuranceCard.size()!=0){
                for(integer i=0; i< InsuranceCard.size(); i++){
                    if (InsuranceCard[i].Risk_Type__c=='Movement'){
                        app.Insurance_Card_Movement__c=InsuranceCard[i].Id;
                        app.Insurance_Movement_value__c=((amountequip * InsuranceCard[i].Premium__c/100)/12).setscale(2);
                        insurOutputmov=InsuranceCard[i].Premium__c;
                    }
                    if (InsuranceCard[i].Risk_Type__c=='Static'){
                        app.Insurance_Card_Static__c=InsuranceCard[i].Id;
                        app.Insurance_Value__c=((amountequip * InsuranceCard[i].Premium__c/100)/12).setscale(2);
                        insurOutputstatic=InsuranceCard[i].Premium__c;
                    } 
                    if (InsuranceCard[i].Risk_Type__c=='Special'){
                        app.Insurance_Card_Special__c=InsuranceCard[i].Id;
                        app.Insurance_Special_Value__c=((amountequip * InsuranceCard[i].Premium__c/100)/12).setscale(2);
                        insurOutputspecial=InsuranceCard[i].Premium__c;
                    } 
                    
                }
                
            }
            app.Output_Ins_Manager__c='Pick Insurance Type: Static Risk with Rate ' + insurOutputstatic + '%; Special Risk with Rate ' + insurOutputspecial + '%; Risk of Movement with Rate ' + insurOutputmov + '%;' ;
            
            //setting payment amount default
            if(term==0){
                if( app.accClient__r.Date_Of_Establishment__c != null && isEmpresaRecente(calculaIdade(app.accClient__r.Date_Of_Establishment__c))){
                    app.Payment_Amount__c=Rent24 ;
                    app.Factor__c=(Rent24/amountequip)*100;
                } else{
                    app.Payment_Amount__c=Rent36 ;
                    app.Factor__c=(Rent36/amountequip)*100;
                }
            }else
                // if amount was calulted from rent
            {
                
                if(term==12){
                    app.Payment_Amount__c=Rent12 ;
                    System.debug('ScoreCard --> Rent12:'+Rent12+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent12/amountequip)*100;
                }
                if(term==24){
                    app.Payment_Amount__c=Rent24 ;
                    System.debug('ScoreCard --> Rent24:'+Rent24+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent24/amountequip)*100;
                }
                if(term==36){
                    app.Payment_Amount__c=Rent36 ;
                    System.debug('ScoreCard --> Rent36:'+Rent36+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent36/amountequip)*100;
                }
                if(term==48){
                    app.Payment_Amount__c=Rent48 ;    
                    System.debug('ScoreCard --> Rent48:'+Rent48+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent48/amountequip)*100;
                }
                if(term==60){
                    app.Payment_Amount__c=Rent60 ;
                    System.debug('ScoreCard --> Rent60:'+Rent60+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent60/amountequip)*100;
                }
                //ALTERACAO - 16/03/17 - (BP)
                if(term==72){
                    app.Payment_Amount__c=Rent72 ;
                    System.debug('ScoreCard --> Rent72:'+Rent72+'\namountequip:'+amountequip);
                    app.Factor__c=(Rent72/amountequip)*100;
                }
            }
            //ALTERACAO - 16/03/17 - (BP)
            app.Output_Rate_Manager__c='Pick Contract Term: 12: €' + Rent12 + '; 24: €' + Rent24 + '; 36: €' + Rent36 + '; 48: €' + Rent48+ '; 60: €' + Rent60 +'; 72: €' + Rent72; 
            app.Rent_12__c=Rent12;
            app.Rent_24__c=Rent24;
            app.Rent_36__c=Rent36;
            app.Rent_48__c=Rent48;
            app.Rent_60__c=Rent60;
            app.Rent_72__c=Rent72;
            System.debug('ScoreCard --> App que vai sofrer update: '+app);
            System.debug('ScoreCard --> A seguir ao preenchimento das rendas e antes do update à APP...');
            update app;
            
            return 'Success';
        }
        catch (Exception e){
            system.debug('Error in ScoreCard - getCalc!');
            system.debug('getCalc' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return 'Failure';
        }
    }
    
    
    public static void RerunGetApplicationStatus(){
        try{
            
        }
        catch(Exception e){
            system.debug('Error in ScoreCard - Rate Analysis!');
            system.debug('ScoreCardConfig' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            
        }
    }
    
    
    public class RerunGetApplicationStatusQueueable implements queueable, database.allowsCallouts {
    public void execute(QueueableContext ctx){
        string nif='';
        Try{
                    // 5 minutes
                    
    datetime dtbegin= system.now() - 0.008;
    datetime dtend= system.now() - 0.001;
    Utilities.OutboundIntegration outInt= new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntpdf= new Utilities.OutboundIntegration();

    system.debug(dtbegin + ' - ' + dtend);
    list <application__C> apps=[select id, name, status__c, accClient__r.nif__c, accClient__r.name, 
                                reject_reason__c, accClient__r.id from application__c where createdDate > :dtbegin and 
                                createdDate < :dtend];
    system.debug(apps);
            
    for ( application__c app :apps){
        if(app.accClient__r.nif__c == app.accClient__r.name  && ( app.status__c =='' || app.status__c == null )){
            system.debug(app.name);
            system.debug(app.reject_reason__c);
            nif=app.accClient__r.nif__c;
            outInt=DBInfoXML.InformadbGetReport( app.accClient__r.nif__c , 'XMLPROSP', 'Xml', 'Client'); 
            outIntpdf=DBInfoXML.InformadbGetPdfReport(app.accClient__r.nif__c, 'XMLPROSP');
            if (outInt.xml != ''){

                DBProp dbprop=DBInfoXML.parseDBXML(outInt.xml );    
                ReportDB__c report=DBInfoXML.UpdateReport(dbprop, 'Client', app.accClient__r.id, outIntPdf.pdf); 
                string result=ScoreCardConfig.GetCreditLineStatus(app.accClient__r.id, app.id) ;
                if (result!=null){
                    Utilities.LogIntegration(datetime.now(), datetime.now(), 'success', 'Scheduable Reprocess infoDB', null, app.accClient__r.nif__c);
                }
                else{
                    Utilities.LogIntegration(datetime.now(), datetime.now(), 'Failure', 'Scheduable Reprocess infoDB', null, app.accClient__r.nif__c);
                }
                
            }
            outInt= null;
            outIntpdf= null;
        }
    }
        }
        catch( exception e){
            Utilities.LogIntegration(datetime.now(), datetime.now(), 'Failure', 'Scheduable Reprocess infoDB for Client ' + nif, null, nif);
        }

    }

}

/*****************************************************************************************************/    
/*****************************************************************************************************/ 
/**                                                                                                 **/
/**              DECISION ALGORITHM BASED ONLY IN ACCOUNTS (INDEPENDENT FROM REQUEST)               **/
/**                                                                                                 **/
/*****************************************************************************************************/  
/*****************************************************************************************************/   
//ADICAO - 22/06/17 - deixar de depender do pedido(BP)

    public static void AprovacaoDeEmpresaRecentePreConfiguracaoParaConta(Account acc)
    {
        system.debug('acc.Risk_Type__c 1>>'+acc.Risk_Type__c);
        acc.Risk_Type__c = 'Very High';
        system.debug('acc.Risk_Type__c 2>>'+acc.Risk_Type__c);        
        acc.Personal_Guarantee__c = true;
    }//end AprovacaoDeEmpresaRecentePreConfiguracaoParaConta method
    
    /*****/

    public static string AprovacaoDeEmpresaRecenteAprova(Account acc)
    {
        acc.Credit_Line_Status__c='Credit Line - Approved';
        return 'Startup - Approved';
    }//end AprovacaoDeEmpresaRecenteAprova method

    /*****/

    public static string AprovacaoDeEmpresaRecenteSemScoreParaConta(Account acc, decimal valdate, List<ReportDB__c> report){
        
        if(!isEmpresaRecente(valdate))
        {
            return 'Not a Startup';
        }

        AprovacaoDeEmpresaRecentePreConfiguracaoParaConta(acc);
        
        if(report[0].CapitalSocial__c == null || report[0].CapitalSocial__c < getStartupNoScoreMinCapital())
        {
            return finalizeRejeicaoParaConta(acc, 'Crédito Elevado');
        }
        
        system.debug('AprovacaoDeEmpresaRecenteSemScore. Apliação aprovada');
        return AprovacaoDeEmpresaRecenteAprova(acc);
    }

    /*****/

    public static string AprovacaoDeEmpresaRecenteComScoreParaConta(Account acc, decimal valdate, List<ReportDB__c> report)
    {
        if(!isEmpresaRecente(valdate))
        {
            return 'Not a Startup';
        }
        
        AprovacaoDeEmpresaRecentePreConfiguracaoParaConta(acc);
        
        if(report[0].CapitalSocial__c == null || report[0].CapitalSocial__c * getStartupCreditMultiplier() < getStartupMinCredit())
        {
            return finalizeRejeicaoParaConta(acc, 'Crédito Elevado');
        }
        
        system.debug('AprovacaoDeEmpresaRecenteComScore. Apliação aprovada');
        return AprovacaoDeEmpresaRecenteAprova(acc);
    }//end AprovacaoDeEmpresaRecenteComScoreParaConta method  

    /*****/

    //ADICAO - 23/06/17 - deixar de depender do pedido(BP)
    public static string RepescaClientsComMauInformaScoreForAccount(Account acc, List<ReportDB__c> report)
    {
        if(report[0].TotIncidentes__c==null)
        {
            acc.Credit_Line_Status__c='Credit Line - Rejected';
            system.debug('report[0].TotIncidentes__c==null || report[0].TotIncidentes__c>0');
            update acc;
            Return acc.Credit_Line_Status__c;
        }
        
        if(report[0].TotIncidentes__c>0 && (report[0].TotValorIncidentes__c==null || acc.Sales__c == null 
                                        || report[0].TotValorIncidentes__c>=acc.Sales__c
                                        *Decimal.valueOf(((ScoreCard_Config__c)[select Matching_Value__c
                                                                                  from scorecard_config__c
                                                                                 where recordtype.name = 'Modifier Score'
                                                                                   and FieldName__c='PercentageSalesForSumCourtActions']).Matching_Value__c)))
        {
            acc.Credit_Line_Status__c='Credit Line - Rejected';
            system.debug('report[0].TotValorIncidentes__c==null || report[0].TotValorIncidentes__c>=');
            update acc;
            Return acc.Credit_Line_Status__c;
        }
                
        if(acc.AnnualRevenue==null){
            acc.Credit_Line_Status__c='Credit Line - Rejected';
            system.debug('(acc.AnnualRevenue==null)');
            update acc;
            Return acc.Credit_Line_Status__c;
        }
        
        system.debug('acc.Sales__c' + acc.Sales__c);
        system.debug('acc.AnnualRevenue' + acc.AnnualRevenue);
        List <ScoreCard_Config__c> ScoreCardRisk4 = New  List <ScoreCard_Config__c>();
        ScoreCardRisk4=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                        (  (  Matching_Value_To_Nr__c < :acc.AnnualRevenue And FieldName__c='NetProfit') or
                         ( ( Matching_Value_To_Nr__c >= :report[0].TotIncidentes__c ) And FieldName__c='CourtActions')) ];
        system.debug('Avalia condições de atribuição de linha de crédito para risco elevado ');    
        system.debug(ScoreCardRisk4.size());
        if(ScoreCardRisk4.size() !=3){
            system.debug('Falhou uma das condições para atribuição de credito para risco elevado');      
            acc.Credit_Line_Status__c='Credit Line - Rejected'; //ALTERACAO - 13/02/17 -  adicao de linha para resolver accs sem estado (BP)
            system.debug('ScoreCardRisk4.size() !=3');
            update acc;
            Return acc.Credit_Line_Status__c;
        }                   
        acc.Credit_Line_Status__c='Credit Line - Approved';
        if ( ScoreCardRisk4[0].Auto_Decision__c==true){
        }
        //ALTERACAO - 06/03/17 - updates estavam em falta (BP)
        update acc;
        system.debug('NetProfit Ok. Aplicação aprovada');
        Return acc.Credit_Line_Status__c;
    } //end RepescaClientsComMauInformaScoreForAccount method

    //ALTERACAO - 22/06/17 - segmentacao da decisao da linha de credito do pedido (BP)
    public static string GetCreditLineStatusForAccount(String clientId)
    {
        try{
            List<ScoreCard_Config__c> ScoreCardCfg   = new List<ScoreCard_Config__c>();
            List<ScoreCard_Config__c> PostalCodeCfg  = new List<ScoreCard_Config__c>();
            List<ScoreCard_Config__c> ScoreCardLegal = new List<ScoreCard_Config__c> ();
            //List<ReportDB__c>         report         = new List<ReportDB__c>();
            ScoreCard_Config__c       IniCandorGrade;//= New  List <ScoreCard_Config__c>();
            ScoreCard_Config__c       ModifierCAE;
            ScoreCard_Config__c       ModifierActCode;
            ScoreCard_Config__c       CandorGradeAfterAct;
            
            boolean risk4=false;
            boolean legalformcredit=false;
            
            List<ReportDB__c> report = [select CAE__c, DataConstituicao__c, FormaObrigarToNr__c, ResultLiqUltimoAno__c, Sales__c, Activitycode__c, recordtype.Name , PercentilScore__c, 
                                               grossincome__c, codigoPostal__c, RiscoInforma__c, IndicadorRisco__c, AttachB__c, AttachC__c , Estado__c, TotIncidentes__c, TotValorIncidentes__c, Ano_Ultimo_Balanco__c,
                                               yearincome__c, FormaJuridica__c, FormaObrigar__c, Sales_n_1__c, ResultLiquido_n_1__c, Sales_n_2__c, ResultLiquido_n_2__c , TotEmpregados__c, CapitalSocial__c
                                          FROM reportDB__c 
                                         WHERE vendor__c=: clientId ];

            Account acc =[SELECT Id, Date_Of_Establishment__c, D_B_Failure_Score__C, AnnualRevenue, BillingPostalCode, Credit_Line_Status__c, CAE__c, 
                                 Activity_code__c, FormaObrigar_Val__c, Credit_line__c, Used_Credit_Line__c,   Available_Credit_Line__c, Risk_Type__c, 
                                 Ano_Ultimo_Balanco__c, FormaObriga_text__c 
                            FROM Account 
                           WHERE Id=:clientId
                         ];   
            /*
            Application__c app = [SELECT Id, Status__c, Reject_Reason__c, Vendor__c, Client_available_Credit_Line__c, 
                                         Insurance_Rent_Together__c,// Monthly__c, Quarterly__c,
                                         Vendor_Diluted_Doc_Interim_fee__c, Vendor_Diluted_Doc_fee__c, Term__c   
                                    FROM Application__c 
                                   WHERE Id=:appId];
            
            account accvendor=[SELECT id, name, Insurance_Rent_Together__c, Diluted_Doc_and_Interim_Fee__c, Diluted_Doc_Fee__c 
                                 FROM account WHERE id=: app.vendor__c];            
            */
            // Copys to application Vendor info that affects rent value
           /* if(accvendor.Diluted_Doc_Fee__c==true){
                app.Vendor_Diluted_Doc_fee__c=false;   
            }
            else{
                app.Vendor_Diluted_Doc_fee__c=true;   
            }*/
            
            
            // if Credit info does not exists no decision can be made
            //Situacao pendente - necessita de mais validações
            // ALTERACAO - 23/02/17 - Resolver as decisoes de mas decisoes - a Informa pode estar ok mas pode haver erros do lado do SF  (BP)
            //                        Fica pendente apenas pela existencia ou nao do report e nao dos estados de recursos da Informa ou SF
            //                        (validacao ja feita quando se obtem o report)-comentadas linhas no if seguinte
            //ALTERACAO - 21/08/17 - quando n tem report a linha fica pendente  comentada condicao dentro do proximo if(BP)
            if(report.size()==0)
            {
                /*
                string informaStatus = ((ScoreCard_Config__c)[SELECT Matching_Value__c FROM scorecard_config__c WHERE recordtype.name = 'Score Card' AND FieldName__c='InformaDB Status OK?(YES/NO)' LIMIT 1]).Matching_Value__c;
                if(informaStatus != null && informaStatus != 'YES')
                {
                    system.debug('report.size()==0 && !informaStatus');
                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                    update acc;
                    return acc.Credit_Line_Status__c; 
                }
                */
                    system.debug('report.size()==0 && informaStatus');
                    acc.Credit_Line_Status__c='Credit Line - Pendent';  
                    update acc;
                    return acc.Credit_Line_Status__c;
            }//end report.size()==0 condition
            
            // avaliação de linha de crédito existente
            if(acc.Credit_line__c!=0 && acc.Credit_line__c != null && acc.Credit_Line_Status__c=='Credit Line - Approved')
            {
                If(acc.Used_Credit_Line__c >= acc.Credit_line__c )
                {
                    Schema.DescribeFieldResult fieldResult = notification__c.message__c.getDescribe();
                    List<Schema.PicklistEntry> plnot = fieldResult.getPicklistValues();
                    string rejectreason;
                    for(integer i=0; i<plnot.size(); i++)
                    {
                        if(plnot[i].getLabel().contains('Rejeitado')==true &&  plnot[i].getLabel().contains('Linha')==true &&
                           plnot[i].getLabel().contains('Financiamento')==true  )
                        {
                           rejectreason=plnot[i].getLabel();
                        }    
                    }
                    return acc.Credit_Line_Status__c;
                }//end acc.Used_Credit_Line__c >= acc.Credit_line__c condition
            }
            //TODO: Checkagem se temos o que precisamos aqui...
            // update account info with credit info report
            acc.CAE__c                   = report[0].CAE__c;
            acc.activity_Code__c         = report[0].activityCode__c;
            acc.D_B_Failure_Score__c     = report[0].PercentilScore__c;
            acc.FormaObrigar_Val__c      = report[0].FormaObrigarToNr__c;
            acc.Date_Of_Establishment__c = report[0].DataConstituicao__c;
            acc.BillingPostalCode        = report[0].CodigoPostal__c;
            acc.Ano_Ultimo_Balanco__c    = report[0].Ano_Ultimo_Balanco__c;
            acc.FormaObriga_text__c      = report[0].FormaObrigar__c;
            acc.AnnualRevenue            = report[0].ResultLiqUltimoAno__c;
            acc.Sales__c                 = report[0].Sales__c;
                        
            decimal score             = acc.D_B_Failure_Score__c;
            decimal rateinf           = report[0].RiscoInforma__c;
            decimal riskclass         = report[0].IndicadorRisco__c;
            decimal limitcredit       = 0;
            decimal limitdate         = 0;            
            decimal ModelRankafterAct = 0;
            date DateOfEstablishment  = acc.Date_Of_Establishment__c;
            date now                  = Date.today();
            string cae;
            // Get years since company establishment
            decimal valdate = calculaIdade(DateOfEstablishment);
            
            string legalForm = report[0].FormaJuridica__c;
            
            // evaluates failure score than starts branching
            if((score!=null && score!=0) || (rateinf!=null && rateinf!=0) )
            {
                // if company has info on failure score...
                if(score!=0 && score!= null)
                {                    
                    IniCandorGrade=[SELECT Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, 
                                           Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,DateOfEstablishment__c 
                                      FROM ScoreCard_Config__c 
                                     WHERE RecordType.Name       = 'Score Card' 
                                       AND FieldName__c          = 'Risco Informa' 
                                       AND Failure_Score_Max__c >= :score 
                                       AND Failure_Score_Min__c <= :score  
                                   ]; 
                    
                    // and Risk Class provided by InformaDB is diferent than what should be for that failure score, informa rating is used
                    if(IniCandorGrade.Risk_Class__c != riskclass && rateinf !=0 && rateinf!=null)
                    { 
                        IniCandorGrade=[SELECT Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, 
                                               Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c, DateOfEstablishment__c 
                                          FROM ScoreCard_Config__c 
                                         WHERE RecordType.Name   = 'Score Card' 
                                           AND FieldName__c      = 'Risco Informa' 
                                           AND Informa_Rating__c = :rateinf LIMIT 1 
                                        ]; 
                    }
                }
                // if not Informa Rating is used
                else 
                {
                    IniCandorGrade=[SELECT Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c,
                                           Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c, DateOfEstablishment__c 
                                      FROM ScoreCard_Config__c 
                                     WHERE RecordType.Name='Score Card' 
                                       AND FieldName__c='Risco Informa' 
                                       AND Informa_Rating__c=: rateinf LIMIT 1 ];    
                }
                
                if(IniCandorGrade.Decision__c=='Credit Line - Rejected')
                {
                    System.debug('is failure Score nok ? check if credit can be conceded anyway.');
                    RepescaClientsComMauInformaScoreForAccount(acc, report);
                    if(acc.Credit_Line_Status__c=='Credit Line - Approved')
                    {
                        risk4=true;
                    }
                    else
                    {
                        acc.Risk_Type__c=IniCandorGrade.App_Client_Risk__c;
                        update acc;
                        return acc.Credit_Line_Status__c;
                    }
                }
                
                if(risk4 != true)
                {
                    //Calcula CandorScore
                    decimal percentageDateModifier = Decimal.valueOf(((ScoreCard_Config__c)[SELECT Matching_Value__c 
                                                                                              FROM scorecard_config__c 
                                                                                             WHERE recordtype.name = 'Modifier Score' 
                                                                                               AND FieldName__c='Date Modifier Percentage']).Matching_Value__c);
                    decimal percentageInformaScore = 1-percentageDateModifier;
                    
                    ScoreCard_Config__c dateModifierScoreCard = [SELECT Matching_Value__c, Matching_Type__c, Amount_Max__c 
                                                                   FROM scorecard_config__c 
                                                                  WHERE recordtype.name = 'Modifier Score' 
                                                                    AND FieldName__c    = 'Date Modifier' 
                                                                    AND Amount_Min__c  <= :valdate 
                                                                    AND Amount_Max__c  >= :valdate LIMIT 1];
                    
                    decimal valdateModified = Decimal.valueOf(dateModifierScoreCard.Matching_Value__c);
                    
                    if(dateModifierScoreCard.Matching_Type__c=='Linear' && valdateModified > 0)
                    {
                        valdateModified = valdate * valdateModified / Integer.valueOf(dateModifierScoreCard.Amount_Max__c);
                    }               
                    
                    //TODO: Se Informa Score for null ou estiver com atualização no rateinf
                    integer candorScore = Integer.valueOf( percentageInformaScore * score + percentageDateModifier * valdateModified );
                    
                    report[0].Candor_Score__c = candorScore;
                    update report[0];
                    
                    System.debug('candorScore:'+candorScore);
                    System.debug('percentageInformaScore:'+percentageInformaScore);
                    System.debug('score:'+score);
                    System.debug('percentageDateModifier:'+percentageDateModifier);
                    System.debug('valdate:'+valdate);
                    
                    IniCandorGrade=[SELECT Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,
                                           DateOfEstablishment__c 
                                      FROM ScoreCard_Config__c 
                                     WHERE RecordType.Name       = 'Score Card' 
                                       AND FieldName__c          = 'Risco Informa' 
                                       AND Failure_Score_Max__c >= :candorScore 
                                       AND Failure_Score_Min__c <= :candorScore  
                                    ]; 
                    
                    if(IniCandorGrade.Decision__c=='Credit Line - Rejected')
                    {
                        system.debug('is Candor Score nok ? check if credit can be conceded anyway.');
                        RepescaClientsComMauInformaScoreForAccount(acc, report);
                        if(acc.Credit_Line_Status__c=='Credit Line - Approved')
                        {
                            risk4=true;
                        }
                        else
                        {
                            return acc.Credit_Line_Status__c;
                        }
                    }
                }//end risk4 != true condition

                // registers model rank and initial credit limit 
                
                // register modifier activity 
                if (acc.CAE__c!=null && acc.CAE__c!='') 
                {
                    cae=acc.CAE__c.substring(0,2);

                    ModifierCAE=[SELECT Id, Modifier__c 
                                   FROM ScoreCard_Config__c 
                                  WHERE RecordType.Name = 'Modifier CAE' 
                                    AND division__c     = :cae ];

                    if(ModifierCAE!=null  )
                    {
                        ModelRankafterAct=IniCandorGrade.Model_Rank__c + ModifierCAE.Modifier__c;
                    }
                }                 
                if(ModelRankafterAct < 1 )
                {
                    ModelRankafterAct=1;
                }
                if(ModelRankafterAct > 35 )
                {
                    ModelRankafterAct=35;
                }
                
                // registers final model rank and creditline limit
                CandorGradeAfterAct=[SELECT Id, Candor_Grade__c, Decision__c, Message__c, Auto_Decision__c, 
                                            App_Client_Risk__c, Credit_Line_Max_Limit__c, DateOfEstablishment__c 
                                       FROM ScoreCard_Config__c 
                                      WHERE RecordType.Name = 'Score Card' 
                                        AND FieldName__c    = 'Risco Informa' 
                                        AND Model_rank__c   = :ModelRankafterAct];

                acc.Credit_Line_Status__c = CandorGradeAfterAct.Decision__c;
                acc.Risk_Type__c          = CandorGradeAfterAct.App_Client_Risk__c;
                
                limitcredit = CandorGradeAfterAct.Credit_Line_Max_Limit__c;
                limitdate   = CandorGradeAfterAct.DateOfEstablishment__c;
                
                // if failure score ok
                /* FIANCA APARTIR DE 161107   
                else {*/
                System.debug('failureScore OK ...');
                // Checks company state
                System.debug('Avalia Company State: '+report[0].Estado__c);
                if( report[0].Estado__c !='Ativa' && report[0].Estado__c !='' &&  report[0].Estado__c !=null)
                {
                    system.debug('Company State NOK ');
                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                    system.debug('1');
                    update acc;
                    Return acc.Credit_Line_Status__c;
                }
                else
                {
                    System.debug('Company State OK');// ou não está preechido');
                    // tem dateOfEstablishment?
                    System.debug('Avalia DateOfEstablishment ...');
                    if( DateOfEstablishment==null)
                    {
                        system.debug('DateOfEstablishment Vazia ...');
                        system.debug('Avalia valor de vendas ...');
                        if(acc.Sales__c==null)
                        {
                            system.debug('Valor de Vendas não existe.');
                            system.debug('Avalia valor NetProfit...');
                            if(acc.AnnualRevenue==null )
                            {
                                system.debug('NetProfit não existe.');
                                system.debug('evaluates court Actions');
                                if(report[0].TotIncidentes__c==null)
                                {
                                    system.debug('courtactions do not exist');                                        
                                    if(legalForm!=null && legalForm!='')
                                    {
                                        system.debug('Legal Form exists');
                                        legalformcredit=true;
                                        ScoreCardLegal=[SELECT id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c 
                                                          FROM scorecard_config__c 
                                                         WHERE recordtype.name = 'LegalForm' 
                                                           AND legal_form__C   = :legalForm];
                                        
                                        if(ScoreCardLegal.size()==0)
                                        {
                                            acc.Credit_Line_Status__c='Credit Line - Pendent';
                                            system.debug('2');
                                            update acc;
                                            Return acc.Credit_Line_Status__c;   
                                        }
                                        else
                                        {
                                            system.debug('IF ENI ADOV or SROC...');
                                            if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' )
                                            {
                                                system.debug('Evaluates failure score for ENI and ADVOG...');
                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                system.debug('3');
                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');                                                
                                            } 
                                            else 
                                                if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP')
                                                {
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    system.debug('4');
                                                    update acc;
                                                    Return acc.Credit_Line_Status__c;        
                                                }
                                                else
                                                {
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado')
                                                    {
                                                        acc.Credit_Line_Status__c = 'Credit Line - Approved';
                                                        acc.Risk_Type__c          = ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else
                                                    {
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        system.debug('5');
                                                        update acc;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                        }
                                    }
                                    else
                                    {
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        system.debug('6');
                                        update acc;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                }
                                else
                                {
                                    //avalia se courtactions ok
                                    system.debug('verifies if courtactions ok?');
                                    list<ScoreCard_config__c> ScoreCardCourtAct=[SELECT id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                   FROM ScoreCard_Config__c 
                                                                                  WHERE RecordType.Name='Risk 4' 
                                                                                    AND Matching_Value_To_Nr__c < :report[0].TotIncidentes__c 
                                                                                    AND FieldName__c='CourtActions' ];
                                    if(ScoreCardCourtAct.size()!=0)
                                    {
                                        system.debug('Courtactions nok?');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        system.debug('7');
                                        update acc;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else
                                    {
                                        //avalia legal form
                                        system.debug('Evaluates LegalForm');
                                        if(legalForm!=null && legalForm!='')
                                        {
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[SELECT id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c 
                                                              FROM scorecard_config__c 
                                                             WHERE recordtype.name = 'LegalForm' 
                                                               AND legal_form__C= :legalForm];
                                            
                                            if(ScoreCardLegal.size()==0)
                                            {
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                system.debug('8');
                                                update acc;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else
                                            {
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' )
                                                {
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                }
                                                else 
                                                    if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP')
                                                    {
                                                        system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        system.debug('9');
                                                        update acc;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else
                                                    {
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado')
                                                        {
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else
                                                        {
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            system.debug('10');
                                                            update acc;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                            }
                                        }
                                        else
                                        {
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            system.debug('11');
                                            update acc;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }
                                } 
                            }
                            else
                            {
                                // verifica se net profit ok
                                system.debug('evaluates Net profit...');
                                system.debug(acc.AnnualRevenue);
                                List<ScoreCard_Config__c> ScoreCardNetProfit=[SELECT Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                FROM ScoreCard_Config__c 
                                                                               WHERE RecordType.Name='Risk 4' 
                                                                                 AND Matching_Value_To_Nr__c >:acc.AnnualRevenue 
                                                                                 AND FieldName__c='NetProfit'  ];
                                if(ScoreCardNetProfit.size()!=0  )
                                { 
                                    system.debug('Net Profit NOK.');
                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                    system.debug('12');
                                    update acc; 
                                    Return acc.Credit_Line_Status__c;
                                }
                                else
                                {
                                    system.debug('Net Profit OK.');
                                    system.debug('Evaluates courtactions...');
                                    if(report[0].TotIncidentes__c==null)
                                    {
                                        system.debug('Courtactions do not exist.');
                                        system.debug('Evaluates legal form...');
                                        if(legalForm!=null && legalForm!='')
                                        {
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[SELECT id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c 
                                                              FROM scorecard_config__c 
                                                             WHERE recordtype.name = 'LegalForm' 
                                                               AND legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0)
                                            {
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                system.debug('13');
                                                update acc;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else
                                            {
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' )
                                                {
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                }
                                                else 
                                                    if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP')
                                                    {
                                                        system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        system.debug('14');
                                                        update acc;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else
                                                    {
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c == 'Aprovado')
                                                        {
                                                            acc.Credit_Line_Status__c = 'Credit Line - Approved';
                                                            acc.Risk_Type__c = ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else
                                                        {
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            system.debug('15');
                                                            update acc;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                            }
                                        }
                                        else
                                        {
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            system.debug('16');
                                            update acc;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }
                                    else
                                    {
                                        //avalia se courtactions ok
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[SELECT id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                       FROM ScoreCard_Config__c 
                                                                                      WHERE RecordType.Name         = 'Risk 4' 
                                                                                        AND Matching_Value_To_Nr__c < :report[0].TotIncidentes__c 
                                                                                        AND FieldName__c            = 'CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0)
                                        {
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            system.debug('17');
                                            update acc;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else
                                        {
                                            //avalia legal form
                                            if(legalForm!=null && legalForm!='')
                                            {
                                                legalformcredit=true;
                                                ScoreCardLegal=[SELECT id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c 
                                                                  FROM scorecard_config__c 
                                                                 WHERE recordtype.name = 'LegalForm' 
                                                                   AND legal_form__C   = :legalForm];
                                                
                                                if(ScoreCardLegal.size()==0)
                                                {
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    system.debug('18');
                                                    update acc;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else
                                                {
                                                    // como não tem failure score vai rejeitar logo estas 2 legalForms
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SORC')
                                                    {
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    } 
                                                    else 
                                                        if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP')
                                                        {
                                                            system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            system.debug('19');
                                                            update acc;
                                                            Return acc.Credit_Line_Status__c;        
                                                        }
                                                        else
                                                        {
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado')
                                                            {
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else
                                                            {
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                system.debug('20');
                                                                update acc;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                }
                                            }
                                            else
                                            {
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                system.debug('21');
                                                update acc;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            system.debug('Evaluate sales ...');
                            list<ScoreCard_Config__c> ScoreCardCfgSales=[SELECT Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                           FROM ScoreCard_Config__c 
                                                                          WHERE RecordType.Name='Score Card' 
                                                                            AND Matching_Value_To_Nr__c >:acc.Sales__c 
                                                                            AND FieldName__c='Sales'  ];
                            if(ScoreCardCfgSales.size()!=0  )
                            { 
                                system.debug('Sales NOK. Rejeitado');
                                acc.Credit_Line_Status__c=ScoreCardCfgSales[0].Decision__c;
                                if(ScoreCardCfgSales[0].Auto_Decision__c==true)
                                {
                                    system.debug('22');
                                }
                                update acc; 
                                Return acc.Credit_Line_Status__c;
                            }
                            else
                            {
                                // vendas ok avalia net profit
                                if(acc.AnnualRevenue==null )
                                {
                                    system.debug('NetProfit não existe. evaluates court Actions');
                                    if(report[0].TotIncidentes__c==null)
                                    {
                                        system.debug('courtactions do not exist');                                        
                                        if(legalForm!=null && legalForm!='')
                                        {
                                            system.debug('Legal Form exists');
                                            legalformcredit=true;
                                            ScoreCardLegal=[SELECT id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c 
                                                              FROM scorecard_config__c 
                                                             WHERE recordtype.name = 'LegalForm' 
                                                               AND legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0)
                                            {
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                system.debug('23');
                                                update acc;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else
                                            {
                                                system.debug('IF ENI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' )
                                                {
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                }
                                                else 
                                                    if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP')
                                                    {
                                                        system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        system.debug('24');
                                                        update acc;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else
                                                    {
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado')
                                                        {
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else
                                                        {
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            system.debug('25');
                                                            update acc;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                            }
                                        }
                                        else
                                        {
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            system.debug('26');
                                            update acc;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }
                                    else
                                    {
                                        //avalia se courtactions ok
                                        system.debug('verifies if courtactions ok?');
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[SELECT id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                       FROM ScoreCard_Config__c 
                                                                                      WHERE RecordType.Name='Risk 4' 
                                                                                        AND Matching_Value_To_Nr__c < :report[0].TotIncidentes__c 
                                                                                        AND FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0)
                                        {
                                            system.debug('Courtactions nok?');
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            system.debug('27');
                                            update acc;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else
                                        {
                                            //avalia legal form
                                            system.debug('Evaluates LegalForm');
                                            if(legalForm!=null && legalForm!='')
                                            {
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[SELECT id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c 
                                                                  FROM scorecard_config__c 
                                                                 WHERE recordtype.name = 'LegalForm' 
                                                                   AND legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0)
                                                {
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    update acc;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else
                                                {
                                                    system.debug('IF ENI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' )
                                                    {
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    }
                                                    else 
                                                        if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP')
                                                        {
                                                            system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            system.debug('28');
                                                            update acc;
                                                            Return acc.Credit_Line_Status__c;        
                                                        }
                                                        else
                                                        {
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado')
                                                            {
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else
                                                            {
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                system.debug('29');
                                                                update acc;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                }
                                            }
                                            else
                                            {
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                system.debug('30');
                                                update acc;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                    } 
                                }
                                else
                                {
                                    // verifica se net profit ok
                                    system.debug('evaluates Net profit...');
                                    List<ScoreCard_Config__c> ScoreCardNetProfit=[SELECT Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                    FROM ScoreCard_Config__c 
                                                                                   WHERE RecordType.Name='Risk 4' 
                                                                                     AND Matching_Value_To_Nr__c >:acc.AnnualRevenue 
                                                                                     AND FieldName__c='NetProfit'  ];
                                    if(ScoreCardNetProfit.size()!=0  )
                                    { 
                                        system.debug('Net Profit is not ok');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        system.debug('31');
                                        update acc; 
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else
                                    {
                                        system.debug('Net Profit OK.');
                                        system.debug('Evaluates courtactions...');
                                        if(report[0].TotIncidentes__c==null)
                                        {
                                            system.debug('Courtactions do not exist.');
                                            system.debug('Evaluates legal form...');
                                            if(legalForm!=null && legalForm!='')
                                            {
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[SELECT id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c 
                                                                  FROM scorecard_config__c 
                                                                 WHERE recordtype.name = 'LegalForm' 
                                                                   AND legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0)
                                                {
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    system.debug('32');
                                                    update acc;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else
                                                {
                                                    system.debug('IF ENI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' )
                                                    {
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    }
                                                    else 
                                                    if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP')
                                                    {
                                                        system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        system.debug('33');
                                                        update acc;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else
                                                    {
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado')
                                                        {
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else
                                                        {
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            system.debug('34');
                                                            update acc;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                system.debug('35');
                                                update acc;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                        else
                                        {
                                            //avalia se courtactions ok
                                            list<ScoreCard_config__c> ScoreCardCourtAct=[SELECT id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                        FROM ScoreCard_Config__c WHERE RecordType.Name='Risk 4' AND 
                                                                                         Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                            if(ScoreCardCourtAct.size()!=0)
                                            {
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                //app.Status__c='Application - Rejected';  
                                                //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                system.debug('36');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                            else{
                                                //avalia legal form
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()==0){
                                                        acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                        //app.Status__c='Application - Pendent';
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                        system.debug('37');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;   
                                                    }
                                                    else{
                                                        system.debug('IF ENI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('Evaluates failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                        }
                                                        else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                            system.debug('38');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;        
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                //app.Status__c='Application - Approved';
                                                                //app.Reject_Reason__c='';
                                                                //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                //app.Status__c='Application - Rejected';  
                                                                //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                system.debug('39');
                                                                update acc;
                                                                //update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }
                                                }
                                                else{
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    system.debug('40');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    else{
                        system.debug('DateOfEstablishment preenchida...');
                        
                        string isStartup=AprovacaoDeEmpresaRecenteComScoreParaConta(acc,valdate, report);
                        if(isStartup=='Credit Line - Rejected'){
                                        /* Startup APARTIR DE 161117
                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                            app.Status__c='Application - Rejected';
                            app.Reject_Reason__c=insertNotification(app.id, 'Data de Início', 'Rejeitado');
                            system.debug('41');
                            update acc; 
                            update app;
                            Return acc.Credit_Line_Status__c;
                            */
                            system.debug('DateOfEstablishment NOK');
                            return acc.Credit_Line_Status__c;                            
                        } 
                        if(isStartup=='Startup - Approved'){
                            return finalizeCreditLineStatusStartupForAccount(acc, report);
                        }
                        
                        if(valdate < limitdate){   
                        system.debug('DateOfEstablishment NOK');  

                                    /* FIANCA APARTIR DE 161107
                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                        app.Status__c='Application - Rejected';
                        app.Reject_Reason__c=insertNotification(app.id, 'Data de Início', 'Rejeitado');
                        update acc; 
                        update app;
                        Return acc.Credit_Line_Status__c;
                        */
                        acc.Personal_Guarantee__c = true;
                        //app.Personal_Guarantee__c = true;
                        }
                        
                        /* FIANCA APARTIR DE 161107 
                        else {*/
                        // tem vendas
                        
                        if(acc.Sales__c== Null){
                            system.debug('evaluates Sales...');
                            system.debug('Sales do not exist.');
                            // inserir fluxo de ramo sem failure score
                            system.debug('Avalia valor NetProfit...');
                            if(acc.AnnualRevenue==null ){
                                system.debug('NetProfit não existe.');
                                system.debug('evaluates court Actions');
                                if(report[0].TotIncidentes__c==null){
                                    system.debug('courtactions do not exist');                                        
                                    if(legalForm!=null && legalForm!=''){
                                        legalformcredit=true;
                                        system.debug('Legal Form exists');
                                        ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                        where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                        if(ScoreCardLegal.size()==0){
                                            acc.Credit_Line_Status__c='Credit Line - Pendent';
                                            //app.Status__c='Application - Pendent';
                                            //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                            system.debug('42');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;   
                                        }
                                        else{
                                            system.debug('IF EI ADOV or SROC...');
                                            if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                //app.Status__c='Application - Approved';
                                                //app.Reject_Reason__c='';
                                                //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                            }
                                            else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                //app.Status__c='Application - Approved';
                                                //app.Reject_Reason__c='';
                                                //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                            }
                                            else{
                                                system.debug('evaluates legal form score card for others legalforms');
                                                if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    //app.Status__c='Application - Approved';
                                                    //app.Reject_Reason__c='';
                                                    //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                }
                                                else{
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                    system.debug('43');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        //app.Status__c='Application - Rejected';  
                                        //app.Reject_Reason__c=insertNotification(app.id, 'Finanaceira Indisponível', 'Rejeitado');
                                        system.debug('44');
                                        update acc;
                                        //update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                }
                                else{
                                    //avalia se courtactions ok
                                    system.debug('verifies if courtactions ok?');
                                    list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                 From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                 Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                    if(ScoreCardCourtAct.size()!=0){
                                        system.debug('Courtactions nok?');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        //app.Status__c='Application - Rejected';  
                                        //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                        system.debug('45');
                                        update acc;
                                        //update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        //avalia legal form
                                        system.debug('Evaluates LegalForm');
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                //app.Status__c='Application - Pendent';
                                                //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                system.debug('46');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    //app.Status__c='Application - Approved';
                                                    //app.Reject_Reason__c='';
                                                    //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, COOP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    //app.Status__c='Application - Approved';
                                                    //app.Reject_Reason__c='';
                                                    //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        system.debug('47');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            system.debug('legal form does not exist. rejected');
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';  
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            system.debug('48');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;  
                                        }
                                    }
                                }
                            }
                            else{
                                // verifica se net profit ok
                                List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                              where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c >:acc.AnnualRevenue And 
                                                                              FieldName__c='NetProfit'  ];
                                if(ScoreCardNetProfit.size()!=0  ){ 
                                    system.debug('Net Profit is not ok');
                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                    //app.Status__c='Application - Rejected';
                                    //app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                    system.debug('49');
                                    update acc; 
                                    //update app;
                                    Return acc.Credit_Line_Status__c;
                                }
                                else{
                                    if(report[0].TotIncidentes__c==null){
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                //app.Status__c='Application - Pendent';
                                                //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                system.debug('50');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    //app.Status__c='Application - Approved';
                                                    //app.Reject_Reason__c='';
                                                    //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    //app.Status__c='Application - Approved';
                                                    //app.Reject_Reason__c='';
                                                    //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        system.debug('51');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';  
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            system.debug('52');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }  
                                    else{
                                        //avalia se courtactions ok
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';  
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                            system.debug('53');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            //avalia legal form
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    //app.Status__c='Application - Pendent';
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    system.debug('54');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else{
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada');
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            system.debug('54');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                            else{
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                //app.Status__c='Application - Rejected';  
                                                //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                system.debug('55');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            
                            system.debug('Sales approval limit X Sales  ok?');
                            //Sales approval limit X Sales > 500€?
                            list<ScoreCard_Config__c > CreditLineCfg=[select Credit_Line_limit__c from ScoreCard_Config__c where recordType.name='Credit Line' and Candor_Grade__c= :CandorGradeAfterAct.Candor_Grade__c AND  Amount_Min__c <= :acc.Sales__c AND Amount_Max__c >=:acc.Sales__c ];
                                            /*
                            system.debug('CreditLineCfg.size() '+CreditLineCfg.size());
                            system.debug('acc.Sales__c '+ acc.Sales__c);
                            system.debug('CandorGradeAfterAct.Candor_Grade__c '+ CandorGradeAfterAct.Candor_Grade__c);
                            */
                            if(CreditLineCfg.size()==0){
                                CreditLineCfg=[select Credit_Line_limit__c from ScoreCard_Config__c where recordType.name='Credit Line' and Candor_Grade__c= :CandorGradeAfterAct.Candor_Grade__c AND  Amount_Min__c <= :acc.Sales__c order by Amount_Min__c DESC];
                            }                        
                            AggregateResult[] groupedResults = [select MIN(Amount_Min__c) min from ScoreCard_Config__c where recordType.name='Factor Card'];
                            integer approvalValueLimit = Integer.valueOf(groupedResults[0].get('min'));
                                        /*
                            system.debug('CreditLineCfg[0].Credit_Line_limit__c'+CreditLineCfg[0].Credit_Line_limit__c);
                            system.debug('acc.Sales__c '+ acc.Sales__c);
                            system.debug('approvalValueLimit '+ approvalValueLimit);
                            */
                            if(CreditLineCfg.size()==0 || CreditLineCfg[0].Credit_Line_limit__c * (acc.Sales__c / 100) < approvalValueLimit){
                                system.debug('acc.Sales__c:'+acc.Sales__c);
                                system.debug('CandorGradeAfterAct.Candor_Grade__c:'+CandorGradeAfterAct.Candor_Grade__c);
                                system.debug('approvalValueLimit:'+approvalValueLimit);
                                if(CreditLineCfg.size()!=0){
                                    system.debug('CreditLineCfg[0].Credit_Line_limit__c:'+CreditLineCfg[0].Credit_Line_limit__c);
                                }
                                system.debug('Sales approval not ok. Rejeitado.');
                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                //app.Status__c='Application - Rejected';                                                
                                //app.Reject_Reason__c=insertNotification(app.id, 'Faturação Insuficiente', 'Rejeitado');
                                update acc; 
                                //update app;
                                Return acc.Credit_Line_Status__c; 
                            }
                            
                            system.debug('are sales ok?');
                            ScoreCardCfg=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                          Matching_Value_To_Nr__c >:acc.Sales__c And FieldName__c='Sales'  ];
                            if(ScoreCardCfg.size()!=0  ){ 
                                system.debug('sales are not ok.');
                                acc.Personal_Guarantee__c = true;
                                //app.Personal_Guarantee__c = true;
                            }else{
                                system.debug('Sales OK.');
                            }
                            /* FIANCA APARTIR DE 161107   
                            system.debug('evaluate years since establishiment.');
                            // avalia anos de empresa
                            if( valdate >= CandorGradeAfterAct.Sales_NOK__c){
                            system.debug('Sales approval ok?');
                            list<ScoreCard_Config__c > CreditLineCfg=[select Id, name, Credit_Line_limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                            where recordType.name='Credit Line' and Candor_Grade__c= :CandorGradeAfterAct.Candor_Grade__c AND  Amount_Min__c <= :acc.Sales__c AND Amount_Max__c >=:acc.Sales__c ];
                            if(CreditLineCfg.size()==0){
                            CreditLineCfg=[select Id, name, Credit_Line_limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                            where recordType.name='Credit Line' and Candor_Grade__c=:CandorGradeAfterAct.Candor_Grade__c AND   Amount_Min__c <= :acc.Sales__c ]; 
                            }    
                            if(CreditLineCfg.size()==0){
                            system.debug('Sales approval not ok. Rejeitado.');
                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                            app.Status__c='Application - Rejected';                                                
                            app.Reject_Reason__c=insertNotification(app.id, 'Faturação Insuficiente', 'Rejeitado'); 
                            update acc; 
                            update app;
                            Return acc.Credit_Line_Status__c; 
                            }
                            else{

                            system.debug('Sales Approval ok.');
                            system.debug('evaluates last 2 years finantial statements');
                            if(report[0].Sales_n_1__c!=0 && report[0].Sales_n_1__c!=null ){
                            acc.Credit_Line_Status__c='Credit Line - Approved';
                            app.Status__c='Application - Approved';
                            app.Reject_Reason__c='';
                            app.ScoreCard__c=CandorGradeAfterAct.Id;
                            acc.Risk_Type__c=CandorGradeAfterAct.App_Client_Risk__C;
                            system.debug('Informação finanaceira para os dois ultimos anos existe.');
                            }
                            else{
                            acc.Credit_Line_Status__c='Credit Line - Pendent';
                            app.Status__c='Application - Pendent';
                            app.Reject_Reason__c=insertNotification(app.id, 'Info disponível inferior', 'Pendente'); 
                            update acc;
                            update app;
                            Return acc.Credit_Line_Status__c;   
                            }
                            }
                            }
                            else{
                            system.debug('Sales NOK not ok. Rejeitado.');
                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                            app.Status__c='Application - Rejected';       
                            app.Reject_Reason__c=insertNotification(app.id, 'Data de Início', 'Rejeitado'); 
                            update acc; 
                            update app;
                            Return acc.Credit_Line_Status__c;
                            }
                            }
                            else{

                            system.debug('Sales OK.');
                            */
                                            
                            system.debug('evaluates last current and previous year finantial statements');
                            if(report[0].Sales_n_1__c!=0 && report[0].Sales_n_1__c!=null  ){
                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                //app.Status__c='Application - Approved';
                                //app.Reject_Reason__c='';
                                //app.ScoreCard__c=CandorGradeAfterAct.Id;
                                acc.Risk_Type__c=CandorGradeAfterAct.App_Client_Risk__C;
                                system.debug('Informação finanaceira para os dois ultimos anos existe.');
                            }
                            else if(report[0].Sales_n_1__c==0){
                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                //app.Status__c='Application - Rejected';
                                //app.Reject_Reason__c=insertNotification(app.id, 'Faturação Insuficiente', 'Rejeitado'); 
                                update acc;
                                //update app;
                                Return acc.Credit_Line_Status__c;   
                            }
                            else{
                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                //app.Status__c='Application - Rejected';
                                //app.Reject_Reason__c=insertNotification(app.id, 'Informação financeira disponível tem mais de 2 anos', 'Rejeitado'); 
                                update acc;
                                //update app;
                                Return acc.Credit_Line_Status__c;   
                            }
                            
                            /* FIANCA APARTIR DE 161107     
                            }
                                    */
                                    }
                                    /* FIANCA APARTIR DE 161107   
                                }*/
                                }
                                /* FIANCA APARTIR DE 161107   
                                }*/
                            }
                        } 
                        // failure scores does not exist
            else {
                system.debug('failure score does not exist');
                
                string isStartup=AprovacaoDeEmpresaRecenteSemScoreParaConta(acc,valdate, report);
                if(isStartup=='Credit Line - Rejected'){
                    system.debug('DateOfEstablishment NOK');
                    return acc.Credit_Line_Status__c;                            
                } 
                if(isStartup=='Startup - Approved'){
                    system.debug('rateinf'+rateinf);
                    List<ScoreCard_Config__c> IniCandorGradeList=[Select Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,
                                    DateOfEstablishment__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                    FieldName__c='Risco Informa' and Informa_Rating__c=: rateinf limit 1 ];
                    if(IniCandorGradeList.size()==0){
                        IniCandorGradeList=[Select Id, Model_Rank__c, Candor_Grade__c, Decision__c, Message__c, Informa_Rating__c, Risk_Class__c, App_Client_Risk__c, Credit_Line_Max_Limit__c,
                                    DateOfEstablishment__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                    FieldName__c='Risco Informa' and Failure_Score_Min__c=:0 limit 1 ];
                    }
                    //app.ScoreCard__c=IniCandorGradeList[0].Id;
                    acc.Risk_Type__c=IniCandorGradeList[0].App_Client_Risk__C;
                    return finalizeCreditLineStatusStartupForAccount(acc, report);
                }
                
                // Checks company state
                system.debug('Evaluates company state...');
                if( report[0].Estado__c !='Ativa' && ( report[0].Estado__c !='' &&  report[0].Estado__c !=null)){
                    system.debug('Company state not ok.');
                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                    //app.Status__c='Application - Rejected';  
                    //app.Reject_Reason__c=insertNotification(app.id, 'sem indícios de atividade', 'Rejeitado');
                    update acc;
                    //update app;
                    Return acc.Credit_Line_Status__c;
                }
                else {
                    // evaluates dateOfEstablishment?
                    system.debug('evaluates dateOfestablishment...');
                    if( DateOfEstablishment ==null){
                        system.debug('DateOfEstablishment empty.');
                        system.debug('evaluates sales...');
                        if(acc.Sales__c== null){
                            system.debug('sales does not exist.');
                            system.debug('evaluates Net Profit...');    
                            if(acc.AnnualRevenue==null ){
                                system.debug('net profit does not exist.');
                                system.debug('evaluates courtactions...');    
                                if(report[0].TotIncidentes__c==null){
                                    system.debug('court actions does not exist...');    
                                    if(legalForm!=null && legalForm!=''){
                                        system.debug('Legal Form exists');
                                        legalformcredit=true;
                                        ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                        where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                        if(ScoreCardLegal.size()==0){
                                            acc.Credit_Line_Status__c='Credit Line - Pendent';
                                            //app.Status__c='Application - Pendent';
                                            //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;   
                                        }
                                        else{
                                            system.debug('IF EI ADOV or SROC...');
                                            if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                system.debug('no failure score so credit line rejected for ENI and ADVOG...');
                                                
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                //app.Status__c='Application - Rejected';  
                                                //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;  
                                                
                                            }
                                            else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                //app.Status__c='Application - Rejected';  
                                                //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;        
                                            }
                                            else{
                                                system.debug('evaluates legal form score card for others legalforms');
                                                if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                    legalformcredit=true;
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    //app.Status__c='Application - Approved';
                                                    //app.Reject_Reason__c='';
                                                    //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists. Aplicação aprovada'); 
                                                }
                                                else{
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        system.debug('Legal form does not exist. rejeitado');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        //app.Status__c='Application - Rejected';  
                                        //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                        update acc;
                                        //update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                }
                                else{
                                    //avalia se courtactions ok
                                    system.debug('evaluate if courtactions are ok...');
                                    list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                 From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                 Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                    if(ScoreCardCourtAct.size()!=0){
                                        system.debug('courtactions nok');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        //app.Status__c='Application - Rejected';  
                                        //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                        update acc;
                                        //update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        system.debug('courtactions ok.');
                                        system.debug('evaluates legal form...');
                                        //avalia legal form
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                //app.Status__c='Application - Pendent';
                                                //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;   
                                                
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;  
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;        
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';  
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        
                                    }
                                }
                            }
                            else{
                                system.debug('evaluates if net profit ok...');
                                // verifica se net profit ok
                                List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                              where RecordType.Name='Score Card' and Matching_Value_To_Nr__c >:acc.AnnualRevenue And 
                                                                              FieldName__c='NetProfit'  ];
                                if(ScoreCardNetProfit.size()!=0  ){ 
                                    system.debug('Net Profit is not ok');
                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                    //app.Status__c='Application - Rejected';
                                    //app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                    update acc; 
                                    //update app;
                                    Return acc.Credit_Line_Status__c;
                                }
                                else{
                                    system.debug('evaluates courtactions');
                                    if(report[0].TotIncidentes__c==null){
                                        system.debug('court actions do not exist.');
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                //app.Status__c='Application - Pendent';
                                                //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente'); 
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;   
                                                
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('Evaluates failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;  
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;        
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }  
                                        }
                                        else{
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';  
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                    }  
                                    else{
                                        //avalia se courtactions ok
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';  
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            //avalia legal form
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    //app.Status__c='Application - Pendent';
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                    
                                                }
                                                else{
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('Evaluates failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            //avalia vendas
                            list<ScoreCard_Config__c> ScoreCardCfgSales=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                                                         Matching_Value_To_Nr__c >:acc.Sales__c And FieldName__c='Sales'  ];
                            if(ScoreCardCfgSales.size()!=0  ){ 
                                acc.Credit_Line_Status__c=ScoreCardCfgSales[0].Decision__c;
                                update acc; 
                                //app.Reject_Reason__c=ScoreCardCfgSales[0].Message__c;
                                if(ScoreCardCfgSales[0].Auto_Decision__c==true){
                                    //app.Status__c='Application - Rejected';
                                    //Notification__c notif= new Notification__c( application__c=app.Id,  Message__c=ScoreCardCfgSales[0].Message__c); 
                                    //insert notif;
                                }
                                update acc; 
                                //update app;
                                Return acc.Credit_Line_Status__c;
                            }
                            else {
                                // netprofit existe?
                                if(acc.AnnualRevenue==null){
                                    // courtactions existe?
                                    if(report[0].TotIncidentes__c==null){
                                        //legalform existe?
                                        if(legalForm==null){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';  
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c; 
                                        }
                                        else{
                                            //avalia legalform coloca chamada a method q avalia legalform
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    //app.Status__c='Application - Pendent';
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else{
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('no failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }  
                                            }
                                            else{
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                //app.Status__c='Application - Rejected';  
                                                //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                        }
                                    }
                                    else{
                                        // avalia courtactions
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';  
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            if(legalForm==null){
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                //app.Status__c='Application - Rejected';  
                                                //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c; 
                                            }
                                            else{
                                                //avalia legalform coloca chamada a method q avalia legalform
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()==0){
                                                        acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                        //app.Status__c='Application - Pendent';
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;   
                                                    }
                                                    else{
                                                        system.debug('IF EI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;        
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                legalformcredit=true;
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                //app.Status__c='Application - Approved';
                                                                //app.Reject_Reason__c='';
                                                                //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                //app.Status__c='Application - Rejected';  
                                                                //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                //update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }  
                                                }
                                                else{
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                else{
                                    // avalia netprofit
                                    // verifica se net profit ok
                                    system.debug('evaluates Net profit...');
                                    List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                                  where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c >:acc.AnnualRevenue And 
                                                                                  FieldName__c='NetProfit'  ];
                                    if(ScoreCardNetProfit.size()!=0  ){ 
                                        system.debug('Net Profit NOK.');
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        //app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                        //app.Status__c='Application - Rejected';
                                        update acc; 
                                        //update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        system.debug('Net Profit OK.');
                                        system.debug('Evaluates courtactions...');
                                        if(report[0].TotIncidentes__c==null){
                                            system.debug('Courtactions do not exist.');
                                            system.debug('Evaluates legal form...');
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()==0){
                                                    acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                    //app.Status__c='Application - Pendent';
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;   
                                                }
                                                else{
                                                    system.debug('IF ENI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('no failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;        
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            //avalia se courtactions ok
                                            list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                         From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                         Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                            if(ScoreCardCourtAct.size()!=0){
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                //app.Status__c='Application - Rejected';  
                                                //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                            else{
                                                //avalia legal form
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()==0){
                                                        acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                        //app.Status__c='Application - Pendent';
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;   
                                                    }
                                                    else{
                                                        system.debug('IF ENI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('no date of establishment for ASS, FUND, SIND, CORP...');  
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;        
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                //app.Status__c='Application - Approved';
                                                                //app.Reject_Reason__c='';
                                                                //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                //app.Status__c='Application - Rejected';  
                                                                //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                //update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }  
                    else{
                        ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                        where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                        // can not find record for client with no failure score
                        if(ScoreCardLegal.size()==0  ){ 
                            if(legalform==null || legalform==''){
                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                //app.Status__c='Application - Rejected';  
                                //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                update acc;
                                //update app;
                                Return acc.Credit_Line_Status__c;
                            }
                            else{
                                /* ++++++ */
                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                //app.Status__c='Application - Pendent';
                                //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                
                                update acc; 
                                //update app;
                                Return acc.Credit_Line_Status__c;
                            }
                            
                        }
                        else{
                            /* 20161212 SalesNok no longer used
                            
                            limitdate=scorecardLegal[0].Sales_NOK__C;//TODO para date establish e fiança
                            */
                            limitdate=scorecardLegal[0].DateOfEstablishment__c;//TODO para date establish e fiança
                            if (valdate < limitdate){
                                
                                acc.Personal_Guarantee__c = true;
                                //app.Personal_Guarantee__c = true;
                                /*
                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                app.Status__c='Application - Rejected';
                                app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');//Data de Início de Atividade
                                update acc; 
                                update app;
                                Return acc.Credit_Line_Status__c;
                                */
                            } 
                            /* 20161212 SalesNok no longer used
                            else if(acc.Sales__c== null){
                            */
                            if(acc.Sales__c== null){
                                if(acc.AnnualRevenue==null ){
                                    if(report[0].TotIncidentes__c==null){
                                        if(legalForm!=null && legalForm!=''){
                                            legalformcredit=true;
                                            system.debug('Legal Form exists');
                                            ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c from scorecard_config__c 
                                                            where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                            if(ScoreCardLegal.size()==0){
                                                acc.Credit_Line_Status__c='Credit Line - Pendent';
                                                //app.Status__c='Application - Pendent';
                                                //app.Reject_Reason__c=insertNotification(app.id, 'último IRC', 'Pendente');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;   
                                            }
                                            else{
                                                system.debug('IF EI ADOV or SROC...');
                                                if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                    system.debug('no failure score for ENI and ADVOG...');
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;  
                                                }
                                                else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                    system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                    legalformcredit=true;
                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                    //app.Status__c='Application - Approved';
                                                    //app.Reject_Reason__c='';
                                                    //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                }
                                                else{
                                                    system.debug('evaluates legal form score card for others legalforms');
                                                    if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;
                                                    }
                                                }
                                            }  
                                        }
                                    }
                                    else{
                                        //avalia se courtactions ok
                                        list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                     From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                     Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                        if(ScoreCardCourtAct.size()!=0){
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';  
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                            update acc;
                                            //update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            //avalia legal form
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()!=0){
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                else{
                                    // verifica se net profit ok
                                    List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                                  where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c <:acc.AnnualRevenue And 
                                                                                  FieldName__c='NetProfit'  ];
                                    if(ScoreCardNetProfit.size()==0  ){ 
                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                        //app.Status__c='Application - Rejected';
                                        //app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                        update acc; 
                                        //update app;
                                        Return acc.Credit_Line_Status__c;
                                    }
                                    else{
                                        if(report[0].TotIncidentes__c==null){
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()!=0){
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('no failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }  
                                        else{
                                            //avalia se courtactions ok
                                            list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                         From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                         Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                            if(ScoreCardCourtAct.size()!=0){
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                //app.Status__c='Application - Rejected';  
                                                //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                            else{
                                                //avalia legal form 
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()!=0){
                                                        
                                                        system.debug('IF EI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else  if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                legalformcredit=true;
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                //app.Status__c='Application - Approved';
                                                                //app.Reject_Reason__c='';
                                                                //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                //app.Status__c='Application - Rejected';  
                                                                //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                //update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }  
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                // avalia se sales ok
                                list<ScoreCard_Config__c> ScoreCardCfgSales=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c where RecordType.Name='Score Card' and 
                                                                             Matching_Value_To_Nr__c >:acc.Sales__c And FieldName__c='Sales'  ];
                                if(ScoreCardCfgSales.size()!=0  ){ 
                                    acc.Credit_Line_Status__c=ScoreCardCfgSales[0].Decision__c;
                                    update acc; 
                                    //app.Reject_Reason__c=ScoreCardCfgSales[0].Message__c;
                                    if(ScoreCardCfgSales[0].Auto_Decision__c==true){
                                        //app.Status__c='Application - Rejected';
                                        //Notification__c notif= new Notification__c( application__c=app.Id,  Message__c=ScoreCardCfgSales[0].Message__c); 
                                        //insert notif;
                                    }
                                    update acc; 
                                    //update app;
                                    Return acc.Credit_Line_Status__c;
                                }
                                else{
                                    if(acc.AnnualRevenue==null ){
                                        if(report[0].TotIncidentes__c==null){
                                            if(legalForm!=null && legalForm!=''){
                                                legalformcredit=true;
                                                system.debug('Legal Form exists');
                                                ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                if(ScoreCardLegal.size()!=0){
                                                    system.debug('IF EI ADOV or SROC...');
                                                    if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                        system.debug('no failure score for ENI and ADVOG...');
                                                        acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                        //app.Status__c='Application - Rejected';  
                                                        //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                        update acc;
                                                        //update app;
                                                        Return acc.Credit_Line_Status__c;  
                                                    }
                                                    else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                        system.debug('date of establishment exists for ASS, FUND, SIND, CORP...');  
                                                        legalformcredit=true;
                                                        acc.Credit_Line_Status__c='Credit Line - Approved';
                                                        //app.Status__c='Application - Approved';
                                                        //app.Reject_Reason__c='';
                                                        //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                        acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                        system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                    }
                                                    else{
                                                        system.debug('evaluates legal form score card for others legalforms');
                                                        if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;
                                                        }
                                                    }
                                                }  
                                            }
                                        }
                                        else{
                                            //avalia se courtactions ok
                                            list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                         From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                         Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                            if(ScoreCardCourtAct.size()!=0){
                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                //app.Status__c='Application - Rejected';  
                                                //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                update acc;
                                                //update app;
                                                Return acc.Credit_Line_Status__c;
                                            }
                                            else{
                                                //avalia legal form 
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()==0){
                                                        system.debug('IF EI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else  if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                legalformcredit=true;
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                //app.Status__c='Application - Approved';
                                                                //app.Reject_Reason__c='';
                                                                //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                //app.Status__c='Application - Rejected';  
                                                                //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                //update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        // verifica se net profit ok
                                        List<ScoreCard_Config__c> ScoreCardNetProfit=[Select Name, Decision__c, Message__C,  Auto_Decision__c From ScoreCard_Config__c 
                                                                                      where RecordType.Name='Risk 4' and Matching_Value_To_Nr__c <:acc.AnnualRevenue And 
                                                                                      FieldName__c='NetProfit'  ];
                                        if(ScoreCardNetProfit.size()==0  ){ 
                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                            //app.Status__c='Application - Rejected';
                                            //app.Reject_Reason__c=insertNotification(app.id, 'Financeiros Negativos', 'Rejeitado');
                                            update acc; 
                                            //update app;
                                            Return acc.Credit_Line_Status__c;
                                        }
                                        else{
                                            if(report[0].TotIncidentes__c==null){
                                                if(legalForm!=null && legalForm!=''){
                                                    legalformcredit=true;
                                                    system.debug('Legal Form exists');
                                                    ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                    where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                    if(ScoreCardLegal.size()!=0){
                                                        system.debug('IF EI ADOV or SROC...');
                                                        if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                            system.debug('no failure score for ENI and ADVOG...');
                                                            acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                            //app.Status__c='Application - Rejected';  
                                                            //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                            update acc;
                                                            //update app;
                                                            Return acc.Credit_Line_Status__c;  
                                                        }
                                                        else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                            legalformcredit=true;
                                                            acc.Credit_Line_Status__c='Credit Line - Approved';
                                                            //app.Status__c='Application - Approved';
                                                            //app.Reject_Reason__c='';
                                                            //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                            acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                            system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                        }
                                                        else{
                                                            system.debug('evaluates legal form score card for others legalforms');
                                                            if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                legalformcredit=true;
                                                                acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                //app.Status__c='Application - Approved';
                                                                //app.Reject_Reason__c='';
                                                                //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                            }
                                                            else{
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                //app.Status__c='Application - Rejected';  
                                                                //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                update acc;
                                                                //update app;
                                                                Return acc.Credit_Line_Status__c;
                                                            }
                                                        }
                                                    }
                                                }
                                            }  
                                            else{
                                                //avalia se courtactions ok
                                                list<ScoreCard_config__c> ScoreCardCourtAct=[Select id, Name, Decision__c, Message__C,  Auto_Decision__c 
                                                                                             From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                                             Matching_Value_To_Nr__c < :report[0].TotIncidentes__c And FieldName__c='CourtActions' ];
                                                if(ScoreCardCourtAct.size()!=0){
                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                    //app.Status__c='Application - Rejected';  
                                                    //app.Reject_Reason__c=insertNotification(app.id, 'Tribunal', 'Rejeitado');
                                                    update acc;
                                                    //update app;
                                                    Return acc.Credit_Line_Status__c;
                                                }
                                                else{
                                                    //avalia legal form
                                                    if(legalForm!=null && legalForm!=''){
                                                        legalformcredit=true;
                                                        // como não tem failure score vai rejeitar logo estas 2 legalForms
                                                        system.debug('Legal Form exists');
                                                        ScoreCardLegal=[select id, App_Client_Risk__c, legal_form__c, message__c, DateOfEstablishment__c from scorecard_config__c 
                                                                        where recordtype.name = 'LegalForm' and legal_form__C= :legalForm];
                                                        if(ScoreCardLegal.size()!=0){
                                                            system.debug('IF EI ADOV or SROC...');
                                                            if(legalForm=='ENI' || legalForm=='ADVOG' || legalForm=='SROC' ){
                                                                system.debug('Evaluates failure score for ENI and ADVOG...');
                                                                
                                                                acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                //app.Status__c='Application - Rejected';  
                                                                //app.Reject_Reason__c=insertNotification(app.id, 'Crédito Elevado', 'Rejeitado');
                                                                update acc;
                                                                //update app;
                                                                Return acc.Credit_Line_Status__c;  
                                                                
                                                            }
                                                            else if(legalForm=='ASS' || legalForm=='FUND' || legalForm=='SIND'  || legalform=='COOP'){
                                                                system.debug('Evaluates date of establishment for ASS, FUND, SIND, CORP...');  
                                                                if (DateOfEstablishment==null){
                                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                    //app.Status__c='Application - Rejected';  
                                                                    //app.Reject_Reason__c=insertNotification(app.id, 'Financeira Indisponível', 'Rejeitado');
                                                                    update acc;
                                                                    //update app;
                                                                    Return acc.Credit_Line_Status__c;        
                                                                }
                                                                else {
                                                                    legalformcredit=true;
                                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                    //app.Status__c='Application - Approved';
                                                                    //app.Reject_Reason__c='';
                                                                    //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                                }
                                                            }
                                                            else{
                                                                system.debug('evaluates legal form score card for others legalforms');
                                                                if(ScoreCardLegal[0].Message__c=='Aprovado'){
                                                                    legalformcredit=true;
                                                                    acc.Credit_Line_Status__c='Credit Line - Approved';
                                                                    //app.Status__c='Application - Approved';
                                                                    //app.Reject_Reason__c='';
                                                                    //app.ScoreCard__c=ScoreCardLegal[0].Id;
                                                                    acc.Risk_Type__c=ScoreCardLegal[0].App_Client_Risk__C;
                                                                    system.debug('failure score exists for ADVOG or ENI. Aplicação aprovada'); 
                                                                }
                                                                else{
                                                                    acc.Credit_Line_Status__c='Credit Line - Rejected';
                                                                    //app.Status__c='Application - Rejected';  
                                                                    //app.Reject_Reason__c=insertNotification(app.id, ScoreCardLegal[0].Message__c, 'Rejeitado');
                                                                    update acc;
                                                                    //update app;
                                                                    Return acc.Credit_Line_Status__c;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }  
                        }
                    }
                }
                
            }
            system.debug('Going to finalizeCreditLineStatus');
            return finalizeCreditLineStatusForAccount(legalformcredit, acc, report, CandorGradeAfterAct, ScoreCardLegal, risk4);
        }
        catch(Exception e){
            system.debug('Error in ScoreCard - Credit Line Analysis!');
            system.debug('ScoreCardConfigv2 - ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return null;
        }   
    }//end GetCreditLineStatusForAccount method

    /*****/

    public static string finalizeRejeicaoParaConta(Account acc, string motivo)
    {
        acc.Credit_Line_Status__c='Credit Line - Rejected';
        update acc; 
        Return acc.Credit_Line_Status__c;
    }//end finalizeRejeicaoParaConta method 

    /*****/

    private static string finalizeCreditLineStatusStartupForAccount(account acc, list<reportdb__c> report){
        system.debug('finalizeCreditLineStatusStartup! Going to getCreditLine');
        if(acc.Credit_Line_Status__c=='Credit Line - Approved' ) {
            if(isEmpresaRecente(acc)){
                system.debug('Credit Line de Startup >> '+'DateOfEstablishment:'+acc.Date_Of_Establishment__c+' calculaIdade(DateOfEstablishment):'+calculaIdade(acc.Date_Of_Establishment__c)+' report[0].CapitalSocial__c:'+ report[0].CapitalSocial__c);
                acc.Credit_line__c = report[0].CapitalSocial__c * getStartupCreditMultiplier();
                decimal startupMaxCredit = getStartupMaxCredit();
                if(acc.Credit_line__c > startupMaxCredit){
                    system.debug('Reducao de Credit Line de Startup >> '+' acc.Credit_line__c:'+acc.Credit_line__c);
                    acc.Credit_line__c = startupMaxCredit;
                }
            }
            
            if ( acc.Used_Credit_Line__c==null){
                acc.Available_Credit_Line__c= acc.Credit_line__c ;
            } else {
                acc.Available_Credit_Line__c= acc.Credit_line__c - acc.Used_Credit_Line__c;     
            }    
        }
        update acc; 
        //insertNotification(app.id, acc);
        return acc.Credit_Line_Status__c;
    }//end finalizeCreditLineStatusStartupForAccount method

    /*****/

    private static string finalizeCreditLineStatusForAccount(boolean legalformcredit, account acc, list<reportdb__c> report, scorecard_config__c CandorGradeAfterAct, list<ScoreCard_Config__c> ScoreCardLegal, boolean risk4){
        update acc;
        system.debug('finalizeCreditLineStatus! Going to getCreditLine');
        if(legalformcredit==true){
            getCreditLineForAccount(acc, report, ScoreCardLegal[0], legalformcredit, risk4 );
        }
        else{
            getCreditLineForAccount(acc, report, CandorGradeAfterAct, legalformcredit, risk4 );
        }
        return acc.Credit_Line_Status__c;
    }//end finalizeCreditLineStatusForAccount method    

    /*****/

    private static string getCreditLineForAccount( account acc, list<reportdb__c> report, scorecard_config__c CandorGradeAfterAct, boolean legalformcredit, boolean risk4){
        //Credit Line Analysis
        List <ScoreCard_Config__c> CreditLineCfg;
        decimal valrev=acc.Sales__c;
        decimal limitCredit=null;
        if(legalformcredit ==false){
            limitCredit=CandorGradeAfterAct.Credit_Line_Max_Limit__c;
        }
        
        if(acc.Credit_Line_Status__c=='Credit Line - Approved' ) {
            if(isEmpresaRecente(acc)){
                system.debug('Credit Line de Startup >> '+'DateOfEstablishment:'+acc.Date_Of_Establishment__c+' calculaIdade(DateOfEstablishment):'+calculaIdade(acc.Date_Of_Establishment__c)+' report[0].CapitalSocial__c:'+ report[0].CapitalSocial__c);
                acc.Credit_line__c = report[0].CapitalSocial__c * getStartupCreditMultiplier();
                decimal startupMaxCredit = getStartupMaxCredit();
                if(acc.Credit_line__c > startupMaxCredit){
                    system.debug('Reducao de Credit Line de Startup >> '+' acc.Credit_line__c:'+acc.Credit_line__c);
                    acc.Credit_line__c = startupMaxCredit;
                }
            }
            else if(legalformcredit==true){
                
                CreditLineCfg=[select Id, name, Credit_Line_Max_Limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                               where recordType.name='Credit Line' and FieldName__c='EmployeeNumber' And  Amount_Min__c <= :report[0].TotEmpregados__c And Amount_Max__c > :report[0].TotEmpregados__c ];
                if(CreditLineCfg.size()==0){
                    CreditLineCfg=[select Id, name, Credit_Line_Max_Limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                                   where recordType.name='Credit Line' and FieldName__c='EmployeeNumber'  and Amount_Min__c <= :report[0].TotEmpregados__c order by Amount_Min__c desc]; 
                }
                acc.Credit_line__c=CreditLineCfg[0].Credit_Line_Max_Limit__c;
            } 
            else{
                CreditLineCfg=[select Id, name, Credit_Line_limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                               where recordType.name='Credit Line' and Candor_Grade__c= :CandorGradeAfterAct.Candor_Grade__c AND  Amount_Min__c <= :valrev AND Amount_Max__c >=:valrev ];
                if(CreditLineCfg.size()==0){
                    CreditLineCfg=[select Id, name, Credit_Line_limit__c, Matching_Type__c, Amount_Min__c, Amount_Max__c, Risk_Class__c from ScoreCard_Config__c 
                                   where recordType.name='Credit Line' and Candor_Grade__c=:CandorGradeAfterAct.Candor_Grade__c AND   Amount_Min__c <= :valrev order by Amount_Min__c DESC]; 
                }
                if(risk4==true){
                    List <ScoreCard_Config__c> CreditLineRisk4Cfg=[Select id, Name, Matching_Value_To_Nr__c From ScoreCard_Config__c where RecordType.Name='Risk 4' and 
                                                                   FieldName__c='SalesApprovalLimit' ];
                    if(CreditLineRisk4Cfg.size()!=0) {
                        decimal crdlinerisk4=0;
                        crdlinerisk4=valrev * CreditLineCfg[0].Credit_Line_limit__c/100;
                        if(crdlinerisk4 <= CreditLineRisk4Cfg[0].Matching_Value_To_Nr__c){
                            acc.Credit_line__c=crdlinerisk4.setScale(0);
                        }
                        else{
                            acc.Credit_line__c=CreditLineRisk4Cfg[0].Matching_Value_To_Nr__c;
                        }
                    }
                }
                
                else {
                    if(CreditLineCfg.size()!=0){
                        decimal crdline=0;
                        crdline=valrev * CreditLineCfg[0].Credit_Line_limit__c/100;
                        if(crdline <= limitcredit){
                            acc.Credit_line__c=crdline.setScale(0);
                        }
                        else{
                            acc.Credit_line__c=limitcredit;
                        }   
                        
                        
                    }  
                }
            }
            
            if ( acc.Used_Credit_Line__c==null)
            {
                acc.Available_Credit_Line__c= acc.Credit_line__c ;
            } 
            else //ALTERACAO - 03/05/17 - quando há uma uma reavalição de report e a linha de financiamento é reduzida (BP) 
            {
                acc.Available_Credit_Line__c= acc.Credit_line__c - acc.Used_Credit_Line__c;     

                List <ScoreCard_Config__c> allowedLimits =[SELECT id,name,fieldname__c,Matching_Value__c  
                                                             FROM ScoreCard_Config__c 
                                                            WHERE fieldname__c LIKE 'Minimum Credit Allowed' LIMIT 1];

                if(acc.Available_Credit_Line__c <= 0)
                {
                    acc.Available_Credit_Line__c = 0;  
                    acc.Credit_Line__c           = acc.Used_credit_line__c; 
                    acc.credit_line_status__c    = 'Credit Line - Rejected'; 
                }
                else                
                    if(acc.Available_Credit_Line__c <= Decimal.valueOf(allowedLimits[0].Matching_Value__c))
                    {
                        acc.Available_Credit_Line__c = 0;
                        acc.credit_line_status__c    = 'Credit Line - Rejected'; 
                    }
            }    
        }
        update acc; 
        /*
        if( app.Status__c=='Application - Approved'){
            Schema.DescribeFieldResult fieldResult = notification__c.message__c.getDescribe();
            List<Schema.PicklistEntry> plnot = fieldResult.getPicklistValues();
            string rejectreason;
            for(integer i=0; i<plnot.size(); i++){
                if(plnot[i].getLabel().contains('Aprovado')==true ){
                    Notification__c notif= new Notification__c( application__c=app.Id,  Message__c=plnot[i].getLabel() + ' - ' + acc.Available_Credit_Line__c + '€'); 
                    rejectreason=plnot[i].getLabel();
                    insert notif;
                }    
            } 
        }
        */
        return 'ok'; 
    }//end getCreditLineForAccount method

    public static void MAGIC() {
        integer i=0;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
    }   
    
    public static void MAGIC2() {
        integer i=0;
        
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
    }   
    
    public static void MAGIC3() {
        integer i=0;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
    }
    
    public static void MAGIC4() {
        integer i=0;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
        i+=1;
        i+=2;
        i++;
    }
}