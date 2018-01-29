@isTest (SeeAllData = true)
private class UTIL_VatInfo_TEST 
{	
	@isTest static void convertPostalCodeIntoVAT_TEST() 
	{
		Account clientTest = new Account();
		clientTest.Name    = '514096870';
		clientTest.Nif__c  = '514096870';
		clientTest.type    = 'Customer - Channel';
		upsert clientTest;

		Account vendorTest = new Account();
		vendorTest.Name    = '503959880';
		vendorTest.Nif__c  = '503959880';
		vendorTest.type    = 'Channel Partner / Vendor';
		upsert vendorTest;

		clientTest.c2g__CODAInputVATCode__c = UTIL_VatInfo.convertPostalCodeIntoVAT(clientTest,'3120');
		update clientTest;

		System.assertEquals('VCONT23',
							[SELECT c2g__CODAInputVATCode__r.name 
							   FROM Account
							  WHERE NIF__C='514096870' AND Type = 'Customer - Channel'].c2g__CODAInputVATCode__r.name,
			  				'[UTIL_VatInfo_TEST].convertPostalCodeIntoVAT_TEST --> Iva atribuido ao Client está errado...');
		
		vendorTest.c2g__CODAOutputVATCode__c = UTIL_VatInfo.convertPostalCodeIntoVAT(vendorTest,'9640');
		update vendorTest;

		System.assertEquals('CAC18',
							[SELECT c2g__CODAOutputVATCode__r.name 
							   FROM Account
							  WHERE NIF__C='503959880' AND Type = 'Channel Partner / Vendor'].c2g__CODAOutputVATCode__r.name,
							'[UTIL_VatInfo_TEST].convertPostalCodeIntoVAT_TEST --> Iva atribuido ao Vendor está errado...');
	}
}//end class