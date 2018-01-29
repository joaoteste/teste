/*

Author   |Date  | Comments
Vinod    |08/31/2017 |t_DoNotDeleteATM Trigger handler class to create Sales Invoice

*/
public class ATMReferenceTriggerHandler{
    //Method called from trigger to insert sales invoice if payment schedule's status is paid 
    public void updatePaymentPlanTable(Set<Id> atmReferenceIds){
        
        System.debug('atmReferenceIds '+atmReferenceIds);
        //Set to store ids of Payment Plan
        Set<ID> paymentPlanIds = new Set<ID>();
        
        //List of payment schedule from trigger fired
        List<Payment_Schedule__c> paymentScheduleList = [SELECT Id, Name, Amount__c, ATM__c, ATM__r.MB_Payment_Status__c, Payment_Status__c, Due_Date__c, Payment_Plan__c, Payment_Plan__r.Collection_Case__r.Account__c FROM Payment_Schedule__c WHERE ATM__c IN: atmReferenceIds];
        System.debug('paymentScheduleList '+paymentScheduleList);
        
        //Create sales invoice and link it to payment schedule if it's ATM Reference's status is Paid 
        for(Payment_Schedule__c objPaymentSchedule : paymentScheduleList){
            paymentPlanIds.add(objPaymentSchedule.Payment_Plan__c);
        }
        
        System.debug('paymentPlanIds '+paymentPlanIds);
        if(paymentPlanIds.size() > 0){
            populatePaymentScheduleTable(paymentPlanIds);
        }
    }
    
    //Populate rich text area with payment schedule table
    public void populatePaymentScheduleTable(Set<Id> paymentPlanIds){
        
        try{
            List<Payment_Plan__c> paymentPlanList = new List<Payment_Plan__c>();
            
            //Query all payment plans to update payment table
            if(paymentPlanIds.size() > 0){
                paymentPlanList = [SELECT Id, Name, Payments_Table__c, (SELECT Id, Name, Due_Date__c, Total_Amount__c, ATM__r.MB_Payment_Status__c, Payment_Status__c FROM Payment_Schedules__r ORDER BY Name ASC) FROM Payment_Plan__c WHERE Id IN: paymentPlanIds];
            }
            
            System.debug('paymentPlanList '+paymentPlanList);
            //Update payment table with payments scheduled
			for(Payment_Plan__c objPlan : paymentPlanList){
                //Variable to maintain serial number of payment scheules
                Integer i=1;
                //Populate rich text field with all values of payments schedule
                /*objPlan.Payments_Table__c = '<table border="1" cellpadding="2" cellspacing="0">'+
                                                    '<tr >'+
                                                        '<th>Nº</th>'+
                                                        '<th>Vencimento </th>'+
                                                        '<th>Valor</th>'+
                                                        '<th>Estado</th>'+
                                                    '</tr>';*/
                
                objPlan.Payments_Table__c = '<table border="0" cellspacing="2" cellpadding="0" style="width:100%;" class="ProductsTable"><tr>' 
                    + '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:20%;" class="ProductsHeader">Nº</th>'
                    + '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Data de Vencimento</th>'                 
                    + '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Valor</th>'
                    +'<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:30%;" class="ProductsHeader">Estado</th>'
                    +'</tr>'; 
                
                for(Payment_Schedule__c objPS : objPlan.Payment_Schedules__r){
                    
                        objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ i +'</td>';
                        objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ String.valueOf(DateTime.newInstance(objPS.Due_Date__c.year(),objPS.Due_Date__c.month(),objPS.Due_Date__c.day()).format('dd/MM/YYYY')) + '</td>';
                        objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ objPS.Total_Amount__c  +'</td>';
                        
                    	if(objPS.Payment_Status__c != null){
                        	objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ convertToPT(objPS.ATM__r.MB_Payment_Status__c)+'</td>';
                    	}else{
                       		objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ convertToPT('Not Paid') +'</td>';
                    	}
                    
                        objPlan.Payments_Table__c +='</tr>';
                    	i++;
                }   
                
                objPlan.Payments_Table__c += '</table>';                   
                    
                
            }
            
            //Update payment plans      
            if(paymentPlanList.size() > 0){
                update paymentPlanList;
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        
    }
    
    public static String convertToPT(String name){
        if(name == 'Not Payed' || name == 'Not Paid' || name == 'In Payment'){
            return 'A Pagar';
        }
        
        if(name == 'Payed' || name == 'Paid'){
            return 'Pago';
        }
        
        return 'ERROR';
        
    }    
}