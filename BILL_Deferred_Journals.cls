public class BILL_Deferred_Journals {
    
    public void Create_Deferred_Journals(set<Id> journals){
        system.debug(journals.size());
        Set<Id> jnlIds=New Set<Id>();
        integer RECUR_JN_FRQ=1;
        c2g__codaPeriod__c periodNewRecurJnl=new c2g__codaPeriod__c();
        c2g__codaPeriod__c NextperiodRecurJnl=new c2g__codaPeriod__c();
        date newPeriodStartDate=null;
        date newPeriodEndDate=null;
        decimal remainval=0; 
        decimal quartervalue=0;
        decimal remainvalProp=0;
        decimal quartervalueProp=0;
        id recurrSrcJnl=null;
        id prvrecurrSrcJnl=null;
        id prvNewJnl=null;
        integer COUNTER=0;
        Savepoint sp = null;
        
        //try{
        
        //journals to be deferred
        List<c2g__codaJournal__c> lstSrcjournal =New List<c2g__codaJournal__c>([select id, name, c2g__JournalDate__c, c2g__JournalDescription__c,
                                                                                c2g__JournalStatus__c,c2g__Period__c, sales_invoice__c, c2g__reference__c,
                                                                                Billing_Contract_Line_Item__r.application__r.Payment_Freq__c, 
                                                                                Billing_Contract_Line_Item__r.name, to_be_deferred__c, Deferred_Type__c 
                                                                                from c2g__codaJournal__c
                                                                                where id in :journals and c2g__Type__c = 'Manual Journal' 
                                                                                and to_be_deferred__c = true and c2g__JournalStatus__c ='Complete' and c2g__CanceledJournal__c = false
                                                                                 and (TypeDescription__c = 'Interest' or TypeDescription__c = 'Insurance' or TypeDescription__c = 'Proportional Insurance')]);
        if(lstSrcjournal == null || lstSrcjournal.size()==0){
            return;
        }
        
        List<Accounting_Admin__c> defJnAdmin = [select  Config_Name__c,  General_Ledger_Account__c, Description__c, Operation__c, Type__c, General_Ledger_Account_Orig__c
                                                from Accounting_Admin__c 
                                                where Config_Name__c in ('Deferred Proportional Insurance' , 'Deferred Journal')];
        
        
        map<id, id> configmapdefprop= new map<id, id>();
        map<id, id> configmapdef= new map<id, id>();
        
        //map the defJnAdmin into 2 map: deferredJournal and deferred proportional insurance
        for ( Accounting_Admin__c cfgadmin :defJnAdmin){
            if(cfgadmin.Config_Name__c=='Deferred Journal'){
                configmapdef.put(cfgadmin.General_Ledger_Account_Orig__c,cfgadmin.General_Ledger_Account__c);
            }
            if(cfgadmin.Config_Name__c=='Deferred Proportional Insurance'){
                configmapdefprop.put(cfgadmin.General_Ledger_Account_Orig__c,cfgadmin.General_Ledger_Account__c);
            }
            
        } 
        
        Boolean runningTest = !Test.isRunningTest();
        System.debug('Not runningTest ' +runningTest);
        
        
        List< c2g.RecurringJournalService.RecurringJournal> lstRecJournal = New List< c2g.RecurringJournalService.RecurringJournal>();
        List<c2g__codajournal__c> lstNewJournal=New List<c2g__codajournal__c>();
        List<c2g__codaJournalLineItem__c> lstNewJournalItem=new List<c2g__codaJournalLineItem__c>();
        
        sp = Database.setSavepoint();
        // gera lista de journal a criar
        string descriptionEnd=null;
        integer monthDelCertSigned=0;
        integer monthSalesInvoice=0;
        
        //create newJournals based on source list lstSrcjournal
        for (integer i=0; i< lstSrcjournal.size() ; i++ ){
            //??? delete previous rec details
            //system.debug('lstRecDetailsClear '+lstRecDetails);
            List<c2g.RecurringJournalService.RecurringJournalDetails> lstRecDetails = New List<c2g.RecurringJournalService.RecurringJournalDetails>();
            RECUR_JN_FRQ = 1;
            //newRecurJnDtl = new c2g.RecurringJournalService.RecurringJournalDetails();
            if(lstSrcjournal[i].Deferred_Type__c==0 || lstSrcjournal[i].Deferred_Type__c == null){
                if(lstSrcjournal[i].Billing_Contract_Line_Item__r.application__r.Payment_Freq__c=='Quarterly'){
                    RECUR_JN_FRQ=3;
                }
            }else{
                // Delivery_Certificate_Signed__c field used to calculate Interim fee days, to check if the all value 
                // should be deferred check this date against invoice date
                RECUR_JN_FRQ=integer.ValueOf(lstSrcjournal[i].Deferred_Type__c);

            }  
            c2g.RecurringJournalService.RecurringJournal newRecurJn=new c2g.RecurringJournalService.RecurringJournal();
            c2g.RecurringJournalService.RecurringJournalDetails newRecurJnDtl= new c2g.RecurringJournalService.RecurringJournalDetails(); 
            periodNewRecurJnl=UTIL_NextPeriod.getNextnPeriod(lstSrcjournal[i].c2g__Period__c,1);
            newRecurJn.setSourceJournal(lstSrcjournal[i]);
            newRecurJnDtl.setSourceJournalId(lstSrcjournal[i].Id);
            newRecurJnDtl.setJournalDate(periodNewRecurJnl.c2g__StartDate__c);
            newRecurJnDtl.setJournalPeriod(periodNewRecurJnl.id); 
            newRecurJnDtl.setJournalDescription('Deferred ' + lstSrcjournal[i].c2g__JournalDescription__c );
            
            lstRecDetails.add(newRecurJnDtl);

            newRecurJn.setRecurringDetails(lstRecDetails);
            //number of recurring 
            for(integer j=0; j< RECUR_JN_FRQ; j++){
                lstRecJournal.add(newRecurJn);
            }

            lstSrcjournal[i].to_be_deferred__c=false;
        }
        //update the source journals to not be deferred
        update lstSrcjournal;

        //here is where the journal are created based on the source journals. the lstRecJournal contains the list of new recurring journal added previouly
        // isRunnningTest Necessary because FF API not running in Apex Text Context
        if(!Test.isRunningTest()){
            lstNewJournal=c2g.RecurringJournalService.buildJournalList(lstRecJournal);
        }
        else{
            lstNewJournal= dataTest();
            //lstNewJournal=c2g.RecurringJournalService.buildJournalList(lstRecJournal);
        }
                
        if(lstNewJournal == null || lstNewJournal.size() == 0){
            return;
        }
        
        lstNewJournalItem=[select id,c2g__GeneralLedgerAccount__r.name, c2g__Value__c,c2g__LineDescription__c ,c2g__GeneralLedgerAccount__c,c2g__Journal__r.TypeDescription__c,
                           c2g__Journal__r.Billing_Contract_Line_Item__r.application__r.Payment_Freq__c, c2g__Journal__r.c2g__recurringjournalsourcejournal__c, 
                           c2g__lineNumber__c, c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c
                           from c2g__codaJournalLineItem__c where c2g__Journal__c in :lstNewJournal order by c2g__Journal__c, c2g__Journal__r.c2g__recurringjournalsourcejournal__c];
        
        //for every "new"journal with will created the corresponding line items
        
        for(integer h=0; h< lstNewJournal.size(); h++){
            if(prvrecurrSrcJnl==null || lstNewJournal[h].c2g__recurringjournalsourcejournal__c !=prvrecurrSrcJnl ) {
                COUNTER=0;
            }        
            else{
                COUNTER++;
            }
            if(lstNewJournal[h].TypeDescription__c != null){
                lstNewJournal[h].TypeDescription__c = 'Deferral ' + lstNewJournal[h].TypeDescription__c;
            }
            if(COUNTER>0){
                NextperiodRecurJnl=UTIL_NextPeriod.getNextnPeriod(lstNewJournal[h].c2g__period__c, COUNTER);  
                lstNewJournal[h].c2g__period__c =NextperiodRecurJnl.id; 
                lstNewJournal[h].c2g__journalDate__c=NextperiodRecurJnl.c2g__StartDate__C;
            }
            
            //create journal items
            for(integer l=0; l< lstNewJournalItem.size(); l++){
                //if the journal item has the same id as the journal
                if(lstNewJournalItem[l].c2g__Journal__c==lstNewJournal[h].id){
                    //if is quarterly and Deferred_Type__c=0   
                    if(lstNewJournalItem[l].c2g__Journal__r.Billing_Contract_Line_Item__r.application__r.Payment_Freq__c=='Quarterly' 
                       && (lstNewJournalItem[l].c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c==0 ||
                           lstNewJournalItem[l].c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c== null)
                      ){
                          /*quartervalue=(lstNewJournalItem[l].c2g__Value__c/3).setscale(2);

if(quartervalue*3 !=lstNewJournalItem[l].c2g__Value__c){
remainval=lstNewJournalItem[l].c2g__Value__c - quartervalue*3;
}

if(COUNTER==0){
lstNewJournalItem[l].c2g__Value__c= quartervalue+remainval;
}
else{
lstNewJournalItem[l].c2g__Value__c=quartervalue;
}
*/
                          
                          lstNewJournalItem[l].c2g__Value__c = getDeferredValue(lstNewJournalItem[l].c2g__Value__c,h, 3, lstNewJournalItem[l].c2g__Journal__r.Billing_Contract_Line_Item__r.application__r.Payment_Freq__c);
                          
                          remainval=0;
                          quartervalue=0;        
                      }
                    //Deferred_Type__c!=0
                    if(lstNewJournalItem[l].c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c!=0 && 
                       lstNewJournalItem[l].c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c!= null){
                           
                           decimal defcount=lstNewJournalItem[l].c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c;
                           if(defcount!=1){
                               /*quartervalueProp= (lstNewJournalItem[l].c2g__Value__c/defcount).setscale(2);

if(quartervalueProp*defcount !=lstNewJournalItem[l].c2g__Value__c){
remainvalProp=lstNewJournalItem[l].c2g__Value__c - quartervalueProp*defcount;
}


if(COUNTER==0){
lstNewJournalItem[l].c2g__Value__c= quartervalueProp+remainvalProp;
}
else{
lstNewJournalItem[l].c2g__Value__c=quartervalueProp;
}*/
                               System.debug('lll '+ l);                              
                               lstNewJournalItem[l].c2g__Value__c = getDeferredValue(lstNewJournalItem[l].c2g__Value__c,h, defcount, lstNewJournalItem[l].c2g__Journal__r.Billing_Contract_Line_Item__r.application__r.Payment_Freq__c);
                               System.debug('remainvalProp');
                           }
                           
                           remainvalProp=0;
                           quartervalueProp=0;        
                           
                       }
                    
                    //add the generalLedgerAccount based on map
                    if(lstNewJournalItem[l].c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c==0 ||
                       lstNewJournalItem[l].c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c==null){
                           lstNewJournalItem[l].c2g__GeneralLedgerAccount__c=configmapdef.get(lstNewJournalItem[l].c2g__GeneralLedgerAccount__c); 
                       }
                    
                    if(lstNewJournalItem[l].c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c!=0 && 
                       lstNewJournalItem[l].c2g__Journal__r.c2g__recurringjournalsourcejournal__r.Deferred_Type__c!=null){
                           if(lstNewJournalItem[l].c2g__Journal__r.TypeDescription__c == 'Deferral Proportional Insurance'){
                               lstNewJournalItem[l].c2g__GeneralLedgerAccount__c=configmapdefprop.get(lstNewJournalItem[l].c2g__GeneralLedgerAccount__c); 
                           }else{
                               lstNewJournalItem[l].c2g__GeneralLedgerAccount__c=configmapdef.get(lstNewJournalItem[l].c2g__GeneralLedgerAccount__c); 
                           }
                       }
                    
                }
                prvNewJnl=lstNewJournalItem[l].c2g__Journal__c;
            }
            prvrecurrSrcJnl= lstNewJournal[h].c2g__recurringjournalsourcejournal__c;
            jnlIds.add(lstNewJournal[h].id);
        }
        
        System.debug('JournalNew '+ lstNewJournal);
        update lstNewJournal;
        update lstNewJournalItem;
        UTIL_CancelAndCreateJournals.postJournal(jnlIds);
        //for now leave only for tests commented ***** POST
        // Bill_BillingProcess.postJournal(jnlIds);
        
        
        /*    }
catch(exception e){
Database.rollback(sp);
System.Debug('BILL_CreateDeferredJournals - Error ');
system.Debug(logginglevel.DEBUG, e.getLineNumber() + ' ' + e.getStackTraceString() + ' ' + e.getMessage() + '' );
}*/
    }
    
    public static Decimal getDeferredValue(Decimal deferredTotalValue,Integer currentPeriod, Decimal numbDefferred, String appFrequency){
        
        if(appFrequency == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
            System.debug('deferredTotalValueMonthly '+deferredTotalValue);
            return deferredTotalValue;
        }else{
            
            Decimal amount =  deferredTotalValue / numbDefferred ;
            amount = amount.setScale(2, System.RoundingMode.HALF_UP);
            
            if(currentPeriod != numbDefferred){
                System.debug('deferredTotalValueTrim '+amount);
                return amount;
            }else{
                Decimal amountRest = (deferredTotalValue - amount*(numbDefferred-1));
                System.debug('deferredTotalValueTrimRestante '+amountRest);
                return amountRest;
            }
        }
        
    }
    
    private static List<c2g__codajournal__c> dataTest()
    {
        List<c2g__codajournal__c> lstNewJournal = new List<c2g__codajournal__c>();
        
        c2g__codaJournal__c testRecuringJournal1 = new c2g__codaJournal__c();
        testRecuringJournal1.c2g__JournalDate__c = Date.newInstance(2017,06,28);
        testRecuringJournal1.Deferred_Type__c = 3;
        insert testRecuringJournal1;
        System.debug('[BILL_Deferred_Journals].Create_Deferred_Journals --> testRecuringJournal1: ]'+testRecuringJournal1);
        
        c2g__codaJournal__c testRecuringJournal2 = new c2g__codaJournal__c();
        testRecuringJournal2.c2g__JournalDate__c = Date.newInstance(2017,06,28);
        testRecuringJournal2.Deferred_Type__c = 1;
        insert testRecuringJournal2;
        System.debug('[BILL_Deferred_Journals].Create_Deferred_Journals --> testRecuringJournal2: ]'+testRecuringJournal2);

        c2g__codaJournal__c testJournal1 = new c2g__codaJournal__c();
        testJournal1.c2g__JournalDate__c = Date.newInstance(2017,06,28);
        testJournal1.c2g__recurringjournalsourcejournal__c = testRecuringJournal1.ID;
        testJournal1.TypeDescription__c = 'Interest';
        insert testJournal1;
        System.debug('[BILL_Deferred_Journals].Create_Deferred_Journals --> testJournal1: ]'+testJournal1);
        
        c2g__codaJournal__c testJournal2 = new c2g__codaJournal__c();
        testJournal2.c2g__JournalDate__c = Date.newInstance(2017,06,28);
        testJournal2.c2g__recurringjournalsourcejournal__c = testRecuringJournal2.ID;
        testJournal2.TypeDescription__c = 'Insurance';
        insert testJournal2;
        System.debug('[BILL_Deferred_Journals].Create_Deferred_Journals --> testJournal2: ]'+testJournal2);
        
        c2g__codaJournalLineItem__c  testJLI1 = new c2g__codaJournalLineItem__c();
        testJLI1.c2g__Journal__c = testJournal1.ID;
        testJLI1.c2g__GeneralLedgerAccount__c= [SELECT ID 
                                                FROM c2g__codaGeneralLedgerAccount__c 
                                                WHERE Name='7816 - OUTROS DÉBITOS RELACIONADOS COM O ALUGUER'].ID;
        testJLI1.c2g__LineType__c ='General Ledger Account';
        testJLI1.c2g__Value__c=-5.30;
        insert testJLI1;
        System.debug('[BILL_Deferred_Journals].Create_Deferred_Journals --> testJLI1 (1.1): ]'+testJLI1);
        
        //System.assertNotEquals(null, testJLI1.ID,'[BILL_Deferred_Journals].Create_Deferred_Journals --> testJLI1 não foi inserido...');
        c2g__codaJournalLineItem__c  testJLI2 = new c2g__codaJournalLineItem__c();
        testJLI2.c2g__Journal__c = testJournal1.ID;
        testJLI2.c2g__GeneralLedgerAccount__c= [SELECT ID 
                                                FROM c2g__codaGeneralLedgerAccount__c 
                                                WHERE Name='2822 - DIFERIMENTO SEGURO'].ID;
        testJLI2.c2g__LineType__c ='General Ledger Account';
        testJLI2.c2g__Value__c=5.30;
        insert testJLI2;
        System.debug('[BILL_Deferred_Journals].Create_Deferred_Journals --> testJLI2 (1.2): ]'+testJLI2);

        c2g__codaJournalLineItem__c  testJLI3 = new c2g__codaJournalLineItem__c();
        testJLI3.c2g__Journal__c = testJournal2.ID;
        testJLI3.c2g__GeneralLedgerAccount__c= [SELECT ID 
                                                FROM c2g__codaGeneralLedgerAccount__c 
                                                WHERE Name='7816 - OUTROS DÉBITOS RELACIONADOS COM O ALUGUER'].ID;
        testJLI3.c2g__LineType__c ='General Ledger Account';
        testJLI3.c2g__Value__c=-9.30;
        insert testJLI3;
        System.debug('[BILL_Deferred_Journals].Create_Deferred_Journals --> testJLI3 (2.1): ]'+testJLI3);
        
        //System.assertNotEquals(null, testJLI1.ID,'[BILL_Deferred_Journals].Create_Deferred_Journals --> testJLI1 não foi inserido...');
        c2g__codaJournalLineItem__c  testJLI4 = new c2g__codaJournalLineItem__c();
        testJLI4.c2g__Journal__c = testJournal2.ID;
        testJLI4.c2g__GeneralLedgerAccount__c= [SELECT ID 
                                                FROM c2g__codaGeneralLedgerAccount__c 
                                                WHERE Name='2822 - DIFERIMENTO SEGURO'].ID;
        testJLI4.c2g__LineType__c ='General Ledger Account';
        testJLI4.c2g__Value__c=9.30;
        insert testJLI4;
        System.debug('[BILL_Deferred_Journals].Create_Deferred_Journals --> testJLI4 (2.2): ]'+testJLI4);

        lstNewJournal.add(testJournal1);
        lstNewJournal.add(testJournal2);
        return lstNewJournal;
    }
}