global class ContactCreation {

    @Future(callout=True)
    global static void createLogin( String email, string vendorId, string conId){
        try{
            
            list<login__c> log=[select Id from login__c where username__c=:email];
            if(log.size()==0){
                Login__c newlogin=new Login__c (Email__c=email, Username__c=email, Vendor_vendor__c=conId, IdVendor__c=vendorId, master__c=true);
                insert newlogin;
                // HP - 29/03/2017 - Changed to generate password with new methods  
                //string idlogin=newlogin.id;
                //Authenticate.generatorPassword(idlogin, 4); 
                CandorAuthorization.resetPassword(email, false); 
            }
           	Account vendor=[select Id, Name from account where Id=: vendorId ];
            vendor.Vendor_Signer_1__c=conId;
            update vendor;
        } 
        catch(Exception e){
             system.Debug('ContactCreation' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
          
        }
        
        
    
    }
    
   /* @Future(callout=True)
    global static void sendpswemail( string conid, string loginid, string APIserverurl  ){
    // envia email com login

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://composer.congamerge.com?SolMgr=1&sessionId='+ UserInfo.getSessionId()+'&serverUrl='+ APIserverurl +
                        '&Id='+ loginid + '&CongaEmailTemplateId=a0E2400000HFySx&EmailFromId=0D224000000TNA8&EmailToId='+conId +
                        '&SF1=1&DS7=12&EmailBCC=info@candor.pt');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
    }*/
}