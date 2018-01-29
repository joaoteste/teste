public class ClientAppService_getCreditNotes extends ClientAppService{

    
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
        
        /*
        //use this when contacts are migrated to MASTER account
        //get acountMaster.NIF from session
        Session__c session = [SELECT Login__r.Vendor_Vendor__r.Account.NIF__c
                              FROM Session__c WHERE token__c =: sessionToken ORDER BY CreatedDate LIMIT 1];
        
        //get child accounts' Ids from masterNIF
        Map<Id,Account> accounts = new Map<Id,Account> ([SELECT Id
                                                         FROM Account
                                                         WHERE (Type = 'Customer - Channel' OR Type = 'Channel Partner / Vendor')
                                                         AND NIF__c =: session.Login__r.Vendor_Vendor__r.Account.NIF__c]);*/
        
        Session__c session = [SELECT Login__c
        FROM Session__c
        WHERE token__c = :sessiontoken
        ORDER BY CreatedDate LIMIT 1];
        
        List<Contact> contacts = [SELECT AccountId
        FROM Contact
        WHERE Login__c = :session.Login__c];
        
        Contact contact = contacts.get(0);//temporary
        
        //get credit notes
        Map<Id, c2g__codaCreditNote__c> creditNotes = new Map<Id, c2g__codaCreditNote__c>([SELECT Id, External_Credit_Note_Number_text__c, c2g__Invoice__c,
                       c2g__CreditNoteStatus__c, c2g__PaymentStatus__c, c2g__InvoiceDate__c, c2g__DueDate__c, c2g__CreditNoteDate__c, c2g__CreditNoteTotal__c, c2g__CreditNoteDescription__c,
                       c2g__Invoice__r.Application__r.Name, c2g__Invoice__r.Application__r.Payment_Timing__c, c2g__Invoice__r.Application__r.Payment_Freq__c, c2g__Invoice__r.Application__r.Interim_Fee_Days__c,
                       Renting_Application__r.Name, Renting_Application__r.Payment_Timing__c, Renting_Application__r.Payment_Freq__c, Renting_Application__r.Interim_Fee_Days__c
                       FROM c2g__codaCreditNote__c
                       WHERE CreditNote_Email_Status__c = 'Sent' AND c2g__DueDate__c >= 2017-09-01 
                       AND ((c2g__Invoice__r.Application__r.Status__c = 'Contract - Running' OR c2g__Invoice__r.Application__r.Status__c = 'Contract - Arrears')
                       OR (Renting_Application__r.Status__c = 'Contract - Running' OR Renting_Application__r.Status__c = 'Contract - Arrears'))
                       AND c2g__Account__c = :contact.AccountId]);
        
        //get creditNotes Line Items
        List<c2g__codaCreditNoteLineItem__c> cnLineItems = [SELECT c2g__CreditNote__c, c2g__Product__r.Name, c2g__Product__r.ProductCode 
                                                              FROM c2g__codaCreditNoteLineItem__c 
                                                              WHERE c2g__CreditNote__c IN :creditNotes.keySet()];
            
        Map<Id, List<c2g__codaCreditNoteLineItem__c>> cnToLineItems = new Map<Id, List<c2g__codaCreditNoteLineItem__c>>();
        for(c2g__codaCreditNoteLineItem__c cnLI : cnLineItems){
            if(cnToLineItems.containsKey(cnLi.c2g__CreditNote__c)){
                List<c2g__codaCreditNoteLineItem__c> aux = cnToLineItems.get(cnLi.c2g__CreditNote__c);
                aux.add(cnLI);
                cnToLineItems.put(cnLi.c2g__CreditNote__c, aux);
            }else{
                List<c2g__codaCreditNoteLineItem__c> aux = new List<c2g__codaCreditNoteLineItem__c>();
                aux.add(cnLI);
                cnToLineItems.put(cnLi.c2g__CreditNote__c, aux);
            }
        }      
        
        List<Map<String,Object>> totalCreditNotes = new List<Map<String,Object>>();
        for(Id cnId : creditNotes.keySet()){
            Map<String, Object> creditNoteMap = new Map<String,Object>();
            
            c2g__codaCreditNote__c cn = creditNotes.get(cnId);
            //skip credit notes ANULADAS, amazing code....
            if(cn.c2g__CreditNoteDescription__c == null || 
            (cn.c2g__CreditNoteDescription__c != null && !cn.c2g__CreditNoteDescription__c.containsIgnoreCase('anulada'))){
            	creditNoteMap.put('Id', cnId);
	            creditNoteMap.put('number', cn.External_Credit_Note_Number_text__c);
	            creditNoteMap.put('total', cn.c2g__CreditNoteTotal__c);
	            creditNoteMap.put('createdDate', cn.c2g__CreditNoteDate__c);
	            creditNoteMap.put('dueDate', cn.c2g__DueDate__c);
	            
	            if(cn.c2g__Invoice__r.Application__r.Name != null){
	            	creditNoteMap.put('applicationNumber', cn.c2g__Invoice__r.Application__r.Name);
	            }
	            else if(cn.Renting_Application__r.Name != null){
	            	creditNoteMap.put('applicationNumber', cn.Renting_Application__r.Name);
	            }
	            else{
	            	creditNoteMap.put('applicationNumber', '');
	            }
	            
	            List<c2g__codaCreditNoteLineItem__c> lineItems = cnToLineItems.get(cnId);
	            String period = getPeriodFromInvoice(cn.c2g__Invoice__c, cn, lineItems);
	            creditNoteMap.put('period', period);
	            totalCreditNotes.add(creditNoteMap);
            }
        }
        
        totalCreditNotes = ClientAppService_Utils.orderByDateField(totalCreditNotes, 'dueDate');
        totalCreditNotes = ClientAppService_Utils.groupByRentingApp(totalCreditNotes);
        
        toReturn.put('creditNotes',totalCreditNotes);
        return toReturn;
    }
    
    private String getPeriodFromInvoice(Id invId, c2g__codaCreditNote__c creditNote, List<c2g__codaCreditNoteLineItem__c> lineItems){
    	//get product codes from credit notes line items
    	Set<String> productCodeSet = new Set<String>();
    	for(c2g__codaCreditNoteLineItem__c cnLI : lineItems){
    		productCodeSet.add(cnLI.c2g__Product__r.ProductCode);
    	}
    	
    	List<c2g__codaInvoiceLineItem__c> invoiceLI = [SELECT c2g__Product__r.Name, c2g__Product__r.ProductCode, Billing_Contract_Line_Item__r.Billing_Period__c
    	FROM c2g__codaInvoiceLineItem__c
    	WHERE c2g__Invoice__c = :invId];
    	
    	String period = '';
    	for(c2g__codaInvoiceLineItem__c li : invoiceLI){
    		if(productCodeSet.contains(li.c2g__Product__r.ProductCode)){
    			period = getPeriodFromLineItem(period,creditNote, li);
    		}
    	}
    	
    	return period;
    }
    
    private String getPeriodFromLineItem(String period, c2g__codaCreditNote__c cn, c2g__codaInvoiceLineItem__c li){
    	//aluguer mensal standard/renewal OR aluguer trimestral standard/renewal OR seguro 
		if(li.c2g__Product__r.ProductCode.equals('PT01') || li.c2g__Product__r.ProductCode.equals('PT18')
		|| li.c2g__Product__r.ProductCode.equals('PT09') || li.c2g__Product__r.ProductCode.equals('PT19')
		|| li.c2g__Product__r.ProductCode.equals('PT02')){
			if(period.length() > 0){
				period += ' & ';
			}
			period = (li.Billing_Contract_Line_Item__r.Billing_Period__c != null) ? li.Billing_Contract_Line_Item__r.Billing_Period__c : '';
		}
		//aluguer mensal/trimestral proporcional OR seguro proporcional
		if(li.c2g__Product__r.ProductCode.equals('PT08') || li.c2g__Product__r.ProductCode.equals('PT10') || li.c2g__Product__r.ProductCode.equals('PT11')){
			if(period.length() > 0){
				period += ' & ';
			}
			period += cn.Renting_Application__r.Interim_Fee_Days__c +' dias';
		}
		return period;
    }
    
}