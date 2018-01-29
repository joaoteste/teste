@isTest(SeeAllData=true)
public class BILL_ConvertBCLIToSI_Test {
    
    @isTest public static void BCLItoSI_Test(){
        /*Creates the test envoirment*/
        //IDs
        // client -> client
        // vendor -> vendor
        // Application -> appID
        // Billing Contract -> bcID
        // Sales Invoice -> salesInvoice
        RentingApplication_Util_Test RAU = new RentingApplication_Util_Test();
        Map <String, String> environment = RAU.environment7();
        
        /* Gets the Billing Contracts and BC Line items used to create the sales invoice and SI line items*/
        Billing_Contract__c bc = [SELECT ID, Account__c, Aux_Invoice_Date__c, Aux_Due_Date__c FROM Billing_Contract__c WHERE ID=:environment.get('bcID') ];
        if(bc == null){
            System.assert(false, 'No Billing Contract Found.');
            return;
        }
       	List <Billing_Contract_Line_Item__c> bcliList = [SELECT ID,Name,Product_Tax_Code__c, Billing_Period__c,Product__c,Line_Item_Start_Date__c,Line_Item_End_Date__c, Quantity__c, Sales_Price__c FROM Billing_Contract_Line_Item__c WHERE Billing_Contract__c=:environment.get('bcID') AND Ready_to_Invoice__c = TRUE];
        if(bcliList == null){
            System.assert(false, 'No Billing Contract Line Item for this contract was Found.');
            return;
        }

        Test.startTest();
        	System.debug('BILL_ConvertBCLIToSI_Test queries limits before ' + System.Limits.getQueries());
            BILL_BH_CreateDueSalesInvoices createDueSalesInvoicesBatch = new BILL_BH_CreateDueSalesInvoices(0);
            ID batchprocessid = Database.executeBatch(createDueSalesInvoicesBatch, 1);	
        	System.debug('BILL_ConvertBCLIToSI_Test queries limits after ' + System.Limits.getQueries());
        Test.stopTest();
		//refresh is done as the Invoice date needs to be updated.
        bc = [SELECT ID, Account__c, Aux_Invoice_Date__c, Aux_Due_Date__c FROM Billing_Contract__c WHERE ID=:environment.get('bcID') ];
        if(bc == null){
            System.assert(false, 'No Billing Contract Found.');
            return;
        }
       	System.debug('BCLI:'+ bcliList);
        List<c2g__codaInvoiceLineItem__c> siliList = [SELECT ID, c2g__TaxCode1__c, Billing_Contract_Line_Item__c, Line_Item_Period__c, c2g__Product__c, c2g__Quantity__c, c2g__UnitPrice__c FROM c2g__codaInvoiceLineItem__c WHERE Billing_Contract_Line_Item__c = :bcliList ] ;  
        if(siliList.size() < 1){
            //Checks for more than on sales invoice LI per billing contract Li, possible in case there is an annulation 
            System.assert(false, 'No Sales invoice line items were found. Or more than one Billing contract line item was found.');
            return;
        }
       // c2g__codaInvoiceLineItem__c sili = siliList[0];
        List<c2g__codaInvoice__c> siList = [SELECT ID,c2g__Account__c, c2g__BillingAddress__c, c2g__DueDate__c, c2g__InvoiceDate__c, Billing_Contract__c FROM  c2g__codaInvoice__c WHERE Billing_Contract__c= :bc.ID];   	
        if(siList.size() < 1 || siList.size() > 1) {
            System.assert(false, 'No Sales invoice was found.');
            return;
        }
        c2g__codaInvoice__c si = siList[0];
        //Comparations between Billing Contract and Sales Invoice
        System.debug('Comparision between values:');
        System.assertEquals(bc.ID,                                  si.Billing_Contract__c);    
        System.assertEquals(bc.Account__c,                          si.c2g__Account__c);
        System.debug('Invoice bc' + bc.Aux_Invoice_Date__c);
        System.debug('Invoice si' + si.c2g__InvoiceDate__c);
        
        System.assertEquals(bc.Aux_Invoice_Date__c,                 si.c2g__InvoiceDate__c);
        System.assertEquals(bc.Aux_Due_Date__c,                     si.c2g__DueDate__c);
      
        Boolean foundsi = False;
        for( Billing_Contract_Line_Item__c bcliItem : bcliList){
            for(c2g__codaInvoiceLineItem__c siliItem : siliList){
                if(bcliItem.ID == siliItem.Billing_Contract_Line_Item__c){
                    foundsi = true;
                    //Comparations between Billing Contract Line items and Sales Invoice Line items
                    System.assertEquals(bcliItem.Product_Tax_Code__c,               siliItem.c2g__TaxCode1__c);
                    System.assertEquals(bcliItem.ID,                                siliItem.Billing_Contract_Line_Item__c);             
                    System.assertEquals(bcliItem.Billing_Period__c,                 siliItem.Line_Item_Period__c);
                    System.assertEquals(bcliItem.Product__c,                        siliItem.c2g__Product__c);
                    System.assertEquals(bcliItem.Quantity__c,                       siliItem.c2g__Quantity__c);
                    System.assertEquals(bcliItem.Sales_Price__c,                    siliItem.c2g__UnitPrice__c);
                }
            }
            System.assert(foundsi);
            foundsi=false;
        }
      
        System.debug('Finishd Comparision between values:');                   
    }    
}