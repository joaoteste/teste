//CREATED BY BP - 24/03/17
//@Apex notation:
//This class is used in Renting Application Page.
//Allow the user changes between 'Quarterly' and 'Monthly' frequencies. 
//It can change also the rents or stay with the old ones.

public class BILL_ChangeBillingFrequency {
    //**************************************************//
    //                  CLASS VARIABLES                 //
    //**************************************************//
    private final String  SUCESS                 = 'SUCESS';
    private final String  ERROR                  = 'ERROR';
    private final String  FAILURE                = 'FAILURE';
    private       String  NEW_PAYMENT_FREQ;
    private       String  OLD_PAYMENT_FREQ;

    //Objects
    private BILL_BillingProcess billProcess         = new BILL_BillingProcess();
    private Billing_Contract_Line_Item__c lastBCLI  = null; 
    private c2g__codaJournal__c journal;
    private Application__c      app                 = null;
    private Account             accClient           = null;
    private Account             accVendor           = null;
    private Billing_Contract__c billContract        = null;
    private Savepoint           sp                  = null;    
    //Scope Variables
    private boolean toPost        = true;
    private Decimal decVendorDiscFactor;
    private Decimal amountFactura = 0;
    private Integer periodNumberOfMonths;
    private Integer dayOfChange ;  
    private Integer monthOfChange;
    private Integer yearOfChange; 
    private Integer lastNumberOfPayments; 
    //related to Billing Contract Line Items
    private Integer totalBCLIS;
    private Integer oldBCLIS;
    private Integer unchangedBCLIS;
    Decimal BegBalanceIni = 0;
 	private String factorType;

    //1stKey Product Code PT01    //2stKey Region(Mainland, Acores, Madeira)
    //private Map<String, Map<String, Product2>> productMap = new Map<String, Map<String, Product2>>();
      
    //**************************************************//
    //      MAIN METHOD - CHANGE BILLING INVOICE        //
    //**************************************************//
    public String changeBillingInvoice(ID appId,boolean buttonValue,Date dateOfChange){
        System.debug('********************ENTRADA NO CHANGEBILLINGINVOICE********************');
		System.debug('Limits queries ' + System.Limits.getQueries());
        try{
            dayOfChange   = dateOfChange.Day();
            monthOfChange = dateOfChange.Month(); 
            yearOfChange  = dateOfChange.Year();            

            sp = Database.setSavepoint();

            billProcess.getAllData(appId);
            getAllData(appId);//Get Data
            
            factorType = app.Vendor_Diluted_Doc_Fee__c ? 'Standard': 'Diluted';

            lastNumberOfPayments =  NEW_PAYMENT_FREQ ==  BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY ? 1 : 3;
            System.debug('BILL_ChangeBillingFrequency --> lastNumberOfPayments: '+lastNumberOfPayments);

            if(!validateChangeFrequency(appId,dateOfChange)){//when app is ARREAS or has invoices to pay
                System.debug('BILL_ChangeBillingFrequency --> App doesnt respect the criteria...');    
                return ERROR;
            }
            
            String region = accClient.Tax_Zone__c; //UTIL_PostCode.getRegionFromPostCode(accClient.BillingPostalCode);
            if(region == null){
                System.debug('Error invalid region.');              
                Database.rollback(sp);// Rollback to the previous value
                return ERROR;
            }else
                System.debug('BILL_ChangeBillingFrequency --> region: '+region);

            setNewPaymentFreq();//set old and new frequency
            app.Payment_Freq__c=NEW_PAYMENT_FREQ; //need to update here to run the next methods correctly
            update app;
            getAllData(appId);//Get Data
            billProcess.getAllData(appId);  
            System.debug('BILL_ChangeBillingFrequency --> Actual Frequency: '+app.Payment_Freq__c);     
           
            //set ao numero de meses no periodo (3 ou 1)
            periodNumberOfMonths = NEW_PAYMENT_FREQ == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY ? 3 : 1; //quarterly = 3 - montlhy = 1
            billProcess.setPeriodNumberOfMonths(periodNumberOfMonths);
            System.debug('BILL_ChangeBillingFrequency --> periodNumberOfMonths: '+periodNumberOfMonths);

            //Desconto do vendedor. Passa de String (ex: 0,5% para um decimal)
            String auxVendorDiscFactor;
            if(accVendor.Discount_Factor__c!= null && accVendor.Discount_Factor__c!='')     
                auxVendorDiscFactor=accVendor.Discount_Factor__c;                   
            else
                auxVendorDiscFactor='0,0%';          
            auxVendorDiscFactor=auxVendorDiscFactor.replace(',', '.');
            decVendorDiscFactor=Decimal.valueOf(auxVendorDiscFactor.substringBefore('%'));
            
            //fillBalanceFields();
            getBillingContract();            

            if(billContract==null){
                System.debug('BILL_ChangeBillingFrequency --> No Billing Contract...');
                // MDS - 14/06/2017 - correction to annualinterest rate
                double paymnt=  app.Payment_Amount__c;
                double nrpay=  app.TermCalc__c;  
                integer npaymentByYear=12;
                integer begEndpay=0;
                if(app.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY){ 
                    nrpay=nrpay/3;
                    paymnt=paymnt*3;
                    npaymentByYear=4;
                }
                if(app.Payment_Timing__c == BILL_BillingProcess.PAYMENT_TIMING_ADVANCED){
                    begEndpay=1;
                }
                app.Annual_Interest_Rate__c = Financial.AnnualInterestRate(nrpay,paymnt,(double)App.Equipment_Cost__c,npaymentByYear, begEndpay, false); 
                app.Amortization_Interest_Rate__c=financial.AnnualInterestRate(nrpay, paymnt,(double)App.Equipment_Cost__c,npaymentByYear, 0, true );
                // MDS - End of Change
                //update app;                 
                //String result=ScoreCardConfig.getCalc(app,(double)App.Equipment_Cost__c,(Integer)app.TermCalc__c,decvendorDiscFactor);
           
				Decimal factor = NEW_PAYMENT_FREQ == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY ? Rents.calculateFactorMonthToQuarterly(app.Factor__c,accClient.BillingCountryCode) : Rents.calculateFactorQuarterlyToMonth(app.Factor__c,accClient.BillingCountryCode); 
                Decimal newRent = Rents.calculatePaymentAmount((double)app.Equipment_Cost__c, factor);
                app.Payment_Amount__c = newRent;
                app.New_Rate_Factor__c = factor;
                app.Factor__c = factor;
                update app;
                getAllData(app.id);
                billProcess.getAllData(appId);  
                
                String result = 'Success';
                
                if(true)
                    return SUCESS;
                else
                    return ERROR;
            }
            
            Date initialNewDueDate = calculateFirstNewDueDate(dateOfChange);

            Date initialNewInvoiceDate = calculateFirstNewInvoiceDate(initialNewDueDate);
            
            if(initialNewInvoiceDate!=null && initialNewDueDate!=null){
                System.debug('BILL_ChangeBillingFrequency --> initialNewInvoiceDate: '+initialNewInvoiceDate+' initialNewDueDate: '+initialNewDueDate);    
            }

            getLastBCLI(initialNewInvoiceDate,initialNewDueDate);

            fillBalanceFields(); 

            boolean cleared=clearOldBillingContractLineItems(initialNewInvoiceDate,initialNewDueDate);
            if(!cleared){//clear old bclis       
                System.debug('BILL_ChangeBillingFrequency --> No BCLIs for delete...');    
            }
            //return'CHECKPOINT';

            BillingAdmin__c billAdmin= getBillAdminNotFirstInvoice();
            System.debug('BILL_ChangeBillingFrequency --> billAdmin: '+billAdmin);

            if(billAdmin == null){
                System.debug('BILL_ChangeBillingFrequency --> Error getting billAdmin...');
                // Rollback to the previous value
                Database.rollback(sp);
                return ERROR;
            }

            Date endQuarter=app.End_of_Term__c;
            if((app.End_of_Term__c).day()!=1)
                endQuarter= endQuarter.addDays(1);
            Integer numberOfPayments =  initialNewDueDate.monthsBetween(endQuarter);
            
            
            if(NEW_PAYMENT_FREQ==BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY)
                numberOfPayments/=periodNumberOfMonths;
                       
            System.debug('BILL_ChangeBillingFrequency --> numberOfPayments: '+numberOfPayments);

            if(!buttonValue){      
                //ScoreCardConfig.getCalc(app, (double)app.Equipment_Cost__c,(Integer)app.termCalc__c,decvendorDiscFactor);
                 
                Decimal factor = NEW_PAYMENT_FREQ == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY ? Rents.calculateFactorMonthToQuarterly(app.Factor__c,accClient.BillingCountryCode) : Rents.calculateFactorQuarterlyToMonth(app.Factor__c,accClient.BillingCountryCode); 
                Decimal newRent = Rents.calculatePaymentAmount((double)app.Equipment_Cost__c, factor);
                System.debug('.... factor'+factor);
                System.debug('.... newRent'+newRent);
                app.Payment_Amount__c = newRent;
                //app.New_Rate_Factor__c = factor;
                app.Factor__c = factor;
                update app;
                
            }
            
            System.debug('app.Payment_Amount__c '+ app.Payment_Amount__c);

            // MDS - 01/08/2017  - Change to annual interest rate calculation
            if ( numberOfPayments !=  app.TermCalc__c){
                double paymnt=  app.Payment_Amount__c;
                double nrpay=  app.TermCalc__c;  
                integer npaymentByYear=12;
                integer begEndpay=0;
                if(app.Payment_Freq__c==BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY){ 
                    nrpay=nrpay/3;
                    paymnt=paymnt*3;
                    npaymentByYear=4;
                }
                if(app.Payment_Timing__c== BILL_BillingProcess.PAYMENT_TIMING_ADVANCED){
                    begEndpay=1;
                }
                app.Annual_Interest_Rate__c = Financial.AnnualInterestRate(numberOfPayments,paymnt,(double) BegBalanceIni,npaymentByYear, begEndpay, false); 
                app.Amortization_Interest_Rate__c=financial.AnnualInterestRate(numberOfPayments, paymnt,(double) BegBalanceIni,npaymentByYear, 0, true );
                
                System.debug('BILL_ChangeBillingFrequency --> App antes do update: '+app);
                update app;
                System.debug('BILL_ChangeBillingFrequencyge --> App depois do update: '+app);
           }                   
            
            ID prod;
            Id productTaxCode;
            if(NEW_PAYMENT_FREQ==BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
                prod = billProcess.billProductRegion.getProduct('PT01',region);
                productTaxCode = billProcess.billProductRegion.getTaxCode('PT01', region);
            }else{
                prod = billProcess.billProductRegion.getProduct('PT09',region);
                productTaxCode = billProcess.billProductRegion.getTaxCode('PT09', region);                
            }
            
            decimal  rentPrice = app.Payment_Amount__c*periodNumberOfMonths;
            System.debug('Bill_ChangeBillingFreq___Payment_Amount__c '+ app.Payment_Amount__c);
           	System.debug('Bill_ChangeBillingFreq___rentPrice '+ rentPrice);
            
            List<Billing_Contract_Line_Item__c> rentingBCLIS   = createPeriodicRentBillLineItems(billContract,numberOfPayments,prod,rentPrice,initialNewInvoiceDate,initialNewDueDate,periodNumberOfMonths,productTaxCode);            

            if(app.Chosen_Insurance_value__c != 0){
                ID insProd   = billProcess.billProductRegion.getProduct('PT02',region);
                ID insProductTaxCode = billProcess.billProductRegion.getTaxCode('PT02',region);
                decimal  insPrice  = app.Chosen_Insurance_value__c * periodNumberOfMonths;
                List<Billing_Contract_Line_Item__c> insuranceBCLIS = createPeriodicBillLineItems(billContract,numberOfPayments,insProd,insPrice,initialNewInvoiceDate,initialNewDueDate,periodNumberOfMonths, insProductTaxCode);

                rentingBCLIS.addAll(insuranceBCLIS);
            }
            
            if(app.ATM_Reference_Costs__c != null){
                ID mbProd  = billProcess.billProductRegion.getProduct('PT03', region);
                Id mbProductTaxCode = billProcess.billProductRegion.getTaxCode('PT03', region);
                Decimal mbPrice = [Select PriceBook2.Name, Product2.Id, Product2.Name, UnitPrice, Name, Product2.c2g__CODAInputTaxCode__c,PriceBook2.id
                                   From PricebookEntry 
                                   WHERE Product2.id = :mbProd and PriceBook2.id = :app.Price_Book__c].UnitPrice;
                //decimal  mbPrice = app.ATM_Reference_Costs__c;
                List<Billing_Contract_Line_Item__c> atmBCLIS = createPerBilling_BillLineItems(billContract, numberOfPayments,mbProd, mbPrice,initialNewInvoiceDate,initialNewDueDate ,periodNumberOfMonths, mbProductTaxCode );
                // List<Billing_Contract_Line_Item__c> atmBCLIS = billProcess.createPeriodicBillLineItems(billContract,app,numberOfPayments,initialNewInvoiceDate,mbProd,mbPrice,mbProductTaxCode);                  
                
                //System.debug('BILL_ChangeBillingFrequency --> atmBCLIS: '+atmBCLIS);
                rentingBCLIS.addAll(atmBCLIS);
                //System.debug('BILL_ChangeBillingFrequency --> Finished to get ATM costs...');
            }
            
            insert rentingBCLIS;

            //billProcess.createInvoices(billContract);// Invoices
            System.debug('Limits queries ' + System.Limits.getQueries());
            System.debug('********************SAIDA DO CHANGEBILLINGINVOICE********************');

            return SUCESS;
        }//end try condition 
        catch(Exception e){
            System.debug('ERROR: BILL_ChangeBillingFrequency --> changeBillingInvoice Method...');
            System.debug('Exception: '+ e.getStackTraceString());
            System.debug('Error type: '+e.getMessage());
            // Rollback to the previous value
            Database.rollback(sp);
            
            // To see the exception
            throw e;
            return ERROR;
        }//end catch condition
    }// end changeBillingInvoice method

    //**************************************************//
    //                AUXILIAR METHODS                  //
    //**************************************************//

    //-----setNewPaymentFreq-----//
    private void setNewPaymentFreq(){
    	
    	NEW_PAYMENT_FREQ = app.Payment_Freq__c==BILL_BillingProcess.PAYMENT_FREQ_MONTHLY ? BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY : BILL_BillingProcess.PAYMENT_FREQ_MONTHLY;
    	OLD_PAYMENT_FREQ = app.Payment_Freq__c==BILL_BillingProcess.PAYMENT_FREQ_MONTHLY ? BILL_BillingProcess.PAYMENT_FREQ_MONTHLY : BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY;
    	
    }//end setNewPaymentFreq method

    //-----validateChangeFrequency----//
    private boolean validateChangeFrequency(ID appId,Date dateOfChange){
        if(app.Payment_Timing__c=='Arreas' || app.Payment_Amount__c==0)
            return false;

        List<Billing_Contract_Line_Item__c> 
        lastInvoicedBCLIS = [SELECT Active__c,Application__c,Beginning_Balance__c,Billing_Contract__c,
                                    Billing_Frequency__c,Contract_Line_Value__c,Ending_Balance__c,Interest__c,
                                    Invoiced__c,Line_Item_End_Date__c,
                                    Line_Item_Start_Date__c,
                                    Principal__c,Product__c,Quantity__c,Ready_to_Invoice__c,
                                    Sales_Price__c
                               FROM Billing_Contract_Line_item__c
                              WHERE Application__c        = :appId
                                AND Invoiced__c           = true
                                AND Billing_Frequency__c != 'Once'
                           ORDER BY Line_Item_Start_Date__c DESC ];   

        if(lastInvoicedBCLIS.size()!=0 && lastInvoicedBCLIS[0].Line_Item_Start_Date__c<dateOfChange){
            List<c2g__codaInvoice__c> salesInvoices=[SELECT c2g__InvoiceDate__c,c2g__DueDate__c,c2g__InvoiceStatus__c,c2g__InvoiceDescription__c
                                                       FROM c2g__codaInvoice__c
                                                      WHERE c2g__InvoiceDescription__c=:app.Name 
                                                        AND c2g__DueDate__c <: dateOfChange
                                                        AND c2g__InvoiceStatus__c!='Complete']; 
            if(salesInvoices.size()!=0)
                return false;
        }
        return true;
    }// end validateChangeFrequency method

    //-----fillBalanceFields-----//
    private void fillBalanceFields(){

        if(lastBCLI!=null)
            BegBalanceIni = lastBCLI.Ending_Balance__c; //lastBCLI.Beginning_Balance__c;
        else
            BegBalanceIni = app.Equipment_Cost__c;

    }// end fillBalanceFields method

    //-----getBillingContract-----//

    private Billing_Contract__c getBillingContract(){
        try{
            this.billContract=  [SELECT Name,Account__c,Account_Vendor__c,Contract_Term__c,
                                        Contract_Start_Date__c,Billing_Date_Override__c,Application__c
                                   FROM Billing_Contract__c
                                  WHERE Application__c=:app.Id 
                               ORDER BY createdDate DESC
                                  LIMIT 1];

            if(billContract==null)
                return null;
            return billContract;
        } catch(Exception e){
        	return null;
        }
    }//end getBillingContract method

    //-----getLastBCLI-----//
    private void getLastBCLI(Date newStartDate,Date newDueDate){
        List<Billing_Contract_Line_Item__c> auxlastBCLI = new List<Billing_Contract_Line_Item__c>();

        if(NEW_PAYMENT_FREQ==BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY)
            auxlastBCLI = [  SELECT id,name,Line_Item_Start_Date__c,Line_Item_End_Date__c,
                                 Application__r.status__c,Beginning_Balance__c,Ending_Balance__c
                            FROM Billing_Contract_Line_Item__c
                           WHERE Billing_Contract__c    =: billContract.id
                             AND Beginning_Balance__c   != null
                             AND Line_Item_End_Date__c<  :newDueDate
                        ORDER BY Line_Item_End_Date__c DESC LIMIT 1];
        else
            auxlastBCLI = [  SELECT id,name,Line_Item_Start_Date__c,Line_Item_End_Date__c,
                                 Application__r.status__c,Beginning_Balance__c,Ending_Balance__c
                            FROM Billing_Contract_Line_Item__c
                           WHERE Billing_Contract__c    =: billContract.id
                             AND Beginning_Balance__c   != null
                             AND Line_Item_Start_Date__c< :newStartDate
                        ORDER BY Line_Item_Start_Date__c DESC LIMIT 1];  
        
        if(auxlastBCLI.size()>0)
            lastBCLI = auxlastBCLI[0];                                  
    }//end getLastBCLI method

    //-----clearOldBillingContractLineItems-----//
    
    private boolean clearOldBillingContractLineItems(Date initialNewInvoiceDate, Date initialNewDueDate){
        List<Billing_Contract_Line_Item__c> oldBCLIS= new List<Billing_Contract_Line_Item__c>();

        if(NEW_PAYMENT_FREQ == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY)
            oldBCLIS = [SELECT id,name,Line_Item_Start_Date__c,Line_Item_End_Date__c,Application__r.status__c
                          FROM Billing_Contract_Line_Item__C
                         WHERE Billing_Contract__c=: billContract.id 
                           AND Product__r.ProductCode IN ('PT02','PT03','PT09')
                           AND Billing_Frequency__c=: OLD_PAYMENT_FREQ
                           AND Line_Item_Start_Date__c >= : initialNewInvoiceDate 
                      ORDER BY Line_Item_Start_Date__c DESC
                       ];
        else{ //NEW_PAYMENT_FREQ== Quarterly
            string convMonth='0';
            string convDay  ='0';
            if(monthOfChange<10)
                convMonth+=monthOfChange;
            else
                convMonth=String.valueOf(monthOfChange);
            if(dayOfChange <10)
                convDay+=dayOfChange;
            else
                convDay=String.valueOf(dayOfChange);
            
            String formattedDate=yearOfChange+'-'+convMonth+'-'+convDay;
            System.debug('BILL_ChangeBillingFrequency --> formattedDate: '+ formattedDate);
                     
            String  query ='SELECT id,name,Line_Item_Start_Date__c,Line_Item_End_Date__c,Application__r.status__c  ';
                    query+='  FROM Billing_Contract_Line_Item__c ';
                    query+=' WHERE Billing_Contract__c= \''      + billContract.id;
                    query+='\' AND Product__r.ProductCode IN (\'PT02\',\'PT03\',\'PT01\')';
                    query+=' AND Line_Item_Start_Date__c >'   + formattedDate;                    

            string convMonth1='0';
            string convDay1  ='0';
            initialNewDueDate = initialNewDueDate.addMonths(-1);

            if(initialNewDueDate.month()<10)
                convMonth1+=initialNewDueDate.month();
            else
                convMonth1=String.valueOf(initialNewDueDate.month());
            if(initialNewDueDate.day() <10)
                convDay1+=initialNewDueDate.day();
            else
                convDay1=String.valueOf(initialNewDueDate.day());

            String revertDate = initialNewDueDate.year()+'-'+convMonth1+'-'+ convDay1;
            System.debug('BILL_ChangeBillingFrequency --> revertDate:'+revertDate);

            if(dayOfChange>15 && (monthOfChange ==3 ||monthOfChange ==6 ||monthOfChange ==9 ||monthOfChange ==12))
                //query+=' AND Line_Item_End_Date__c > NEXT_QUARTER ORDER BY Line_Item_Start_Date__c DESC';
                query+=' AND Line_Item_End_Date__c >'+ revertDate +' ORDER BY Line_Item_Start_Date__c DESC';
            else 
                if(dayOfChange<15 && (monthOfChange ==3 ||monthOfChange ==6 ||monthOfChange ==9 ||monthOfChange ==12))                
                    //OK
                    query+=' AND Line_Item_End_Date__c >= THIS_MONTH ORDER BY Line_Item_Start_Date__c DESC';                    
                else    //query+=' AND Line_Item_End_Date__c >= NEXT_QUARTER ORDER BY Line_Item_Start_Date__c DESC';
                    query+=' AND Line_Item_End_Date__c >'+ revertDate +' ORDER BY Line_Item_Start_Date__c DESC';
            System.debug('BILL_ChangeBillingFrequency --> DELETE QUERY:'+query);
            try{
                oldBCLIS=Database.query(query); 
            }catch(Exception e){
                return false;
            }
        }
        delete oldBCLIS;
        return true;
    }// end clearOldBillingContractLineItems method

    //-----getAllData-----//
    public void getAllData(ID appId){
        this.app=[SELECT id,  Name, vendor__C, accClient__c,Vendor__r.Diluted_Doc_Fee__c,accClient__r.Risk_Type__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                         Equipment_Cost__c,End_of_Term__c, Vendor_invoice_VAT__c,Chosen_Insurance_value__c,
                         Original_Insurance_Value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c, Vendor_Diluted_Doc_Fee__c,
                         Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                         ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, Amortization_Interest_Rate__c,
                         Insurance_Pro_Rata__c, Original_Insurance_ProRata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                         Interest_Amount__c, annual_interest_rate__c, accClient__r.c2g__CODAInvoiceEmail__c, status__c,Price_Book__c,
                  		 Grade__c,Sub_Grade__c, Client_Country_Code__c,Documentation_fee_cost__c,Factor__c,New_Rate_Factor__c
                    FROM Application__c 
                   WHERE id= :appId ];
        
        if(app.Original_Insurance_Value__c==null)
            app.Original_Insurance_Value__c=app.Chosen_Insurance_value__c;
        if(app.Original_Insurance_ProRata__c==null)
            app.Original_Insurance_ProRata__c=app.Insurance_Pro_Rata__c;
        System.debug(' Original_Insurance_Value__c --> '+ app.Original_Insurance_Value__c);
        System.debug(' Original_Insurance_ProRata__c --> '+ app.Original_Insurance_ProRata__c);
        
        this.accClient =[SELECT id,name, c2g__CODABankIBANNumber__c, c2g__CODATaxCalculationMethod__c,
                                c2g__CODAAccountsReceivableControl__c, BillingCountryCode,
                                c2g__CODAInputVATCode__c, BillingPostalCode, c2g__CODAVATStatus__c, Tax_Zone__c
                           FROM account 
                          WHERE id= :app.AccClient__c];
        
        this.accVendor =[SELECT id, name, c2g__CODABankIBANNumber__c,Discount_Factor__c  ,BillingCountryCode
                           FROM account 
                          WHERE id= :app.vendor__C];
        /*
        // Query add save the product in a MAP of Map. First key is the product second key is the region
        list<Product2>productList =[SELECT id, Description, c2g__CODAInputTaxCode__c, 
                                           c2g__CODAInputTaxCode__r.Area__c,name, ProductCode 
                                      FROM Product2 ];
        //1stKey Product Code exPT01    //2stKey Region(Mainland, Acores, Madeira)
        //Map<String, Map<String, Product2>> productMap = new Map<String, Map<String, Product2>>();
        for(Product2 prodAux : productList)
        {
            Map<String, Product2> prodPerVat = this.productMap.get(prodAux.ProductCode);
            if(prodPerVat == null)
            {
                prodPerVat = new Map<String, Product2>();
                this.productMap.put(prodAux.ProductCode, prodPerVat);
            }            
            prodPerVat.put(prodAux.c2g__CODAInputTaxCode__r.Area__c, prodAux);
        }*/
    }//end getAllData method

    //-----calculateFirstNewDueDate-----//
    private Date calculateFirstNewDueDate(Date dateOfChange){
        if(dateOfChange==null)          
            return null;
        
        Date dueDate;

        if(dayOfChange<15 && (monthOfChange==12  /*|| monthOfChange==1 */ || monthOfChange==3 || monthOfChange==6|| monthOfChange==9)){        
            dueDate= Date.newInstance(yearOfChange, monthOfChange, 1).addMonths(1);
        } else {
            if(monthOfChange==1 || monthOfChange==2 || monthOfChange ==3)
                   dueDate=Date.newInstance(yearOfChange, 4, 1 );                         
            else   
                if(monthOfChange==4 || monthOfChange==5 || monthOfChange ==6)
                  dueDate=Date.newInstance(yearOfChange, 7, 1 );         
                else
                    if(monthOfChange==7 || monthOfChange==8 || monthOfChange ==9)
                       dueDate=Date.newInstance(yearOfChange, 10, 1 );             
                    else
                       if(monthOfChange==10 || monthOfChange==11 || monthOfChange ==12) 
                          dueDate=Date.newInstance(yearOfChange+1, 1, 1 );      
        }
       /*
        if(dayOfChange>15 && (monthOfChange==12  || monthOfChange==1 || monthOfChange==3 || monthOfChange==6|| monthOfChange==9))
            dueDate=dueDate.addMonths(3);
     */
        return dueDate;
    }//end calculateFirstNewDueDate method

    //-----calculateFirstNewInvoiceDate-----//
    private Date calculateFirstNewInvoiceDate(Date newDueDate){
        if(newDueDate==null)
            return null;
        
        //if(NEW_PAYMENT_FREQ==BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY)
            //return newDueDate-15;
        //else
        return Date.newInstance(newDueDate.year(),newDueDate.month()-1,15);
    }// end calculateFirstNewInvoiceDate method 

    //-----getBillAdminNotFirstInvoice-----//
    public BillingAdmin__c getBillAdminNotFirstInvoice(){
        if(this.app.Payment_Timing__c != BILL_BillingProcess.PAYMENT_TIMING_ADVANCED){
            System.debug('Only Payment_Timing__c "Advanced" is supported');
            System.debug('Error: this.app.Payment_Timing__c: ' + this.app.Payment_Timing__c);
            return null;
        }

        System.debug('Billing Frequency: ' + this.app.Payment_Freq__c);
        System.debug('Payment Timing: ' + this.app.Payment_Timing__c);
    
        BillingAdmin__c billAdmin =[ SELECT Settlement_Date__c, Payment_Timing__c, Invoice_Date__c, 
                                            Due_Date__c, Billing_Frequency__c
                                       FROM BillingAdmin__c
                                      WHERE type__c              = 'Invoice Terms' 
                                        AND Payment_Timing__c    = :BILL_BillingProcess.PAYMENT_TIMING_ADVANCED 
                                        AND Billing_Frequency__c =:NEW_PAYMENT_FREQ 
                                      LIMIT 1];

        System.debug('billAdmin: ' + billAdmin);        

        if(billAdmin == null){
            System.debug('Error no BillingAdmin__c returned');  
            return null;      
        }    
        return billAdmin;
    }//end getBillAdminNotFirstInvoice method   

    //-----createPeriodicBillLineItems-----//
    public List<Billing_Contract_Line_Item__c> createPeriodicBillLineItems(Billing_Contract__c billCont, Integer numberOfPayment, ID prod, decimal price, Date invoiceDate ,Date dueDate,Integer period, ID productTaxCode){
        List<Billing_Contract_Line_Item__c> lineItemsList = new List<Billing_Contract_Line_Item__c>();

        for(Integer perNumber=0; perNumber < numberOfPayment; perNumber++){

            Billing_Contract_Line_Item__c billContLineItem = createOneBillLineItem(billCont, prod,price,invoiceDate,dueDate, productTaxCode);
            
            lineItemsList.add(billContLineItem);    
            invoiceDate = invoiceDate.addMonths(period);
            dueDate     = dueDate.addMonths(period);                                                                                
        }    
        return lineItemsList;
    }//end createPeriodicBillLineItems method

    //-----createOneBillLineItem-----//
    private Billing_Contract_Line_Item__c createOneBillLineItem(Billing_Contract__c billCont, ID prod, decimal price, Date invoiceDate ,Date dueDate, ID productTaxCode){
        
		Date billingPeriodDate = Bill_billingProcess.getBillingPeriodDate(dueDate,app.Payment_Freq__c,app.Payment_Timing__c,app.Payment_Freq__c);
        
        Billing_Contract_Line_Item__c billContLineItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=billCont.id, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                         Line_Item_Start_Date__c=invoiceDate, Line_Item_End_Date__c=dueDate, Active__c=true,
                                                                                         Sales_Price__c=price, Product__c=prod, Quantity__c=1, 
                                                                                         // Last_Invoiced__c=invoiceDate,
                                                                                         application__c=app.id, Product_Tax_Code__c = productTaxCode,
                                                                                         Billing_Period_Date__c = billingPeriodDate
                                                                                         );
                                                                                         
        billContLineItem.Billing_Period__c = Bill_BillingProcess.setBillingPeriod(billprocess.billProductRegion.getProductCode(prod), billingPeriodDate,'PT',app.Payment_Freq__c);         
        
        system.debug('billContLineItem:' + billContLineItem);
        return billContLineItem;
    }//end createOneBillLineItem method

    //-----createPeriodicRentBillLineItems-----//
    public List<Billing_Contract_Line_Item__c> createPeriodicRentBillLineItems(Billing_Contract__c billCont, Integer numberOfPayment, ID prod, decimal price,Date invoiceDate,Date dueDate, Integer periodNumberOfMonths,ID productTaxCode){                                   

        List<Billing_Contract_Line_Item__c> lineItemsList = new List<Billing_Contract_Line_Item__c>();
        
        decimal beginning_Balance;
        if(lastBCLI!= null)
            beginning_Balance=lastBCLI.ending_balance__c ;//lastBCLI.Beginning_Balance__c;
        else
            beginning_Balance=app.equipment_cost__c;

        Integer period;
        if(this.app.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
            period = 12;
        }else if(this.app.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY){
            period = 4;     
        }

        decimal interest   =(app.Amortization_Interest_Rate__c/period/100 * beginning_Balance).setScale(3);
        decimal principal  =(price-interest).setscale(3);
        decimal endBalance =(beginning_Balance-principal).setscale(3);

        for(Integer perNumber=0; perNumber < numberOfPayment; perNumber++){

            System.debug('Principal='+ principal+ ' ...endBalance='+endBalance);
            //on the last rent adds the remaining endbalance to principal
            if(perNumber==(numberOfPayment-1)){
                System.debug('Before adding remaining. Principal='+ principal+ ' ...endBalance='+endBalance);
                principal = principal + endBalance;
                endBalance = beginning_Balance - principal;
                System.debug('After adding remaining. Principal='+ principal+ ' ...endBalance='+endBalance);
            }
            
            //system.debug('lineItemStartDate: ' + lineItemStartDate);
            //Billing_Contract_Line_Item__c billContLineItem = createOneRentBillLineItem(billCont, lineItemStartDate, prod,price, perNumber, beginning_Balance, interest, principal, endBalance);
            Billing_Contract_Line_Item__c billContLineItem = createOneRentBillLineItem(billCont,prod,price, perNumber, beginning_Balance, interest, principal, endBalance,invoiceDate,dueDate, productTaxCode);                                                                                                                                                                                      
            //system.debug('billContLineItem:' + billContLineItem);
            
            beginning_Balance=endBalance;
            interest=(app.Amortization_Interest_Rate__c/period/100 * beginning_Balance).setScale(3);
            principal=(price-interest).setscale(3);
            endBalance=(beginning_Balance-principal).setscale(3);
            
            lineItemsList.add(billContLineItem); 
            invoiceDate = invoiceDate.addMonths(periodNumberOfMonths);                                                                                   
            dueDate = dueDate.addMonths(periodNumberOfMonths); 
        }        
        return lineItemsList;
    }//end createPeriodicRentBillLineItems method

    //-----createOneRentBillLineItem-----//
    private Billing_Contract_Line_Item__c createOneRentBillLineItem(Billing_Contract__c billCont, ID prod, decimal price, Integer perNumber,decimal beginning_Balance, decimal interest, decimal principal, decimal endBalance,Date invoiceDate, Date dueDate, ID productTaxCode){    
    	
    	Date billingPeriodDate = Bill_billingProcess.getBillingPeriodDate(dueDate,app.Payment_Freq__c,app.Payment_Timing__c,app.Payment_Freq__c);
        Billing_Contract_Line_Item__c billContLineItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=billCont.id, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                         Line_Item_Start_Date__c=invoiceDate, Line_Item_End_Date__c=dueDate, Active__c=true,
                                                                                         Sales_Price__c=price, Product__c=prod, Quantity__c=1, 
                                                                                         // Last_Invoiced__c=invoiceDate, 
                                                                                         Beginning_Balance__c=beginning_Balance, 
                                                                                         interest__c=interest, Principal__C=principal,
                                                                                         Ending_Balance__c=endBalance, application__c=app.id, Product_Tax_Code__c = productTaxCode,
                                                                                         Billing_Period_Date__c = billingPeriodDate
                                                                                         );
                                                                                         
        billContLineItem.Billing_Period__c = Bill_BillingProcess.setBillingPeriod(billprocess.billProductRegion.getProductCode(prod), billingPeriodDate,'PT',app.Payment_Freq__c);         
                                                                                                     
        system.debug('billContLineItem:' + billContLineItem);
        return billContLineItem;
    }//end createOneRentBillLineItem method
        
    //-----createPerBilling_BillLineItems-----//
    private List<Billing_Contract_Line_Item__c> createPerBilling_BillLineItems(Billing_Contract__c billCont, Integer numberOfPayment, ID prod, decimal price, Date newInvoiceDate, Date newDueDate , Integer periodNumberOfMonths, ID productTaxCode  ){
       
        List<Billing_Contract_Line_Item__c> lineItemsList = new List<Billing_Contract_Line_Item__c>();
        // MDS - 08/06/2017 - change done to sole error in test class  BILL_ChangeBillingFrequency_TEST.withInterimFeeAmount_Test1 lastBCLI can be null
        date lastStartInvoiceDate;
        if(lastBCLI!=null){
            //lastStartInvoiceDate = lastBCLI.Last_Invoiced__c;
            lastStartInvoiceDate = lastBCLI.Line_Item_Start_Date__c;
        }
        
        
        Billing_Contract_Line_Item__c billContLineItem;
        
        for(Integer perNumber=0; perNumber <numberOfPayment ; perNumber++){

            date lineItemStartDate = newInvoiceDate;
            if(lineItemStartDate == lastStartInvoiceDate){
                continue;
            }
            
            lastStartInvoiceDate = lineItemStartDate;
            boolean active=true;

            billContLineItem = createOneBillLineItem(billCont, prod, price, newInvoiceDate, newDueDate, productTaxCode);
            
            lineItemsList.add(billContLineItem);  
            newInvoiceDate = newInvoiceDate.addMonths(periodNumberOfMonths);                                                                                   
            newDueDate = newDueDate.addMonths(periodNumberOfMonths);                                                                                   
        }        
        return lineItemsList;
    }//end createPerBilling_BillLineItems method
    
}//end BILL_ChangeBillingFrequency class