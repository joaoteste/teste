global class b_ManageATMReference implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{

    public b_ManageATMReference(){
    } 
  
    global void execute(SchedulableContext SC) {           
        b_ManageATMReference b = new b_ManageATMReference(); 
        database.executebatch(b,1);       
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator([SELECT Id, Sent_Date__c, Amount_Claimed__c, Due_Date__c From Dunning_Alert__c where Status__c = 'Open' and Flow__c = 'Automatic']);
    }
    
    global void execute(Database.BatchableContext BC, List<Dunning_Alert__c> cDunning){     
        Date date_today = date.today();
        
        List<ATM_Reference__c> listATM = new List<ATM_Reference__c>();
        for(Dunning_Alert__c da : cDunning){ 

            if(date_today == da.Sent_Date__c){
                system.debug('AQUI = ');
                Bill_EasyPayAPI billEasyPay = new Bill_EasyPayAPI();
                if(!Test.isRunningTest()){
                    listATM.add(billEasyPay.getNewMBReference(String.ValueOf(da.Amount_Claimed__c), Date.valueOf(da.Due_Date__c), da.id, 'DunningAlert'));
               }else{
                   ATM_Reference__c atm = new ATM_Reference__c();
                   listATM.add(atm);
              
               }
           }
        }
        if(!listATM.isEmpty()){  
            system.debug('AQUI listATM ' + listATM);
            try{
                insert listATM;
                
                PaymentCollection_Utils pcUtils = new PaymentCollection_Utils();
                pcUtils.createPaymentCollectionWithATM(listATM);
             
            }catch(Exception e){
                system.debug('Erro EasyPay');          
            }            
        }
    }
    
    global void finish(Database.BatchableContext BC){
   
    }
}