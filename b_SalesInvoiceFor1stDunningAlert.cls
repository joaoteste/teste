global class b_SalesInvoiceFor1stDunningAlert implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{
  
    public b_SalesInvoiceFor1stDunningAlert(){
    } 
    
    global List<Id> insertedIds = new List<Id>();
    global List<Dunning_Alert__c> newDunningAlert = new List<Dunning_Alert__c>();
    global List<Id> sId_0 = new List<Id>();  
    global List<Id> sId_1 = new List<Id>();  
    global List<Id> sId_2 = new List<Id>();   
    
    global void execute(SchedulableContext SC) {           
        b_SalesInvoiceFor1stDunningAlert b = new b_SalesInvoiceFor1stDunningAlert(); 
        database.executebatch(b,1);        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        if(Test.IsRunningTest())
             return Database.getQueryLocator([SELECT Id, Name, Account__c,Invoices_Due__c, Amount_Claimed__c, Count_Dunning_Alert__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c, Status__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c= false and Flow__c = 'Automatic' limit 1]);
        
        return Database.getQueryLocator([SELECT Id, Name, Account__c,Invoices_Due__c, Amount_Claimed__c, Count_Dunning_Alert__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c, Status__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c= false and Flow__c = 'Automatic' and Count_Dunning_Alert__c = 0 ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Collection_Case__c> cCase){      
        
        //se date actual > data limite do pagamento cria-se reminder seguinte
        Date date_today = date.today();
        
        for(Collection_Case__c cc2 : cCase){
            
            Decimal count_da_aux = cc2.Count_Dunning_Alert__c;
            
            //se nao tiver nenhum alerta, cria-se o primeiro
            if(cc2.Dunning_Alerts__r.isEmpty()){
                if(count_da_aux==0){
                    sId_0.add(cc2.ID);
                    SalesInvoce.Create(sId_0, '1st Reminder');                
                }               
            }          
        }
        sId_0 = new List<Id>(); 
    }
    
    global void finish(Database.BatchableContext BC){
        
    }    
}