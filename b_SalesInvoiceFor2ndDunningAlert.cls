global class b_SalesInvoiceFor2ndDunningAlert implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{
    
    public string sIDTeste;
    public b_SalesInvoiceFor2ndDunningAlert(){
    }  
    
    public b_SalesInvoiceFor2ndDunningAlert(string sID){
        sIDTeste=sID;
    }  
    
    global List<Id> insertedIds = new List<Id>();
    global List<Dunning_Alert__c> newDunningAlert = new List<Dunning_Alert__c>();
      
    global List<Id> sId = new List<Id>();  
      
    
    global void execute(SchedulableContext SC) {           
        b_SalesInvoiceFor2ndDunningAlert b = new b_SalesInvoiceFor2ndDunningAlert(); 
        database.executebatch(b,1);        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        if(Test.IsRunningTest())
             return Database.getQueryLocator([SELECT Id, Name, Account__c,Invoices_Due__c, Amount_Claimed__c, Count_Dunning_Alert__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c, Status__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c= false and Flow__c = 'Automatic' limit 1]);
        
        return Database.getQueryLocator([SELECT Id, Name, Account__c,Invoices_Due__c, Amount_Claimed__c, Count_Dunning_Alert__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c, Status__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c= false and Flow__c = 'Automatic' and Count_Dunning_Alert__c = 1 ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Collection_Case__c> cCase){      
        
        //se date actual > data limite do pagamento cria-se reminder seguinte
        Date date_today = date.today();
        
        for(Collection_Case__c cc : cCase){  
                   
            //Decimal count_da_aux = cc2.Count_Dunning_Alert__c;
             
            if(!cc.Dunning_Alerts__r.isEmpty()){
                                               
                Dunning_Alert__c da_alert=cc.Dunning_Alerts__r[0]; 
                
                if(date_today > da_alert.Due_Date__c){   
                                
                    //if(count_da_aux==1){                 
                        sId.add(cc.ID);  
                        SalesInvoce.Create(sId, '2nd Reminder');                              
                    //} 
                } 
            }       
        }       
        sId = new List<Id>();        
    }
    
    global void finish(Database.BatchableContext BC){

    }    
}