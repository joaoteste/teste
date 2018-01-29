public class AttendReports implements Queueable, database.allowsCallouts {
    //Criacao - 02/12/16 - (BP)
    private ID     appId    {get;set;}
    private String clientNif{get;set;}
    private String cliid    {get;set;}
    
    public AttendReports(String appId, String clientNif,String cliid) 
    {
        this.appId      = appID;
        this.clientNif  = clientNif;
        this.cliid      = cliid;
    }

    public void execute(QueueableContext context) 
    {
        System.debug('***********ENTRADA NO MÉTODO ATTEND_REPORTS**********');
        
        Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
        Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();
        
        string xml;
        Blob Pdf=null;
        
        //System.debug('ATTENDREPORTS---> Antes do pedido XML...');
        outInt=DBInfoXML.InformadbGetReport( clientNif , 'XMLPROSP', 'Xml', 'Client'); 
        xml=outInt.xml;  

        System.debug('ATTENDREPORTS---> Depois do pedido XML...');
        
        //System.debug('ATTENDREPORTS---> Antes do pedido PDF...');
        outIntPdf=DBInfoXML.InformadbGetPdfReport(clientNif, 'XMLPROSP');
        pdf=outIntPdf.pdf;
                      
        System.debug('ATTENDREPORTS---> Depois do pedido PDF...\noutIntPdf.startReq: '+ outIntPdf.startReq  + '\n outIntPdf.endReq: '
                     +  outIntPdf.endReq + '\n outIntPdf.status: '+ outIntPdf.status+ '\n outIntPdf.response: '
                     +  outIntPdf.response + '\n outIntPdf.identifierReq: '+ outIntPdf.identifierReq);
        
        //System.debug('ATTENDREPORTS---> Antes dos Logs...');
        Utilities.LogIntegrationLongResponse( outInt.startReq, outInt.endReq, outInt.status, outInt.code, outInt.response,
                                                                                            outInt.identifierReq,xml);                                                                                                              
        
        if(!Test.isRunningTest())
        {
            slideInformadbPt.GetReport_element Aux_to_Log = SlideInformadbPt.get_XML_Request;
            String request_string=    'Request.tipId: '      + Aux_to_Log.tipId+ '      Request.valorId: '    + Aux_to_Log.valorId+ '       Request.idProcesso: ' + Aux_to_Log.idProcesso 
                + '     Request.bocados: '    + Aux_to_Log.bocados+ '       Request.refCliente: ' + Aux_to_Log.refCliente+ '        Request.tipOutput: '  + Aux_to_Log.tipOutput.TipoOutput[0] ;
            Utilities.LogIntegrationLongResponse( outIntPdf.startReq, outIntPdf.endReq, outIntPdf.status, outIntPdf.code, outIntPdf.response,outIntPdf.identifierReq,request_string); 
        }
        else
        {
            xml = '<Relatorio data_xml="2016-12-06" id_xml="41638716"><Identificacao><IDPrincipais><IDPrincipal><EstabelecimentoSecundario>N</EstabelecimentoSecundario>';
            xml += '</IDPrincipal><IDPrincipalX1><ICI>6200025197200000</ICI><DataUltMod>2011-02-09</DataUltMod></IDPrincipalX1></IDPrincipais><Anexas>';
            xml += '<Anexa tipo="ID01">500572585</Anexa><Anexa tipo="ID02">500572585</Anexa><Anexa tipo="ID03">337460971</Anexa></Anexas><Denominacoes><Denominacao situacao="1" tipo="1"><ValorDeno>JORGE &amp; JORGE, LDA</ValorDeno>';
            xml += '<DataInformacao>2002-07-05</DataInformacao></Denominacao></Denominacoes><FormasJuridicas><FormaJuridica situacao="1">LDA</FormaJuridica>';
            xml += '</FormasJuridicas><Estado><ValorEstado>B10</ValorEstado><DataInformacao>2011-02-09</DataInformacao></Estado><InformacoesLegais><InformacaoLegal>';
            xml += '<DataInicioNegocios>1968-10-29</DataInicioNegocios><ConservatoriaActual>1810</ConservatoriaActual></InformacaoLegal><InformacaoLegalX1>';
            xml += '<DataConstituicao>1968-10-29</DataConstituicao></InformacaoLegalX1></InformacoesLegais><Capitais divisa="EUR"><Capital><CapitalSocial>5000</CapitalSocial>';
            xml += '</Capital></Capitais><Empregados><DetalheEmpregado situacao="1"><Empregado><Efectivos>1</Efectivos><DataInformacao>2007-12-31</DataInformacao></Empregado>';
            xml += '<EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>1</Efectivos>';
            xml += '<DataInformacao>2006-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2">';
            xml += '<Empregado><Efectivos>1</Efectivos><DataInformacao>2002-07-05</DataInformacao></Empregado></DetalheEmpregado></Empregados></Identificacao><Localizacao>';
            xml += '<Moradas><DetalheMorada situacao="1" tipo="A40"><Morada><ValorMorada>OLIVEIRA DE FRADES 3680-000 OLIVEIRA DE FRADES</ValorMorada></Morada></DetalheMorada>';
            xml += '<DetalheMorada situacao="1" tipo="B10"><Morada><NomeVia>PORCELHE</NomeVia><CodigoPostal>3680-019</CodigoPostal><EnderecoPostal>ARCOZELO DAS MAIAS</EnderecoPostal>';
            xml += '<Localidade>PORCELHE</Localidade><Concelho>OLIVEIRA DE FRADES</Concelho></Morada><MoradaX1><Freguesia>ARCOZELO DAS MAIAS</Freguesia><Distrito>18</Distrito><CoordX>-8.27231247287</CoordX><CoordY>40.7369174569</CoordY></MoradaX1>';
            xml += '</DetalheMorada></Moradas></Localizacao><Actividades><RamoNegocio><DetalheActividade situacao="1" tipo="1"><Actividade><Descricao>Serviços</Descricao><SIC>4119</SIC></Actividade><ActividadeX1>49392</ActividadeX1></DetalheActividade>';
            xml += '</RamoNegocio></Actividades><ResumoX1><IndBolsa>0</IndBolsa><IndTelefone>0</IndTelefone><IndFax>0</IndFax><IndEmail>0</IndEmail><IndOPC>1</IndOPC><TotEmpregados>1</TotEmpregados><IndImport>0</IndImport><IndExport>0</IndExport><IndImprensa>0</IndImprensa>';
            xml += '<IndEmpresaMae>0</IndEmpresaMae><IndSubsidiarias>0</IndSubsidiarias><TotSubsidiarias>0</TotSubsidiarias><IndParticipadas>0</IndParticipadas><TotParticipadas>0</TotParticipadas><IndIncidentes>0';
            xml += '</IndIncidentes><TotIncidentes>0</TotIncidentes><IndAccaoInsolvencia>0</IndAccaoInsolvencia><IndProcessoInsolvencia>0</IndProcessoInsolvencia><NumFiliais>0</NumFiliais><IndExpPagamentos>0</IndExpPagamentos><IndProcAdmon>0</IndProcAdmon>';
            xml += '<IndCertificacao>0</IndCertificacao><CapacidadeFinanceira>NQ</CapacidadeFinanceira><CapitalSocial>5000</CapitalSocial><CAE>49392</CAE><DataConstituicao>1968-10-29</DataConstituicao><DataPublicacaoLegal>2011-02-17</DataPublicacaoLegal><DataInicioNegocios>1968-10-29';
            xml += '</DataInicioNegocios><EstadoActCod>X</EstadoActCod><CF2>NQ</CF2><PubLegaisUlt12meses>0</PubLegaisUlt12meses><IndDimensao>ND</IndDimensao><IndProcessoRevitalizacao>0</IndProcessoRevitalizacao><IndDormant>0</IndDormant><IndSActComer>0</IndSActComer></ResumoX1><FichaEmpresaX1><Nome>JORGE &amp; JORGE, LDA</Nome>';
            xml += '<Duns>337460971</Duns><NumeroContribuinte>500572585</NumeroContribuinte><TipoMorada>UNICA</TipoMorada><NomeVia>PORCELHE</NomeVia><Localidade>PORCELHE</Localidade><CodigoPostal>3680-019</CodigoPostal><EnderecoPostal>ARCOZELO DAS MAIAS</EnderecoPostal><SIC>4119</SIC><DescricaoSIC>Transporte urbano de passageiros, NCA</DescricaoSIC>';
            xml += '<CAE>49392</CAE><DescricaoCAE>Outros transportes terrestres de passageiros diversos, n.e</DescricaoCAE><DataUltimoBalancoPublicado>2007</DataUltimoBalancoPublicado><NumeroConsultas>0';
            xml += '</NumeroConsultas><IndMediasSectoriais>0</IndMediasSectoriais><TipoEmpresa>Real</TipoEmpresa></FichaEmpresaX1></Relatorio>';
        }                                     

        System.debug('ATTENDREPORTS---> Depois dos Logs...');
        
        if (xml=='Error - InformaDB is down') 
        {
            //Utilities.LogIntegration(outInt.startReq, outInt.endReq, outInt.status, outInt.code, outInt.response, outInt.identifierReq);
            //Utilities.LogIntegration(outIntPdf.startReq, outIntPdf.endReq, outIntPdf.status, outIntPdf.code, outIntPdf.response, outIntPdf.identifierReq);
            //Utilities.SendEmail('info@candor.pt', 
              //                  'O serviço da InformaDB está em baixo. Volte a tentar retirar o report mais tarde!','Erro WebService InformaDB');
            Notification__c notif= new Notification__c( application__c=appId,Message__c='O serviço do nosso parceiro InformaDB está com problemas: A decisão poderá demorar mais algum tempo.'); 
            insert notif;return;
        }  
        else 
            if ( xml=='Erro na comunicação com a InformaDB')
            {
                //Utilities.LogIntegration(outInt.startReq, outInt.endReq, outInt.status, outInt.code, outInt.response, outInt.identifierReq);
                //Utilities.LogIntegration(outIntPdf.startReq, outIntPdf.endReq, outIntPdf.status, outIntPdf.code, 
                //                                                                              outIntPdf.response, outIntPdf.identifierReq);
                //Utilities.SendEmail('info@candor.pt', 
                 //                  'O serviço da InformaDB está em baixo. Volte a tentar retirar o report mais tarde!','Erro WebService InformaDB');
                Notification__c notif= new Notification__c( application__c=appId,Message__c='O serviço do nosso parceiro InformaDB está com problemas: A decisão poderá demorar mais algum tempo.'); 
                insert notif;return;
            } 
            else//ALTERACAO - 20/07/17 - quando os reports estao a ser actualizados serão reprocessados até que estes estejam novamente disponiveis (BP)
                if(xml == 'STOP-DISTRIBUTION')
                {
                    Application__c app    = new Application__c(id=appId,Status__c = 'Application - Pendent');update app;
                    Account        client = new Account(id = cliid,Credit_Line_Status__c = 'Credit Line - Pendent',Updating_Report__c = true);update client;
                    Notification__c notif= new Notification__c( application__c=appId,Message__c='O serviço do nosso parceiro InformaDB está com problemas: A decisão poderá demorar mais algum tempo.');insert notif;
                    return;
                }
                else
                    if(xml!='' && xml != null)
                    {
                        DBProp dbprop=DBInfoXML.parseDBXML(xml);    
                        ReportDB__c report=DBInfoXML.UpdateReport(dbprop, 'Client', cliid, Pdf); 
                        
                        Account        client     = new Account(id = cliid);
                        client.Updating_Report__c = false;
                        update client;

                        System.debug('ATTENDREPORTS---> ENTRADA NO METODO GetCreditLineStatus');
                        System.debug('PARAMETROS DE ENTRADA---CLIID: '+cliid+' appId: '+appId);
                        //ScoreCardConfig.GetCreditLineStatus( cliid, appId);//alterado para fora do if. Não tomava decisão para clientes sem informação fincanceira
                        System.debug('ATTENDREPORTS---> SAIDA DO METODO GetCreditLineStatus');
                    }
        ScoreCardConfig.GetCreditLineStatus( cliid, appId);
    }
}