// Sales invoice to SEPA records
public class SEPA_SI_to_SR {
                                                                                         //ATENTION this receive a list but can only process a List with ONE element (at least it was only tested that way)
    public static Map<String, Payment_Collection__c > createPaymentCollectionWithSEPAFromSalesInvoice(Set<Id> salesInvoiceIdList ){
        
        system.debug('createPaymentCollectionWithSEPAFromSalesInvoice');

        //Verificar se já existe um Payment collection para a mesma account e due date se sim, adicionar Receipt_Line_Item__c ao PC
  
        Map<Id, c2g__codaInvoice__c> salesInvoiceMap = querySalesInvoices(salesInvoiceIdList);
        
        //0 check is the Sales Invoice is already in a Payment collection //used has a validation
        //Remove Sales Invoice that are already in a Payment Collection
        List<Receipt_Line_Item__c> receiptLineItemList = [SELECT Id, Invoice__c, Payment_Collection__c, Payment_Collection__r.Status__c FROM Receipt_Line_Item__c WHERE (Payment_Collection__r.Status__c ='In Payment' OR Payment_Collection__r.Status__c ='Paid') AND  Invoice__c IN :salesInvoiceMap.keySet()];
        for(Receipt_Line_Item__c receipientLineItem : receiptLineItemList){
            salesInvoiceMap.remove(receipientLineItem.Invoice__c);
        }

        system.debug('salesInvoiceMap' + salesInvoiceMap); 
//1 SEPARA EM 2 (com PC na mesma due date) e (sem PC na mesma due date)
    //Key=SI Id - Value=PC Id 
        Map<Id,Id> salesInvoiceWithPCWithSameDueDate_Map = salesSalesInvoiceWithPCAccountWithSameDueDate(salesInvoiceMap);
        
        system.debug('salesInvoiceWithPCWithSameDueDate_Map' + salesInvoiceWithPCWithSameDueDate_Map); 
 
        Map<Id,c2g__codaInvoice__c> salesInvoiceWithoutPCMap = new Map<Id,c2g__codaInvoice__c>();
        for( Id salesInvoiceId : salesInvoiceMap.keySet() ){
            if(!salesInvoiceWithPCWithSameDueDate_Map.containsKey(salesInvoiceId)){
                salesInvoiceWithoutPCMap.put(salesInvoiceId, salesInvoiceMap.get(salesInvoiceId) );    //1
            }
        }

        system.debug('salesInvoiceWithoutPCMap' + salesInvoiceWithoutPCMap);
        
  //1 com payment collection, com SEPA, ainda por pagar
        addInvoiceToPaymentCollectionWithSEPA(salesInvoiceWithPCWithSameDueDate_Map, salesInvoiceMap);

 //2 nenhum PC em aberto
        createPaymentCollectionFromSalesInvoice(salesInvoiceWithoutPCMap);
        
        return null;
    }
    
               //sales invoice Id - PC id
    private static Map<Id,Id> salesSalesInvoiceWithPCAccountWithSameDueDate(Map<Id,c2g__codaInvoice__c> salesInvoiceMap ){
        system.debug('salesInvoiceMap in salesSalesInvoiceWithPCAccountWithSameDueDate' + salesInvoiceMap);
        
        List<id> accountIdList = new List<id>();
        for(c2g__codaInvoice__c invoice : salesInvoiceMap.values()){
            accountIdList.add(invoice.c2g__Account__c);
        }
        system.debug('accountIdList' + accountIdList);
        

        List<Receipt_Line_Item__c> recLineItemList = [SELECT Id, name, Invoice__c, Payment_Collection__c, Payment_Collection__r.Account__c, Payment_Collection__r.Status__c, Payment_Collection__r.Expiry_Date__c
                                                                          FROM Receipt_Line_Item__c
                                                                          WHERE Payment_Collection__r.Account__c IN :accountIdList AND Invoice__c != null AND Payment_Collection__r.Status__c = 'In Payment' AND Payment_Collection__c IN (SELECT Payment_Collection__c FROM CR_Sepa_Record__c WHERE CR_Sepa_File__c = null)];

        //group Receipt_Line_Item by account
        Map<Id, List<Receipt_Line_Item__c>> accountId_RLI_Map = new Map<Id, List<Receipt_Line_Item__c>>();
        for(Receipt_Line_Item__c recLineItem : recLineItemList){
            List<Receipt_Line_Item__c> recLineItemsList = accountId_RLI_Map.get(recLineItem.Payment_Collection__r.Account__c);
            if(recLineItemsList == null){
                recLineItemsList = new List<Receipt_Line_Item__c>();
                accountId_RLI_Map.put(recLineItem.Payment_Collection__r.Account__c, recLineItemsList);
            }
            recLineItemsList.add(recLineItem);
        }
        system.debug('accountId_RLI_Map' + accountId_RLI_Map);
        
        //sales Invoice Id and PC (of the same account and due date) 
  //key invoiceIde - Value PC Id
        Map<Id,Id> salesInvoiceId_PC_Map = new Map<Id,Id>();
        for(c2g__codaInvoice__c invoice : salesInvoiceMap.values()){
            List<Receipt_Line_Item__c> rliList = accountId_RLI_Map.get(invoice.c2g__Account__c);
            system.debug('rliList' + rliList + '###invoice.c2g__DueDate__c' + invoice.c2g__DueDate__c); 
            if(rliList != null){
                for(Receipt_Line_Item__c recLineItem : rliList){
                    system.debug('rliList' + rliList + '###' + invoice.c2g__DueDate__c + '#####' + recLineItem.Payment_Collection__r.Expiry_Date__c); 
                    if(invoice.c2g__DueDate__c == recLineItem.Payment_Collection__r.Expiry_Date__c){
                        //se tiver mais que um é posto num há sorte, não há nada que possa fazer
                        salesInvoiceId_PC_Map.put(invoice.Id, recLineItem.Payment_Collection__c);
                    }
                }
            }
        }

        system.debug('salesInvoiceId_PC_Map' + salesInvoiceId_PC_Map);
        
        return salesInvoiceId_PC_Map;
    }
    
    private static Map<String, Payment_Collection__c > createPaymentCollectionFromSalesInvoice(Map<Id,c2g__codaInvoice__c> salesInvoiceMap ){
        
        system.debug('createPaymentCollectionFromSalesInvoice' + salesInvoiceMap);
        
        Savepoint sp = Database.setSavepoint();
        try{
            
            if(salesInvoiceMap.values() == null || salesInvoiceMap.values().size() == 0){
                system.debug('No Sales invoiced Query');
                return null;
            }
            
            // 2 group by account and due date
            //Key Account Id + due date

            Map<String, List<c2g__codaInvoice__c> > invoicePerAccountAndDateMap = new Map<String, List<c2g__codaInvoice__c> >();
            for(c2g__codaInvoice__c salesInvoice : salesInvoiceMap.values()){
                String makInvoiceKey = salesInvoice.c2g__Account__c+ '#' + salesInvoice.c2g__DueDate__c;
                List<c2g__codaInvoice__c> salesInvoiceAuxList = invoicePerAccountAndDateMap.get(makInvoiceKey);
                if(salesInvoiceAuxList == null){
                    salesInvoiceAuxList = new List<c2g__codaInvoice__c>();
                    invoicePerAccountAndDateMap.put(makInvoiceKey,salesInvoiceAuxList);
                }
                salesInvoiceAuxList.add(salesInvoice);
            } 
            
            
            //3 create Payment_Collection__c
              //Key Account Id + Due date
            Map<String, Payment_Collection__c > paymentColectionPerAccountAndDateMap = new Map<String, Payment_Collection__c >();
    
            for(String key : invoicePerAccountAndDateMap.keySet()){
                Id accountId = key.substringBefore('#'); 
                //TODO usase um salesInvoice auciliar porque a informação vai ser igual para todos os salesInvoices deste grupo
                c2g__codaInvoice__c salesInvoiceaux;
                decimal sepaRecordTotal = 0;
                for(  c2g__codaInvoice__c salesInvoice : invoicePerAccountAndDateMap.get(key)){
                    sepaRecordTotal += salesInvoice.c2g__InvoiceTotal__c;
                    salesInvoiceaux = salesInvoice;
                }
                Payment_Collection__c paymentCollection = new Payment_Collection__c(
                Account__c = accountId ,
                Expiry_Date__c = salesInvoiceaux.c2g__DueDate__c,
                Period__c = salesInvoiceaux.c2g__Period__c,
                Status__c = 'In Payment',
                Payment_Method__c = 'Direct Debit');
                
    
                paymentColectionPerAccountAndDateMap.put(key, paymentCollection);
            }
    
            insert paymentColectionPerAccountAndDateMap.values();
            
            system.debug('paymentColectionPerAccountAndDateMap: ' + paymentColectionPerAccountAndDateMap.values());
    
            //4 create SEPA record.
            Map<String, CR_Sepa_Record__c> salesInvoiceAccountDateMap = SEPA_SI_to_SR.createSEPARecords(invoicePerAccountAndDateMap, paymentColectionPerAccountAndDateMap);
    
           
            List<Receipt_Line_Item__c> receiptLineItemList = new List<Receipt_Line_Item__c>();
            for(c2g__codaInvoice__c salesInvoice : salesInvoiceMap.values()){
                //Receipt_Line_Item__c rli = createPaymentCollectionReceiptLineItems(paymentCollection.Id, salesInvoiceMap.values()[0].Application__c , salesInvoiceMap.values()[0].c2g__InvoiceTotal__c, salesInvoiceMap.values()[0].Id);
                String key = salesInvoice.c2g__Account__c + '#' + salesInvoice.c2g__DueDate__c;
                Receipt_Line_Item__c rli = new Receipt_Line_Item__c(
                    Payment_Collection__c = paymentColectionPerAccountAndDateMap.get(key).Id,
                    Amount_Claimed__c = salesInvoice.c2g__InvoiceTotal__c,
                    First_try__c = system.today(),
                    Invoice__c = salesInvoice.Id,
                    Renting_Application__c = salesInvoice.Application__c
                );
                receiptLineItemList.add(rli);
            } 
            
            system.debug('receiptLineItemList' + receiptLineItemList);
            if(receiptLineItemList != null || !receiptLineItemList.isEmpty() ){
                insert receiptLineItemList;
            }
            return paymentColectionPerAccountAndDateMap;
        } catch (Exception ex) {
            Database.rollback(sp);
            system.debug( 'ERROR:' + ex.getStackTraceString());
    
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c = system.today(), Code__c = 'CRITICAL',ApplicationID__c = 'SEPA',message__c = 'PaymentCollection_Utils.createPaymentCollectionWithSEPA' , printStackTrace__c = ex.getStackTraceString() );
            system.debug('CRITICAL: '+ record);
            return null;
        }

        return null;
    }

                 //key Account ID + date
    public static Map<String, CR_Sepa_Record__c> createSEPARecords(Map<String, List<c2g__codaInvoice__c> > invoicePerAccountAndDateMap, Map<String, Payment_Collection__c > paymentColectionPerAccountAndDateMap){
        System.debug(loggingLevel.INFO, '[SEPA_SI_to_SR] execute started.');
        
        List<CR_Sepa_Record__c> sepaRecordLis = new List<CR_Sepa_Record__c>();
        //key Sales invoice Id
        Map<Id, CR_Sepa_Record__c> sepaRecsMap = new Map<Id, CR_Sepa_Record__c>();
        //key Sales invoice Id
        Map<Id, c2g__codaInvoice__c> salesInvoiceMap = new Map<Id, c2g__codaInvoice__c>();
        //key Account ID +date      
        Map<String, CR_Sepa_Record__c> sepaAccountDateMap = new Map<String, CR_Sepa_Record__c>();
        
        Map<String, String> currencyISOFromIdMap  = SEPA_UTILS.getCurrencyISOFromIdMap();
                   
        CR_Sepa_Admin__c sepaAdmin = SEPA_UTILS.getSepaAdmin(invoicePerAccountAndDateMap.values().get(0).get(0));
   
   //1 for each account
        for(String key : invoicePerAccountAndDateMap.keySet() ){
            Id accountId = key.substringBefore('#'); 
            c2g__codaInvoice__c salesInvoiceaux;
            decimal sepaRecordTotal = 0;
   //2 sum sales invoices
            for(  c2g__codaInvoice__c salesInvoice : invoicePerAccountAndDateMap.get(key)){
                sepaRecordTotal += salesInvoice.c2g__InvoiceTotal__c;
                salesInvoiceaux = salesInvoice;
            }

            date activationDate = SEPA_UTILS.processActivationDate(sepaAdmin, salesInvoiceaux.c2g__DueDate__c);
            
            String accountName = salesInvoiceaux.c2g__Account__r.Name;
            accountName = accountName.left(math.min(accountName.length(), 70));

            CR_Sepa_Record__c sepaRec = new CR_Sepa_Record__c(
                       Document_Due_Date__c = salesInvoiceaux.c2g__DueDate__c,
                       Document_Type__c = SepaAdmin.SEPA_Movement_Type__c,
                       Activation_Date__c = activationDate,
                       Debtor_Account__c = accountId,
                       Debtor_Name__c = accountName,
                       IBAN__c = salesInvoiceaux.c2g__Account__r.c2g__CODABankIBANNumber__c,
                       // Invoice_Number__c = salesInvoiceaux.Invoice_Express_Number_text__c,    // TODO no futuro por o proprio SEPA Record Name
                       Mandate_Date__c = salesInvoiceaux.Application__r.Delivery_Certificate_Signed__c,     // TODO no futuro por o primeiro Application__r.Delivery_Certificate_Signed__c
                       Mandate_Identification__c = salesInvoiceaux.c2g__Account__r.NIF__c,
                       Request_Count__c = 1,
                       Request_Amount__c = sepaRecordTotal,
                       Request_Currency__c = currencyISOFromIdMap.get(salesInvoiceaux.c2g__InvoiceCurrency__c),
                       Payment_Date__c = SEPA_UTILS.processExecutionDate(sepaAdmin, activationDate),
                       Swift_Bic__c = salesInvoiceaux.c2g__Account__r.c2g__CODABankSWIFTNumber__c,
                       Sales_Invoice__c = salesInvoiceaux.id,
                       Payment_Collection__c = paymentColectionPerAccountAndDateMap.get(key).Id
            ); 
        
            system.debug('sepaRec' + sepaRec); 
    
            if(salesInvoiceaux.c2g__Account__r.RecordType.Name != 'Account Customer - Channel'){
                sepaRec.Invalid_Record__c = true;
                        
                sepaRec.Notes__c = 'The Account record Type is diferent of "Account Customer - Channel" ';
                //Notify the error
                        
                Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c = system.today(), Code__c = 'CRITICAL',ApplicationID__c = 'SEPA',message__c = sepaRec.Notes__c , printStackTrace__c = 'Not applicable.');
                system.debug('CRITICAL: '+ record);
                insert record;
                        
            }
                        
            sepaRecsMap.put(salesInvoiceaux.Id, sepaRec);  //TODO to be removed later
            salesInvoiceMap.put(salesInvoiceaux.Id, salesInvoiceaux);   //TODO to be removed later
            
                
            sepaAccountDateMap.put(key, sepaRec);   //Vou usar este no futuro
                
        }

        if(sepaAccountDateMap.values().size() > 0){
            Savepoint sp = Database.setSavepoint();
            try {
                system.debug('Insert dos SEPA Records');
                insert sepaAccountDateMap.values();
                
//TODO review/delete this code
                List<c2g__codaInvoice__c> sis = new List<c2g__codaInvoice__c>();
                for (Id salesInvoiceId : sepaRecsMap.keySet()) {
                    salesInvoiceMap.get(salesInvoiceId).CR_Sepa_Record__c = sepaRecsMap.get(salesInvoiceId).Id;  //TODO ?to be removed after Payment Collection is implemented?
                    sis.add(salesInvoiceMap.get(salesInvoiceId));  //TODO to be removed later
                }

                update sis;
                
                List<Id> sepaRecordsIdList = new List<Id>();
                for(CR_Sepa_Record__c sepa : sepaAccountDateMap.values()){
                    sepaRecordsIdList.add(sepa.Id);
                }
                
                Map<Id, CR_Sepa_Record__c> sepaRecordsList = new Map<Id, CR_Sepa_Record__c>([SELECT Id, Name FROM CR_Sepa_Record__c WHERE Id IN :sepaRecordsIdList]);
                for(CR_Sepa_Record__c sepa : sepaAccountDateMap.values()){
                    sepa.Invoice_Number__c = sepaRecordsList.get(sepa.Id).Name;
                }
                update sepaAccountDateMap.values();
                        
                } catch (Exception ex) {
                    system.debug('ex.getStackTraceString:' + ex.getStackTraceString() );
                    
                    Database.rollback(sp);
                    Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c = system.today(), Code__c = 'CRITICAL',ApplicationID__c = 'SEPA',message__c = ex.getStackTraceString() , printStackTrace__c = ex.getStackTraceString() );
                    system.debug('CRITICAL: '+ record);
                    insert record;
                }

        }
  
        system.debug('[SEPA_SI_to_SR] new SalesInvoices for Sepa Records: ' + sepaAccountDateMap);
        
        return sepaAccountDateMap;
    }
  

    private static Map<Id, c2g__codaInvoice__c> querySalesInvoices(Set<Id> turnedToCompletedIDs){
        Map<Id, c2g__codaInvoice__c> salesInvoiceMap;

        system.debug(loggingLevel.INFO, '[PaymentCollection_Utils] turnedToCompletedIDs.size(): ' + turnedToCompletedIDs.size());
        system.debug( 'turnedToCompletedIDs: ' + turnedToCompletedIDs);

        salesInvoiceMap = new Map<Id, c2g__codaInvoice__c>([SELECT Id
                       , Name
                       , Application__r.Delivery_Certificate_Signed__c
                       , c2g__Account__c
                       , c2g__Account__r.Id
                       , c2g__Account__r.Name
                       , c2g__Account__r.Type 
                       , c2g__Account__r.NIF__c
                       , c2g__Account__r.c2g__CODABankIBANNumber__c
                       , c2g__Account__r.c2g__CODABankSWIFTNumber__c
                       , c2g__Account__r.RecordType.Name
                       , c2g__DueDate__c
                       , c2g__InvoiceStatus__c
                       , c2g__InvoiceCurrency__c
                       , c2g__OutstandingValue__c
                       , c2g__InvoiceTotal__c //c2g__OutstandingValue__c comes 0 from trigger on complete event
                       , Invoice_Express_Number_text__c
                       , Payment_Method__c
                       , c2g__Period__c
                       FROM c2g__codaInvoice__c
                       WHERE
                       Id IN :turnedToCompletedIDs
                       AND Payment_Method__c  = 'Direct Debit'// Payment_Method__c = 'Direct Debit' 
                       AND c2g__Account__r.SEPA_Inactive__c = false
                      ]);
                      
        System.debug(loggingLevel.INFO, '[SEPA_SI_to_SR]salesInvoiceMap' + salesInvoiceMap);

        return salesInvoiceMap;
    }
                                                        //Key=SI Id - Value=PC Id 
    private static void addInvoiceToPaymentCollectionWithSEPA(Map<Id,Id> salesInvoiceWithPCWithSameDueDate_Map, Map<Id, c2g__codaInvoice__c> salesInvoiceMap){
        
        List<Receipt_Line_Item__c> receiptLineItemList = new List<Receipt_Line_Item__c>();
        for(Id salesInvoiceId : salesInvoiceWithPCWithSameDueDate_Map.keySet()){
            Receipt_Line_Item__c rli = new Receipt_Line_Item__c(
                    Payment_Collection__c = salesInvoiceWithPCWithSameDueDate_Map.get(salesInvoiceId),
                    Amount_Claimed__c = salesInvoiceMap.get(salesInvoiceId).c2g__InvoiceTotal__c,
                    First_try__c = system.today(),
                    Invoice__c = salesInvoiceId
                );
            receiptLineItemList.add(rli);
        }
        
        
        system.debug(Logginglevel.ERROR, 'receiptLineItemList' + receiptLineItemList);
        system.debug('receiptLineItemList' + receiptLineItemList);
        if(receiptLineItemList != null || !receiptLineItemList.isEmpty() ){
            insert receiptLineItemList;
        }
    }

}