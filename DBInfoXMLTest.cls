@isTest (SeeAllData=true)
public class DBInfoXMLTest {
 	

  @isTest
  public static void DBInfoXMLTest () 
  {
    // test WebService CallOut
    string ClientType;
    ClientType='Client';
    Blob pdf=Blob.valueOf('This is a string test to pdf');
    Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('XMLNewClient');   
    mock.setStatusCode(200); 
    mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
	HttpRequest req = new HttpRequest();
    req.setEndpoint('http://api.salesforce.com/foo/bar');
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    string xmlnew=res.getbody();
    outInt=DBInfoXML.InformadbGetReport('508898960', 'XMLCOMER','Xml', 'Client');
  	string xml=outInt.xml;
    Test.startTest();

    DBProp dbprop=DBInfoXML.parseDBXML(xml);
	ReportDB__C rep = DBInfoXML.UpdateReport(dbprop,'Client', '0012400000QeLPVAA3', pdf);
    
    DBProp dbprop1=DBInfoXML.parseDBXML(xml);
    ReportDB__C rep1= DBInfoXML.UpdateReport(dbprop1,ClientType, '0012400000QeLPVAA3', pdf);
    
    outIntPdf=DBInfoXML.InformadbGetPdfReport('508898960', 'XMLCOMER');
    Test.stopTest();
  }

  @isTest
  public static void DBInfoXMLTest0_1(){
    string ClientType;
    ClientType='Client';
    Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('XMLNewClient');   
    mock.setStatusCode(200); 
    mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
        HttpRequest req = new HttpRequest();
    req.setEndpoint('http://api.salesforce.com/foo/bar');
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    string xmlnew=res.getbody();

    Test.startTest();
    DBProp dbprop=DBInfoXML.parseDBXML(xmlnew);
    Blob pdf = Blob.valueOf('<Relatorio data_xml="2016-05-10" id_xml="31237612"><Identificacao><IDPrincipais><IDPrincipal><EstabelecimentoSecundario>N</EstabelecimentoSecundario></IDPrincipal><IDPrincipalX1><ICI>6201599245100000</ICI><DataUltMod>2015-03-17</DataUltMod>');
    ReportDB__C rep1 = DBInfoXML.UpdateReport(dbprop,ClientType, '0012400000QeLPVAA3', pdf); 
    ClientType='Lead';
    ReportDB__c Report= DBInfoXML.UpdateReport(dbprop,ClientType, '00Q24000001IIlYEAW', pdf);
    ClientType='';
    Test.stopTest();
  }
  
  @isTest
  public static void DBInfoXMLTest0 () 
  {
    string ClientType;
    ClientType='Client';
    Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();
    Blob pdf = Blob.valueOf('test');


    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('XMLNewClient');   
    mock.setStatusCode(200); 
    mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://api.salesforce.com/foo/bar');
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    string xmlnew=res.getbody();

    //New Account Client
    Account client = new Account();
    client.Name = '504092090'; 
    client.Type = 'Customer - Channel';
    client.NIF__c = '504092090';
    Client.Date_Of_Establishment__c = Date.newInstance(2015, 01, 01);
    insert client;

    Test.startTest();

    DBProp dbpropnew=DBInfoXML.parseDBXML(xmlnew);
	ReportDB__C repnew1= DBInfoXML.UpdateReport(dbpropnew,ClientType, client.Id, pdf);
    ClientType='Client';
	ReportDB__C repnew2= DBInfoXML.UpdateReport(dbpropnew,ClientType, client.Id, pdf);

    Test.stopTest();
  }  

  @isTest
  public static void DBInfoXMLTest_2 () 
  {
    // test WebService CallOut
    string ClientType;
    ClientType='Client';
    Blob pdf=null;

    Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('XMLNewClient');   
    mock.setStatusCode(200); 
    mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://api.salesforce.com/foo/bar');
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    string xmlnew=res.getbody();
    //HttpResponse res=DBInfoXMLTest.getInfoFromExternalService('http://api.salesforce.com/foo/bar');
    
    //New Account Client
    Account client = new Account();
    client.Name = '508898961'; 
    client.Type = 'Customer - Channel';
    client.NIF__c = '508898961';
    Client.Date_Of_Establishment__c = Date.newInstance(2015, 01, 01);
    insert client;

    outInt=DBInfoXML.InformadbGetReport('508898961', 'XMLCOMER','Xml', 'Client');
    string xml=outInt.xml;
    
    DBProp dbprop=DBInfoXML.parseDBXML(xml);
    ReportDB__C rep= DBInfoXML.UpdateReport(dbprop,'Client', client.Id, pdf);
    
    Test.startTest();
    DBProp dbprop2=DBInfoXML.parseDBXML(xmlnew);
    ReportDB__C rep1= DBInfoXML.UpdateReport(dbprop2,ClientType, client.Id, pdf);
    outIntPdf=DBInfoXML.InformadbGetPdfReport('508898961', 'XMLCOMER');
    Test.stopTest();

  }  

  @isTest
  public static void  DBInfoXMLTest_3(){
     // test WebService CallOut
    string ClientType;
    ClientType='Client';
    Blob pdf=null;

    Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('XMLNewClient');   
    mock.setStatusCode(200); 
    mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://api.salesforce.com/foo/bar');
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    string xmlnew=res.getbody();

    //New Account Client
    Account client = new Account();
    client.Name = '508898963'; 
    client.Type = 'Customer - Channel';
    client.NIF__c = '508898963';
    Client.Date_Of_Establishment__c = Date.newInstance(2015, 01, 01);
    insert client;
   /* pdf = Blob.valueOf('<Relatorio data_xml="2016-05-10" id_xml="31237612"><Identificacao><IDPrincipais><IDPrincipal><EstabelecimentoSecundario>N</EstabelecimentoSecundario></IDPrincipal><IDPrincipalX1><ICI>6201599245100000</ICI><DataUltMod>2015-03-17</DataUltMod>');
    rep1= DBInfoXML.UpdateReport(dbprop1,ClientType, '0012400000QeLPVAA3', pdf); 
    ClientType='Lead';*/
   
    Test.startTest();
        DBProp dbprop=DBInfoXML.parseDBXML(xmlnew);
        ReportDB__c Report1= DBInfoXML.UpdateReport(dbprop,ClientType, client.Id, pdf);
        DBProp dbpropnew=DBInfoXML.parseDBXML(xmlnew);
        ClientType='Lead';
        ReportDB__C repnew= DBInfoXML.UpdateReport(dbpropnew,ClientType, client.Id, pdf);
    Test.stopTest();
  }
    
  @isTest
  public static void BOReportTest () 
  {
    string fileId=BOReport.GetInformaDBPdfAttachId( 'a0M24000007JigUEAS', '508898960');
    //test WebService CallOut
    string ClientType;
    ClientType='Client';
    Blob pdf=null;

    //string InId='0012400000Q2lSOAAZ';
    //Test.startTest();
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('testreport');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
	  slideInformadbPt.SlideResponse gett = new slideInformadbPt.SlideResponse ();
    //HttpResponse res=DBInfoXMLTest.getInfoFromExternalService('http://api.salesforce.com/foo/bar');
  	string xml=BOReport.DownladAndGetReport('508898960','Client' ,'0012400000QeLPVAA3', 'XMLCOMER' );      
  }
    
  @isTest
  public static void testGetTranslatedInfo() 
  {    	
	TranslateInfo.GetTranslatedInfo('03', 'A01', '2010-05-05');
  	TranslateInfo.GetFormaObrigarVal('uma assinatura');
  }
  
  public static testmethod void testSendEmail( ) 
  {
     Utilities.SendEmail('martadads@hotmail.com','teste', 'teste');  
  }

  @isTest static void dBInfoXML_coverException_test()
  {
    DBInfoXML.InformadbGetReport(null, 'XMLCOMER','Xml', null);
    ReportDB__C rep= DBInfoXML.UpdateReport(null,'Client', null, null);
    DBInfoXML.InformadbGetPdfReport(null, 'XMLCOMER');
  }

    @isTest static void dBInfoXML_existingAccount_test_0()
  {
    //Test.startTest();

    // test WebService CallOut
    string ClientType;
    ClientType='Client';
    Blob pdf=null;
    Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();

    Account client = new Account(name='111222333',nif__c='111222333',Type = 'Customer - Channel');
    
    //string InId='0012400000RRVwYAAX';
    //Test.startTest();
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('XMLNewClient');   
    mock.setStatusCode(200); 
    mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://api.salesforce.com/foo/bar');
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    string xmlnew=res.getbody();
    //HttpResponse res=DBInfoXMLTest.getInfoFromExternalService('http://api.salesforce.com/foo/bar');
    outInt=DBInfoXML.InformadbGetReport('111222333', 'XMLCOMER','Xml', 'Client');
    string xml=outInt.xml;
    DBInfoXML.parseDBXML(xml);
    DBProp dbprop=DBInfoXML.parseDBXML(xml);

    insert client;
    //21/06/17 - necessario por nif (BP)
    pdf = Blob.valueOf('<Relatorio data_xml="2016-05-10" id_xml="31237612"><Identificacao><IDPrincipais><IDPrincipal><EstabelecimentoSecundario>N</EstabelecimentoSecundario></IDPrincipal><IDPrincipalX1><ICI>6201599245100000</ICI><DataUltMod>2015-03-17</DataUltMod>');

    // test Report InformaDB Upsert
    dbprop.NumeroContribuinte = '111222333';
    dbprop.TotEmpregados = null;
    dbprop.TotEmpregados = null;
    dbprop.Localidade ='Rua dos testes nº666 , Freguesia do Salesforce, Dream Country.';
    dbprop.DataConstituicao = Date.valueOf('1680-01-01');
    dbprop.EnderecoPostal = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.CodigoPostal = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.NomeVia = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.SituacaoContributiva ='A empresa não deve nada, encontra-se com a sua situação regularizada, nunca se atrasando nos pagamentos das mensalidades que a ela lhe dizem respeito. Encontra-se no seu auge empresarial, empregando deste modo 500 colaboradores. Foi sediada na Comarca de Lisboa com o registo xxxxx.';
     
    Test.startTest();
    ReportDB__C rep= DBInfoXML.UpdateReport(dbprop,'Client', client.id, pdf);
    
    // outInt=DBInfoXML.InformadbGetReport('508898960', 'XMLCOMER','Xml', ClientType);
    string xml1=outInt.xml;
    // outInt=DBInfoXML.InformadbGetReport('508898960', 'XMLCOMER','Xml', ClientType);
    string xml5=outInt.xml;
        
    //system.debug(xml5);
    DBProp dbprop5=DBInfoXML.parseDBXML(xml5);
    DBInfoXML.parseDBXML(xml1);
    DBProp dbprop1=DBInfoXML.parseDBXML(xml1);
       
    ReportDB__C rep1= DBInfoXML.UpdateReport(dbprop1,ClientType, client.id, pdf);
    outIntPdf=DBInfoXML.InformadbGetPdfReport('111222333', 'XMLCOMER');
    //Pdf=outIntPdf.pdf;
    //pdf.DataConstituicao = Date.newInstance(1200, 04,07);
    pdf = Blob.valueOf('<Relatorio data_xml="2017-04-06" id_xml="45227835"><Identificacao><IDPrincipais><IDPrincipal><EstabelecimentoSecundario>N</EstabelecimentoSecundario></IDPrincipal><IDPrincipalX1><ICI>6200044646500000</ICI><DataUltMod>2017-03-24</DataUltMod></IDPrincipalX1></IDPrincipais><Anexas><Anexa tipo="ID01">500772037</Anexa><Anexa tipo="ID02">500772037</Anexa><Anexa tipo="ID03">449689512</Anexa></Anexas><Denominacoes><Denominacao situacao="1" tipo="1"><ValorDeno>ERNESTO PEDRO ANDRÉ, LDA</ValorDeno><DataInformacao>2013-08-12</DataInformacao></Denominacao></Denominacoes><FormasJuridicas><FormaJuridica situacao="1">LDA</FormaJuridica></FormasJuridicas><Estado><ValorEstado>A00</ValorEstado><DataInformacao>2013-08-12</DataInformacao></Estado><InformacoesLegais><InformacaoLegal><DataInicioNegocios>1978-05-23</DataInicioNegocios><FormaObrigar>2 assinaturas</FormaObrigar><ConservatoriaActual>1015</ConservatoriaActual><DataRegistoConservatoria>1978-01-01</DataRegistoConservatoria></InformacaoLegal><InformacaoLegalX1><DataConstituicao>1978-03-17</DataConstituicao></InformacaoLegalX1></InformacoesLegais><Contactos><DetalheContacto tipo="A10"><Contacto>236959303</Contacto></DetalheContacto><DetalheContacto tipo="A12"><Contacto>236959300</Contacto><ContactoX1><Departamento>D001</Departamento></ContactoX1></DetalheContacto><DetalheContacto tipo="A13"><Contacto>236959301</Contacto></DetalheContacto><DetalheContacto tipo="C10"><Contacto>236959308</Contacto></DetalheContacto><DetalheContacto tipo="C10"><Contacto>236959309</Contacto></DetalheContacto><DetalheContacto tipo="D10"><ContactoX1><NomeContacto>oficina@epandre.pt</NomeContacto></ContactoX1></DetalheContacto><DetalheContacto tipo="D10"><ContactoX1><Departamento>D015</Departamento><NomeContacto>vendas@epandre.pt</NomeContacto></ContactoX1></DetalheContacto><DetalheContacto tipo="D10"><ContactoX1><Departamento>D025</Departamento><NomeContacto>contab@epandre.pt</NomeContacto></ContactoX1></DetalheContacto><DetalheContacto tipo="D10"><ContactoX1><NomeContacto>epandre@epandre.pt</NomeContacto></ContactoX1></DetalheContacto></Contactos><Capitais divisa="EUR"><Capital><CapitalSocial>149639.37</CapitalSocial></Capital></Capitais><Empregados><DetalheEmpregado situacao="1"><Empregado><Efectivos>14</Efectivos><DataInformacao>2015-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>14</Efectivos><DataInformacao>2014-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>15</Efectivos><DataInformacao>2013-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>15</Efectivos><DataInformacao>2012-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>15</Efectivos><DataInformacao>2011-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>20</Efectivos><DataInformacao>2010-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado></Empregados></Identificacao><Localizacao><Moradas><DetalheMorada situacao="1" tipo="A10"><MoradaX1><Website>www.epandre.pt</Website></MoradaX1></DetalheMorada><DetalheMorada situacao="1" tipo="B10"><Morada><NomeVia>MATOS</NomeVia><CodigoPostal>3105-064</CodigoPostal><EnderecoPostal>CARRIÇO</EnderecoPostal><Localidade>MATOS DO CARRIÇO</Localidade><Concelho>POMBAL</Concelho></Morada><MoradaX1><Freguesia>CARRIÇO</Freguesia><Distrito>10</Distrito><CoordX>-8.80608170797</CoordX><CoordY>39.9822307383</CoordY></MoradaX1></DetalheMorada><DetalheMorada situacao="1" tipo="B12"><Morada><NomeVia>MATOS</NomeVia><CodigoPostal>3105-064</CodigoPostal><EnderecoPostal>CARRIÇO</EnderecoPostal><Localidade>MATOS DO CARRIÇO</Localidade><Concelho>POMBAL</Concelho></Morada><MoradaX1><Freguesia>CARRIÇO</Freguesia><Distrito>10</Distrito><CoordX>-8.80608170797</CoordX><CoordY>39.9822307383</CoordY></MoradaX1></DetalheMorada></Moradas></Localizacao><Actividades><RamoNegocio><DetalheActividade situacao="1" tipo="1"><Actividade><Descricao>indústria de reparação de viaturas, estação de serviço e retalhista de automóveis e peças 100%</Descricao><SIC>7539</SIC></Actividade><ActividadeX1>45200</ActividadeX1></DetalheActividade><DetalheActividade situacao="1" tipo="2"><Actividade><SIC>5511</SIC></Actividade><ActividadeX1>45110</ActividadeX1></DetalheActividade></RamoNegocio></Actividades><Ligacoes><LigacoescomTerceiros><DetalheLigacaocomTerceiro situacao="1" tipo="C10"><LigacaocomTerceiro>NOVO BANCO, S.A.</LigacaocomTerceiro></DetalheLigacaocomTerceiro><DetalheLigacaocomTerceiro situacao="1" tipo="C10"><LigacaocomTerceiro>BANCO COMERCIAL PORTUGUÊS, S.A.</LigacaocomTerceiro></DetalheLigacaocomTerceiro><DetalheLigacaocomTerceiro situacao="1" tipo="C10"><LigacaocomTerceiro>BANCO SANTANDER TOTTA, S.A.</LigacaocomTerceiro></DetalheLigacaocomTerceiro><DetalheLigacaocomTerceiro situacao="1" tipo="I10"><LigacaocomTerceiro>LUSITÂNIA - COMPANHIA DE SEGUROS, S.A.</LigacaocomTerceiro></DetalheLigacaocomTerceiro></LigacoescomTerceiros><LigacoescomPessoas><DetalheLigacaoPessoa situacao="1" tipo="SOCGER"><LigacaoPessoa><Apelido1>Andre</Apelido1><Apelido2>Leal</Apelido2><Nome>Leonel</Nome><TituloAcademico>ENG</TituloAcademico></LigacaoPessoa><LigacaoPessoaX1><Sexo>H</Sexo><EstadoPessoa>V</EstadoPessoa><Classificacao>G</Classificacao><Ordenacao>250</Ordenacao></LigacaoPessoaX1></DetalheLigacaoPessoa><DetalheLigacaoPessoa situacao="1" tipo="SOCGER"><LigacaoPessoa><Apelido1>Andre</Apelido1><Apelido2>Maria Leal</Apelido2><Nome>Lidia</Nome></LigacaoPessoa><LigacaoPessoaX1><Sexo>M</Sexo><EstadoPessoa>V</EstadoPessoa><Classificacao>G</Classificacao><Ordenacao>250</Ordenacao></LigacaoPessoaX1></DetalheLigacaoPessoa><DetalheLigacaoPessoa situacao="1" tipo="SOCGER"><LigacaoPessoa><Apelido1>Andre</Apelido1><Apelido2>Pedro</Apelido2><Nome>Ernesto</Nome></LigacaoPessoa><LigacaoPessoaX1><Sexo>H</Sexo><EstadoPessoa>V</EstadoPessoa><Classificacao>G</Classificacao><Ordenacao>250</Ordenacao></LigacaoPessoaX1></DetalheLigacaoPessoa></LigacoescomPessoas></Ligacoes><InformacoesFinanceiras><Balancos numAnos="4"><DetalheBalanco divisa="EUR" subtipo="12" tipo="B00"><Balanco><DataEncerramento>2015-12-31</DataEncerramento><Ano>2015</Ano><Contabilidade>NCFR-PE</Contabilidade><Partidas><Partida CodigoPartida="PG_1011">75861.22</Partida><Partida CodigoPartida="PG_1012">0</Partida><Partida CodigoPartida="PG_1013">0</Partida><Partida CodigoPartida="PG_1014">1377.69</Partida><Partida CodigoPartida="PG_1015">0</Partida><Partida CodigoPartida="PG_1016">0</Partida><Partida CodigoPartida="PG_1017">0</Partida><Partida CodigoPartida="PG_1018">0</Partida><Partida CodigoPartida="PG_1019">0</Partida><Partida CodigoPartida="PG_1020">0</Partida><Partida CodigoPartida="PG_1021">0</Partida><Partida CodigoPartida="PG_1023">77238.91</Partida><Partida CodigoPartida="PG_1024">995523.41</Partida><Partida CodigoPartida="PG_1025">0</Partida><Partida CodigoPartida="PG_1026">159776.36</Partida><Partida CodigoPartida="PG_1027">80.41</Partida><Partida CodigoPartida="PG_1028">3517.46</Partida><Partida CodigoPartida="PG_1029">0</Partida><Partida CodigoPartida="PG_1030">0</Partida><Partida CodigoPartida="PG_1031">8195.40</Partida><Partida CodigoPartida="PG_1032">1500</Partida><Partida CodigoPartida="PG_1033">0</Partida><Partida CodigoPartida="PG_1034">0</Partida><Partida CodigoPartida="PG_1035">21092.73</Partida><Partida CodigoPartida="PG_1036">0</Partida><Partida CodigoPartida="PG_1037">1189685.77</Partida><Partida CodigoPartida="PG_1038">1266924.68</Partida><Partida CodigoPartida="PG_1039">149639.37</Partida><Partida CodigoPartida="PG_1040">0</Partida><Partida CodigoPartida="PG_1041">536245.67</Partida><Partida CodigoPartida="PG_1042">0</Partida><Partida CodigoPartida="PG_1043">8573.77</Partida><Partida CodigoPartida="PG_1044">69706.59</Partida><Partida CodigoPartida="PG_1045">4460.18</Partida><Partida CodigoPartida="PG_1046">0</Partida><Partida CodigoPartida="PG_1047">0</Partida><Partida CodigoPartida="PG_1048">0</Partida><Partida CodigoPartida="PG_1049">3979.59</Partida><Partida CodigoPartida="PG_1050">0</Partida><Partida CodigoPartida="PG_1051">772605.17</Partida><Partida CodigoPartida="PG_1052">0</Partida><Partida CodigoPartida="PG_1053">0</Partida><Partida CodigoPartida="PG_1054">0</Partida><Partida CodigoPartida="PG_1055">0</Partida><Partida CodigoPartida="PG_1056">0</Partida><Partida CodigoPartida="PG_1058">0</Partida><Partida CodigoPartida="PG_1059">108882.05</Partida><Partida CodigoPartida="PG_1060">0</Partida><Partida CodigoPartida="PG_1061">13293.52</Partida><Partida CodigoPartida="PG_1062">257410</Partida><Partida CodigoPartida="PG_1063">76250</Partida><Partida CodigoPartida="PG_1064">0</Partida><Partida CodigoPartida="PG_1065">38483.94</Partida><Partida CodigoPartida="PG_1066">0</Partida><Partida CodigoPartida="PG_1067">0</Partida><Partida CodigoPartida="PG_1068">0</Partida><Partida CodigoPartida="PG_1069">0</Partida><Partida CodigoPartida="PG_1070">494319.51</Partida><Partida CodigoPartida="PG_1071">494319.51</Partida><Partida CodigoPartida="PG_1072">1266924.68</Partida><Partida CodigoPartida="PG_1073">944090.02</Partida><Partida CodigoPartida="PG_1074">0</Partida><Partida CodigoPartida="PG_1075">0</Partida><Partida CodigoPartida="PG_1076">0</Partida><Partida CodigoPartida="PG_1077">0</Partida><Partida CodigoPartida="PG_1078">637930.18</Partida><Partida CodigoPartida="PG_1079">82521.90</Partida><Partida CodigoPartida="PG_1080">183215.05</Partida><Partida CodigoPartida="PG_1081">0</Partida><Partida CodigoPartida="PG_1082">0</Partida><Partida CodigoPartida="PG_1083">0</Partida><Partida CodigoPartida="PG_1084">0</Partida><Partida CodigoPartida="PG_1085">0</Partida><Partida CodigoPartida="PG_1086">0</Partida><Partida CodigoPartida="PG_1087">4.20</Partida><Partida CodigoPartida="PG_1088">12750.26</Partida><Partida CodigoPartida="PG_1089">27676.83</Partida><Partida CodigoPartida="PG_1090">17466.06</Partida><Partida CodigoPartida="PG_1091">0</Partida><Partida CodigoPartida="PG_1092">10210.77</Partida><Partida CodigoPartida="PG_1093">0</Partida><Partida CodigoPartida="PG_1094">6231.18</Partida><Partida CodigoPartida="PG_1095">3979.59</Partida><Partida CodigoPartida="PG_1096">0</Partida><Partida CodigoPartida="PG_1097">3979.59</Partida><Partida CodigoPartida="PG_1098">0</Partida><Partida CodigoPartida="PG_1105">768625.58</Partida></Partidas></Balanco><BalancoX1><Duracao>12</Duracao><NumeroEmpregados>14</NumeroEmpregados><Unidade>0</Unidade><CapitalSocial>149639.37</CapitalSocial></BalancoX1></DetalheBalanco><DetalheBalanco divisa="EUR" subtipo="12" tipo="B00"><Balanco><DataEncerramento>2014-12-31</DataEncerramento><Ano>2014</Ano><Contabilidade>NCFR-PE</Contabilidade><Partidas><Partida CodigoPartida="PG_1011">82577.28</Partida><Partida CodigoPartida="PG_1012">0</Partida><Partida CodigoPartida="PG_1013">0</Partida><Partida CodigoPartida="PG_1014">1377.69</Partida><Partida CodigoPartida="PG_1015">0</Partida><Partida CodigoPartida="PG_1016">0</Partida><Partida CodigoPartida="PG_1017">0</Partida><Partida CodigoPartida="PG_1018">0</Partida><Partida CodigoPartida="PG_1019">0</Partida><Partida CodigoPartida="PG_1020">0</Partida><Partida CodigoPartida="PG_1021">0</Partida><Partida CodigoPartida="PG_1023">83954.97</Partida><Partida CodigoPartida="PG_1024">1177306.52</Partida><Partida CodigoPartida="PG_1025">0</Partida><Partida CodigoPartida="PG_1026">180759.64</Partida><Partida CodigoPartida="PG_1027">0</Partida><Partida CodigoPartida="PG_1028">57.95</Partida><Partida CodigoPartida="PG_1029">0</Partida><Partida CodigoPartida="PG_1030">0</Partida><Partida CodigoPartida="PG_1031">8195.40</Partida><Partida CodigoPartida="PG_1032">1500</Partida><Partida CodigoPartida="PG_1033">0</Partida><Partida CodigoPartida="PG_1034">0</Partida><Partida CodigoPartida="PG_1035">148622.42</Partida><Partida CodigoPartida="PG_1036">0</Partida><Partida CodigoPartida="PG_1037">1516441.93</Partida><Partida CodigoPartida="PG_1038">1600396.90</Partida><Partida CodigoPartida="PG_1039">149639.37</Partida><Partida CodigoPartida="PG_1040">0</Partida><Partida CodigoPartida="PG_1041">536245.67</Partida><Partida CodigoPartida="PG_1042">0</Partida><Partida CodigoPartida="PG_1043">8573.77</Partida><Partida CodigoPartida="PG_1044">69706.59</Partida><Partida CodigoPartida="PG_1045">3106.46</Partida><Partida CodigoPartida="PG_1046">0</Partida><Partida CodigoPartida="PG_1047">0</Partida><Partida CodigoPartida="PG_1048">0</Partida><Partida CodigoPartida="PG_1049">1353.72</Partida><Partida CodigoPartida="PG_1050">0</Partida><Partida CodigoPartida="PG_1051">768625.58</Partida><Partida CodigoPartida="PG_1052">0</Partida><Partida CodigoPartida="PG_1053">0</Partida><Partida CodigoPartida="PG_1054">0</Partida><Partida CodigoPartida="PG_1055">0</Partida><Partida CodigoPartida="PG_1056">645704</Partida><Partida CodigoPartida="PG_1058">645704</Partida><Partida CodigoPartida="PG_1059">78235.25</Partida><Partida CodigoPartida="PG_1060">0</Partida><Partida CodigoPartida="PG_1061">11257.74</Partida><Partida CodigoPartida="PG_1062">0</Partida><Partida CodigoPartida="PG_1063">53074.36</Partida><Partida CodigoPartida="PG_1064">0</Partida><Partida CodigoPartida="PG_1065">43499.97</Partida><Partida CodigoPartida="PG_1066">0</Partida><Partida CodigoPartida="PG_1067">0</Partida><Partida CodigoPartida="PG_1068">0</Partida><Partida CodigoPartida="PG_1069">0</Partida><Partida CodigoPartida="PG_1070">186067.32</Partida><Partida CodigoPartida="PG_1071">831771.32</Partida><Partida CodigoPartida="PG_1072">1600396.90</Partida><Partida CodigoPartida="PG_1073">950692.79</Partida><Partida CodigoPartida="PG_1074">0</Partida><Partida CodigoPartida="PG_1075">0</Partida><Partida CodigoPartida="PG_1076">0</Partida><Partida CodigoPartida="PG_1077">0</Partida><Partida CodigoPartida="PG_1078">630350.78</Partida><Partida CodigoPartida="PG_1079">85362.31</Partida><Partida CodigoPartida="PG_1080">187596.79</Partida><Partida CodigoPartida="PG_1081">0</Partida><Partida CodigoPartida="PG_1082">0</Partida><Partida CodigoPartida="PG_1083">0</Partida><Partida CodigoPartida="PG_1084">0</Partida><Partida CodigoPartida="PG_1085">0</Partida><Partida CodigoPartida="PG_1086">0</Partida><Partida CodigoPartida="PG_1087">4.50</Partida><Partida CodigoPartida="PG_1088">22047.65</Partida><Partida CodigoPartida="PG_1089">25339.76</Partida><Partida CodigoPartida="PG_1090">17996.25</Partida><Partida CodigoPartida="PG_1091">0</Partida><Partida CodigoPartida="PG_1092">7343.51</Partida><Partida CodigoPartida="PG_1093">0</Partida><Partida CodigoPartida="PG_1094">5989.79</Partida><Partida CodigoPartida="PG_1095">1353.72</Partida><Partida CodigoPartida="PG_1096">0</Partida><Partida CodigoPartida="PG_1097">1353.72</Partida><Partida CodigoPartida="PG_1098">0</Partida><Partida CodigoPartida="PG_1105">767271.86</Partida></Partidas></Balanco><BalancoX1><Duracao>12</Duracao><NumeroEmpregados>14</NumeroEmpregados><Unidade>0</Unidade><CapitalSocial>149639.37</CapitalSocial></BalancoX1></DetalheBalanco><DetalheBalanco divisa="EUR" subtipo="12" tipo="B00"><Balanco><DataEncerramento>2013-12-31</DataEncerramento><Ano>2013</Ano><Contabilidade>NCFR-PE</Contabilidade><Partidas><Partida CodigoPartida="PG_1011">95132.56</Partida><Partida CodigoPartida="PG_1012">0</Partida><Partida CodigoPartida="PG_1013">0</Partida><Partida CodigoPartida="PG_1014">1377.69</Partida><Partida CodigoPartida="PG_1015">0</Partida><Partida CodigoPartida="PG_1016">0</Partida><Partida CodigoPartida="PG_1017">0</Partida><Partida CodigoPartida="PG_1018">0</Partida><Partida CodigoPartida="PG_1019">0</Partida><Partida CodigoPartida="PG_1020">0</Partida><Partida CodigoPartida="PG_1021">0</Partida><Partida CodigoPartida="PG_1023">96510.25</Partida><Partida CodigoPartida="PG_1024">1324185.60</Partida><Partida CodigoPartida="PG_1025">0</Partida><Partida CodigoPartida="PG_1026">164376.34</Partida><Partida CodigoPartida="PG_1027">0</Partida><Partida CodigoPartida="PG_1028">35227.37</Partida><Partida CodigoPartida="PG_1029">0</Partida><Partida CodigoPartida="PG_1030">0</Partida><Partida CodigoPartida="PG_1031">8195.40</Partida><Partida CodigoPartida="PG_1032">1500</Partida><Partida CodigoPartida="PG_1033">0</Partida><Partida CodigoPartida="PG_1034">0</Partida><Partida CodigoPartida="PG_1035">43579.62</Partida><Partida CodigoPartida="PG_1036">0</Partida><Partida CodigoPartida="PG_1037">1577064.33</Partida><Partida CodigoPartida="PG_1038">1673574.58</Partida><Partida CodigoPartida="PG_1039">149639.37</Partida><Partida CodigoPartida="PG_1040">0</Partida><Partida CodigoPartida="PG_1041">536245.67</Partida><Partida CodigoPartida="PG_1042">0</Partida><Partida CodigoPartida="PG_1043">8573.77</Partida><Partida CodigoPartida="PG_1044">69706.59</Partida><Partida CodigoPartida="PG_1045">35050.31</Partida><Partida CodigoPartida="PG_1046">0</Partida><Partida CodigoPartida="PG_1047">0</Partida><Partida CodigoPartida="PG_1048">0</Partida><Partida CodigoPartida="PG_1049">2047.88</Partida><Partida CodigoPartida="PG_1050">0</Partida><Partida CodigoPartida="PG_1051">801263.59</Partida><Partida CodigoPartida="PG_1052">0</Partida><Partida CodigoPartida="PG_1053">0</Partida><Partida CodigoPartida="PG_1054">0</Partida><Partida CodigoPartida="PG_1055">0</Partida><Partida CodigoPartida="PG_1056">641704</Partida><Partida CodigoPartida="PG_1058">641704</Partida><Partida CodigoPartida="PG_1059">78691.61</Partida><Partida CodigoPartida="PG_1060">0</Partida><Partida CodigoPartida="PG_1061">11129.36</Partida><Partida CodigoPartida="PG_1062">0</Partida><Partida CodigoPartida="PG_1063">96500</Partida><Partida CodigoPartida="PG_1064">0</Partida><Partida CodigoPartida="PG_1065">44286.02</Partida><Partida CodigoPartida="PG_1066">0</Partida><Partida CodigoPartida="PG_1067">0</Partida><Partida CodigoPartida="PG_1068">0</Partida><Partida CodigoPartida="PG_1069">0</Partida><Partida CodigoPartida="PG_1070">230606.99</Partida><Partida CodigoPartida="PG_1071">872310.99</Partida><Partida CodigoPartida="PG_1072">1673574.58</Partida><Partida CodigoPartida="PG_1073">894675.95</Partida><Partida CodigoPartida="PG_1074">0</Partida><Partida CodigoPartida="PG_1075">0</Partida><Partida CodigoPartida="PG_1076">0</Partida><Partida CodigoPartida="PG_1077">0</Partida><Partida CodigoPartida="PG_1078">562388.28</Partida><Partida CodigoPartida="PG_1079">92218.16</Partida><Partida CodigoPartida="PG_1080">205410.98</Partida><Partida CodigoPartida="PG_1081">0</Partida><Partida CodigoPartida="PG_1082">0</Partida><Partida CodigoPartida="PG_1083">0</Partida><Partida CodigoPartida="PG_1084">0</Partida><Partida CodigoPartida="PG_1085">0</Partida><Partida CodigoPartida="PG_1086">0</Partida><Partida CodigoPartida="PG_1087">4687.66</Partida><Partida CodigoPartida="PG_1088">13676.14</Partida><Partida CodigoPartida="PG_1089">25670.05</Partida><Partida CodigoPartida="PG_1090">19635.58</Partida><Partida CodigoPartida="PG_1091">0</Partida><Partida CodigoPartida="PG_1092">6034.47</Partida><Partida CodigoPartida="PG_1093">0</Partida><Partida CodigoPartida="PG_1094">3986.59</Partida><Partida CodigoPartida="PG_1095">2047.88</Partida><Partida CodigoPartida="PG_1096">0</Partida><Partida CodigoPartida="PG_1097">2047.88</Partida><Partida CodigoPartida="PG_1098">0</Partida><Partida CodigoPartida="PG_1105">799215.71</Partida></Partidas></Balanco><BalancoX1><Duracao>12</Duracao><NumeroEmpregados>15</NumeroEmpregados><Unidade>0</Unidade><CapitalSocial>149639.37</CapitalSocial></BalancoX1></DetalheBalanco><DetalheBalanco divisa="EUR" subtipo="12" tipo="B00"><Balanco><DataEncerramento>2012-12-31</DataEncerramento><Ano>2012</Ano><Contabilidade>NCFR-PE</Contabilidade><Partidas><Partida CodigoPartida="PG_1011">111308.14</Partida><Partida CodigoPartida="PG_1012">0</Partida><Partida CodigoPartida="PG_1013">0</Partida><Partida CodigoPartida="PG_1014">1377.69</Partida><Partida CodigoPartida="PG_1015">0</Partida><Partida CodigoPartida="PG_1016">0</Partida><Partida CodigoPartida="PG_1017">0</Partida><Partida CodigoPartida="PG_1018">0</Partida><Partida CodigoPartida="PG_1019">0</Partida><Partida CodigoPartida="PG_1020">0</Partida><Partida CodigoPartida="PG_1021">0</Partida><Partida CodigoPartida="PG_1023">112685.83</Partida><Partida CodigoPartida="PG_1024">1452176.08</Partida><Partida CodigoPartida="PG_1025">0</Partida><Partida CodigoPartida="PG_1026">205092.38</Partida><Partida CodigoPartida="PG_1027">0</Partida><Partida CodigoPartida="PG_1028">32428.27</Partida><Partida CodigoPartida="PG_1029">0</Partida><Partida CodigoPartida="PG_1030">0</Partida><Partida CodigoPartida="PG_1031">8116.68</Partida><Partida CodigoPartida="PG_1032">750</Partida><Partida CodigoPartida="PG_1033">0</Partida><Partida CodigoPartida="PG_1034">0</Partida><Partida CodigoPartida="PG_1035">59471.45</Partida><Partida CodigoPartida="PG_1036">0</Partida><Partida CodigoPartida="PG_1037">1758034.86</Partida><Partida CodigoPartida="PG_1038">1870720.69</Partida><Partida CodigoPartida="PG_1039">149639.37</Partida><Partida CodigoPartida="PG_1040">0</Partida><Partida CodigoPartida="PG_1041">536245.67</Partida><Partida CodigoPartida="PG_1042">0</Partida><Partida CodigoPartida="PG_1043">8573.77</Partida><Partida CodigoPartida="PG_1044">69706.59</Partida><Partida CodigoPartida="PG_1045">33800.81</Partida><Partida CodigoPartida="PG_1046">0</Partida><Partida CodigoPartida="PG_1047">0</Partida><Partida CodigoPartida="PG_1048">0</Partida><Partida CodigoPartida="PG_1049">1249.50</Partida><Partida CodigoPartida="PG_1050">0</Partida><Partida CodigoPartida="PG_1051">799215.71</Partida><Partida CodigoPartida="PG_1052">0</Partida><Partida CodigoPartida="PG_1053">0</Partida><Partida CodigoPartida="PG_1054">0</Partida><Partida CodigoPartida="PG_1055">0</Partida><Partida CodigoPartida="PG_1056">0</Partida><Partida CodigoPartida="PG_1058">0</Partida><Partida CodigoPartida="PG_1059">104387.18</Partida><Partida CodigoPartida="PG_1060">0</Partida><Partida CodigoPartida="PG_1061">13909.61</Partida><Partida CodigoPartida="PG_1062">823210</Partida><Partida CodigoPartida="PG_1063">97530</Partida><Partida CodigoPartida="PG_1064">0</Partida><Partida CodigoPartida="PG_1065">32468.19</Partida><Partida CodigoPartida="PG_1066">0</Partida><Partida CodigoPartida="PG_1067">0</Partida><Partida CodigoPartida="PG_1068">0</Partida><Partida CodigoPartida="PG_1069">0</Partida><Partida CodigoPartida="PG_1070">1071504.98</Partida><Partida CodigoPartida="PG_1071">1071504.98</Partida><Partida CodigoPartida="PG_1072">1870720.69</Partida><Partida CodigoPartida="PG_1073">619155.72</Partida><Partida CodigoPartida="PG_1074">0</Partida><Partida CodigoPartida="PG_1075">0</Partida><Partida CodigoPartida="PG_1076">0</Partida><Partida CodigoPartida="PG_1077">0</Partida><Partida CodigoPartida="PG_1078">266271.50</Partida><Partida CodigoPartida="PG_1079">100641.17</Partida><Partida CodigoPartida="PG_1080">193531.41</Partida><Partida CodigoPartida="PG_1081">0</Partida><Partida CodigoPartida="PG_1082">0</Partida><Partida CodigoPartida="PG_1083">0</Partida><Partida CodigoPartida="PG_1084">0</Partida><Partida CodigoPartida="PG_1085">0</Partida><Partida CodigoPartida="PG_1086">0</Partida><Partida CodigoPartida="PG_1087">1126.93</Partida><Partida CodigoPartida="PG_1088">33014.74</Partida><Partida CodigoPartida="PG_1089">26823.83</Partida><Partida CodigoPartida="PG_1090">19632.65</Partida><Partida CodigoPartida="PG_1091">0</Partida><Partida CodigoPartida="PG_1092">7191.18</Partida><Partida CodigoPartida="PG_1093">0</Partida><Partida CodigoPartida="PG_1094">5941.68</Partida><Partida CodigoPartida="PG_1095">1249.50</Partida><Partida CodigoPartida="PG_1096">0</Partida><Partida CodigoPartida="PG_1097">1249.50</Partida><Partida CodigoPartida="PG_1098">0</Partida><Partida CodigoPartida="PG_1105">797966.21</Partida></Partidas></Balanco><BalancoX1><Duracao>12</Duracao><NumeroEmpregados>15</NumeroEmpregados><Unidade>0</Unidade><CapitalSocial>149639.37</CapitalSocial></BalancoX1></DetalheBalanco></Balancos></InformacoesFinanceiras><ResumoX1><IndBolsa>0</IndBolsa><IndTelefone>1</IndTelefone><IndFax>1</IndFax><IndEmail>1</IndEmail><IndOPC>1</IndOPC><TotEmpregados>14</TotEmpregados><IndImport>0</IndImport><IndExport>1</IndExport><IndImprensa>0</IndImprensa><IndEmpresaMae>0</IndEmpresaMae><TotAccionistas>3</TotAccionistas><IndSubsidiarias>0</IndSubsidiarias><TotSubsidiarias>0</TotSubsidiarias><IndParticipadas>0</IndParticipadas><TotParticipadas>0</TotParticipadas><IndIncidentes>0</IndIncidentes><TotIncidentes>0</TotIncidentes><IndAccaoInsolvencia>0</IndAccaoInsolvencia><IndProcessoInsolvencia>0</IndProcessoInsolvencia><TotBalancos>4</TotBalancos><NumFiliais>0</NumFiliais><IndExpPagamentos>1</IndExpPagamentos><IndProcAdmon>0</IndProcAdmon><IndCertificacao>1</IndCertificacao><CapacidadeFinanceira>A</CapacidadeFinanceira><IndicadorRisco>1</IndicadorRisco><PercentilScore>94</PercentilScore><OpiniaoCredito>96600</OpiniaoCredito><VendasUltimoAno>944090.02</VendasUltimoAno><TotActivoUltimoAno>1266924.68</TotActivoUltimoAno><ResultLiqUltimoAno>3979.59</ResultLiqUltimoAno><CapProprioUltimoAno>772605.17</CapProprioUltimoAno><CapitalSocial>149639.37</CapitalSocial><AutonomiaFinanceira>60.98</AutonomiaFinanceira><RacioSolvabilidade>156.30</RacioSolvabilidade><CAE>45200</CAE><DataConstituicao>1978-03-17</DataConstituicao><Administrador tipo="SOCGER">Lidia Maria Leal Andre</Administrador><DataPublicacaoLegal>2014-07-17</DataPublicacaoLegal><DataUltimaModificacao>2017-03-24</DataUltimaModificacao><DataUltimoBalancoDisponivel>2015-12-31</DataUltimoBalancoDisponivel><DataInicioNegocios>1978-05-23</DataInicioNegocios><EstadoActCod>B</EstadoActCod><RiscoInforma>19</RiscoInforma><CF2>A</CF2><RI2>19</RI2><PubLegaisUlt12meses>0</PubLegaisUlt12meses><IndDimensao>MI</IndDimensao><IndProcessoRevitalizacao>0</IndProcessoRevitalizacao><IndDormant>0</IndDormant><IndSActComer>0</IndSActComer></ResumoX1><FichaEmpresaX1><Nome>ERNESTO PEDRO ANDRÉ, LDA</Nome><Duns>449689512</Duns><NumeroContribuinte>500772037</NumeroContribuinte><TipoMorada>UNICA</TipoMorada><NomeVia>MATOS</NomeVia><Localidade>MATOS DO CARRIÇO</Localidade><CodigoPostal>3105-064</CodigoPostal><EnderecoPostal>CARRIÇO</EnderecoPostal><Website>www.epandre.pt</Website><Email>oficina@epandre.pt</Email><Telefone>236959303</Telefone><Fax>236959308</Fax><SIC>7539</SIC><DescricaoSIC>Serviços de reparação de automóveis, NCA</DescricaoSIC><CAE>45200</CAE><DescricaoCAE>Manutenção e reparação de veículos automóveis</DescricaoCAE><DataUltimoBalancoDisponivel>2015-12-31</DataUltimoBalancoDisponivel><DataUltimoBalancoPublicado>2013</DataUltimoBalancoPublicado><DataUltimaModificacao>2017-03-24</DataUltimaModificacao><DataUltimaConsulta>2015-11-04</DataUltimaConsulta><NumeroConsultas>11</NumeroConsultas><IndMediasSectoriais>1</IndMediasSectoriais><TipoEmpresa>Real</TipoEmpresa></FichaEmpresaX1></Relatorio>');
    
    Test.stopTest();
    rep1= DBInfoXML.UpdateReport(dbprop1,ClientType, client.id, pdf); 
    ClientType='Lead';
    ReportDB__c Report= DBInfoXML.UpdateReport(dbprop,ClientType, client.id, pdf);
    ClientType='';
    ReportDB__c Report1= DBInfoXML.UpdateReport(dbprop,ClientType, client.id , pdf);
    //Test.stopTest();
  }

  @isTest static void dBInfoXML_existingAccount_test()
  {
    //Test.startTest();

    // test WebService CallOut
    string ClientType;
    ClientType='Client';
    Blob pdf=null;
    Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();

    Account client = new Account(name='111222333',nif__c='111222333',Type = 'Customer - Channel');
    
    //string InId='0012400000RRVwYAAX';
    //Test.startTest();
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('XMLNewClient');   
    mock.setStatusCode(200); 
    mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://api.salesforce.com/foo/bar');
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    string xmlnew=res.getbody();
    //HttpResponse res=DBInfoXMLTest.getInfoFromExternalService('http://api.salesforce.com/foo/bar');
    outInt=DBInfoXML.InformadbGetReport('111222333', 'XMLCOMER','Xml', 'Client');
    string xml=outInt.xml;
    DBInfoXML.parseDBXML(xml);
    DBProp dbprop=DBInfoXML.parseDBXML(xml);

    insert client;
    //21/06/17 - necessario por nif (BP)
    pdf = Blob.valueOf('<Relatorio data_xml="2016-05-10" id_xml="31237612"><Identificacao><IDPrincipais><IDPrincipal><EstabelecimentoSecundario>N</EstabelecimentoSecundario></IDPrincipal><IDPrincipalX1><ICI>6201599245100000</ICI><DataUltMod>2015-03-17</DataUltMod>');

    // test Report InformaDB Upsert
    dbprop.NumeroContribuinte = '111222333';
    dbprop.TotEmpregados = null;
    dbprop.TotEmpregados = null;
    dbprop.Localidade ='Rua dos testes nº666 , Freguesia do Salesforce, Dream Country.';
    dbprop.DataConstituicao = Date.valueOf('1680-01-01');
    dbprop.EnderecoPostal = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.CodigoPostal = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.NomeVia = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.SituacaoContributiva ='A empresa não deve nada, encontra-se com a sua situação regularizada, nunca se atrasando nos pagamentos das mensalidades que a ela lhe dizem respeito. Encontra-se no seu auge empresarial, empregando deste modo 500 colaboradores. Foi sediada na Comarca de Lisboa com o registo xxxxx.';
     
    Test.startTest();
    ReportDB__C rep= DBInfoXML.UpdateReport(dbprop,'Client', client.id, pdf);
    
    // outInt=DBInfoXML.InformadbGetReport('508898960', 'XMLCOMER','Xml', ClientType);
    string xml1=outInt.xml;
    // outInt=DBInfoXML.InformadbGetReport('508898960', 'XMLCOMER','Xml', ClientType);
    string xml5=outInt.xml;
        
    //system.debug(xml5);
    DBProp dbprop5=DBInfoXML.parseDBXML(xml5);
    DBInfoXML.parseDBXML(xml1);
    DBProp dbprop1=DBInfoXML.parseDBXML(xml1);
       
    ReportDB__C rep1= DBInfoXML.UpdateReport(dbprop1,ClientType, client.id, pdf);
    outIntPdf=DBInfoXML.InformadbGetPdfReport('111222333', 'XMLCOMER');
    //Pdf=outIntPdf.pdf;
    //pdf.DataConstituicao = Date.newInstance(1200, 04,07);
    pdf = Blob.valueOf('<Relatorio data_xml="2017-04-06" id_xml="45227835"><Identificacao><IDPrincipais><IDPrincipal><EstabelecimentoSecundario>N</EstabelecimentoSecundario></IDPrincipal><IDPrincipalX1><ICI>6200044646500000</ICI><DataUltMod>2017-03-24</DataUltMod></IDPrincipalX1></IDPrincipais><Anexas><Anexa tipo="ID01">500772037</Anexa><Anexa tipo="ID02">500772037</Anexa><Anexa tipo="ID03">449689512</Anexa></Anexas><Denominacoes><Denominacao situacao="1" tipo="1"><ValorDeno>ERNESTO PEDRO ANDRÉ, LDA</ValorDeno><DataInformacao>2013-08-12</DataInformacao></Denominacao></Denominacoes><FormasJuridicas><FormaJuridica situacao="1">LDA</FormaJuridica></FormasJuridicas><Estado><ValorEstado>A00</ValorEstado><DataInformacao>2013-08-12</DataInformacao></Estado><InformacoesLegais><InformacaoLegal><DataInicioNegocios>1978-05-23</DataInicioNegocios><FormaObrigar>2 assinaturas</FormaObrigar><ConservatoriaActual>1015</ConservatoriaActual><DataRegistoConservatoria>1978-01-01</DataRegistoConservatoria></InformacaoLegal><InformacaoLegalX1><DataConstituicao>1978-03-17</DataConstituicao></InformacaoLegalX1></InformacoesLegais><Contactos><DetalheContacto tipo="A10"><Contacto>236959303</Contacto></DetalheContacto><DetalheContacto tipo="A12"><Contacto>236959300</Contacto><ContactoX1><Departamento>D001</Departamento></ContactoX1></DetalheContacto><DetalheContacto tipo="A13"><Contacto>236959301</Contacto></DetalheContacto><DetalheContacto tipo="C10"><Contacto>236959308</Contacto></DetalheContacto><DetalheContacto tipo="C10"><Contacto>236959309</Contacto></DetalheContacto><DetalheContacto tipo="D10"><ContactoX1><NomeContacto>oficina@epandre.pt</NomeContacto></ContactoX1></DetalheContacto><DetalheContacto tipo="D10"><ContactoX1><Departamento>D015</Departamento><NomeContacto>vendas@epandre.pt</NomeContacto></ContactoX1></DetalheContacto><DetalheContacto tipo="D10"><ContactoX1><Departamento>D025</Departamento><NomeContacto>contab@epandre.pt</NomeContacto></ContactoX1></DetalheContacto><DetalheContacto tipo="D10"><ContactoX1><NomeContacto>epandre@epandre.pt</NomeContacto></ContactoX1></DetalheContacto></Contactos><Capitais divisa="EUR"><Capital><CapitalSocial>149639.37</CapitalSocial></Capital></Capitais><Empregados><DetalheEmpregado situacao="1"><Empregado><Efectivos>14</Efectivos><DataInformacao>2015-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>14</Efectivos><DataInformacao>2014-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>15</Efectivos><DataInformacao>2013-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>15</Efectivos><DataInformacao>2012-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>15</Efectivos><DataInformacao>2011-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado><DetalheEmpregado situacao="2"><Empregado><Efectivos>20</Efectivos><DataInformacao>2010-12-31</DataInformacao></Empregado><EmpregadoX1><Fonte>IES</Fonte></EmpregadoX1></DetalheEmpregado></Empregados></Identificacao><Localizacao><Moradas><DetalheMorada situacao="1" tipo="A10"><MoradaX1><Website>www.epandre.pt</Website></MoradaX1></DetalheMorada><DetalheMorada situacao="1" tipo="B10"><Morada><NomeVia>MATOS</NomeVia><CodigoPostal>3105-064</CodigoPostal><EnderecoPostal>CARRIÇO</EnderecoPostal><Localidade>MATOS DO CARRIÇO</Localidade><Concelho>POMBAL</Concelho></Morada><MoradaX1><Freguesia>CARRIÇO</Freguesia><Distrito>10</Distrito><CoordX>-8.80608170797</CoordX><CoordY>39.9822307383</CoordY></MoradaX1></DetalheMorada><DetalheMorada situacao="1" tipo="B12"><Morada><NomeVia>MATOS</NomeVia><CodigoPostal>3105-064</CodigoPostal><EnderecoPostal>CARRIÇO</EnderecoPostal><Localidade>MATOS DO CARRIÇO</Localidade><Concelho>POMBAL</Concelho></Morada><MoradaX1><Freguesia>CARRIÇO</Freguesia><Distrito>10</Distrito><CoordX>-8.80608170797</CoordX><CoordY>39.9822307383</CoordY></MoradaX1></DetalheMorada></Moradas></Localizacao><Actividades><RamoNegocio><DetalheActividade situacao="1" tipo="1"><Actividade><Descricao>indústria de reparação de viaturas, estação de serviço e retalhista de automóveis e peças 100%</Descricao><SIC>7539</SIC></Actividade><ActividadeX1>45200</ActividadeX1></DetalheActividade><DetalheActividade situacao="1" tipo="2"><Actividade><SIC>5511</SIC></Actividade><ActividadeX1>45110</ActividadeX1></DetalheActividade></RamoNegocio></Actividades><Ligacoes><LigacoescomTerceiros><DetalheLigacaocomTerceiro situacao="1" tipo="C10"><LigacaocomTerceiro>NOVO BANCO, S.A.</LigacaocomTerceiro></DetalheLigacaocomTerceiro><DetalheLigacaocomTerceiro situacao="1" tipo="C10"><LigacaocomTerceiro>BANCO COMERCIAL PORTUGUÊS, S.A.</LigacaocomTerceiro></DetalheLigacaocomTerceiro><DetalheLigacaocomTerceiro situacao="1" tipo="C10"><LigacaocomTerceiro>BANCO SANTANDER TOTTA, S.A.</LigacaocomTerceiro></DetalheLigacaocomTerceiro><DetalheLigacaocomTerceiro situacao="1" tipo="I10"><LigacaocomTerceiro>LUSITÂNIA - COMPANHIA DE SEGUROS, S.A.</LigacaocomTerceiro></DetalheLigacaocomTerceiro></LigacoescomTerceiros><LigacoescomPessoas><DetalheLigacaoPessoa situacao="1" tipo="SOCGER"><LigacaoPessoa><Apelido1>Andre</Apelido1><Apelido2>Leal</Apelido2><Nome>Leonel</Nome><TituloAcademico>ENG</TituloAcademico></LigacaoPessoa><LigacaoPessoaX1><Sexo>H</Sexo><EstadoPessoa>V</EstadoPessoa><Classificacao>G</Classificacao><Ordenacao>250</Ordenacao></LigacaoPessoaX1></DetalheLigacaoPessoa><DetalheLigacaoPessoa situacao="1" tipo="SOCGER"><LigacaoPessoa><Apelido1>Andre</Apelido1><Apelido2>Maria Leal</Apelido2><Nome>Lidia</Nome></LigacaoPessoa><LigacaoPessoaX1><Sexo>M</Sexo><EstadoPessoa>V</EstadoPessoa><Classificacao>G</Classificacao><Ordenacao>250</Ordenacao></LigacaoPessoaX1></DetalheLigacaoPessoa><DetalheLigacaoPessoa situacao="1" tipo="SOCGER"><LigacaoPessoa><Apelido1>Andre</Apelido1><Apelido2>Pedro</Apelido2><Nome>Ernesto</Nome></LigacaoPessoa><LigacaoPessoaX1><Sexo>H</Sexo><EstadoPessoa>V</EstadoPessoa><Classificacao>G</Classificacao><Ordenacao>250</Ordenacao></LigacaoPessoaX1></DetalheLigacaoPessoa></LigacoescomPessoas></Ligacoes><InformacoesFinanceiras><Balancos numAnos="4"><DetalheBalanco divisa="EUR" subtipo="12" tipo="B00"><Balanco><DataEncerramento>2015-12-31</DataEncerramento><Ano>2015</Ano><Contabilidade>NCFR-PE</Contabilidade><Partidas><Partida CodigoPartida="PG_1011">75861.22</Partida><Partida CodigoPartida="PG_1012">0</Partida><Partida CodigoPartida="PG_1013">0</Partida><Partida CodigoPartida="PG_1014">1377.69</Partida><Partida CodigoPartida="PG_1015">0</Partida><Partida CodigoPartida="PG_1016">0</Partida><Partida CodigoPartida="PG_1017">0</Partida><Partida CodigoPartida="PG_1018">0</Partida><Partida CodigoPartida="PG_1019">0</Partida><Partida CodigoPartida="PG_1020">0</Partida><Partida CodigoPartida="PG_1021">0</Partida><Partida CodigoPartida="PG_1023">77238.91</Partida><Partida CodigoPartida="PG_1024">995523.41</Partida><Partida CodigoPartida="PG_1025">0</Partida><Partida CodigoPartida="PG_1026">159776.36</Partida><Partida CodigoPartida="PG_1027">80.41</Partida><Partida CodigoPartida="PG_1028">3517.46</Partida><Partida CodigoPartida="PG_1029">0</Partida><Partida CodigoPartida="PG_1030">0</Partida><Partida CodigoPartida="PG_1031">8195.40</Partida><Partida CodigoPartida="PG_1032">1500</Partida><Partida CodigoPartida="PG_1033">0</Partida><Partida CodigoPartida="PG_1034">0</Partida><Partida CodigoPartida="PG_1035">21092.73</Partida><Partida CodigoPartida="PG_1036">0</Partida><Partida CodigoPartida="PG_1037">1189685.77</Partida><Partida CodigoPartida="PG_1038">1266924.68</Partida><Partida CodigoPartida="PG_1039">149639.37</Partida><Partida CodigoPartida="PG_1040">0</Partida><Partida CodigoPartida="PG_1041">536245.67</Partida><Partida CodigoPartida="PG_1042">0</Partida><Partida CodigoPartida="PG_1043">8573.77</Partida><Partida CodigoPartida="PG_1044">69706.59</Partida><Partida CodigoPartida="PG_1045">4460.18</Partida><Partida CodigoPartida="PG_1046">0</Partida><Partida CodigoPartida="PG_1047">0</Partida><Partida CodigoPartida="PG_1048">0</Partida><Partida CodigoPartida="PG_1049">3979.59</Partida><Partida CodigoPartida="PG_1050">0</Partida><Partida CodigoPartida="PG_1051">772605.17</Partida><Partida CodigoPartida="PG_1052">0</Partida><Partida CodigoPartida="PG_1053">0</Partida><Partida CodigoPartida="PG_1054">0</Partida><Partida CodigoPartida="PG_1055">0</Partida><Partida CodigoPartida="PG_1056">0</Partida><Partida CodigoPartida="PG_1058">0</Partida><Partida CodigoPartida="PG_1059">108882.05</Partida><Partida CodigoPartida="PG_1060">0</Partida><Partida CodigoPartida="PG_1061">13293.52</Partida><Partida CodigoPartida="PG_1062">257410</Partida><Partida CodigoPartida="PG_1063">76250</Partida><Partida CodigoPartida="PG_1064">0</Partida><Partida CodigoPartida="PG_1065">38483.94</Partida><Partida CodigoPartida="PG_1066">0</Partida><Partida CodigoPartida="PG_1067">0</Partida><Partida CodigoPartida="PG_1068">0</Partida><Partida CodigoPartida="PG_1069">0</Partida><Partida CodigoPartida="PG_1070">494319.51</Partida><Partida CodigoPartida="PG_1071">494319.51</Partida><Partida CodigoPartida="PG_1072">1266924.68</Partida><Partida CodigoPartida="PG_1073">944090.02</Partida><Partida CodigoPartida="PG_1074">0</Partida><Partida CodigoPartida="PG_1075">0</Partida><Partida CodigoPartida="PG_1076">0</Partida><Partida CodigoPartida="PG_1077">0</Partida><Partida CodigoPartida="PG_1078">637930.18</Partida><Partida CodigoPartida="PG_1079">82521.90</Partida><Partida CodigoPartida="PG_1080">183215.05</Partida><Partida CodigoPartida="PG_1081">0</Partida><Partida CodigoPartida="PG_1082">0</Partida><Partida CodigoPartida="PG_1083">0</Partida><Partida CodigoPartida="PG_1084">0</Partida><Partida CodigoPartida="PG_1085">0</Partida><Partida CodigoPartida="PG_1086">0</Partida><Partida CodigoPartida="PG_1087">4.20</Partida><Partida CodigoPartida="PG_1088">12750.26</Partida><Partida CodigoPartida="PG_1089">27676.83</Partida><Partida CodigoPartida="PG_1090">17466.06</Partida><Partida CodigoPartida="PG_1091">0</Partida><Partida CodigoPartida="PG_1092">10210.77</Partida><Partida CodigoPartida="PG_1093">0</Partida><Partida CodigoPartida="PG_1094">6231.18</Partida><Partida CodigoPartida="PG_1095">3979.59</Partida><Partida CodigoPartida="PG_1096">0</Partida><Partida CodigoPartida="PG_1097">3979.59</Partida><Partida CodigoPartida="PG_1098">0</Partida><Partida CodigoPartida="PG_1105">768625.58</Partida></Partidas></Balanco><BalancoX1><Duracao>12</Duracao><NumeroEmpregados>14</NumeroEmpregados><Unidade>0</Unidade><CapitalSocial>149639.37</CapitalSocial></BalancoX1></DetalheBalanco><DetalheBalanco divisa="EUR" subtipo="12" tipo="B00"><Balanco><DataEncerramento>2014-12-31</DataEncerramento><Ano>2014</Ano><Contabilidade>NCFR-PE</Contabilidade><Partidas><Partida CodigoPartida="PG_1011">82577.28</Partida><Partida CodigoPartida="PG_1012">0</Partida><Partida CodigoPartida="PG_1013">0</Partida><Partida CodigoPartida="PG_1014">1377.69</Partida><Partida CodigoPartida="PG_1015">0</Partida><Partida CodigoPartida="PG_1016">0</Partida><Partida CodigoPartida="PG_1017">0</Partida><Partida CodigoPartida="PG_1018">0</Partida><Partida CodigoPartida="PG_1019">0</Partida><Partida CodigoPartida="PG_1020">0</Partida><Partida CodigoPartida="PG_1021">0</Partida><Partida CodigoPartida="PG_1023">83954.97</Partida><Partida CodigoPartida="PG_1024">1177306.52</Partida><Partida CodigoPartida="PG_1025">0</Partida><Partida CodigoPartida="PG_1026">180759.64</Partida><Partida CodigoPartida="PG_1027">0</Partida><Partida CodigoPartida="PG_1028">57.95</Partida><Partida CodigoPartida="PG_1029">0</Partida><Partida CodigoPartida="PG_1030">0</Partida><Partida CodigoPartida="PG_1031">8195.40</Partida><Partida CodigoPartida="PG_1032">1500</Partida><Partida CodigoPartida="PG_1033">0</Partida><Partida CodigoPartida="PG_1034">0</Partida><Partida CodigoPartida="PG_1035">148622.42</Partida><Partida CodigoPartida="PG_1036">0</Partida><Partida CodigoPartida="PG_1037">1516441.93</Partida><Partida CodigoPartida="PG_1038">1600396.90</Partida><Partida CodigoPartida="PG_1039">149639.37</Partida><Partida CodigoPartida="PG_1040">0</Partida><Partida CodigoPartida="PG_1041">536245.67</Partida><Partida CodigoPartida="PG_1042">0</Partida><Partida CodigoPartida="PG_1043">8573.77</Partida><Partida CodigoPartida="PG_1044">69706.59</Partida><Partida CodigoPartida="PG_1045">3106.46</Partida><Partida CodigoPartida="PG_1046">0</Partida><Partida CodigoPartida="PG_1047">0</Partida><Partida CodigoPartida="PG_1048">0</Partida><Partida CodigoPartida="PG_1049">1353.72</Partida><Partida CodigoPartida="PG_1050">0</Partida><Partida CodigoPartida="PG_1051">768625.58</Partida><Partida CodigoPartida="PG_1052">0</Partida><Partida CodigoPartida="PG_1053">0</Partida><Partida CodigoPartida="PG_1054">0</Partida><Partida CodigoPartida="PG_1055">0</Partida><Partida CodigoPartida="PG_1056">645704</Partida><Partida CodigoPartida="PG_1058">645704</Partida><Partida CodigoPartida="PG_1059">78235.25</Partida><Partida CodigoPartida="PG_1060">0</Partida><Partida CodigoPartida="PG_1061">11257.74</Partida><Partida CodigoPartida="PG_1062">0</Partida><Partida CodigoPartida="PG_1063">53074.36</Partida><Partida CodigoPartida="PG_1064">0</Partida><Partida CodigoPartida="PG_1065">43499.97</Partida><Partida CodigoPartida="PG_1066">0</Partida><Partida CodigoPartida="PG_1067">0</Partida><Partida CodigoPartida="PG_1068">0</Partida><Partida CodigoPartida="PG_1069">0</Partida><Partida CodigoPartida="PG_1070">186067.32</Partida><Partida CodigoPartida="PG_1071">831771.32</Partida><Partida CodigoPartida="PG_1072">1600396.90</Partida><Partida CodigoPartida="PG_1073">950692.79</Partida><Partida CodigoPartida="PG_1074">0</Partida><Partida CodigoPartida="PG_1075">0</Partida><Partida CodigoPartida="PG_1076">0</Partida><Partida CodigoPartida="PG_1077">0</Partida><Partida CodigoPartida="PG_1078">630350.78</Partida><Partida CodigoPartida="PG_1079">85362.31</Partida><Partida CodigoPartida="PG_1080">187596.79</Partida><Partida CodigoPartida="PG_1081">0</Partida><Partida CodigoPartida="PG_1082">0</Partida><Partida CodigoPartida="PG_1083">0</Partida><Partida CodigoPartida="PG_1084">0</Partida><Partida CodigoPartida="PG_1085">0</Partida><Partida CodigoPartida="PG_1086">0</Partida><Partida CodigoPartida="PG_1087">4.50</Partida><Partida CodigoPartida="PG_1088">22047.65</Partida><Partida CodigoPartida="PG_1089">25339.76</Partida><Partida CodigoPartida="PG_1090">17996.25</Partida><Partida CodigoPartida="PG_1091">0</Partida><Partida CodigoPartida="PG_1092">7343.51</Partida><Partida CodigoPartida="PG_1093">0</Partida><Partida CodigoPartida="PG_1094">5989.79</Partida><Partida CodigoPartida="PG_1095">1353.72</Partida><Partida CodigoPartida="PG_1096">0</Partida><Partida CodigoPartida="PG_1097">1353.72</Partida><Partida CodigoPartida="PG_1098">0</Partida><Partida CodigoPartida="PG_1105">767271.86</Partida></Partidas></Balanco><BalancoX1><Duracao>12</Duracao><NumeroEmpregados>14</NumeroEmpregados><Unidade>0</Unidade><CapitalSocial>149639.37</CapitalSocial></BalancoX1></DetalheBalanco><DetalheBalanco divisa="EUR" subtipo="12" tipo="B00"><Balanco><DataEncerramento>2013-12-31</DataEncerramento><Ano>2013</Ano><Contabilidade>NCFR-PE</Contabilidade><Partidas><Partida CodigoPartida="PG_1011">95132.56</Partida><Partida CodigoPartida="PG_1012">0</Partida><Partida CodigoPartida="PG_1013">0</Partida><Partida CodigoPartida="PG_1014">1377.69</Partida><Partida CodigoPartida="PG_1015">0</Partida><Partida CodigoPartida="PG_1016">0</Partida><Partida CodigoPartida="PG_1017">0</Partida><Partida CodigoPartida="PG_1018">0</Partida><Partida CodigoPartida="PG_1019">0</Partida><Partida CodigoPartida="PG_1020">0</Partida><Partida CodigoPartida="PG_1021">0</Partida><Partida CodigoPartida="PG_1023">96510.25</Partida><Partida CodigoPartida="PG_1024">1324185.60</Partida><Partida CodigoPartida="PG_1025">0</Partida><Partida CodigoPartida="PG_1026">164376.34</Partida><Partida CodigoPartida="PG_1027">0</Partida><Partida CodigoPartida="PG_1028">35227.37</Partida><Partida CodigoPartida="PG_1029">0</Partida><Partida CodigoPartida="PG_1030">0</Partida><Partida CodigoPartida="PG_1031">8195.40</Partida><Partida CodigoPartida="PG_1032">1500</Partida><Partida CodigoPartida="PG_1033">0</Partida><Partida CodigoPartida="PG_1034">0</Partida><Partida CodigoPartida="PG_1035">43579.62</Partida><Partida CodigoPartida="PG_1036">0</Partida><Partida CodigoPartida="PG_1037">1577064.33</Partida><Partida CodigoPartida="PG_1038">1673574.58</Partida><Partida CodigoPartida="PG_1039">149639.37</Partida><Partida CodigoPartida="PG_1040">0</Partida><Partida CodigoPartida="PG_1041">536245.67</Partida><Partida CodigoPartida="PG_1042">0</Partida><Partida CodigoPartida="PG_1043">8573.77</Partida><Partida CodigoPartida="PG_1044">69706.59</Partida><Partida CodigoPartida="PG_1045">35050.31</Partida><Partida CodigoPartida="PG_1046">0</Partida><Partida CodigoPartida="PG_1047">0</Partida><Partida CodigoPartida="PG_1048">0</Partida><Partida CodigoPartida="PG_1049">2047.88</Partida><Partida CodigoPartida="PG_1050">0</Partida><Partida CodigoPartida="PG_1051">801263.59</Partida><Partida CodigoPartida="PG_1052">0</Partida><Partida CodigoPartida="PG_1053">0</Partida><Partida CodigoPartida="PG_1054">0</Partida><Partida CodigoPartida="PG_1055">0</Partida><Partida CodigoPartida="PG_1056">641704</Partida><Partida CodigoPartida="PG_1058">641704</Partida><Partida CodigoPartida="PG_1059">78691.61</Partida><Partida CodigoPartida="PG_1060">0</Partida><Partida CodigoPartida="PG_1061">11129.36</Partida><Partida CodigoPartida="PG_1062">0</Partida><Partida CodigoPartida="PG_1063">96500</Partida><Partida CodigoPartida="PG_1064">0</Partida><Partida CodigoPartida="PG_1065">44286.02</Partida><Partida CodigoPartida="PG_1066">0</Partida><Partida CodigoPartida="PG_1067">0</Partida><Partida CodigoPartida="PG_1068">0</Partida><Partida CodigoPartida="PG_1069">0</Partida><Partida CodigoPartida="PG_1070">230606.99</Partida><Partida CodigoPartida="PG_1071">872310.99</Partida><Partida CodigoPartida="PG_1072">1673574.58</Partida><Partida CodigoPartida="PG_1073">894675.95</Partida><Partida CodigoPartida="PG_1074">0</Partida><Partida CodigoPartida="PG_1075">0</Partida><Partida CodigoPartida="PG_1076">0</Partida><Partida CodigoPartida="PG_1077">0</Partida><Partida CodigoPartida="PG_1078">562388.28</Partida><Partida CodigoPartida="PG_1079">92218.16</Partida><Partida CodigoPartida="PG_1080">205410.98</Partida><Partida CodigoPartida="PG_1081">0</Partida><Partida CodigoPartida="PG_1082">0</Partida><Partida CodigoPartida="PG_1083">0</Partida><Partida CodigoPartida="PG_1084">0</Partida><Partida CodigoPartida="PG_1085">0</Partida><Partida CodigoPartida="PG_1086">0</Partida><Partida CodigoPartida="PG_1087">4687.66</Partida><Partida CodigoPartida="PG_1088">13676.14</Partida><Partida CodigoPartida="PG_1089">25670.05</Partida><Partida CodigoPartida="PG_1090">19635.58</Partida><Partida CodigoPartida="PG_1091">0</Partida><Partida CodigoPartida="PG_1092">6034.47</Partida><Partida CodigoPartida="PG_1093">0</Partida><Partida CodigoPartida="PG_1094">3986.59</Partida><Partida CodigoPartida="PG_1095">2047.88</Partida><Partida CodigoPartida="PG_1096">0</Partida><Partida CodigoPartida="PG_1097">2047.88</Partida><Partida CodigoPartida="PG_1098">0</Partida><Partida CodigoPartida="PG_1105">799215.71</Partida></Partidas></Balanco><BalancoX1><Duracao>12</Duracao><NumeroEmpregados>15</NumeroEmpregados><Unidade>0</Unidade><CapitalSocial>149639.37</CapitalSocial></BalancoX1></DetalheBalanco><DetalheBalanco divisa="EUR" subtipo="12" tipo="B00"><Balanco><DataEncerramento>2012-12-31</DataEncerramento><Ano>2012</Ano><Contabilidade>NCFR-PE</Contabilidade><Partidas><Partida CodigoPartida="PG_1011">111308.14</Partida><Partida CodigoPartida="PG_1012">0</Partida><Partida CodigoPartida="PG_1013">0</Partida><Partida CodigoPartida="PG_1014">1377.69</Partida><Partida CodigoPartida="PG_1015">0</Partida><Partida CodigoPartida="PG_1016">0</Partida><Partida CodigoPartida="PG_1017">0</Partida><Partida CodigoPartida="PG_1018">0</Partida><Partida CodigoPartida="PG_1019">0</Partida><Partida CodigoPartida="PG_1020">0</Partida><Partida CodigoPartida="PG_1021">0</Partida><Partida CodigoPartida="PG_1023">112685.83</Partida><Partida CodigoPartida="PG_1024">1452176.08</Partida><Partida CodigoPartida="PG_1025">0</Partida><Partida CodigoPartida="PG_1026">205092.38</Partida><Partida CodigoPartida="PG_1027">0</Partida><Partida CodigoPartida="PG_1028">32428.27</Partida><Partida CodigoPartida="PG_1029">0</Partida><Partida CodigoPartida="PG_1030">0</Partida><Partida CodigoPartida="PG_1031">8116.68</Partida><Partida CodigoPartida="PG_1032">750</Partida><Partida CodigoPartida="PG_1033">0</Partida><Partida CodigoPartida="PG_1034">0</Partida><Partida CodigoPartida="PG_1035">59471.45</Partida><Partida CodigoPartida="PG_1036">0</Partida><Partida CodigoPartida="PG_1037">1758034.86</Partida><Partida CodigoPartida="PG_1038">1870720.69</Partida><Partida CodigoPartida="PG_1039">149639.37</Partida><Partida CodigoPartida="PG_1040">0</Partida><Partida CodigoPartida="PG_1041">536245.67</Partida><Partida CodigoPartida="PG_1042">0</Partida><Partida CodigoPartida="PG_1043">8573.77</Partida><Partida CodigoPartida="PG_1044">69706.59</Partida><Partida CodigoPartida="PG_1045">33800.81</Partida><Partida CodigoPartida="PG_1046">0</Partida><Partida CodigoPartida="PG_1047">0</Partida><Partida CodigoPartida="PG_1048">0</Partida><Partida CodigoPartida="PG_1049">1249.50</Partida><Partida CodigoPartida="PG_1050">0</Partida><Partida CodigoPartida="PG_1051">799215.71</Partida><Partida CodigoPartida="PG_1052">0</Partida><Partida CodigoPartida="PG_1053">0</Partida><Partida CodigoPartida="PG_1054">0</Partida><Partida CodigoPartida="PG_1055">0</Partida><Partida CodigoPartida="PG_1056">0</Partida><Partida CodigoPartida="PG_1058">0</Partida><Partida CodigoPartida="PG_1059">104387.18</Partida><Partida CodigoPartida="PG_1060">0</Partida><Partida CodigoPartida="PG_1061">13909.61</Partida><Partida CodigoPartida="PG_1062">823210</Partida><Partida CodigoPartida="PG_1063">97530</Partida><Partida CodigoPartida="PG_1064">0</Partida><Partida CodigoPartida="PG_1065">32468.19</Partida><Partida CodigoPartida="PG_1066">0</Partida><Partida CodigoPartida="PG_1067">0</Partida><Partida CodigoPartida="PG_1068">0</Partida><Partida CodigoPartida="PG_1069">0</Partida><Partida CodigoPartida="PG_1070">1071504.98</Partida><Partida CodigoPartida="PG_1071">1071504.98</Partida><Partida CodigoPartida="PG_1072">1870720.69</Partida><Partida CodigoPartida="PG_1073">619155.72</Partida><Partida CodigoPartida="PG_1074">0</Partida><Partida CodigoPartida="PG_1075">0</Partida><Partida CodigoPartida="PG_1076">0</Partida><Partida CodigoPartida="PG_1077">0</Partida><Partida CodigoPartida="PG_1078">266271.50</Partida><Partida CodigoPartida="PG_1079">100641.17</Partida><Partida CodigoPartida="PG_1080">193531.41</Partida><Partida CodigoPartida="PG_1081">0</Partida><Partida CodigoPartida="PG_1082">0</Partida><Partida CodigoPartida="PG_1083">0</Partida><Partida CodigoPartida="PG_1084">0</Partida><Partida CodigoPartida="PG_1085">0</Partida><Partida CodigoPartida="PG_1086">0</Partida><Partida CodigoPartida="PG_1087">1126.93</Partida><Partida CodigoPartida="PG_1088">33014.74</Partida><Partida CodigoPartida="PG_1089">26823.83</Partida><Partida CodigoPartida="PG_1090">19632.65</Partida><Partida CodigoPartida="PG_1091">0</Partida><Partida CodigoPartida="PG_1092">7191.18</Partida><Partida CodigoPartida="PG_1093">0</Partida><Partida CodigoPartida="PG_1094">5941.68</Partida><Partida CodigoPartida="PG_1095">1249.50</Partida><Partida CodigoPartida="PG_1096">0</Partida><Partida CodigoPartida="PG_1097">1249.50</Partida><Partida CodigoPartida="PG_1098">0</Partida><Partida CodigoPartida="PG_1105">797966.21</Partida></Partidas></Balanco><BalancoX1><Duracao>12</Duracao><NumeroEmpregados>15</NumeroEmpregados><Unidade>0</Unidade><CapitalSocial>149639.37</CapitalSocial></BalancoX1></DetalheBalanco></Balancos></InformacoesFinanceiras><ResumoX1><IndBolsa>0</IndBolsa><IndTelefone>1</IndTelefone><IndFax>1</IndFax><IndEmail>1</IndEmail><IndOPC>1</IndOPC><TotEmpregados>14</TotEmpregados><IndImport>0</IndImport><IndExport>1</IndExport><IndImprensa>0</IndImprensa><IndEmpresaMae>0</IndEmpresaMae><TotAccionistas>3</TotAccionistas><IndSubsidiarias>0</IndSubsidiarias><TotSubsidiarias>0</TotSubsidiarias><IndParticipadas>0</IndParticipadas><TotParticipadas>0</TotParticipadas><IndIncidentes>0</IndIncidentes><TotIncidentes>0</TotIncidentes><IndAccaoInsolvencia>0</IndAccaoInsolvencia><IndProcessoInsolvencia>0</IndProcessoInsolvencia><TotBalancos>4</TotBalancos><NumFiliais>0</NumFiliais><IndExpPagamentos>1</IndExpPagamentos><IndProcAdmon>0</IndProcAdmon><IndCertificacao>1</IndCertificacao><CapacidadeFinanceira>A</CapacidadeFinanceira><IndicadorRisco>1</IndicadorRisco><PercentilScore>94</PercentilScore><OpiniaoCredito>96600</OpiniaoCredito><VendasUltimoAno>944090.02</VendasUltimoAno><TotActivoUltimoAno>1266924.68</TotActivoUltimoAno><ResultLiqUltimoAno>3979.59</ResultLiqUltimoAno><CapProprioUltimoAno>772605.17</CapProprioUltimoAno><CapitalSocial>149639.37</CapitalSocial><AutonomiaFinanceira>60.98</AutonomiaFinanceira><RacioSolvabilidade>156.30</RacioSolvabilidade><CAE>45200</CAE><DataConstituicao>1978-03-17</DataConstituicao><Administrador tipo="SOCGER">Lidia Maria Leal Andre</Administrador><DataPublicacaoLegal>2014-07-17</DataPublicacaoLegal><DataUltimaModificacao>2017-03-24</DataUltimaModificacao><DataUltimoBalancoDisponivel>2015-12-31</DataUltimoBalancoDisponivel><DataInicioNegocios>1978-05-23</DataInicioNegocios><EstadoActCod>B</EstadoActCod><RiscoInforma>19</RiscoInforma><CF2>A</CF2><RI2>19</RI2><PubLegaisUlt12meses>0</PubLegaisUlt12meses><IndDimensao>MI</IndDimensao><IndProcessoRevitalizacao>0</IndProcessoRevitalizacao><IndDormant>0</IndDormant><IndSActComer>0</IndSActComer></ResumoX1><FichaEmpresaX1><Nome>ERNESTO PEDRO ANDRÉ, LDA</Nome><Duns>449689512</Duns><NumeroContribuinte>500772037</NumeroContribuinte><TipoMorada>UNICA</TipoMorada><NomeVia>MATOS</NomeVia><Localidade>MATOS DO CARRIÇO</Localidade><CodigoPostal>3105-064</CodigoPostal><EnderecoPostal>CARRIÇO</EnderecoPostal><Website>www.epandre.pt</Website><Email>oficina@epandre.pt</Email><Telefone>236959303</Telefone><Fax>236959308</Fax><SIC>7539</SIC><DescricaoSIC>Serviços de reparação de automóveis, NCA</DescricaoSIC><CAE>45200</CAE><DescricaoCAE>Manutenção e reparação de veículos automóveis</DescricaoCAE><DataUltimoBalancoDisponivel>2015-12-31</DataUltimoBalancoDisponivel><DataUltimoBalancoPublicado>2013</DataUltimoBalancoPublicado><DataUltimaModificacao>2017-03-24</DataUltimaModificacao><DataUltimaConsulta>2015-11-04</DataUltimaConsulta><NumeroConsultas>11</NumeroConsultas><IndMediasSectoriais>1</IndMediasSectoriais><TipoEmpresa>Real</TipoEmpresa></FichaEmpresaX1></Relatorio>');
    
    Test.stopTest();
    DBProp dbpropnew=DBInfoXML.parseDBXML(xmlnew);
    ClientType='Lead';
    ReportDB__C repnew= DBInfoXML.UpdateReport(dbpropnew,ClientType, client.id, pdf);
    ClientType='Client';
    ReportDB__C repnew2= DBInfoXML.UpdateReport(dbpropnew,ClientType, client.id, pdf);

    //Test.stopTest();
  }

  @isTest static void dBInfoXML_existingAccount_test_2()
  {
    //Test.startTest();

    // test WebService CallOut
    string ClientType;
    ClientType='Client';
    Blob pdf=null;
    Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();

    Account client = new Account(name='111222333',nif__c='111222333',Type = 'Customer - Channel');
    
    //string InId='0012400000RRVwYAAX';
    //Test.startTest();
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('XMLNewClient');   
    mock.setStatusCode(200); 
    mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://api.salesforce.com/foo/bar');
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    string xmlnew=res.getbody();
    //HttpResponse res=DBInfoXMLTest.getInfoFromExternalService('http://api.salesforce.com/foo/bar');
    outInt=DBInfoXML.InformadbGetReport('111222333', 'XMLCOMER','Xml', 'Client');
    string xml=outInt.xml;
    DBInfoXML.parseDBXML(xml);
    DBProp dbprop=DBInfoXML.parseDBXML(xml);
    string xml1=outInt.xml;
    DBProp dbprop1=DBInfoXML.parseDBXML(xml1);

    insert client;
    //21/06/17 - necessario por nif (BP)
    pdf = Blob.valueOf('<Relatorio data_xml="2016-05-10" id_xml="31237612"><Identificacao><IDPrincipais><IDPrincipal><EstabelecimentoSecundario>N</EstabelecimentoSecundario></IDPrincipal><IDPrincipalX1><ICI>6201599245100000</ICI><DataUltMod>2015-03-17</DataUltMod>');

    // test Report InformaDB Upsert
    dbprop.NumeroContribuinte = '111222333';
    dbprop.TotEmpregados = null;
    dbprop.TotEmpregados = null;
    dbprop.Localidade ='Rua dos testes nº666 , Freguesia do Salesforce, Dream Country.';
    dbprop.DataConstituicao = Date.valueOf('1680-01-01');
    dbprop.EnderecoPostal = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.CodigoPostal = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.NomeVia = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.SituacaoContributiva ='A empresa não deve nada, encontra-se com a sua situação regularizada, nunca se atrasando nos pagamentos das mensalidades que a ela lhe dizem respeito. Encontra-se no seu auge empresarial, empregando deste modo 500 colaboradores. Foi sediada na Comarca de Lisboa com o registo xxxxx.';
     
    Test.startTest();
    
    ReportDB__C rep1 = DBInfoXML.UpdateReport(dbprop1,ClientType, client.id, pdf); 
    ClientType='Lead';
    ReportDB__c Report= DBInfoXML.UpdateReport(dbprop,ClientType, client.id, pdf);
    ClientType='';
    ReportDB__c Report1= DBInfoXML.UpdateReport(dbprop,ClientType, client.id , pdf);
    DBProp dbpropnew=DBInfoXML.parseDBXML(xmlnew);
    ClientType='Lead';
    Test.stopTest();
    
   
  } 

  @isTest static void dBInfoXML_existingAccount_test_3()
  {
    //Test.startTest();

    // test WebService CallOut
    string ClientType;
    ClientType='Client';
    Blob pdf=null;
    Utilities.OutboundIntegration outInt=new Utilities.OutboundIntegration();
    Utilities.OutboundIntegration outIntPdf=new Utilities.OutboundIntegration();

    Account client = new Account(name='111222333',nif__c='111222333',Type = 'Customer - Channel');
    
    //string InId='0012400000RRVwYAAX';
    //Test.startTest();
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('XMLNewClient');   
    mock.setStatusCode(200); 
    mock.setHeader('Content-Type', 'text/xml');
    Test.setMock(HttpCalloutMock.class, mock);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://api.salesforce.com/foo/bar');
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    string xmlnew=res.getbody();
    //HttpResponse res=DBInfoXMLTest.getInfoFromExternalService('http://api.salesforce.com/foo/bar');
    outInt=DBInfoXML.InformadbGetReport('111222333', 'XMLCOMER','Xml', 'Client');
    string xml=outInt.xml;
    DBInfoXML.parseDBXML(xml);
    DBProp dbprop=DBInfoXML.parseDBXML(xml);

    insert client;
    //21/06/17 - necessario por nif (BP)
    pdf = Blob.valueOf('<Relatorio data_xml="2016-05-10" id_xml="31237612"><Identificacao><IDPrincipais><IDPrincipal><EstabelecimentoSecundario>N</EstabelecimentoSecundario></IDPrincipal><IDPrincipalX1><ICI>6201599245100000</ICI><DataUltMod>2015-03-17</DataUltMod>');

    // test Report InformaDB Upsert
    dbprop.NumeroContribuinte = '111222333';
    dbprop.TotEmpregados = null;
    dbprop.TotEmpregados = null;
    dbprop.Localidade ='Rua dos testes nº666 , Freguesia do Salesforce, Dream Country.';
    dbprop.DataConstituicao = Date.valueOf('1680-01-01');
    dbprop.EnderecoPostal = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.CodigoPostal = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.NomeVia = 'Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country Rua dos testes nº666 , Freguesia do Salesforce, Dream Country';
    dbprop.SituacaoContributiva ='A empresa não deve nada, encontra-se com a sua situação regularizada, nunca se atrasando nos pagamentos das mensalidades que a ela lhe dizem respeito. Encontra-se no seu auge empresarial, empregando deste modo 500 colaboradores. Foi sediada na Comarca de Lisboa com o registo xxxxx.';
      DBProp dbpropnew=DBInfoXML.parseDBXML(xmlnew);
    Test.startTest();
    
    /*ReportDB__C repnew= DBInfoXML.UpdateReport(dbpropnew,ClientType, client.id, pdf);
    ClientType='';*/
    ReportDB__C repnew1= DBInfoXML.UpdateReport(dbpropnew,ClientType, client.id, pdf);
    ClientType='Client';
    ReportDB__C repnew2= DBInfoXML.UpdateReport(dbpropnew,ClientType, client.id, pdf);
    
    Test.stopTest();
  }   

  @isTest static void doRequestImpelentationTest(){
    Test.startTest();
        DBInfoXML dbinfoxml = new DBInfoXML();
        dbinfoxml.doRequest('510167250');
    Test.stopTest();
  }
}