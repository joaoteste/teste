public with sharing class AuxCalcController {

private ApexPages.StandardController StandardController;

public AuxCalcController(ApexPages.StandardController StandardController)
    {
        this.StandardController = StandardController;
    }

//ID appID = StandardController.getId(); 
//private Application__c rentingApp = [SELECT Payment_Freq__c,accClient__c,Term__c,Vendor__c,Aux_Payment_Amount__c FROM Application__c WHERE id=:appID];
    

    public void Calculate(){
        String auxfactor = ApexPages.currentPage().getParameters().get('auxfactor');
        String auxec = ApexPages.currentPage().getParameters().get('auxec');
        String auxpa = ApexPages.currentPage().getParameters().get('auxpa');
        String reqdiscount = ApexPages.currentPage().getParameters().get('reqdiscount');
        if((auxpa.equals('')) && (!auxfactor.equals('')) && (!auxec.equals('')) && (reqdiscount.equals('')) ){
            CalculatePaymentAmount();
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Payment Amount calculated successfuly, please refresh your Application page.'));
        }else if((!auxpa.equals('')) && (auxfactor.equals('')) && (!auxec.equals('')) && (reqdiscount.equals('')) ){
            CalculateFactor();
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Factor calculated successfuly, please refresh your Application page.'));
        }else if((!auxpa.equals('')) && (!auxfactor.equals('')) && (auxec.equals('')) && (reqdiscount.equals('')) ){
            CalculateEquipCost();
        }else if((auxpa.equals('')) && (auxfactor.equals('')) && (auxec.equals('')) && (!reqdiscount.equals(''))){
            CalculateAll();
        }else{
            
        }

        //errorMessage= '! Please input values only for 2 of the 3 fields (Payment Amount, Factor, Equipment Cost) leaving empty what you which to calculate! For a Requested Discount Calculation please clear all fields except the Request Discount.';

    }

    
    public void CalculatePaymentAmount(){

        ID appID = StandardController.getId();
        system.debug(appID); 
        Application__c rentingApp = [SELECT Payment_Freq__c,accClient__c,accClient__r.risk_Type__c,Term__c,Vendor__c,Vendor__r.Diluted_Doc_Fee__c,Grade__c,Sub_Grade__c,
        							Payment_Amount__c, vendor__r.discount_factor__c,vendor__r.BillingCountryCode
        							FROM Application__c
        							WHERE id=:appID];
        							 
        
        //Decimal discfactor = discfactorS != null ? decimal.valueOf(((discfactorS).replace(',','.')).replace('%','')) : 0;
                   
        Decimal factor = decimal.valueOf(ApexPages.currentPage().getParameters().get('auxfactor'));
        Decimal auxEquipCost = decimal.valueOf(ApexPages.currentPage().getParameters().get('auxec'));
        							 
        /*

        
        system.debug('Vou para o risk type o meu ID é: '+appID); 
        String risktype = [SELECT Risk_Type__c FROM Account WHERE id=:rentingApp.accClient__c].risk_Type__c;
        system.debug('passei do riskType! Para o ID: '+appID+' o risktype é: '+risktype);
        
        //string risktype=rentingApp.accClient__r.Risk_Type__c;
        boolean fee=[SELECT Diluted_Doc_Fee__c FROM Account WHERE id=:rentingApp.vendor__c].Diluted_Doc_Fee__c;
        //boolean fee=rentingApp.Vendor__r.Diluted_Doc_Fee__c;
        */
        /*Boolean payfee;
        
        String factorType = rentingApp.Vendor__r.Diluted_Doc_Fee__c ? 'Standard': 'Diluted';
        
        // replace previous with this
        if(rentingApp.Payment_freq__c!= null && rentingApp.Payment_Freq__c=='Monthly'){
        	payfee=true;
        }else if(rentingApp.Payment_Freq__c=='Quarterly') {
        	payfee=false;
        }
        
        Decimal feesFactor = payfee ? 1.8 : 0;
        Decimal vendorDiscount=0;
        
        if(rentingApp.vendor__r.discount_factor__c==null || rentingApp.vendor__r.discount_factor__c == '')
        	vendorDiscount = 0;
        else 
        	vendorDiscount = Decimal.valueOf(rentingApp.vendor__r.discount_factor__c);
        	
        Rents rentCalc = new Rents(rentingApp.Grade__c, rentingApp.Sub_Grade__c, factorType,  feesFactor, vendorDiscount , rentingApp.vendor__r.BillingCountryCode);
		List<Integer> termList = new List<Integer>();
		termList.add(Integer.valueOf(rentingApp.Term__c));
		Map<Integer, Decimal> options = rentCalc.getOptions(amountequip,termList);
		//Decimal rent = Rents.calculate(amountequip, factor, feesFactor, discountFee);
		Decimal rent = options.get(Integer.valueOf(rentingApp.Term__c));
		*/		
		//Decimal rent = auxEquipCost / 100 * factor;
		Decimal rent = Rents.calculatePaymentAmount(auxEquipCost,factor);
		//rentingApp.Aux_Payment_Amount__c = rent;
        rentingApp.Aux_Equipment_Cost__c = auxEquipCost;
        rentingApp.Aux_Rate_Factor__c = factor;
        rentingApp.Aux_Payment_Amount__c = rent;
		rentingApp.Aux_Discount__c = (1-(rent/rentingApp.Payment_Amount__c))*100;
		update rentingApp;
    }


    public void CalculateFactor(){

        ID appID = StandardController.getId(); 
        Application__c rentingApp = [SELECT Payment_Amount__c,Rent_12__c,Rent_24__c,Rent_36__c,Rent_48__c,Rent_60__c,Aux_Equipment_Cost__c,Aux_Rate_Factor__c,Payment_Freq__c,accClient__c,Term__c,Vendor__c,Aux_Payment_Amount__c,Equipment_Cost__c 
        							FROM Application__c 
        							WHERE id=:appID];

        Decimal auxPaymentAmount = decimal.valueOf(ApexPages.currentPage().getParameters().get('auxpa'));
		Decimal auxEquipCost = decimal.valueOf( ApexPages.currentPage().getParameters().get('auxec') );

        rentingApp.Aux_Payment_Amount__c = auxPaymentAmount;
        rentingApp.Aux_Equipment_Cost__c = auxEquipCost;
        rentingApp.Aux_Rate_Factor__c = Rents.calculateRateFactor(auxPaymentAmount,auxEquipCost);
        rentingApp.Aux_Discount__c = (1-(auxPaymentAmount/rentingApp.Payment_Amount__c))*100;

        update rentingApp;

    }


    public void CalculateEquipCost(){

        ID appID = StandardController.getId(); 
        Application__c rentingApp = [SELECT Payment_Amount__c,Rent_12__c,Rent_24__c,Rent_36__c,Rent_48__c,Rent_60__c,Aux_Equipment_Cost__c,Aux_Rate_Factor__c,Payment_Freq__c,accClient__c,Term__c,Vendor__c,Aux_Payment_Amount__c,Equipment_Cost__c 
        							FROM Application__c
        							WHERE id=:appID];

	   Decimal auxPaymentAmount = decimal.valueOf(ApexPages.currentPage().getParameters().get('auxpa'));
	   Decimal auxFactor = decimal.valueOf( ApexPages.currentPage().getParameters().get('auxfactor'));
	   
       rentingApp.Aux_Payment_Amount__c = auxPaymentAmount;
       rentingApp.Aux_Equipment_Cost__c = Rents.calculateEqCostFromRateFactorRent(auxPaymentAmount,auxFactor);
       rentingApp.Aux_Rate_Factor__c = auxFactor;
       rentingApp.Aux_Discount__c = (1-(auxPaymentAmount/rentingApp.Payment_Amount__c))*100;

      update rentingApp;

    }

     public void CalculateAll(){

        ID appID = StandardController.getId(); 
        Application__c rentingApp = [SELECT Payment_Amount__c,Rent_12__c,Rent_24__c,Rent_36__c,Rent_48__c,Rent_60__c,Aux_Equipment_Cost__c,Aux_Rate_Factor__c,Payment_Freq__c,accClient__c,Term__c,Vendor__c,Aux_Payment_Amount__c,Equipment_Cost__c 
        							FROM Application__c 
        							WHERE id=:appID];

        Decimal discountpct = decimal.valueOf(ApexPages.currentPage().getParameters().get('reqdiscount'))/100;
        Decimal discountAux = rentingApp.Payment_Amount__c*(discountpct);

        rentingApp.Aux_Payment_Amount__c = rentingApp.Payment_Amount__c-discountAux;
        rentingApp.Aux_Equipment_Cost__c = rentingApp.Equipment_Cost__c;
        rentingApp.Aux_Rate_Factor__c = Rents.calculateRateFactor(rentingApp.Aux_Payment_Amount__c,rentingApp.Aux_Equipment_Cost__c);
        rentingApp.Aux_Discount__c = discountpct;

        update rentingApp;

    }



}