@isTest
private class RentsTest {

	static Factorcard__c createFactorCards(String type, String status, String country){

		Factorcard__c f = new Factorcard__c(
			Type__c = type,
			Status__c = status,
			Country__c = country
		);

		insert f;
		return f;
	}

	static Factorcard_Line_Item__c createFactorcardLineItems(Id factorId, String grade, String subGrade, Decimal max, Decimal min, String term, Decimal factor ){

		Factorcard_Line_Item__c fli = new Factorcard_Line_Item__c(
			Factor__c = factor,
			Grade__c = grade,
			Sub_grade__c = subGrade,
			Max_Value__c = max,
			Min_Value__c = min,
			Term__c = term,
			Factorcard__c = factorId
		);

		insert fli;
		return fli;
	}

	@isTest static void testGetOptions() {
		//setTestData
		Factorcard__c f = createFactorCards('Standard', 'Active', 'PT');
		createFactorcardLineItems(f.id, 'A', '1', 50000, 25001, '12', 8.5634);
		createFactorcardLineItems(f.id, 'A', '1', 50000, 25001, '24', 4.3972);
		createFactorcardLineItems(f.id, 'A', '1', 50000, 5001 , '36', 3.0405);

		Integer[] termOptions = new Integer[]{12,24,36};
		
		Test.startTest();
			
		//calc rents with additional fee
		Rents rents_1 = new Rents('A','1','Standard',1.9,'PT');
		Map<Integer, Decimal> optionsMap = rents_1.getOptions(30000, termOptions);
	 	System.assertEquals(optionsMap.get(12), 2617.83, 'Wrong rent value for term 12');
	 	System.assertEquals(optionsMap.get(24), 1344.21, 'Wrong rent value for term 24');
	 	System.assertEquals(optionsMap.get(36), 929.46, 'Wrong rent value for term 36');

		//calc rents without additional fee
		Rents rents_2 = new Rents('A','1','Standard','PT');
		Map<Integer, Decimal> optionsMap_withoutFee = rents_2.getOptions(30000, termOptions);
	 	System.assertEquals(optionsMap_withoutFee.get(12), 2569.02, 'Wrong rent value for term 12');
	 	System.assertEquals(optionsMap_withoutFee.get(24), 1319.16, 'Wrong rent value for term 24');
	 	System.assertEquals(optionsMap_withoutFee.get(36), 912.15, 'Wrong rent value for term 36');

		//test if returns only the options for the terms in termOptions_only12
		Integer[] termOptions_only12 = new Integer[]{12};
		Rents rents_3 = new Rents('A','1','Standard','PT');
		Map<Integer, Decimal> optionsMap_only12 = rents_3.getOptions(30000, termOptions_only12);
	 	System.assertEquals(optionsMap_only12.get(24), NULL, 'Should not return rent value for term 24');
	 	System.assertEquals(optionsMap_only12.get(36), NULL, 'Should not return rent value for term 36');

	 	//termOption.size()
	 	Integer[] termOptions_only60 = new Integer[]{60};
		Rents rents_4 = new Rents('A','1','Standard','PT');
		Map<Integer, Decimal> optionsMap_only60 = rents_4.getOptions(30000, termOptions_only60);
	 	System.assertEquals(optionsMap_only60.get(60), NULL, 'Should not return rent value for term 60');
	 	
	 	Test.stopTest();
	}
	
	@isTest static void testGetFactorItems() {

		//setTestData
		Factorcard__c f = createFactorCards('Standard', 'Active', 'PT');
		Factorcard_Line_Item__c fli_C_12 = createFactorcardLineItems(f.id, 'C', '1', 3000, 1501, '12', 9.4112);
		Factorcard_Line_Item__c fli_C_48 = createFactorcardLineItems(f.id, 'C', '1', 3000, 1501, '48', 2.6108);
		Factorcard_Line_Item__c fli_C_60 = createFactorcardLineItems(f.id, 'C', '1', 3000, 1501, '60', 2.1555);
		

		Factorcard_Line_Item__c fli_B_60 = createFactorcardLineItems(f.id, 'B', '1', 12500, 5001, '36', 3.1566);
		 
		Test.startTest();
		
		Decimal amount = 1800.36;
		Rents rents= new Rents('C','1','Standard','PT');
		List<Factorcard_Line_Item__c> factorCardLineItemsList = rents.getFactorItems(amount);
		Map< Id, Factorcard_Line_Item__c> fliTestMap = new Map< Id, Factorcard_Line_Item__c>(factorCardLineItemsList);
		Set<Id> idSetFli = fliTestMap.keySet();

		System.assert(idSetFli.contains(fli_C_12.Id),'Error finding factor card line items for the amount ' +  amount);
		System.assert(idSetFli.contains(fli_C_48.Id),'Error finding factor card line items for the amount ' +  amount);
		System.assert(idSetFli.contains(fli_C_60.Id),'Error finding factor card line items for the amount ' +  amount);
		
		System.assert(!idSetFli.contains(fli_B_60.Id),'Should not found this factor for the amount ' +  amount);

		Decimal amount2 = 500;
		Rents rents2= new Rents('C','1','Standard','PT');
		List<Factorcard_Line_Item__c> factorCardLineItemsList2 = rents2.getFactorItems(amount2);
		
		System.assert(factorCardLineItemsList2.size()==0,'Should not find any factor item for the amount' +  amount2);
		
		Test.stopTest();

	}

	@isTest static void testCalculate(){
		Test.startTest();
		Decimal value = Rents.calculate(30000, 8.5634);
		System.assertEquals(value, 2569.02, 'Calculate return Wrong value');
		Test.stopTest();
	}

	@isTest static void testUpdateApplicationRent(){
		Factorcard__c f = createFactorCards('Standard', 'Active', 'PT');
			
		createFactorcardLineItems(f.id, 'E', '1', 25000, 12501, '60', 2.2593);
		createFactorcardLineItems(f.id, 'E', '1', 25000, 12501, '48', 2.6100);
		createFactorcardLineItems(f.id, 'E', '1', 25000, 12501, '36', 3.3047);

		Integer[] termOptions = new Integer[]{36,48,60};
		
        //New Account Vendor
        Account vendor = new Account();
        vendor.Name = 'Test Account Vendor'; 
        vendor.Type = 'Channel Partner / Vendor';
        vendor.NIF__c = '503630311';
        insert vendor;
        
        //New Account Client
        Account client = new Account();
        client.Name = 'Test Account Client'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '504092090';
        Client.Date_Of_Establishment__c = Date.newInstance(2015, 01, 01);
        insert client;
        
        Application__c app = new Application__c();
        app.AccClient__c = client.ID;
        app.Vendor__c = vendor.ID;
        insert app;

		Test.startTest();

		//calc rents 
		Rents rents = new Rents('E','1','Standard','PT');
		Map<Integer, Decimal> optionsMap = rents.getOptions(24000, termOptions);
		
		Rents.Selected selected = new Rents.Selected();
		selected.term = 60;
		selected.rent = optionsMap.get(60);
		selected.freq = 'Quarterly';
		selected.admin_costs = 100;
		selected.doc_fee = false;


		//test when selected rent is not correct
		selected.opValue = 23950;
		boolean result_NOTOK = rents.updateApplicationRent(app.Id, selected);
		System.assert(!result_NOTOK, 'Should have failed the aplication update');

		//test when selected rent is correct
		selected.opValue = 24000;
		boolean result_OK = rents.updateApplicationRent(app.Id, selected);
		System.assert(result_OK, 'failed to update Renting Application');

		Test.stopTest();


	}
}