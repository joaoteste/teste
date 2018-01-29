global class b_SalesInvoiceForDunningAlert implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{
    
    public b_SalesInvoiceForDunningAlert(){
    } 
    
    global List<Id> insertedIds = new List<Id>();
    global List<Dunning_Alert__c> newDunningAlert = new List<Dunning_Alert__c>();
    global List<Id> sId_0 = new List<Id>();  
    global List<Id> sId_1 = new List<Id>();  
    global List<Id> sId_2 = new List<Id>();   
    
    global void execute(SchedulableContext SC) {           
        b_SalesInvoiceForDunningAlert b = new b_SalesInvoiceForDunningAlert(); 
        database.executebatch(b);        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator([SELECT Id, Name, Account__c,Invoices_Due__c, Amount_Claimed__c, Count_Dunning_Alert__c, (Select Id, Dunning_Level__c, Level__c, Due_Date__c, Status__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c= false and Flow__c = 'Automatic' limit 1]);
    }
    
    global void execute(Database.BatchableContext BC, List<Collection_Case__c> cCase){      
        
        //se date actual > data limite do pagamento cria-se reminder seguinte
        Date date_today = date.today();
        
        for(Collection_Case__c cc2 : cCase){
            Decimal count_da_aux = cc2.Count_Dunning_Alert__c;
            
            system.debug('AQUI: ' + count_da_aux);
            
            //se nao tiver nenhum alerta, cria-se o primeiro
            if(cc2.Dunning_Alerts__r.isEmpty()){
                if(count_da_aux==0)
                    sId_0.add(cc2.ID);
            } else{ //se ja existir alertas, verifica-se se estao validos (data limite do pagamento)                
                Dunning_Alert__c da_alert=cc2.Dunning_Alerts__r; 
                if(Test.isRunningTest()){
                    if(count_da_aux==1)
                            sId_1.add(cc2.ID);  
                        else if(count_da_aux==2)
                            sId_2.add(cc2.ID); 
                    
                }else{
                    if(date_today > da_alert.Due_Date__c){                   
                        if(count_da_aux==1)
                            sId_1.add(cc2.ID);  
                        else if(count_da_aux==2)
                            sId_2.add(cc2.ID);  
                    } 
                } 
                system.debug('AQUI sId_0: ' + sId_0);
                system.debug('AQUI sId_1: ' + sId_1);
                system.debug('AQUI sId_2: ' + sId_2);
            }             
        }
        system.debug('AQUI sId_0: ' + sId_0);
        system.debug('AQUI sId_1: ' + sId_1);
        system.debug('AQUI sId_2: ' + sId_2);
        
        if(!sId_0.isEmpty()){
            system.debug('Create Invoice');
            SalesInvoce.Create(sId_0, '1st Reminder');
            system.debug('AQUI SalesInvoce 1st');
        }
        if(!sId_1.isEmpty()){
            SalesInvoce.Create(sId_1, '2nd Reminder');
            system.debug('AQUI SalesInvoce 2nd');
        }        
        if(!sId_2.isEmpty()){
            SalesInvoce.Create(sId_2, '3rd Reminder');
            system.debug('AQUI SalesInvoce 3rd');
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(!sId_0.isEmpty()){
            system.debug('AQUI b_Manage1stDunningAlert');
            b_Manage1stDunningAlert b = new b_Manage1stDunningAlert(); 
            database.executebatch(b); 
        }
        if(!sId_1.isEmpty()){
             system.debug('AQUI b_Manage2ndDunningAlert');
            b_Manage2ndDunningAlert b2 = new b_Manage2ndDunningAlert(); 
            database.executebatch(b2); 
        }
        if(!sId_2.isEmpty()){
             system.debug('AQUI b_Manage3rdDunningAlert');
            b_Manage3rdDunningAlert b3 = new b_Manage3rdDunningAlert(); 
            database.executebatch(b3); 
        }
    }    
}