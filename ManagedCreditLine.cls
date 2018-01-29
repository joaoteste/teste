public class ManagedCreditLine {
    
    public static void updateCreditLine(Application__c App){
        
        try{
            
            AggregateResult[] groupedResults = [SELECT 	SUM(Equipment_Cost__c)total_equipment
                                                FROM 	Application__c
                                                WHERE 	AccClient__c=:App.AccClient__c AND
                                                Status__c = 'Contract - Running' ];
            
            Object sumEquimentCost = groupedResults[0].get('total_equipment');
            
            Account acc = [SELECT Used_Credit_line__c, Available_Credit_Line__c, Credit_line__c
                           FROM 	Account
                           WHERE 	id=:App.AccClient__c];
            
            acc.Used_Credit_Line__c = (Decimal) sumEquimentCost;
            acc.Available_Credit_Line__c = acc.Credit_line__c - acc.Used_Credit_Line__c;    
            
            if(acc.Available_Credit_Line__c < 0){
                acc.Available_Credit_Line__c = 0;
            }
            

            update acc;
            
            
        }catch(Exception e){
            
            system.Debug('ManagedCreditLine' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            
        }
        
    }
    
}