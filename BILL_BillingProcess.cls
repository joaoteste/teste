// Dates important for the process
// Most of the dates are not calculated in this Class
//
//      |------------|---------------|------------------------------------------------------| - - - - - - - - - - - - - - -|
//                                   |                                                      |
//         Contract Settlement Date                                                    End of Term
//          Invoice_Payment_Date__c
//      |
//Delivery Certificate Signed
//Delivery_Certificate_Signed__c     
//                                    |   
//                            Beginning of Term 
//                           Beginning_of_Term__c
//
//  Interim_Fee_Days__c == prorata days.
//
//       |-----------------------------|
//               Interim Fee Days
//         Insurance Pro-Rata Value + Interim Fee Amount



public class BILL_BillingProcess {
    public static String PAYMENT_FREQ_MONTHLY = 'Monthly';
    public static String PAYMENT_FREQ_QUARTERLY = 'Quarterly';
    
    public static String PAYMENT_TIMING_ADVANCED = 'ADVANCED';
    public static String PAYMENT_TIMING_ARREAS = 'ARREAS';
    
    public static String PAYMENT_METHOD_ATM = 'ATM REFERENCE';

    //public  boolean QA=false;//BP     
    private List<c2g__codaJournal__c> journalList;
    private c2g__codaJournal__c journal;
    private application__c app;
    private account accClient;
    private account accVendor;
    
    private Integer periodNumberOfMonths;
    private Savepoint sp = null;
    
    private boolean toPost = true;
    
    public Bill_ProductRegion billProductRegion = new BILL_ProductRegion('Input');

    public list<c2g__codainvoice__c> invoicesCreated;
    
    public void createBillingInvoice(ID appId ){
        system.debug('createBillingInvoice'); 
        try{
            sp = Database.setSavepoint();
            
            //Get Data
            getAllData(appId);
            
            //String region = UTIL_PostCode.getRegionFromPostCode(accClient.BillingPostalCode);
            String region = accClient.Tax_Zone__c;
            system.debug(region);
            if(region == null){
                System.debug('Error invalid region.');
                // Rollback to the previous value
                Database.rollback(sp);
                return;
            }
            
            this.periodNumberOfMonths = getPeriodNumberOfMonths(this.app);
            //Journal Contract Beginning
            
            if(!Test.isRunningTest()){
                System.enqueueJob(new ContractBeginningJournalQueue(this.app.id));
            }
            
            //Billing contract
            BillingAdmin__c billAdmin = getBillAdmin();
            if(billAdmin == null){
                system.debug('Error in billAdmin');
                // Rollback to the previous value
                Database.rollback(sp);
                return;
            }
            
            Date initialInvoiceDate = getInvoiceDate(billAdmin);
            
            //Bill Line Items
            Billing_Contract__c billContrat = createBillContract();
            system.debug('Billing_Contract__c'+billContrat);
            system.debug(region);
            creatBillContractLineItems(billContrat, initialInvoiceDate, region);
            
            // Invoices
            createInvoices(billContrat);
            
            // Update app
            //set generate billing contract to false to never generate billing for this record again
            app.Generate_Billing__C=false;
            /*
            if(app.Delivery_Certificate_Sent__c >= Date.newInstance(2017, 11, 06)){
                app.Renewal_Frequency__c = '6 Months';
            }else{
                if(app.Payment_Freq__c == PAYMENT_FREQ_MONTHLY){
                    app.Renewal_Frequency__c = '1 Month';
                }else {
                    app.Renewal_Frequency__c = '3 Months';
                }
            }
            */
            system.debug('Update APP: '+app);
            update app;
            
            //settle the insurance managment
            List<Insurance_Management__c> insurance = [Select ID,Renting_Application__c, Insurance_Policy_Number__c,Client_Policy_Beginning_Term__c,Submitted__c,Insurance_Status__c
                                                       From Insurance_Management__c
                                                       where Renting_Application__c = :appId
                                                       order by CreatedDate Desc 
                                                       limit 1];
            
            if(!insurance.isEmpty()){
                String msg = InsuranceManagement.settleInsuranceManagement(insurance[0], app.Insurance_Type__c, 'Candor', app.Chosen_Insurance_value__c, app.Insurance__c);
            }else{
                InsuranceManagement.createAndSettleInsurance(app.Name);
            }

        }catch(exception e){
            system.debug('ERROR: in BILL_BillingProcess createBillingInvoice');
            System.debug('exception: '+ e.getStackTraceString());
            // Rollback to the previous value
            Database.rollback(sp);
            
            // To see the exception
            throw e;
            return;
        }
    }
    
    public void getAllData(ID appId){
        this.app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                  Equipment_Cost__c, Vendor_invoice_VAT__c,Chosen_Insurance_value__c, Interim_Fee_Days__c, 
                  Original_Insurance_Value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                  Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, Payment_Method__c, eSignature_Contract_Fee__c, TermCalc__c,
                  ATM_Reference_Costs__c, ATM_Reference__c, Insurance_Amount__c, Paper_Contract_Fee__c, Amortization_Interest_Rate__c,
                  Insurance_Pro_Rata__c, Original_Insurance_ProRata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                  Interest_Amount__c, annual_interest_rate__c, accClient__r.c2g__CODAInvoiceEmail__c,  status__c,Price_Book__c,Delivery_Certificate_Sent__c
                  from application__c 
                  where id= :appId ];
        //Are these fields used?
        if(app.Original_Insurance_Value__c==null)
            app.Original_Insurance_Value__c=app.Chosen_Insurance_value__c;
        if(app.Original_Insurance_ProRata__c==null)
            app.Original_Insurance_ProRata__c=app.Insurance_Pro_Rata__c;
      //  System.debug(' Original_Insurance_Value__c --> '+ app.Original_Insurance_Value__c);
      //  System.debug(' Original_Insurance_ProRata__c --> '+ app.Original_Insurance_ProRata__c);
        
        this.accClient =        [select id,name, c2g__CODABankIBANNumber__c, c2g__CODATaxCalculationMethod__c,
                                 c2g__CODAAccountsReceivableControl__c, 
                                 c2g__CODAInputVATCode__c, BillingPostalCode, c2g__CODAVATStatus__c, Tax_Zone__c
                                 from account 
                                 where id= :app.AccClient__c];
        
        this.accVendor =       [select id, name, c2g__CODABankIBANNumber__c  
                                from account 
                                where id= :app.vendor__C];
        
        
        
        
        
        // system.debug('All product in Map productMap' + this.productMap);                      
    }
        
    private Billing_Contract__c createBillContract(){
        Date billdate;
        
        if (app.Invoice_Payment_Date__c < date.today()){
            billdate=date.today();
        }
        else{
            billdate=app.Invoice_Payment_Date__c;
        }
        
        Billing_Contract__c billCont = New Billing_Contract__c(Name=app.Name, Account__c=accClient.Id, Account_Vendor__c=accVendor.Id, Equipment_Cost__c = app.Equipment_Cost__c,
                                                               Contract_Start_Date__c= app.Beginning_of_Term__c,
                                                               Billing_Date_Override__c=billdate, application__c=app.id  );
        
        if(app.Delivery_Certificate_Sent__c >= Date.newInstance(2017, 11, 06)){
            billCont.Renewal_Frequency__c = '6 Months';
        }else{
            if(app.Payment_Freq__c == PAYMENT_FREQ_MONTHLY){
                billCont.Renewal_Frequency__c = '1 Month';
            }else {
                billCont.Renewal_Frequency__c = '3 Months';
            }
        }
        
        //     System.debug('billCont: ' + billCont);
        insert billCont;
        
        return billCont;
    }
    
    public void creatBillContractLineItems(Billing_Contract__c billCont, Date initialInvoiceDate, String region){
        system.debug('billContractLineItems');
        
        Integer numberOfPayment = numberOfPayments();
        
        //Create all bill line Items Create product by product
        List<Billing_Contract_Line_Item__c> allBillLineItemsList = new List<Billing_Contract_Line_Item__c>();
        
        Date propBillingPeriod = getBillingPeriodDate(app.Delivery_Certificate_Signed__c, this.app.Payment_Freq__c,this.app.Payment_Timing__c, 'One Time');
        
        //Products the product are nor order by the name but by the order that I want to see in the list (yes I know that the order is not guaranteed :-( , but is not critical :-) ...)
        
        // 1st prorata values
        //Product PT08 Aluguer Mensal Proporcional Equipamento CANDOR RENTING S.A.
        if(this.app.Payment_Freq__c == PAYMENT_FREQ_MONTHLY && app.Interim_Fee_Amount__c != 0){
            ID prod = this.billProductRegion.getProduct('PT08', region);
            ID productTaxCode = this.billProductRegion.getTaxCode('PT08', region);
            decimal prorataQuarterlyPrice = app.Interim_Fee_Amount__c;
            
            Billing_Contract_Line_Item__c billLineItem = createOneBillLineItem(billCont.Id,app, app.Invoice_Payment_Date__c, propBillingPeriod, prod, prorataQuarterlyPrice, productTaxCode, this.billProductRegion);
            billLineItem.Billing_Frequency__c = 'One Time';
            billLineItem.Billing_Period_Date__c = getBillingPeriodDate(app.Invoice_Payment_Date__c, this.app.Payment_Freq__c,this.app.Payment_Timing__c, 'One Time');
            allBillLineItemsList.add(billLineItem);
        }
        
        //Product PT10 Aluguer Trimestral Proporcional Equipamento CANDOR RENTING S.A.
        if(this.app.Payment_Freq__c == PAYMENT_FREQ_QUARTERLY && app.Interim_Fee_Amount__c != 0){
            ID prod = this.billProductRegion.getProduct('PT10', region);
            ID productTaxCode = this.billProductRegion.getTaxCode('PT10', region);          
            decimal prorataQuarterlyPrice = app.Interim_Fee_Amount__c;
            Billing_Contract_Line_Item__c billLineItem = createOneBillLineItem(billCont.Id, app, app.Invoice_Payment_Date__c, propBillingPeriod, prod, prorataQuarterlyPrice, productTaxCode, this.billProductRegion);
            billLineItem.Billing_Frequency__c = 'One Time';
            billLineItem.Billing_Period_Date__c = getBillingPeriodDate(app.Invoice_Payment_Date__c, this.app.Payment_Freq__c,this.app.Payment_Timing__c, 'One Time');
            allBillLineItemsList.add(billLineItem);
        }
        
        //Product PT11 Prémio de Seguro Proporcional
        if(app.Insurance_Pro_Rata__c!=0){
            ID prod = this.billProductRegion.getProduct('PT11', region);
            ID productTaxCode = this.billProductRegion.getTaxCode('PT11', region);                  
            decimal insuranceProRata = app.Insurance_Pro_Rata__c;
            Billing_Contract_Line_Item__c billLineItem = createOneBillLineItem( billCont.Id, app, app.Invoice_Payment_Date__c,propBillingPeriod, prod, insuranceProRata, productTaxCode, this.billProductRegion);
            billLineItem.Billing_Frequency__c = 'One Time';
            billLineItem.Billing_Period_Date__c = getBillingPeriodDate(app.Invoice_Payment_Date__c, this.app.Payment_Freq__c,this.app.Payment_Timing__c, 'One Time');
            allBillLineItemsList.add(billLineItem);
        }
        
        List<Billing_Contract_Line_Item__c> prodLineItems;
        // 2nd one time payments 
        //Product PT03 Pagamento por Multibanco
        if((app.ATM_Reference__c == TRUE) && (app.Payment_Method__c == PAYMENT_METHOD_ATM)){
            ID prod = this.billProductRegion.getProduct('PT03', region);
            ID productTaxCode = this.billProductRegion.getTaxCode('PT03', region);
            Decimal mbValue = [Select PriceBook2.Name, Product2.Id, Product2.Name, UnitPrice, Name, Product2.c2g__CODAInputTaxCode__c,PriceBook2.id
                               From PricebookEntry 
                               WHERE Product2.id = :prod and PriceBook2.id = :app.Price_Book__c].UnitPrice;
            prodLineItems = createPerBilling_BillLineItems(billCont, app, numberOfPayment, initialInvoiceDate, app.Invoice_Payment_Date__c, prod, mbValue, productTaxCode);
            allBillLineItemsList.addall(prodLineItems);
        }
        
        //Product PT04 not used in this process
        //Product PT05 not used in this process
        
        //Product PT06 Custos de Documentação Contrato Digital
        if(app.eSignature_Contract_Fee__c != 0){
            ID prod = this.billProductRegion.getProduct('PT06', region);
            ID productTaxCode = this.billProductRegion.getTaxCode('PT06', region);  
            decimal eFee = app.eSignature_Contract_Fee__c;
            Billing_Contract_Line_Item__c billLineItem = createOneBillLineItem( billCont.Id, app, app.Invoice_Payment_Date__c,propBillingPeriod, prod, eFee, productTaxCode, this.billProductRegion);
            billLineItem.Billing_Frequency__c = 'One Time';
            allBillLineItemsList.add(billLineItem);
        }
        
        //Product PT07 Custos de Documentação Contrato em Papel
        if(app.Paper_Contract_Fee__c != 0){
            ID prod = this.billProductRegion.getProduct('PT07', region);
            ID productTaxCode = this.billProductRegion.getTaxCode('PT07', region);              
            decimal paperFee = app.Paper_Contract_Fee__c;
            Billing_Contract_Line_Item__c billLineItem = createOneBillLineItem( billCont.Id,app, app.Invoice_Payment_Date__c,propBillingPeriod, prod, paperFee, productTaxCode, this.billProductRegion);
            billLineItem.Billing_Frequency__c = 'One Time';
            allBillLineItemsList.add(billLineItem);
        }
        
        //Product PT01 Aluguer Mensal Equipamento CANDOR RENTING S.A.
        if(this.app.Payment_Freq__c == PAYMENT_FREQ_MONTHLY){  
            ID prod = this.billProductRegion.getProduct('PT01', region);          
            ID productTaxCode = this.billProductRegion.getTaxCode('PT01', region);
            decimal rentMensalPrice = this.app.Payment_Amount__c;
            prodLineItems = createPeriodicRentBillLineItems(billCont, numberOfPayment, initialInvoiceDate, prod, rentMensalPrice, productTaxCode);
            allBillLineItemsList.addall(prodLineItems);
        }
        
        
        //Product PT09 Aluguer Trimestral Equipamento CANDOR RENTING S.A.
        if(this.app.Payment_Freq__c == PAYMENT_FREQ_QUARTERLY){
            ID prod = this.billProductRegion.getProduct('PT09', region);  
            ID productTaxCode = this.billProductRegion.getTaxCode('PT09', region);          
            decimal rentMensalPrice = app.Payment_Amount__c * 3;
            System.debug('billCont, numberOfPayment, initialInvoiceDate, prod, rentMensalPrice: '+billCont+' '+numberOfPayment+' '+initialInvoiceDate+' '+prod+' '+rentMensalPrice);
            prodLineItems = createPeriodicRentBillLineItems( billCont, numberOfPayment, initialInvoiceDate, prod, rentMensalPrice, productTaxCode);
            allBillLineItemsList.addall(prodLineItems);
        }
        
        
        //Product PT02 Prémio de Seguro // pagamento periodico
        ID prod = this.billProductRegion.getProduct('PT02', region);
        ID productTaxCode = this.billProductRegion.getTaxCode('PT02', region);              
        if(app.Chosen_Insurance_value__c != 0){  //Insurance Type ou Insurance Value
            decimal insurancePrice;
            if(app.Payment_Freq__c == PAYMENT_FREQ_MONTHLY){
                insurancePrice = app.Chosen_Insurance_value__c;
            }else if(app.Payment_Freq__c == PAYMENT_FREQ_QUARTERLY){
                insurancePrice = app.Chosen_Insurance_value__c * 3;
            }
            List<Billing_Contract_Line_Item__c> prodP02LineItems = createPeriodicBillLineItems(billCont, app, numberOfPayment, initialInvoiceDate, prod, insurancePrice, productTaxCode);
            if (prodP02LineItems.size()>0){
                allBillLineItemsList.addall(prodP02LineItems);
            }
        }
        System.debug('Limits before insert allBillLineItemsList'+Limits.getQueries());
        insert allBillLineItemsList;
        system.debug(allBillLineItemsList);
        System.debug('Limits after insert allBillLineItemsList '+Limits.getQueries());
    }
    
    public List<Billing_Contract_Line_Item__c> createPeriodicRentBillLineItems(Billing_Contract__c billCont, Integer numberOfPayment, date initialInvoiceDate, ID prod, decimal price, ID productTaxCode){
        List<Billing_Contract_Line_Item__c> lineItemsList = new List<Billing_Contract_Line_Item__c>();
        
        Integer period;
        if(this.app.Payment_Freq__c == PAYMENT_FREQ_MONTHLY){
            period = 12;
        }else if(this.app.Payment_Freq__c == PAYMENT_FREQ_QUARTERLY){
            period = 4;     
        }
        
        decimal beginning_Balance=app.Equipment_Cost__c;
        decimal interest=(app.Amortization_Interest_Rate__c/period/100 * beginning_Balance).setScale(3);
        decimal principal=(price-interest).setscale(3);
        decimal endBalance=(beginning_Balance-principal).setscale(3);
        
        for(Integer perNumber=0; perNumber < numberOfPayment; perNumber++){
            
            //returns the billings Line Item Start Date checked
            Date lineItemStartDate = getLineItemStartDate(perNumber, initialInvoiceDate,this.app);
            
            //return the period of the billing wich can be diferent from the line item start date
            Date billingPeriodDate = getBillingPeriodDate(getBillingInvoiceDate(perNumber,this.app),app.Payment_Freq__c,this.app.Payment_Timing__c,this.app.Payment_Freq__c);
            
            System.debug('Principal='+ principal+ ' ...endBalance='+endBalance);
            //on the last rent adds the remaining endbalance to principal
            if(perNumber==(numberOfPayment-1)){
                System.debug('Before adding remaining. Principal='+ principal+ ' ...endBalance='+endBalance);
                principal = principal + endBalance;
                endBalance = beginning_Balance - principal;
                System.debug('After adding remaining. Principal='+ principal+ ' ...endBalance='+endBalance);
            }

            //system.debug('lineItemStartDate: ' + lineItemStartDate);
            Billing_Contract_Line_Item__c billContLineItem = createOneRentBillLineItem(billCont, lineItemStartDate,billingPeriodDate, prod,price, perNumber, beginning_Balance, interest, principal, endBalance, productTaxCode);
            //system.debug('billContLineItem:' + billContLineItem);
            
            beginning_Balance=endBalance;
            interest=(app.Amortization_Interest_Rate__c/period/100 * beginning_Balance).setScale(3);
           
            principal=(price-interest).setscale(3);
            endBalance=(beginning_Balance-principal).setscale(3);
            
            
            lineItemsList.add(billContLineItem);                                                                                    
        }
        
        return lineItemsList;
    }
    
    private Billing_Contract_Line_Item__c createOneRentBillLineItem(Billing_Contract__c billCont, date invoiceDate,date billingPeriodDate, ID prod, decimal price, Integer perNumber,
                                                                    decimal beginning_Balance, decimal interest, decimal principal, decimal endBalance, ID productTaxCode){
                                                                        /*        system.debug('createOneBillLineItem');
system.debug('billCont' + billCont);
system.debug('invoiceDate' + invoiceDate);
system.debug('prod' + prod);
system.debug('price' + price);
*/       
                                                                        boolean active=true;
                                                                        
                                                                        Date dueDate;
                                                                        if(this.app.Payment_Timing__c == 'Advanced'){
                                                                            dueDate = getLineItemEndDateAdvanced(invoiceDate);
                                                                        }else if(this.app.Payment_Timing__c == 'Arreas'){
                                                                            dueDate = getLineItemEndDateArreas(invoiceDate);
                                                                        }
                                                                        
                                                                        
                                                                        Billing_Contract_Line_Item__c billContLineItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=billCont.id, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                                                                                         Line_Item_Start_Date__c=invoiceDate, Line_Item_End_Date__c=dueDate, Active__c=active,
                                                                                                                                                         Sales_Price__c=price, Product__c=prod, Quantity__c=1, 
                                                                                                                                                         //Last_Invoiced__c=invoiceDate,
                                                                                                                                                         Beginning_Balance__c=beginning_Balance, 
                                                                                                                                                         interest__c=interest, Principal__C=principal,
                                                                                                                                                         Ending_Balance__c=endBalance, application__c=app.id, Product_Tax_Code__c = productTaxCode,
                                                                                                                                                         Billing_Period_Date__c =billingPeriodDate //getBillingPeriodDate(invoiceDate,app.Payment_Freq__c,this.app.Payment_Timing__c,app.Payment_Freq__c)
                                                                                                                                                         );
                                                                        
                                                                        billContLineItem.Billing_Period__c = setBillingPeriod(billProductRegion.getProductCode(prod),billContLineItem.Billing_Period_Date__c,'PT',app.Payment_Freq__c);
                                                                        
                                                                        system.debug('billContLineItem:' + billContLineItem);
                                                                        
                                                                        return billContLineItem;
                                                                    }
    
    public List<Billing_Contract_Line_Item__c> createPeriodicBillLineItems(Billing_Contract__c billCont, application__c app, Integer numberOfPayment, date initialInvoiceDate, ID prod, decimal price, ID productTaxCode){
        List<Billing_Contract_Line_Item__c> lineItemsList = new List<Billing_Contract_Line_Item__c>();
        
        for(Integer perNumber=0; perNumber < numberOfPayment; perNumber++){
                        
             //returns the billings Line Item Start Date checked
            Date lineItemStartDate = getLineItemStartDate(perNumber, initialInvoiceDate,this.app);
            
            //return the period of the billing wich can be diferent from the line item start date
            Date billingPeriod = getBillingPeriodDate(getBillingInvoiceDate(perNumber,this.app),app.Payment_Freq__c,this.app.Payment_Timing__c,this.app.Payment_Freq__c);
            
            system.debug('lineItemStartDate: ' + lineItemStartDate);
            Billing_Contract_Line_Item__c billContLineItem = createOneBillLineItem(billCont.Id, app, lineItemStartDate,billingPeriod, prod,price, productTaxCode, this.billProductRegion);
            system.debug('billContLineItem:' + billContLineItem);
            
            lineItemsList.add(billContLineItem);                                                                                    
        }
        
        return lineItemsList;
    }
    
    //create one Bill Line Item per invoice is equal of one billing at each lineItem billing date
    private List<Billing_Contract_Line_Item__c> createPerBilling_BillLineItems(Billing_Contract__c billCont, application__c app, Integer numberOfPayment, date initialInvoiceDate, date invoice_PaymentDate, ID prod, decimal price, ID productTaxCode){
        List<Billing_Contract_Line_Item__c> lineItemsList = new List<Billing_Contract_Line_Item__c>();
        
        date lastStartInvoiceDate = invoice_PaymentDate ;
        
        //return the period of the billing wich can be diferent from the line item start date
        Date billingPeriod = getBillingPeriodDate(invoice_PaymentDate,app.Payment_Freq__c,this.app.Payment_Timing__c,this.app.Payment_Freq__c);
        
        Billing_Contract_Line_Item__c billContLineItem = createOneBillLineItem(billCont.Id, app, invoice_PaymentDate, billingPeriod, prod,price, productTaxCode, this.billProductRegion);
        lineItemsList.add(billContLineItem);
        
        for(Integer perNumber=0; perNumber <numberOfPayment ; perNumber++){
            
             //returns the billings Line Item Start Date checked
            Date lineItemStartDate = getLineItemStartDate(perNumber, initialInvoiceDate,this.app);
            
            //return the period of the billing wich can be diferent from the line item start date
            billingPeriod = getBillingPeriodDate(getBillingInvoiceDate(perNumber,this.app),app.Payment_Freq__c,this.app.Payment_Timing__c,this.app.Payment_Freq__c);
            
            if(lineItemStartDate == lastStartInvoiceDate){
                continue;
            }
            
            lastStartInvoiceDate = lineItemStartDate;
            //          date lineItemEndDate = getLineItemEndDate(lineItemStartDate );
            //          system.debug('lineItemStartDate: ' + lineItemStartDate);
            
            boolean active=true;
            
            billContLineItem = createOneBillLineItem(billCont.Id, app, lineItemStartDate,billingPeriod, prod,price,productTaxCode, this.billProductRegion);
            
            //system.debug('billContLineItem:' + billContLineItem);
   
            lineItemsList.add(billContLineItem);                                                                                    
        }
        
        return lineItemsList;
    }
   
    public static Billing_Contract_Line_Item__c createOneBillLineItem(Id billContId, application__c app, date invoiceDate, Date billingPeriodDate, ID prod, decimal price, ID productTaxCode, BILL_ProductRegion billProductRegion){
        
        system.debug('createOneBillLineItem');
        system.debug('invoiceDate' + invoiceDate);
        system.debug('prod' + prod);
        system.debug('price' + price);
        
        boolean active=true;
        
        Date dueDate;
        if(app.Payment_Timing__c == 'Advanced'){
            dueDate = getLineItemEndDateAdvanced(invoiceDate);
        }else if(app.Payment_Timing__c == 'Arreas'){
            dueDate = getLineItemEndDateArreas(invoiceDate);
        }
        
        Billing_Contract_Line_Item__c billContLineItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=billContId, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                         Line_Item_Start_Date__c=invoiceDate, Line_Item_End_Date__c=dueDate, Active__c=active,
                                                                                         Sales_Price__c=price, Product__c=prod, Quantity__c=1, 
                                                                                         //Last_Invoiced__c=invoiceDate, 
                                                                                         application__c=app.id, Product_Tax_Code__c = productTaxCode,
                                                                                         Billing_Period_Date__c = billingPeriodDate//getBillingPeriodDate(invoiceDate,app.Payment_Freq__c,app.Payment_Timing__c,app.Payment_Freq__c)
                                                                                         );
        
        billContLineItem.Billing_Period__c = setBillingPeriod(billProductRegion.getProductCode(prod), billingPeriodDate,'PT',app.Payment_Freq__c);         
        
        system.debug('billContLineItem:' + billContLineItem);
        
        return billContLineItem;
    }
    
    public static Integer getPeriodNumberOfMonths(application__c app){
        Integer period;
        if(app.Payment_Freq__c == PAYMENT_FREQ_MONTHLY){
            period = 1;
        }else if(app.Payment_Freq__c == PAYMENT_FREQ_QUARTERLY){
            period = 3;
        }
        
        return period;
    }
    
    public static date getLineItemStartDate(Integer periodNumber, date firstInvoiceDate,Application__c app){
        
        Date lineItemStartDate = getBillingInvoiceDate(periodNumber,app);
        
        if(app.Invoice_Payment_Date__c > lineItemStartDate ){
            lineItemStartDate = app.Invoice_Payment_Date__c;
        }else if(firstInvoiceDate > lineItemStartDate){
            lineItemStartDate = firstInvoiceDate;
        }
        
        system.debug('lineItemStartDate: ' + lineItemStartDate);
        return lineItemStartDate;
    }
    
    public static date getBillingInvoiceDate(Integer periodNumber,Application__c app){
        Integer periodNumberOfMonths = getPeriodNumberOfMonths(app);
        
        Integer yearAux  = app.Beginning_of_Term__c.addMonths( (periodNumber*periodNumberOfMonths)-1 ).year();
        Integer monthAux = app.Beginning_of_Term__c.addMonths( (periodNumber*periodNumberOfMonths)-1 ).month();
        
        return Date.newInstance(yearAux, monthAux, 15);
    }
        
    public void setPeriodNumberOfMonths(Integer per){
        this.periodNumberOfMonths=per;
    }
    
    public static String setBillingPeriod(String ProductCode,Date periodDate, String countryCode, String appFrequency){

        if(periodDate == null){
            return '';
        }
        Integer month = periodDate.Month();
        String period = '';
        if(ProductCode == 'PT01' || ProductCode == 'PT02' || ProductCode == 'PT09' || ProductCode == 'PT18' || ProductCode == 'PT19'){
            
            if(appFrequency == PAYMENT_FREQ_QUARTERLY){
                
                if(month == 1 || month == 2 || month == 3){
                    period = '1. Trim';
                }else if(month == 4 || month == 5 || month == 6){
                    period = '2. Trim';
                }else if(month == 7 || month == 8 || month == 9){
                    period = '3. Trim';
                }else{
                    period = '4. Trim';
                }
            }else{
                if(month == 1){
                    period = 'Jan';
                }else if(month == 2){
                    period = 'Fev';
                }else if(month == 3){
                    period = 'Mar';
                }else if(month == 4){
                    period = 'Abr';
                }else if(month == 5){
                    period = 'Maio';
                }else if(month == 6){
                    period = 'Jun';
                }else if(month == 7){
                    period = 'Jul';
                }else if(month == 8){
                    period = 'Ago';
                }else if(month == 9){
                    period = 'Set';
                }else if(month == 10){
                    period = 'Out';
                }else if(month == 11){
                    period = 'Nov';
                }else if(month == 12){
                    period = 'Dez';
                }
            }
            period = period + '/' + periodDate.year();
        }
        
        return period;
    }   
    
    //get the billing period start date
    public static Date getBillingPeriodDate(Date invoiceDate, String appFrequency,String appTiming, STring billingFrequency){
        
        if(billingFrequency == null || billingFrequency == ''){
            billingFrequency = appFrequency; 
        }else{
            if(billingFrequency == 'One Time'){
                return invoiceDate;
            }
        }
        
        Integer month = invoiceDate.Month();
        
        Date billingPeriodDate;
            
        if(appFrequency == PAYMENT_FREQ_QUARTERLY){
            if(month == 1 || month == 2 || month == 3){
                billingPeriodDate = Date.newInstance(invoiceDate.year(), 4, 1);
            }else if(month == 4 || month == 5 || month == 6){
                billingPeriodDate = Date.newInstance(invoiceDate.year(), 7, 1);
            }else if(month == 7 || month == 8 || month == 9){
                billingPeriodDate = Date.newInstance(invoiceDate.year(), 10, 1);
            }else{
                billingPeriodDate = Date.newInstance(invoiceDate.year()+1, 1, 1);
            }
            
            return billingPeriodDate;
        }else{
            if(appFrequency == PAYMENT_FREQ_MONTHLY){
                billingPeriodDate = Date.newInstance(invoiceDate.year(), month, 1);
                if(appTiming == PAYMENT_TIMING_ADVANCED){
                    System.debug('appTiming ' + appTiming);
                    billingPeriodDate = billingPeriodDate.addMonths(1);
                }
            }
        }
        return billingPeriodDate;
        /*
        Decimal aux = ((Decimal)itemEndDate.month())/3;
        aux = aux.round(System.roundingMode.CEILING);
        Integer month = aux*3-2;
        return Date.newInstance(itemEndDate.year(), month, 1);*/
    }
    
    //check if two date are in the same period
    public static boolean checkDateSamePeriod(Date date1, Date date2, String paymentFreq){
        Integer monthDate1 = date1.month();
        Integer yearDate1 = date1.Year();
        Integer monthDate2 = date2.month();
        Integer yearDate2 = date2.year();
        
        if(paymentFreq == PAYMENT_FREQ_MONTHLY){
            if(monthDate1 == monthDate2 && yearDate1 == yearDate2){
                return true;
            }
            return false;
            
        }else{ 
            if(paymentFreq == PAYMENT_FREQ_QUARTERLY){
                if(yearDate1 != yearDate2){
                    return false;
                }
                if((monthDate1 == 1 || monthDate1 ==2 || monthDate1==3) && 
                   (monthDate2 == 1 || monthDate2 ==2 || monthDate2==3)
                  ){
                      return true;
                  }
                if((monthDate1 == 4 || monthDate1 ==5 || monthDate1==6) && 
                   (monthDate2 == 4 || monthDate2 ==5 || monthDate2==6)
                  ){
                      return true;
                  }
                if((monthDate1 == 7 || monthDate1 ==8|| monthDate1==9) && 
                   (monthDate2 == 7 || monthDate2 == 8 || monthDate2==9)
                  ){
                      return true;
                  }
                if((monthDate1 == 10 || monthDate1 ==11|| monthDate1==12) && 
                   (monthDate2 == 10 || monthDate2 == 11 || monthDate2==12)
                  ){
                      return true;
                  }
                return false;
            }
        }
        return false;
    }
    
    public static date getLineItemEndDateAdvanced(date startDate){
        date lineItemEndDate;
        
        Integer yearAux = startDate.year();
        Integer monthAux = startDate.month();
        if(startDate.day() == 15 || (startDate.day() == 16 && date.daysInMonth(yearAux, monthAux) == 31)){
            lineItemEndDate =  Date.newInstance(yearAux, monthAux+1, 1);
        }else{
            lineItemEndDate = startDate.adddays(15);
        }
        system.debug('lineItemEndDate: ' + lineItemEndDate);
        return lineItemEndDate;
    }
    
    public static date getLineItemEndDateArreas(date startDate){
        Integer yearAux = startDate.year();
        Integer monthAux = startDate.month();
        date lineItemEndDate = Date.newInstance(yearAux, monthAux, Date.daysInMonth(yearAux, monthAux));
        
        return lineItemEndDate;
    }
    
    public BillingAdmin__c getBillAdmin(){
        date startInvoiceDate;
        if(this.app.Payment_Timing__c != 'Advanced'){
            system.debug('Only Payment_Timing__c "Advanced" is supported');
            system.debug('Error: this.app.Payment_Timing__c: ' + this.app.Payment_Timing__c);
            return null;
        }
        
        system.debug('Contract Settlement Date: ' + this.app.Invoice_Payment_Date__c); 
        
        String settlement_Date;
        if(this.app.Payment_Freq__c == PAYMENT_FREQ_QUARTERLY){
            if(this.app.Invoice_Payment_Date__c.day() > 15 && math.mod(this.app.Invoice_Payment_Date__c.month(), 3) == 0){ 
                settlement_Date = '> 16 Days Last Quarter Month';
            }else{
                settlement_Date = '< 15 Days Last Quarter Month';
            }
        }else if(this.app.Payment_Freq__c == PAYMENT_FREQ_MONTHLY){
            if(this.app.Invoice_Payment_Date__c.day() > 15){
                settlement_Date = '> 16 Days Month';
            }else{
                settlement_Date = '< 15 Days Month';
            }
        }
        
        System.debug('Billing Frequency: ' + this.app.Payment_Freq__c);
        System.debug('Payment Timing: ' + this.app.Payment_Timing__c);
        System.debug('settlement_Date: ' + settlement_Date);
        
        BillingAdmin__c billAdmin = [SELECT Billing_Frequency__c, Due_Date__c, Invoice_Date__c, Payment_Timing__c, Settlement_Date__c
                                     FROM BillingAdmin__c 
                                     WHERE Billing_Frequency__c = :this.app.Payment_Freq__c
                                     AND Payment_Timing__c = :this.app.Payment_Timing__c
                                     AND Settlement_Date__c = :settlement_Date
                                     AND Type__c = 'Invoice Terms'];
        
        system.debug('billAdmin: ' + billAdmin);        
        
        if(billAdmin == null){
            system.debug('Error no BillingAdmin__c returned');
        }
        
        return billAdmin;
    }
    
    // Invoice date    
    public Date getInvoiceDate(BillingAdmin__c billAdmin){
        
        system.debug('billAdmin.Invoice_Date__c: ' + billAdmin.Invoice_Date__c);
        Date invoiceDate;
        if( billAdmin.Invoice_Date__c == 'Settlement Date'){
            invoiceDate = this.app.Invoice_Payment_Date__c; //  or today because this code must run in Settlement contract system.today();
        }else if( billAdmin.Invoice_Date__c.equals('15-Month')){
            invoiceDate = Date.newInstance(this.app.Invoice_Payment_Date__c.year(), this.app.Invoice_Payment_Date__c.month() ,15);
        }else if( billAdmin.Invoice_Date__c == '15 - Last Month of the Quarter'){
            Integer month = this.app.Invoice_Payment_Date__c.month();
            month = math.abs((month-1)/3);
            month = (month+1)*3;
            invoiceDate = Date.newInstance(this.app.Invoice_Payment_Date__c.year(), month, 15);
        }
        system.debug('invoiceDate: ' + invoiceDate);
        
        return invoiceDate;
    }
    
    public Integer numberOfPayments(){
        Integer numberOfPayment;
        if(this.app.Payment_Freq__c == PAYMENT_FREQ_MONTHLY){
            numberOfPayment = Integer.valueOf( this.app.TermCalc__c );
        }else if(this.app.Payment_Freq__c == PAYMENT_FREQ_QUARTERLY){
            numberOfPayment = Integer.valueOf( (this.app.TermCalc__c/3) );
        }
        
        return numberOfPayment;
    }
    
    public void createInvoices(Billing_Contract__c billContrat){
        System.debug('Limits createInvoices (begin) '+Limits.getQueries());
        // run job to create sales invoice from billing contract
        List<Billing_Contract_Line_Item__c> salesinvoicedueList = [select id, name, Line_Item_Start_Date__c,  Line_Item_End_Date__c 
                                                                   from Billing_Contract_Line_Item__c 
                                                                   where Billing_Contract__c = :billContrat.id 
                                                                   and Ready_to_Invoice__c = true];
        
        List<Id> targetIds = new List<Id>();
        if(salesinvoicedueList.size()>0){
            
            //TODO
            if( app.Payment_Timing__c=='Advanced'){
                
                AggregateResult[] groupitem=[select Max(Line_Item_Start_Date__c) maxstart, max( Line_Item_End_Date__c) maxend 
                                             from Billing_Contract_Line_Item__c 
                                             where Billing_Contract__c=:billContrat.id 
                                             and Ready_to_Invoice__c= true];
                
                object maxstartdt=groupitem[0].get('maxstart');
                object maxenddt=groupitem[0].get('maxend'); 
                list <Billing_Contract_Line_Item__c> updalineItems=new List<Billing_Contract_Line_Item__c>();
                for(Billing_Contract_Line_Item__c item :salesinvoicedueList ){
                    item.Line_Item_Start_Date__c=date.valueOf(maxstartdt);
                    item.Line_Item_End_Date__c=date.valueOf(maxenddt);
                    updalineItems.add(item);
                }
                system.debug(updalineItems);
                System.debug('*****CHECKPOINT*****');
                update updalineItems;
                System.debug('Limits createInvoices (afterupdatelineitems) '+Limits.getQueries());
                billContrat.Aux_Due_Date__c=date.valueOf(maxenddt);
                billContrat.Aux_Invoice_Date__c=date.valueOf(maxstartdt);
            }
            
            update billContrat;
            System.debug('Limits createInvoices (afterbillcontract) '+Limits.getQueries());
            
            Set<Id> BillIds = new Set<Id>{billContrat.id};
            
            /*
            Id ruleId = [select id 
                         from ffirule__IntegrationRule__c 
                         where name ='Billing Contract to Sales Invoice'].id;
            
                
                // Criação do sales Invoice via click link rule
                //if(!QA)

                targetIds = ffirule.RuleService.run(new List<Id>(BillIds), ruleId);
           
            for(c2g.CODAAPICommon.Reference sinReference : sinReferenceList){
                targetIds.add(sinReference.id);
            }
            
        }
        
        // posting sales invoices due for current date   done with trigger on Post_SalesInvoice__c = true 
        System.debug('Limits createInvoices (beforeselectsalesinv) '+Limits.getQueries());
        List<c2g__codaInvoice__c> salesInvList = [select id, Post_SalesInvoice__c 
                                                  from c2g__codaInvoice__c 
                                                  where id IN :targetIds ];
        System.debug('Limits createInvoices (afterselectsalesinv) '+Limits.getQueries());
        for (c2g__codaInvoice__c salesinv : salesInvList){
            salesinv.Posted_InvoiceXpress__c = true;
            salesinv.Post_SalesInvoice__c = true;
        }
        //}
        // TODO  -----------COMENTADO 09/02/2017 -> Impedir envio automático no Settle
        System.debug('Limits createInvoices (beforeupdatelineitems) '+Limits.getQueries());
        update salesInvList;
        System.debug('Limits createInvoices (afterupdatelineitems) '+Limits.getQueries());
*/
                
                billlingToSIN(BillIds);
        }
        
    }
    
    public static List<c2g.CODAAPICommon.Reference> billlingToSIN(Set<ID> billContratSet){
        System.debug('Limits ' + System.Limits.getQueries());
        List<Billing_Contract_Line_Item__c> billItemList = new List<Billing_Contract_Line_Item__c>([Select ID,Name,Billing_Period__c,Product__c,Quantity__c,Sales_Price__c,
                                                                                                    Application__c,Billing_Contract__c,Product_Tax_Code__c
                                                                                                    From Billing_Contract_Line_Item__c 
                                                                                                    where Billing_Contract__c in :billContratSet and //Line_Item_Start_Date__c <= :Date.today() and Invoiced__c = false
                                                                                                    Ready_to_Invoice__c = true
                                                                                                   ]);
        
        List<Billing_Contract__c> billContractList = new List<Billing_Contract__c>([SELECT ID,Application__c,Name,Aux_Invoice_Date__c,Aux_Due_Date__c,Account__c,Application__r.Payment_Method__c,Application__r.Payment_timing__c
                                                                                    FROM Billing_Contract__c
                                                                                    WHERE id in :billContratSet]);
        
        if(billItemList.isEmpty() || billContractList.isEmpty()){
            return null;
        }
          
        Id currencyID = [SELECT ID 
                         FROM c2g__codaAccountingCurrency__c 
                         WHERE Name='EUR'].Id; /////WARNING. Every current account are in euros. but if they aren't?
        
        Date auxDate = billContractList.get(0).Aux_Invoice_Date__c;
        
        List<c2g__codaPeriod__c> periodIDList = [SELECT ID 
                                                 FROM c2g__codaPeriod__c 
                                                 where c2g__StartDate__c <= :auxDate and c2g__EndDate__c >= :auxDate];
        
        System.debug('Limits ' + System.Limits.getQueries());
        
        Id periodID = periodIDList.get(0).ID;

        
        //Map key BillingContract_ID - values sin
        Map<Id,c2g__codaInvoice__c> invoiceToInsertMap = new Map<Id,c2g__codaInvoice__c>();
        invoiceToInsertMap.putAll(createSIN(billContractList,currencyID,periodID));
        
        //create and insert the sin
        insert invoiceToInsertMap.values();
        
        //create sin line itens and insert
        insert createSINItem(billItemList,invoiceToInsertMap);
        
        //update to post the sales invoice
        for(c2g__codaInvoice__c  invoice : invoiceToInsertMap.values()){
            invoice.Post_SalesInvoice__c = true;
            invoice.Posted_InvoiceXpress__c = true;
        }
        update invoiceToInsertMap.values();
        
        System.debug('Limits ' + System.Limits.getQueries());
        
        //update billing line items to invoiced
        update billItemList;
        System.debug('Limits ' + System.Limits.getQueries());
        
        return null;
        // return ;
    }

    private static Map<Id,c2g__codaInvoice__c> createSIN(List<Billing_Contract__c> billContractList, Id currencyID, Id periodID){
        Map<Id,c2g__codaInvoice__c> invoiceToInsertMap = new Map<Id,c2g__codaInvoice__c>();
        
        for(Billing_Contract__c billContract : billContractList){
            c2g__codaInvoice__c invoice = new c2g__codaInvoice__c();
            invoice.Application__c = billContract.Application__c;
            invoice.Billing_Contract__c = billContract.id;
            invoice.c2g__Account__c = billContract.Account__c;
            invoice.c2g__InvoiceDate__c = billContract.Aux_Invoice_Date__c;
            invoice.c2g__DueDate__c = billContract.Aux_Due_Date__c;
            invoice.Candor_Due_Date__c = billContract.Aux_Due_Date__c;
            invoice.c2g__InvoiceDescription__c = billContract.Name;
            invoice.c2g__CustomerReference__c = billContract.Name;
            invoice.c2g__InvoiceCurrency__c = currencyID;
            invoice.Payment_Method__c = billContract.Application__r.Payment_Method__c;
            invoice.c2g__Period__c = periodID;
            
            invoiceToInsertMap.put(billContract.id,invoice);
        }
        return invoiceToInsertMap;
    }
    
    private static List<c2g__codaInvoiceLineItem__c> createSINItem(List<Billing_Contract_Line_Item__c> billItemList, Map<Id,c2g__codaInvoice__c> invoiceToInsertMap){
        
        List<c2g__codaInvoiceLineItem__c> invoiceItemToInsertList = new List<c2g__codaInvoiceLineItem__c>();
        for(Billing_Contract_Line_Item__c billItem : billItemList){
            c2g__codaInvoiceLineItem__c invoiceItem = new c2g__codaInvoiceLineItem__c();
            
            invoiceItem.c2g__Invoice__c = invoiceToInsertMap.get(billItem.Billing_Contract__c).id;
            invoiceItem.Billing_Contract_Line_Item__c = billItem.id;
            invoiceItem.c2g__TaxCode1__c = billItem.Product_Tax_Code__c;
            invoiceItem.c2g__Product__c = billItem.Product__c;
            invoiceItem.c2g__Quantity__c = billItem.Quantity__c;
            invoiceItem.c2g__UnitPrice__c = billItem.Sales_Price__c;
            invoiceItem.Line_Item_Period__c =   billItem.Billing_Period__c;
            invoiceItem.c2g__DeriveUnitPriceFromProduct__c = false;
            
            invoiceItemToInsertList.add(invoiceItem);
            billItem.Invoiced__c = true;
        }
        return invoiceItemToInsertList;
    }
    
    
    ////////////////////////////////
    // To delete Only for debug   //
    ////////////////////////////////
    public static void cleanData(String app){
        Id appId = app;
        
        Billing_Contract__c billingContract = [SELECT id FROM Billing_Contract__c WHERE application__c=:appId];
        
        List<Billing_Contract_Line_Item__c> billingContractLineItemList = [SELECT id FROM Billing_Contract_Line_Item__c WHERE application__c=:billingContract.Id];
        
        delete billingContract;
        delete billingContractLineItemList ;
        /*
List<>  = [SELECT id FROM ];
delete ;
*/
        system.debug('Delete Done');
    }
    
    
    public void createBillingInvoiceVXX(ID appId , Id journalId){
        this.toPost = false;
        system.debug('createBillingInvoice');
        try{
            sp = Database.setSavepoint();
            
            //Get Data
            getAllData(appId);   
            String region = UTIL_PostCode.getRegionFromPostCode(accClient.BillingPostalCode);  
            this.periodNumberOfMonths = getPeriodNumberOfMonths(this.app); 
            this.journal = [Select Id FROM c2g__codaJournal__c Where Id = :journalId];
            // this.createJournal();
            
            //Billing contract
            BillingAdmin__c billAdmin = getBillAdmin();  Date initialInvoiceDate = getInvoiceDate(billAdmin); Billing_Contract__c billContrat = createBillContract(); creatBillContractLineItems(billContrat, initialInvoiceDate, region); createInvoices(billContrat); app.Generate_Billing__C=false; update app;
            
        }catch(exception e){
            system.debug('ERROR: in BILL_BillingProcess createBillingInvoice');
            System.debug('exception: '+ e.getStackTraceString());
            // Rollback to the previous value
            Database.rollback(sp);
            
            // To see the exception
            throw e;
            return;
        }
    }
    
    
}