public class AC_Controler_AssignmentOfContract implements Database.AllowsCallouts{
    
    private ApexPages.StandardController standardController;
    public PageReference pgReturnPage;
    public String nif {get; set;}
    public Boolean pdfCertificate {get; set;}
    public Boolean dateClose {get; set;}
    public Boolean disable {get; set;}
    private ID accID;
    public string idURL {get;set;} 
    public String typeOfAssignContract {get; set;}
    public Date closedCompanyDate {get; set;} 
      
	public List<SelectOption> getOptions() {
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('Merged Company','Merged Company'));
    	options.add(new SelectOption('Closed Company','Closed Company'));
    	options.add(new SelectOption('Others','Others'));
    	return options;
	}   
 

    
	public Attachment attachment {
	  get {
	      if (attachment == null)
	        attachment = new Attachment();
	      return attachment;
	    }
	  set;
	  }    
    
    public AC_Controler_AssignmentOfContract(ApexPages.StandardController standardController)
    {
    	disable = true;
        this.standardController = standardController;
        
        idURL  = standardController.GetID();
        String returnUrl = '/' + idURL;
        pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
    }    
    
    
	public PageReference upload(ID acID) {
	 
	    attachment.OwnerId = UserInfo.getUserId();
	    attachment.ParentId = acID; // the record the file is attached to
	    attachment.IsPrivate = true;
	    attachment.description = 'Certificate Merge PDF';
	    try { 
	      insert attachment;
	    } catch (DMLException e) {
	      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
	      return null;
	    } finally {
	      attachment = new Attachment(); 
	    }
	
	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
	    return null;
	}
 
    
    public PageReference assignmentContract(){ 
          
        //[Status, assignContractID, description] - for more information check AC_AssignmentContractAPI
        List<String> result = new List<String>();
  
     	ID appID = standardController.getId(); 
  
        result = AC_AssignmentContractAPI.assignmentContract(nif, typeOfAssignContract, appID, accID, closedCompanyDate);  
		AssignmentContract__c ac = AC_AssignmentContractAPI.updateAC(result[1]); 
		if (result[0].equals('Credit Line - Approved')){ 
		    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, ac.Name + ' - Assignment of contract Approved.'));
		}else{ 
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ac.Name + ' - ' + result[0] + ' Description:' + result[2]));
		}  
		  
		if(typeOfAssignContract != 'Others'){ 
			 upload(result[1]);
			 ac.Commercial_Certificate_Upload_Date__c = system.today();
			 update ac;
		}   
        return null;
    }     
    

    public PageReference validate(){
        
        if(String.isEmpty(nif) || !validateNIF(nif)){ 
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Nif is mandatory and should contain 9 digits'));
        }else{
        	if(typeOfAssignContract == 'Merged Company' && attachment.name==null){
        		pdfCertificate=true;
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Certificate Required for merged companies'));
        	}else{	   
        		if(typeOfAssignContract == 'Closed Company' && (attachment.name==null || closedCompanyDate == null)){
        			pdfCertificate=true;
        			dateClose=true;
        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Certificate and Date required for closed companies '));
        		}else{ 
        		disable=false;
        		accID = AC_AssignmentContractAPI.createAccount(nif);
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Data checked and validated. Press Assignment Contract.'));
        		}
       		}
        }
        
        return null;
        	
    }    
    
    private static Boolean validateNIF(String nif){
    	return nif.isNumeric() && nif.length()==9;
    } 
    
}