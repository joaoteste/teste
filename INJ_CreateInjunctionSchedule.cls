global class INJ_CreateInjunctionSchedule implements Schedulable {

    global void execute(SchedulableContext ctx) {
    	//X days after the 4th dunning alert, create an injunction
    	
    	Dunning_Admin__c admin = [SELECT Nr_of_Days_to_Pay__c FROM Dunning_Admin__c WHERE Dunning_Level__c = '4th Reminder'];
    	
    	Integer days = Integer.valueOf(admin.Nr_of_Days_to_Pay__c*-1);//multiply by -1 to remove days
    	
    	Date minusDays = Date.today().addDays(days);
        
        //get all dunnings that have passed the time threshold
        List<Dunning_Alert__c> dunnings = [SELECT Collection_Case__c, Status__c, Amount_Claimed__c, Interest_Rate__c FROM Dunning_Alert__c 
        WHERE Dunning_Level__c = '4th Reminder' AND Status__c = 'Open' AND Sent_Date__c < :minusDays AND Collection_Case__r.Status__c = 'Open'];
        
        //get all ccs from dunnings
        Map<Id, Dunning_Alert__c> ccToDunning = new Map<Id, Dunning_Alert__c>();
        for(Dunning_Alert__c dunn : dunnings){
        	ccToDunning.put(dunn.Collection_Case__c, dunn);
        }
        
        //get all invoices from ccs
        List<c2g__codaInvoice__c> invoices = [SELECT Id, Collection_Case__c 
        FROM c2g__codaInvoice__c 
        WHERE Collection_Case__c IN :ccToDunning.keySet()
        AND Invoice_Email_Status__c = 'Sent'
        AND Canceled__c = false];
        
        Map<Id, List<c2g__codaInvoice__c>> ccToInvoices = new Map<Id, List<c2g__codaInvoice__c>>();
        for(c2g__codaInvoice__c inv : invoices){
        	List<c2g__codaInvoice__c> aux;
        	if(ccToInvoices.containsKey(inv.Collection_Case__c)){
        		aux = ccToInvoices.get(inv.Collection_Case__c);
        	}
        	else{
        		aux = new List<c2g__codaInvoice__c>();
        	}
        	aux.add(inv);
        	ccToInvoices.put(inv.Collection_Case__c, aux);
        }
        
        //get Inv Line Items from invs
        List<c2g__codaInvoiceLineItem__c> invLineItems = [SELECT c2g__Invoice__c, c2g__Product__r.Name, c2g__Product__r.ProductCode, Billing_Contract_Line_Item__r.Billing_Period__c
                                                              FROM c2g__codaInvoiceLineItem__c 
                                                              WHERE c2g__Invoice__c IN :invoices];
            
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
        
        List<Injunction_Procedure__c> toInsertInj = new List<Injunction_Procedure__c>();
        List<Dunning_Alert__c> toInsertDunn = new List<Dunning_Alert__c>();
        List<Dunning_Alert__c> toUpdateDunn = new List<Dunning_Alert__c>();
        //for each cc, get all invoices that have a renting product code
        //if they are more than 1, create Injunction
        //otherwise create new level 1 dunning alert
        for(Id cc : ccToDunning.keySet()){
        	if(ccToInvoices.containsKey(cc)){
        		List<c2g__codaInvoice__c> ccInvoices = ccToInvoices.get(cc);
        		List<c2g__codaInvoice__c> rentingInvoices = new List<c2g__codaInvoice__c>();
        		for(c2g__codaInvoice__c inv : ccInvoices){
        			List<c2g__codaInvoiceLineItem__c> lineItems = invoiceToLineItems.get(inv.Id);
        			for(c2g__codaInvoiceLineItem__c li : lineItems){
        				if(li.c2g__Product__r.ProductCode == 'PT01' || li.c2g__Product__r.ProductCode == 'PT09'){
        					rentingInvoices.add(inv);
        				}
        			}
        		}
        		//has more than 1 renting invoices
    			//create injunction
    			if(rentingInvoices.size() > 1){
    				Injunction_Procedure__c injProc = new Injunction_Procedure__c();
    				injProc.Collection_Case__c = cc;
    				toInsertInj.add(injProc);
    			}
    			//has 1 or less renting invoices
				//close existing (level 4) dunning and create new (level 1) dunning alert
				else{
					Dunning_Alert__c aux = ccToDunning.get(cc);
					aux.Status__c = 'Close';
					toUpdateDunn.add(aux);
					
					Dunning_Alert__c created = new Dunning_Alert__c();
					created.Collection_Case__c = cc;
					created.Status__c = 'Open';
					created.Dunning_Level__c = '1st Reminder';
					toInsertDunn.add(created);
				}
    		}
    		//cc has 0 invoices......
    		//close existing (level 4) dunning and create new (level 1) dunning alert
    		else{
    			Dunning_Alert__c aux = ccToDunning.get(cc);
				aux.Status__c = 'Close';
				toUpdateDunn.add(aux);
				
				Dunning_Alert__c created = new Dunning_Alert__c();
				created.Collection_Case__c = cc;
				created.Status__c = 'Open';
				created.Dunning_Level__c = '1st Reminder';
				toInsertDunn.add(created);
    		}
    	}
        
        insert toInsertInj;
        insert toInsertDunn;
        update toUpdateDunn;
    }
}