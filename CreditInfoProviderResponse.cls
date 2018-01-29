/**
* @date 2017
*
* @description class to handle the response from Credit Info Provider request
*/

public virtual class CreditInfoProviderResponse{
    
    public String xml {get; protected set;}
    public String code {get; protected set;}
    public String error {get; protected set;}
    public String info {get; protected set;}
    public boolean status {get; protected set;}
    public Datetime startDate {get; protected set;}
    public Datetime endDate {get; protected set;}
    public Blob pdfBlob {get; protected set;}
    public String statusForCreditInfo {get; protected set;}

    public CreditInfoProviderResponse(){}

    public CreditInfoProviderResponse(String xml, boolean status){
        this.xml     = xml;
        this.status  = status;
        this.statusForCreditInfo = status ? 'OK' : 'ERROR'; 
    }

    public void setResponseXml(String xml){
    	this.xml = xml;
    }

    public void setResponseCode(String code){
    	this.code = code;
    }

    public void setResponseError(String error){
    	this.error = error;
    }
    
    public void setResponseInfo(String info){
    	this.info = info;
    }

    public void setResponseStatus(boolean status){
    	this.status = status;
    }    

    public void setResponseStartDate(Datetime startDate){
    	this.startDate = startDate;
    } 

    public void setResponseEndDate(Datetime endDate){
    	this.endDate = endDate;
    } 

    public void setResponsePdfBlob(Blob pdfBlob){
    	this.pdfBlob = pdfBlob;
    } 

    public void setStatusForCreditInfo(String statusForCreditInfo){
    	this.statusForCreditInfo = statusForCreditInfo;
    }
}