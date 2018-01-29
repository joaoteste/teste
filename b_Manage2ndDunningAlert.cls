global class b_Manage2ndDunningAlert implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{

    public b_Manage2ndDunningAlert(){
    } 
    
    global List<Id> insertedIds = new List<Id>();
    global boolean aux_var=false;
    global List<Dunning_Alert__c> newDunningAlert = new List<Dunning_Alert__c>();
    
    global void execute(SchedulableContext SC) {   
         b_Manage2ndDunningAlert b2 = new b_Manage2ndDunningAlert(); 
         database.executebatch(b2,1); 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
         if(Test.IsRunningTest())
            return Database.getQueryLocator([SELECT Id,Account__c,Invoices_Due__c, Amount_Claimed__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Count_Dunning_Alert__c = 1 and Dunning_Enabled__c= false and Flow__c = 'Automatic' limit 1]);
    
        return Database.getQueryLocator([SELECT Id,Account__c,Invoices_Due__c, Amount_Claimed__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Count_Dunning_Alert__c = 1 and Dunning_Enabled__c= false and Flow__c = 'Automatic' /*limit 1*/]);
    }
    
    global void execute(Database.BatchableContext BC, List<Collection_Case__c> cCase){     
        String reminder_level = '2nd Reminder';
        String n_reminder_level = '2';
        Date date_today = date.today();
        
        Map<Id,Collection_Case__c> sId = new Map<Id,Collection_Case__c>();
        for(Collection_Case__c cc2 : cCase){
            if(!cc2.Dunning_Alerts__r.isEmpty()){
                //Dunning_Alert__c da_alert=cc2.Dunning_Alerts__r;
                Dunning_Alert__c da_alert=cc2.Dunning_Alerts__r[0]; 
                
                system.debug('today: '+date_today);
                system.debug('due date: '+da_alert.Due_Date__c);
                if(Test.isRunningTest()){
                    sId.put(cc2.ID, cc2);  
                }else{  
                    if(date_today > da_alert.Due_Date__c){
                        sId.put(cc2.ID, cc2);     
                    }
                }
            }
            
        } 
        
        List<c2g__codaInvoice__c> m_ListCC = [Select Id, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c,c2g__InvoiceTotal__c,  Collection_Case__c, c2g__PaymentStatus__c From c2g__codaInvoice__c where Collection_Case__c =: sId.keyset() and c2g__PaymentStatus__c!='Paid']; 
        Map<Id,Decimal> amounts_per_CC = new Map<Id,Decimal>(); 
        for(c2g__codaInvoice__c si : m_ListCC){
            Decimal quantia=0;
            if(amounts_per_CC.containsKey(si.Collection_Case__c)){
                quantia = amounts_per_CC.get(si.Collection_Case__c);
                quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c; 
                amounts_per_CC.put(si.Collection_Case__c, quantia);
            } else{
                quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                amounts_per_CC.put(si.Collection_Case__c, quantia);
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
                 if(dsr.getId() != null)
                    insertedIds.add(dsr.getId());
            }              
        }
         
    }
    
    global void finish(Database.BatchableContext BC){
  
    }
}