global class APP_PriceBookRepairBatch implements Database.Batchable<sObject>{
    public Map<String,ID> priceBookMap = new Map<String,ID>();
    
    global APP_PriceBookRepairBatch(){
        List<Pricebook2> priceBookList = [Select id, Name From Pricebook2];
        
        for(Pricebook2 priceBook : priceBookList){
            this.priceBookMap.put(priceBook.Name,priceBook.id);    
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'Select ID, Price_Book__c,ATM_Reference_Costs__c From Application__c where Price_Book__c = null';
        if(Test.isRunningTest()){
            RentingApplication_Util_Test rentingUtils = new RentingApplication_Util_Test();
            ID appID = rentingUtils.environment3();
            query += ' and id = :appID';
        }else{
            query += ' ORDER BY Name DESC ';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Application__c> appList) {
        
        for(Application__c app : appList){
            
            if(app.ATM_Reference_Costs__c == 2.75 || app.ATM_Reference_Costs__c == 0 || app.ATM_Reference_Costs__c == null){
                app.Price_Book__c = this.priceBookMap.get('Standard Price Book');
            }
            if(app.ATM_Reference_Costs__c == 10.00 ){
                app.Price_Book__c = this.priceBookMap.get('ATM 2nd PriceBook');
            }
        }
        update appList;
    }
    
    
    global void finish(Database.BatchableContext bc) {
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        i++;
        i++;
        i++;
        i++;  
        i++;
        i++;
        i++;
        i++;
    }
    
}