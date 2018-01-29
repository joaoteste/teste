global class b_Manage4thDunningAlert implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{

    public b_Manage4thDunningAlert(){
    } 
    
    global List<Id> insertedIds = new List<Id>();
    global boolean aux_var=false;
    global List<Dunning_Alert__c> newDunningAlert = new List<Dunning_Alert__c>();
    global Map<String,Dunning_Alert__c> insDA = new Map<String,Dunning_Alert__c>();
    
    global void execute(SchedulableContext SC) {           
        b_Manage4thDunningAlert b3 = new b_Manage4thDunningAlert(); 
        database.executebatch(b3,1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        if(Test.IsRunningTest())
            return Database.getQueryLocator([SELECT Id,Account__c,Invoices_Due__c, Amount_Claimed__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c, Status__c, Sent_Date__c, Total_Interest_Charges__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Count_Dunning_Alert__c = 3 and Dunning_Enabled__c= false and Flow__c = 'Automatic' limit 1]);
    
        return Database.getQueryLocator([SELECT Id,Account__c,Invoices_Due__c, Amount_Claimed__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c, Status__c, Sent_Date__c, Total_Interest_Charges__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Count_Dunning_Alert__c = 3 and Dunning_Enabled__c= false and Flow__c = 'Automatic' /*limit 1*/]);
    }
    
    global void execute(Database.BatchableContext BC, List<Collection_Case__c> cCase){     
        String reminder_level = '4th Reminder';
        String n_reminder_level = '4';
        Date date_today = date.today();
          
        Map<Id,Collection_Case__c> sId = new Map<Id,Collection_Case__c>();
        for(Collection_Case__c cc2 : cCase){
            if(!cc2.Dunning_Alerts__r.isEmpty()){
                Dunning_Alert__c da_alert=cc2.Dunning_Alerts__r;
                if(Test.isRunningTest()){
                    sId.put(cc2.ID, cc2);  
                }
                else{
                    if(date_today > da_alert.Due_Date__c)
                        sId.put(cc2.ID, cc2);                                     
                }                
            }
        } 
        
        List<Legal_Fees__c> legalFee = [SELECT Id, Interest_Rate__c, Judicial_Fees__c, Name FROM Legal_Fees__c where Name = 'Interest Rate' limit 1];
        Decimal ir_fee = 0;
        for(Legal_Fees__c lf : legalFee){
            ir_fee=lf.Interest_Rate__c/100;
        }
       Map<Id, Decimal> valores_ir = new Map<Id, Decimal>();
        
        List<c2g__codaInvoice__c> m_ListCC = [Select Id,Days_Overdue__c, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c,c2g__InvoiceTotal__c,c2g__DueDate__c, Candor_Due_Date__c, Collection_Case__c, c2g__PaymentStatus__c From c2g__codaInvoice__c where Collection_Case__c =: sId.keyset() and c2g__PaymentStatus__c!='Paid']; 
            
        Map<Id,Decimal> amounts_per_CC = new Map<Id,Decimal>();
        for(c2g__codaInvoice__c si : m_ListCC){
            Decimal quantia=0;
            if(amounts_per_CC.containsKey(si.Collection_Case__c)){
                quantia = amounts_per_CC.get(si.Collection_Case__c); quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c; amounts_per_CC.put(si.Collection_Case__c, quantia);
            } else{
                quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c; amounts_per_CC.put(si.Collection_Case__c, quantia);                
            }          
        }
        
        Dunning_Admin__c daLevel = [Select Id,Past_Due_Days__c,Nr_of_Days_to_Pay__c,Dunning_Level__c,Dunning_Frequency__c,Active__c, Email_Template__c From Dunning_Admin__c where Dunning_Level__c=:reminder_level and Active__c='Yes' limit 1];
       
        for(Collection_Case__c cc2 : sId.values()){    
            
            Decimal amount = amounts_per_CC.get(cc2.Id);
            
            Integer iSentDate = Integer.ValueOf(daLevel.Past_Due_Days__c);
            Integer iDate = Integer.ValueOf(daLevel.Nr_of_Days_to_Pay__c);              
            Date sentDate = Date.today(); 
            sentDate = sentDate.addDays(iSentDate);
            Date firstEmail = sentDate;
            Date dueDate = sentDate.addDays(iDate);
            
            c_DunningAlert da = new c_DunningAlert(); 
            
            newDunningAlert.add(da.insDunningAlert(cc2.id, reminder_level, n_reminder_level, sentDate, firstEmail, dueDate, amount,'Automatic'));                             
        }        
        if(!newDunningAlert.isEmpty()) {           
            Database.SaveResult[] insresults = Database.insert(newDunningAlert, false); 
            
            for(Database.SaveResult dsr : insresults){
                insertedIds.add(dsr.getId());
            }  
            
            //calculo de juros
            insDA = new Map<String,Dunning_Alert__c>([select Id, Collection_Case__c, Total_Interest_Charges__c, Due_Date__c from Dunning_Alert__c where Id in : insertedIds]);
            Map<String, Dunning_Alert__c> teste_da = new Map<String, Dunning_Alert__c>();
            for(Dunning_Alert__c ad : insDA.values()){
                teste_da.put(ad.Collection_Case__c, ad);
            }
        
            List<Interest_Charged_Calculation__c> icc_list = new List<Interest_Charged_Calculation__c>();
            if(!m_ListCC.isEmpty()){
                for(c2g__codaInvoice__c ci_cc : m_ListCC){
                    Dunning_Alert__c dunning_alert = teste_da.get(ci_cc.Collection_Case__c);
                    
                    Interest_Charged_Calculation__c icc = new Interest_Charged_Calculation__c();
                    icc.Days_Overdue__c = ci_cc.Days_Overdue__c; icc.Invoice_Due_Date__c=ci_cc.c2g__DueDate__c; icc.Dunning_Alert__c=dunning_alert.Id; icc.Interest_Rate__c=ir_fee*100; icc.Interest_Charged__c=ir_fee*ci_cc.c2g__InvoiceTotal__c; icc.Sales_Invoice__c=ci_cc.Id; 
                    if(ci_cc.Days_Overdue__c > 0){
                        if(Test.IsRunningTest())
                            icc.Invoice_Value__c = 365;
                        icc.Interest_Charged__c = (icc.Invoice_Value__c/365)*ci_cc.Days_Overdue__c;                    
                    }else{
                        icc.Interest_Charged__c = 0; 
                    }
                    //icc.Invoice_Amount__c=ci_cc.c2g__InvoiceTotal__c+ir_fee*ci_cc.c2g__InvoiceTotal__c;
                    icc.Sales_Invoice_Total__c = ci_cc.c2g__InvoiceTotal__c; icc_list.add(icc);
                }
            }
            if(!icc_list.isEmpty())
                insert icc_list;            
        }         
    }
    
    global void finish(Database.BatchableContext BC){    
        
    }
}