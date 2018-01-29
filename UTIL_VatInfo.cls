//CREATED BY BP - 09/05/17
public class UTIL_VatInfo 
{

	public static String convertPostalCodeIntoVAT(Account acc,String PostalCode)
	{
		try
		{
			if(acc==null)
				return null;

			Integer postcode_min;
			Integer postcode_max;
			Integer accpostcode = integer.valueOf((PostalCode).substring(0,4));
			String  accregion   = '';	
			String  query; 

			List<PostCode__c> postcod = [SELECT CP_Max__c, CP_Min__c, Region__c 
			                               FROM postcode__c 
			                              WHERE Region__c != null
			                            ];

			for (integer i=0; i<postcod.size(); i++)
			{
	            postcode_max 	= integer.valueOf((postcod[i].Cp_Max__c).substring(0,4));
	            postcode_min 	= integer.valueOf((postcod[i].CP_Min__c).substring(0,4));            
	            if(accpostcode <= postcode_max && accpostcode >= postcode_min)
	            	accregion   = postcod[i].Region__c;            
	        }   
	        System.debug('[convertPostalCodeIntoVAT] accregion --> '+accregion);
	        query =  'SELECT name, Area__c,Country__c, id  FROM c2g__codaTaxCode__c WHERE country__C= \'Portugal\' AND Area__c = \''+accregion+ '\'';
	        //query += '	and Area__c= \''+accregion+'\'';
	        if(acc.type == 'Customer - Channel')
	        	query += ' and Name like \'V%\' and ( not name like \'%00\') LIMIT 1';
	       	else
	       		query += ' and Name like \'C%\' and ( not name like \'%00\') LIMIT 1';

	       	System.debug('[UTIL_VatInfo].convertPostalCodeIntoVAT --> query: '+ query);
	       	List<c2g__codaTaxCode__c> taxcodes= Database.query(query);	

	       	/*
	       	if(acc.type == 'Customer - Channel')
	        	acc.c2g__CODAInputVATCode__c = taxcodes[0].id;
	       	else
	       		acc.c2g__CODAOutputVATCode__c = taxcodes[0].id;
	       	acc.Account_Status_Comments__c ='None of Interest.';
	        update acc;
	        */

	        System.debug('[UTIL_VatInfo].convertPostalCodeIntoVAT --> taxcodes[0].name: '+taxcodes[0].Name); 
	        return taxcodes[0].id;
		}
		catch(Exception e)
		{
			System.debug('[UTIL_VatInfo].convertPostalCodeIntoVAT --> Entrou no catch...');
			System.debug('[UTIL_VatInfo] Line: '+e.getLineNumber()+ '		Type: '+e.getTypeName()+'		Message: '+e.getMessage());
			System.debug('[UTIL_VatInfo] TRACING: '+e.getStackTraceString());
	    	return null;
		}      
	}// end convertPostalCodeIntoRegion method	
}//end class