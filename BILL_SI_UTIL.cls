public class BILL_SI_UTIL {
    
    public c2g__codaInvoice__c createSI(ID AccountID, ID ApplicationID, Date DueDate, Date InvoiceDate, /*String Invoice_Express_Number*/ String InvoiceDescription, List<Product2> InvoiceLineItems, String externalId, Boolean sepaInative){
        Bill_ProductRegion billRegion = new Bill_ProductRegion('Input');
        Account acc = [SELECT Id, Tax_Zone__c FROM Account WHERE ID = :AccountID];
        //Criação da Payable Invoice a partir do objecto Vendor_Invoice__c                              
        c2g__codaInvoice__c si = new c2g__codaInvoice__c();
        si.c2g__Account__c = AccountID;
        si.Application__c = ApplicationID;
        si.c2g__DueDate__c = DueDate;
        si.c2g__InvoiceDate__c = InvoiceDate;
        //si.Invoice_Express_Number_text__c = Invoice_Express_Number;
        si.c2g__InvoiceDescription__c = InvoiceDescription; 
        si.Collection_Case__c = externalId;     
      
        insert si;                  
        
        List<c2g__codaInvoiceLineItem__c> list_InvoiceLineItem = new List<c2g__codaInvoiceLineItem__c>();
        for(Product2 p : InvoiceLineItems){
            c2g__codaInvoiceLineItem__c ili = new c2g__codaInvoiceLineItem__c();
            ili.c2g__Invoice__c = si.Id;
            system.debug(p.ProductCode);
            ili.c2g__Product__c = billRegion.getProduct(p.ProductCode, acc.Tax_Zone__c);
            ili.c2g__TaxCode1__c = billRegion.getTaxCode(p.ProductCode, acc.Tax_Zone__c);
            list_InvoiceLineItem.add(ili);
        }
        insert list_InvoiceLineItem;
        
        //Criação / Adição dos Invoice Line Items associadas à SI
        /*for(c2g__codaInvoiceLineItem__c ili : InvoiceLineItems){
            ili.c2g__Invoice__c = si.Id;
        }
        upsert InvoiceLineItems;*/

        //TODO to Post invoice         
//        c2g.CODAAPICommon.Reference refInvoice = new c2g.CODAAPICommon.Reference();
//        refInvoice.Id = si.Id;
//        system.debug('[BILL_SI_UTIL CreateSI] - journal ref ' + refInvoice.id);     
//        c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, refInvoice);
//        Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'Success', 'BILL_SI_UTIL.CreateSI', si.ID, ApplicationID);
                 // O post depois é feito no trigger.
         si.Posted_InvoiceXpress__c = true;
         si.Post_SalesInvoice__c = true; 
         
         update si;
        // factura criada, due date no proprio dia, email gerado no dia seguinte. 
        
        return si;
    } 
    
    public c2g__codaInvoice__c createSI_3rdReminder(String DunningAlert, ID AccountID, ID ApplicationID, Date DueDate, Date InvoiceDate, String InvoiceDescription, List<Product2> InvoiceLineItems, String externalId, Boolean sepaInative, String DunningDescription, Decimal InterestCharges){
        Bill_ProductRegion billRegion = new Bill_ProductRegion('Input');
        Account acc = [SELECT Id, Tax_Zone__c FROM Account WHERE ID = :AccountID];                                  
        c2g__codaInvoice__c si = new c2g__codaInvoice__c();
        si.c2g__Account__c = AccountID;
        si.Application__c = ApplicationID;
        si.c2g__DueDate__c = DueDate;
        si.c2g__InvoiceDate__c = InvoiceDate; 
        si.c2g__InvoiceDescription__c = InvoiceDescription; 
        si.Collection_Case__c = externalId;  
        
        insert si;
        
        List<c2g__codaInvoiceLineItem__c> list_InvoiceLineItem = new List<c2g__codaInvoiceLineItem__c>();
        for(Product2 p : InvoiceLineItems){
            c2g__codaInvoiceLineItem__c ili = new c2g__codaInvoiceLineItem__c();
            ili.c2g__Invoice__c = si.Id;
            system.debug(p.ProductCode);
            ili.c2g__Product__c = billRegion.getProduct(p.ProductCode, acc.Tax_Zone__c);
            ili.c2g__TaxCode1__c = billRegion.getTaxCode(p.ProductCode, acc.Tax_Zone__c);         
            if(DunningDescription == '3rd Reminder'){                  
                if(p.Name == 'Juros de Mora'){                    
                    ili.c2g__UnitPrice__c =  InterestCharges.setScale(2);
                    ili.c2g__DeriveUnitPriceFromProduct__c = false;                     
                } 
            }             
            list_InvoiceLineItem.add(ili); 
        }
        insert list_InvoiceLineItem;
        
         c2g__codaInvoice__c getAmount = [select id, c2g__InvoiceTotal__c from c2g__codaInvoice__c where id =: si.Id limit 1];
        
         Interest_Charged_Calculation__c icc = new Interest_Charged_Calculation__c();
         icc.Days_Overdue__c = 0;
         icc.Interest_Charged__c = 0;      
         icc.Invoice_Due_Date__c = date.today();
         icc.Dunning_Alert__c = DunningAlert;         
         icc.Interest_Rate__c=0;              
         icc.Sales_Invoice__c=si.Id;
         icc.Sales_Invoice_Total__c = getAmount.c2g__InvoiceTotal__c;
         
         insert icc;
         
         Decimal sValue = 0;
         for(Interest_Charged_Calculation__c m_icc :[select id, Sales_Invoice_Total__c, Invoice_Total__c  from Interest_Charged_Calculation__c where Dunning_Alert__c =: DunningAlert]){
             //sValue += m_icc.Sales_Invoice_Total__c;  
             sValue += m_icc.Invoice_Total__c;
         }
         
         Dunning_Alert__c da = new Dunning_Alert__c();
         da.id = DunningAlert;
         da.Amount_Claimed__c = sValue;
         
         update da;
                
         //TODO to Post invoice         
//         c2g.CODAAPICommon.Reference refInvoice = new c2g.CODAAPICommon.Reference();
//         refInvoice.Id = si.Id;
//         system.debug('[BILL_SI_UTIL CreateSI] - journal ref ' + refInvoice.id);
        
//         c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, refInvoice);
//         Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'Success', 'BILL_SI_UTIL.CreateSI', si.ID, ApplicationID);
         // O post depois é feito no trigger.
         si.Posted_InvoiceXpress__c = true;
         si.Post_SalesInvoice__c = true; 
         
         // factura criada, due date no proprio dia, email gerado no dia seguinte. 
         update si;
         
         return si; 
    } 
    
    public c2g__codaInvoice__c createSI_4thReminder(String DunningAlert, ID AccountID, ID ApplicationID, Date DueDate, Date InvoiceDate, String InvoiceDescription, List<Product2> InvoiceLineItems, String externalId, Boolean sepaInative, String DunningDescription, Decimal InterestCharges){
        Bill_ProductRegion billRegion = new Bill_ProductRegion('Input');
        Account acc = [SELECT Id, Tax_Zone__c FROM Account WHERE ID = :AccountID];                                  
        c2g__codaInvoice__c si = new c2g__codaInvoice__c();
        si.c2g__Account__c = AccountID;
        si.Application__c = ApplicationID;
        si.c2g__DueDate__c = DueDate;
        si.c2g__InvoiceDate__c = InvoiceDate; 
        si.c2g__InvoiceDescription__c = InvoiceDescription; 
        si.Collection_Case__c = externalId;  
        
        insert si;
        
        List<c2g__codaInvoiceLineItem__c> list_InvoiceLineItem = new List<c2g__codaInvoiceLineItem__c>();
        for(Product2 p : InvoiceLineItems){
            c2g__codaInvoiceLineItem__c ili = new c2g__codaInvoiceLineItem__c();
            ili.c2g__Invoice__c = si.Id;
            system.debug(p.ProductCode);
            ili.c2g__Product__c = billRegion.getProduct(p.ProductCode, acc.Tax_Zone__c);
            ili.c2g__TaxCode1__c = billRegion.getTaxCode(p.ProductCode, acc.Tax_Zone__c);         
            if(DunningDescription == '4th Reminder'){                  
                if(p.Name == 'Juros de Mora'){                    
                    ili.c2g__UnitPrice__c =  InterestCharges.setScale(2);
                    ili.c2g__DeriveUnitPriceFromProduct__c = false;                     
                } 
            }             
            list_InvoiceLineItem.add(ili); 
        }
        insert list_InvoiceLineItem;
        
         c2g__codaInvoice__c getAmount = [select id, c2g__InvoiceTotal__c from c2g__codaInvoice__c where id =: si.Id limit 1];
        
         Interest_Charged_Calculation__c icc = new Interest_Charged_Calculation__c();
         icc.Days_Overdue__c = 0;
         icc.Interest_Charged__c = 0;      
         icc.Invoice_Due_Date__c = date.today();
         icc.Dunning_Alert__c = DunningAlert;         
         icc.Interest_Rate__c=0;              
         icc.Sales_Invoice__c=si.Id;
         icc.Sales_Invoice_Total__c = getAmount.c2g__InvoiceTotal__c;
         
         insert icc;
         
         Decimal sValue = 0;
         for(Interest_Charged_Calculation__c m_icc :[select id, Sales_Invoice_Total__c, Invoice_Total__c  from Interest_Charged_Calculation__c where Dunning_Alert__c =: DunningAlert]){
             //sValue += m_icc.Sales_Invoice_Total__c;  
             sValue += m_icc.Invoice_Total__c;
         }
         
         Dunning_Alert__c da = new Dunning_Alert__c();
         da.id = DunningAlert;
         da.Amount_Claimed__c = sValue;
         
         update da;
                
         //TODO to Post invoice         
//         c2g.CODAAPICommon.Reference refInvoice = new c2g.CODAAPICommon.Reference();
//         refInvoice.Id = si.Id;
//         system.debug('[BILL_SI_UTIL CreateSI] - journal ref ' + refInvoice.id);
        
//         c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, refInvoice);
//         Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'Success', 'BILL_SI_UTIL.CreateSI', si.ID, ApplicationID);
         // O post depois é feito no trigger.
         si.Posted_InvoiceXpress__c = true;
         si.Post_SalesInvoice__c = true; 
         
         // factura criada, due date no proprio dia, email gerado no dia seguinte. 
         update si;
         
         return si; 
    }   
}