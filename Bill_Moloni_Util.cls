public class Bill_Moloni_Util {

    public static Attachment getPDF(String url, String filename, Id parentId){

       //url = 'https://www.moloni.com/downloads/?h=3ed61efdf77463fd7f06e8bd1e0680a9&d=189606041';   //example URL , only used for tests
       //String url = 'https://www.moloni.com/downloads/?h=98c7ef90097e57380732398e083348e5&d=189548629'; //example URL, only used for tests        
       system.debug('attachPdfToDocument: ' + url);
       system.debug('filename: ' + filename);
       system.debug('parentId: ' + parentId);
       if(url == null){
           return null;
       }
       
       String[] aux2 = url.split('=');
       if(aux2.size() != 3){
          return null;
       }
       String h = aux2[1].left(aux2[1].length() - 2);
       String d = aux2[2];
       
       System.debug('aux2: '+ aux2 );
       System.debug('h: '+ h );
       System.debug('d: '+ d );

       url = 'https://www.moloni.pt/downloads/index.php?action=getDownload&h=' + h + '&d=' + d + '&e=teste@moloni.com&i=1&t=n';

       Http http = new Http();
       HttpRequest req = new HttpRequest();

       req.setEndpoint(url);

       req.setMethod('GET');

       HttpResponse res;
       if(!Test.isRunningTest())
       	res = http.send(req);
       else{
       		res = new HttpResponse();
       		String myString = 'StringToBlob';
            Blob bodyBlob = Blob.valueof(myString);
            res.setBodyAsBlob(bodyBlob);
            res.setStatusCode(200);
       	}

       String doc = res.getBody();

       transient Blob blbPDFContent = res.getBodyAsBlob();                 
       Attachment attachmentPDF = new Attachment();
       attachmentPdf.parentId = parentId;
       attachmentPdf.name =  filename +'.pdf' ;
       attachmentPdf.body = blbPDFContent;
       
       return attachmentPDF;
       
    }	
    
    
    public static void addAttchment(Messaging.SingleEmailMessage email, Attachment attach){
    	system.debug('sendEmailWithDocument');
	    //add attachments to email
	    if(attach != null){
		    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
		    // Add to attachment file list
		    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
		    efa.setFileName(attach.Name);
		    efa.setBody(attach.Body);
		    fileAttachments.add(efa);
		    email.setFileAttachments(fileAttachments);
	    }
    } 
    
}
