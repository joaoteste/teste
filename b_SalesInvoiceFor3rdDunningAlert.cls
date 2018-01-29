global class b_SalesInvoiceFor3rdDunningAlert implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{
    
    public b_SalesInvoiceFor3rdDunningAlert(){
    } 
    
    global List<Id> sId = new List<Id>();   
    
    global void execute(SchedulableContext SC) {           
        b_SalesInvoiceFor3rdDunningAlert b = new b_SalesInvoiceFor3rdDunningAlert(); 
        database.executebatch(b,1);        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        if(Test.IsRunningTest())
             return Database.getQueryLocator([SELECT Id, Name, Account__c,Invoices_Due__c, Amount_Claimed__c, Count_Dunning_Alert__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c, Status__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c= false and Flow__c = 'Automatic' and Count_Dunning_Alert__c = 2 limit 1]);
        
        return Database.getQueryLocator([SELECT Id, Name, Account__c,Invoices_Due__c, Amount_Claimed__c, Count_Dunning_Alert__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c, Status__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c= false and Flow__c = 'Automatic' and Count_Dunning_Alert__c = 2 ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Collection_Case__c> cCase){      
        
        //se date actual > data limite do pagamento cria-se reminder seguinte
        Date date_today = date.today();
        
        for(Collection_Case__c cc : cCase){            
            if(!cc.Dunning_Alerts__r.isEmpty()){
                Dunning_Alert__c da_alert = cc.Dunning_Alerts__r[0]; 
                system.debug('AQUI da_alert ' + da_alert);
                if(date_today > da_alert.Due_Date__c){          
                    sId.add(cc.ID);
                    SalesInvoce.Create(sId, '3rd Reminder');
                }
            }   
        } 
        sId = new List<Id>(); 
    }
    
    global void finish(Database.BatchableContext BC){
       
    }    
}