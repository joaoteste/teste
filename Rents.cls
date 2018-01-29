/**
* @date 2017
*
* @description Class for calculate rents from a given grade, subGrade, factor type. 
*/
public with sharing class Rents{

	private static final Integer DECIMALS = 2;
	private Map<Integer, Decimal> options {get;set;} 
	private String grade {get;set;}
	private String subGrade {get;set;}
	private String factorType {get;set;}
	private Decimal additionalFee {get;set;}
	private Factorcard__c[] factorCardArray {get;set;}
	private Decimal creditLimitMin {get;set;}
	private Decimal discountFee {get;set;}
	
	public Rents(String grade, String subGrade, String factorType,  Decimal additionalFee, Decimal discountFee,  String countryCode) {
		this.grade = grade;
		this.subGrade = subGrade;
		this.factorType = factorType;
		this.additionalFee = additionalFee;
		this.discountFee = discountFee;
		this.options = new Map<Integer, Decimal>();	
		this.creditLimitMin = [SELECT Minimum_Credit_Allowed__c FROM Credit_Decisions_Settings__mdt WHERE DeveloperName =:countryCode LIMIT 1].Minimum_Credit_Allowed__c;       
		this.factorCardArray = [SELECT ID, Name, Type__c, (SELECT ID, Name, Factor__c, Grade__c, Max_Instalment__c, Max_Value__c, Min_Instalment__c, Min_Value__c, Sub_grade__c, Term__c 
				   										  FROM Factorcard_Line_Items__r 
				   										  WHERE Grade__c =:grade AND Sub_grade__c=:subGrade) 
			                	FROM Factorcard__c
			                	WHERE Type__c =:factorType AND Country__c =: countryCode LIMIT 1];	
	}

	public Rents(String grade, String subGrade, String factorType, Decimal additionalFee, String countryCode) {
		
		this(grade, subGrade, factorType, additionalFee,0, countryCode);

		System.debug('[Rents - Constructor]  Rents: ' + this);
	
	}

	public Rents(String grade, String subGrade, String factorType, String countryCode) {

		this(grade, subGrade, factorType, 0,0, countryCode);

		System.debug('[Rents - Constructor]  Rents: ' + this);

	}


	 /*******************************************************************************************************
    * @description calculate the rent options per Terms according to the factor grade, subGrade and type
    * @param Decimal amount   
    * @param Integer[] terms  
    * @return Map<Integer, Decimal> 
    */
	public Map<Integer, Decimal> getOptions(Decimal amount, Integer[] terms){

		List<Factorcard_Line_Item__c> factorItems = getFactorItems(amount);
		Map<String,Decimal> termFactorMap = new Map<String,Decimal>();

        for(Factorcard_Line_Item__c fcli : factorItems){
        	termFactorMap.put(fcli.Term__c, fcli.Factor__c);
        }

        System.debug('[Rents - getOptions()] Map<Term__c, Factor>: ' +  termFactorMap);
        System.debug('[Rents - getOptions()] Map<Term__c, Factor> keySet: ' +  termFactorMap.keySet());
        System.debug('[Rents - getOptions()] Map<Term__c, Factor> values: ' +  termFactorMap.values());

        Decimal factor;
		for(Integer term : terms){
			factor = termFactorMap.get(term+'');
			if(factor!=null){
				options.put(term, calculate(amount, factor, additionalFee,discountFee));
			}else{
				System.debug('[Rents - getOptions()] Factor for term ' + term + ' is NULL');
			}
		}

		System.debug('[Rents - getOptions()] options: ' +  options);

		return options;
	}


	 /*******************************************************************************************************
    * @description get a list of factorcard line items for the amount, grade, subGrade and Type choosen 
    * @param Decimal amount   
    * @return  List<Factorcard_Line_Item__c>
    */
	public List<Factorcard_Line_Item__c> getFactorItems(Decimal amount){

		System.debug('[Rents - getFactorItems()] going to get factorItems for amount: ' +  amount);
		List<Factorcard_Line_Item__c> factorItems = new List<Factorcard_Line_Item__c>();

		if(factorCardArray.size()==0){
			System.debug('[Rents - getFactorItems()] WARNING: Factor Card NOT FOUND!: ' +  factorCardArray);
			return factorItems; //retorna lista vazia
		}

		Factorcard__c fc = factorCardArray[0];
		if(fc.Factorcard_Line_Items__r == null || fc.Factorcard_Line_Items__r.size()==0){
			System.debug('[Rents - getFactorItems()] WARNING: Factor Card Line Item NOT FOUND!: ' +  fc.Factorcard_Line_Items__r);
			return factorItems; //retorna lista vazia
		}

		for(Factorcard_Line_Item__c fcli : fc.Factorcard_Line_Items__r){
			if(fcli.Max_Value__c >= amount && (fcli.Min_Value__c < amount || fcli.Min_Value__c == this.creditLimitMin && amount == this.creditLimitMin)){
				factorItems.add(fcli);
			}
		}

		System.debug('[Rents - getFactorItems()] factorItems: ' +  factorItems);
		System.debug('[Rents - getFactorItems()] factorItems size: ' +  factorItems.size());
		return factorItems;
	} 


	 /*******************************************************************************************************
    * @description calculate rent for specific amount and factor
    * @param Decimal amount   
    * @param Decimal factor  
    * @return  Decimal rent value
    */
	public static Decimal calculate(Decimal amount, Decimal factor){
		return calculate(amount, factor , 0,0);
    } 


	 /*******************************************************************************************************
    * @description calculate rent for specific amount and factor with additonal fee 
    * @param Decimal amount   
    * @param Decimal factor  
    * @return  Decimal rent value
    */
	public static Decimal calculate(Decimal amount, Decimal factor, decimal additionalFee){
		return calculate(amount, factor , additionalFee, 0);
    }
    
     /*******************************************************************************************************
    * @description calculate rent for specific amount and factor with additonal fee and discount
    * @param Decimal amount   
    * @param Decimal factor  
    * @param Decimal additionalFee
    * @param Decimal discountFee
    * @return Decimal rent value
    */
    public static Decimal calculate(Decimal amount, Decimal factor, Decimal additionalFee, Decimal discountFee){
        System.debug('[Rents - calc()] amount->' + amount + ' factor->'+factor+ ' additionalFee->'+additionalFee+' discountFee->'+discountFee);
    	factor = factor * (1+(additionalFee/100));
		factor = factor.setScale(4, System.RoundingMode.DOWN);
		discountFee = (1-discountFee/100);
		discountFee = discountFee.setScale(4, System.RoundingMode.DOWN);
		Decimal value = (factor/100 * amount * discountFee).setscale(DECIMALS);
		System.debug('[Rents - calc()] rent value: ' +  value);
		return value;
    }
    
    public static Decimal calculateFactorMonthToQuarterly(Decimal factorMonthly, String BillingCountryCode){
    	Decimal additionalFee = [Select Monthly_Fee__c From Credit_Decisions_Settings__mdt where DeveloperName = :BillingCountryCode].Monthly_Fee__c;
        Decimal factor = factorMonthly / (1+(additionalFee/100));
        return factor;
    }
    
    public static Decimal calculateFactorQuarterlyToMonth(Decimal factorQuarterly, String BillingCountryCode){
    	Decimal additionalFee = [Select Monthly_Fee__c From Credit_Decisions_Settings__mdt where DeveloperName = :BillingCountryCode].Monthly_Fee__c;
        Decimal factor = factorQuarterly * (1+(additionalFee/100));
        return factor;
    }
    
    //calcula o valor da renda a partir do valor do equiamento e do Rate Factor
    public static Decimal calculateEqCostFromRateFactorRent(Decimal auxPaymentAmount, Decimal finalFactor){
    	return auxPaymentAmount * 100 / finalFactor;
    }
    
    //calcula o valor da renda a partir do valor do equiamento e do Rate Factor
    public static Decimal calculatePaymentAmount(Decimal amount, Decimal finalFactor){
        return (amount * finalFactor/100).setscale(DECIMALS);
    }
    
    //calcula o factor final (Rate Factor) baseado no valor do Payment amount e do custo do equipamento
    public static Decimal calculateRateFactor(Decimal auxPaymentAmount, Decimal auxEquipCost){
    	return (auxPaymentAmount/auxEquipCost*100).setscale(DECIMALS);
    }
    
	 /*******************************************************************************************************
    * @description update application Contract Values 
    * @param ID appId   
    * @param Selected selectedRent  
    * @return  boolean
    */
	public boolean updateApplicationRent(Id appId, Selected selectedRent) {

		selectedRent.rent = selectedRent.rent.setscale(DECIMALS);
		selectedRent.opValue = selectedRent.opValue.setscale(DECIMALS);
		
		boolean isValid = validateRent(selectedRent);

		if(isValid){
			Application__c app = new Application__c(Id = appId);
	    	app.Equipment_cost__c = selectedRent.opValue;
	    	app.Payment_Amount__c = selectedRent.rent;
	    	app.Term__c = selectedRent.term+'';
	    	app.TermCalc__c = selectedRent.term;
	    	app.Vendor_Diluted_Doc_Fee__c = selectedRent.doc_fee;
	    	app.Payment_Freq__c = selectedRent.freq;
			app.New_Rate_Factor__c = selectedRent.opValue != 0 ? (selectedRent.rent * 100) / selectedRent.opValue : null;
			app.Factor__c = selectedRent.opValue != 0 ? (selectedRent.rent * 100) / selectedRent.opValue : null;
			app.Documentation_fee_cost__c = selectedRent.admin_costs;
	    	System.debug('[Rents - updateApplicationRent()] before update -> ' + app);
	    	update app;
	    	System.debug('[Rents - updateApplicationRent()] after update -> ' + app);
    	}

    	return isValid;
    } 

	 /*******************************************************************************************************
    * @description Valida a renda escolhida  
    * @param Selected selectedRent   
    * @param Decimal factor  
    * @return  boolean
    */
    @TestVisible
    private boolean validateRent(Selected selectedRent){
    	System.debug('[Rents - validateRent()]');

		List<Factorcard_Line_Item__c> factorItems = getFactorItems(selectedRent.opValue);
       	List<Integer> terms = new List<Integer>();
       	
       	for(Factorcard_Line_Item__c fcli : factorItems){
       		terms.add(Integer.ValueOf(fcli.Term__c));
        }
    	
    	Map<Integer, Decimal> options = getOptions(selectedRent.opValue, terms); 
    	Decimal rentfromOptions = options.get(selectedRent.term);
    	System.debug('[Rents - validateRent()] rent from options: ' +  rentfromOptions +'; for term ' + selectedRent.term);
    	System.debug('[Rents - validateRent()] rent received: ' +  selectedRent.rent +'; for term ' + selectedRent.term);
    	
    	boolean isPaymentAmountOK = rentfromOptions == selectedRent.rent;    	
    	isPaymentAmountOk = isPaymentAmountOk && selectedRent.doc_fee != null && selectedRent.freq != null;
    	System.debug('[Rents - validateRent()] is Payment_Amount__c Correct? ' +  isPaymentAmountOK);

    	return isPaymentAmountOK;
    
    }

	/*******************************************************************************************************
    * Inner Class - Wrapper to handle selected rent from site
    */
    public class Selected{
    	
    	public Integer term {get;set;}
    	public Decimal rent {get;set;}
    	public String freq {get;set;}
    	public Decimal opValue {get;set;} 
    	public Decimal admin_costs {get;set;}
    	public boolean doc_fee {get;set;}

    }
}