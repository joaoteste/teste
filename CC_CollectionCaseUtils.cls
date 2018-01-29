public class CC_CollectionCaseUtils {
    
    public static String processAccount(Account acc, List<c2g__codaInvoice__c> salesInvoiceList){
        
        //results
        Map<ID, List<c2g__codaInvoice__c>> ccToCreateMap = new Map<ID, List<c2g__codaInvoice__c>>();
        List<c2g__codaInvoice__c> siToCCList = new List<c2g__codaInvoice__c>();
        ccToCreateMap.put(acc.ID, siToCCList);
        Map<Collection_Case__c, List<c2g__codaInvoice__c>> salesInvoiceToAddMap = new Map<Collection_Case__c, List<c2g__codaInvoice__c>>();
        List<c2g__codaInvoice__c> siList = new List<c2g__codaInvoice__c>(); 
        
        //get All Payment Collections
        Map<ID, List<Receipt_Line_Item__c>> siInPCMap = CC_CollectionCaseUtils.rcWithoutPPMap(salesInvoiceList);
        Map<ID, List<Receipt_Line_Item__c>> siInPPMap = CC_CollectionCaseUtils.rcWithPPMap(salesInvoiceList);
        Map<ID, Collection_Case__c> ccMap = new Map<ID, Collection_Case__c>([SELECT ID, Status__c, Account__c, Count_Dunning_Alert__c FROM Collection_Case__C WHERE Account__c = :acc.ID]);
        List<Payment_Plan__c> ppList = new List<Payment_Plan__c>([SELECT ID, Hit_Date__c, Status__c, Collection_Case__c FROM Payment_Plan__c WHERE Collection_Case__r.Account__c = :acc.ID AND Status__c = 'Open']);
        
        
        
        for(c2g__codaInvoice__c si : salesInvoiceList){
            if(!siInPCMap.containsKey(si.ID) && !siInPPMap.containsKey(si.ID)){
                Collection_Case__c ccOpen = getCollectionCaseOpen(ccMap);
                System.debug('No Payment Collection Detected for Invoice. '+'Invoice:' +si.ID + ' Account:' + account.ID);
                if(ccOpen != null){
                    System.debug('Account Have a Open Collection Case.'+'Invoice:' +si.ID + ' Account:' + account.ID);
                    //account has open collection case 
                    if(si.Collection_Case__c != ccOpen.ID){
                        System.debug('Invoice on Open Collection Case? '+'Invoice:'+ si.ID + ' Account:' + account.ID);
                        if(si.Collection_Case__c == null){
                            System.debug('Add Invoice to open Collection Case. '+'Invoice:'+ si.ID + ' Account:' + account.ID);
                            //addInvoiceToCollectionCase
                            siList.add(si);
                            salesInvoiceToAddMap.put(ccOpen, siList);
                            
                        }else{
                            System.debug('Invoice doesnt have Collection Case. '+'Invoice:'+ si.ID + ' Account:' + account.ID);
                            if(ccMap.get(si.Collection_Case__c).Status__c == 'Closed'){
                                System.debug('Invoice Collection Case is Closed. '+'Invoice:'+ si.ID + ' Account:' + account.ID);
                                if(!collectionCaseToOpenPaymentPlan(si.Collection_Case__c, ppList)){
                                    System.debug('Add Invoice to open Collection Case. '+'Invoice:' +si.ID + ' Account:' + account.ID);
                                    //sales invoice to add to c
                                    siList.add(si);
                                    salesInvoiceToAddMap.put(ccOpen, siList);                                   
                                }else{
                                    System.debug('Waiting for payment. '+'Invoice:' +si.ID + ' Account:' + account.ID); 
                                }
                            }else if(ccMap.get(si.Collection_Case__c).Status__c == 'Legal'){
                                System.debug('Collection Case in Legal Status. '+'Invoice:' +si.ID + ' Account:' + account.ID);
                                //Wait for payment
                            }                           
                        }
                        
                    }else{
                        //waiting for payment
                        System.debug('Invoice already on an Open Collection Case. '+'Invoice:'+ si.ID + ' Account:' + account.ID);
                    }
                }else{
                    //account doesnt have open collection case 
                    System.debug('Account doesnt have open collection case. '+'Invoice:' +si.ID + ' Account:' + account.ID);
                    if(si.Collection_Case__c != null){
                        System.debug('Invoice has Collection Case. '+'Invoice:' +si.ID + ' Account:' + account.ID);
                        //create new collection case
                        if(ccMap.get(si.Collection_Case__c).Status__c == 'Closed'){
                            System.debug('Collection Case is closed. '+'Invoice:'+ si.ID + ' Account:' + account.ID);
                            if(!collectionCaseToOpenPaymentPlan(si.Collection_Case__c, ppList)){
                                System.debug('Create new Collection Case. '+'Invoice:'+ si.ID + ' Account:' + account.ID);
                                //sales invoice to add to c
                                ccToCreateMap.get(acc.ID).add(si);                                 
                            }
                        }else if(ccMap.get(si.Collection_Case__c).Status__c == 'Legal'){
                            System.debug('Collection Case in Legal Status. '+'Invoice:' +si.ID + ' Account:' + account.ID);
                            //Wait for payment
                        }                                               
                        
                    }else{
                        System.debug('Invoice doesnt have a collection case. '+'Invoice:' +si.ID + ' Account:' + account.ID);
                        if(ppList.isEmpty() || firstSchedulePaid(ppList) ){
                            System.debug('Create new Collection Case. '+'Invoice:'+ si.ID + ' Account:' + account.ID);
                            ccToCreateMap.get(acc.ID).add(si); 
                        }else{
                            System.debug('Waiting to know if the client pays the first payment schedule. '+'Invoice:' +si.ID + ' Account:' + account.ID);
                            //wait 
                        }
                    }
                }
            }else{
                System.debug('Detected open payment collection for account. '+'Invoice:' +si.ID + ' Account:' + account.ID);
            } 
        }
        
        if(!ccToCreateMap.get(acc.ID).isEmpty() || !salesInvoiceToAddMap.isEmpty()){
            System.debug('Sent to process. '+ ' Account:' + account.ID);
            processCollectionCase(acc, ccToCreateMap, salesInvoiceToAddMap);
        }
        
        system.debug(ccToCreateMap);
        system.debug(salesInvoiceToAddMap);        
        
        return 'OK';
    }
    
    public static Boolean firstSchedulePaid(List<Payment_Plan__c> ppList){
        for(Payment_Plan__c pp : ppList){
            if(pp.Hit_Date__c < System.TODAY())
                return true;
        }
        return false;
    }
    
    public static Boolean collectionCaseToOpenPaymentPlan(ID ccID, List<Payment_Plan__c> ppList){
        if(ppList.isEmpty())
            return false;
        else{
            for(Payment_Plan__c pp : ppList){
                if(pp.Collection_Case__c == ccID)
                    return true;
            }
            return false;
        }
    }
    
    //check in a map if there's any CC with status open
    public static Collection_Case__c getCollectionCaseOpen(Map<ID, Collection_Case__c> ccMap){
        for(ID cc : ccMap.keySet()){
            if(ccMap.get(cc).Status__c == 'Open')
                return ccMap.get(cc);
        }
        return null;
    }
    
    //get all Receipt Line Items IN PAYMENT
    public static Map<ID, List<Receipt_Line_Item__c>> rcWithoutPPMap(List<c2g__codaInvoice__c> salesInvoicesList){
        
        Map<ID, List<Receipt_Line_Item__c>> siToRLIMap = new Map<ID, List<Receipt_Line_Item__c>>();
        
        // Receipt with sales invoices
        List<Receipt_Line_Item__c> rcList = new List<Receipt_Line_Item__c>([SELECT ID, Invoice__c, Payment_Collection__r.Account__c FROM Receipt_Line_Item__c WHERE Invoice__c in :salesInvoicesList AND Payment_Collection__r.Status__c = 'In Payment']);
        
        for(Receipt_Line_Item__c rli : rcList){
            if(siToRLIMap.containsKey(rli.Invoice__c)){
                siToRLIMap.get(rli.Invoice__c).add(rli);
            }else{
                List<Receipt_Line_Item__c> rliList = new List<Receipt_Line_Item__c>();
                siToRLIMap.put(rli.Invoice__c, rliList);
            }
        }
        
        return siToRLIMap;     
        
    }
    
    //Receipt Line Items with Partial Invoice Payments
    public static Map<ID, List<Receipt_Line_Item__c>> rcWithPPMap(List<c2g__codaInvoice__c> salesInvoicesList){
        Map<ID, List<Receipt_Line_Item__c>> siToRLIMap = new Map<ID, List<Receipt_Line_Item__c>>();
        
        // Partial Invoices Payments with Sales Invoices  
        List<Receipt_Line_Item__c> rcList = new List<Receipt_Line_Item__c>([SELECT ID, Partial_Invoice_Payment__r.Sales_Invoice__c FROM Receipt_Line_Item__c WHERE Partial_Invoice_Payment__c in (SELECT ID FROM Partial_Invoice_Payment__c WHERE Sales_Invoice__c in :salesInvoicesList) AND Payment_Collection__r.Status__c = 'In Payment']);
        
        for(Receipt_Line_Item__c rli : rcList){
            if(siToRLIMap.containsKey(rli.Partial_Invoice_Payment__r.Sales_Invoice__c)){
                siToRLIMap.get(rli.Partial_Invoice_Payment__r.Sales_Invoice__c).add(rli);
            }else{
                List<Receipt_Line_Item__c> rliList = new List<Receipt_Line_Item__c>();
                siToRLIMap.put(rli.Partial_Invoice_Payment__r.Sales_Invoice__c, rliList);
            }
        }
        
        return siToRLIMap;
    }
    
    
    public static void processCollectionCase(Account conta, Map<ID, List<c2g__codaInvoice__c>> ccToCreateMap, Map<Collection_Case__c, List<c2g__codaInvoice__c>> salesInvoiceToAddMap){
        //TODO    
        if(!ccToCreateMap.get(conta.ID).isEmpty()){
            System.debug('Create new Collection Case for account.'+ conta.ID);
            //ccToCreateMap = new Map<Account, List<c2g__codaInvoice__c>>();
            List<Collection_Case__c> l_ccToInsert = new List<Collection_Case__c>();
            List<String> l_updateCC = new List<String>();
            //criar CC
            List<Account> lista_Acc = [select id from account where id in:ccToCreateMap.keyset()];
            System.debug(lista_Acc);
            System.debug(ccToCreateMap);
            
            for(Account c:lista_Acc ){
                Collection_Case__c newCC = new Collection_Case__c();
                newCC.Account__c = c.Id;
                l_ccToInsert.add(newCC);
                
                
            }
            if(l_ccToInsert.size()>0){
                Database.SaveResult[] insresultsNewCC = Database.insert(l_ccToInsert, false);
                System.debug('Collection Case Created!.'+ l_ccToInsert[0].ID);
                
                List<Id> ccsInserted = new List<Id>();
                List<c2g__codaInvoice__c> l_siNewCCtoUpd = new List<c2g__codaInvoice__c>();
                for(Database.SaveResult insresult : insresultsNewCC){
                    ccsInserted.add(insresult.Id); 
                    l_updateCC.add(insresult.Id);
                }
                
                List<String> appID = new List<String>();
                for (ID cc : ccToCreateMap.keySet() ){
                    List<c2g__codaInvoice__c> l_cc= ccToCreateMap.get(cc);
                    for(c2g__codaInvoice__c si:l_cc){
                        appID.add(si.Application__c);            
                    }
                }
                
                List<Application__c> upd_Application = new List<Application__c>();
                List<Application__c> l_App = [Select id, Status__c from Application__c where id IN : appID ];
                
                List<Billing_Contract__c> upd_BillContract = new List<Billing_Contract__c>();
                List<Billing_Contract__c> billexists = [Select id, Application__r.Equipment_Cost__c  from Billing_Contract__c where Application__c IN : appID ];
                
                //update das invoices dos case collections inseridos
                List<Collection_Case__c> l_newCcs = [select id,Account__c, Account__r.id from Collection_Case__c where id IN : ccsInserted];
                List<c2g__codaInvoice__c> l_siUpdNewCC = new List<c2g__codaInvoice__c>();
                
                for(Collection_Case__c newCc : l_newCcs){
                    Account acc = new account(id =newCc.Account__c);
                    List<c2g__codaInvoice__c> l_siAccToUpd = ccToCreateMap.get(acc.ID);
                    for(c2g__codaInvoice__c si:l_siAccToUpd){
                        c2g__codaInvoice__c siNew = new c2g__codaInvoice__c();
                        siNew.Id = si.Id;
                        siNew.Collection_Case__c = newCc.Id;
                        l_siUpdNewCC.add(siNew);
                        appID.add(si.Application__c);
                    }
                    
                    for(Application__c app:l_App){
                        Application__c ca = new Application__c();
                        ca.id = app.Id;
                        ca.Status__c = 'Contract - Arrears';
                        upd_Application.add(ca);                
                    }                    
                    
                    for(Billing_Contract__c bc: billexists){
                        Billing_Contract__c billContract = new Billing_Contract__c();                    
                        billContract.id = bc.id; 
                        billContract.Collection_Case__c = newCc.id;
                        billContract.Equipment_Cost__c = bc.Application__r.Equipment_Cost__c;
                        upd_BillContract.add(billContract); 
                    }                     
                }
                
                if(l_siUpdNewCC.size()>0){
                    update l_siUpdNewCC;
                }      
                
                if(!upd_Application.isEmpty()){
                    update upd_Application;  
                } 
                
                if(!upd_BillContract.isEmpty()){
                    update upd_BillContract; 
                } 
                
                updateCC(l_updateCC);
            }
        }else{  
            
            List<String> appID = new List<String>();
            for (Collection_Case__c cc : salesInvoiceToAddMap.keySet() ){
                List<c2g__codaInvoice__c> l_siCc= salesInvoiceToAddMap.get(cc);
                for(c2g__codaInvoice__c si:l_siCc){
                    appID.add(si.Application__c);            
                }
                
            }
            List<Application__c> upd_Application = new List<Application__c>();
            List<Application__c> l_App = [Select id, Status__c from Application__c where id IN : appID ];
            
            List<Billing_Contract__c> upd_BillContract = new List<Billing_Contract__c>();
            List<Billing_Contract__c> billexists = [Select id, Application__r.Equipment_Cost__c  from Billing_Contract__c where Application__c IN : appID ];
            
            List<c2g__codaInvoice__c> l_siUpdExistingCC = new List<c2g__codaInvoice__c>();
            List<String> l_updateCC = new List<String>();
            Map<id,Account> map_accId_acc = new Map<id,Account>();
            for (Collection_Case__c cc : salesInvoiceToAddMap.keySet() ){
                List<c2g__codaInvoice__c> l_siCc= salesInvoiceToAddMap.get(cc);
                l_updateCC.add(cc.id);
                for(c2g__codaInvoice__c si:l_siCc){
                    c2g__codaInvoice__c siNew = new c2g__codaInvoice__c();
                    siNew.Id = si.Id;
                    siNew.Collection_Case__c = cc.Id;
                    l_siUpdExistingCC.add(siNew); 
                }
                Account accCc = new Account();
                accCc.id = cc.Account__c;
                if(!map_accId_acc.containsKey(accCc.Id)){
                    map_accId_acc.put(accCc.id, accCc);
                }
                
                for(Application__c app:l_App){
                    Application__c ca = new Application__c();
                    ca.id = app.Id;
                    ca.Status__c = 'Contract - Arrears';
                    upd_Application.add(ca);    
                } 
                
                for(Billing_Contract__c bc: billexists){
                    Billing_Contract__c billContract = new Billing_Contract__c();
                    billContract.id = bc.id; 
                    billContract.Collection_Case__c = cc.id;
                    billContract.Equipment_Cost__c = bc.Application__r.Equipment_Cost__c;
                    upd_BillContract.add(billContract); 
                } 
            }
            if(l_siUpdExistingCC.size()>0){
                update l_siUpdExistingCC;
            }        
            if(!upd_Application.isEmpty()){
                update upd_Application;  
            } 
            if(!upd_BillContract.isEmpty()){
                update upd_BillContract; 
            } 
            
            updateCC(l_updateCC);            
            //Reminder Update
            
            List<String> sid_DunningAlert = new List<String>();
            List<Dunning_Alert__c> m_DunningAlert = new List<Dunning_Alert__c>();
            Map<String, String> map_CC_DunningAlert = new Map<String, String>();
            
            List<Collection_Case__c> m_cc = [select id, Amount_Claimed__c, Count_Dunning_Alert__c, (Select id From Dunning_Alerts__r where Status__c = 'Open') from Collection_Case__c where Account__c IN: map_accId_acc.keySet()  and Status__c = 'Open'];
            
            for(Collection_Case__c c: m_cc){
                if(!c.Dunning_Alerts__r.isEmpty()){ 
                    Dunning_Alert__c da = new Dunning_Alert__c();
                    da.id =c.Dunning_Alerts__r[0].id;
                    da.Amount_Claimed__c = c.Amount_Claimed__c;                    
                    da.Updated__c =true;
                    da.Updated_Date__c = system.today();
                    da.Updated_Text__c ='Atenção! Este aviso foi actualizado pois existem novas facturas em atraso.';
                    
                    sid_DunningAlert.add(da.id);            
                    m_DunningAlert.add(da); 
                    map_CC_DunningAlert.put(c.Id, c.Dunning_Alerts__r[0].id);
                }               
            }
            if(!m_DunningAlert.isEmpty()){
                update m_DunningAlert;
            }
            
            List<Interest_Charged_Calculation__c> insICC = new List<Interest_Charged_Calculation__c>(); 
            List<Legal_Fees__c> legalFee = [SELECT Id, Interest_Rate__c, Judicial_Fees__c, Name FROM Legal_Fees__c where Name = 'Interest Rate' limit 1];
            Decimal ir_fee = 0;
            for(Legal_Fees__c lf : legalFee){
                ir_fee=lf.Interest_Rate__c/100;
            }
            //***
            if(!salesInvoiceToAddMap.isEmpty()){ 
                for(Collection_Case__c cc: salesInvoiceToAddMap.keySet()){
                    if(cc.Count_Dunning_Alert__c == 3 || cc.Count_Dunning_Alert__c == 4){
                        //Se 3rd ou 4th Interest_Charged_Calculation__c
                        
                        for(c2g__codaInvoice__c ci: salesInvoiceToAddMap.get(cc)){
                            Interest_Charged_Calculation__c icc = new Interest_Charged_Calculation__c();
                            
                            icc.Days_Overdue__c = ci.Days_Overdue__c;
                            icc.Invoice_Due_Date__c=ci.c2g__DueDate__c;                        
                            String sId_Dunning = map_CC_DunningAlert.get(cc.id);
                            icc.Dunning_Alert__c=sId_Dunning;
                            icc.Interest_Rate__c=ir_fee*100;
                            icc.Invoice_Value__c=ir_fee*ci.c2g__InvoiceTotal__c;               
                            icc.Sales_Invoice__c=ci.Id;                
                            if(ci.Days_Overdue__c > 0){
                                icc.Interest_Charged__c = (icc.Invoice_Value__c/365)*ci.Days_Overdue__c;                    
                            }else{
                                icc.Interest_Charged__c = 0; 
                            }
                            icc.Sales_Invoice_Total__c = ci.c2g__InvoiceTotal__c;
                            
                            insICC.add(icc);
                        } 
                    }
                }
            }  
            if(!insICC.isEmpty()) 
                insert insICC;
            //***
        }
        
    }
    public static void updateCC(List<String> m_ids){
        List<String> products = new List<String>{'PT01','PT08','PT09','PT10','PT18','PT19'};

        List<Account> accountCCSet = [SELECT ID 
                                      FROM Account
                                      WHERE ID in (SELECT Account__c
                                                    FROM Collection_Case__c 
                                                    WHERE ID in :m_ids)];
        
        Map<Id,AggregateResult> invoiceItemMap = new Map<Id,AggregateResult>([Select c2g__Invoice__r.c2g__Account__c Id,count(c2g__Invoice__c) cnt,sum(c2g__NetValue__c) sumNetValue
                                                                              From c2g__codaInvoiceLineItem__c 
                                                                              where c2g__Invoice__r.Canceled__c = false and c2g__Invoice__r.c2g__Account__c in :accountCCSet
                                                                              and c2g__Invoice__r.c2g__PaymentStatus__c = 'Unpaid'
                                                                              and c2g__Invoice__r.c2g__DueDate__c < :Date.today()
                                                                              and c2g__Product__r.ProductCode in :products
                                                                              and c2g__Invoice__r.c2g__InvoiceStatus__c = 'Complete'
                                                                              group by c2g__Invoice__r.c2g__Account__c]);
        
        
        List<Collection_Case__c> l_ccToUpdate = new List<Collection_Case__c>();
        for(Collection_Case__c cc: [SELECT Id, Status__c,Number_Contracts__c,Contracts_Amount__c,Advanced_Expired_Payments_Amount__c,Account__c,
                                    Advanced_Expired_Payments_Term__c, (SELECT Id, Equipment_Cost__c, Payment_Amount__c,Terms_To_End_Of_Contract__c 
                                                                        FROM Billing_Contracts__r)
                                    FROM Collection_Case__c 
                                    WHERE id = : m_ids]){
            Decimal valor = 0;
            Decimal m_countContract = 0;
            
            Decimal m_Value = 0;
            Decimal m_ValueTerm = 0;            
            if(!cc.Billing_Contracts__r.isEmpty()){                     
                
                for(Billing_Contract__c bc : cc.Billing_Contracts__r){      
                    if(bc.Equipment_Cost__c != null)  
                        valor += bc.Equipment_Cost__c;   
                    
                    m_countContract = m_countContract + 1;
                    if( bc.Terms_To_End_Of_Contract__c > m_ValueTerm){
                        m_ValueTerm = bc.Terms_To_End_Of_Contract__c;
                    }                    
                    m_Value +=  bc.Terms_To_End_Of_Contract__c * bc.Payment_Amount__c; 
                }
                
                cc.Number_Contracts__c = m_countContract;
                cc.Contracts_Amount__c = valor; 
                
                cc.Advanced_Expired_Payments_Amount__c = m_Value; 
                cc.Advanced_Expired_Payments_Term__c = m_ValueTerm; 
                
                if(invoiceItemMap.get(cc.Account__c) != null){
                    cc.Advanced_Expired_Payments_Term__c += 1;
                    cc.Advanced_Expired_Payments_Amount__c += (Decimal) invoiceItemMap.get(cc.Account__c).get('sumNetValue');
                }
                
                l_ccToUpdate.add(cc);
            } 
            update l_ccToUpdate;
        } 
    }
    
}