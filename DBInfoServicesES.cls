public class DBInfoServicesES {
    private static final Integer MAX_ATTEMPTS    = 3;
    private static       Integer CURRENT_ATTEMPT = 1;
    public static Utilities.OutboundIntegration DBInfogetReport( string Nif, string codigoProc, string productVersion, boolean binary ) {
        
        Utilities.OutboundIntegration outInt= new Utilities.OutboundIntegration();
        
        try{
            //create method to get credencials
            List<Credentials__c> credential=[select Username__c, Password__c, Web_Service_Url__c from Credentials__c where name ='InformaDB_ES' Limit 1];
            datetime startreq=datetime.now();
            datetime endreq; 
            string status;
            string response=null;
            string xml='';
            string errorCode;
            string errorMsg;
            List<Dom.XMLNode> childBody = new List<Dom.XMLNode>(); 
            List<Dom.XMLNode> childCodeResp = new List<Dom.XMLNode>();  
            List<Dom.XmlNode> childproduct = new List<Dom.XmlNode>();
            string parampdf='';
            string att;
            if (binary==true){

                parampdf='<parameter name="FORMATO">PDF</parameter>';
            }

            if(!Test.isRunningTest()){
                try{
                    string body='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gps="http://services.informa.es/si/gps"><soapenv:Header/><soapenv:Body><gps:getProduct><userId>'+credential[0].Username__c + '</userId><password>' + credential[0].Password__c + '</password><productCode>' + codigoProc +'</productCode><productVersion>'+ productVersion +'</productVersion><parameters><parameter name="CIF">'+Nif+'</parameter><parameter name="NORMALIZADO">1</parameter><parameter name="FORMATO_PGC">1</parameter><parameter name="RATING_ENRIQUECIDO">1</parameter>'+parampdf+'</parameters></gps:getProduct></soapenv:Body></soapenv:Envelope>';
                   
                    HttpRequest req = new HttpRequest(); req.setEndpoint(credential[0].Web_Service_Url__c); req.setTimeout(120000); req.setMethod('POST'); req.setBody(body); Http h = new Http();  HttpResponse res = h.send(req);
                    endreq =datetime.now(); status='Success'; response=res.getBody();
                    system.debug('resp' + response);

                    while (response==null && CURRENT_ATTEMPT <= MAX_ATTEMPTS) {
                            // time out given on Service, try again
                            CURRENT_ATTEMPT++; res = h.send(req); response=res.getBody();
                    } 
                }
                catch( CalloutException calle){
                    outInt.startReq=startReq;  outInt.endReq=endReq;  outInt.status=status;  outInt.code='INFORMADB_ES';     
                    outInt.response=response;  outInt.identifierReq=Nif;    outInt.xml='Error - InformaDB is down';    
                    return outInt;                
                }
            } 
            else
            {
                // test WebService CallOut
                StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
                mock.setStaticResource('InformaDB_ES_TestResp');             mock.setStatusCode(200);            mock.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                Test.setMock(HttpCalloutMock.class, mock);
                HttpRequest request = new HttpRequest();
                request.setEndpoint('http://api.salesforce.com/foo/bar');
                request.setMethod('GET');
                Http r = new Http();
                HttpResponse resp = r.send(request);
                response=resp.getbody();
            } 

            Dom.Document doc = new Dom.Document();
            // load the InformDB_ES xml into the document.
            doc.load(response);
            //Retrieve the root element for this document.
            Dom.XMLNode CurXML = doc.getRootElement();
           
            for(Dom.XMLNode root : CurXML.getChildElements()) {
               
                
                childBody=root.getChildren();
                
                for( integer l=0; l<childBody.size(); l++){
                    if(childBody[l].getName()=='getProductResponse'){
                        childCodeResp=childBody[l].getChildren();
                    }
                }
                

                for (integer i=0; i<childCodeResp.size();i++){
                    if(childCodeResp[i].getName()=='errorCode'){
                        errorCode=childCodeResp[i].getText();
                    }
                    if(childCodeResp[i].getName()=='errorDescription'){
                        errorMsg=childCodeResp[i].getText();
                       
                    }
                    if(binary==true){
                        if(childCodeResp[i].getName()=='attach'){
                            att=childCodeResp[i].getText();
                         }
                    
                    }
                    else if(childCodeResp[i].getName()=='product'){
                        childproduct=childCodeResp[i].getChildren();
                    }
                }
                
            }
            

            if(errorCode=='0' && (( childproduct !=null && childproduct.size()!=0 ) || att!=null) ){                                      
                xml = response;
                endreq=datetime.now();                      
                status='Success';             
            }
            else
            {
                // errorCode 11003 TaxNumber does not exist
                endreq=datetime.now();
                if(errorCode =='11003'){ 
                    xml='';                                               
                    status='Failure - Nif Does not exist in Database';  
               // all errorCodes 
                }else if(errorCode !='11003' || response==null || errorCode ==''){
                    xml='Erro na comunicação com a InformaDB';  
                    status='Failure';
                }                        
                response=errorCode + ' - ' + errorMsg;
                   
            }
              
            if(errorCode == '11005')
            {
                xml    = 'STOP-DISTRIBUTION';
                status = 'Failure'; 
            } 
           
            outInt.startReq=startReq;
            outInt.endReq=endReq;
            outInt.status=status;
            outInt.code='INFORMADB_ES';
            outInt.response=response;     
            outInt.identifierReq=Nif;
            outInt.xml=xml;  
            if(binary==true){
                outInt.pdf=EncodingUtil.base64Decode(att);
            }         
            return outInt;
        }
        catch (Exception e)
        {
            System.Debug('DBInfoServicesES InformadbGetReport - Error *** Report InformaDB erro getting report!');
            system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            outInt.startReq=datetime.now();            outInt.status='Failure';            outInt.code='INFORMADB_ES';            outInt.response=e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() ;
            outInt.identifierReq=Nif;            outInt.xml='Error - InformaDB is down';            return outInt;
        }
    }

    public static string getTranslatedValue(string field, string code){
        string trasnlateValue=code;
        List<InformaDB_ES_Translation__mdt> WSTranslations = [SELECT MasterLabel, QualifiedApiName, Field__c, Value__C, Translated_Value__c FROM InformaDB_ES_Translation__mdt];
        for(integer i=0; i<WSTranslations.size(); i++){
            if(WSTranslations[i].MasterLabel==field && WSTranslations[i].QualifiedApiName==field + '_'+code ){
                trasnlateValue=WSTranslations[i].Translated_Value__c;
            }
        }
        return trasnlateValue;
    }

    public static integer getRiskIndicator(string field, integer Rawscore, integer score){
        integer riskindicator=0;
        List<InformaDB_ES_RiskIndicator__mdt> WSRiskIndicator = [SELECT MasterLabel, QualifiedApiName, MinRawScore__c, MaxRawScore__c, RiskIndicator__c, score__c FROM InformaDB_ES_RiskIndicator__mdt];
        for(integer i=0; i<WSRiskIndicator.size(); i++){
            if(WSRiskIndicator[i].MasterLabel==field && WSRiskIndicator[i].MinRawScore__c<= Rawscore && WSRiskIndicator[i].MaxRawScore__c>= Rawscore 
                && WSRiskIndicator[i].score__c==score){
                riskindicator=integer.valueOf(WSRiskIndicator[i].RiskIndicator__c);
            }
        }
        return riskindicator;
    }

    public static DBProp parseDBInfoXML( String xml){
        try{
                Dom.Document doc = new Dom.Document();
                List<Dom.XmlNode> childBody = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childCodeResp = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childProduct = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childInfFin = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childIdLoc = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childId = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childTpIds = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childTpDenoms = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childTpDirecs = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childTpContacts = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childTpActivs = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childCaract = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childFin = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childOpCred = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childInfNeg= new List<Dom.XmlNode>();
                List<Dom.XmlNode> childIncResum = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childIncJudResum = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childIncidencias = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childIncJud = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childInc = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childFinData = new List<Dom.XmlNode>(); 
                List<Dom.XmlNode> childBalUltAno = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childBalAnoN_1 = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childBalAnoN_2 = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childPersons = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childDirFuncs = new List<Dom.XmlNode>();
                List<Dom.XmlNode> childDirFunc = new List<Dom.XmlNode>();

                


                DBProp valores= new DBProp();
                valores.ListContacto = new List<DBProp.Contacto>();

                // load the InformDB_ES xml into the document.
                doc.load(xml);
                //Retrieve the root element for this document.
                Dom.XMLNode CurXML = doc.getRootElement();

                for(Dom.XMLNode root : CurXML.getChildElements()) {
                     childBody=root.getChildren();
                }     
                for( integer l=0; l<childBody.size(); l++){
                    if(childBody[l].getName()=='getProductResponse'){
                        childCodeResp=childBody[l].getChildren();
                    }
                }

                // get level zero of product info
                for (integer i=0; i<childCodeResp.size();i++){
                    if(childCodeResp[i].getName()=='product'){
                        childProduct=childCodeResp[i].getChildren();
                    }
                }
                for (integer a=0; a<childProduct.size();a++){
                    if(childProduct[a].getName()=='informeComercial'){
                        childInfFin=childProduct[a].getChildren();
                        for (integer b=0; b<childInfFin.size();b++){
                            if(childInfFin[b].getName()=='identificacionLocalizacion'){
                                childIdLoc=childInfFin[b].getChildren();
                                for (integer c=0; c<childIdLoc.size(); c++){
                                    if(childIdLoc[c].getName()=='identificacion'){
                                        childId=childIdLoc[c].getChildren();
                                        for (integer d=0; d<childId.size(); d++){
                                             if(childId[d].getName()=='tipoIdentificaciones'){
                                                childTpIds=childId[d].getChildren();
                                                for (integer e=0; e<childTpIds.size(); e++){
                                                    if(childTpIds[e].getName()=='tipoIdentificacion'){
                                                        string auxtipo;
                                                        string valor;
                                                        if (childTpIds[e].getChildElement('tipologia', null)!=null ) {
                                                            auxtipo=childTpIds[e].getChildElement('tipologia', null).getText();
                                                        }
                                                        if (childTpIds[e].getChildElement('valor', null)!=null ) {
                                                            valor=childTpIds[e].getChildElement('valor', null).getText();
                                                        }
                                                        if(auxtipo=='01'){
                                                            valores.NumeroContribuinte=valor;
                                                        }
                                                    }
                                                }
                                            }
                                            if(childId[d].getName()=='tipoDenominaciones'){
                                                childTpDenoms=childId[d].getChildren();
                                                for (integer e=0; e<childTpDenoms.size(); e++){
                                                    if(childTpDenoms[e].getName()=='tipodenominacion'){
                                                        string auxtipo;
                                                        string auxsitu;
                                                        string valor;
                                                        if (childTpDenoms[e].getChildElement('valor', null)!=null ) {
                                                            valor=childTpDenoms[e].getChildElement('valor', null).getText();
                                                        }
                                                        
                                                        if (childTpDenoms[e].getChildElement('tipologia', null)!=null ) {
                                                            auxtipo=childTpDenoms[e].getChildElement('tipologia', null).getText();
                                                        }
                                                        if (childTpDenoms[e].getChildElement('situacion', null)!=null ) {
                                                            auxsitu=childTpDenoms[e].getChildElement('situacion', null).getText();
                                                        }
                                                        if(auxtipo=='01' && auxsitu=='01'){
                                                            valores.DenomEmp=valor;
                                                            valores.Nome=valor;
                                                        }
                                                    }
                                                }
                                            }
                                            if(childId[d].getName()=='tipoDirecciones'){
                                                childTpDirecs=childId[d].getChildren();
                                                for (integer g=0; g<childTpDirecs.size(); g++){
                                                    if(childTpDirecs[g].getName()=='direccion'){
                                                        string auxtipo='';
                                                        string auxsitu='';
                                                        string via='';
                                                        string valor='';
                                                        string nrcalle='';
                                                        string codpostal;
                                                        string municipio;
                                                      
                                                        if (childTpDirecs[g].getChildElement('tipologia', null)!=null ) {
                                                            auxtipo=childTpDirecs[g].getChildElement('tipologia', null).getText();
                                                        }
                                                        if (childTpDirecs[g].getChildElement('situacion', null)!=null ) {
                                                            auxsitu=childTpDirecs[g].getChildElement('situacion', null).getText();
                                                        }
                                                        if (childTpDirecs[g].getChildElement('via', null)!=null ) {
                                                            via=childTpDirecs[g].getChildElement('via', null).getText();
                                                        }
                                                        if (childTpDirecs[g].getChildElement('valor', null)!=null ) {
                                                            valor=childTpDirecs[g].getChildElement('valor', null).getText();
                                                        }
                                                        if (childTpDirecs[g].getChildElement('numeroCalle', null)!=null ) {
                                                            nrcalle=childTpDirecs[g].getChildElement('numeroCalle', null).getText();
                                                        }
                                                        if (childTpDirecs[g].getChildElement('codigoPostal', null)!=null ) {
                                                            codpostal=childTpDirecs[g].getChildElement('codigoPostal', null).getText();
                                                        }
                                                        if (childTpDirecs[g].getChildElement('municipio', null)!=null ) {
                                                            municipio=childTpDirecs[g].getChildElement('municipio', null).getText();
                                                        }

                                                        if(auxtipo=='01' && auxsitu=='01'){
                                                            if(nrcalle != ''){
                                                                valores.NomeVia=via + ' ' + valor + ', ' + nrcalle;
                                                            }
                                                            else{
                                                                valores.NomeVia=via + ' ' + valor ;
                                                            }
                                                            valores.Localidade = municipio;
                                                            valores.CodigoPostal= codpostal;
                                                        }
                                                        if(auxtipo=='03' && auxsitu=='01'){
                                                            valores.website=valor;
                                                        }
                                                    }
                                                }
                                            }
                                            if(childId[d].getName()=='tipoContactos'){
                                                childTpContacts=childId[d].getChildren();
                                                for (integer h=0; h<childTpContacts.size(); h++){
                                                    if(childTpContacts[h].getName()=='contacto'){
                                                        string auxtipo;
                                                        string auxsitu;
                                                        string valor;
                                                        if (childTpContacts[h].getChildElement('valor', null)!=null ) {
                                                            valor=childTpContacts[h].getChildElement('valor', null).getText();
                                                        }
                                                        
                                                        if (childTpContacts[h].getChildElement('tipologia', null)!=null ) {
                                                            auxtipo=childTpContacts[h].getChildElement('tipologia', null).getText();
                                                        }
                                                        if (childTpContacts[h].getChildElement('situacion', null)!=null ) {
                                                            auxsitu=childTpContacts[h].getChildElement('situacion', null).getText();
                                                        }
                                                        if(auxtipo=='03' && auxsitu=='01'){
                                                            valores.Telefone=valor;
                                                        }
                                                        if(auxtipo=='02' && auxsitu=='01'){
                                                            valores.Email=valor;
                                                        }
                                                       

                                                    }
                                                }
                                            }
                                            if(childId[d].getName()=='tipoActividades'){
                                                childTpActivs=childId[d].getChildren();
                                                for (integer i=0; i<childTpActivs.size(); i++){
                                                    if(childTpActivs[i].getName()=='actividad'){
                                                        string auxcod;
                                                        string auxtpcod;
                                                        string valor;
                                                        if (childTpActivs[i].getChildElement('codigo', null)!=null ) {
                                                            auxcod=childTpActivs[i].getChildElement('codigo', null).getText();
                                                        }
                                                        
                                                        if (childTpActivs[i].getChildElement('valor', null)!=null ) {
                                                            valor=childTpActivs[i].getChildElement('valor', null).getText();
                                                        }
                                                        if (childTpActivs[i].getChildElement('tipoCodificacion', null)!=null ) {
                                                            auxtpcod=childTpActivs[i].getChildElement('tipoCodificacion', null).getText();
                                                        }
                                                        if(auxtpcod=='03' ){
                                                            valores.CAE=auxcod;
                                                            valores.DescricaoCAE=valor;
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        } 
                                    }
                                    if(childIdLoc[c].getName()=='caracteristicas'){
                                        string dataconst;
                                        if (childIdLoc[c].getChildElement('formaLegal', null)!=null ) {
                                          valores.FormaJuridica=getTranslatedValue('FormaLegal',childIdLoc[c].getChildElement('formaLegal', null).getText());
                                        }
                                        if (childIdLoc[c].getChildElement('fechaConstitucion', null)!=null ) {
                                            dataconst=childIdLoc[c].getChildElement('fechaConstitucion', null).getText();
                                            list<string> auxdate=dataconst.split('/');

                                            valores.DataConstituicao=date.valueOf(auxdate[2]+'-'+auxdate[1]+'-'+auxdate[0]);
                                        }
                                        if (childIdLoc[c].getChildElement('capitalSocial', null)!=null ) {
                                          valores.CapitalSocial=decimal.valueOf((childIdLoc[c].getChildElement('capitalSocial', null).getText()).replace('.',''));
                                        }
                                        if (childIdLoc[c].getChildElement('empleados', null)!=null ) {
                                          valores.TotEmpregados=Integer.valueOf(childIdLoc[c].getChildElement('empleados', null).getText());
                                        }
                                        if (childIdLoc[c].getChildElement('status', null)!=null ) {
                                          valores.ValorEstado=getTranslatedValue('Status', childIdLoc[c].getChildElement('status', null).getText());
                                        }
                                    
                                    }
                                }
                            }
                            if(childInfFin[b].getName()=='informacionFinanciera'){
                                childFin=childInfFin[b].getChildren();
                                for (integer c=0; c<childFin.size(); c++){
                                    if(childFin[c].getName()=='sintesis'){
                                        childOpCred=childFin[c].getChildren();
                                         integer rawscore=0;
                                         for (integer d=0; d<childOpCred.size();d++){
                                             system.debug(childOpCred[d].getName());
                                            if(childOpCred[d].getName()=='opinionCredito'){
                                               
                                                if (childOpCred[d].getChildElement('nota', null)!=null ) {
                                                    valores.RiscoInforma=Integer.valueOf(childOpCred[d].getChildElement('nota', null).getText());
                                                }
                                                if (childOpCred[d].getChildElement('credito', null)!=null ) {
                                                    valores.OpCred=(childOpCred[d].getChildElement('credito', null).getText()).replace('.','');
                                                }
                                            }
                                            
                                             if(childOpCred[d].getName()=='ratingLiquidez'){                                               
                                                if (childOpCred[d].getChildElement('scoreLiquidez', null)!=null ) {
                                                    valores.scoreLiquidez=Integer.valueOf(childOpCred[d].getChildElement('scoreLiquidez', null).getText());
                                                }
                                            }

                                         
                                            if(childOpCred[d].getName()=='rawScoreEntregable'){
                                                rawscore=integer.ValueOf((childOpCred[d].getText()).replace('.',''));
                                            } 
                                            
                                            if(childOpCred[d].getName()=='scoreEntregable'){
                                                valores.PercentilScore=Integer.ValueOf(childOpCred[d].getText());
                                            }
                                             
                                            valores.IndRisco=getRiskIndicator('RiskIndicator',rawscore,valores.PercentilScore);
                                         }
                                    }

                                    if(childFin[c].getName()=='elementosFinancieros'){
                                        childFinData=childFin[c].getChildren();
                                        integer countyears=0;
                                        for(integer d=0; d<childFinData.size(); d++){
                                            if(childFinData[d].getName()=='datosEconomicos'){
                                               countyears+=1; 
                                            }
                                        }
                                        childBalUltAno=childFinData[countyears-1].getChildren();
                                        for (integer e=0; e<childBalUltAno.size();e++){
                                            if (childBalUltAno[e].getName()=='fecha') {
                                                    valores.AnoBalanco=integer.ValueOf((childBalUltAno[e].getText()).replace('.',''));

                                            }
                                             for (Integer f = 0; f< childBalUltAno[e].getAttributeCount(); f++ ) {
                                                if(childBalUltAno[e].getAttributeValue('codigo', childBalUltAno[e].getAttributeKeyNsAt(f))=='RVEN'){
                                                   valores.VendasUltimoAno=decimal.valueOf((childBalUltAno[e].gettext()).replace('.','')); 
                                                }
                                                if(childBalUltAno[e].getAttributeValue('codigo', childBalUltAno[e].getAttributeKeyNsAt(f))=='RRN'){
                                                   valores.ResultLiqUltimoAno=decimal.valueOf((childBalUltAno[e].gettext()).replace('.','')); 
                                                }
                                             }
                                        }
                                        if(countyears>1){
                                            childBalAnoN_1=childFinData[countyears-2].getChildren();
                                            for (integer f=0; f<childBalAnoN_1.size();f++){
                                                 for (Integer g = 0; g< childBalAnoN_1[f].getAttributeCount(); g++ ) {
                                                    if(childBalAnoN_1[f].getAttributeValue('codigo', childBalAnoN_1[f].getAttributeKeyNsAt(g))=='RVEN'){
                                                       valores.Vendas_n_1=decimal.valueOf((childBalAnoN_1[f].gettext()).replace('.','')); 
                                                    }
                                                    if(childBalAnoN_1[f].getAttributeValue('codigo', childBalAnoN_1[f].getAttributeKeyNsAt(g))=='RRN'){
                                                       valores.ResultLiqAno_n_1=decimal.valueOf((childBalAnoN_1[f].gettext()).replace('.','')); 
                                                    }
                                                 }
                                            }   
                                        }
                                        if(countyears>2){
                                            childBalAnoN_2=childFinData[countyears-3].getChildren();
                                            for (integer h=0; h<childBalAnoN_2.size();h++){
                                                 for (Integer i = 0; i< childBalAnoN_2[h].getAttributeCount(); i++ ) {
                                                    if(childBalAnoN_2[h].getAttributeValue('codigo', childBalAnoN_2[h].getAttributeKeyNsAt(i))=='RVEN'){
                                                       valores.Vendas_n_2=decimal.valueOf((childBalAnoN_2[h].gettext()).replace('.','')); 
                                                    }
                                                    if(childBalAnoN_2[h].getAttributeValue('codigo', childBalAnoN_2[h].getAttributeKeyNsAt(i))=='RRN'){
                                                       valores.ResultLiqAno_n_2=decimal.valueOf((childBalAnoN_2[h].gettext()).replace('.','')); 
                                                    }
                                                 }
                                            }   
                                        }
                                    }

                                }
                            }
                            if(childInfFin[b].getName()=='informacionNegativa'){
                                childInfNeg=childInfFin[b].getChildren();
                                for (integer c=0; c<childInfNeg.size(); c++){
                                    if(childInfNeg[c].getName()=='incidenciasResumen'){
                                        childIncResum=childInfNeg[c].getChildren();
                                        for (integer d=0; d<childIncResum.size(); d++){
                                            if(childIncResum[d].getName()=='incidenciasJudicialesResumen'){
                                                if (childIncResum[d].getChildElement('totalProcedimientoConcursal', null)!=null ) {
                                                    valores.IndApresInsol=childIncResum[d].getChildElement('totalProcedimientoConcursal', null).getText();
                                                }
                                                 if (childIncResum[d].getChildElement('demandas', null)!=null ) {
                                                    valores.TotIncidentes=Integer.valueOf(childIncResum[d].getChildElement('demandas', null).getText());
                                                }
                                            }
                                        }
                                    }
                                    if(childInfNeg[c].getName()=='incidencias'){
                                        childIncidencias=childInfNeg[c].getChildren();
                                        for (integer d=0; d<childIncidencias.size(); d++){
                                            if(childIncidencias[d].getName()=='incidenciasJudiciales'){
                                                childIncJud=childIncidencias[d].getChildren();
                                                for (integer e=0; e<childIncJud.size(); e++){
                                                    if(childIncJud[e].getName()=='incidenciasProcedimientoConcursal'){
                                                        childInc=childIncJud[e].getChildren();
                                                        for (integer f=0; f<childInc.size(); f++){
                                                            if(childInc[f].getName()=='incidencia'){
                                                                if (childInc[f].getChildElement('CodFaseDema', null)!=null ) {
                                                                    valores.indProcessoRevitalizacao=childIncResum[d].getChildElement('CodFaseDema', null).getText(); // needs translation
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
                            //Get Contact Information
                            if(childInfFin[b].getName()=='vinculosPersonas'){
                                childPersons=childInfFin[b].getChildren();
                                for (integer c=0; c<childPersons.size();c++){
                                    if(childPersons[c].getName()=='directivosFuncionales'){
                                        childDirFuncs=childPersons[c].getChildren();
                                        for(integer d=0; d< childDirFuncs.size(); d++) {
                                            if(childDirFuncs[d].getName()=='directivoFuncional'){
                                                DBProp.Contacto contacto = new DBProp.Contacto();
                                                childDirFunc=childDirFuncs[d].getChildren();
                                                if(childDirFuncs[d].getChildElement('cargo', null)!=null){
                                                    contacto.Tipo=getTranslatedValue('Tipo', childDirFuncs[d].getChildElement('cargo', null).getText());
                                                }
                                                if(childDirFuncs[d].getChildElement('nombre', null)!=null){
                                                    contacto.Apelido1=childDirFuncs[d].getChildElement('nombre', null).getText();
                                                }
                                                valores.ListContacto.add(contacto);
                                            }
                                        }
                                    }
                                }
                            }

                        }
                    }
                }    
//                system.debug(valores);
                return valores;
        }
        catch(Exception e){
            System.Debug('DBInfoXML parseDBXML - Report InformaDB Not Parsed!');
            system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return null;
        }
 
    }
    
}