public class Criminal_Procedure_Trigger_Handler {

	//before insert
    public static void handleSetClientAccount(List<Criminal_Judicial_Procedure__c> newCrims){
        Map<Id,Criminal_Judicial_Procedure__c> ccToCrim = new Map<Id,Criminal_Judicial_Procedure__c>();
        for(Criminal_Judicial_Procedure__c crim : newCrims){
            ccToCrim.put(crim.Collection_Case__c, crim);
        }
        
        //get client account from collection case
        List<Collection_Case__c> ccs = [SELECT Id, Account__c FROM Collection_Case__c WHERE Id IN :ccToCrim.keySet()];
        
        //populate criminal actions' client account
        for(Collection_Case__c cc : ccs){
            ccToCrim.get(cc.Id).Account_Client__c = cc.Account__c;
        }
    } 
    
    //after insert
    public static void handleSetContractAndAutoAttachments(List<Criminal_Judicial_Procedure__c> newCrims){
        Map<Id,Criminal_Judicial_Procedure__c> accToCrim = new Map<Id,Criminal_Judicial_Procedure__c>();
        for(Criminal_Judicial_Procedure__c crim : newCrims){
            accToCrim.put(crim.Account_Client__c, crim);
        }
        
        //get applications from criminal accounts
        List<Application__c> apps = [SELECT Id, AccClient__c FROM Application__c WHERE AccClient__c IN :accToCrim.keySet()];
        
        Map<Id, Id> appToAccount = new Map<Id, Id>();
        //relate apps to their accounts
        for(Application__c app : apps){
        	appToAccount.put(app.Id, app.AccClient__c);
        }
        
        //get attachments by app
        Attachment[] contracts = [SELECT ID, Name, Body, ContentType, Description, ParentId FROM Attachment WHERE ParentId IN :apps AND NAME LIKE '%Contrato%Renting%' ORDER BY CreatedDate desc LIMIT 1];
        Attachment[] autos = [SELECT ID, Name, Body, ContentType, Description, ParentId FROM Attachment WHERE ParentId IN :apps AND NAME LIKE '%Auto%Aceitação%' ORDER BY CreatedDate desc LIMIT 1];
        
        //relate contract/auto atts to criminal action
        List<Attachment> crimContracts = new List<Attachment>();
        for(Attachment contract : contracts){
        	Id auxAccId = appToAccount.get(contract.ParentId);
        	Criminal_Judicial_Procedure__c auxCrim = accToCrim.get(auxAccId);
        	//create copy and relate to criminal action
        	Attachment auxAtt = new Attachment();
        	auxAtt.Name = contract.Name;
        	auxAtt.Body = contract.Body;
        	auxAtt.ContentType = contract.ContentType;
        	auxAtt.Description = contract.Description;
        	auxAtt.ParentId = auxCrim.Id;
        	crimContracts.add(auxAtt);
        }
        
        List<Attachment> crimAutos = new List<Attachment>();
        for(Attachment auto : autos){
        	Id auxAccId = appToAccount.get(auto.ParentId);
        	Criminal_Judicial_Procedure__c auxCrim = accToCrim.get(auxAccId);
        	//create copy and relate to criminal action
        	Attachment auxAtt = new Attachment();
        	auxAtt.Name = auto.Name;
        	auxAtt.Body = auto.Body;
        	auxAtt.ContentType = auto.ContentType;
        	auxAtt.Description = auto.Description;
        	auxAtt.ParentId = auxCrim.Id;
        	crimAutos.add(auxAtt);
        }
        
        insert crimContracts;
        insert crimAutos;
    } 
    
    //after insert
    public static void handleSetVendorInvoice(List<Criminal_Judicial_Procedure__c> newCrims){
    	Map<Id,Criminal_Judicial_Procedure__c> accToCrim = new Map<Id,Criminal_Judicial_Procedure__c>();
        for(Criminal_Judicial_Procedure__c crim : newCrims){
            accToCrim.put(crim.Account_Client__c, crim);
        }
        
        //get apps from criminal accounts
        List<Application__c> apps = [SELECT Id, AccClient__c FROM Application__c WHERE AccClient__c IN :accToCrim.keySet()];
        
        Map<Id, Id> appToAccount = new Map<Id, Id>();
        //relate apps to their accounts
        for(Application__c app : apps){
        	appToAccount.put(app.Id, app.AccClient__c);
        }
        
        //get vendor invoices from apps
        List<Vendor_Invoice__c> vendorInvoices = [SELECT Id, Application__c FROM Vendor_Invoice__c WHERE Application__c IN :appToAccount.keySet()];
        
        Map<Id,Id> invoiceToApp = new Map<Id,Id>();
        //relate vendor invoices to their apps
        for(Vendor_Invoice__c inv : vendorInvoices){
        	invoiceToApp.put(inv.Id, inv.Application__c);
        }
        
        //get invoices' attachs
        List<Attachment> invoiceAtts = [SELECT ID, Name, Body, ContentType, Description, ParentId FROM Attachment WHERE ParentId IN :invoiceToApp.keySet()];
        
        //relate invoice att to criminal action
        List<Attachment> toInsert = new List<Attachment>();
        for(Attachment invAtt : invoiceAtts){
        	Id auxAppId = invoiceToApp.get(invAtt.ParentId);
        	Id auxAccId = appToAccount.get(auxAppId);
        	Criminal_Judicial_Procedure__c auxCrim = accToCrim.get(auxAccId);
        	//create copy and relate to criminal action
        	Attachment auxAtt = new Attachment();
        	auxAtt.Name = invAtt.Name;
        	auxAtt.Body = invAtt.Body;
        	auxAtt.ContentType = invAtt.ContentType;
        	auxAtt.Description = invAtt.Description;
        	auxAtt.ParentId = auxCrim.Id;
        	toInsert.add(auxAtt);
        }
        
        insert toInsert;
    }
    
    //after insert
    public static void handleSetUnpaidInvoices(List<Criminal_Judicial_Procedure__c> newCrims){
    	Map<Id,Criminal_Judicial_Procedure__c> accToCrim = new Map<Id,Criminal_Judicial_Procedure__c>();
        for(Criminal_Judicial_Procedure__c crim : newCrims){
            accToCrim.put(crim.Account_Client__c, crim);
        }
        
        List<c2g__codaInvoice__c> invoices = [SELECT Id, c2g__Account__c, c2g__Period__c, Collection_Case__c
        FROM c2g__codaInvoice__c
        WHERE Invoice_Email_Status__c = 'Sent' AND Canceled__c = false 
        AND (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid')
        AND Collection_Case__c != null
        AND c2g__Account__c IN :accToCrim.keySet()];
        
        List<Collection_Sales_Invoice__c> toInsert = new List<Collection_Sales_Invoice__c>();
        for(c2g__codaInvoice__c inv : invoices){
        	Collection_Sales_Invoice__c auxCollInv = new Collection_Sales_Invoice__c();
        	auxCollInv.Account__c = inv.c2g__Account__c;
        	auxCollInv.Period__c = inv.c2g__Period__c;
        	auxCollInv.Collection_Case__c = inv.Collection_Case__c;
        	auxCollInv.Sales_Invoice__c = inv.Id;
        	
        	Criminal_Judicial_Procedure__c auxCrim = accToCrim.get(inv.c2g__Account__c);
        	auxCollInv.Criminal_Action__c = auxCrim.Id;
        	toInsert.add(auxCollInv);
        }
        insert toInsert;
    }
    
    //after insert
    public static void handleSetDunnings(List<Criminal_Judicial_Procedure__c> newCrims){
    	Map<Id,Criminal_Judicial_Procedure__c> ccToCrim = new Map<Id,Criminal_Judicial_Procedure__c>();
        for(Criminal_Judicial_Procedure__c crim : newCrims){
            ccToCrim.put(crim.Collection_Case__c, crim);
        }
        
        List<Dunning_Alert__c> dunnings = [SELECT Id, Collection_Case__c, Criminal_Action__c FROM Dunning_Alert__c 
        WHERE Collection_Case__c IN :ccToCrim.keySet() /*AND (Collection_Case__r.Status__c = 'Open' OR Collection_Case__r.Status__c = 'Legal')*/];
        
        for(Dunning_Alert__c dunn : dunnings){
        	Criminal_Judicial_Procedure__c auxCrim = ccToCrim.get(dunn.Collection_Case__c);
        	dunn.Criminal_Action__c = auxCrim.Id;
        }
        
        update dunnings;
    }
}