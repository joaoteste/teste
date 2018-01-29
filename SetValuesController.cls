public with sharing class SetValuesController {
	
	private ApexPages.StandardController StandardController;

	public SetValuesController(ApexPages.StandardController StandardController) {
		this.StandardController = StandardController;
	}




	public void SetValues(){

        ID appID = StandardController.getId(); 
        Application__c rentingApp = [SELECT Invoice_Value__c,Payment_Amount__c,Rent_12__c,Rent_24__c,Rent_36__c,Rent_48__c,Rent_60__c,
        							Decision__c,Aux_Equipment_Cost__c,Aux_Discount__c,Aux_Rate_Factor__c,Payment_Freq__c,accClient__c,Term__c,Vendor__c,Aux_Payment_Amount__c,Equipment_Cost__c 
        							FROM Application__c
        							 WHERE id=:appID];
        /*							 
		List<Decision__c> decisionList = [Select ID, FactorCard_Discount__c 
								From Decision__c 
								where id = :rentingApp.Decision__c 
								limit 1];
		
		Decision__c decision;
		if(!decisionList.isEmpty()){
			decision = decisionList[0];
		}*/
		
            rentingApp.Payment_Amount__c = rentingApp.Aux_Payment_Amount__c;

            if( rentingApp.term__c == '12'){
                 rentingApp.rent_12__c = rentingApp.Aux_Payment_Amount__c;
            }else if( rentingApp.term__c == '24'){
                 rentingApp.rent_24__c = rentingApp.Aux_Payment_Amount__c;
            }else if( rentingApp.term__c == '36'){
                 rentingApp.rent_36__c = rentingApp.Aux_Payment_Amount__c;
            }else if( rentingApp.term__c == '48'){
                 rentingApp.rent_48__c = rentingApp.Aux_Payment_Amount__c;
            }else if( rentingApp.term__c == '60'){
                 rentingApp.rent_60__c = rentingApp.Aux_Payment_Amount__c;
            }else if( rentingApp.term__c == '72'){							//16/03/17- (BP)
                rentingApp.rent_72__c = rentingApp.Aux_Payment_Amount__c;
            } 

            rentingApp.Equipment_Cost__c = rentingApp.Aux_Equipment_Cost__c;
            rentingApp.Factor__c = rentingApp.Aux_Rate_Factor__c;
            rentingApp.Vendor_Invoice_Amount__c = rentingApp.Aux_Equipment_Cost__c;
            /*if(decision != null && !decisionList.isEmpty()){
            	decision.FactorCard_Discount__c = rentingApp.Aux_Discount__c;
            	update decision;
            }*/
            rentingApp.Discount_Factor__c = rentingApp.Aux_Equipment_Cost__c;
            
            update rentingApp;            
    }

}