public class OCR_API {
    
    public class Item {
        public String artigo { get;set; } 
        public String descricao { get;set; } 
        public decimal preco { get;set; } 
        public decimal quant  { get;set; } 
        public String serialNr { get;set; } 
        
    }
    public class InvoiceOCR{
        public decimal totalIVA{get ; set;}
        public decimal totalValor{get ; set;}
        public string factura{get; set;}
    }
    
    
    
    public static string OCRParse_Api( string appId, string clientId){
        try{
            OCR_API inv= new OCR_API();
            list<OCR_API.Item> itemlist=new list<OCR_API.Item>();
            List<Dom.XMLNode> task = new List<Dom.XMLNode>(); 
            
   			string baseEncoded= EncodingUtil.base64Encode(Blob.valueof('Candor Renting OCR'+':'+'UZalLe9KGfIlu71SPv8cO9VA')); // PRD credencials
           //string baseEncoded= EncodingUtil.base64Encode(Blob.valueof('Read Uploaded Documents'+':'+'ZQAOIKLvGqzsSTZ8UDn8wnoy'));
            string endpoint='https://cloud.ocrsdk.com/processImage';
            
            string parameters='language=PortugueseStandard&exportFormat=txt&profile=documentConversion';
            string msg='';
            
            attachment att=[select id, name, body from attachment where parentId = :appId And name like '%a%tura%' order by CreatedDate desc LIMIT 1];
            
            application__c app=[Select name, Vendor__r.nif__c, Vendor_Invoice_Total__c , Issuing_Date_Invoice__c from application__c where id= :appId];
            Blob body=att.body;
            
            HttpRequest reqOCR = new HttpRequest();
            HTTPResponse resOCR = new HTTPResponse(); 
            Integer timeout_x=20000;
            reqOCR.setTimeout(timeout_x);
            reqOCR.setEndpoint(endpoint+'?'+parameters);
            reqOCR.setMethod('POST');
            reqOCR.setHeader( 'Authorization', 'Basic ' + baseEncoded );
            reqOCR.setHeader( 'Content-Type', 'application/pdf' );
            
            reqOCR.setBodyAsBlob(body);
            Http http = new Http(); 
            
            if (!Test.isRunningTest()){
                resOCR = http.send(reqOCR);  
            }
            
            system.debug(resOCR.getBody());
            string taskid;
            string taskstatus;
            Dom.Document doc = new Dom.Document();
            // load the InformDB xml into the document.
            if(!Test.isRunningTest()){
                doc.load(resOCR.getBody()); 
            }
            else{
                doc.load('<?xml version="1.0" encoding="utf-8"?><response><task id="2e14167d-ca4a-46e7-82f8-b29d37468b59" registrationTime="2016-05-27T16:02:42Z" statusChangeTime="2016-05-27T16:02:42Z" status="Queued" filesCount="1" credits="0" estimatedProcessingTime="5" /></response>');
            }
            
            //Retrieve the root element for this document.
            Dom.XMLNode CurXML = doc.getRootElement();
            //Retrieve specific values from InformaDB Report
            for(Dom.XMLNode child : CurXML.getChildElements()) {
                if(child.getName() == 'task'){
                    if (child.getAttributeCount() > 0 ) {
                        for (Integer k = 0; k< child.getAttributeCount(); k++ ) {
                            if ( child.getAttributeKeyAt(k)=='id'){
                                taskid=child.getAttributeValue(child.getAttributeKeyAt(k), child.getAttributeKeyNsAt(k));
                            }
                            
                        }
                    }
                }
            }
            
            
            string endpoint1='https://cloud.ocrsdk.com/getTaskStatus?taskId='+ taskid; 
            Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
            Integer delayInMilliseconds = 5000; // five-second delay
            string resultUrl;
            
            while(taskstatus!='Completed' && System.now().getTime() - startingTime<  delayInMilliseconds ){
                
                HttpRequest reqstatOCR = new HttpRequest();
                HTTPResponse resstatOCR = new HTTPResponse(); 
                Integer timeout_x1=20000;
                reqstatOCR.setTimeout(timeout_x1);
                reqstatOCR.setEndpoint(endpoint1);
                reqstatOCR.setMethod('GET');
                reqstatOCR.setHeader( 'Authorization', 'Basic ' + baseEncoded );
                
                Http http1 = new Http(); 
                
                if(!Test.isRunningTest()){
                    resstatOCR = http1.send(reqstatOCR);    
                }
                
                
                Dom.Document doc1 = new Dom.Document();
                // load the InformDB xml into the document.
                if(!Test.isRunningTest()){
                    doc1.load(resstatOCR.getbody());  
                }
                else{
                    doc1.load('<?xml version="1.0" encoding="utf-8"?><response><task id="2e14167d-ca4a-46e7-82f8-b29d37468b59" registrationTime="2016-05-27T16:02:42Z" statusChangeTime="2016-05-27T16:02:42Z" status="Completed" filesCount="1" credits="0" resultUrl="https://ocrsdk.blob.core.windows.net/files/2e14167d-ca4a-46e7-82f8-b29d37468b59.result?sv=2012-02-12&amp;se=2016-05-28T02%3A00%3A00Z&amp;sr=b&amp;si=downloadResults&amp;sig=JIzjjACKn1OyzQY1E1wRUSSeiED%2BCQuSmIHUWbGRzAA%3D" /></response>' ) ;                          
                }
                
                
                //Retrieve the root element for this document.
                Dom.XMLNode CurXML1 = doc1.getRootElement();
                //Retrieve specific values from InformaDB Report
                
                for(Dom.XMLNode child1 : CurXML1.getChildElements()) {
                    if(child1.getName() == 'task'){
                        if (child1.getAttributeCount() > 0 ) {
                            for (Integer k = 0; k< child1.getAttributeCount(); k++ ) {
                                if ( child1.getAttributeKeyAt(k)=='status'){
                                    taskstatus=child1.getAttributeValue(child1.getAttributeKeyAt(k), child1.getAttributeKeyNsAt(k));
                                }
                            }
                        }
                    }
                    
                    if(taskstatus=='Completed'){
                        if(child1.getName() == 'task'){
                            if (child1.getAttributeCount() > 0 ) {
                                for (Integer k = 0; k< child1.getAttributeCount(); k++ ) {
                                    if ( child1.getAttributeKeyAt(k)=='resultUrl'){
                                        resultUrl=child1.getAttributeValue(child1.getAttributeKeyAt(k), child1.getAttributeKeyNsAt(k));
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            
            system.debug(resulturl);
            string endpoint2=resultUrl;
           //string endpoint2='https://ocrsdk.blob.core.windows.net/files/ce2c9a77-6027-4c2e-9b2e-60a9cf4b2f09.result?sv=2012-02-12&se=2016-06-02T18%3A00%3A00Z&sr=b&si=downloadResults&sig=j4oycOOol82RYe0o9sBbdz7FxOCesoI5%2FGW%2B4suXaMc%3D';
            
            HttpRequest reqOCRtextXML = new HttpRequest();
            HTTPResponse resOCRtextXML = new HTTPResponse(); 
            Integer timeout_x2=20000;
            reqOCRtextXML.setTimeout(timeout_x2);
            reqOCRtextXML.setEndpoint(endpoint2);
            reqOCRtextXML.setMethod('GET');
            
            Http http2 = new Http(); 
            
            if(!Test.isRunningTest()){
                resOCRtextXML = http2.send(reqOCRtextXML);  
            }
            else{
                
                StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
                mock.setStaticResource('ocr_ex');   
                mock.setStatusCode(200);            mock.setHeader('Content-Type', 'text/plain');
                Test.setMock(HttpCalloutMock.class, mock);
                HttpRequest req = new HttpRequest();
                req.setEndpoint('http://api.salesforce.com/foo/bar');
                req.setMethod('GET');
                Http h = new Http();
                resOCRtextXML = h.send(req);
                
            }   
            system.debug(resOCRtextXML);
            string pdf=resOCRtextXML.getbody();
            string factura='';
            string data='';
            string artigo='';
            string descrip='';
            string quant='';
            string valor='';
            string totalIva='';
            string totalValor='';
            string desconto='';
            string SerialNr='';
            string nif='';
            
            
            if(pdf.IndexOf('Duplicado')!=-1){
                pdf=pdf.substringBefore('Duplicado');
            } else
                if(pdf.IndexOf('DUPLICADO')!=-1){
                    pdf=pdf.substringBefore('DUPLICADO');
                }
            
            
            list<string> lstfactura=pdf.split('\r\n');
            
            integer Items=0;
            integer itemini=0;
            integer itemfim=0;
            integer refPos=-1;
            integer descripPos=-1;
            integer quantPos=-1;
            integer amountPos=-1;
            integer amountTotPos=-1;
            string itemToProc;
            integer sizeamount;
            string strAux='';
            integer descontos=-1;
            integer sizedescontos;
            integer totalllinenr=0;
            integer auxpreco=-1;
            integer sizeauxpreco=-1;
            integer sizedesc=0;
            
            
            Pattern pIVA;
            matcher pmIVA;
            pattern ptotal;
            matcher pmtotal;
            Pattern pSN;
            matcher pmSN;
            
            // numbers start from right, big word for quantity 
            integer sizeQuant=0;
            
            for(integer m=0; m<lstfactura.size(); m++){
            
                if( totalllinenr!=0 && nif=='' ){
               
                    string auxnif='';
                    If( lstfactura[m].IndexOf('NIF') > -1 && nif=='' ){
                        auxnif=lstfactura[m].substring(lstfactura[m].IndexOf('NIF')+3, lstfactura[m].length()) ;
                        Pattern pnif = Pattern.compile('(\\d+)');
                        Matcher pmnif = pnif.matcher( lstfactura[m] );
                        if( pmnif.find() ){
                           // system.debug('cont' + pmnif.group(0)  );
                            nif=pmnif.group(0) ;
                        }
                    }
                    If( lstfactura[m].IndexOf('NIPC') > -1 && nif=='' ){
                        auxnif=lstfactura[m].substring(lstfactura[m].IndexOf('NIPC')+4, lstfactura[m].length()) ;
                        Pattern pnif = Pattern.compile('(\\d+)');
                        Matcher pmnif = pnif.matcher( lstfactura[m] );
                        if( pmnif.find() ){
                         //   system.debug('cont' + pmnif.group(0)  );
                            nif=pmnif.group(0) ;
                        }
                    }
                    If( lstfactura[m].IndexOf('Contribuinte n°.') > -1 && nif==''){
                        auxnif=lstfactura[m].substring(lstfactura[m].IndexOf('Contribuinte n°')+16, lstfactura[m].length()) ;
                        Pattern pnif = Pattern.compile('(\\d+)');
                        Matcher pmnif = pnif.matcher( lstfactura[m] );
                        if( pmnif.find() ){
                            system.debug('cont' + pmnif.group(0)  );
                            nif=pmnif.group(0);
                        }
                    }
                    If( lstfactura[m].IndexOf('Contribuinte n°') > -1 && nif==''){
                        auxnif=lstfactura[m].substring(lstfactura[m].IndexOf('Contribuinte n°')+16, lstfactura[m].length()) ;
                        Pattern pnif = Pattern.compile('(\\d+) (\\d+) (\\d+)');
                        Matcher pmnif = pnif.matcher( lstfactura[m] );
                        if( pmnif.find() ){
                           // system.debug('cont' + pmnif.group(0)  );
                            nif=pmnif.group(0);
                        }
                    }
                    If( lstfactura[m].IndexOf('Contribuinte: ') > -1 && nif==''){
                        auxnif=lstfactura[m].substring(lstfactura[m].IndexOf('Contribuinte: ')+14, lstfactura[m].length()) ;
                        Pattern pnif = Pattern.compile('(\\d+) (\\d+) (\\d+)');
                        Matcher pmnif = pnif.matcher( lstfactura[m] );
                        if( pmnif.find() ){
                            system.debug('cont' + pmnif.group(0)  );
                            nif=pmnif.group(0);
                        }
                    }
                    If( lstfactura[m].IndexOf('N/N,Contribuinte: ') > -1 && nif==''){
                        auxnif=lstfactura[m].substring(lstfactura[m].IndexOf('N/N,Contribuinte: ')+14, lstfactura[m].length()) ;
                        Pattern pnif = Pattern.compile('(\\d+)');
                        Matcher pmnif = pnif.matcher( lstfactura[m] );
                        if( pmnif.find() ){
                            system.debug('cont' + pmnif.group(0)  );
                            nif=pmnif.group(0);
                        }
                    }
                    
                    
                }
                if(nif=='' && lstfactura[m].IndexOf('Capital Social ') >-1 ){
                    string auxnif='';
                    auxnif=lstfactura[m].substring(lstfactura[m].IndexOf('N° Contribuinte:')+17, lstfactura[m].length()) ;
                    Pattern pnif = Pattern.compile('(\\d+)');
                    Matcher pmnif = pnif.matcher( lstfactura[m] );
                    if( pmnif.find() ){
                        system.debug('cont' + pmnif.group(0)  );
                        nif=pmnif.group(0);
                    }  
                    
                }
                if(factura==''){
                    //Nº Factura
                    string str=lstfactura[m].substring(lstfactura[m].IndexOf('N°')+3, lstfactura[m].length() );
                    
                    Pattern pfac = Pattern.compile('(\\D+\\d+\\/\\d+)');
                    Matcher pmfac = pfac.matcher( str);
                    if( pmfac.find() ){
                        factura=pmfac.group(1);
                        // system.debug(pmfac.group(1)) ;
                    }
                    
                    
                    if((lstfactura[m]).IndexOf('NFa')> -1){
                        // system.debug(lstfactura[m]);
                        factura=lstfactura[m].substring(lstfactura[m].IndexOf('NFa')+3, lstfactura[m].length());
                        system.debug(factura);
                    }
                    
                    if(factura=='' && (lstfactura[m]).IndexOf('Factura')> -1){
                        // system.debug(lstfactura[m]);
                        //  factura=lstfactura[m].substring(lstfactura[m].IndexOf('Factura')+7, lstfactura[m].IndexOf(' '));
                        system.debug(factura);
                    }
                }
                if(data==''){
                    // data factura
                    //if(lstfactura[m].IndexOf('Data')> -1){
                    Pattern p = Pattern.compile('(\\d+)-(\\d+)-(\\d+)');
                    Matcher pm = p.matcher( lstfactura[m] );
                    if( pm.find() ){
                        //system.debug(pm.group(1) + ' : ' + pm.group(2) + ' : '+ pm.group(3) );
                        data=pm.group(1)+ '-' + pm.group(2)  +'-' + pm.group(3) ;
                        
                    }

                }
                if(lstfactura[m].indexOf('Código  ')!=-1){
                    itemini=m;
                    string str=lstfactura[m].trim();
                    refPos=str.indexOf('Código  ');
                    descripPos=lstfactura[m].indexOf('Designação');
                    quantPos=lstfactura[m].indexOf('Quantidade');
                    sizeQuant=('Quantidade').length();
                    amountPos=lstfactura[m].indexOf('Preço');
                    sizeamount=('Pr. Unitário').length();
                }
                
                if(lstfactura[m].indexOf('Artieo  ')!=-1){
                    itemini=m;
                    string str=lstfactura[m].trim();
                    refPos=str.indexOf('Artieo  ');
                    descripPos=lstfactura[m].indexOf('Designação');
                    sizedesc=('Designação').length();
                    quantPos=lstfactura[m].indexOf('Quantidade');
                    sizeQuant=('Quantidade').length();
                    amountPos=lstfactura[m].indexOf('Preco');
                    sizeamount=('Preco').length();
                    auxpreco=lstfactura[m].indexOf('Desc.l');    
                    
                }
                
                if(lstfactura[m].indexOf('Artigo')!=-1){
                    itemini=m;
                    refPos=lstfactura[m].indexOf('Artigo');
                    descripPos=lstfactura[m].indexOf('Descrição');
                
                    if ( descripPos == -1 ) {
                        descripPos=lstfactura[m].indexOf('Designação');
                    }
                   
                    quantPos=lstfactura[m].indexOf('Quant.');
                    sizeQuant=('Quant.').length();
                    if ( quantPos == -1 ) {
                        quantPos=lstfactura[m].indexOf('Quantidade');
                        sizeQuant=('Quantidade').length();
                    }
                    if ( quantPos == -1 ) {
                        quantPos=lstfactura[m].indexOf('Qtd. Un.');
                        sizeQuant=('Qtd. Un.').length();
                    }
                   
                    descontos=lstfactura[m].indexOf('Descontos');
                    sizedescontos=('Descontos').length();
                    amountPos=lstfactura[m].indexOf('Pr. Unitário');
                    sizeamount=('Pr. Unitário').length(); 
                    if ( amountPos==-1){
                        amountPos=lstfactura[m].indexOf('Preço Unit.');
                       
                    }
                    if ( sizeamount==-1){
                        sizeamount=lstfactura[m].indexOf('Preço Unit.');
                       
                    }
                    if ( amountPos==-1){
                        amountPos=lstfactura[m].indexOf('Preco');
                    }
                    if ( sizeamount==-1){
                        sizeamount=lstfactura[m].indexOf('Preco');
                    }
                    if ( amountPos==-1){
                        amountPos=lstfactura[m].indexOf('Preço Un.');
                    }
                    if ( sizeamount==-1){
                        sizeamount=lstfactura[m].indexOf('Preço Un.');
                    }
                    
                }
				if(lstfactura[m].indexOf('Referência  ')!=-1){
                    itemini=m;
                    string str=lstfactura[m].trim();
                    refPos=str.indexOf('Referência  ');
                    descripPos=lstfactura[m].indexOf('Designação');
                    sizedesc=('Designação').length();
                    quantPos=lstfactura[m].indexOf('Qtd.');
                    sizeQuant=('Qtd.').length();
                    amountPos=lstfactura[m].indexOf('Preço');
                    sizeamount=('Preço').length();
 
                    
                }	
                if(lstfactura[m].indexOf('REFERÊNCIA')!=-1){
                    itemini=m;
                    refPos=lstfactura[m].indexOf('REFERÊNCIA');
                    descripPos=lstfactura[m].indexOf('DESCRIÇÃO');
                    quantPos=lstfactura[m].indexOf('QUANTIDADE');
                    sizeQuant=('QUANTIDADE').length();
                    amountPos=lstfactura[m].indexOf('VALOR LIQUIDO');
                    sizeamount=('VALOR LIQUIDO').length();
                }
                
                if(lstfactura[m].indexOf('Refã Item')!=-1){
                    itemini=m;
                    refPos=lstfactura[m].indexOf('Refã Item');
                    descripPos=lstfactura[m].indexOf('Descrição');
                    quantPos=lstfactura[m].indexOf('Qtde');
                    sizeQuant=('Qtde').length();
                    amountPos=lstfactura[m].indexOf('Preço');
                    sizeamount=('Preço').length();
                }
                
                if((lstfactura[m].trim()).length()==0 && m < lstfactura.size() -1 && (lstfactura[m+1].trim()).length()==0  )   {

                    if((m > itemini && itemini != 0 && itemfim ==0 )|| ( itemini==itemfim && itemini!=0) ){
                        itemfim=m-1;
     
                        if(itemfim==itemini){
                            if ((lstfactura[m+2].trim()).length()==0 ){
                              itemfim=m-1;  

                            }
                        }
                    }
                  
                } else
                    if( m < lstfactura.size() -1 && (lstfactura[m].indexOf('Os artigos facturados foram colocados à disposição do adquirente nesta data')!=-1 || lstfactura[m].indexOf('Os artigos serviços constantes desta factura foram entregues prestados na data supra indicada')!=-1 )  ){
                      
                        if(m > itemini && itemini != 0 && itemfim ==0 ){
                            itemfim=m-1;
                      
                        }
                    } 
                else    
                    if( m < lstfactura.size() -1 && (lstfactura[m].indexOf('Os artigos serviços constantes desta factura foram entregues prestados na data supra indicada')!=-1) )  {
                        if(m > itemini && itemini != 0 && itemfim ==0 ){
                            itemfim=m-1;
             
                        }
                    }
                
                
               

                if(lstfactura[m].indexOf('Total de IVA')!=-1){
                    lstfactura[m].substring(lstfactura[m].indexOf('Total de IVA'),lstfactura[m].length() );
                    pIVA = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmIVA = pIVA.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Total de IVA'),lstfactura[m].length() ) );
                    if(pmIVA.find()==true){
                        totalIVA=pmIVA.group(0);  
                    }
                    system.debug(totalIVA);
                    
                }
                if(lstfactura[m].indexOf('Total IVA')!=-1){
                    pIVA = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmIVA = pIVA.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Total IVA') ,lstfactura[m].indexOf('  ',lstfactura[m].indexOf('Total IVA') )) );
                    if(pmIVA.find()==true){
                        totalIVA=pmIVA.group(0);  
                    }
                    else{
                        pmIVA =pIVA.matcher( lstfactura[m+1].substring(lstfactura[m].indexOf('Total IVA') ,lstfactura[m].indexOf('  ', lstfactura[m].indexOf('Total IVA') )) ) ;
                        if(pmIVA.find()==true){
                            totalIVA=pmIVA.group(0);  
                        }  else{
                            pIVA = Pattern.compile('(\\d+),(\\d+)');
                            pmIVA =pIVA.matcher( lstfactura[m+1].substring(lstfactura[m].indexOf('Total IVA') ,lstfactura[m].indexOf('  ', lstfactura[m].indexOf('Total IVA') ) ) ) ;
                            if(pmIVA.find()){
                                totalIVA=pmIVA.group(0);  
                            }
                        }  
                        
                    }
                    
                    sYstem.debug(totalIVA);
                }
                if(lstfactura[m].indexOf('TOTAL I.V.A.')!=-1){
                    pIVA = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmIVA = pIVA.matcher( lstfactura[m].substring(lstfactura[m].indexOf('TOTAL I.V.A.'),lstfactura[m].length() ));
                    if(pmIVA.find()==true){
                        totalIVA=pmIVA.group(0);  
                    }
                    system.debug(totalIVA);
                    
                }
                
                if(lstfactura[m].indexOf('TOTAL de I.V.A.')!=-1){
                    pIVA = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmIVA = pIVA.matcher( lstfactura[m].substring(lstfactura[m].indexOf('TOTAL de I.V.A.'),lstfactura[m].length() ));
                    if(pmIVA.find()==true){
                        totalIVA=pmIVA.group(0);  
                    }
                    system.debug(totalIVA);
                    
                }
                if(lstfactura[m].indexOf('Total de I.V.A.')!=-1){
                    pIVA = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmIVA = pIVA.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Total de I.V.A.'),lstfactura[m].length() ));
                    if(pmIVA.find()==true){
                        totalIVA=pmIVA.group(0);  
                    }
                    system.debug(totalIVA);
                    
                }
                if(lstfactura[m].indexOf('** Total **')!=-1){
                    integer x;
                    totalllinenr=m;
                    strAux=lstfactura[m].substring(lstfactura[m].indexOf('** Total **'),lstfactura[m].length() );
                    if( strAux.indexOf(',') != -1){
                        ptotal = Pattern.compile('(\\d+).(\\d+),(\\d+)'); 
                    }
                    else{
                        ptotal = Pattern.compile('(\\d+).(\\d+).(\\d+)');
                    }
                    
                    pmtotal = ptotal.matcher( lstfactura[m].substring(lstfactura[m].indexOf('** Total **'),lstfactura[m].length() ));
                    if(pmtotal.find()==true){
                        totalValor=pmtotal.group(0);  
                    }
                    if( strAux.indexOf(',') == -1){
                        x   =totalValor.indexOf('.');
                        totalValor=totalValor.substring(0,x ) +(totalValor.substring(x,totalValor.indexOf('.', x+1))).replace('.',',')+totalValor.substring(totalValor.indexOf('.', x+1),totalValor.length());
                    }
                    // system.debug(totalValor);
                    
                }
                if(lstfactura[m].indexOf('Total (')!=-1){
                    totalllinenr=m;
                    ptotal = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmtotal = ptotal.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Total ('),lstfactura[m].length() ));
                    if(pmtotal.find()==true){
                        totalValor=pmtotal.group(0);  
                    }
                    // system.debug(totalValor);
                    
                }
                if(lstfactura[m].indexOf('Total em')!=-1){
                    totalllinenr=m;
                    ptotal = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmtotal = ptotal.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Total em'),lstfactura[m].length() ) );
                    if(pmtotal.find()==true){
                        totalValor=pmtotal.group(0);  
                    }
                    system.debug(totalValor);
                    
                }
                 if(lstfactura[m].indexOf('Total do Documento')!=-1){
                    totalllinenr=m;
                    ptotal = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmtotal = ptotal.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Total do Documento'),lstfactura[m].length() ) );
                    if(pmtotal.find()==true){
                        totalValor=pmtotal.group(0);  
                    }
                    system.debug(totalValor);
                    
                }
                if(lstfactura[m].indexOf('Total Ilíquido')!=-1){
                    totalllinenr=m;
                    ptotal = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmtotal = ptotal.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Total Ilíquido'),lstfactura[m].length() ) );
                    if(pmtotal.find()==true){
                        totalValor=pmtotal.group(0);  
                    }
                    system.debug(totalValor);
                    
                }
                if(lstfactura[m].indexOf('TOTAL')!=-1){
                    totalllinenr=m;
                    ptotal = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmtotal = ptotal.matcher( lstfactura[m].substring(lstfactura[m].indexOf('TOTAL'),lstfactura[m].length() ) );
                    if(pmtotal.find()==true){
                        totalValor=pmtotal.group(0);  
                    }
                    system.debug(totalValor);
                    
                }
                if(lstfactura[m].indexOf('Total Final (EUR) ')!=-1){
                    totalllinenr=m;
                    ptotal = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmtotal = ptotal.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Total Final (EUR)'),lstfactura[m].length() ) );
                    if(pmtotal.find()==true){
                        totalValor=pmtotal.group(0);  
                    }
                    system.debug(totalValor);
                    
                }
                
                if(lstfactura[m].indexOf('Vl-Total (Euros)')!=-1){
                    totalllinenr=m;
                    ptotal = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                    pmtotal = ptotal.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Vl-Total (Euros)'),lstfactura[m].length() ) );
                    if(pmtotal.find()==true){
                        totalValor=pmtotal.group(0);  
                    }
                    system.debug(totalValor);
                    
                }
                
                if(lstfactura[m].indexOf('Valor TOTAL EUR')!=-1){
                    totalllinenr=m;
                    ptotal = Pattern.compile('(\\d+) (\\d+).(\\d+)');
                    pmtotal = ptotal.matcher( lstfactura[m].substring(lstfactura[m].indexOf('Valor TOTAL EUR'),lstfactura[m].length() ) );
                    if(pmtotal.find()==true){
                        totalValor=pmtotal.group(0);  
                    }
                    system.debug(totalValor);
                    
                }
            }


            for(integer k=itemini+1; k<=itemfim; k++){
                OCR_API.Item itemocr = new OCR_API.Item();   
                itemToProc=lstfactura[k].trim();
               //   system.debug(itemToProc);

                if( itemToProc.length()>0) {
                    if(lstfactura[k].substring(0, lstfactura[k].indexOf(' ', refPos))!=''){
                        itemocr.artigo=(lstfactura[k].substring(0, lstfactura[k].indexOf(' ', refPos))).trim();
                        //system.debug('artigo: ' + artigo);
                        
                    }
                    if(descripPos>-1){
                        if( lstfactura[k].substring(descripPos, lstfactura[k].indexOf('  ', descripPos))!=''){
                            itemocr.descricao=lstfactura[k].substring(descripPos, lstfactura[k].indexOf('  ', descripPos)); 
                            //  system.debug('desc' + lstfactura[k].substring(descripPos, lstfactura[k].indexOf('  ', descripPos)));
                        }
                        else{
                            
                            if( lstfactura[k].substring(descripPos+sizedesc, lstfactura[k].indexOf('  ', descripPos+sizedesc))!=''){
                                itemocr.descricao=lstfactura[k].substring(descripPos+sizedesc, lstfactura[k].indexOf('  ', descripPos+sizedesc)); 
                            }
                        
                        }
                        if(itemocr.descricao==null && lstfactura[k].substring(descripPos, quantPos)!=''){
                            itemocr.descricao=(lstfactura[k].substring(descripPos, quantPos)).trim();
                        }
                    } 
                    if(lstfactura[k].indexOf(' UNI ')!=-1){
                        if(lstfactura[k].substring(quantPos,  lstfactura[k].indexOf(' UNI ', quantPos+sizeQuant))!=''){
                            // system.debug('quant:' + lstfactura[k].substring(quantPos,  lstfactura[k].indexOf(' UNI ', quantPos+sizeQuant)));
                            itemocr.quant=decimal.valueOf(((lstfactura[k].substring(quantPos,  lstfactura[k].indexOf(' UNI ', quantPos+sizeQuant))).trim()).replace(',','.'));
                        }
                    } 
                    
                    else{
                        if(quantPos>-1){
                            if(lstfactura[k].substring(quantPos,  lstfactura[k].indexOf('  ', quantPos+sizeQuant))!=' '){
                                
                                if ( itemToProc.length() > 0 &&  (lstfactura[k].substring(quantPos,  lstfactura[k].indexOf('  ', quantPos+sizeQuant))).trim()==''){
                                    if (((lstfactura[k].substring(0, quantPos)).trim()).length()>0){
                                        itemocr.descricao= lstfactura[k].substring(0, quantPos); 
                                    }
                                    
                                } else {
                                    if((lstfactura[k].substring(quantPos,  lstfactura[k].indexOf('  ', quantPos+sizeQuant))).indexOf('UN')>-1){
                                        itemocr.quant=decimal.valueOf(((lstfactura[k].substring(quantPos+4,  lstfactura[k].indexOf('  ', quantPos+sizeQuant))).trim()).replace(',','.'));
                                      
                                          system.debug('q1' + ((lstfactura[k].substring(quantPos+4,  lstfactura[k].indexOf('  ', quantPos+sizeQuant))).trim()).replace(',','.')); 
                                    }
                                    else{
                                     // system.debug('QQuant' + ((lstfactura[k].substring(quantPos,  lstfactura[k].indexOf('  ', quantPos+sizeQuant))).trim()).replace(',','.'));   
                                        if((lstfactura[k].substring(quantPos,  lstfactura[k].indexOf('  ', quantPos+sizeQuant))).trim()!='Unit.'){
                                      	 	 itemocr.quant=decimal.valueOf(((lstfactura[k].substring(quantPos,  lstfactura[k].indexOf('  ', quantPos+sizeQuant))).trim()).replace(',','.'));
                                           
                                        }
                                       
                                    }
                                    
                                }
                                
                            }
                            else{
                                
                                if(lstfactura[k].substring( quantPos, lstfactura[k].indexOf('        ', quantPos))!=' '){
                                    
                                    pattern pquant = Pattern.compile('(\\d+),(\\d+)');
                                    matcher pmquant = pquant.matcher( lstfactura[k].substring( quantPos, lstfactura[k].indexOf('        ', quantPos)) );
                                    if(pmquant.find()==true){
                                        itemocr.quant=decimal.valueof((pmquant.group(0)).replace(',','.'));  
                                    }
                                    // system.debug('q: ' + quant);
                                }
                            }   
                        }
                        
                        
                    }
                    /// ????????
                    if(artigo=='' & quantPos!=-1 && itemocr.quant==null  ){
                        system.debug('quant' + lstfactura[k].substring(quantPos,  lstfactura[k].indexOf('  ', quantPos+sizeQuant)));
                    }
                    ////////
                    if(lstfactura[k].indexOf(' Un ')!=-1){
                        if(lstfactura[k].substring(quantPos,  lstfactura[k].indexOf(' UN ', quantPos+sizeQuant))!=''){
                            // system.debug(lstfactura[k].substring(quantPos,  lstfactura[k].indexOf(' UN ', quantPos+sizeQuant)));
                            itemocr.quant=decimal.valueof((lstfactura[k].substring(quantPos,  lstfactura[k].indexOf(' UN ', quantPos+sizeQuant))).replace(',','.'));
                            //   system.debug('q1: ' + quant);
                        }
                        
                    } 
                    
                    if(descontos!=-1){
                        if (lstfactura[k].substring(descontos,  lstfactura[k].indexOf(' ', descontos+sizedescontos) )!=''){
                            Pattern pd = Pattern.compile('(\\d+),(\\d+)%');
                            Matcher pmd = pd.matcher( lstfactura[k].substring(descontos,  lstfactura[k].indexOf(' ', descontos+sizedescontos) ) );
                            if(pmd.find()==true){
                                desconto=pmd.group(0);
                                //  system.debug(pmd.group(0));  
                            }    
                        }    
                    }

                    if(amountPos != -1){
            
                        if(lstfactura[k].substring(amountPos,  amountPos + sizeamount).trim()!=''){
                            // system.debug('amount:' + lstfactura[k].substring(amountPos,  amountPos + sizeamount));
                            Pattern pA = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                            Matcher pmA = pA.matcher( lstfactura[k].substring(amountPos,  amountPos + sizeamount) );
                            if(pmA.find()==true){
                                // system.debug('amount: ' + pmA.group(0)); 
                                if(desconto!=''){
                                    
                                    itemocr.preco=decimal.valueof((((pmA.group(0)).replace('.','')).replace(',','.')))* (1-decimal.valueOf((( desconto.substring( 0, desconto.IndexOf('%')).trim()).replace(',','.')))/100);
                                }else{
                                    itemocr.preco=decimal.valueof((((pmA.group(0)).replace(' ','')).replace('.','')).replace(',','.'));
                                }
                                
                            }else{
                                pA=Pattern.compile('(\\d+),(\\d+)');
                                pmA= pA.matcher( lstfactura[k].substring(amountPos,  amountPos + sizeamount) );
                                if(pmA.find()==true){
                                    // system.debug('amount: ' + pmA.group(0) );
                                    if(desconto!=''){
                                        itemocr.preco=decimal.valueof(((pmA.group(0).replace('.','')).replace(',','.')))* (1-decimal.valueOf(( desconto.substring( 0, desconto.IndexOf('%')).replace(',','.')))/100);
                                    }else{
                                        itemocr.preco=decimal.valueof((((pmA.group(0).trim().replace(' ','')).replace('.','')).replace(',','.')));
                                    }
                                    
                                }
                            }
                            
                        }
                        system.debug('auxpreco:' + auxpreco + ' - preco:' + amountPos);
                        if(itemocr.preco==null && auxpreco>-1 && lstfactura[k].substring(auxpreco,  lstfactura[k].indexOf('     ', auxpreco)).trim()!=''){
                         //  system.debug('teste' + lstfactura[k].substring(auxpreco,  lstfactura[k].indexOf('   ', auxpreco)-3) );
                          Pattern pA = Pattern.compile('(\\d+).(\\d+)');
                            Matcher pmA = pA.matcher( lstfactura[k].substring(auxpreco,  lstfactura[k].indexOf('     ', auxpreco)-3 ));
                            if(pmA.find()==true){
                              itemocr.preco=decimal.valueof(((pmA.group(0)).replace('.','')).replace(',','.'));
                            }
                        }
                    }
                    if(artigo=='' & amountPos!=-1 && itemocr.preco==null  ){
               
                        system.debug(lstfactura[k].substring(amountPos,  lstfactura[k].indexOf('   ', amountPos)));
                        Pattern pA = Pattern.compile('(\\d+).(\\d+),(\\d+)');
                        Matcher pmA = pA.matcher( lstfactura[k].substring(amountPos,  lstfactura[k].indexOf('   ', amountPos)) );
                        if(pmA.find()==true){
                               itemocr.preco=decimal.valueof(((pmA.group(0)).replace('.','')).replace(',','.'));
                        }
                        else{
                             pA = Pattern.compile('(\\d+) (\\d+).(\\d+)');
                             pmA = pA.matcher( lstfactura[k].substring(amountPos,  lstfactura[k].indexOf('   ', amountPos)) );
                             if(pmA.find()==true){
                               itemocr.preco=decimal.valueof(((pmA.group(0)).replace(' ','')));
                       		 }
                        }
                    }
                   
                    if(descrip!=''){
                        pSN=Pattern.compile('S/N (\\w*)');
                        pmSN=pSN.matcher(descrip);
                        
                        if(pmSN.find() ==true){
                            itemocr.SerialNr=pmSN.group(0);
                            system.debug(pmSN.group(0));
                        }
                    }
                    
                    
                }
                system.debug(itemocr.artigo);
                if(itemocr.artigo!=null || itemocr.descricao!=null || itemocr.quant!= null || itemocr.preco != null ||itemocr.serialNr!=null){
                     itemlist.add(itemocr);    
                }
            }
            if(app.Vendor__r.nif__c != nif && app.Vendor__r.nif__c != '0' + nif ){
                     msg='Verifique se a Factura é a correcta, Nif Parceiro diferente ou não correctamente identificado!';
        
                
                
            } else {
                if(app.Issuing_Date_Invoice__c!=date.valueOf(data)){
                    system.debug('data' + date.valueOf(data));
                    msg='Nif Parceiro Ok!\n Atenção verifique Data da factura!';
                } 
                else{
                    if(app.Vendor_Invoice_Total__c < decimal.valueof(((totalvalor.trim().replace('.','')).replace(',','.'))) + 1 &&  
                       app.Vendor_Invoice_Total__c >  decimal.valueof(((totalvalor.trim().replace('.','')).replace(',','.'))) - 1){
                           msg= 'Nif Parceiro Ok! \n Data Factura Ok! \n Valor Factura Ok!';
                       }
                    else {
                        msg= 'Nif Parceiro Ok! \n Data Factura Ok! \n Atenção - Verifique Valor factura!';
                    }   
                }
                
            }
     //      msg='Nif Parceiro Ok! \n Data Factura Ok! \n Valor Factura Ok!';
        //    if(msg.indexOf('Data Factura Ok! \n Valor Factura Ok!')>-1 ){
                list<Equipment__c> appitems = new list<Equipment__c>();
                Equipment__c appitem;
                string appartigo='';
                string descapp='';
                string serial='';
                integer itemindex=0;
                decimal quantitem=0;
                decimal precoitem=0;
                for(integer l=0; l<itemlist.size(); l++){
                    system.debug(itemindex);
                    if((appartigo!=itemlist[l].artigo  && ( itemlist[l].artigo !='' && itemlist[l].artigo != null &&  itemlist[l].artigo !='*' )) || l==0){
                        system.debug('artigo:' + appartigo);
                        if(itemlist[l].SerialNr==''){
                            serial='N/A';
                        }else{
                            serial=itemlist[l].SerialNr  ;   
                        }
                        if(itemlist[l].artigo!=null){
                            if( (itemlist[l].artigo).length()>21){
                                appartigo=(itemlist[l].artigo).substring(0,21);  
                            }   
                            
                            else{
                                appartigo=itemlist[l].artigo;
                            }
                        }
                        
                        descapp=itemlist[l].descricao;
                        quantitem=itemlist[l].quant;
                        precoitem=itemlist[l].preco;
                        appitem=new Equipment__c(application__c=appId, Equipment_quantity__c=quantitem, Equipment_description__C=descapp, 
                                                 Equipment_brand__C= appartigo, equipment_serial_number__C=serial, account_client__C=clientId, 
                                                 equipment_value__c=precoitem);
                        appitems.add(appitem);
                        itemindex=itemindex+1;
                    }
                    else{
                        system.debug('artigo:' + appartigo);
                        if(itemlist[l].descricao!=null){
                            descapp=descapp+itemlist[l].descricao+'\n';
                        }
                        
                        system.debug(descapp);
                        if(descapp.length()>255){
                            descapp=descapp.substring(0,255);
                        }
                         if(itemlist[l].quant!=null){
                            quantitem=itemlist[l].quant;
                        }
                         if(itemlist[l].preco!=null){
                            precoitem=itemlist[l].preco;
                        }
                        appitems[itemindex-1].equipment_description__c=descapp;
                        appitems[itemindex-1].Equipment_quantity__c=quantitem;
                        appitems[itemindex-1].equipment_value__c=precoitem;
                    }
                    
                    
                } 
                insert appitems;
                msg=msg + '\n Verfique os items da factura!';
           // }      
            
            
            
            return msg;
        }
        catch(Exception e){
            System.Debug('Error in OCR_API!');
            system.Debug('OCR_API' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return 'Error in OCR_API! \n Tente outra vez!';
            
        }
        
    }      
}