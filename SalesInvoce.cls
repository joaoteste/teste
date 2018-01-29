global class SalesInvoce{
    
    //List<c2g__codaInvoice__c> newSalesInvoice = new List<c2g__codaInvoice__c>();
    
    public static boolean create(List<Id> Ids, String reminder){
        
        Map<Id, List<c2g__codaInvoice__c>> map_SalesInvoives = new Map<Id, List<c2g__codaInvoice__c>>(); 
        
        List<c2g__codaInvoice__c> m_ListCC = [Select Id, c2g__InvoiceTotal__c, Collection_Case__c, c2g__PaymentStatus__c, Application__c From c2g__codaInvoice__c where Collection_Case__c =: Ids];
        for(c2g__codaInvoice__c coda : m_ListCC){            
            if(map_SalesInvoives.containsKey(coda.Collection_Case__c)){
                map_SalesInvoives.get(coda.Collection_Case__c).add(coda);
            }else{
                List<c2g__codaInvoice__c> l_ci =  new List<c2g__codaInvoice__c>();
                l_ci.add(coda);
                map_SalesInvoives.put(coda.Collection_Case__c,l_ci);        
            }
        } 
        
        Map<String, Dunning_Admin__c> map_Case_DunningAdmin = new  Map<String, Dunning_Admin__c>();
        List<Dunning_Admin__c> l_DunningAdmin = [Select Id,Past_Due_Days__c,Nr_of_Days_to_Pay__c,Email_Template__c,Dunning_Level__c,Dunning_Frequency__c,Active__c, (Select id, Product__c,Product_Name__c, Product_Code__c, Product__r.Id, Product__r.Name, Product__r.ProductCode From Dunning_Products__r) from Dunning_Admin__c where Active__c='Yes'];
        for(Dunning_Admin__c m_da: l_DunningAdmin){
            map_Case_DunningAdmin.put(m_da.Dunning_Level__c, m_da); 
        }
        
        for(Collection_Case__c cc : [SELECT Id,Name,Account__c,Invoices_Due__c, Amount_Claimed__c, (Select Id,Dunning_Level__c,Level__c,Total_Interest_Charges__c,Amount_Claimed__c From Dunning_Alerts__r order by Level__c desc limit 1) FROM Collection_Case__c where id=:Ids]){ 
            Dunning_Admin__c daLevel = map_Case_DunningAdmin.get(reminder);             
            List<Product2> InvoiceLineItems = new List<Product2>();
            for(Dunning_Product__c tes: daLevel.Dunning_Products__r){
            system.debug('AQUI' + tes);
                Product2 pp = new Product2();
                pp.Id = tes.Product__c; 
                pp.Name = tes.Product_Name__c;  
                pp.ProductCode = tes.Product_Code__c;
                InvoiceLineItems.add(pp);
            }  
            
            Id applicationId = null;
            List<c2g__codaInvoice__c> l_coda = map_SalesInvoives.get(cc.Id); 
            List<Id> sIDInvoice = new List<Id>();
            for(c2g__codaInvoice__c ci: l_coda){
                sIDInvoice.add(ci.id);
                applicationId = ci.Application__c;     // TODO não devia ser necessário. é para retirar quando a criação dos sales invoices não depender da 'Renting application'
            }
          
            BILL_SI_UTIL billSIUtil = new BILL_SI_UTIL(); 
            if(daLevel.Dunning_Level__c == '3rd Reminder'){
                                  Dunning_Alert__c da_alert=cc.Dunning_Alerts__r;                 
                billSIUtil.createSI_3rdReminder(da_alert.Id, cc.Account__c,applicationId,Date.today(), Date.today(), cc.Name,InvoiceLineItems, cc.Id, True, daLevel.Dunning_Level__c,da_alert.Total_Interest_Charges__c);
            }
            else if(daLevel.Dunning_Level__c == '4th Reminder'){
                Dunning_Alert__c da_alert=cc.Dunning_Alerts__r;                 
                billSIUtil.createSI_4thReminder(da_alert.Id, cc.Account__c,applicationId,Date.today(), Date.today(), cc.Name,InvoiceLineItems, cc.Id, True, daLevel.Dunning_Level__c,da_alert.Total_Interest_Charges__c);
            }           
            else{  
                billSIUtil.CreateSI(cc.Account__c,applicationId,Date.today(), Date.today(), cc.Name,InvoiceLineItems, cc.Id, True);         
            }          
        } 
     
        return true;
    }
}