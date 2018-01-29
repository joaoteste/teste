global class DownloadDocument {

    webService static string getApplicationsInvoices(List<ID> AppIDList){
        
        List<attachment> attachmentList = [SELECT ID, Name, body FROM Attachment Where (Name like 'Fa%tura%' or Name like 'FA%TURA%') AND ParentID IN :AppIDList];
        
        List<Object> dataList = new List<Object>();
       
        for(Attachment at :attachmentList)
        {
            Map<String, String> atMap = new Map<String, String>();
            atMap.put( 'ID', at.ID );
            atMap.put( 'Name', at.Name );
            atMap.put( 'Body', EncodingUtil.base64Encode( at.body ));
            datalist.add( atMap );
            
        }
        
        Map<String, Object> response = new Map<String, Object>();
        response.put('status', true);
        if( datalist != null ){
            response.put('data',datalist);
        }
        return json.serialize( response );
    } 
}