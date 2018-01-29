public class DBInfoXML implements CreditInfoProviderRequest.CreditInfoProvider {
    //ALTERACAO - 06/04/17 - adicicao de variaveis para fazer mais pedidos à informa (BP)
    //private static final Integer MAX_ATTEMPTS    = 3;
    //private static       Integer CURRENT_ATTEMPT = 1;

    public static DBProp parseDBXML ( String xml){
        try{
            List<Dom.XMLNode> childIdent = new List<Dom.XMLNode>();  
            List<Dom.XmlNode> childInfo = new List<Dom.XmlNode>();
            List<Dom.XmlNode> childLiga = new List<Dom.XmlNode>(); 
            List<Dom.XmlNode> childLocal = new List<Dom.XmlNode>();
            List<Dom.XMLNode> grandchild = new List<Dom.XMLNode>(); 
            List<Dom.XMLNode> ggrandchild = new List<Dom.XMLNode>(); 
            List<Dom.XMLNode> gggrandchild = new List<Dom.XMLNode>(); 
            List<Dom.XMLNode> ggggrandchild = new List<Dom.XMLNode>(); 
            List<String> val = new List<String>();
            string tipoObr;         string dataObr;         string valorObr; string auxmsg=''; string valEstado;
            DBProp valores = new DBProp();  
            valores.ListContacto = new List<DBProp.Contacto>();
            Dom.Document doc = new Dom.Document();
            // load the InformDB xml into the document.
            doc.load(xml);
            //Retrieve the root element for this document.
            Dom.XMLNode CurXML = doc.getRootElement();
            //Retrieve specific values from InformaDB Report
            System.debug('CurXML:'+CurXML);
            for(Dom.XMLNode child : CurXML.getChildElements()) {
                // Get Company Denomination
              
                System.debug('child:'+child);
                if(child.getName() == 'Identificacao'){
                    childIdent=child.getChildren();
                    System.debug('childIdent: ' + childIdent);
                    for (integer i=0; i<childIdent.size();i++){
                        if(childIdent[i].getName()=='Denominacoes'){
                            grandchild=childIdent[i].getChildren();
                            System.debug('Grandchild: ' + grandchild);
                            Boolean fantasyName= false;
                            for(integer j=0; j< grandchild.size(); j++) {
                                System.debug('grandchild[j] ' + grandchild[j]);
                                if(grandchild[j].getName()=='Denominacao'){
                                    System.debug('grandchild[j].getAttributeCount ' + grandchild[j].getAttributeCount());
                                    if (grandchild[j].getAttributeCount() == 2 ) {
                                        if ( grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(0), grandchild[j].getAttributeKeyNsAt(0))=='1' && 
                                            grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(1), grandchild[j].getAttributeKeyNsAt(1))=='1') 
                                        {  
                                            if (grandchild[j].getChildElement('ValorDeno', null)!=null) {
                                                if(!fantasyName){
                                                valores.DenomEmp=grandchild[j].getChildElement('ValorDeno', null).getText();
                                                	fantasyName= true; //da próxima vez que encontrar uma denominaçao será para pôr no campo fantasyName
                                                }else{
                                                	valores.DenoFantasyEmp = grandchild[j].getChildElement('ValorDeno', null).getText();
                                                }
                                            } 
                                        }
                                    }
                                }
                                
                            }
                        }
                        if(childIdent[i].getName()=='FormasJuridicas'){
                            grandchild=childIdent[i].getChildren();
                            for(integer j=0; j< grandchild.size(); j++) {
                                if(grandchild[j].getName()=='FormaJuridica'){
                                    if (grandchild[j].getAttributeCount() > 0 ) {
                                        for (Integer k = 0; k< grandchild[j].getAttributeCount(); k++ ) {
                                            if ( grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k), grandchild[j].getAttributeKeyNsAt(k))=='1') 
                                            {  
                                                if (childIdent[i].getChildElement('FormaJuridica', null)!=null) {
                                                    valores.FormaJuridica=childIdent[i].getChildElement('FormaJuridica', null).getText();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(childIdent[i].getName()=='Estado'){
                            if (childIdent[i].getChildElement('ValorEstado', null)!=null) {
                                valEstado=childIdent[i].getChildElement('ValorEstado', null).getText();
                                valores.ValorEstado=TranslateInfo.GetTranslatedInfo('',valEstado, null);
                            } 
                        }
                        if(childIdent[i].getName()=='InformacoesLegais'){
                            grandchild=childIdent[i].getChildren();
                            for(integer j=0; j< grandchild.size(); j++) {
                                if(grandchild[j].getName()=='InformacaoLegal'){
                                    if(grandchild[j].getChildElement('FormaObrigar', null)!= null ){
                                        valores.FormaObrigar=grandchild[j].getChildElement('FormaObrigar', null).getText();
                                        valores.FormaObrigarVal=TranslateInfo.GetFormaObrigarVal(valores.FormaObrigar);
                                    }
                                }
                            }
                        }
                        if(childIdent[i].getName()=='Contactos'){
                            grandchild=childIdent[i].getChildren();
                            for(integer j=0; j< grandchild.size(); j++) {
                                if(grandchild[j].getName()=='DetalheContacto'){
                                    if (grandchild[j].getAttributeCount() > 0 ) {
                                        for (Integer k = 0; k< grandchild[j].getAttributeCount(); k++ ) {
                                            if ( grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k), grandchild[j].getAttributeKeyNsAt(k))=='D10') 
                                            {  
                                                ggrandchild=grandchild[j].getChildren();
                                                for(integer l=0; l< ggrandchild.size(); l++) {
                                                    if (ggrandchild[l].getName()=='ContactoX1'){
                                                        if  (ggrandchild[l].getChildElement('NomeContacto', null)!=null){
                                                            valores.email=ggrandchild[l].getChildElement('NomeContacto', null).getText()   ;
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
                if(child.getName() == 'InformacoesFinanceiras'){
                    childInfo=child.getChildren();
                    integer anos;
                    for (integer i=0; i<childInfo.size();i++){
                        if(childInfo[i].getName()=='Balancos'){
                            if (childInfo[i].getAttributeCount() > 0 ) {
                                for (Integer m = 0; m< childInfo[i].getAttributeCount(); m++ ) {
                                    anos=integer.valueOf(childInfo[i].getAttributeValue(childInfo[i].getAttributeKeyAt(m), childInfo[i].getAttributeKeyNsAt(m)));
                                }
                            }
                            grandchild=childInfo[i].getChildren();
                            for(integer j=0; j< grandchild.size(); j++) {
                                if(grandchild[0].getName()=='DetalheBalanco'){
                                    ggrandchild=grandchild[0].getChildren();
                                    for(integer k=0; k < ggrandchild.size(); k++) {
                                        if(ggrandchild[k].getName()=='Balanco'){
                                            if  (ggrandchild[k].getChildElement('Ano', null)!=null){
                                                valores.AnoBalanco=Integer.ValueOf(ggrandchild[k].getChildElement('Ano', null).getText())   ;
                                            }                                         
                                        }
                                    }
                                }
                                if(grandchild.size()>1){
                                    if(grandchild[1].getName()=='DetalheBalanco'){
                                        ggrandchild=grandchild[1].getChildren();
                                        for(integer l=0; l < ggrandchild.size(); l++) {
                                            if(ggrandchild[l].getName()=='Balanco'){
                                                gggrandchild=ggrandchild[l].getChildren(); 
                                                for(integer o=1; o< gggrandchild.size(); o++ ){
                                                    if(gggrandchild[o].getName()=='Partidas'){
                                                        ggggrandchild=gggrandchild[o].getChildren();
                                                        for(integer p=0; p < ggggrandchild.size(); p++) {
                                                            if(ggggrandchild[p].getName()=='Partida'){
                                                                if (ggggrandchild[p].getAttributeCount() > 0 ) {
                                                                    for (Integer m = 0; m< ggggrandchild[p].getAttributeCount(); m++ ) {
                                                                        if(ggggrandchild[p].getAttributeValue(ggggrandchild[p].getAttributeKeyAt(m), ggggrandchild[p].getAttributeKeyNsAt(m))=='PG_1073'){
                                                                            if(ggggrandchild[p].getText()!=null){
                                                                                valores.Vendas_n_1=  decimal.valueOf(ggggrandchild[p].getText());
                                                                            }
                                                                        }
                                                                        if(ggggrandchild[p].getAttributeValue(ggggrandchild[p].getAttributeKeyAt(m), ggggrandchild[p].getAttributeKeyNsAt(m))=='PG_1097'){
                                                                            if(ggggrandchild[p].getText()!=null){
                                                                                valores.ResultLiqAno_n_1=   decimal.valueOf(ggggrandchild[p].getText());
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
                                if(grandchild.size()>2){
                                    if(grandchild[2].getName()=='DetalheBalanco'){
                                        ggrandchild=grandchild[2].getChildren();
                                        for(integer l=0; l < ggrandchild.size(); l++) {
                                            if(ggrandchild[l].getName()=='Balanco'){
                                                gggrandchild=ggrandchild[l].getChildren(); 
                                                for(integer o=1; o< gggrandchild.size(); o++ ){
                                                    if(gggrandchild[o].getName()=='Partidas'){
                                                        ggggrandchild=gggrandchild[o].getChildren();
                                                        for(integer p=0; p < ggggrandchild.size(); p++) {
                                                            if(ggggrandchild[p].getName()=='Partida'){
                                                                if (ggggrandchild[p].getAttributeCount() > 0 ) {
                                                                    for (Integer m = 0; m< ggggrandchild[p].getAttributeCount(); m++ ) {
                                                                        if(ggggrandchild[p].getAttributeValue(ggggrandchild[p].getAttributeKeyAt(m), ggggrandchild[p].getAttributeKeyNsAt(m))=='PG_1073'){
                                                                            if(ggggrandchild[p].getText()!=null){
                                                                                valores.Vendas_n_2=  decimal.valueOf(ggggrandchild[p].getText());
                                                                            }
                                                                        }
                                                                        if(ggggrandchild[p].getAttributeValue(ggggrandchild[p].getAttributeKeyAt(m), ggggrandchild[p].getAttributeKeyNsAt(m))=='PG_1097'){
                                                                            if(ggggrandchild[p].getText()!=null){
                                                                                valores.ResultLiqAno_n_2=   decimal.valueOf(ggggrandchild[p].getText());
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
                    }
                }
                
                if(child.getName() == 'InformacoesAdicionais'){
                    childInfo=child.getChildren();
                    for (integer i=0; i<childInfo.size();i++){
                        if(childInfo[i].getName()=='Obrigacoes'){
                            grandchild=childInfo[i].getChildren();
                            for(integer j=0; j< grandchild.size(); j++) {
                                if (grandchild[j].getAttributeCount() > 0 ) {
                                    for (Integer k = 0; k< grandchild[j].getAttributeCount(); k++ ) {
                                        if ( grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k), grandchild[j].getAttributeKeyNsAt(k))=='03' || grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k), grandchild[j].getAttributeKeyNsAt(k)) =='04') 
                                        {
                                            if(grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k), grandchild[j].getAttributeKeyNsAt(k))!=null){
                                                tipoObr=grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k), grandchild[j].getAttributeKeyNsAt(k));
                                            }
                                            if(grandchild[j].getChildElement('DataInformacao', null)!=null){
                                                dataObr=grandchild[j].getChildElement('DataInformacao', null).getText(); 
                                            }
                                            if(grandchild[j].getChildElement('ValorObrigacao', null)!=null){
                                                valorObr=grandchild[j].getChildElement('ValorObrigacao', null).getText(); 
                                            }
                                            auxmsg=TranslateInfo.GetTranslatedInfo(tipoObr, valorObr, dataObr);
                                            
                                        } 
                                    } 
                                }
                            }
                        }
                    }
                    if (auxmsg==''){
                        valores.SituacaoContributiva='A empresa não apresenta dividas' ;
                    } else {
                        valores.SituacaoContributiva=auxmsg; 
                    }    
                }
                //Get Contact Information
                if(child.getName()=='Ligacoes'){
                    childLiga=child.getChildren(); 
                    for (integer i=0; i<childLiga.size();i++){
                        if(childLiga[i].getName()=='LigacoescomPessoas'){
                            grandchild=childLiga[i].getChildren();
                            for(integer j=0; j< grandchild.size(); j++) {
                                if(grandchild[j].getName()=='DetalheLigacaoPessoa'){
                                    if (grandchild[j].getAttributeCount() > 0 ) {
                                        for (Integer k = 0; k< grandchild[j].getAttributeCount(); k++ ) {
                                            if ( grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k), grandchild[j].getAttributeKeyNsAt(k))=='1') {
                                                DBProp.Contacto contacto = new DBProp.Contacto();
                                                contacto.Tipo=grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k+1), grandchild[j].getAttributeKeyNsAt(k+1));
                                                ggrandchild=grandchild[j].getChildren();
                                                for(integer h=0; h< ggrandchild.size(); h++) {
                                                    if ( ggrandchild[h].getName()=='LigacaoPessoa'){ 
                                                        if(ggrandchild[h].getChildElement('Nome', null)!=null){
                                                            contacto.Nome=ggrandchild[h].getChildElement('Nome', null).getText();
                                                        }
                                                        if(ggrandchild[h].getChildElement('Apelido1', null)!=null){
                                                            contacto.Apelido1=ggrandchild[h].getChildElement('Apelido1', null).getText();
                                                        }
                                                        if(ggrandchild[h].getChildElement('Apelido2', null)!=null){
                                                            contacto.Apelido2=ggrandchild[h].getChildElement('Apelido2', null).getText();
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
                    }
                }
                // get website info
                if(child.getName()=='Localizacao'){
                    childlocal=child.getChildren(); 
                    for (integer i=0; i<childlocal.size();i++){
                        if(childlocal[i].getName()=='Moradas'){
                            grandchild=childlocal[i].getChildren();
                            for(integer j=0; j< grandchild.size(); j++) {
                                if(grandchild[j].getName()=='DetalheMorada'){
                                    if (grandchild[j].getAttributeCount() > 0 ) {
                                        for (Integer k = 0; k< grandchild[j].getAttributeCount(); k++ ) {
                                            if ( grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k), grandchild[j].getAttributeKeyNsAt(k))=='1' &&   
                                                grandchild[j].getAttributeValue(grandchild[j].getAttributeKeyAt(k+1), grandchild[j].getAttributeKeyNsAt(k+1))=='A10'){
                                                    ggrandchild=grandchild[j].getChildren();
                                                    for(integer l=0; l< ggrandchild.size(); l++) {
                                                        if(ggrandchild[l].getName()=='MoradaX1'){
                                                            if( ggrandchild[l].getChildElement('Website',  null) !=null ) {
                                                                valores.website= ggrandchild[l].getChildElement('Website',  null).getText();
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
                // Get Risk Assessement Info
                if(child.getName()=='ResumoX1'){
                    if (child.getChildElement('OpiniaoCredito', null) != null) {
                        valores.CapcFin        = child.getChildElement('CapacidadeFinanceira', null).getText();
                    }
                    
                    if (child.getChildElement('IndicadorRisco',  null) !=null ) {
                        try {
                            valores.IndRisco     = Integer.valueOf(child.getChildElement('IndicadorRisco', null).getText()); 
                        }
                        Catch (exception e) {                            valores.IndRisco = null;    
                        }
                    }
                    if (child.getChildElement('OpiniaoCredito', null) != null) {
                        valores.OpCred       = child.getChildElement('OpiniaoCredito', null).getText();
                    }
                    if(child.getChildElement('CapitalSocial', null)!= null ){
                        valores.CapitalSocial  = Decimal.ValueOf(child.getChildElement('CapitalSocial', null).getText());
                    }
                    if(child.getChildElement('DataConstituicao', null)!= null){
                        valores.DataConstituicao  = Date.valueOf(child.getChildElement('DataConstituicao', null).getText());
                    }
                    
                    if(child.getChildElement('TotIncidentes', null)!= null){
                        if (child.getChildElement('TotIncidentes', null).getText()=='') {
                            valores.TotIncidentes = 0;
                        } 
                        else{
                            valores.TotIncidentes   = Integer.valueOf(child.getChildElement('TotIncidentes', null).getText());
                        }
                    }
                    
                    if(child.getChildElement('TotValorIncidentes', null)!= null){
                        if (child.getChildElement('TotValorIncidentes', null).getText()=='') {
                            valores.TotValorIncidentes = 0;
                        } 
                        else{
                            valores.TotValorIncidentes   = Decimal.valueOf(child.getChildElement('TotValorIncidentes', null).getText());
                        }
                    }
                    if(child.getChildElement('TotEmpregados', null)!= null){
                        if (child.getChildElement('TotEmpregados', null).getText()=='') {
                            valores.TotEmpregados = 0;
                        } 
                        else{
                            valores.TotEmpregados   = Integer.valueOf(child.getChildElement('TotEmpregados', null).getText());
                        }
                    }
                    if(child.getChildElement('ResultLiqUltimoAno', null)!= null ){
                        valores.ResultLiqUltimoAno  = Decimal.ValueOf(child.getChildElement('ResultLiqUltimoAno', null).getText());
                    }
                    if (child.getChildElement('RiscoInforma',  null)!=null ) {
                        try {
                            valores.RiscoInforma    = Integer.valueOf(child.getChildElement('RiscoInforma', null).getText());
                        }
                        Catch (exception e) {
                            valores.RiscoInforma = 0;    
                        }
                    }
                    if (child.getChildElement('PercentilScore',  null) != null  ) {
                        try {
                            valores.PercentilScore    = Integer.valueOf(child.getChildElement('PercentilScore', null).gettext());
                        }
                        Catch (exception e) {
                            valores.PercentilScore = 0;    
                        }
                    }
                    if(child.getChildElement('VendasUltimoAno', null)!= null ){
                        valores.VendasUltimoAno  = Decimal.ValueOf(child.getChildElement('VendasUltimoAno', null).getText());
                    }
                    if(child.getChildElement('IndApresInsol', null)!= null ){
                        valores.indApresInsol  = child.getChildElement('IndApresInsol', null).getText();
                    }
                    if(child.getChildElement('IndProcessoRevitalizacao', null)!= null ){
                        valores.indProcessoRevitalizacao  = child.getChildElement('IndProcessoRevitalizacao', null).getText();
                    }

                }
                // Get Summary Info about Company
                if(child.getName()=='FichaEmpresaX1'){
                    if (child.getChildElement('Nome', null) != null) {
                        valores.Nome         = child.getChildElement('Nome', null).getText();
                    }
                    if(child.getChildElement('NumeroContribuinte', null) != null){
                        valores.NumeroContribuinte  = child.getChildElement('NumeroContribuinte', null).getText();
                    }
                    if(child.getChildElement('CAE', null) != null){
                        valores.CAE          = child.getChildElement('CAE', null).getText();
                    }
                    if(child.getChildElement('DescricaoCAE', null) != null){
                        valores.DescricaoCAE       = child.getChildElement('DescricaoCAE', null).getText();
                    }
                    if(child.getChildElement('NomeVia', null) != null){
                        valores.NomeVia        = child.getChildElement('NomeVia', null).getText();
                    }
                    if(child.getChildElement('Localidade', null) != null){
                        valores.Localidade      = child.getChildElement('Localidade', null).getText();    
                    }
                    if(child.getChildElement('CodigoPostal', null) != null){
                        valores.CodigoPostal       = child.getChildElement('CodigoPostal', null).getText();
                    }    
                    if(child.getChildElement('EnderecoPostal', null) != null){
                        valores.EnderecoPostal     = child.getChildElement('EnderecoPostal', null).getText();
                    }
                    if(child.getChildElement('Telefone', null) !=null){
                        valores.Telefone         = child.getChildElement('Telefone', null).getText();
                    }
                    
                }
            }
            system.debug(valores);
            return valores;
        }
        catch(Exception e){
            System.Debug('DBInfoXML parseDBXML - Report InformaDB Not Parsed!');
            system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return null;
        }
    } 
    
    public static Utilities.OutboundIntegration     InformadbGetReport( string Nif, string codigoProc, string RepType, String ClientType){
        System.debug('**********ENTRADA NO INFORMADB_GET_REPORT***********');
        
        Utilities.OutboundIntegration outInt= new Utilities.OutboundIntegration();
        
        try{
            slideInformadbPt.SLIDESoap cl= new slideInformadbPt.SLIDESoap();
            slideInformadbPt.SLIDECredentials cred= new slideInformadbPt.SLIDECredentials();
            List<CredentialsForAPI__mdt> credential=[select Username__c, Password__c from CredentialsForAPI__mdt where DeveloperName ='InformaDB_PT'];
            cred.Username=credential[0].Username__c; 
            cred.Password=credential[0].Password__c;  
            cl.SLIDECredentials = cred; 
            String tipId = 'Nif'; 
            String valorId = Nif;  
            String idProcesso= codigoProc;       
            String bocados= 'True';        
            String refCliente = '';
            slideInformadbPt.ArrayOfTipoOutput tipOutput= new  slideInformadbPt.ArrayOfTipoOutput();
            tipOutput.TipoOutput=new String[]{RepType};
            string xml;
            datetime startreq=datetime.now();
            datetime endreq;
            string status;
            string response;
            
            //system.debug('%%%%');
            if (!Test.isRunningTest())
            {
                try{                                       
                    //System.debug('InformadbGetReport--->Antes do pedido...\ntipId: '+valorId+' idProcesso: '+idProcesso);
                    slideInformadbPt.SlideResponse resp= cl.GetReport(tipId, valorId, idProcesso, bocados, refCliente, tipOutput);
                    System.debug('InformadbGetReport --> Depois do pedido do Report...');
                    system.debug(resp);
                    //ALTERACAO - 06/04/17 - caso falhe da primeira vez faz mais dois pedidos à informa (BP)
                    /*while (resp==null && CURRENT_ATTEMPT <= MAX_ATTEMPTS)
                    {*/
                        // time out given on Service, try again
                        //CURRENT_ATTEMPT++;
						//resp= cl.GetReport(tipId, valorId, idProcesso, bocados, refCliente, tipOutput);
                   /* }  */  

                    if(resp != null && resp.Codigo=='1' && resp.SlideResponseContents!=null && resp.SlideResponseContents.size()!=0)
                    {                                      
                        xml = resp.SlideResponseContents[0].Conteudo;
                        endreq=datetime.now();                      
                        status='Success';             
                    }
                    else
                    {
                        //NIF Não existe na BD
                        endreq=datetime.now();
                        if(resp.Codigo =='2'){ 
                            System.debug('Código de resposta: ' + resp.Codigo + '; NIF_DOES_NOT_EXIST_IN_EXTERNAL_SERVICE');
                            xml='NIF_DOES_NOT_EXIST_IN_EXTERNAL_SERVICE'; //(HP - 2017/10/11 -> Envia mensagem que NIF não existe)                                               
                            status='Failure';  
                        //HP 12/04/2017 - Qualquer código de erro que seja diferente de '2' (nif não existe na informaDB) e '1' (sucesso) ou se a repsosta seja nula passa mensagem de erro no serviço da informaDB               
                        }else if(resp.Codigo!='2' || resp==null || resp.Codigo==''){
                            xml='Erro na comunicação com a InformaDB';  
                            status='Failure';
                        }                        
                        response=resp.Codigo + ' - ' + resp.Mensagem;
                        System.debug('****' + resp);       
                    }
                    //ALTERACAO - 20/07/17 - quando está Stop Distribution (BP)
                    //resp.Codigo ='-98';//para testar
                    if(resp.Codigo == '-98')
                    {
                        xml    = 'STOP-DISTRIBUTION';
                        status = 'Failure'; 
                    } 
                    //ALTERACAO - escrita do  xml nos logs (BP)
                    outInt.startReq=startReq;                    outInt.endReq=endReq;                    outInt.status=status;                    outInt.code=resp.Codigo;
                    outInt.response='RESPONSE: '+resp.Codigo+' - '+ resp.Mensagem;                    outInt.identifierReq=Nif;                    outInt.xml=xml;
                    System.debug('InformadbGetReport -->\n outInt.startReq: '+  outInt.startReq  + '\noutInt.endReq: '+  outInt.endReq + '\noutInt.status: '+ outInt.status+ 
                                 '\noutInt.response: '+  outInt.response + '\noutInt.identifierReq'+ outInt.identifierReq+ '\noutInt.xml' +outInt.xml);
                    //Utilities.LogIntegration(outInt.startReq,outInt.endReq,outInt.status,outInt.code,outInt.response,outInt.identifierReq);
                    System.debug('**********SAIDA DO INFORMADB_GET_REPORT***********');
                    // fim da alteracao
                    return outInt;                   
                }
                catch( CalloutException calle){
                    system.Debug('InformaDB is down');
                    outInt.startReq=startReq;                    outInt.endReq=endReq;                      outInt.status=status;                        outInt.code='INFORMADB';     
                    outInt.response=response;                        outInt.identifierReq=Nif;                      outInt.xml='Error - InformaDB is down';    
                    return outInt;                
                }
            }
            else
            {
                // test WebService CallOut
                StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
                mock.setStaticResource('testreport');             mock.setStatusCode(200);            mock.setHeader('Content-Type', 'text/xml');
                Test.setMock(HttpCalloutMock.class, mock);
                HttpRequest req = new HttpRequest();
                req.setEndpoint('http://api.salesforce.com/foo/bar');
                req.setMethod('GET');
                Http h = new Http();
                HttpResponse res = h.send(req);
                xml=res.getbody();
            }
            
            outInt.startReq=startReq;
            outInt.endReq=endReq;
            outInt.status=status;
            outInt.code= 'INFORMADB';
            outInt.response=response;
            outInt.identifierReq=Nif;
            outInt.xml=xml;           
            return outInt;
        }
        catch (Exception e)
        {
            System.Debug('DBInfoXML InformadbGetReport - Error *** Report InformaDB erro getting report!');
            system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            outInt.startReq=datetime.now();            outInt.status='Failure';            outInt.code='INFORMADB';            outInt.response=e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() ;
            outInt.identifierReq=Nif;            outInt.xml='Error - InformaDB is down';            return outInt;
        }
    }
    
    public static ReportDB__c UpdateReport( DBprop valores, string ClientType, string Inid, Blob pdf) {
        
        Datetime start = Datetime.now();
        ReportDB__c ret;
        
        try{
            
            decimal opcr;
            List<contact> cons= new List<contact>();
            List<DBProp.Contacto> ConfromRep= new List<DBProp.Contacto>();
            string lname='';
            try
            {
                opcr =decimal.valueOf(valores.OpCred);
            }
            catch(Exception e)
            {
                opcr =0; 
            }
            integer maxsize;
            string SFormaObr='';
            integer intTotemp=0;
            
            //ALTERACAO - 16/08/17 - campo deixou de ser preenchido descomentado if abaixo (BP)
            if(valores.FormaObrigar!=null && valores.FormaObrigar!='')
            {
                maxsize=valores.FormaObrigar.length();
                if( maxsize>255)
                    maxsize= 255;
                SFormaObr=valores.FormaObrigar.subString(0,maxsize);
            }
            
            if (valores.DataConstituicao < Date.valueOf('1700-01-01'))
            {
                valores.DataConstituicao=Date.valueOf('1700-01-01');  
            }  
                        
            if(valores.TotEmpregados==null)
            {
                valores.TotEmpregados=intTotemp;
            }
            
            //ALTERACAO - 16/12/16 - truncar campos vindos da resposta da informa (BP)
            
                                              //VALORES EM SALESFORCE
            //valores.NumeroContribuinte  = valores.NumeroContribuinte;               //text(80)
            //valores.CAE          = valores.CAE;                      //text(06)
            
            if(valores.DenomEmp!=null && valores.DenomEmp!='')
            {
                maxsize=valores.DenomEmp.length();
                if( maxsize>255)
                    maxsize= 255;                
              valores.DenomEmp          = valores.DenomEmp.subString(0,maxsize);          //Text(150)      --> Text(255)
          }
            
            if(SFormaObr!=null && SFormaObr!='')
            {
                maxsize=SFormaObr.length();
                if( maxsize>255)
                    maxsize= 255;                
              SFormaObr          = SFormaObr.subString(0,maxsize);             //Text(255)     
            }
            
            if(valores.FormaJuridica!=null && valores.FormaJuridica!='')
            {
                maxsize=valores.FormaJuridica.length();
                if( maxsize>255)
                    maxsize= 255; 
              valores.FormaJuridica       = valores.FormaJuridica.subString(0,maxsize);      //Text(10)       --> Text(255)
            }
            
            if(valores.Nome!=null && valores.Nome!='')
            {
                maxsize=valores.Nome.length();
                if( maxsize>255)
                    maxsize= 255;               
                valores.Nome              = valores.Nome.subString(0,maxsize);             //Text(200)      --> Text(255)
            }
            
            if(valores.DescricaoCAE!=null && valores.DescricaoCAE!='')
            {
                maxsize=valores.DescricaoCAE.length();
                if( maxsize>255)
                    maxsize= 255;                 
              valores.DescricaoCAE    = valores.DescricaoCAE.subString(0,maxsize);       //Text(255)     
            }
            
            //valores.CapitalSocial       = valores.CapitalSocial;                 //Currency(16,2)
            
            if(valores.Localidade!=null && valores.Localidade!='')
            {
                maxsize=valores.Localidade.length();
                if( maxsize>40)
                    maxsize= 40;                                 
              valores.Localidade          = valores.Localidade.subString(0,maxsize);        //Text(40)       
            }
            //valores.TotValorIncidentes   = valores.TotValorIncidentes;              //Currency(16,2)
            //valores.TotIncidentes      = valores.TotIncidentes;                //Number(5,0)
            //valores.DataConstituicao      = valores.DataConstituicao;                //Date
            //opcr                  = opcr;                         //Currency(16, 2)
            //valores.TotEmpregados      = valores.TotEmpregados;                   //Number(10,0)
            //valores.CapcFin        = valores.CapcFin;                    //Text(3)
            //valores.RiscoInforma          = valores.RiscoInforma;                  //Number(3, 0)
            //valores.ResultLiqUltimoAno  = valores.ResultLiqUltimoAno;                //Currency(16,2)
            //valores.Telefone              = valores.Telefone;                    //Phone
            
            if(valores.EnderecoPostal!=null && valores.EnderecoPostal!='')
            {
                maxsize=valores.EnderecoPostal.length();
                if( maxsize>255)
                    maxsize= 255;
              valores.EnderecoPostal      = valores.EnderecoPostal.subString(0,maxsize);      //Text(100)     --> Text(255) // na app que deu erro len=110
            }
            
            if(valores.CodigoPostal!=null && valores.CodigoPostal!='')
            {
                maxsize=valores.CodigoPostal.length();
                if( maxsize>255)
                    maxsize= 255;
              valores.CodigoPostal    = valores.CodigoPostal.subString(0,maxsize);       //Text(8)
            }
            
            //valores.IndRisco        = valores.IndRisco;                    //Number(3,0)
            
            if(valores.NomeVia!=null && valores.NomeVia!='')
            {    
                maxsize=valores.NomeVia.length();
                if( maxsize>255)
                    maxsize= 255;                
              valores.NomeVia        = valores.NomeVia.subString(0,maxsize);         //Text(200)     --> Text(255)
            }
            
            if(valores.SituacaoContributiva!=null && valores.SituacaoContributiva!='')
            {
                maxsize=valores.SituacaoContributiva.length();
                System.debug('Passou com maxsize= '+maxsize);
                if( maxsize>255)
                    maxsize= 255;                
              valores.SituacaoContributiva= valores.SituacaoContributiva.subString(0,maxsize);  //Text(200)     --> Text(255)
            }
            //valores.PercentilScore     = valores.PercentilScore;                //Number(3,0)
            //valores.website         = valores.website;                     //URL(255)
            //valores.email          = valores.email;                     //Email
            //valores.FormaObrigarVal    = valores.FormaObrigarVal;                //Number(2,0)     
            //valores.VendasUltimoAno    = valores.VendasUltimoAno;                //Currency(18,0)
            
            if(valores.ValorEstado!=null && valores.ValorEstado!='')
            {
                maxsize=valores.ValorEstado.length();
                if( maxsize>255)
                    maxsize= 255;                 
              valores.ValorEstado       = valores.ValorEstado.subString(0,maxsize);        //Text(150)      --> Text(255)
            }
            
            //valores.AnoBalanco      = valores.AnoBalanco;                   //Number(4, 0)
            //valores.Vendas_n_1      = valores.Vendas_n_1;                   //Currency(16,2)   
            //valores.Vendas_n_2      = valores.Vendas_n_2;                  //Currency(16,2)   
            //valores.ResultLiqAno_n_1    = valores.ResultLiqAno_n_1;               //Currency(16,2)  
            //valores.ResultLiqAno_n_2    = valores.ResultLiqAno_n_2;               //Currency(16,2)  
      
            
            //ReportDB__c[] repExist = [SELECT Id, Vendor__r.Type FROM ReportDB__c where Name=:valores.NumeroContribuinte];
            ReportDB__c[] repExist = [SELECT Id, Vendor__c FROM ReportDB__c WHERE Vendor__c=:Inid ORDER BY CreatedDate DESC LIMIT 1]; //HP 26/09/2017 --> Procura o report por ID de forma a permitir a ter dois reportes para o mm nif (tipos de contas diferentes)
            if (repExist != null && repExist.size()!=0)
            { 
                //update report data
                for( ReportDB__c report: repExist )
                {
                    report.Name            = valores.NumeroContribuinte;
                    report.CAE__c          = valores.CAE;  
                    report.ValorDeno__c        = valores.DenomEmp;    
                    report.FormaObrigar__c      = SFormaObr; 
                    report.FormaJuridica__c      = valores.FormaJuridica;  
           //         report.Nome__c          = valores.Nome;        // apagado porque ValorDeno tem um valor que é igual
                    report.DescricaoCAE__c      = valores.DescricaoCAE;  
                    report.CapitalSocial__c      = valores.CapitalSocial;
                    report.Localidade__c       = valores.Localidade;  
                    report.TotValorIncidentes__c  = valores.TotValorIncidentes;
                    report.TotIncidentes__c      = valores.TotIncidentes;
                    report.DataConstituicao__c    = valores.DataConstituicao;  
                    report.OpiniaoCredito__c     = opcr  ; 
                    report.TotEmpregados__c      = valores.TotEmpregados;  
                    report.CapacidadeFinanceira__c  = valores.CapcFin; 
                    report.RiscoInforma__c       = valores.RiscoInforma;  
                    report.ResultLiqUltimoAno__c  = valores.ResultLiqUltimoAno;  
                    report.Telefone__c        = valores.Telefone;  
                    report.EnderecoPostal__c     = valores.EnderecoPostal;  
                    report.CodigoPostal__c      = valores.CodigoPostal;
                    report.IndicadorRisco__c    = valores.IndRisco; 
                    report.NomeVia__c        = valores.NomeVia;
                    report.situacaocontributiva__c  = valores.SituacaoContributiva;
                    report.PercentilScore__c     = valores.PercentilScore;
                    report.Web_Site__c         = valores.website; 
                    report.Email__c          = valores.email; 
                    report.FormaObrigarToNr__c    = valores.FormaObrigarVal;
                    report.Sales__c          = valores.VendasUltimoAno;
                    report.Estado__c        = valores.ValorEstado;
                    report.Ano_Ultimo_Balanco__c    = valores.AnoBalanco;
                    report.Sales_n_1__c        = valores.Vendas_n_1; 
                    report.Sales_n_2__c        = valores.Vendas_n_2;
                    report.ResultLiquido_n_1__c    = valores.ResultLiqAno_n_1; 
                    report.ResultLiquido_n_2__c    = valores.ResultLiqAno_n_2; 
                    ret=report;
                }
            } 
            else
            {
                string reptypeid=[select Id from Recordtype where name ='InformaDB'].Id;
                ReportDB__c report;
                if(ClientType=='Client') 
                {
                    report = new ReportDB__c(Name=valores.NumeroContribuinte, NumeroContribuinte__c=valores.NumeroContribuinte, CAE__c= valores.CAE, Vendor__c= Inid, ValorDeno__c=valores.DenomEmp,   FormaObrigar__c=SFormaObr, FormaObrigarToNr__c=valores.FormaObrigarVal, FormaJuridica__c=valores.FormaJuridica, 
                                             DescricaoCAE__c=valores.DescricaoCAE, CapitalSocial__c=valores.CapitalSocial, Localidade__c=valores.Localidade,  TotIncidentes__c=valores.TotIncidentes, TotValorIncidentes__c=valores.TotValorIncidentes, DataConstituicao__c=valores.DataConstituicao,
                                             OpiniaoCredito__c=opcr,TotEmpregados__c=valores.TotEmpregados, CapacidadeFinanceira__c=valores.CapcFin, RiscoInforma__c=valores.RiscoInforma,   ResultLiqUltimoAno__c=valores.ResultLiqUltimoAno, Telefone__c=valores.Telefone, EnderecoPostal__c=valores.EnderecoPostal, CodigoPostal__c=valores.CodigoPostal, 
                                             IndicadorRisco__c=valores.IndRisco, NomeVia__c=valores.NomeVia, situacaocontributiva__c =valores.SituacaoContributiva  , PercentilScore__c =valores.PercentilScore , RecordTypeId=reptypeid ,  Web_Site__c=valores.website, Email__c=valores.email, Sales__c=valores.VendasUltimoAno, Estado__c= valores.ValorEstado,
                                             Ano_Ultimo_Balanco__c=valores.AnoBalanco, Sales_n_1__c=valores.Vendas_n_1, Sales_n_2__c=valores.Vendas_n_2, ResultLiquido_n_1__c=valores.ResultLiqAno_n_1, ResultLiquido_n_2__c=valores.ResultLiqAno_n_2 );
                }
                else if(ClientType=='Lead')
                {  //16/12/16 corrigida situação em que Leads estava a apontar para atributo de Client - JR
                    report = new ReportDB__c(Name=valores.NumeroContribuinte, NumeroContribuinte__c=valores.NumeroContribuinte, CAE__c= valores.CAE, Lead__c= Inid, ValorDeno__c=valores.DenomEmp,   FormaObrigar__c=SFormaObr, FormaObrigarToNr__c=valores.FormaObrigarVal,FormaJuridica__c=valores.FormaJuridica,  DescricaoCAE__c=valores.DescricaoCAE, CapitalSocial__c=valores.CapitalSocial, Localidade__c=valores.Localidade,
                                             /*situacaocontributiva__c=*/         TotIncidentes__c=valores.TotIncidentes, TotValorIncidentes__c=valores.TotValorIncidentes, DataConstituicao__c=valores.DataConstituicao, 
                                             OpiniaoCredito__c=opcr,TotEmpregados__c=valores.TotEmpregados, CapacidadeFinanceira__c=valores.CapcFin, RiscoInforma__c=valores.RiscoInforma,   ResultLiqUltimoAno__c=valores.ResultLiqUltimoAno, Telefone__c=valores.Telefone, EnderecoPostal__c=valores.EnderecoPostal, CodigoPostal__c=valores.CodigoPostal, 
                                             IndicadorRisco__c=valores.IndRisco, NomeVia__c=valores.NomeVia, situacaocontributiva__c =valores.SituacaoContributiva  , PercentilScore__c =valores.PercentilScore , RecordTypeId=reptypeid, Web_Site__c=valores.website, Email__c=valores.email, Sales__c=valores.VendasUltimoAno,Estado__c= valores.ValorEstado,
                                             Ano_Ultimo_Balanco__c=valores.AnoBalanco, Sales_n_2__c=valores.Vendas_n_2,
                                             ResultLiquido_n_1__c=valores.ResultLiqAno_n_1, ResultLiquido_n_2__c=valores.ResultLiqAno_n_2 );
                }
                else if(ClientType=='')
                {
                    report = new ReportDB__c(Name=valores.NumeroContribuinte, NumeroContribuinte__c=valores.NumeroContribuinte, CAE__c= valores.CAE,  Vendor__c= Inid, ValorDeno__c=valores.DenomEmp,    FormaObrigar__c=SFormaObr, FormaObrigarToNr__c=valores.FormaObrigarVal, FormaJuridica__c=valores.FormaJuridica, DescricaoCAE__c=valores.DescricaoCAE, CapitalSocial__c=valores.CapitalSocial, Localidade__c=valores.Localidade,
                                             /*situacaocontributiva__c=*/      TotIncidentes__c=valores.TotIncidentes, TotValorIncidentes__c=valores.TotValorIncidentes, DataConstituicao__c=valores.DataConstituicao, 
                                             OpiniaoCredito__c=opcr,  TotEmpregados__c=valores.TotEmpregados, CapacidadeFinanceira__c=valores.CapcFin, RiscoInforma__c=valores.RiscoInforma,  ResultLiqUltimoAno__c=valores.ResultLiqUltimoAno, Telefone__c=valores.Telefone, EnderecoPostal__c=valores.EnderecoPostal,CodigoPostal__c=valores.CodigoPostal, 
                                             IndicadorRisco__c=valores.IndRisco, NomeVia__c=valores.NomeVia,  situacaocontributiva__c =valores.SituacaoContributiva , PercentilScore__c =valores.PercentilScore, RecordTypeId=reptypeid,  Web_Site__c=valores.website, Email__c=valores.email, Sales__c=valores.VendasUltimoAno, Estado__c= valores.ValorEstado,
                                             Ano_Ultimo_Balanco__c=valores.AnoBalanco, Sales_n_2__c=valores.Vendas_n_2,
                                             ResultLiquido_n_1__c=valores.ResultLiqAno_n_1, ResultLiquido_n_2__c=valores.ResultLiqAno_n_2 );
                }
                ret=report;
            }

            upsert ret;
            
            if(pdf !=null)
            {
                Attachment attach = new Attachment();
                attach.Name = ret.Name + '.pdf';
                attach.Body = pdf;
                attach.ContentType='application/pdf';
                attach.ParentID = ret.Id;
                upsert attach;
            }
            
            // update Lead, Account or Client Information
            if(ClientType=='Lead')
            {
                for( Lead led: [SELECT Id FROM Lead where Id=:Inid] )
                {
                    led.Street=valores.NomeVia; led.City=valores.Localidade; led.PostalCode=valores.CodigoPostal;  led.Country='Portugal'; 
					/*led.State=valores.EnderecoPostal;*/
                    led.NumberOfEmployees=valores.TotEmpregados; led.Company=valores.DenomEmp; led.Phone=valores.Telefone; led.AnnualRevenue=valores.ResultLiqUltimoAno; 
					/* led.LastName=valores.DenomEmp; led.FirstName='';*/                    
					led.Email=valores.email; led.Website=valores.website; led.Sales__c=valores.VendasUltimoAno;
                    update led;
                    ConfromRep=valores.ListContacto;
                    for(integer i=0; i< ConfromRep.size(); i++)
                    {
                        if(ConfromRep[i].Apelido2 !=null)
                        {
                            lName=ConfromRep[i].Apelido2 + ' ' + ConfromRep[i].Apelido1;
                        }
                        else{
                        	                            lName=ConfromRep[i].Apelido1;                        }
                        List<contact> conExist = [select Id from Contact where ext_key__c=: ConfromRep[i].Nome + lname + ConfromRep[i].Tipo + Inid ];
                        if (conExist != null && conExist.size()!=0){ 
                            for( Contact cont: conExist ){    
                                cont.Description=TranslateInfo.GetTranslatedInfo('', ConfromRep[i].Tipo, '') ;                                cont.Department=ConfromRep[i].Tipo;                                cont.ext_key__c=ConfromRep[i].Nome+lname+ConfromRep[i].Tipo+Inid;                                upsert cont ext_key__c;
                            }
                        }
                        else
                        {
                            contact con = new contact();                            con.Lead__c=Inid;                             con.Description=TranslateInfo.GetTranslatedInfo('', ConfromRep[i].Tipo, '') ;                            con.Department=ConfromRep[i].Tipo;                            con.FirstName=ConfromRep[i].Nome;                            con.LastName=lname;                                                       con.ext_key__c=ConfromRep[i].Nome+lname+ConfromRep[i].Tipo+Inid;                            cons.add(con);
                        }
                    }
                    insert cons ;
                }
            }
            else if(ClientType=='Client' || ClientType=='' )
            {
                id receivableacc=null;
                id payableacc=null;
                id expenseAcc = null;
                id inputvat=null;
                id outputvat=null;
                //Account[] accExist = [SELECT Id, Type FROM Account where Nif__c=:valores.NumeroContribuinte ];
                Account[] accExist = [SELECT Id, Type FROM Account where ID=:Inid]; //HP 26/09/2017 --> Procura o Account por ID de forma a permitir a ter dois reportes para o mm nif (tipos de contas diferentesz)
                System.debug('accExist: ' + accExist[0].Id + '; Type: ' + accExist[0].Type);
                list<Accounting_Admin__c> accAdminList=[select id, General_Ledger_Account__c,Accounting_Type__c from Accounting_Admin__c where Config_Name__c  ='Account' 
                                                    	and Type__c= :accExist[0].type];
				
                
                if (accExist != null && accExist.size()!=0){
                    // general ledger account payable or receivable
                    //Alteração 21/12/17 PC Atribuição das accounting admins. As accounts poderão ter os dois tipos (Payable e Receivable)                    
                    if(accAdminList.size()!=0){
                        /* if(accExist[0].type=='Channel Partner / Vendor'){
                            receivableacc=null;
                            payableacc=accAdmin[0].General_Ledger_Account__c;
                        }else{
                            receivableacc=accAdmin[0].General_Ledger_Account__c;
                            payableacc=null;
                        }*/
                        for(Accounting_Admin__c accAdmin : accAdminList){
							if(accAdmin.Accounting_Type__c == 'Accounts Payable Control' ){
								payableacc = accAdmin.General_Ledger_Account__c;
							}
							if(accAdmin.Accounting_Type__c == 'Accounts Receivable Control' ){
								receivableacc = accAdmin.General_Ledger_Account__c;
							}
							if(accAdmin.Accounting_Type__c == 'Default Expense Account'){
								expenseAcc = accAdmin.General_Ledger_Account__c;
							}
                   		}
                    }

                    if( accExist[0].type=='Channel Partner / Vendor'){
						inputvat=null;
                    	outputvat = UTIL_VatInfo.convertPostalCodeIntoVAT(accExist[0],valores.CodigoPostal);                      //ALTERACAO - 11/05/17 - atribuicao correcta dos ivas (BP)
                    }else{ 
						inputvat=UTIL_VatInfo.convertPostalCodeIntoVAT(accExist[0],valores.CodigoPostal);
                    	 outputvat=null;   //ALTERACAO - 11/05/17 - atribuicao correcta dos ivas (BP)                       
                    }
                    
                    //HP 2017/11 remover query do loop. Erro no build
                    ConfromRep=valores.ListContacto;  
                    Set<String> ext_keyArray = new Set<String>(); 
                    String ext_key = '';                    
                    for(integer i=0; i< ConfromRep.size(); i++){
                        if(ConfromRep[i].Apelido2 !=null){
                            lName=ConfromRep[i].Apelido2 + ' ' + ConfromRep[i].Apelido1;
                            ext_key = ConfromRep[i].Nome + lname + ConfromRep[i].Tipo + Inid;
                        }
                        else{
                            lName=ConfromRep[i].Apelido1;
                            ext_key = ConfromRep[i].Nome + lname + ConfromRep[i].Tipo + Inid;
                        }
                        ext_keyArray.add(ext_key);
                    }
                    System.debug(ext_keyArray);
                    List<contact> conExist = [select Id, Name, ext_key__c from Contact where ext_key__c IN: ext_keyArray ]; 
                    //Map<String,Contact> ext_keyArrayMap = new Map<String,Contact>(); 
                    /*for(contact con : conExist){
                        ext_keyArrayMap.put(con.ext_key__c, con);
                    }*/
                    System.debug('conExist: ' + conExist); 
                    for( Account acc: accExist ){
                        acc.BillingStreet=valores.NomeVia;                        acc.BillingCity=valores.Localidade; 
                        acc.BillingPostalCode=valores.CodigoPostal;
                        acc.BillingCountry='Portugal';                        acc.No_of_Employees__c=valores.TotEmpregados;  
                        acc.Name=valores.DenomEmp;
                        acc.Fantasy_Name__c = valores.DenoFantasyEmp;  
                        acc.Phone=valores.Telefone;
                        acc.AnnualRevenue=valores.ResultLiqUltimoAno;                        acc.Email__c=valores.email;
                        acc.Website=valores.website;                         acc.Date_Of_Establishment__c=valores.DataConstituicao;
                        acc.D_B_Failure_Score__c=valores.PercentilScore;                        acc.CAE__c=valores.CAE;
                        acc.Sales__c=valores.VendasUltimoAno;                        acc.Ano_Ultimo_Balanco__c=valores.AnoBalanco; 
                        acc.c2g__CODAVATRegistrationNumber__c=valores.NumeroContribuinte;
                         acc.c2g__CODAAccountsPayableControl__c=payableacc;
                        acc.c2g__CODAAccountsReceivableControl__c=receivableacc;
                        acc.c2g__CODADefaultExpenseAccount__c = expenseAcc;
                         acc.c2g__CODAInputVATCode__c=inputvat; 
                        acc.c2g__CODAOutputVATCode__c=outputvat;
                        update acc;
                       /* ConfromRep=valores.ListContacto;
                       
                        for(integer i=0; i< ConfromRep.size(); i++){//HP 2017/11 remover query do loop. Erro no build
                            if(ConfromRep[i].Apelido2 !=null){
                                lName=ConfromRep[i].Apelido2 + ' ' + ConfromRep[i].Apelido1;
                            }
                            else{
                                lName=ConfromRep[i].Apelido1;
                            }
                            List<contact> conExist = [select Id from Contact where ext_key__c=: ConfromRep[i].Nome + lname + ConfromRep[i].Tipo + Inid ]; 
                            System.debug('conExist: ' + conExist);   */ 
                        boolean existContactUpdateError = false;
                        for(integer i=0; i< ConfromRep.size(); i++){
                            if (conExist != null && conExist.size()!=0){ 
                                for( Contact cont: conExist ){ 
                                    if(ConfromRep[i].Apelido2 !=null){
                                        lName=ConfromRep[i].Apelido2 + ' ' + ConfromRep[i].Apelido1;
                                        //ext_key = ConfromRep[i].Nome + lname + ConfromRep[i].Tipo + Inid;
                                    }else{
                                        lName=ConfromRep[i].Apelido1;
                                        //ext_key = ConfromRep[i].Nome + lname + ConfromRep[i].Tipo + Inid;
                                    } 
                                    cont.Description=TranslateInfo.GetTranslatedInfo('', ConfromRep[i].Tipo, '') ;
                                    cont.Department=ConfromRep[i].Tipo;
                                    //cont.Email='CHANGE_ME@EMAIL.COM';
                                    cont.ext_key__c=ConfromRep[i].Nome+lname+ConfromRep[i].Tipo+Inid;
                                    System.debug('Upsert Contact: ' + cont.ext_key__c);
                                    //upsert cont cont.ext_key__c ;
                                }
                                Database.UpsertResult[] lur =  Database.upsert(conExist, Contact.Fields.ext_key__c, false);
                                
                                for(Database.UpsertResult ur : lur){
                                    existContactUpdateError = !ur.isSuccess() ? true : existContactUpdateError;
                                    break;
                                }
                            }
                            else
                            {   
                                if(ConfromRep[i].Apelido2 !=null){
                                    lName=ConfromRep[i].Apelido2 + ' ' + ConfromRep[i].Apelido1;
                                    //ext_key = ConfromRep[i].Nome + lname + ConfromRep[i].Tipo + Inid;
                                }else{
                                    lName=ConfromRep[i].Apelido1;
                                    //ext_key = ConfromRep[i].Nome + lname + ConfromRep[i].Tipo + Inid;
                                }

                                //ext_keyArray.add(ext_key);

                                contact con = new contact();
                                con.AccountId=Inid;                                con.Description=TranslateInfo.GetTranslatedInfo('', ConfromRep[i].Tipo, '') ;
                                con.Department=ConfromRep[i].Tipo;                                con.FirstName=ConfromRep[i].Nome;
                                con.LastName=lname;
                                /*con.Email='CHANGE_ME@EMAIL.COM';*/

                                con.ext_key__c=ConfromRep[i].Nome+lname+ConfromRep[i].Tipo+Inid;                                
                                cons.add(con);
                                System.debug('New Contact: ' + con.ext_key__c);
                            }
                        }
                        if(existContactUpdateError){
                            String message = 'There was errors updating contact';
                            Outbound_Integration_Log__c log_fail_cont = new Outbound_Integration_Log__c(Start__c = start, End__c = Datetime.now(), Status__c = 'ERROR', Code__c = 'DBINFOXML_UPDATE_CONTACTS', Get_Sent_XML__c = JSON.serialize(ConfromRep, true), Get_Received_XML__c = 'Contacts to be updated: ' + JSON.serialize(conExist, true),  ApplicationID__c = Inid, Message__c = message);
                            insert log_fail_cont;
                        } 
                        insert cons ;
                    }
                }
            }
            
            return ret;  
        }
        catch(Exception e){
            String message = e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage(); 
            Outbound_Integration_Log__c log_fail = new Outbound_Integration_Log__c(Start__c = start, End__c = Datetime.now(), Status__c = 'ERROR', Code__c = 'DBINFOXML_UPDATE_REPORT', Get_Sent_XML__c = JSON.serialize(valores, true), Get_Received_XML__c = JSON.serialize(ret, true),  ApplicationID__c = Inid, Message__c = message, printStackTrace__c = e.getStackTraceString());
            insert log_fail;
            System.Debug('DBInfoXML UpdateReport ERROR! : ' + message);
            return ret;
        }
    }
    
    public static Utilities.OutboundIntegration InformadbGetPdfReport( string Nif, String idProcesso){
        System.debug('**********ENTRADA NO INFORMADB_GET_PDF_REPORT***********');
        Utilities.OutboundIntegration outInt= new Utilities.OutboundIntegration();
        try{
            ReportDB__c Report;
            slideInformadbPt.SLIDESoap cl= new slideInformadbPt.SLIDESoap();
            slideInformadbPt.SLIDECredentials cred= new slideInformadbPt.SLIDECredentials();
            List<CredentialsForAPI__mdt> credential=[select Username__c, Password__c from CredentialsForAPI__mdt where DeveloperName ='InformaDB_PT'];
            cred.Username=credential[0].Username__c; 
            cred.Password=credential[0].Password__c; 
            cl.SLIDECredentials = cred; 
            String tipId = 'Nif';  
            String valorId = Nif;   
            String bocados= 'True';    
            String refCliente = '';
            slideInformadbPt.ArrayOfTipoOutput tipOutput= new  slideInformadbPt.ArrayOfTipoOutput();
            tipOutput.TipoOutput=new String[]{'Pdf'};
            Blob pdf;
            datetime startreq=datetime.now();
            datetime endreq;
            string status;
            string response;
            
            if (!Test.isRunningTest()){
                slideInformadbPt.SlideResponse resp= cl.GetReport(tipId, valorId, idProcesso, bocados, refCliente, tipOutput);
                if(resp!=null){
                    if(resp.Codigo=='-990'  ){
                        endreq=datetime.now();    
                        status='Failure';   
                        resp = cl.GetReport(tipId, valorId, idProcesso, bocados, refCliente, tipOutput);    
                    }
                    if (resp.Codigo=='1'){
                        if(resp.SlideResponseContents!=null && resp.SlideResponseContents.size()!=0) { 
                            endreq=datetime.now();           
                            status='Success';        
                            pdf = EncodingUtil.base64Decode(resp.SlideResponseContents[0].Conteudo);                                
                        }
                    }
                    response=resp.Codigo + ' - ' + resp.Mensagem;
                }
                //ALTERACAO - 29/11/16 - preenchimento dos campos e prints (BP)
                outInt.startReq=startReq;                outInt.endReq=endReq;                          outInt.status=status;                      outInt.code=resp.Codigo;          
                outInt.response='RESPONSE PDF: '+resp.Codigo+' - '+ resp.Mensagem;                         outInt.identifierReq=Nif;                outInt.pdf=pdf; 
                System.debug('InformadbGetReport--->\n outInt.startReq: '+outInt.startReq+ '\noutInt.endReq: '+outInt.endReq + '\noutInt.status: '+outInt.status+ 
                                 '\noutInt.response: '+  outInt.response + '\noutInt.identifierReq: '+ outInt.identifierReq+ '\noutInt.xml: ' +outInt.xml);
                System.debug('**********SAIDA DO INFORMADB_GET_PDF_REPORT***********');
                //fim de alteracao
                return outInt; 
            }
            else {
                // test WebService CallOut
                StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
                mock.setStaticResource('testreportPdf');             mock.setStatusCode(200);            mock.setHeader('Content-Type', 'application/pdf');
                Test.setMock(HttpCalloutMock.class, mock);
                HttpRequest req = new HttpRequest();
                req.setEndpoint('http://api.salesforce.com/foo/bar');
                req.setMethod('GET');
                Http h = new Http();
                HttpResponse res = h.send(req);
                pdf=res.getBodyAsBlob();

            }
            outInt.startReq=startReq;
            outInt.endReq=endReq;          
            outInt.status=status;      
            outInt.code='INFORMADBPdf';          
            outInt.response=response;          
            outInt.identifierReq=Nif;          
            outInt.pdf=pdf;           
            return outInt; 
        }
        catch (Exception e) {
            System.Debug('DBInfoXML InformadbGetReport - Error *** Pdf for Report InformaDB error getting report!');
            system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            outInt.startReq=datetime.now();
            outInt.status='Failure';
            outInt.code='INFORMADBPdf';
            outInt.response=e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() ;
            outInt.identifierReq=Nif;
            outInt.xml='Error - InformaDB is down';
            return outInt;
        }
    }

     /***********************************************************************************************************
    * @description Wrapper to do the request to informaDb and handle the response from the CreditInfoProviderRequest
    * @param NIF -> NIF: taxpayer number   
    * @return DBInfoXMLResponse
    */
    public DBInfoXMLResponse doRequest(String nif){

        Utilities.OutboundIntegration outInt = new Utilities.OutboundIntegration();
        Utilities.OutboundIntegration outIntPdf = new Utilities.OutboundIntegration();

        System.debug('[DBInfoXML - doRequest()] -> GOING TO REQUEST CREDIT REPORT FOR TAXPAYER NUMBER: ' + nif);
        
        //Request to get credit info XML
        outInt=DBInfoXML.InformadbGetReport( nif , 'XMLPROS', 'Xml', 'Client'); 

        //contruct inner object to help handle response
        DBInfoXMLResponse response = new DBInfoXMLResponse(outInt);
        
        //LOG response to system debug
        System.debug('[DBInfoXML - doRequest()] -> STATUS FROM INFORMADB: ' + response.status);
        System.debug('[DBInfoXML - doRequest()] -> ERROR: ' + response.error);
        System.debug('[DBInfoXML - doRequest()] -> MESSAGE FROM REQUEST TO INFORMADB: ' + response.info);  
        System.debug('[DBInfoXML - doRequest()] -> XML: ' + response.xml);

        //Request credit info PDF if the request before was successful
        if(response.status) {
            outIntPdf=DBInfoXML.InformadbGetPdfReport(nif, 'XMLPROS');
            //contruct inner object to help handle response
            DBInfoXMLResponse responsePdf = new DBInfoXMLResponse(outIntPdf);

            //save the blob with the pdf
            response.setResponsePdfBlob(responsePdf.pdfBlob);
            
            //LOG response to system debug
            System.debug('[DBInfoXML - doRequest()] -> PDF IS NULL? -> ' + (responsePdf.pdfBlob==null ? 'YES':'NO'));
            slideInformadbPt.GetReport_element Aux_to_Log = SlideInformadbPt.get_XML_Request;
            String request_string   = 'Request.tipId: '      + Aux_to_Log.tipId + 'Request.valorId: '    + Aux_to_Log.valorId  + 'Request.idProcesso: ' + Aux_to_Log.idProcesso + 'Request.bocados: '    + Aux_to_Log.bocados + 'Request.refCliente: ' + Aux_to_Log.refCliente + 'Request.tipOutput: '  + Aux_to_Log.tipOutput.TipoOutput[0];
            //LOG REQUEST TO PDF
            String statusPDF = responsePdf.status ? 'Success':'Failure'; //to put in outbound log
            Utilities.LogIntegrationLongResponse( responsePdf.startDate, responsePdf.endDate, statusPDF,'INFORMADBPdf', responsePdf.info,nif, request_string);
        }

        //Erros that can be received from DBInfoXML.InformadbGetReport()
        System.debug('[DBInfoXML - doRequest()] -> response.error: '  +  response.error);
        System.debug('[DBInfoXML - doRequest()] -> response.status: ' +  response.status);
        
        //LOG REQUEST TO XML
        String status = response.status ? 'Success':'Failure';
        Utilities.LogIntegrationLongResponse( response.startDate, response.endDate, status, 'INFORMADB', response.info, nif, response.xml);

        return response;
    }

    /*******************************************************************************************************
    *wrapper method of parseDBXML to implement interface
    */
    public DBProp parseXML(String xml){
       return parseDBXML(xml);
    }

    /*******************************************************************************************************
    *
    * INNER CLASSES.
    *
    ********************************************************************************************************/    

    /*******************************************************************************************************
    * @description Inner class to handle the Object received from DBInfoXML.InformadbGetReport();
    */
    public class DBInfoXMLResponse extends CreditInfoProviderResponse{

        public DBInfoXMLResponse(Utilities.OutboundIntegration outboundResponse){
            
            super();
            
            this.xml = outboundResponse.status == 'Success' ? outboundResponse.xml : '';
            this.status = outboundResponse.status == 'Success' ? true : false;
            this.error = outboundResponse.status == 'Failure' ? outboundResponse.xml : '';
            this.info  = outboundResponse.response;
            this.code  = outboundResponse.code;
            this.startDate = outboundResponse.startReq;
            this.endDate = outboundResponse.endReq;
            this.pdfBlob = outboundResponse.pdf;

            if(this.error == 'STOP-DISTRIBUTION'){
                this.statusForCreditInfo = 'STOP-DISTRIBUTION';
            }else if(this.error == 'NIF_DOES_NOT_EXIST_IN_EXTERNAL_SERVICE'){
                this.statusForCreditInfo = 'NONEXISTENT';
            }else if(this.status){
                this.statusForCreditInfo = 'OK';
            }else{
                this.statusForCreditInfo = 'ERROR';
            }
        }
    }
    
}