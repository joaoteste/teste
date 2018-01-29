/**

Author   |Date  | Comments
Vinod    |08/28/2017 | Initial Creation

**/

public class PartialPaymentPlan_Ctrl {
    
    public Collection_Case__c objCollectionCase { get; set; }
    public Payment_Plan__c objPaymentPlan { get; set; }
    public List<c2g__codaInvoice__c> salesInvoice {get;set;}
    public List<Payment_Schedule__c> payScheduleList{get;set;} 
    public List<c2g__codaInvoice__c> invoicesUnpaidNotCC{get; set;}   

    public ID caseId {get; set; }
    public List<Payment_Schedule__c> totalResults{get;set;}
    public List<Payment_Schedule__c> fullResults{get;set;}
    public List<Billing_Contract__c> bcList{get;set;}
    public Double feeAmount {get;set;}
    public Double unpaidInvoicesDueDate {get; set;}
    public Double totalAmountClaimed {get;set;}
    public Decimal scheduleAmount {get; set;}
    public Decimal newPaymentAmount {get; set;}
    public Integer newTerm {get; set;}
    public Integer partialTerm {get; set;}
    public Account objAccount;
    public Boolean partial {get; set;}
    public Boolean full {get; set;}
    public Boolean showResult{get; set;}
    public string  cssMatch {get; set;}
    
    //fullPaymentPlan
    public Double totalContracts {get;set;}
    public Double fullTotalAmountClaimed {get;set;}
    public Decimal fullTotal{get; set;}
    public Integer fullMaxExpiredTerm {get; set;}
    public Integer fullExtensionTerm {get; set;}
    public Integer fullNewTerm {get; set;}
    public Double taxRate{get; set;}
    
    //Parameterised constructor to get collection case object
    public PartialPaymentPlan_Ctrl(ApexPages.StandardController controller) {
        objPaymentPlan = new Payment_Plan__c();
        objCollectionCase = new Collection_Case__c();
        caseID = controller.GetID();
        fullTotalAmountClaimed = 0;
        totalContracts = 0;
        fullTotal = 0;
        fullMaxExpiredTerm = 0;
        fullExtensionTerm = 0;
        fullNewTerm = 0;
        
        //GET Collection Case Information
        List<Collection_Case__c> collectionCaseList = [SELECT ID, Account__c, Account__r.Tax_Zone__c FROM Collection_Case__c WHERE ID = :caseID];



        if(collectionCaseList.size()>0){
            objCollectionCase = collectionCaseList[0];
            bcList = [select id, name, Current_Balance__c, Equipment_Cost__c, Application__r.Client_Signer_1__c,Application__r.Client_Signer_2__c,  Payment_Amount_to_The_End_Of_Contract__c, Terms_To_End_Of_Contract__c from Billing_Contract__c where Collection_Case__c = :objCollectionCase.iD];
            totalContracts = bcList.size();
            objPaymentPlan.Total_Equipment_Cost__c = 0;
            for(Billing_Contract__c bc : bcList){
                totalContracts +=  bc.Payment_Amount_to_The_End_Of_Contract__c;
                if(fullMaxExpiredTerm < bc.Terms_To_End_Of_Contract__c)
                    fullMaxExpiredTerm = Integer.valueOf(bc.Terms_To_End_Of_Contract__c);
                objPaymentPlan.Total_Equipment_Cost__c += bc.Equipment_Cost__c;
            }
            
            if(bcList[0].Application__r.Client_Signer_1__c != null){
                objPaymentPlan.Signer_1__c = bcList[0].Application__r.Client_Signer_1__c;
                if(bcList[0].Application__r.Client_Signer_2__c != null)
                    objPaymentPlan.Signer_2__c = bcList[0].Application__r.Client_Signer_2__c;
                objPaymentPlan.Contact__c = bcList[0].Application__r.Client_Signer_1__c;
            }
                
            if(!Test.isRunningTest()){
                Bill_ProductRegion billRegion = new Bill_ProductRegion();
                taxRate = billRegion.getTaxRateToTaxCode(billRegion.getTaxCode('PT01', objCollectionCase.Account__r.Tax_Zone__c));
            }else{
                taxRate = 0.23;
            }
        } 
        
        objPaymentPlan.Advanced_Expired_Payments_Amount__c = totalContracts;
        salesInvoice = new List<c2g__codaInvoice__c>([SELECT ID,  Name, Application__c, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c FROM c2g__codaInvoice__c WHERE Collection_Case__c =:objCollectionCase.ID  AND (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid')]);
        invoicesUnpaidNotCC = new List<c2g__codaInvoice__c>([SELECT ID, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c FROM c2g__codaInvoice__c WHERE c2g__Account__c = :objCollectionCase.Account__c AND Collection_Case__c = null AND (c2g__PaymentStatus__c = 'Unpaid' OR c2g__PaymentStatus__c = 'Part Paid') AND c2g__DueDate__c > TODAY]); 
        
        Double total=0;
        unpaidInvoicesDueDate = 0;
        
        if(!salesInvoice.isEmpty()){
            objPaymentPlan.Renting_Application__c = salesInvoice[0].Application__c;      
            
            for(c2g__codaInvoice__c si : salesInvoice){
                system.debug(si.ID + ' ' + si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c);
                total+=si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                if(si.Application__c != null)
                   objPaymentPlan.Renting_Application__c = si.Application__c; 
            }  
            
            objPaymentPlan.Amount_Claimed__c=total;
        }
        
        fullTotalAmountClaimed += total;
        if(!invoicesUnpaidNotCC.isEmpty()){
            for(c2g__codaInvoice__c  si : invoicesUnpaidNotCC)
                fullTotalAmountClaimed += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
        }
        
        
        objPaymentPlan.Advanced_Expired_Payments_Amount_Net__c = totalContracts;
        objPaymentPlan.Advanced_Expired_Payments_Amount__c = totalContracts * (1+taxRate);
        fullTotal = fullTotalAmountClaimed + objPaymentPlan.Advanced_Expired_Payments_Amount__c;
        fullTotal = fullTotal.setScale(2);
        objPaymentPlan.PP_Total_Amount__c = fullTotal;
        if(Test.isRunningTest()){
            objPaymentPlan.Amount_Claimed__c=100;
            fullTotalAmountClaimed = 100;
        }
                
        //Fetch account to pass for getting fees amount cost of amount claimed
        //objAccount = [SELECT Id,Name, Tax_Zone__c FROM Account WHERE Id =: objCollectionCase.Account__c LIMIT 1];
        
        //To prepopulate values of payment plan from collection case
        objPaymentPlan.Collection_Case__c = objCollectionCase.Id;
        objPaymentPlan.Account__c = objCollectionCase.Account__c;
        objPaymentPlan.Type__c = 'Partial';
        partial = true; full = false;
        objPaymentPlan.Status__c = 'Open';
        objPaymentPlan.Fees_Amount__c = PP_CreateSalesInvoice.getCost(objCollectionCase.Account__c);
        feeAmount = objPaymentPlan.Fees_Amount__c;
        totalAmountClaimed = feeAmount + objPaymentPlan.Amount_Claimed__c;
        payScheduleList = new List<Payment_Schedule__c>();
        showResult = false;
        totalResults = new List<Payment_Schedule__c>();
        fullResults =  new List<Payment_Schedule__c>();
        
        Payment_Plan_Specs__mdt pp = [select Additional_Costs__c, Late_Payment_Interest__c , Dilute__c, Residual_Value__c from Payment_Plan_Specs__mdt where masterLabel = 'Portugal'];
        
        //default
        objPaymentPlan.Hit_Date__c = system.today().addDays(5);
        objPaymentPlan.Day_Of_Month_To_Pay__c = '15';
        objPaymentPlan.Addiction_Charges__c  = pp.Additional_Costs__c;
        objPaymentPlan.Residual_Value__c = pp.Residual_Value__c;
        objPaymentPlan.Dilute_Residual_Value__c = pp.Dilute__c;
        objPaymentPlan.Total_Residual_Value__c = ((objPaymentPlan.Residual_Value__c/100) * objPaymentPlan.Total_Equipment_Cost__c) * (1+taxRate);
        objPaymentPlan.Total_Residual_Value__c = objPaymentPlan.Total_Residual_Value__c.setScale(2);
        objPaymentPlan.PP_Total_Amount__c += Double.valueOf(objPaymentPlan.Addiction_Charges__c)*(1+taxRate) + objPaymentPlan.Total_Residual_Value__c;
        objPaymentPlan.Late_Payment_Interest__c = pp.Late_Payment_Interest__c;
        objPaymentPlan.Net_Total__c = objPaymentPlan.PP_Total_Amount__c / (1+taxRate);
        objPaymentPlan.Payment_Method__c = 'ATM Reference';
        objPaymentPlan.Initial_Payment__c = 0;
        objPaymentPlan.ATM_Costs__c = true;
    }
    
    /***************************************************************************************/
    /*																					   */
 	/*	         						Cancel and Save PP      	      				   */
    /*																					   */
    /***************************************************************************************/    
    
    //Method to go back to previous screen
    public PageReference doCancel(){
        if(caseId != null){   
            PageReference pageRef = new PageReference('/'+caseId);
            pageRef.setRedirect(true);
            return pageRef;   
        }
        
        return null;
    }
    
    public Boolean validateContact(){
        if(partial){
            Contact c = [select id, email, phone, mobilephone, accountid from Contact where id = :objPaymentPlan.Contact__c];
            return c.email != null && (c.MobilePhone != null || c.Phone != null) && c.AccountID == objPaymentPlan.Account__c;     
        }else{
            List<ID> idsList = new List<ID>{objPaymentPlan.Contact__c, objPaymentPlan.Signer_1__c};
            if(objPaymentPlan.Signer_2__c != null)
                idsList.add(objPaymentPlan.Signer_2__c);
            List<Contact> cList = [select id, email, phone, mobilephone, accountid from Contact where id in :idsList];
            for(Contact c : cList){
                if(c.email == null || (c.MobilePhone == null && c.Phone == null) || c.AccountID != objPaymentPlan.Account__c)
                    return false;
            }
        }
        return true;
    }
    
    public String validatePartialSchedule(){
        Double sumTotalAux = 0;
        
        for(Payment_Schedule__c ps : payScheduleList){
           
            
            if(ps.Amount__c  == 0 || ps.Amount__c == null)
                return 'Its not possible to have a schedule with 0 or not filled, if you want to delete one of the payments reduce the number of payments.';
             
            sumTotalAux += ps.Amount__c;
            
            if(ps.Schedule_Number__c == '1' && (ps.Due_Date__c < system.today() || ps.Due_Date__c > system.today().addDays(5)))
                return 'First Schedule Due Date should be greater than today and should not have more than 5 days since today';  
                
            if(ps.Schedule_Number__c != '1' && payScheduleList[Integer.valueOf(ps.Schedule_Number__c)-1].Due_Date__c <=payScheduleList[Integer.valueOf(ps.Schedule_Number__c)-2].Due_Date__c){
                return 'Its not possible to have a schedule with an higher schedule number and a due date less or equal than the previous schedule';  
            }
            
            if(ps.Schedule_Number__c != '1' && payScheduleList[Integer.valueOf(ps.Schedule_Number__c)-1].Due_Date__c.addDays(-5) <=payScheduleList[Integer.valueOf(ps.Schedule_Number__c)-2].Due_Date__c){
                return 'Its not possible to have a schedule with less than 5 days of the previous schedule';  
            }            
        }
        if(totalResults[0].Total_Amount__c != sumTotalAux  && payScheduleList.size()!=1)
            return 'Amount Without Fees sum doesnt match with Total Amount without Fees. Difference: '+(totalResults[0].Total_Amount__c - sumTotalAux);
        
        if(payScheduleList.size()==1 && sumTotalAux > totalResults[0].Total_Amount__c)   
            return 'Its not possible to pay more than the debt of the client';
         
        if(payScheduleList[payScheduleList.size()-1].Due_Date__c >= system.today().addDays(180))
            return 'Its not possible to create a payment plan for more than 6 months';
            
        return 'OK';           
        
    }
    
    public void clearFields(){
        objPaymentPlan.Late_Payment_Interest__c = null;
        objPaymentPlan.Total_Equipment_Cost__c = null;
        objPaymentPlan.Advanced_Expired_Payments_Amount__c = null;
        objPaymentPlan.Signer_1__c = null;
        objPaymentPlan.Signer_2__c = null;
        objPaymentPlan.Addiction_Charges__c = null;
        objPaymentPlan.Residual_Value__c = null;
        objPaymentPlan.Late_Payment_Interest_Amount__c = null;
        objPaymentPlan.Day_Of_Month_To_Pay__c = null;
        objPaymentPlan.Net_Total__c = null;
        objPaymentPlan.Residual_Value__c = null;
    }
    
    public void fillPaymentsTable(){
        objPaymentPlan.Payments_Table__c = '<table border="0" cellspacing="2" cellpadding="0" style="width:100%;" class="ProductsTable"><tr>' 
        + '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:20%;" class="ProductsHeader">Nº</th>'
        + '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Valor</th>'                            
        + '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Data de Vencimento</th>'                 
        +'</tr>'; 
                        
        for(Payment_Schedule__c pp : payScheduleList){
            objPaymentPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ pp.Schedule_Number__c +'</td>';
            objPaymentPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ pp.Total_Amount__c  +'€ </td>';                            
            objPaymentPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ String.valueOf(DateTime.newInstance(pp.Due_Date__c.year(),pp.Due_Date__c.month(),pp.Due_Date__c.day()).format('dd/MM/YYYY')) + '</td>';
            objPaymentPlan.Payments_Table__c +='</tr>';
        }        
    }
    
    //Method to save payment plan
    public PageReference savePaymentPlan(){
    
        if(partial){
            if(!validateContact())
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'In Contact email and phone/mobilePhone are mandatory, the contact should belong to the same account of payment plan account. Candor will send sms/email and make some calls.'));  
            else{
                String result = validatePartialSchedule();
                if(result != 'OK'){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,result));  
                }else{
                    return createPartialPaymentPlan();
                }
            }
            
            //criar plano de pagamentos
        }else{
            if(!validateContact())
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'In Contact email and phone/mobilePhone are mandatory. Candor will send sms/email and make some calls.'));  
            else if(objPaymentPlan.Initial_Payment__c > (fullTotalAmountClaimed)){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Initial Payment should be less/equal than Amount Claimed (Incl VAT)'));  

					return null; 
            }else{
                return createFullPaymentPlan(); 
            }
        }
        
        
        return null;
    }     
    
    /***************************************************************************************/
    /*																					   */
 	/*	         						Partial Payment Plan      	      				   */
    /*																					   */
    /***************************************************************************************/      
    
    
    
    public PageReference createPartialPaymentPlan(){
        objPaymentPlan.Amount_Claimed__c = totalResults[0].Total_Amount__c;
        objPaymentPlan.Amount_Claimed_VAT__c = objPaymentPlan.Amount_Claimed__c / (1+taxRate);
        objPaymentPlan.Fees_Amount__c = totalResults[1].Total_Amount__c;
        objPaymentPlan.Hit_Date__c = payScheduleList[0].Due_Date__c;
        objPaymentPlan.PP_Total_Amount__c = totalResults[2].Total_Amount__c;
        RecordType recordType = [SELECT ID FROM RecordType WHERE Name = 'Partial Payment Plan' LIMIT 1];
        RecordType recordTypeSchedule = [SELECT ID FROM RecordType WHERE Name = 'Partial Payment Plan Schedule' LIMIT 1];
        objPaymentPlan.RecordTypeID = recordType.ID;
        
        clearFields();
        fillPaymentsTable();
        insert objPaymentPlan;
        
        for(Payment_Schedule__c ps : payScheduleList){
            ps.Amount_W_O_Tax__c = ps.Total_Amount__c /(1+taxRate);
            ps.Payment_Plan__c = objPaymentPlan.ID;
            ps.RecordTypeID = recordTypeSchedule.ID;
        }
        payScheduleList[payScheduleList.size()-1].isLast__c = true;
		
		if(objPaymentPlan.Number_of_Payments__c == '1') payScheduleList[0].isLast__c = true;
        insert payScheduleList;
		
        
        PageReference pageRef = new PageReference('/'+objPaymentPlan.Id);
        pageRef.setRedirect(true);
        return pageRef;    
       
    }
    
    //Calculate fees amount for payment plan
    public PageReference calculateFeesAmount(){     
        if(partial){
            feeAmount = objPaymentPlan.Fees_Amount__c * Integer.valueOf(objPaymentPlan.Number_of_Payments__c);
            totalAmountClaimed = feeAmount + objPaymentPlan.Amount_Claimed__c;
            scheduleAmount = totalAmountClaimed / Integer.valueOf(objPaymentPlan.Number_of_Payments__c);
            scheduleAmount  = scheduleAmount.setScale(2);
            createPaymentScheduleAutomatic();
        }else{       
        
            objPaymentPlan.Amount_Claimed__c = totalContracts ;                                                             
        }        
        
        return null;            
    }      
    
 public void createPaymentScheduleAutomatic(){
    
        payScheduleList.clear();
        totalResults.clear();
        Integer numberOfPayments = Integer.valueOf(objPaymentPlan.Number_of_Payments__c);
        Double feesAmount = objPaymentPlan.Fees_Amount__c;
        Double totalAmount = objPaymentPlan.Amount_Claimed__c;
        Decimal amountClaimed = (totalAmount/ numberOfPayments);
        amountClaimed = amountClaimed.setScale(2);        
        Double lastSchedule = totalAmount - (amountClaimed * (numberOfPayments-1)) ;
        Date hitDate;
        if( objPaymentPlan.Hit_Date__c == null){
            hitDate = System.today().addDays(5);
        }else{
            hitDate = objPaymentPlan.Hit_Date__c;
        }    
        Integer frequency ;
        if(objPaymentPlan.Frequency__c == 'Every 30 Days'){
            frequency = 30;
        }else{
            frequency = 15;
        }
        
        for(Integer i = 1; i <= numberOfPayments; i++){
            
            Payment_Schedule__c ps = new Payment_Schedule__c();
            
            ps.Schedule_Number__c = ''+i;
            ps.Due_Date__c = hitDate;
            hitDate = hitDate.addDays(frequency);
            ps.Fees_Amount__c = feesAmount;
            
            if(i != numberOfPayments){
                ps.Amount__c = amountClaimed;
            }else{
                ps.Amount__c = lastSchedule;
            }
            ps.Total_Amount__c = ps.Amount__c + ps.Fees_Amount__c;
            
            
            
            payScheduleList.add(ps);
        }  
        
        Payment_Schedule__c psAmountClaimed = new Payment_Schedule__c();
        psAmountClaimed .Total_Amount__c = objPaymentPlan.Amount_Claimed__c;
        psAmountClaimed .Schedule_Number__c = 'Total Amount (Fees N Incl)';
        totalResults.add(psAmountClaimed );        
       
        Payment_Schedule__c psTotalFeesAmount = new Payment_Schedule__c();
        psTotalFeesAmount .Total_Amount__c = feesAmount * numberOfPayments;
        psTotalFeesAmount .Schedule_Number__c = 'Total Fees Amount';
        totalResults.add(psTotalFeesAmount);
        
        Payment_Schedule__c psTotalAmountClaimed= new Payment_Schedule__c();
        psTotalAmountClaimed.Total_Amount__c = totalAmountClaimed;
        psTotalAmountClaimed.Schedule_Number__c = 'Total Amount';
        psTotalAmountClaimed.Style__c = 'font-size: 110%; font-weight: bold;';        
        psTotalAmountClaimed.Style2__c = 'font-size: 110%; font-weight: bold;';
        totalResults.add(psTotalAmountClaimed);                    
              
        Payment_Schedule__c sumTotalAmount = new Payment_Schedule__c();
        sumTotalAmount .Total_Amount__c = totalAmountClaimed;
        sumTotalAmount .Schedule_Number__c = 'Total Amount Calculator';
        sumTotalAmount .Style__c = 'color: green; font-size: 110%; font-weight: bold;';        
        sumTotalAmount .Style2__c = 'color: green; font-size: 110%; font-weight: bold;';
        totalResults.add(sumTotalAmount );        
   
        
        Payment_Schedule__c psSumTotal = new Payment_Schedule__c();
        psSumTotal .Total_Amount__c = 0;
        psSumTotal .Schedule_Number__c = '';
        psSumTotal .Style__c = 'font-size: 110%; font-weight: bold;';
        psSumTotal .Style2__c = 'color:green; font-size: 125%; font-weight: bold; ';        
        totalResults.add(psSumTotal );        
                  
        
      
        showResult = true;
           

    }
    
    public PageReference recalculatePaymentSchedule(){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'First Schedule can\'t have a start date less than today'));  
        system.debug(payScheduleList);  
        Double sum = 0;  
        
        for(Payment_Schedule__c  ps : payScheduleList){
            system.debug('ps:'+ps);
            if(ps.Amount__c != null)
                ps.Total_Amount__c = ps.Amount__c + ps.Fees_Amount__c;
            else
                ps.Total_Amount__c = ps.Fees_Amount__c;
            sum += ps.Total_Amount__c ; 
            
        } 
        
        if(sum != totalAmountClaimed){
            totalResults[3].Total_Amount__c = sum;       
            totalResults[3].Style2__c = 'color:red; font-weight: bold; font-size: 125%';
            totalResults[4].Style2__c = 'color:red; font-weight: bold; font-size: 125%';
            totalResults[4].Total_Amount__c= sum-totalAmountClaimed; 
            totalResults[4].Total_Amount__c = totalResults[4].Total_Amount__c.setScale(2);
        }else{
            totalResults[3].Total_Amount__c = sum;
            totalResults[3].Style2__c = 'color:green;font-weight: bold; font-size: 125%';
            totalResults[4].Style2__c = 'color:green; font-weight: bold; font-size: 125%';
            totalResults[4].Total_Amount__c= totalAmountClaimed-sum; 
        }
        
        return null;

    }
    
    public void updateDate(){
        if(!payScheduleList.isEmpty()){
            Date todayDate = system.today().addDays(5);
            Integer frequency ;
            if(objPaymentPlan.Frequency__c == 'Every 30 Days'){
                frequency = 30; 
            }else{
                frequency = 15;
            }        
            for(Payment_Schedule__c  ps : payScheduleList){
                ps.Due_Date__c = todayDate; 
                todayDate = todayDate.addDays(frequency);
            }      
        }
    }
    
    public Boolean validateSum(){
        Double sum = 0;  
        
        for(Payment_Schedule__c  ps : payScheduleList){
            system.debug('ps:'+ps);
            ps.Total_Amount__c = ps.Amount__c + ps.Fees_Amount__c;  
            sum += ps.Total_Amount__c ;     
        } 
        
        return sum == totalAmountClaimed;    
    }     
    
    /***************************************************************************************/
    /*																					   */
 	/*	         						Full Payment Plan       	      				   */
    /*																					   */
    /***************************************************************************************/     
    
    public PageReference createFullPaymentPlan(){
        //payment plan
        RecordType recordType = [SELECT ID FROM RecordType WHERE Name = 'Full Payment Plan' LIMIT 1];
        RecordType recordTypeSchedule = [SELECT ID FROM RecordType WHERE Name = 'Full Payment Plan Schedule' LIMIT 1];
        objPaymentPlan.RecordTypeID = recordType.ID;
        objPaymentPlan.Amount_Claimed_VAT__c = objPaymentPlan.Amount_Claimed__c/(1+taxRate);
        insert objPaymentPlan;
       
        
        //payment schedule
        for(Payment_Schedule__c ps : fullResults){
            ps.RecordTypeID = recordTypeSchedule.ID;
            ps.Payment_Plan__c = objPaymentPlan.ID;
        }
        
        insert fullResults; 

        
        PageReference pageRef = new PageReference('/'+objPaymentPlan.Id);
        pageRef.setRedirect(true);
        return pageRef;    
    }
    

    
    public Boolean validateFullPaymentPlan(){
        return objPaymentPlan.Extension_Term_Months__c != null && objPaymentPlan.Day_Of_Month_To_Pay__c!= null;
    }
    
    //Calculate fees amount for payment plan
     public PageReference calculateFullPaymentPlan(){    
         if(validateFullPaymentPlan()){
         
            objPaymentPlan.Late_Payment_Interest_Amount__c = 0;
            Double totalAux = (totalContracts*(1+taxRate))+fullTotalAmountClaimed+(Double.valueOf(objPaymentPlan.Addiction_Charges__c)*(1+taxRate));
            
            if(objPaymentPlan.Residual_Value__c == 0 || objPaymentPlan.Residual_Value__c == null)
                objPaymentPlan.Total_Residual_Value__c = 0;
            
            if(objPaymentPlan.Residual_Value__c != 0){
                objPaymentPlan.Total_Residual_Value__c = ((objPaymentPlan.Residual_Value__c/100) * objPaymentPlan.Total_Equipment_Cost__c) * (1+taxRate);
                objPaymentPlan.Total_Residual_Value__c =  objPaymentPlan.Total_Residual_Value__c.setScale(2);
            }
            
            totalAux += objPaymentPlan.Total_Residual_Value__c ;
            
            Integer newTerm = fullMaxExpiredTerm + Integer.valueOf(objPaymentPlan.Extension_Term_Months__c);
            
            if(objPaymentPlan.Initial_Payment__c == 0 || objPaymentPlan.Initial_Payment__c == null){
             	
	            Decimal paymentEstimated = ((Decimal)(totalAux/newTerm)).setScale(2);
	            Integer partialTerm = (Integer)((fullTotalAmountClaimed/paymentEstimated).setScale(0));
	            if(partialTerm == 0 || partialTerm == 1) partialTerm = 2;
	            objPaymentPlan.Partial_Payment_Plan_Term__c = partialTerm;
	            List<Double> partialAmount = getPartialPaymentAmount(fullTotalAmountClaimed, partialTerm);
	            
	            Integer bcTerm = newTerm - partialTerm;
	            
	            
	            List<Double> bcAmount;
	            if(!objPaymentPlan.Dilute_Residual_Value__c){
	                bcAmount = getPartialPaymentAmount((totalAux-fullTotalAmountClaimed-(Double)objPaymentPlan.Total_Residual_Value__c) , bcTerm);
	            }
	            else{
	                bcAmount = getPartialPaymentAmount(totalAux-fullTotalAmountClaimed , bcTerm); 
	            }
	            objPaymentPlan.New_Contract_Term__c = bcTerm;
	            
	            if(!objPaymentPlan.Dilute_Residual_Value__c) 
	                totalAux -= objPaymentPlan.Total_Residual_Value__c;
	                
	            objPaymentPlan.Net_Total__c = totalAux / (1+taxRate);
	            fullResults.clear();

	            
	            createNPaymentSchedule(partialTerm-1, 1, partialAmount[0], fullResults,objPaymentPlan.Hit_Date__c, (Double)objPaymentPlan.Net_Total__c);
	            createNPaymentSchedule(1, partialTerm, partialAmount[1], fullResults, objPaymentPlan.Hit_Date__c, ((Double)fullResults[fullResults.size()-1].Balance__c));            
	            createNPaymentSchedule(bcTerm-1, partialTerm+1, bcAmount[0], fullResults, objPaymentPlan.Hit_Date__c,(Double)fullResults[fullResults.size()-1].Balance__c);
	            createNPaymentSchedule(1,newTerm, bcAmount[1], fullResults, objPaymentPlan.Hit_Date__c,(Double)fullResults[fullResults.size()-1].Balance__c);  
	            
	            fullResults[0].Due_Date__c = objPaymentPlan.Hit_Date__c;
	            
	            if(objPaymentPlan.Dilute_Residual_Value__c == false && objPaymentPlan.Residual_Value__c != 0){
	                //new schedule for residual value
	                objPaymentPlan.Total_Residual_Value__c = (objPaymentPlan.Residual_Value__c/100) * objPaymentPlan.Total_Equipment_Cost__c * (1+taxRate);
	                objPaymentPlan.Total_Residual_Value__c = objPaymentPlan.Total_Residual_Value__c.setScale(2);
	                Payment_Schedule__c ps = new Payment_Schedule__c();
	                ps.Amount__c =  objPaymentPlan.Total_Equipment_Cost__c * (objPaymentPlan.Residual_Value__c/100) * (1+taxRate);
	           
	                ps.Schedule_Number__c = ''+(fullResults.size()+1);
	                ps.Amount_W_O_Tax__c = ps.Amount__c / (1+taxRate);
	                ps.Amount_W_O_Tax__c = ps.Amount_W_O_Tax__c.setScale(2);
	                ps.Due_Date__c = fullResults[fullResults.size()-1].Due_Date__c.addDays(30) ;
	                
	                if(ps.Due_Date__c.month() == 2 && (objPaymentPlan.Day_Of_Month_To_Pay__c =='29' || objPaymentPlan.Day_Of_Month_To_Pay__c =='30'))
	                    ps.Due_Date__c = Date.newInstance(ps.Due_Date__c.year(),ps.Due_Date__c.month(), 28);
	                else
	                    ps.Due_Date__c = Date.newInstance(ps.Due_Date__c.year(),ps.Due_Date__c.month(), Integer.valueOf(objPaymentPlan.Day_Of_Month_To_Pay__c));   
	
	                ps.Late_Payment_Interest_Amount__c = (ps.Amount__c * (objPaymentPlan.Late_Payment_Interest__c/100))/12 ;
	                ps.Balance__c = fullResults[fullResults.size()-1].Balance__c-ps.Amount_W_O_Tax__c;
	                if(((Decimal)ps.Balance__c).setScale(2) == 0.01 || ((Decimal)ps.Balance__c).setScale(2) == -0.01)
	                    ps.Balance__c = 0;              
	                    
	                if(!objPaymentPlan.Dilute_Residual_Value__c){
	                      ps.Balance__c = 0;   
	                      ps.Late_Payment_Interest_Amount__c = 0;
	                }
	                objPaymentPlan.Late_Payment_Interest_Amount__c += ps.Late_Payment_Interest_Amount__c;
	               
	                ps.Total_Amount__c = ps.Amount__c +  ps.Late_Payment_Interest_Amount__c;                                    
	                fullResults.add(ps);
	            }
	            
	            if(!objPaymentPlan.Dilute_Residual_Value__c){
	                totalAux += objPaymentPlan.Total_Residual_Value__c;
	                objPaymentPlan.Net_Total__C += objPaymentPlan.Total_Residual_Value__c;
	                objPaymentPlan.PP_Total_Amount__c += objPaymentPlan.Total_Residual_Value__c;
	            }
	            
	            totalAux+= objPaymentPlan.Late_Payment_Interest_Amount__c;  
	            objPaymentPlan.PP_Total_Amount__c = totalAux;
	            
	        }else{
	        	
	            if(!objPaymentPlan.Dilute_Residual_Value__c) 
	                totalAux -= objPaymentPlan.Total_Residual_Value__c;
	                
	            objPaymentPlan.Net_Total__c = totalAux / (1+taxRate);
	            	        	
				Double initialInterest = (objPaymentPlan.Net_Total__c * (objPaymentPlan.Late_Payment_Interest__c/100))/12;
				
				Decimal paymentEstimated = ((Decimal)((totalAux-objPaymentPlan.Initial_Payment__c+initialInterest)/(newTerm-1))).setScale(2);
				
				if(objPaymentPlan.Initial_Payment__c > (fullTotalAmountClaimed)){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Initial Payment should be less/equal than Amount Claimed (Incl VAT)'));  

					return null; //TODO ERROR
				}
					
				Decimal remainValueAmountClaimedAux = fullTotalAmountClaimed-objPaymentPlan.Initial_Payment__c+initialInterest;
				remainValueAmountClaimedAux = remainValueAmountClaimedAux.setScale(2);
				
				Double remainValueAmountClaimed = remainValueAmountClaimedAux;
	            Integer partialTerm;
	            
	            partialTerm = (Integer)(((remainValueAmountClaimed)/paymentEstimated).setScale(0));
	            if(partialTerm == 0 && remainValueAmountClaimed != 0)
	            	partialTerm = 1;
	            	
	            objPaymentPlan.Partial_Payment_Plan_Term__c = partialTerm+1;
	            
	            List<Double> partialAmount = new List<Double>();
	            if(partialTerm == 1)
	            	partialAmount.add(remainValueAmountClaimed);
	            else if(partialTerm >= 2){
	            	Decimal firstPay = (Decimal)(remainValueAmountClaimed/partialTerm);
	            	firstPay = firstPay.setScale(2);
	            	partialAmount.add(Double.valueOf(firstPay));
	            	partialAmount.add((remainValueAmountClaimed-(Double.valueOf(firstPay)*(partialTerm-1))));
	            }
	            
	            
	            Integer bcTerm = newTerm - partialTerm - 1;
	            
	            
	            List<Double> bcAmount;

	            bcAmount = getPartialPaymentAmount(totalAux-fullTotalAmountClaimed , bcTerm); 

	            objPaymentPlan.New_Contract_Term__c = bcTerm;
	            

	            fullResults.clear();

				createNPaymentSchedule(1, 1, Double.valueOf(objPaymentPlan.Initial_Payment__c-initialInterest), fullResults,objPaymentPlan.Hit_Date__c, (Double)objPaymentPlan.Net_Total__c);
	            if(partialTerm != 0){
	            	Integer beginPartial;
	            	if(partialTerm == 1) beginPartial = 1; else beginPartial = partialTerm-1;
	            	createNPaymentSchedule(beginPartial, 2, partialAmount[0], fullResults,objPaymentPlan.Hit_Date__c, (Double)fullResults[fullResults.size()-1].Balance__c);
	            	if(partialTerm != 1)
	            		createNPaymentSchedule(1, partialTerm, partialAmount[1], fullResults, objPaymentPlan.Hit_Date__c, ((Double)fullResults[fullResults.size()-1].Balance__c));            
	            }

	            
	            createNPaymentSchedule(bcTerm-1, partialTerm+2, bcAmount[0], fullResults, objPaymentPlan.Hit_Date__c,(Double)fullResults[fullResults.size()-1].Balance__c);
	            createNPaymentSchedule(1,newTerm, bcAmount[1], fullResults, objPaymentPlan.Hit_Date__c,(Double)fullResults[fullResults.size()-1].Balance__c);  
	            
	            fullResults[0].Due_Date__c = objPaymentPlan.Hit_Date__c;
	            
	            if(objPaymentPlan.Dilute_Residual_Value__c == false && objPaymentPlan.Residual_Value__c != 0){
	                //new schedule for residual value
	                objPaymentPlan.Total_Residual_Value__c = (objPaymentPlan.Residual_Value__c/100) * objPaymentPlan.Total_Equipment_Cost__c * (1+taxRate);
	                objPaymentPlan.Total_Residual_Value__c = objPaymentPlan.Total_Residual_Value__c.setScale(2);
	                Payment_Schedule__c ps = new Payment_Schedule__c();
	                ps.Amount__c =  objPaymentPlan.Total_Equipment_Cost__c * (objPaymentPlan.Residual_Value__c/100) * (1+taxRate);
	           
	                ps.Schedule_Number__c = ''+(fullResults.size()+1);
	                ps.Amount_W_O_Tax__c = ps.Amount__c / (1+taxRate);
	                ps.Amount_W_O_Tax__c = ps.Amount_W_O_Tax__c.setScale(2);
	                ps.Due_Date__c = fullResults[fullResults.size()-1].Due_Date__c.addDays(30) ;
	                
	                if(ps.Due_Date__c.month() == 2 && (objPaymentPlan.Day_Of_Month_To_Pay__c =='29' || objPaymentPlan.Day_Of_Month_To_Pay__c =='30'))
	                    ps.Due_Date__c = Date.newInstance(ps.Due_Date__c.year(),ps.Due_Date__c.month(), 28);
	                else
	                    ps.Due_Date__c = Date.newInstance(ps.Due_Date__c.year(),ps.Due_Date__c.month(), Integer.valueOf(objPaymentPlan.Day_Of_Month_To_Pay__c));   
	
	                ps.Late_Payment_Interest_Amount__c = (ps.Amount__c * (objPaymentPlan.Late_Payment_Interest__c/100))/12 ;
	                ps.Balance__c = fullResults[fullResults.size()-1].Balance__c-ps.Amount_W_O_Tax__c;
	                if(((Decimal)ps.Balance__c).setScale(2) == 0.01 || ((Decimal)ps.Balance__c).setScale(2) == -0.01)
	                    ps.Balance__c = 0;              
	                    
	                if(!objPaymentPlan.Dilute_Residual_Value__c){
	                      ps.Balance__c = 0;   
	                      ps.Late_Payment_Interest_Amount__c = 0;
	                }
	                objPaymentPlan.Late_Payment_Interest_Amount__c += ps.Late_Payment_Interest_Amount__c;
	               
	                ps.Total_Amount__c = ps.Amount__c +  ps.Late_Payment_Interest_Amount__c;                                    
	                fullResults.add(ps);
	            }
	            
	            if(!objPaymentPlan.Dilute_Residual_Value__c){
	                totalAux += objPaymentPlan.Total_Residual_Value__c;
	                objPaymentPlan.Net_Total__C += objPaymentPlan.Total_Residual_Value__c;
	                objPaymentPlan.PP_Total_Amount__c += objPaymentPlan.Total_Residual_Value__c;
	            }
	            
	            totalAux+= objPaymentPlan.Late_Payment_Interest_Amount__c;  
	            objPaymentPlan.PP_Total_Amount__c = totalAux;	        	
	        	
	        } 
        }
        
        Integer term = Integer.valueOf(objPaymentPlan.New_Contract_Term__c + objPaymentPlan.Partial_Payment_Plan_Term__c);
       
        Double totalContracts=0; 
        for(Billing_Contract__c billCont : bcList){
        	//porque é populado por formula, e o contrato teria de ser no futuro
        	if(!Test.isRunningTest())
        		totalContracts+=billCont.Current_Balance__c;
        	else
        		totalContracts+=1000;
        }
        Decimal firstCapital = totalContracts / term;
        firstCapital = firstCapital.setScale(2); 
        Decimal lastCapital = totalContracts - (firstCapital * (term-1));
        //calculate capital
       	for(Integer i = Integer.valueOf(objPaymentPlan.Partial_Payment_Plan_Term__c); i < (term-1); i++){
       		fullResults[i].Principal__c = firstCapital;
       	}
        
        fullResults[term-1].Principal__c = lastCapital;
        objPaymentPlan.Total_Residual_Value__c = objPaymentPlan.Total_Residual_Value__c / (1+taxRate);
        objPaymentPlan.Total_Residual_Value__c  = objPaymentPlan.Total_Residual_Value__c.setScale(2);
        return null;            
    } 
    
    public void createNPaymentSchedule(Integer times, Integer start, Double amount, List<Payment_Schedule__c> listToAdd, Date dateToStart, Double startBalance){

        if(start!=1){
            dateToStart = dateToStart.addDays(30*(start-1));
        }
        
        if(dateToStart.day() < 15 && Integer.valueOf(objPaymentPlan.Day_Of_Month_To_Pay__c) >= 15){
            dateToStart = dateToStart.addDays(-30);
        }
        
        
    
        Double amountWoTax = ((amount)/(1+taxRate));
        
        for(Integer i = start; i <= ((times-1)+start); i++){
            Payment_Schedule__c ps = new Payment_Schedule__c();
            ps.Amount__c = amount;
            
            ps.Late_Payment_Interest_Amount__c = (startBalance  * (objPaymentPlan.Late_Payment_Interest__c/100))/12 ;
            startBalance = startBalance - amountWoTax ;            
            ps.Balance__c = startBalance;
            
            ps.Total_Amount__c = ps.Amount__c +  ps.Late_Payment_Interest_Amount__c;            
            ps.Schedule_Number__c = ''+i;
            ps.Amount_W_O_Tax__c = amountWoTax;
            ps.Amount_W_O_Tax__c = ps.Amount_W_O_Tax__c.setScale(2);
            if(ps.Schedule_Number__c == '1'){
                ps.Due_Date__c = objPaymentPlan.Hit_Date__c;
            }else
                ps.Due_Date__c = dateToStart;
            objPaymentPlan.Late_Payment_Interest_Amount__c += ps.Late_Payment_Interest_Amount__c;
            if(ps.Due_Date__c.month() == 2 && (objPaymentPlan.Day_Of_Month_To_Pay__c =='29' || objPaymentPlan.Day_Of_Month_To_Pay__c =='30'))
                ps.Due_Date__c = Date.newInstance(ps.Due_Date__c.year(),ps.Due_Date__c.month(), 28);
            else
                ps.Due_Date__c = Date.newInstance(ps.Due_Date__c.year(),ps.Due_Date__c.month(), Integer.valueOf(objPaymentPlan.Day_Of_Month_To_Pay__c));   
                             
            dateToStart = dateToStart.addDays(30);
            fullResults.add(ps);
        }    
        
    }
    
    public List<Double> getPartialPaymentAmount(Double total, Integer numOfPayments){
        Decimal amountClaimed = (total/ numOfPayments);
        amountClaimed = amountClaimed.setScale(2);        
        Double lastSchedule = total - (amountClaimed * (numOfPayments-1)) ;   
        List<Double> payments = new List<Double>{amountClaimed, lastSchedule};
        return payments;     
    } 
    
    
    /***************************************************************************************/
    /*																					   */
 	/*	         						Others                  	      				   */
    /*																					   */
    /***************************************************************************************/       
          
       
    public PageReference changePaymentPlanType(){
        partial = !partial;    
        if(partial && !payScheduleList.isEmpty()){
            showResult = true; 
        }
                 
        full = !full;  
        if(full){
            objPaymentPlan.Amount_Claimed__c = fullTotalAmountClaimed ;
            showResult = false;
        }
        

             
        return null;   
    }
    
       
    
}