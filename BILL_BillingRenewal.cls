/*************************************************
*   Test Class: BILL_BillingRenewalTest 
* 
* 
*************************************************/

public class BILL_BillingRenewal {
    
    private List<Application__c> app;
    //private List<Billing_Contract__c> billContract;
    
    //Date firstDayOFCurrPeriod = Date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);       
    private Date firstDayOFCurrPeriod;
    
    private List<Billing_Contract_Line_Item__c> lineItemsList = new List<Billing_Contract_Line_Item__c>();
    
    //key= Application
    private Map<ID,Application__c> appMap = new Map<Id, Application__c>();
    //Key=Application Key=Product_Code
    private Map<ID, Map<String,Billing_Contract_Line_Item__c>> billContractItemMap = new Map<ID, Map<String,Billing_Contract_Line_Item__c>>();
    //Key=Application 
    private Map<ID,Account> clientMap = new Map<ID,Account>();
    //Key=Application 
    private Map<ID,Billing_Contract__c> billContractMap = new Map<ID,Billing_Contract__c>();
    
    //private List<ID> prodctIdsList  = new List<ID>();
    
    public void billingRenewal(List<Application__c> rentingAppList){
        
        system.debug('Beginning BillingRenewal');
        Savepoint savePointGeneral = Database.setSavepoint();
        try{
            getData(rentingAppList);            
            // this.region = UTIL_PostCode.getRegionFromPostCode(this.accClient.BillingPostalCode);       
            
            for(Application__c app:rentingAppList){
                renewal(app,Date.Today());
            }
            insert this.lineItemsList;
            
        }catch(Exception e){
            Database.rollback(savePointGeneral);
            Outbound_Integration_Log__c outboundIntegrationLog = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'CRITICAL',ApplicationID__c = 'BillingRenewal',message__c = e.getMessage(),printStackTrace__c = e.getStackTraceString());
            system.debug('CRITICAL: '+ outboundIntegrationLog);
            insert outboundIntegrationLog;
            system.debug(e.getStackTraceString());
        }
    }
    
    public void getData(List<Application__c> rentingAppList){
        //appMap
        for(Application__c appAux : rentingAppList){
            this.appMap.put(appAux.Id, appAux);
        }      
        
        //List<Product2> prodList = [Select Id, ProductCode From Product2 Where ProductCode = 'PT02' or ProductCode = 'PT03' or ProductCode ='PT18' or ProductCode ='PT19'];
        
        //for(Product2 auxProduct : prodList){
        //    this.prodctIdsList.add(auxProduct.id);
        //}
        
        List<account>  accClientList =  [Select id,name, c2g__CODABankIBANNumber__c, c2g__CODATaxCalculationMethod__c,
                                         c2g__CODAAccountsReceivableControl__c, 
                                         c2g__CODAInputVATCode__c, BillingPostalCode, c2g__CODAVATStatus__c, Tax_Zone__c   
                                         from account 
                                         where id IN (Select AccClient__c From Application__c where Id IN :appMap.keySet())];
        
        for(Account accClientAux : accClientList){
            this.clientMap.put(accClientAux.Id,accClientAux);
        }
        
        List<Billing_Contract__c> billingContractList = [Select Id, application__c from Billing_Contract__c where application__c IN :appMap.keySet()];
        
        for(Billing_Contract__c billingContractAux : billingContractList){
            this.billContractMap.put(billingContractAux.application__c,billingContractAux);  
        }
    }
    
    //get Billing Item! Used to check if already exists the specific billing item (PT01,Pt02,...) in the  specific dates. 
    private Billing_Contract_Line_Item__c getBillingItem(ID appId, String product_Code){
        
        //MAP
        
        /* List<Billing_Contract_Line_Item__c> billContractItemList = [select id, name, Line_Item_Start_Date__c, Billing_Contract__c , Product__r.ProductCode , Application__r.ID
from Billing_Contract_Line_Item__c
where Application__r.ID = :appID and Product__r.ProductCode = :product_Code and Line_Item_Start_Date__c >= :date1 AND Line_Item_Start_Date__c <= :date2];*/
        Map<String,Billing_Contract_Line_Item__c> billContractItemMapAux = billContractItemMap.get(appID);
        if(billContractItemMapAux == null)
            return null;
        
        Billing_Contract_Line_Item__c billContractItem = billContractItemMapAux.get(product_Code);
        
        if(billContractItem ==null ){
            return null;
        }
        return billContractItem;
    }
    
    public void renewal(Application__c rentingApp, Date startDate){
        
        Savepoint spApp = Database.setSavepoint();
        try{ 
            this.firstDayOFCurrPeriod = Date.newInstance(startDate.Year(), startDate.Month(), 1);       //current month/year
           // this.firstDayOFCurrPeriod //add 1 month to date to do the renewal of the next month/period

            //if firstDayOFCurrPeriod is less than end_of_term won't renew
            if(this.firstDayOFCurrPeriod.addMonths(1) < Date.newInstance(rentingApp.End_of_Term__c.year(),rentingApp.End_of_Term__c.month(),1)){
                System.debug('Return');
                return;        
            }
            
            //Last period Date. Depends on rentingApp period (Monthly/Quarterly)
            Date lastDayofCurrPeriod  = firstDayOFCurrPeriod.addMonths(BILL_BillingProcess.getPeriodNumberOfMonths(rentingApp)); 
            lastDayofCurrPeriod = lastDayofCurrPeriod.addDays(-1);
            
            Date renewalDate = Date.newInstance(lastDayofCurrPeriod.Year(),lastDayofCurrPeriod.Month(),15); //the renewal date occours on 15th of the last period date
            
            String region = this.clientMap.get(rentingApp.AccClient__c).Tax_Zone__c; 
            System.debug('X');
            List<Billing_Contract_Line_Item__c> itensPerAppList = new List<Billing_Contract_Line_Item__c>();
            if (!(verifyExistenceRentalItens(rentingApp,firstDayOfCurrPeriod,lastDayofCurrPeriod))){
                itensPerAppList = createBillingsRenewal(rentingApp, renewalDate, region);
                if((itensPerAppList!=null)){
                    this.lineItemsList.addAll(itensPerAppList);
                }
            }            
        }catch(Exception e){
            Database.rollback(spApp);
            Outbound_Integration_Log__c outboundIntegrationLog = new Outbound_Integration_Log__c(Start__c=system.today(),Code__c = 'CRITICAL',ApplicationID__c = 'BillingRenewal',message__c = e.getMessage(),printStackTrace__c = e.getStackTraceString());
            system.debug('CRITICAL: '+ outboundIntegrationLog);
            insert outboundIntegrationLog;
            system.debug(e.getStackTraceString());
        }
    }
    
    
    public List<Billing_Contract_Line_Item__c> createBillingsRenewal(Application__c rentingApp, Date renewalDate, String region){
        Bill_ProductRegion billProductRegion = new BILL_ProductRegion();
        ID prod;  
        ID productTaxCode;
        List<Billing_Contract_Line_Item__c> lineItemsList = new List<Billing_Contract_Line_Item__c>();
        
         //return the period of the billing wich can be diferent from the line item start date
         Date billingPeriodDate = Bill_BillingProcess.getBillingPeriodDate(renewalDate,rentingApp.Payment_Freq__c,rentingApp.Payment_Timing__c,rentingApp.Payment_Freq__c);
        
        if(rentingApp.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
            prod = billProductRegion.getProduct('PT18', region);
            productTaxCode = billProductRegion.getTaxCode('PT18', region);
            Billing_Contract_Line_Item__c billLineItem = BILL_BillingProcess.createOneBillLineItem(this.billContractMap.get(rentingApp.Id).Id, rentingApp,renewalDate , billingPeriodDate, prod, rentingApp.Payment_Amount__c, productTaxCode, billProductRegion);
            lineItemsList.add(billLineItem);                                                                            
            System.debug('Cria produto 18 Mensalmente');
            
        }
        if(rentingApp.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY){
            prod = billProductRegion.getProduct('PT19', region);
            productTaxCode = billProductRegion.getTaxCode('PT19', region);            
            Billing_Contract_Line_Item__c billLineItem = BILL_BillingProcess.createOneBillLineItem(this.billContractMap.get(rentingApp.Id).Id, rentingApp,renewalDate ,billingPeriodDate, prod, rentingApp.Payment_Amount__c*3, productTaxCode, billProductRegion);
            lineItemsList.add(billLineItem);                                                                            
            System.debug('Cria produto 19 Trimestralmente');   
            
        }
       
        if(rentingApp.Chosen_Insurance_value__c != 0){  //Insurance Type ou Insurance Value
            prod = billProductRegion.getProduct('PT02', region);
            productTaxCode = billProductRegion.getTaxCode('PT02', region);            
            decimal insurancePrice;
            if(rentingApp.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
                insurancePrice = rentingApp.Chosen_Insurance_value__c;
            }else if(rentingApp.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY){
                insurancePrice = rentingApp.Chosen_Insurance_value__c * 3;
            }
        
            // List<Billing_Contract_Line_Item__c> insuranceList = BILL_BillingProcess.createPeriodicBillLineItems(this.billContractMap.get(rentingApp.Id),rentingApp, 1, this.renewalDate, prod, insurancePrice);
            Billing_Contract_Line_Item__c insurance = BILL_BillingProcess.createOneBillLineItem(this.billContractMap.get(rentingApp.Id).Id, rentingApp, renewalDate,billingPeriodDate, prod,insurancePrice, productTaxCode, billProductRegion);
            lineItemsList.add(insurance);             
        }
            
        if (rentingApp.ATM_Reference__c){
            prod = billProductRegion.getProduct('PT03', region);
            productTaxCode = billProductRegion.getTaxCode('PT03', region);           

            Billing_Contract_Line_Item__c billLineItem = BILL_BillingProcess.createOneBillLineItem(this.billContractMap.get(rentingApp.Id).Id, rentingApp,renewalDate , billingPeriodDate, prod, rentingApp.ATM_Reference_Costs__c, productTaxCode, billProductRegion);
            lineItemsList.add(billLineItem);
            System.debug('Cria produto 3');    
        }else{
            system.debug('Sem ATM reference!!');
        }
        return lineItemsList;
    }
    
    private boolean verifyExistenceRentalItens(Application__c app, Date firstDayOfCurrPeriod, Date lastDayofCurrPeriod){
        List<Billing_Contract_Line_Item__c> billContractItemList = [select id, name, Line_Item_Start_Date__c, Billing_Contract__c ,Product__r.Id, Product__r.ProductCode , Application__r.ID
                                                                    from Billing_Contract_Line_Item__c
                                                                    where Application__r.ID IN :this.appMap.keySet() AND Product__r.ProductCode IN ('PT02', 'PT03', 'PT18', 'PT19') AND Line_Item_Start_Date__c >= :firstDayOfCurrPeriod AND Line_Item_Start_Date__c <= :lastDayofCurrPeriod];
        system.debug('billContractItemList '+billContractItemList);       
        Map<String,Billing_Contract_Line_Item__c> billMapPerCode = new Map<String,Billing_Contract_Line_Item__c>();
        for(Billing_Contract_Line_Item__c billItem :billContractItemList){
            System.debug('billItem ' + billItem);
            
            billMapPerCode.put(billItem.Product__r.ProductCode, billItem);
            this.billContractItemMap.put(billItem.Application__r.Id, billMapPerCode);
        }
        
        Billing_Contract_Line_Item__c billing;
        if(app.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
            billing = getBillingItem(app.Id, 'PT18');
        }
        if(app.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY){
            billing =  getBillingItem(app.Id, 'PT19');
        }
        if(billing==null){
            return false;
        }else{
            return true;
        }
    }
    
    
}