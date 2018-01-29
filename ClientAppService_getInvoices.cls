public class ClientAppService_getInvoices extends ClientAppService{

    
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
        
        Map<Id, c2g__codaInvoice__c> invoices;
        //get invoices
        if(args.containsKey('contractId')){
            String contractId = (String) args.get('contractId');
            invoices = new Map<Id, c2g__codaInvoice__c>([SELECT Id, Invoice_Express_Number_text__c, c2g__InvoiceTotal__c, c2g__InvoiceDate__c, c2g__DueDate__c,
                        c2g__PaymentStatus__c, c2g__InvoiceStatus__c, c2g__Period__r.Name, c2g__InvoiceDescription__c,
                        Application__r.Name, Application__r.Payment_Timing__c, Application__r.Payment_Freq__c, Application__r.Interim_Fee_Days__c
                        FROM c2g__codaInvoice__c
                        WHERE Invoice_Email_Status__c = 'Sent' AND c2g__DueDate__c >= 2017-09-01 AND Canceled__c = false 
                        AND (Application__r.Status__c = 'Contract - Running' OR Application__r.Status__c = 'Contract - Arrears')
                        AND Billing_Contract__c =: contractId AND c2g__Account__c IN
                        (SELECT AccountId
                        FROM Contact
                        WHERE Login__c = :session.Login__c
                        )
                        ORDER BY c2g__InvoiceDate__c DESC]);
        }else{
            invoices = new Map<Id, c2g__codaInvoice__c>([SELECT Id, Invoice_Express_Number_text__c, c2g__InvoiceTotal__c, c2g__InvoiceDate__c, c2g__DueDate__c,
                        c2g__PaymentStatus__c, c2g__InvoiceStatus__c, c2g__Period__r.Name, c2g__InvoiceDescription__c,
                        Application__r.Name, Application__r.Payment_Timing__c, Application__r.Payment_Freq__c, Application__r.Interim_Fee_Days__c
                        FROM c2g__codaInvoice__c
                        WHERE Invoice_Email_Status__c = 'Sent' AND c2g__DueDate__c >= 2017-09-01 AND Canceled__c = false 
                        AND (Application__r.Status__c = 'Contract - Running' OR Application__r.Status__c = 'Contract - Arrears')  
                        AND c2g__Account__c IN
                        (SELECT AccountId
                        FROM Contact
                        WHERE Login__c = :session.Login__c
                        )
                        ORDER BY c2g__InvoiceDate__c DESC]);
        }
        
        //get Inv Line Items
        List<c2g__codaInvoiceLineItem__c> invLineItems = [SELECT c2g__Invoice__c, c2g__Product__r.Name, c2g__Product__r.ProductCode, Billing_Contract_Line_Item__r.Billing_Period__c
                                                              FROM c2g__codaInvoiceLineItem__c 
                                                              WHERE c2g__Invoice__c IN :invoices.keySet()];
            
        Map<Id, List<c2g__codaInvoiceLineItem__c>> invoiceToLineItems = new Map<Id, List<c2g__codaInvoiceLineItem__c>>();
        for(c2g__codaInvoiceLineItem__c invLI : invLineItems){
            if(invoiceToLineItems.containsKey(invLi.c2g__Invoice__c)){
                List<c2g__codaInvoiceLineItem__c> aux = invoiceToLineItems.get(invLi.c2g__Invoice__c);
                aux.add(invLI);
                invoiceToLineItems.put(invLi.c2g__Invoice__c, aux);
            }else{
                List<c2g__codaInvoiceLineItem__c> aux = new List<c2g__codaInvoiceLineItem__c>();
                aux.add(invLI);
                invoiceToLineItems.put(invLi.c2g__Invoice__c, aux);
            }
        }
        
        //populate return object
        List<Map<String,Object>> totalInvoices = new List<Map<String,Object>>();
        
        for(Id invId : invoiceToLineItems.keySet()){
            Map<String, Object> invoiceMap = new Map<String,Object>();
            invoiceMap.put('Id', invId);
            c2g__codaInvoice__c inv = invoices.get(invId);
            invoiceMap.put('number', inv.Invoice_Express_Number_text__c);
            invoiceMap.put('total', inv.c2g__InvoiceTotal__c);
            invoiceMap.put('createdDate', inv.c2g__InvoiceDate__c);
            invoiceMap.put('dueDate', inv.c2g__DueDate__c);
            invoiceMap.put('applicationNumber', inv.Application__r.Name);
            invoiceMap.put('status', inv.c2g__PaymentStatus__c);
            
            String description = inv.c2g__InvoiceDescription__c;
            String period = '';
            //factura proveniente de uma transferencia de contracto
            if(description != null && description.contains('New Invoice')){
            	String[] tokens = description.split('\\s+');
            	String prevInvName = tokens[tokens.size()-1];
            	period = handleNewInvoices(prevInvName);
            }else{
            	List<c2g__codaInvoiceLineItem__c> lineItems = invoiceToLineItems.get(invId);
		        Date dueDate = inv.c2g__DueDate__c;
		        for(c2g__codaInvoiceLineItem__c li : lineItems){
		        	period = getPeriodFromLineItem(period, inv, li);
		        }
            }
            invoiceMap.put('period', period);
            totalInvoices.add(invoiceMap);
        }
        
        //return ordered by dueDate, grouped by appNumber
        totalInvoices = ClientAppService_Utils.orderByDateField(totalInvoices, 'dueDate');
        totalInvoices = ClientAppService_Utils.groupByRentingApp(totalInvoices);
        toReturn.put('invoices',totalInvoices);
        return toReturn;
    }
    
    private String handleNewInvoices(String prevInvName){
    	//fetch previous Invoice
    	List<c2g__codaInvoice__c> prevInvoiceList = [SELECT Id, Invoice_Express_Number_text__c, c2g__InvoiceTotal__c, c2g__InvoiceDate__c, c2g__DueDate__c,
            c2g__PaymentStatus__c, c2g__InvoiceStatus__c, c2g__Period__r.Name, c2g__InvoiceDescription__c,
            Application__r.Name, Application__r.Payment_Timing__c, Application__r.Payment_Freq__c, Application__r.Interim_Fee_Days__c
            FROM c2g__codaInvoice__c
            WHERE Name = :prevInvName AND Invoice_Email_Status__c = 'Sent'];
        
        String period = '';
        //should only be 1
        if(prevInvoiceList.size() > 0){
        	c2g__codaInvoice__c prevInvoice = prevInvoiceList.get(0);
        	List<c2g__codaInvoiceLineItem__c> lineItems = [SELECT c2g__Invoice__c, c2g__Product__r.Name, c2g__Product__r.ProductCode, Billing_Contract_Line_Item__r.Billing_Period__c 
                                                      FROM c2g__codaInvoiceLineItem__c 
                                                      WHERE c2g__Invoice__c = :prevInvoice.Id];
            
	        for(c2g__codaInvoiceLineItem__c li : lineItems){
	        	period = getPeriodFromLineItem(period, prevInvoice, li);
	        }
        }
        return period;
    }
    
    
    private String getPeriodFromLineItem(String period, c2g__codaInvoice__c inv, c2g__codaInvoiceLineItem__c li){
    	//aluguer mensal standard/renewal OR aluguer trimestral standard/renewal
		if(li.c2g__Product__r.ProductCode.equals('PT01') || li.c2g__Product__r.ProductCode.equals('PT18')
		|| li.c2g__Product__r.ProductCode.equals('PT09') || li.c2g__Product__r.ProductCode.equals('PT19')){
			if(period.length() > 0){
				period += ' & ';
			}
			period = (li.Billing_Contract_Line_Item__r.Billing_Period__c != null) ? li.Billing_Contract_Line_Item__r.Billing_Period__c : '';
		}
		//aluguer mensal/trimestral proporcional
		if(li.c2g__Product__r.ProductCode.equals('PT08') || li.c2g__Product__r.ProductCode.equals('PT10')){
			if(period.length() > 0){
				period += ' & ';
			}
			period += inv.Application__r.Interim_Fee_Days__c +' dias';
		}
		return period;
    }
}