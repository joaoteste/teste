@isTest
global class DBinfoServicesESTest implements HttpCalloutMock {
   
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://services.informa.es/soap/gps', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        StaticResource respSrv = [SELECT Id, Body FROM StaticResource WHERE Name = 'InformaDB_ES_TestResp' LIMIT 1];
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(EncodingUtil.base64Encode(respSrv.Body));
        res.setStatusCode(200);
        return res;
    }


    @isTest
    public static void testDBInfoServices() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new DBinfoServicesESTest());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Utilities.OutboundIntegration res = DBInfoServicesES.DBInfogetReport( 'A80192727', 'INFORME_COMERCIAL', '5.38', false);
        system.debug(res);

         staticResource respSrv = [SELECT Id, Body FROM StaticResource WHERE Name = 'InformaDB_ES_TestResp' LIMIT 1];
        string  xml=respSrv.Body.Tostring();
        
        System.assertEquals(res.xml, xml);
    
    }

    @isTest
    public static void testDBInfoServicesPdf() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new DBinfoServicesESTest());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Utilities.OutboundIntegration res = DBInfoServicesES.DBInfogetReport( 'A80192727', 'INFORME_COMERCIAL', '5.38', true);
        system.debug(res);

        staticResource respSrv = [SELECT Id, Body FROM StaticResource WHERE Name = 'InformaDB_ES_TestResp' LIMIT 1];

        string response=respSrv.Body.toString();
        Dom.Document doc = new Dom.Document();
        string att;
        Blob pdf;
        doc.load(response);
            //Retrieve the root element for this document.
            Dom.XMLNode CurXML = doc.getRootElement();
            List<Dom.XmlNode> childBody = new List<Dom.XmlNode>();
            List<Dom.XmlNode> childCodeResp = new List<Dom.XmlNode>();
            for(Dom.XMLNode root : CurXML.getChildElements()) {
               
                
                childBody=root.getChildren();
                
                for( integer l=0; l<childBody.size(); l++){
                    if(childBody[l].getName()=='getProductResponse'){
                        childCodeResp=childBody[l].getChildren();
                    }
                }
                

                for (integer i=0; i<childCodeResp.size();i++){
                    if(childCodeResp[i].getName()=='attach'){
                        att=childCodeResp[i].getText();
                     }
                }
                
            }
        pdf=EncodingUtil.base64Decode(att);
        
        System.assertEquals(res.pdf, pdf);
    
    }

    @isTest
    public static void testDBInfoESXML(){
         staticResource respSrv = [SELECT Id, Body FROM StaticResource WHERE Name = 'InformaDB_ES_TestResp' LIMIT 1];
        string xml=respSrv.Body.Tostring();
        
        DBProp valtest= DBInfoServicesES.parseDBInfoXML(xml);
    }

}