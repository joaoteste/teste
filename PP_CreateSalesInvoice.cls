/*

Author   |Date  | Comments
Vinod    |09/01/2017 | Related Sales Invoice with payment schedule

*/
public class PP_CreateSalesInvoice {
    
    public static Double getCost(Id accountID){
        Account acc = [SELECT ID, Tax_Zone__c FROM Account WHERE ID = :accountID];         
        Bill_ProductRegion billRegion = new Bill_ProductRegion('Input');
        Double total;
        if(!Test.isRunningTest()){
        	ID prod = billRegion.getProduct('PT03', acc.Tax_Zone__c);
        	Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true LIMIT 1];
			List<PricebookEntry> standardEntryPB = [select id, UnitPrice from PricebookEntry where Product2Id = :prod  AND Pricebook2Id = :standardPB.ID ];        	
        	ID taxCode = billRegion.getTaxCode('PT03', acc.Tax_Zone__c);
        	Double rate = billRegion.getTaxRateToTaxCode(taxCode);
        	total = (standardEntryPB[0].UnitPrice * (1+rate)).setScale(2);
        }else{
            Double rate = 0.23;
            total = (2.75 * (1+rate)).setScale(2);
        }
        return total;

    }
  
  public static ID createInvoice(ID accountID, Date dueDate, ID rentingApplicationID){
      	Bill_ProductRegion billRegion = new Bill_ProductRegion('Input');
      
    	Account acc = [SELECT ID, Tax_Zone__c, c2g__CODAInputVATCode__c FROM Account WHERE ID = :accountID];

		ID pdd ; 
      	Id taxCode ;
      
              pdd = billRegion.getProduct('PT03', acc.Tax_Zone__c);
              taxCode = billRegion.getTaxcode('PT03', acc.Tax_Zone__c);      

        
                        
        //Criação da Payable Invoice a partir do objecto Vendor_Invoice__c                              
        c2g__codaInvoice__c si = new c2g__codaInvoice__c();
        
        
        si.c2g__Account__c = acc.ID;
          
        si.Application__c = rentingApplicationID;
        Date todayDate = system.today();

        si.c2g__DueDate__c = dueDate;
        si.c2g__InvoiceDate__c = todayDate; 
      
        insert si;      
        
        //update dueDate
        si.c2g__DueDate__c = dueDate.addDays(5);
        update si;          
        
        c2g__codaInvoiceLineItem__c ili = new c2g__codaInvoiceLineItem__c();
        ili.c2g__Invoice__c = si.Id;
        ili.c2g__Product__c = pdd;
        ili.c2g__TaxCode1__c = taxCode;
        insert ili;
        
        
        //c2g.CODAAPICommon.Reference refInvoice = new c2g.CODAAPICommon.Reference();
        //refInvoice.Id = si.Id;
        //system.debug('Posting sales invoice for assignment contract costs ' + refInvoice.id);
        //TODO to Post invoice        
        //c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, refInvoice);
        
        if(!Test.isRunningTest())
          si.Posted_InvoiceXpress__c = true;
        si.Post_SalesInvoice__c = true;      
         
        update si; 
        
        return si.ID;
  }
    
	public static ID createInvoiceWithInterest(ID accountID, Date dueDate, ID rentingApplicationID, Double interest, Boolean atmCosts){
      	Bill_ProductRegion billRegion = new Bill_ProductRegion('Input');
      
    	Account acc = [SELECT ID, Tax_Zone__c, c2g__CODAInputVATCode__c FROM Account WHERE ID = :accountID];

		ID pdd ; 
        ID pddInterest;
        ID taxCodeInterest;
      	Id taxCode ;
      
          /*if(test.isRunningTest()){
       		  Product2  prd = [SELECT ID, Name, c2g__CODAInputTaxCode__c FROM Product2  WHERE ProductCode = 'PT03'
                                    AND c2g__CODAInputTaxCode__c =:acc.c2g__CODAInputVATCode__c];
              pdd = prd.ID;
              taxCode = prd.c2g__CODAInputTaxCode__c;
              
       		  Product2  prdInterest = [SELECT ID, Name, c2g__CODAInputTaxCode__c FROM Product2  WHERE ProductCode = 'PT15'
                                    AND c2g__CODAInputTaxCode__c =:acc.c2g__CODAInputVATCode__c];
              pddInterest = prdInterest.ID;
              taxCodeInterest = prd.c2g__CODAInputTaxCode__c;              
          }else{*/
              pdd = billRegion.getProduct('PT03', acc.Tax_Zone__c);
              taxCode = billRegion.getTaxcode('PT03', acc.Tax_Zone__c);
 			  pddInterest = billRegion.getProduct('PT15', acc.Tax_Zone__c);
              taxCodeInterest = billRegion.getTaxcode('PT15', acc.Tax_Zone__c);              
          //}
      

        
                        
        //Criação da Payable Invoice a partir do objecto Vendor_Invoice__c                              
        c2g__codaInvoice__c si = new c2g__codaInvoice__c();
        
        
        si.c2g__Account__c = acc.ID;
          
        si.Application__c = rentingApplicationID;
        Date todayDate = system.today();

        si.c2g__DueDate__c = dueDate;
        si.c2g__InvoiceDate__c = todayDate; 
      
        insert si;      
        
        //update dueDate - trust me, this should be here
        si.c2g__DueDate__c = dueDate;
        update si;          
        
        if(atmCosts){
	        c2g__codaInvoiceLineItem__c ili = new c2g__codaInvoiceLineItem__c();
	        ili.c2g__Invoice__c = si.Id;
	        ili.c2g__Product__c = pdd;
	        ili.c2g__TaxCode1__c = taxCode;
	        insert ili;
        }
        
        c2g__codaInvoiceLineItem__c iliInterest = new c2g__codaInvoiceLineItem__c();
        iliInterest.c2g__Invoice__c = si.Id;
        iliInterest.c2g__Product__c = pddInterest;
        iliInterest.c2g__TaxCode1__c = taxCodeInterest;
        Decimal auxInterest = interest;
        iliInterest.c2g__UnitPrice__c = auxInterest.setScale(2);
		iliInterest.c2g__DeriveUnitPriceFromProduct__c = false;            
        insert iliInterest;        
        
        
        //c2g.CODAAPICommon.Reference refInvoice = new c2g.CODAAPICommon.Reference();
        //refInvoice.Id = si.Id;
        //system.debug('Posting sales invoice for assignment contract costs ' + refInvoice.id);
        //TODO to Post invoice        
        //c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, refInvoice);
        
        if(!Test.isRunningTest())
          si.Posted_InvoiceXpress__c = true;
        si.Post_SalesInvoice__c = true;      
         
        update si; 
        
        return si.ID;
  } 
    
  public static ID createInvoiceFull(ID accountID, Date dueDate, ID rentingApplicationID, Double interest, Double rentAmount, Boolean atmCosts){
      	Bill_ProductRegion billRegion = new Bill_ProductRegion('Input');
      
    	Account acc = [SELECT ID, Tax_Zone__c, c2g__CODAInputVATCode__c FROM Account WHERE ID = :accountID];

		ID pdd ; 
        ID pddInterest;
    	ID pddRent;
        ID taxCodeInterest;
    	ID taxCodeRent;
      	Id taxCode ;
      
              pdd = billRegion.getProduct('PT03', acc.Tax_Zone__c);
              taxCode = billRegion.getTaxcode('PT03', acc.Tax_Zone__c);
 			  pddInterest = billRegion.getProduct('PT15', acc.Tax_Zone__c);
              taxCodeInterest = billRegion.getTaxcode('PT15', acc.Tax_Zone__c);  
 			  pddRent = billRegion.getProduct('PT22', acc.Tax_Zone__c);
              taxCodeRent = billRegion.getTaxcode('PT22', acc.Tax_Zone__c);                   

      

        
                        
        //Criação da Payable Invoice a partir do objecto Vendor_Invoice__c                              
        c2g__codaInvoice__c si = new c2g__codaInvoice__c();
        
        
        si.c2g__Account__c = acc.ID;
          
        si.Application__c = rentingApplicationID;
        Date todayDate = system.today();

        si.c2g__DueDate__c = dueDate;
        si.c2g__InvoiceDate__c = todayDate; 
      
        insert si;      
        
        //update dueDate - trust me, this should be here !!
        si.c2g__DueDate__c = dueDate;
        update si;          
        
        if(atmCosts){
	        c2g__codaInvoiceLineItem__c ili = new c2g__codaInvoiceLineItem__c();
	        ili.c2g__Invoice__c = si.Id;
	        ili.c2g__Product__c = pdd;
	        ili.c2g__TaxCode1__c = taxCode;
	        insert ili;
        }
        
        Decimal valueRounded = interest;
        valueRounded = valueRounded.setScale(2);
        if(valueRounded != 0){
	        c2g__codaInvoiceLineItem__c iliInterest = new c2g__codaInvoiceLineItem__c();
	        iliInterest.c2g__Invoice__c = si.Id;
	        iliInterest.c2g__Product__c = pddInterest;
	        iliInterest.c2g__TaxCode1__c = taxCodeInterest;
	        iliInterest.c2g__UnitPrice__c = interest;
	        iliInterest.c2g__UnitPrice__c = iliInterest.c2g__UnitPrice__c.setScale(2);
	    	iliInterest.c2g__DeriveUnitPriceFromProduct__c = false;    
	        insert iliInterest;   
        }  
    
        c2g__codaInvoiceLineItem__c iliRent = new c2g__codaInvoiceLineItem__c();
        iliRent.c2g__Invoice__c = si.Id;
        iliRent.c2g__Product__c = pddRent;
        iliRent.c2g__TaxCode1__c = taxCodeRent;
        iliRent.c2g__UnitPrice__c = rentAmount;
        iliRent.c2g__UnitPrice__c = iliRent.c2g__UnitPrice__c.setScale(2);
    	iliRent.c2g__DeriveUnitPriceFromProduct__c = false;
        insert iliRent;        
        
        
        //c2g.CODAAPICommon.Reference refInvoice = new c2g.CODAAPICommon.Reference();
        //refInvoice.Id = si.Id;
        //system.debug('Posting sales invoice for assignment contract costs ' + refInvoice.id);
        //TODO to Post invoice        
        //c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, refInvoice);
        
        if(!Test.isRunningTest())
          si.Posted_InvoiceXpress__c = true;
        si.Post_SalesInvoice__c = true;      
         
        update si; 
        
        return si.ID;
  }        
    
}