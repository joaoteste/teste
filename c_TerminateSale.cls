Public class c_TerminateSale{

    public PageReference pgReturnPage;
    Public string IdUrl {get;set;} 

    Public c_TerminateSale (ApexPages.StandardController stdController){
        IdUrl  = stdController.GetID();
       
        String returnUrl = '/' + IdUrl;
        pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
    }    
    
    Public PageReference RedirectCollectionCase(){
        Collection_Case__c cc = [SELECT id FROM Collection_Case__c WHERE id =:IdUrl];        
        RecordType rt = [Select Id From RecordType where DeveloperName = 'Terminate_Sale_and_Purchase_Contract'];        
        cc.RecordTypeId= rt.Id;     
        cc.Terminate_Sale_and_Purchase_Agreement_Tr__c = True;
        cc.Date_Terminate_Sale_Purchase_Agreement__c = Date.Today();  
        update cc;
    
        return pgReturnPage;
    }
    
}