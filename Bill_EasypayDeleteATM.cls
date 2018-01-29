global class Bill_EasypayDeleteATM {
	
	webservice static String deleteReference(ID atmID){
		
		Credentials__c credential = Credentials__c.getInstance('EasyPay');
		ATM_Reference__c atm = [SELECT ID, MB_Payment_Status__c, Amount__c, MB_Reference__c, Payment_Collection__c  FROM ATM_Reference__c WHERE ID = :atmID];
		
		String endpoint = credential.Web_Service_Url__c + '_s/api_easypay_00BG.php?';
		endpoint+= 'ep_cin='+credential.cin__c+'&';
		endpoint+= 'ep_user='+credential.Username__c+'&';
		endpoint+= 'ep_entity='+credential.AccountID__c+'&';
		endpoint+= 'ep_ref='+atm.MB_Reference__c+'&';
		endpoint+= 'ep_delete=yes&';
		endpoint+= 't_value='+atm.Amount__c;
		
		if(String.valueOf(atm.MB_Reference__c).startsWith('6063')){
			HTTPResponse res;
			if(Test.isRunningTest())
				res = getFakeAnswer();
			else 
				res = Rest_Utils.sendGet(endpoint);
			
	        //Process response
	        Dom.Document doc = res.getBodyDocument();
	        
	        //Retrieve the root element for this document.
	        Dom.XMLNode address = doc.getRootElement();
	        
	        String ep_statusRec = address.getChildElement('ep_status', null).getText();		
	        
	        if(ep_statusRec != 'ok0'){
	            System.debug('ERROR: ' + ep_statusRec);
	            return 'Easypay returned error';
	        }
		}
		atm.MB_Payment_Status__c = 'Canceled';
		update atm;
		
		List<Payment_Collection__c> pcList = [SELECT ID, Status__c FROM Payment_Collection__c WHERE ID = :atm.Payment_Collection__c LIMIT 1];
		if(pcList.size() != 0){
			pcList[0].Status__c = 'Unpaid';
			update pcList;
		}
		
		return 'Reference Canceled';
		
	}
	
    
    private static HTTPResponse getFakeAnswer(){
        String body;
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
          body = '<?xml version="1.0"?><getautoMB>';
          body += '<ep_status>ok0</ep_status>';
          body += '</getautoMB>';
          res.setBody(body);
          res.setStatusCode(200);

        System.debug('test body: ' + body);
        return res;

    }   	
    
}