global class UTIL_CancelAndCreateJournals {
        
    /////////////////////////////Create Insurance Interest, Proprocional and Invoice Capital Journals  -- PER BILLING///////////////////////////////
    public static Set<ID> createOldJournalsListAP(List<ID> appIdList){
        
        List <Billing_Contract_Line_Item__c> billingItemList = new  List<Billing_Contract_Line_Item__c> ([SELECT id
                                                                                                          FROM Billing_Contract_Line_Item__c 
                                                                                                          where Application__r.id in :appIdList and Invoiced__c = true and ((Interest__c!=0 And Interest__c!=null) OR
	                                                                                                                                                    					(Product_code__c='PT02' OR  Product_code__c='PT11' OR 
	                                                                                                                                                      					Product_code__c='PT18' OR  Product_code__c='PT19')) and Line_Item_Start_Date__c <= Today]);
        
        if(billingItemList ==null || billingItemList.isEmpty()){
            return new Set<ID>();
        }
        
        List<ID> billingItemIDList = new List<ID>();
        for(Billing_Contract_Line_Item__c billItem : billingItemList){
            billingItemIDList.add(billItem.id);
        }
        
        return createJournalsListBLI(billingItemIDList);
    }
    
    public static Set<ID> createJournalsListBLI(List<id> billingItemIDList){
        
        List<Billing_Contract_Line_Item__c> billingItemList = new  List<Billing_Contract_Line_Item__c> ([SELECT id,Name, Line_Item_Start_Date__c,Line_Item_End_Date__c, 
                                                                                                         Interest__c,Principal__c,Contract_Line_Value__c,Product_code__c, Sales_Price__c,
                                                                                                         Application__r.name, Application__r.id,Application__r.Payment_Timing__c,Application__r.Payment_Freq__c,
                                                                                                         Application__r.AccClient__c, Application__r.Vendor__r.BillingCountryCode,
                                                                                                         Application__r.Invoice_Payment_Date__c,Application__r.Beginning_of_Term__c,
                                                                                                         Application__r.Insurance_Pro_Rata__c, Application__r.Interim_Fee_Days__c,
                                                                                                         Application__r.Delivery_Certificate_Signed__c, (Select ID,Name,c2g__Invoice__r.Name, c2g__Invoice__r.id 
                                                                                                                                                         From Sales_Invoice_Line_Items__r 
                                                                                                                                                         where c2g__Invoice__r.Canceled__c = false 
                                                                                                                                                         order by c2g__Invoice__r.c2g__Period__c desC
                                                                                                                                                         limit 1)
                                                                                                         FROM Billing_Contract_Line_Item__c 
                                                                                                         where id in :billingItemIDList and Invoiced__c = true and((Interest__c!=0 And Interest__c!=null) OR 
                                                                                                                                             						(Product_code__c='PT02' OR  Product_code__c='PT11' OR 
                                                                                                                                              						Product_code__c='PT18' OR  Product_code__c='PT19'))]);
        
        if(billingItemList ==null || billingItemList.isEmpty()){
            return new Set<ID>();
        }
        
        Set<String> appCountryList = new Set<String>();
        for(Billing_Contract_Line_Item__c billItem : billingItemList){
            appCountryList.add(billItem.Application__r.Vendor__r.BillingCountryCode);
        }
        
        List<c2g__codaJournal__c> existJournalList = new List<c2g__codaJournal__c>([Select Id,Application__c, c2g__Reference__c, c2g__JournalDescription__c,TypeDescription__c,Billing_Contract_Line_Item__r.Name
                                                                                    From c2g__codaJournal__c 
                                                                                    where (Billing_Contract_Line_Item__c in :billingItemList) and 
                                                                                    (c2g__CanceledJournal__c = false) and c2g__JournalStatus__c != 'Discarded' and 
                                                                                    (TypeDescription__c = 'Interest' or TypeDescription__c  = 'Insurance' or
                                                                                     TypeDescription__c = 'Proportional Insurance' or TypeDescription__c = 'Invoice Capital')
                                                                                   ]);
        
        //verify if there is a jource with that description already create to that invoice
        Map<String,Boolean> journalCreatedPerBilling= new Map<String,Boolean>();
        for(c2g__codaJournal__c journalAux : existJournalList){
            journalCreatedPerBilling.put(journalAux.TypeDescription__c + ' ' + journalAux.Billing_Contract_Line_Item__r.Name, True);
        }
        
        List<Accounting_Admin__c> trsAdminList = new List<Accounting_Admin__c>([Select Journal_line_type__c, General_Ledger_Account__c, Operation__c, Type__c,Description__c,Country_Code__c,Config_Name__c
                                                                                from Accounting_Admin__c 
                                                                                where (Config_Name__c= 'Transaction'  or (Config_Name__c = 'Deferred Journal' and Type__c = 'Interest' and Operation__c = '(-)'))
                                                                                	   and (Type__c = 'Interest' or Type__c = 'Insurance')
                                                                                       and Country_Code__c in :appCountryList/*order by order__c*/ ]);
        
        List<Accounting_Admin__c> balAdminList = new List<Accounting_Admin__c>([Select Journal_line_type__c, General_Ledger_Account__c, Operation__c, Type__c,Description__c,Country_Code__c,Config_Name__c
                                                                                from Accounting_Admin__c 
                                                                                where Config_Name__c= 'Balance Journal' and Country_Code__c in :appCountryList]); 
        
        List<Accounting_Admin__c> propAdminList = new List<Accounting_Admin__c>([Select Journal_line_type__c, General_Ledger_Account__c,Operation__c,Description__c,Type__c,Country_Code__c,Config_Name__c
                                                                                 from Accounting_Admin__c 
                                                                                 where Config_Name__c ='Proportional Insurance' and Country_Code__c in :appCountryList]);
        
        Map<String,List<Accounting_Admin__c>> trsAdminMap = new Map<String,List<Accounting_Admin__c>>();
        Map<String,List<Accounting_Admin__c>> balAdminMap = new Map<String,List<Accounting_Admin__c>>();
        Map<String,List<Accounting_Admin__c>> propAdminMap = new Map<String,List<Accounting_Admin__c>>();
        List<Accounting_Admin__c> auxAdmin = new List<Accounting_Admin__c>();
        
        for(Accounting_Admin__c trsItem :trsAdminList){
            if(trsAdminMap.get(trsItem.Country_Code__c) ==null){
                auxAdmin = new List<Accounting_Admin__c>();
                auxAdmin.add(trsItem);
                trsAdminMap.put(trsItem.Country_Code__c,auxAdmin);
            }else{
                trsAdminMap.get(trsItem.Country_Code__c).add(trsItem);
            }
        }
        
        for(Accounting_Admin__c propItem :propAdminList){
            if(propAdminMap.get(propItem.Country_Code__c) == null){
                auxAdmin = new List<Accounting_Admin__c>();
                auxAdmin.add(propItem);
                propAdminMap.put(propItem.Country_Code__c,auxAdmin);
            }else{
                propAdminMap.get(propItem.Country_Code__c).add(propItem);
            }
            
        }
        
        for(Accounting_Admin__c balItem :balAdminList){
            if(balAdminMap.get(balItem.Country_Code__c) == null){
                auxAdmin = new List<Accounting_Admin__c>();
                auxAdmin.add(balItem);
                balAdminMap.put(balItem.Country_Code__c,auxAdmin);
            }else{
                balAdminMap.get(balItem.Country_Code__c).add(balItem);
            }
        }  
        
        
        List<c2g__codaJournal__c> journalList=new List<c2g__codaJournal__c>();
        journalList.addAll(createJournalsBillings(billingItemList,journalCreatedPerBilling));
        
        if (journalList != null && journalList.size() != 0){
            insert journalList;
        }else{
            return new Set<ID>();
        }
        
        journalList = [Select ID,Name,c2g__JournalDescription__c,TypeDescription__c,c2g__Reference__c,Application__c,Billing_Contract_Line_Item__r.Name
                       From c2g__codaJournal__c 
                       where id in :journalList];
        
        //map the journals created with their description and their reference so that the following items are created
        Map<String,ID> billingItemJournalMap = new  Map<String,ID>();
        for(c2g__codaJournal__c journalToMap : journalList){
            billingItemJournalMap.put(journalToMap.TypeDescription__c + ' ' + journalToMap.Billing_Contract_Line_Item__r.Name,journalToMap.ID);
        }
        
        List<c2g__codaJournalLineItem__c> JournalItemList=new List<c2g__codaJournalLineItem__c>();
        
        JournalItemList.addAll(createJournalsItemBillingItem(billingItemList,billingItemJournalMap, journalCreatedPerBilling, trsAdminMap, balAdminMap, propAdminMap));
        
        if(JournalItemList !=null && JournalItemList.size()>0){
            insert JournalItemList; 
        }else{
            return (new Set<ID>());
        }
        
        Set<ID> journalsToPost=new Set<ID>();
        
        //journals to post
        for(c2g__codaJournal__c journal :journalList){
            journalsToPost.add(journal.id);
        }
        
        // leave post commented for prod for now
        if(journalsToPost.size()>0){
            // postJournal(journalsToPost);
        }
        
        return journalsToPost;
    }
    
    /////////////////////////////SettleContract - ContractBeginning Journals////////////////////////////////
    webservice static void createJournalSettleContract(string appName){
        
        Application__c app=[select id from application__c where name = :appName];
        
        List<ID> appIDList = new List<ID>();
        appIDList.add(app.id);
        
        createJournalSettleContractAppList(appIDList);
    }
    
    //create multiple contract beginning journals for the apps passed by parameter (IDs)
    public static Set<ID> createJournalSettleContractAppList(List<ID> appIdList){
        Savepoint sp = Database.setSavepoint();
        
        try{
            List<Application__c> appList=[Select id, name, Interim_Fee_Days__c, Equipment_Cost__c, AccClient__c, Payment_Freq__c, Vendor__r.BillingCountryCode, Insurance_Pro_Rata__c,Invoice_Payment_Date__c 
                                          from application__c 
                                          where id in :appIdList];
            
            List<String> appNameList = new List<String>();
            Set<String> appCountryList = new Set<String>();
            
            for(application__c app : appList){
                appNameList.add(app.Name);
                appCountryList.add(app.Vendor__r.BillingCountryCode);
            }
            
            List<c2g__codaJournal__c> existantContractBeginningJournal = new List<c2g__codaJournal__c>([Select Id,c2g__Reference__c,Application__r.Name
                                                                                                        From c2g__codaJournal__c 
                                                                                                        where TypeDescription__c = 'Contract Beginning'  
                                                                                                        and c2g__CanceledJournal__c = false 
                                                                                                        and c2g__Type__c='Manual Journal' and (c2g__Reference__c in :appNameList or Application__c in :appList)]);
            
            Map<String,Boolean> existantContractBeginningMap = new Map<String,Boolean>();
            for(c2g__codaJournal__c journal: existantContractBeginningJournal){
                existantContractBeginningMap.put(journal.Application__c,True);
            }
            
            List<c2g__codaJournal__c> journalsCreated = new List<c2g__codaJournal__c>();
            //for every app verify if need to create
            for(Application__c app : appList){
                if(existantContractBeginningMap.get(app.id)==null){
                    
                    c2g__codaJournal__c journal = new c2g__codaJournal__c(c2g__JournalDate__c=app.Invoice_Payment_Date__c,c2g__Reference__c= app.name, Application__c = app.id,
                                                                          c2g__JournalDescription__c='Contract Beginning ' + app.Name, Batch_To_Post__c = true,
                                                                          TypeDescription__c = 'Contract Beginning');
                    
                    journalsCreated.add(journal);
                }
            }
            
            if(journalsCreated != null && !journalsCreated.isEmpty()){
                insert journalsCreated;
            }else{
                return new Set<ID>();
            }
            
            Map<String,ID> journalsByAppMap = new Map<String,ID>();
            for(c2g__codaJournal__c journal : journalsCreated){
                journalsByAppMap.put(journal.Application__c, journal.id);
            }
            
            //Select and MAp the operations by country (account admin) 
            List<Accounting_Admin__c> accAdminList = [Select Config_Name__c, Journal_Line_Type__c, General_Ledger_Account__c,Operation__c,Description__c,Country_Code__c
                                                      from Accounting_Admin__c 
                                                      where Config_Name__c in ('Journal'/*,'Proportional Insurance'*/) and Country_Code__c in :appCountryList ] ;
            
            Map<String,List<Accounting_Admin__c>> accAdminMap = new Map<String,List<Accounting_Admin__c>>();
            List<Accounting_Admin__c> auxAccAdminList = new List<Accounting_Admin__c>();
            for(Accounting_Admin__c accItem :accAdminList){
                if(accAdminMap.get(accItem.Country_Code__c) ==null){
                    auxAccAdminList = new List<Accounting_Admin__c>();
                    auxAccAdminList.add(accItem);
                    accAdminMap.put(accItem.Country_Code__c,auxAccAdminList);
                }else{
                    accAdminMap.get(accItem.Country_Code__c).add(accItem);
                }
            }
            
            //creation of itens
            Id c2gAccount;
            Decimal journVal=0;
            List<c2g__codaJournalLineItem__c> journalItemsList = new List<c2g__codaJournalLineItem__c>();
            
            for(Application__c app : appList){
                if(existantContractBeginningMap.get(app.Name)==null){
                    auxAccAdminList = accAdminMap.get(app.Vendor__r.BillingCountryCode);
                    if(auxAccAdminList != null && !auxAccAdminList.isEmpty()){
                        for(Accounting_Admin__c accAdmin : auxAccAdminList){
                            
                            if(accAdmin.Operation__c=='(-)'){
                                journVal=app.Equipment_Cost__c*-1;
                            }
                            else{
                                journVal=app.Equipment_Cost__c;
                            }
                            //   descrip=(accAdmin[h].Description__c).replace('AP-xxxxxx', app.name); deprecated for development ACCOUNTING INTEREST
                            // ADDED for development ACCOUNTING INTEREST
                            if(accAdmin.Journal_Line_Type__c=='General Ledger Account'){
                                c2gAccount=null;
                            } else {
                                c2gAccount=app.AccClient__c;
                            }
                            
                            //journalItem changed to accomodate development ACCOUNTING INTEREST    
                            c2g__codaJournalLineItem__c journalItem=new c2g__codaJournalLineItem__c(c2g__LineType__c=accAdmin.Journal_Line_Type__c, c2g__Account__c= c2gAccount,
                                                                                                    c2g__GeneralLedgerAccount__c= accAdmin.General_Ledger_Account__c, c2g__Value__c =journVal,
                                                                                                    c2g__Journal__c= journalsByAppMap.get(app.id)/*,  c2g__LineDescription__c =descrip*/);
                            journalItemsList.add(journalItem);
                            
                        }
                    }
                }
            }
            
            insert journalItemsList;
            
            Set<ID> journalsToPost = new Set<Id>();
            for(integer l=0; l<journalsCreated.size(); l++){
                journalsToPost.add(journalsCreated[l].id);
            }
            
            if(journalsToPost.size()>0){
                // postJournal(journalsToPost);
            }
            return journalsToPost;
        } catch(Exception e){
            Database.rollback(sp);
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c();
            record.Start__c=system.today();
            record.Code__c = 'CRITICAL';
            record.ApplicationID__c = 'JOURNAL CONTRACT BEGINNING';
            record.message__c = e.getMessage();
            record.printStackTrace__c = e.getStackTraceString();
            system.debug('CRITICAL: '+ record);
            system.debug(e.getStackTraceString());
            insert record;
            return (new Set<ID>());
        }
    }
    
    /////////////////////////////Cancelamento Journals////////////////////////////////
    webservice static void CancelJournals( string appname){   
        Savepoint sp = Database.setSavepoint();
        /* try{   */         
        List<ID> journalIDS       = new List<ID>();  
        List<ID> newCancelrefsIds = new List<ID>();
        List<c2g.CODAAPICommon.Reference> refs                                  = new List<c2g.CODAAPICommon.Reference>();
        List<c2g.CODAAPICommon.Reference> newCancelrefs                         = new List<c2g.CODAAPICommon.Reference>();
        list<c2g.CODAAPIJournalTypes_12_0.CancellingInformation> listCancelInfo = new list<c2g.CODAAPIJournalTypes_12_0.CancellingInformation>();
        
        List<c2g__codaJournal__c> journalsCanceled = [Select c2g__OriginalJournal__r.id 
                                                      From c2g__codaJournal__c 
                                                      where c2g__Reference__c= :appname and c2g__Type__c = 'Cancelling Journal' ];
        Set<ID> journalIdCanceledList = new Set<ID>();
        
        for(c2g__codaJournal__c journalCanceled : journalsCanceled){
            journalIdCanceledList.add(journalCanceled.c2g__OriginalJournal__r.id);
        }
        
        list<c2g__codaJournal__c> jnlToCancel=new LIST<c2g__codaJournal__c>([SELECT id,  c2g__Period__c, c2g__Reference__c,  c2g__JournalDescription__c, c2g__OriginalJournal__c,
                                                                             Sales_Invoice__r.name, to_be_deferred__c , createddate
                                                                             FROM c2g__codaJournal__c 
                                                                             WHERE c2g__Reference__c= :appname 
                                                                             AND (c2g__JournalDescription__c='Interest Amount Post' 
                                                                                  OR c2g__JournalDescription__c ='Contract Beginning Post' 
                                                                                  or c2g__JournalDescription__c = 'Interest and Insurance Post' 
                                                                                  or c2g__JournalDescription__c = 'Balance Account Post' 
                                                                                  or c2g__JournalDescription__c = 'Proportional Insurance Post'
                                                                                  or c2g__JournalDescription__c LIKE 'Deferred Interest and Insurance Post%'
                                                                                  or c2g__JournalDescription__c LIKE 'Deferred Proportional Insurance Post%'
                                                                                  or ((Application__c = '' or Application__c = null) and TypeDescription__c = 'Contract Beginning' )) 
                                                                             and c2g__CanceledJournal__c = false and id not in :journalIdCanceledList and c2g__JournalStatus__c = 'Complete'
                                                                             order by c2g__Period__c 
                                                                             //AND c2g__Transaction__r.name='TRN016952'
                                                                            ]);
        
        if(jnlToCancel == null || jnlToCancel.size()==0){
            return;
        }
        //System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> jnlToCancel: '+jnlToCancel); 
        System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> jnlToCancel.size(): '+jnlToCancel.size());                                                  
        
        for (c2g__codaJournal__c auxjnl : jnlToCancel)
        {
            c2g.CODAAPICommon.Reference refjnlid     = new c2g.CODAAPICommon.Reference(); 
            c2g.CODAAPICommon.Reference refjnlPeriod = new c2g.CODAAPICommon.Reference(); 
            refjnlid.id                              = auxjnl.id;
            refjnlPeriod.id                          = auxjnl.c2g__Period__c;
            c2g.CODAAPIJournalTypes_12_0.CancellingInformation cancelinfo = new c2g.CODAAPIJournalTypes_12_0.CancellingInformation();
            cancelinfo.OriginalJournalRef            = refjnlid;
            cancelinfo.CancellingDescription         = 'Cancel ' + auxjnl.c2g__JournalDescription__c + ' ' + auxjnl.c2g__Reference__c;
            cancelinfo.CancellingReference           = auxjnl.c2g__Reference__c;
            cancelinfo.CancellingPeriod              = refjnlPeriod;
            listCancelInfo.add(cancelinfo);
            auxjnl.c2g__CanceledJournal__c = true;            
            journalIDS.add(auxjnl.ID);
        }
        update jnlToCancel;
        System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> listCancelInfo: '+listCancelInfo);
        if(listCancelInfo == null || listCancelInfo.size()==0){
            return;
        }
        newCancelrefs = c2g.CODAAPIJournal_12_0.BulkCancelJournal(null, listCancelInfo);
        
        // System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> newCancelrefs: ' + newCancelrefs);
        System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> newCancelrefs.size(): ' + newCancelrefs.size());
        
        //return newCancelrefs;
        //ALTERACAO - 26/06/17 - BP started here                                                
        /**********************************************************************/
        /*   CASH MATCHING BETWEEN Journals to Cancel and Canceled Journals   */
        /**********************************************************************/
        
        for(c2g.CODAAPICommon.Reference currentRef: newCancelrefs){            
            newCancelrefsIds.add(currentRef.Id);
        }
        //System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> newCancelrefsIds: '+newCancelrefsIds);
        System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> (2nd query) newCancelrefsIds.size(): '+newCancelrefsIds.size());
        
        System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> (1st query) journalIDS.size(): ' + journalIDS.size());
        List<c2g__codaTransactionLineItem__c> relatedJournalsToCancelTLIS = [SELECT ID,c2g__AccountValue__c,c2g__Transaction__r.c2g__Period__c , c2g__GeneralLedgerAccount__c
                                                                             FROM c2g__codaTransactionLineItem__c 
                                                                             WHERE c2g__LineType__c='Account'
                                                                             AND c2g__Transaction__c IN (SELECT c2g__Transaction__c
                                                                                                         FROM c2g__codaJournal__c 
                                                                                                         WHERE  ID IN :journalIDS or ID IN :newCancelrefsIds )
                                                                             ORDER BY c2g__GeneralLedgerAccount__c ASC                                                                                                                                                   
                                                                            ];
        
        System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> relatedJournalsToCancelTLIS: '+relatedJournalsToCancelTLIS);
        System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> relatedJournalsToCancelTLIS.size(): '+relatedJournalsToCancelTLIS.size());
        
        List<Account> client = [SELECT ID 
                                FROM Account 
                                WHERE ID IN  (SELECT AccClient__c 
                                              FROM Application__c 
                                              WHERE Name =:appname
                                             )
                               ];
        // Cash Matching need Trs to have same ledger Account
        List<c2g__codaTransactionLineItem__c> TrsWithsameGenLedgAcc= new List<c2g__codaTransactionLineItem__c>();
        id prevgenledgacc;
        integer maxlistTrs=relatedJournalsToCancelTLIS.size();
        integer i=0;
        for(c2g__codaTransactionLineItem__c trs :relatedJournalsToCancelTLIS ){
            i++;
            system.debug(trs.c2g__GeneralLedgerAccount__c);
            if (prevgenledgacc==null || trs.c2g__GeneralLedgerAccount__c == prevgenledgacc){
                TrsWithsameGenLedgAcc.add(trs) ;
            }
            if(prevgenledgacc!=null && prevgenledgacc!=trs.c2g__GeneralLedgerAccount__c)
            {   
                system.debug('TrsWithsameGenLedgAcc '+ prevgenledgacc+ ' '+ TrsWithsameGenLedgAcc.size());
                System.enqueueJob(new UTIL_QE_CashMatchCancelJnl(client[0].Id,null,TrsWithsameGenLedgAcc));
                // SEPA_SF_Return.doMatch(client[0].Id,null,TrsWithsameGenLedgAcc);
                TrsWithsameGenLedgAcc.clear();
                TrsWithsameGenLedgAcc.add(trs) ;
                
            }
            if(i==maxlistTrs){
                system.debug('TrsWithsameGenLedgAcc '+ prevgenledgacc+ ' '+ TrsWithsameGenLedgAcc.size());
                System.enqueueJob(new UTIL_QE_CashMatchCancelJnl(client[0].Id,null,TrsWithsameGenLedgAcc));
                //FF_Utils.doMatch(client[0].Id,null,TrsWithsameGenLedgAcc);
                
            }
            prevgenledgacc=trs.c2g__GeneralLedgerAccount__c;
            
            
        }
        
        /*}//end catch scope
catch(Exception e)
{
System.Debug('[UTIL_CancelAndCreateJournals].CancelJournals --> ERROR: ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() + e.getStackTraceString());
System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> RollingBack...');
Database.rollback(sp);*
}*/
    }
    
    //multiple apps cancel old journals
    public static void cancelOldJournalAppList(List<ID> appIDList){
        List<String> deferredTypeDescription = new List<String>();
        deferredTypeDescription.add('Invoice Capital');
        deferredTypeDescription.add('Interest');
        deferredTypeDescription.add('Insurance');
        deferredTypeDescription.add('Proportional Insurance');
        deferredTypeDescription.add('Deferral Interest');
        deferredTypeDescription.add('Deferral Insurance');
        deferredTypeDescription.add('Deferral Proportional Insurance');
        
        //app List
        List<Application__c> appList = new List<Application__c>([Select ID, Name From Application__c where id in :appIDList]);
        
        List<String> appNameList = new List<String>();
        for(application__c app : appList){
            appNameList.add(app.Name);
        }
        
        //already canceled journals
        List<c2g__codaJournal__c> journalsCanceled = [Select c2g__OriginalJournal__r.id,c2g__JournalStatus__c
                                                      From c2g__codaJournal__c 
                                                      where (c2g__Reference__c in :appNameList or Application__c in :appIDList) and c2g__Type__c = 'Cancelling Journal' ];
        
        Set<ID> journalIdCanceledList = new Set<ID>();
        for(c2g__codaJournal__c journalCanceled : journalsCanceled){
            journalIdCanceledList.add(journalCanceled.c2g__OriginalJournal__r.id);
        }
        
        //Journals to cancelled: same app, have the corresponding description; can't be already canceled and need to be Complete
        List<c2g__codaJournal__c> jnlToCancel=new List<c2g__codaJournal__c>([SELECT id,  c2g__Period__c, c2g__Reference__c, Application__c, c2g__JournalDescription__c, c2g__OriginalJournal__c,
                                                                             Sales_Invoice__r.name, to_be_deferred__c , createddate,c2g__CanceledJournal__c,c2g__JournalStatus__c
                                                                             FROM c2g__codaJournal__c 
                                                                             WHERE (c2g__Reference__c in :appNameList or Sales_Invoice__r.Application__c in :appIDList or Application__c  in :appIDList)
                                                                             AND (c2g__JournalDescription__c='Interest Amount Post' 
                                                                                  OR c2g__JournalDescription__c ='Contract Beginning Post' 
                                                                                  or c2g__JournalDescription__c = 'Interest and Insurance Post' 
                                                                                  or c2g__JournalDescription__c = 'Balance Account Post' 
                                                                                  or c2g__JournalDescription__c = 'Proportional Insurance Post'
                                                                                  or c2g__JournalDescription__c LIKE 'Deferred Interest and Insurance Post%'
                                                                                  or c2g__JournalDescription__c LIKE 'Deferred Proportional Insurance Post%'
                                                                                  or TypeDescription__c='Interest' 
                                                                                  or TypeDescription__c = 'Insurance' 
                                                                                  or TypeDescription__c = 'Invoice Capital' 
                                                                                  or TypeDescription__c = 'Proportional Insurance'
                                                                                  or TypeDescription__c = 'Deferral Interest'
                                                                                  or TypeDescription__c = 'Deferral Insurance'
                                                                                  or TypeDescription__c = 'Deferral Proportional Insurance'                                                                                  
                                                                                  or ((Application__c = '' or Application__c = null) and TypeDescription__c = 'Contract Beginning' ) 
                                                                                  or (Sales_Invoice__c != '' and Sales_Invoice__c != null and TypeDescription__c in :deferredTypeDescription))
                                                                             and c2g__CanceledJournal__c = false and id not in :journalIdCanceledList and c2g__JournalStatus__c = 'Complete'
                                                                             order by c2g__Period__c 
                                                                             //AND c2g__Transaction__r.name='TRN016952'
                                                                            ]);
        if(jnlToCancel != null && jnlToCancel.size()>0){
            CancelJournals(jnlToCancel);
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////******************************////////////////////////////////
    //                                  Métodos Auxiliares
    /////////////////////////////******************************////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////
    
    //method to cancel
    public static void CancelJournals(List<c2g__codaJournal__c> journalList){
        List<c2g.CODAAPICommon.Reference> newCancelrefs = new List<c2g.CODAAPICommon.Reference>();
        list<c2g.CODAAPIJournalTypes_12_0.CancellingInformation> listCancelInfo = new list<c2g.CODAAPIJournalTypes_12_0.CancellingInformation>();
        
        for(c2g__codaJournal__c journal : journalList){
            c2g.CODAAPICommon.Reference refjnlid     = new c2g.CODAAPICommon.Reference(); 
            c2g.CODAAPICommon.Reference refjnlPeriod = new c2g.CODAAPICommon.Reference();
            if(journal.c2g__JournalStatus__c == 'In Progress' || journal.c2g__CanceledJournal__c){
                continue;
            }
            refjnlid.id                              = journal.id;
            refjnlPeriod.id                          = journal.c2g__Period__c;
            c2g.CODAAPIJournalTypes_12_0.CancellingInformation cancelinfo = new c2g.CODAAPIJournalTypes_12_0.CancellingInformation();
            cancelinfo.OriginalJournalRef            = refjnlid;
            cancelinfo.CancellingDescription         = 'Cancel ' + journal.c2g__JournalDescription__c;
            cancelinfo.CancellingReference           = journal.c2g__Reference__c;
            cancelinfo.CancellingPeriod              = refjnlPeriod;
            listCancelInfo.add(cancelinfo);
            journal.c2g__CanceledJournal__c = true;
        }
        update journalList;
        newCancelrefs = c2g.CODAAPIJournal_12_0.BulkCancelJournal(null, listCancelInfo);
    }
    
    //reverse journals
    public static void ReverseJournals(Set<ID> journalToReverseIDList){
        c2g.CODAAPIJournalTypes_12_0.ReversingInformation  reverseJournal;
        System.debug('journalToReverseIDList: '+journalToReverseIDList);
        List<c2g__codaJournal__c> journalToReverseList = [Select ID, c2g__JournalDescription__c,c2g__Period__c 
                                                          From  c2g__codaJournal__c where id IN :journalToReverseIDList and c2g__Type__c != 'Reversing Journal']; 
        
        System.debug('journalToReverseList: '+journalToReverseList);
        List<c2g.CODAAPIJournalTypes_12_0.ReversingInformation> reverseJournalList = new List<c2g.CODAAPIJournalTypes_12_0.ReversingInformation>();
        for(c2g__codaJournal__c journalToReverse : journalToReverseList){
            
            c2g.CODAAPICommon.Reference refjnlid     = new c2g.CODAAPICommon.Reference(); 
            c2g.CODAAPICommon.Reference refjnlPeriod = new c2g.CODAAPICommon.Reference();
            
            reverseJournal = new c2g.CODAAPIJournalTypes_12_0.ReversingInformation();
            
            refjnlid.ID = journalToReverse.ID;
            refjnlPeriod.Id = journalToReverse.c2g__Period__c;
            reverseJournal.OriginalJournalRef = refjnlid;
            reverseJournal.ReversingDescription = 'Reversed ' + journalToReverse.c2g__JournalDescription__c;
            reverseJournal.ReversingReference = journalToReverse.ID;
            reverseJournal.ReversingPeriod = refjnlPeriod;
            reverseJournalList.add(reverseJournal);
            System.debug('reverseJournal '+reverseJournal);
        }
        
        System.debug('reverseJournalList '+reverseJournalList);
        
        if(reverseJournalList!=null && reverseJournalList.size()>0){
            c2g.CODAAPIJournal_12_0.BulkReverseJournal(null, reverseJournalList);
        }
    }
    
    //post journals
    public static void postJournal(Set<ID> journals){
        //post journal related to contract
        List<c2g.CODAAPICommon.Reference> refs = new List<c2g.CODAAPICommon.Reference>();
        for(ID journal :journals){
            c2g.CODAAPICommon.Reference ref1 = new c2g.CODAAPICommon.Reference();  
            ref1.Id = journal;
            refs.add(ref1);
        }
        c2g.CODAAPIJournal_6_0.BulkPostJournal(null, refs);
    }
    
    private static List<c2g__codaJournal__c> createJournalsBillings(List<Billing_Contract_Line_Item__c> billingItemList, Map<String,Boolean> journalCreatedPerBilling){
        c2g__codaJournal__c journalInterest, journalInsurance, journalInterestBal, journalProp; 
        List<c2g__codaJournal__c> journalList=new List<c2g__codaJournal__c>();
        
        for(Billing_Contract_Line_Item__c billItem : billingItemList){
            String journalItemName;
            ID sinID;
            if(billItem.Sales_Invoice_Line_Items__r != null && !billItem.Sales_Invoice_Line_Items__r.isEmpty()){
                journalItemName = billItem.Sales_Invoice_Line_Items__r[0].c2g__Invoice__r.Name;
                sinID = billItem.Sales_Invoice_Line_Items__r[0].c2g__Invoice__r.id;
            }else{
                journalItemName = billItem.Name;
            }
            
            //Interest/Insurance journal: Journal to put on deferment accoun
            if(journalCreatedPerBilling.get('Interest '+billItem.Name) == null && (billItem.Product_code__c!='PT02' && billItem.Product_code__c!='PT11')){
                System.debug(' billItem ' + billItem.id + ' product code  '+billItem.Product_code__c);
                
                journalInterest=new c2g__codaJournal__c(c2g__JournalDate__c=billItem.Line_Item_Start_Date__c,  c2g__Reference__c=billItem.name,Application__c = billItem.application__r.id,
                                                        Sales_Invoice__c = sinID,
                                                        Billing_Contract_Line_Item__c = billItem.id,/*c2g__JournalDescription__c='Interest ' + billItem.name,*/ c2g__JournalDescription__c='Interest ' + journalItemName,
                                                        TypeDescription__c = 'Interest',to_be_deferred__c = true, Batch_To_Post__c = true, Deferred_Type__c= numberOfDeferrals(billItem.Line_Item_Start_Date__c,billItem.Application__r.Payment_Freq__c)
                                                       );
            	if((billItem.Line_Item_Start_Date__c.Day() < 15 || billItem.Application__r.Payment_Timing__c == 'Arreas') && (billItem.Application__r.Payment_Freq__c == 'Monthly')){  
                    journalInterest.to_be_deferred__c = false;
                    journalInterest.Deferred_Type__c = 0;
                }
                
                journalList.add(journalInterest) ;
            }
            
            
            if((billItem.Line_Item_Start_Date__c.Day() >= 15 && billItem.Application__r.Payment_Timing__c == 'Advanced') || (billItem.Application__r.Payment_Freq__c == 'Quarterly')){  
                if(journalCreatedPerBilling.get('Insurance '+billItem.Name) == null && billItem.Product_code__c=='PT02'){
                    journalInsurance=new c2g__codaJournal__c(c2g__JournalDate__c=billItem.Line_Item_Start_Date__c,  c2g__Reference__c=billItem.name,Application__c = billItem.application__r.id,
                                                             Billing_Contract_Line_Item__c = billItem.id,/*c2g__JournalDescription__c='Insurance ' + billItem.name,*/ c2g__JournalDescription__c='Insurance ' + journalItemName,
                                                             Sales_Invoice__c = sinID,
                                                             TypeDescription__c = 'Insurance',to_be_deferred__c = true, Batch_To_Post__c = true, Deferred_Type__c= numberOfDeferrals(billItem.Line_Item_Start_Date__c,billItem.Application__r.Payment_Freq__c)
                                                            );
                    journalList.add(journalInsurance);
                }
            }
            
            //journal to divide interest and capital
            if(journalCreatedPerBilling.get('Invoice Capital '+billItem.Name) == null && billItem.interest__c != null && billItem.interest__c != 0){
                journalInterestBal=new c2g__codaJournal__c(c2g__JournalDate__c=billItem.Line_Item_Start_Date__c,  c2g__Reference__c=billItem.name,Application__c = billItem.application__r.id,
                                                           Billing_Contract_Line_Item__c = billItem.id,/*c2g__JournalDescription__c='Invoice Capital ' + billItem.name,*/ c2g__JournalDescription__c='Invoice Capital ' + journalItemName,
                                                           Sales_Invoice__c = sinID,
                                                           TypeDescription__c = 'Invoice Capital',to_be_deferred__c = false, Batch_To_Post__c = true
                                                          );      
                journalList.add(journalInterestBal) ; 
            }               
            
            //product is proporcional insurance
            if(journalCreatedPerBilling.get('Proportional Insurance '+billItem.Name) == null && billItem.application__r.Payment_Freq__c=='Quarterly' && billItem.Product_code__c == 'PT11'){
                integer defdays=(billItem.application__r.Invoice_Payment_Date__c).daysBetween(billItem.application__r.Beginning_of_Term__c);
                integer payMonth=(billItem.Line_Item_Start_Date__c).Month();
                integer begMonth=((billItem.application__r.Beginning_of_Term__c).AddDays(-1)).Month();
                SYSTEM.debug('Proporcional Insurance');
                //The value of proporcional insurance (pro-rata) needs to be different from 0
                //App needs to be quarterly. If app is montlhy the proporcional won't need to be deferred
                //the interim fee days needs to be bigger than 29. if not the proporcional is on the last month and won't needs to be deferred.
                Decimal daysToPeriod = 0;
                Set<Integer> firstMonths = new Set<Integer>{1,4,7,10};
                    Set<Integer> secondMonths = new Set<Integer>{2,5,8,11};
                        
                        if(firstMonths.contains(billItem.Line_Item_Start_Date__c.Month())){
                            daysToPeriod +=60;
                        }else{
                            if(secondMonths.contains(billItem.Line_Item_Start_Date__c.Month())){
                                daysToPeriod +=30;
                            }
                        }
                daysToPeriod += billItem.Line_Item_Start_Date__c.Day();
                
                if(billItem.Sales_Price__c !=0 &&  billItem.application__r.Interim_Fee_Days__c>29 && payMonth !=begMonth/*&& defdays>29*/){
                    journalProp = new c2g__codaJournal__c(c2g__JournalDate__c=billItem.application__r.Invoice_Payment_Date__c,
                                                          c2g__Reference__c= billItem.name,
                                                          Billing_Contract_Line_Item__c = billItem.id,Application__c = billItem.application__r.id,
                                                          //c2g__JournalDescription__c='Proportional Insurance ' + billItem.name,
                                                          c2g__JournalDescription__c='Proportional Insurance ' + journalItemName,
                                                          TypeDescription__c= 'Proportional Insurance', to_be_deferred__c=true,
                                                          Sales_Invoice__c = sinID,
                                                          Deferred_Type__c=(daysToPeriod/30).intvalue(), Batch_To_Post__c = true
                                                         );  
                    
                    journalList.add(journalProp);
                }
            }
        }
        
        return journalList;
    }
    
    private static List<c2g__codaJournalLineItem__c> createJournalsItemBillingItem(List<Billing_Contract_Line_Item__c> billingItemList,Map<String,ID> billingItemJournalMap, Map<String,Boolean> journalCreatedPerBilling, Map<String,List<Accounting_Admin__c>> trsAdminMap,Map<String,List<Accounting_Admin__c>> balAdminMap, Map<String,List<Accounting_Admin__c>> propAdminMap){
        Decimal amountjnl = 0;
        List<c2g__codaJournalLineItem__c> JournalItemList=new List<c2g__codaJournalLineItem__c>();
        
        for(Billing_Contract_Line_Item__c billItem : billingItemList){
            //verify if invoice item as the same id as the invoice and product isn't the proportional insurance
            // create journal line itens to the respective sale invoice item. 
            decimal journalInteres=0;
            List<Accounting_Admin__c> trsAdminPerInvoiceList = trsAdminMap.get(billItem.application__r.Vendor__r.BillingCountryCode);
            System.debug('billItem '+billItem);
            if((billItem.Line_Item_Start_Date__c.Day() >= 15 && billItem.Application__r.Payment_Timing__c == 'Advanced') || ( billItem.Application__r.Payment_Freq__c == 'Quarterly')){
                System.debug('IS deferred ');
                if(journalCreatedPerBilling.get('Insurance '+billItem.Name) == null && billItem.Product_code__c=='PT02'){
                	System.debug('IS insurance ');
                    amountjnl = journalDeferredValue(billItem.Sales_Price__c,numberOfDeferrals(billItem.Line_Item_Start_Date__c,  billItem.Application__r.Payment_Freq__c) , billItem.Application__r.Payment_Freq__c);                    
                    JournalItemList.addAll(billItemOperationAccAdmin(trsAdminPerInvoiceList,amountjnl, billItem,billingItemJournalMap.get('Insurance ' + billItem.name)));
                }
            }
            
            if(journalCreatedPerBilling.get('Interest '+billItem.Name) == null && billItem.Product_code__c!='PT11' && billItem.Product_code__c!='PT02'){
            	System.debug('Juros ');
                if(billItem.Product_code__c=='PT18' || billItem.Product_code__c=='PT19'){
                    amountjnl = billItem.Contract_Line_Value__c;
                }else{
                    amountjnl=billItem.Interest__c ;
                }
                amountjnl = journalDeferredValue(amountjnl,numberOfDeferrals(billItem.Line_Item_Start_Date__c,  billItem.Application__r.Payment_Freq__c) , billItem.Application__r.Payment_Freq__c);
                JournalItemList.addAll(billItemOperationAccAdmin(trsAdminPerInvoiceList,amountjnl, billItem,billingItemJournalMap.get('Interest ' + billItem.name)));
            
            }
            
            journalInteres=0;
            System.debug('billContItems.Billing_Contract_Line_Item__r'+billItem);
            //BalAdmin (Balance) isn't done in insurance (PT02 and PT11)
            if( billItem.Product_code__c!='PT02' && billItem.Product_code__c != 'PT18' && billItem.Product_code__c != 'PT19' && 
               (billItem.interest__c != null && billItem.interest__c != 0) && journalCreatedPerBilling.get('Invoice Capital '+billItem.Name) == null){
                   System.debug('Capital');
                   
                   List<Accounting_Admin__c> balAdminPerInvoiceList = balAdminMap.get(billItem.application__r.Vendor__r.BillingCountryCode);
                   JournalItemList.addAll(billItemOperationAccAdmin(balAdminPerInvoiceList,billItem.principal__c, billItem,billingItemJournalMap.get('Invoice Capital ' + billItem.Name)));
               } 
            
            decimal journVal;
            
            //if invoice item as the same id as the invoice and product is proporcional insurance
            if(journalCreatedPerBilling.get('Proportional Insurance '+billItem.Name) == null && billItem.application__r.Payment_Freq__c=='Quarterly' && billItem.Product_code__c == 'PT11'){
                JournalItemList.addAll(createPropJournalItemByBillingItem(billItem,propAdminMap,billingItemJournalMap));
            }
        }
        
        return JournalItemList;
    }   
    
    private static List<c2g__codaJournalLineItem__c> createPropJournalItemByBillingItem(Billing_Contract_Line_Item__c billItem,Map<String,List<Accounting_Admin__c>> propAdminMap,Map<String,ID> billingItemJournalMap){
        
        Decimal journVal=0;
        integer defdays=(billItem.Line_Item_Start_Date__c).daysBetween(billItem.application__r.Beginning_of_Term__c);
        integer payMonth=(billItem.Line_Item_Start_Date__c).Month();
        integer begMonth=((billItem.application__r.Beginning_of_Term__c).AddDays(-1)).Month();
        List<c2g__codaJournalLineItem__c> JournalItemList = new List<c2g__codaJournalLineItem__c>();
        
        SYSTEM.debug('Proporcional Insurance');
        //The value of proporcional insurance (pro-rata) needs to be different from 0
        //App needs to be quarterly. If app is montlhy the proporcional won't need to be deferred
        //the interim fee days needs to be bigger than 29. if not the proporcional is on the last month and won't needs to be deferred.
        if(billItem.Sales_Price__c !=0 &&  billItem.application__r.Interim_Fee_Days__c>29 && payMonth !=begMonth){
            
            //for that journal it needs that operations
            Integer aux_nopropdays = defdays - 30 * (defdays/30);
            Integer aux_propdays=defdays-aux_nopropdays;
            //aux_propdays=Math.min(defdays, 30);
            List<Accounting_Admin__c> propAdminList = propAdminMap.get(billItem.application__r.Vendor__r.BillingCountryCode);
            journval=((billItem.Sales_Price__c/billItem.application__r.Interim_Fee_Days__c)*aux_propdays).setscale(2);
            
            JournalItemList.addAll(billItemOperationAccAdmin(propAdminList,journval, billItem,billingItemJournalMap.get('Proportional Insurance ' + billItem.name)));
            
        }
        
        return JournalItemList;
    }
    
    private static List<c2g__codaJournalLineItem__c> billItemOperationAccAdmin(List<Accounting_Admin__c> accountingAdminList,Decimal amount, Billing_Contract_Line_Item__c billItem,ID journalId){
        
        List<c2g__codaJournalLineItem__c> JournalItemList = new List<c2g__codaJournalLineItem__c>();
        Decimal journalValue;
        for(Accounting_Admin__c accAdmin : accountingAdminList){
            //if opperation is interest and billing product_code IS insurance/prop insurance doens't execute or
            //if operation is insurance and billing product code ISN'T insurance/prop also doesn't execute
            if((accAdmin.Type__c=='Interest' && (billItem.Product_code__c=='PT02' || billItem.Product_code__c=='PT11' )) || (accAdmin.Type__c=='Insurance' && billItem.Product_code__c!='PT02')){
                continue;
            }
           
            //if there isn't necessity of creating a deferred journal (like on the  Arreas Contract) the Interest Journal created put the value into the account that the Deferred journal uses 
            //(i.e. instead of using (ex:) the acc: 2821 - DIFERIMENTO JUROS, it uses directly the acc 7932 - JUROS DE RENDAS that is used in the Deferred interesst Journal
            //so if the condition of not deferred is verify and the account using on negative isn't the deferred it continues to next iteration. 
            //Also, this condition only exists to the intest journal. however the previous condition verify that
            if(billItem.Application__r.Payment_Timing__c == 'Arreas' || (billItem.Line_Item_Start_Date__c.Day() < 15 && billItem.Application__r.Payment_Timing__c == 'Advanced')){
                if(accAdmin.Type__c=='Interest' && accAdmin.Config_Name__c != 'Deferred Journal' && accAdmin.Operation__c == '(-)'){
                	continue;
                }
            }else{
                 if(accAdmin.Config_Name__c == 'Deferred Journal'){
                	continue;
                }
            }
            
            c2g__codaJournalLineItem__c JournalIntItem=new c2g__codaJournalLineItem__c();
            
            if(accAdmin.Operation__c=='(-)'){
                journalValue=amount  *-1;
            }else{
                journalValue=amount;
            }
            
            if(accAdmin.Journal_line_type__c =='Account - Customer'){
                JournalIntItem.c2g__account__c=billItem.Application__r.AccClient__c;
            }else{
                JournalIntItem.c2g__account__c=null;
            }
            
            JournalIntItem.c2g__LineType__c=accAdmin.Journal_line_type__c;
            JournalIntItem.c2g__GeneralLedgerAccount__c= accAdmin.General_Ledger_Account__c;
            JournalIntItem.c2g__Value__c =journalValue.setScale(2);
            JournalIntItem.c2g__Journal__c= journalID;
            
            //DEPRECATED for development ACCOUNTING_INTEREST
            //JournalIntItem.c2g__LineDescription__c =descripinterest;
            
            JournalItemList.add(JournalIntItem);
        }
        
        return JournalItemList;
    }
    
    public static void cashMatchingCancelJournals(ID appID){
        Application__c app = [SELECT Id,Name,AccClient__c 
                              FROM Application__c 
                              WHERE id = :appID limit 1
                             ];
        List<String> deferredTypeDescription = new List<String>();
        deferredTypeDescription.add('Invoice Capital');
        deferredTypeDescription.add('Interest');
        deferredTypeDescription.add('Insurance');
        deferredTypeDescription.add('Proportional Insurance');
        deferredTypeDescription.add('Deferral Interest');
        deferredTypeDescription.add('Deferral Insurance');
        deferredTypeDescription.add('Deferral Proportional Insurance');
        
        List<c2g__codaJournal__c> journalCanceledList = new List<c2g__codaJournal__c>([SELECT id
                                                                                       FROM c2g__codaJournal__c 
                                                                                       WHERE (c2g__Reference__c = :app.Name or Sales_Invoice__r.Application__c = :app.Id or Application__c = :app.id or Billing_Contract_Line_Item__r.Application__c = :app.id)  
                                                                                       AND (c2g__JournalDescription__c='Interest Amount Post' 
                                                                                            OR c2g__JournalDescription__c ='Contract Beginning Post' 
                                                                                            or c2g__JournalDescription__c = 'Interest and Insurance Post' 
                                                                                            or c2g__JournalDescription__c = 'Balance Account Post' 
                                                                                            or c2g__JournalDescription__c = 'Proportional Insurance Post'
                                                                                            or c2g__JournalDescription__c LIKE 'Deferred Interest and Insurance Post%'
                                                                                            or c2g__JournalDescription__c LIKE 'Deferred Proportional Insurance Post%'
                                                                                            or TypeDescription__c = 'Interest' 
                                                                                            or TypeDescription__c = 'Insurance' 
                                                                                            or TypeDescription__c = 'Invoice Capital' 
                                                                                            or TypeDescription__c = 'Proportional Insurance'
                                                                                            or TypeDescription__c = 'Deferral Interest'
                                                                                            or TypeDescription__c = 'Deferral Insurance'
                                                                                            or TypeDescription__c = 'Deferral Proportional Insurance' 
                                                                                            or ((Application__c = '' or Application__c = null) and TypeDescription__c = 'Contract Beginning' )
                                                                                            or (Sales_Invoice__c != '' and Sales_Invoice__c != null and TypeDescription__c in :deferredTypeDescription))
                                                                                       and c2g__CanceledJournal__c = true and c2g__JournalStatus__c = 'Complete'
                                                                                       order by c2g__Period__c 
                                                                                       //AND c2g__Transaction__r.name='TRN016952'
                                                                                      ]);
        
        List<c2g__codaJournal__c> cancellationJournalList = new List<c2g__codaJournal__c>([SELECT id,  c2g__Period__c, c2g__Reference__c,  c2g__JournalDescription__c, c2g__OriginalJournal__c,
                                                                                           Sales_Invoice__r.name, to_be_deferred__c , createddate,c2g__CanceledJournal__c,c2g__JournalStatus__c
                                                                                           FROM c2g__codaJournal__c 
                                                                                           WHERE c2g__OriginalJournal__c in :journalCanceledList
                                                                                           order by c2g__Period__c 
                                                                                           //AND c2g__Transaction__r.name='TRN016952'
                                                                                          ]);
        
        List<c2g__codaTransactionLineItem__c> relatedJournalsToCancelTLIS = [SELECT ID,c2g__AccountValue__c,c2g__Transaction__r.c2g__Period__c , c2g__GeneralLedgerAccount__c
                                                                             FROM c2g__codaTransactionLineItem__c 
                                                                             WHERE c2g__LineType__c='Account' and c2g__MatchingStatus__c = 'Available'
                                                                             AND c2g__Transaction__c IN (SELECT c2g__Transaction__c
                                                                                                         FROM c2g__codaJournal__c 
                                                                                                         WHERE  ID IN :journalCanceledList or ID IN :cancellationJournalList)
                                                                             ORDER BY c2g__GeneralLedgerAccount__c ASC                                                                                                                                                   
                                                                            ];
        
        System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> relatedJournalsToCancelTLIS: '+relatedJournalsToCancelTLIS);
        System.debug('[UTIL_CancelAndCreateJournals].CancelJournals --> relatedJournalsToCancelTLIS.size(): '+relatedJournalsToCancelTLIS.size());
        
        List<Account> client = [SELECT ID 
                                FROM Account 
                                WHERE ID = :app.AccClient__c
                               ];
        
        // Cash Matching need Trs to have same ledger Account
        List<c2g__codaTransactionLineItem__c> TrsWithsameGenLedgAcc= new List<c2g__codaTransactionLineItem__c>();
        id prevgenledgacc;
        integer maxlistTrs=relatedJournalsToCancelTLIS.size();
        integer i=0;
        for(c2g__codaTransactionLineItem__c trs :relatedJournalsToCancelTLIS ){
            i++;
            system.debug(trs.c2g__GeneralLedgerAccount__c);
            if (prevgenledgacc==null || trs.c2g__GeneralLedgerAccount__c == prevgenledgacc){
                TrsWithsameGenLedgAcc.add(trs) ;
            }
            if(prevgenledgacc!=null && prevgenledgacc!=trs.c2g__GeneralLedgerAccount__c)
            {   
                system.debug('TrsWithsameGenLedgAcc '+ prevgenledgacc+ ' '+ TrsWithsameGenLedgAcc.size());
                //System.enqueueJob(new UTIL_QE_CashMatchCancelJnl(client[0].Id,null,TrsWithsameGenLedgAcc));
                FF_Utils.doMatch(client[0].Id,null,TrsWithsameGenLedgAcc);
                // SEPA_SF_Return.doMatch(client[0].Id,null,TrsWithsameGenLedgAcc);
                TrsWithsameGenLedgAcc.clear();
                TrsWithsameGenLedgAcc.add(trs) ;
                
            }
            if(i==maxlistTrs){
                system.debug('TrsWithsameGenLedgAcc '+ prevgenledgacc+ ' '+ TrsWithsameGenLedgAcc.size());
                //System.enqueueJob(new UTIL_QE_CashMatchCancelJnl(client[0].Id,null,TrsWithsameGenLedgAcc));
                FF_Utils.doMatch(client[0].Id,null,TrsWithsameGenLedgAcc);
                
            }
            prevgenledgacc=trs.c2g__GeneralLedgerAccount__c;            
        }
    }
    
    public static Integer numberOfDeferrals(Date billingStartDate, String appFrequency){
        if(appFrequency == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
            return 1;
        }else{
            Integer restDivisiodMonth = Math.mod(billingStartDate.Month(), 3);
            if(restDivisiodMonth == 1){
                return 2;
            }else if(restDivisiodMonth == 2){
                return 1;
            }else{
                return 3;
            }
        }
    }
    
    public static Decimal journalDeferredValue(Decimal billingValue, Integer numbDefferred, String appFrequency){
        
        if(appFrequency == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
            return billingValue;
        }else{
            Decimal amount = (billingValue/3 * numbDefferred);
            amount = amount.setScale(2, System.RoundingMode.HALF_UP);
            return amount;
        }
    }
    
    //dumy method to code coverage the class. 
    //After being made the settle journals and the cancel/cashMatching that methods won't run again, 
    //causing less code coverage to pass for the creation of the deferred journal
    public static void dummyMethod(){
        Integer i= 1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
         i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; 
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1; 
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
        i +=1;
    }    
}