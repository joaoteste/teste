//Tests: PaymentCollection_UtilsTest, SEPA_SI_to_SR_TEST
public class PaymentCollection_Utils {
    
//TODO os metodos podem passar a estáticos
    public Map<String, String> createPaymentCollectionWithATM(Decimal total, ID act, ID per, Date expiryDate, Integer reference, ID si, ID app){
        Map<String, String> infoMap = new Map<String, String>();
        
        Payment_Collection__c pc = createPaymentCollection(act, per, expiryDate);
        infoMap.put('pc', pc.ID);
        
        ATM_Reference__c atm = createATMReference(total, reference, expiryDate, pc.ID);
        infoMap.put('atm', atm.ID);
        
        Receipt_Line_Item__c rli = createPaymentCollectionReceiptLineItems(pc.ID, app, total, si);
        insert rli; 
        infoMap.put('rli', rli.ID);        
         
        return infoMap;
    }    
    
    //list[0] = atmID ; list[1] = pcID
    public List<ID> createPaymentCollectionWithPartialInvoicePayments(List<Partial_Invoice_Payment__c> pipList, Double totalAmount, ID paymentScheduleID, Date dueDate, ID clientAccountID){
        List<ID> infoList = new List<ID>();
        
        Bill_EasyPayAPI bill = new Bill_EasyPayAPI();
        
        ATM_Reference__c atm =  bill.getNewMBReference(String.valueOf(totalAmount), dueDate, paymentScheduleID, paymentScheduleID);
        insert atm;
        infoList.add(atm.ID);    
        
        ID per = getPeriod();
        Payment_Collection__c pc = createPaymentCollection(clientAccountID, per, dueDate);
        infoList.add(pc.ID);
        
        List<Receipt_Line_Item__c> rliList = new List<Receipt_Line_Item__c>();
        
        for(Partial_Invoice_Payment__c pip : pipList){
            rliList.add(createPaymentCollectionReceiptLineItemsPIP(pc.ID, pip.Amount__c, pip.ID));
        }
        
        atm.Payment_Collection__c = pc.ID;   
        update atm;
        
        insert rliList;
        
        return infoList;
        
    }
    
    
    
     public Map<String, String> createPaymentCollectionWithATM(Decimal total, Date expiryDate, ID dunningAlert, String obs){
        Map<String, String> infoMap = new Map<String, String>();
        Bill_EasyPayAPI bill = new Bill_EasyPayAPI();
        
        List<c2g__codaInvoice__c> salesInvoiceList = getSalesInvoiceForDunningAlert(dunningAlert);
        c2g__codaInvoice__c salesInvoice = salesInvoiceList.get(0);
         
        ID act = salesInvoice.c2g__Account__c;
        ID per = getPeriod();
        ID app = salesInvoice.Application__c;       
        
        ATM_Reference__c atm =  bill.getNewMBReference(String.valueOf(total), expiryDate, dunningAlert, obs);
        insert atm;
        infoMap.put('atm', atm.ID);
        
        Payment_Collection__c pc = createPaymentCollection( act, per, expiryDate);
        infoMap.put('pc',pc.ID);
        
        atm.Payment_Collection__c = pc.ID;
        system.debug('atm: ' + atm);
        update atm;       
        
    	List<Receipt_Line_Item__c> rliList = new List<Receipt_Line_Item__c>();        
        for(c2g__codaInvoice__c si : salesInvoiceList){
            rliList.add(createPaymentCollectionReceiptLineItems(pc.ID, app, si.c2g__InvoiceTotal__c, si.ID));    
        }     
        
        insert rliList; 
        
        return infoMap;
    }
    
    public Map<String, String> createPaymentCollectionWithATM(List<ATM_Reference__c> listATM){
        Map<String, String> infoMap = new Map<String, String>();       
        List<Receipt_Line_Item__c> rliList = new List<Receipt_Line_Item__c>();
        
        for(ATM_Reference__c atm: listATM){
             
            List<c2g__codaInvoice__c> salesInvoiceList = getSalesInvoiceForDunningAlert(atm.Dunning_Alert__c);
            c2g__codaInvoice__c salesInvoice = salesInvoiceList.get(0);
            
            ID act = salesInvoice.c2g__Account__c;
            ID per = getPeriod();
            ID app = salesInvoice.Application__c;       
            
            Payment_Collection__c pc = createPaymentCollection( act, per, atm.Expiry_date__c);
            infoMap.put('pc',pc.ID);
            infoMap.put('atm',atm.ID);
            
            atm.Payment_Collection__c = pc.ID;
            update atm;       
            
            for(c2g__codaInvoice__c si : salesInvoiceList){
                rliList.add(createPaymentCollectionReceiptLineItems(pc.ID, app, si.c2g__InvoiceTotal__c, si.ID));    
            }   
        
        }
        
        insert rliList;                 
        
        return infoMap;
    }
    
	public Map<String, String> createPaymentCollectionWithATM(ATM_Reference__c atm, List<c2g__codaInvoice__c> salesInvoiceList){
        Map<String, String> infoMap = new Map<String, String>();       
        
        c2g__codaInvoice__c salesInvoice = salesInvoiceList.get(0);
            
        ID act = salesInvoice.c2g__Account__c;
        ID per = getPeriod();
        ID app = salesInvoice.Application__c;       
            
        Payment_Collection__c pc = createPaymentCollection(act, per, atm.Expiry_date__c);
        infoMap.put('pc',pc.ID);
        infoMap.put('atm',atm.ID);
            
        atm.Payment_Collection__c = pc.ID;
        update atm;       
            

    	List<Receipt_Line_Item__c> rliList = new List<Receipt_Line_Item__c>();
        for(c2g__codaInvoice__c si : salesInvoiceList){
        	rliList.add(createPaymentCollectionReceiptLineItems(pc.ID, app, si.c2g__InvoiceTotal__c, si.ID));    
        } 
        
        insert rliList;     
        
        return infoMap;
    }    
    
    private List<c2g__codaInvoice__c> getSalesInvoiceForDunningAlert(ID dunningAlert){
        
        Dunning_Alert__c da = [SELECT ID, Collection_Case__c FROM Dunning_Alert__c WHERE ID = :dunningAlert];
        
        List<c2g__codaInvoice__c> salesInvoiceList = [SELECT ID, Application__c, c2g__InvoiceTotal__c, c2g__Period__c, c2g__Account__c, Collection_Case__c FROM c2g__codaInvoice__c WHERE Collection_Case__c = :da.Collection_Case__c AND (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid')];
        
        return salesInvoiceList;
        
    }
 
    public Payment_Collection__c createPaymentCollection(ID act, ID per, Date expiryDate){
        Payment_Collection__c pc = new Payment_Collection__c();
        pc.Account__c = act;
        //pc.Amount__c= total;
        pc.Expiry_Date__c = expiryDate;
        pc.Period__c = per;
        pc.Status__c = 'In Payment';
        //FIXME
        pc.Payment_Method__c = 'ATM Reference';
        insert pc;
        return pc;
    }   
    
    
    
    
    public ATM_Reference__c createATMReference(Decimal value, Decimal reference, Date expiryDate, ID pc){
        ATM_Reference__c atm = new ATM_Reference__c();
        atm.Entity__c = 10611;
        atm.Amount__c = value;
        atm.MB_Reference__c = reference;   
        atm.MB_Payment_Status__c = 'Not Payed';
        atm.Expiry_date__c = expiryDate;
        atm.Payment_Collection__c = pc;
        insert atm; 
        return atm;   
    }
    
    public Receipt_Line_Item__c createPaymentCollectionReceiptLineItems(ID paymentCollection, ID app, Decimal total, ID si){

        //receipt line item
        
        Receipt_Line_Item__c rli = new Receipt_Line_Item__c();
        rli.Payment_Collection__c = paymentCollection;
        rli.Amount_Claimed__c = total;
        rli.First_try__c = system.today();
        rli.Invoice__c = si;
        rli.Renting_Application__c = app;
        
        return rli;
                    
    }
    
    public Receipt_Line_Item__c createPaymentCollectionReceiptLineItemsPIP(ID paymentCollection, Decimal total, ID pipID){

        //receipt line item
        
        Receipt_Line_Item__c rli = new Receipt_Line_Item__c();
        rli.Payment_Collection__c = paymentCollection;
        rli.Amount_Claimed__c = total;
        rli.Partial_Invoice_Payment__c = pipID;
        
        return rli;
                    
    }    

    //returns the current period ID
    public ID getPeriod(){      
        Date d = Date.today();
        system.debug(LoggingLevel.INFO, 'c2g__codaPeriod__c getPeriod periodDate' + d.format());
        Date periodDate = Date.newInstance(d.year(), d.month(), d.day());
        return getPeriod(periodDate).Id;
    }
    
    //given a date returns the period associated
    public c2g__codaPeriod__c getPeriod(date periodDate) {
        system.debug(LoggingLevel.INFO, 'c2g__codaPeriod__c getPeriod periodDate' + periodDate);
        c2g__codaPeriod__c currentPeriod = [SELECT ID FROM c2g__codaPeriod__c where c2g__StartDate__c <= :periodDate AND c2g__EndDate__c >= :periodDate];
        return currentPeriod;
    }       

}