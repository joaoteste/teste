// Dates important for the process
// 
//App:  App Creation       Settle                                                                                   End of Term
//ISM:  ISM Creation   SettleActivation                 Inactivation                        Activation
//            SettleInactivation                 Activation                        Inactivation
//          |---------------|---------------|-------------------|-------------------------------|------------------------| - - - - - - - - - - - - - - -                                                                                   
//          |                                                                                                       
//  Delivery_Certificate_Signed__c
//
//        ----------------|                                                
//               Invoice_Payment_Date__c
//             
//         --------------------------------|                                
//                                    Beginning_of_Term__c
//                                                                                    


global class InsuranceManagement {
    
    private static OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@candor.pt'];
    
    public InsuranceManagement(){
    }
    
    webservice static string createAndSettleInsurance(String Name){
        Application__c ap = [Select Id,Insurance_Type__c,Insurance__c,Chosen_Insurance_value__c From Application__c where name = :Name limit 1];
        List<Insurance_Management__c> insuranceList = [Select ID,Renting_Application__c,Insurance_Status__c,Old_Insurance_Type__c,Billing_Contract__c
                                                       From Insurance_Management__c where Renting_Application__c = :ap.id];
        Insurance_Management__c insurance;
        String msg;
        if(insuranceList.isEmpty()){
            insurance = createActiveInsuranceManagement(ap.ID, 'Candor', '',null , ap.Insurance_Type__c);
            msg = 'Insurance record created!!';
            
        }else{
            msg = 'Insurance already exists!!';
            insurance  = insuranceList[0];
            //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,));           
        }
        
        List<Billing_Contract__c> billContractList = new List<Billing_Contract__c>([Select Id From Billing_Contract__c where Application__c = :ap.id limit 1]);
        
        if(billContractList.isEmpty()){
            return msg;
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,));           
        }else{
            Billing_Contract__c billContract = billContractList[0];
            String msg2 = InsuranceManagement.settleInsuranceManagement(insurance, ap.Insurance_Type__c, 'Candor', ap.Chosen_Insurance_value__c, ap.Insurance__c);
            if(msg2==null || msg2 == ''){
                msg += 'Insurance record has been settled!!';
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,));           
            }else{
                msg += 'The insurance record cannot be settled';
                msg += msg2;
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,));           
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,msg));           
            }
            return msg;
        }
        
    }
    
    //Creates an object Insurance Management (before Settle Contract)
    public static Insurance_Management__c createActiveInsuranceManagement(ID appId, String company,String policyNumber, Date beginningTerm, String insuranceType){
        
        Insurance_Management__c insuranceManagement = new Insurance_Management__c();
        
        insuranceManagement.Renting_Application__c = appId;
        insuranceManagement.Insurance_Policy_Number__c = policyNumber;
        insuranceManagement.Insurance_Company2__c = company;
        insuranceManagement.Client_Policy_Beginning_Term__c = beginningTerm;
        insuranceManagement.Submitted__c = False;
        //insuranceManagement.Current_Insurance_Type__c = insuranceType;       
        insuranceManagement.Insurance_Status__c = 'Active';
        
        insert insuranceManagement;
        System.debug('Create InsuranceManagement '+insuranceManagement);
        return insuranceManagement;
    }
    
    //Inativate Insurance on renting Appplication (Before being settled)
    public static String insuranceInactivationRenting(Id apId, String insurancePolicyNumber, String insuranceCompany, Date clientPolicyBeginningTerm){
        Application__c app = [Select ID,Name,Delivery_Certificate_Signed__c,Beginning_of_Term__c,AccClient__c,Payment_Timing__c,Insurance_Type__c
                              FROM Application__c 
                              where id = :apId];
        
        app.Insurance_Type__c = 'Own Insurance';
        update app;
        
        Insurance_Management__c insuranceManagement = new Insurance_Management__c(Client_Policy_Beginning_Term__c = clientPolicyBeginningTerm, 
                                                                                  Insurance_Policy_Number__c = insurancePolicyNumber,
                                                                                  Insurance_Company2__c = insuranceCompany,
                                                                                  Renting_Application__c = apId,
                                                                                  Insurance_Status__c = 'Inactive',
                                                                                  Submitted__c = True, Submitted_Date__c = Date.today());
        insert insuranceManagement;
        /*
insuranceManagement.Insurance_Status__c = 'Inactive';
insuranceManagement.Client_Policy_Beginning_Term__c = clientePolicyBeginningTerm;
insuranceManagement.Insurance_Policy_Number__c = insurancePolicyNumber; 
insuranceManagement.Insurance_Company2__c = insuranceCompany;
InsuranceManagement.Submitted__c = True;
InsuranceManagement.Submitted_Date__c = Date.today();

update insuranceManagement;
*/
        return '';
    }
    
    //When the agreement is settled, insurance is activated and the enable / disable buttons are made on the Billing Contract object
    public static String settleInsuranceManagement(Insurance_Management__c insuranceManagement,String insuranceType, String insuranceCompany, Decimal insuranceValue, Decimal insurancePercent){
        Billing_Contract__c billContract = [Select ID,Application__r.Insurance_Type__c ,Application__r.Vendor__r.Insurance_Type__c
                                            FROM Billing_Contract__c 
                                            where Application__c = :insuranceManagement.Renting_Application__c limit 1];
        
        String msg = '';                                                
        if(insuranceCompany == ''){
            msg += 'Insurance Company field cannot be empty' ;
        }
        
        if(insuranceValue == null){
            msg += 'Insurace value field cannot be empty' ;
        }  
        
        if(insurancePercent == null){
            msg += 'Insurance Percentage field cannot be empty';    
        }
        
        if(insuranceType == ''){
            msg += 'Insurance Type field cannot be empty';    
        }
        
        if(msg != ''){
            return msg;
        }
        
        Schema.DescribeFieldResult fieldResult = Insurance_Management__c.Insurance_Company2__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        boolean pickListValue = false;
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getLabel() == insuranceCompany){
                pickListValue = true;
            }
        }
        if(!pickListValue){
            return 'Insurance Company value must be on picklist';
        }
        insuranceManagement.Insurance_Company2__c = insuranceCompany;
        
        if(billContract.Application__r.Insurance_Type__c == 'Own Insurance'){
            insuranceManagement.Insurance_Status__c = 'Inactive';
            //insuranceManagement.Old_Insurance_Type__c = 'Static Risk';
            insuranceManagement.Old_Insurance_Type__c = billContract.Application__r.Vendor__r.Insurance_Type__c;
        }else{
            insuranceManagement.Insurance_Status__c = 'Active';
            insuranceManagement.Old_Insurance_Type__c = 'Own Insurance';
        }
        
        insuranceManagement.Billing_Contract__c = billContract.id;
        
        update billContract;
        
        //billings are automaticly created throught Bill_BillingProcess
        
        update insuranceManagement;
        
        System.debug('Settle InsuranceManagement '+insuranceManagement);
        return '';
    }
    
    //cancellation of the insurance on the billing contract
    public static String cancelInsurance(ID appID, String insurancePolicyNumber, String insuranceCompany, Date clientePolicyBeginningTerm){
                
        Application__c app = [Select ID,Name,Delivery_Certificate_Signed__c,Invoice_Payment_Date__c,Beginning_of_Term__c,AccClient__c,Payment_Timing__c,Insurance_Type__c,
                              Payment_Freq__c,Payment_Method__c, Client_Signer_1_First_Name__c,Client_Signer_1_Last_Name__c,Aux_Quarterly_Days__c,
                              AccClient__r.Name,AccClient__r.BillingPostalCode,AccClient__r.c2g__CODAInvoiceEmail__c,AccClient__r.Tax_Zone__c,AccClient__r.c2g__CODABankIBANNumber__c
                              FROM Application__c 
                              where id = :appID];
        
        app.Insurance_Type__c = 'Own Insurance';
        
        //the update is made in the final to use the values of the insurance to create the credit notes. if made right here the insurance value would be 0
        //update app;
        Integer insuranceCreditDays = app.Delivery_Certificate_Signed__c.daysBetween(clientePolicyBeginningTerm)-1;
        if(insuranceCreditDays<0){
            insuranceCreditDays = 0;
        }
        Insurance_Management__c oldInsurance = [Select Id,Name,Renting_Application__c,Billing_Contract__c, Insurance_Status__c,Insurance_Policy_Number__c,Insurance_Company2__c,InsuranceType__c,
                                                Client_Policy_Beginning_Term__c,Insurance_Value2__c,Old_Insurance_Type__c ,Insurance_Credit_Days__c
                                                From Insurance_Management__c 
                                                where Renting_Application__c = :appID 
                                                order by CreatedDate Desc 
                                                limit 1];
        
        Insurance_Management__c insuranceManagement = new Insurance_Management__c(Client_Policy_Beginning_Term__c = clientePolicyBeginningTerm, Insurance_Policy_Number__c = insurancePolicyNumber,Insurance_Company2__c = insuranceCompany,
                                                                                  Insurance_Credit_Days__c = insuranceCreditDays,Renting_Application__c = oldInsurance.Renting_Application__c, Billing_Contract__c = oldInsurance.Billing_Contract__c);
        insert insuranceManagement;
        
        insuranceManagement = [Select Id,Name,Renting_Application__c,Insurance_Status__c,Insurance_Policy_Number__c,Insurance_Company2__c,InsuranceType__c,
                               Client_Policy_Beginning_Term__c,Insurance_Value2__c,Old_Insurance_Type__c ,Insurance_Credit_Days__c
                               From Insurance_Management__c 
                               where id = :insuranceManagement.Id];
        
        /*insuranceManagement.Client_Policy_Beginning_Term__c = clientePolicyBeginningTerm;
insuranceManagement.Insurance_Policy_Number__c = insurancePolicyNumber; 
insuranceManagement.Insurance_Company2__c = insuranceCompany;
*/
        
        //cancel future insurance billings
        List<Billing_Contract_Line_Item__c> futureInsuranceLineItensList = [Select ID,Product_Code__c,Line_Item_Start_Date__c,Invoiced__c 
                                                                            From Billing_Contract_Line_Item__c 
                                                                            where Application__c = :app.ID and Product_Code__c = 'PT02' and Line_Item_Start_Date__c > :insuranceManagement.Client_Policy_Beginning_Term__c and Invoiced__c = False];
        delete futureInsuranceLineItensList;
                
        Date startDate;
        if(insuranceManagement.Insurance_Credit_Days__c >= 30){
            startDate = Date.newInstance(insuranceManagement.Client_Policy_Beginning_Term__c.year(), insuranceManagement.Client_Policy_Beginning_Term__c.month(), 1);
            
            if(app.Payment_Timing__c == Bill_BillingProcess.PAYMENT_FREQ_QUARTERLY){
                
                Integer day = insuranceManagement.Client_Policy_Beginning_Term__c.Day();
                Integer month = insuranceManagement.Client_Policy_Beginning_Term__c.Month();
                Integer year= insuranceManagement.Client_Policy_Beginning_Term__c.Year();
                Set<Integer> secondMonths = new Set<Integer>{2,5,8,11};
                    Set<Integer> thirdMonths = new Set<Integer>{3,6,9,12};
                        
                        if(secondMonths.contains(month)){
                            startDate = startDate.addDays(-1*Date.daysInMonth(year, month-1));
                        }
                if(thirdMonths.contains(month)){
                    startDate = startDate.addDays(-1*Date.daysInMonth(year, month-1));
                    startDate = startDate.addDays(-1*Date.daysInMonth(year, month-2));
                }
            }
        }else{
            startDate = app.Invoice_Payment_Date__c;
        }
        System.debug('startDate final '+startDate);
        //create credit notes
        List<c2g__codaCreditNote__c> existingCreditNoteList = new List<c2g__codaCreditNote__c>([Select c2g__Invoice__c,c2g__DueDate__c
                                                                                                From c2g__codaCreditNote__c 
                                                                                                where c2g__InvoiceDate__c <= :Date.Today() and c2g__DueDate__c >= :startDate  and (Renting_Application__c  = :app.id or c2g__Account__c = :app.AccClient__c)
                                                                                                and c2g__CreditNoteReason__c = 'Insurance Cancellation' and  c2g__CreditNoteStatus__c != 'Discarded']);
        List<ID> existingCreditNoteIDList = new List<ID>();
        for(c2g__codaCreditNote__c existingCreditNote: existingCreditNoteList ){
            existingCreditNoteIDList.add(existingCreditNote.c2g__Invoice__c);
        }
        
        List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>([Select ID, Name, c2g__Account__c,Application__c,c2g__CopyAccountValues__c, c2g__CopyDefaultPrintedTextDefinitions__c, c2g__InvoiceCurrency__c,c2g__InvoiceRate__c,c2g__InvoiceTotal__c,
                                                                                    c2g__InvoiceStatus__c, c2g__CustomerReference__c, c2g__DeriveCurrency__c,c2g__DeriveDueDate__c,c2g__DerivePeriod__c,c2g__Dimension1__c,c2g__Dimension2__c,c2g__Dimension3__c,c2g__Dimension4__c,
                                                                                    c2g__DiscardReason__c,c2g__DualRate__c,c2g__DueDate__c,c2g__ExternalId__c,c2g__IntercompanyTransfer__c,c2g__InvoiceDate__c,c2g__Opportunity__c,c2g__OwnerCompany__c,c2g__Period__c,
                                                                                    c2g__PrintedText1AllowEdit__c,c2g__PrintedText1Heading__c,c2g__PrintedText1Text__c,c2g__PrintedText1TextDefinitionName__c,
                                                                                    c2g__PrintedText2AllowEdit__c,c2g__PrintedText2Heading__c,c2g__PrintedText2Text__c,c2g__PrintedText2TextDefinitionName__c,
                                                                                    c2g__PrintedText3AllowEdit__c,c2g__PrintedText3Heading__c,c2g__PrintedText3Text__c,c2g__PrintedText3TextDefinitionName__c,
                                                                                    c2g__PrintedText4AllowEdit__c,c2g__PrintedText4Heading__c,c2g__PrintedText4Text__c,c2g__PrintedText4TextDefinitionName__c,
                                                                                    c2g__PrintedText5AllowEdit__c,c2g__PrintedText5Heading__c,c2g__PrintedText5Text__c,c2g__PrintedText5TextDefinitionName__c,
                                                                                    c2g__PrintStatus__c,c2g__SalesTaxDocumentCode__c,c2g__SalesTaxStatus__c,c2g__UnitOfWork__c,CR_Sepa_Record__c,ffbext__Approved__c,Invoice_Email_Status__c
                                                                                    From c2g__codaInvoice__c  
                                                                                    where Application__c = :app.Id and c2g__InvoiceDate__c <= :Date.Today() and c2g__DueDate__c >= :startDate
                                                                                    and c2g__InvoiceStatus__c != 'Discarded' and Canceled__c = false and id NOT IN :existingCreditNoteIDList
                                                                                    order by c2g__InvoiceDate__c asc]);
        
        if(salesInvoiceList.size() > 0){
            
            //list salesinvocie lineItem
            List<c2g__codaInvoiceLineItem__c> salesInvoiceItemList = [Select ID,c2g__Invoice__c,c2g__DeriveLineNumber__c,c2g__DeriveUnitPriceFromProduct__c,c2g__GeneralLedgerAccount__c,c2g__LineDescription__c,
                                                                      c2g__LineNumber__c,c2g__OwnerCompany__c,c2g__Product__c,c2g__Quantity__c,c2g__UnitOfWork__c,c2g__UnitPrice__c,
                                                                      c2g__CalculateTaxValue1FromRate__c,c2g__DeriveTaxRate1FromCode__c,c2g__Dimension1__c,c2g__SetTaxCode1ToDefault__c,c2g__TaxCode1__c,c2g__TaxValue1__c,
                                                                      c2g__CalculateTaxValue2FromRate__c,c2g__DeriveTaxRate2FromCode__c,c2g__Dimension2__c,c2g__SetTaxCode2ToDefault__c,c2g__TaxCode2__c,c2g__TaxValue2__c,
                                                                      c2g__CalculateTaxValue3FromRate__c,c2g__DeriveTaxRate3FromCode__c,c2g__Dimension3__c,c2g__SetTaxCode3ToDefault__c,c2g__TaxCode3__c,c2g__TaxValue3__c,
                                                                      c2g__Dimension4__c, Billing_Contract_Line_Item__r.Billing_Period_Date__c
                                                                      From c2g__codaInvoiceLineItem__c
                                                                      Where c2g__Invoice__c in :salesInvoiceList and c2g__Product__c in (Select ID From Product2 Where (ProductCode = 'PT02' or ProductCode ='PT11')) 
                                                                     ];         
            
            //Set the Insurance Credit Amount
            insuranceManagement.Insurance_Credit_Amount__c = insuranceCreditAmount(app,insuranceManagement, salesInvoiceItemList);
            
            //Map key = ID SaleInvoice  -> Object : List of insurace sales invoice line 
            Map<ID,List<c2g__codaInvoiceLineItem__c>> insuranceSINItemMap = new Map<ID,List<c2g__codaInvoiceLineItem__c>>();
            for(c2g__codaInvoiceLineItem__c salesInvoiceItemAux :salesInvoiceItemList){
                if(insuranceSINItemMap.get(salesInvoiceItemAux.c2g__Invoice__c) == null){
                    List<c2g__codaInvoiceLineItem__c> invoiceLineItemList = new List<c2g__codaInvoiceLineItem__c>();
                    invoiceLineItemList.add(salesInvoiceItemAux);
                    insuranceSINItemMap.put(salesInvoiceItemAux.c2g__Invoice__c, invoiceLineItemList);
                }else{
                    insuranceSINItemMap.get(salesInvoiceItemAux.c2g__Invoice__c).add(salesInvoiceItemAux);
                }
            }
            
            List<c2g__codaCreditNote__c> codaCreditNoteList= new List<c2g__codaCreditNote__c>();
            //refund everything
            if(insuranceManagement.Insurance_Credit_Days__c<30){
                //For all salesinvoice create de credit note
                if(!salesInvoiceList.isEmpty()){
                    for(c2g__codaInvoice__c salesInvoiceAux :salesInvoiceList){
                        if(insuranceSINItemMap.get(salesInvoiceAux.Id) != null){
                            c2g__codaCreditNote__c creditNote = SalesInvoiceCreditNote.createCreditNoteFromSalesInvoice(salesInvoiceAux,app);
                            creditNote.c2g__CreditNoteReason__c = 'Insurance Cancellation';
                            creditNote.c2g__CreditNoteDescription__c = 'Invoice Number: ' + salesInvoiceAux.Name;
                            creditNote.Insurance_Management__c = insuranceManagement.id;
                            creditNote.c2g__DueDate__c = Date.today();
                            codaCreditNoteList.add(creditNote);
                        }
                    }
                    
                    if(!codaCreditNoteList.isEmpty()){
                        insert codaCreditNoteList;
                        List<c2g__codaCreditNoteLineItem__c> creditNoteItemToInsertList = new List<c2g__codaCreditNoteLineItem__c>();
                        for(c2g__codaCreditNote__c creditNoteAux: codaCreditNoteList){
                            if(insuranceSINItemMap.get(creditNoteAux.c2g__Invoice__c) != null){
                                List<c2g__codaInvoiceLineItem__c> invoiceLineItemList = insuranceSINItemMap.get(creditNoteAux.c2g__Invoice__c);
                                for(c2g__codaInvoiceLineItem__c salesInvoiceItemAux :invoiceLineItemList){
                                    c2g__codaCreditNoteLineItem__c creditNoteItem = SalesInvoiceCreditNote.createCreditNoteItemFromSaleInvoiceItem(salesInvoiceItemAux, creditNoteAux.ID);     
                                    creditNoteItemToInsertList.add(creditNoteItem);
                                }
                            }
                        }
                        
                        insert creditNoteItemToInsertList;
                    }
                    
                }
            }
            else{
                System.debug('Beginning salesInvoiceList ' +salesInvoiceList);
                
                List<c2g__codaCreditNoteLineItem__c> creditNoteItemToInsertList = new List<c2g__codaCreditNoteLineItem__c>();
                List<c2g__codaInvoiceLineItem__c> invoiceLineItemList = new List<c2g__codaInvoiceLineItem__c>();
                c2g__codaInvoice__c firstInvoice;
                c2g__codaCreditNote__c firstCreditNote;
                Integer salesInvoiceListSize =  salesInvoiceList.size();
                //the first one is a partial
                for(Integer i = 0; i <salesInvoiceListSize ; i++){
                    System.debug('loop (I) '+i);
                    firstInvoice = salesInvoiceList.remove(0);
                    System.debug('firstInvoice ' + firstInvoice);
                    if(insuranceSINItemMap.get(firstInvoice.id) != null && insuranceSINItemMap.get(firstInvoice.id).size() > 0){                        
                        firstCreditNote = SalesInvoiceCreditNote.createCreditNoteFromSalesInvoice(firstInvoice,app);
                        firstCreditNote.Insurance_Management__c = insuranceManagement.id;
                        firstCreditNote.c2g__CreditNoteReason__c = 'Insurance Cancellation';
                        firstCreditNote.c2g__CreditNoteDescription__c = 'Invoice Number: ' + firstInvoice.Name;
                        firstCreditNote.c2g__DueDate__c = Date.today();
                        invoiceLineItemList = insuranceSINItemMap.remove(firstCreditNote.c2g__Invoice__c);
                        break;
                    }
                }
                
                if(invoiceLineItemList!=null && invoiceLineItemList.size()>0 ){
                    for(c2g__codaInvoiceLineItem__c salesInvoiceItemAux :invoiceLineItemList){
                        System.debug('salesInvoiceItemAux ' + salesInvoiceItemAux);
                        System.debug('clientePolicyBeginningTerm ' + clientePolicyBeginningTerm);
                        System.debug('salesInvoiceItemAux.Billing_Contract_Line_Item__r.Billing_Period_Date__c ' + salesInvoiceItemAux.Billing_Contract_Line_Item__r.Billing_Period_Date__c);
                        
                        if(Bill_BillingProcess.checkDateSamePeriod(clientePolicyBeginningTerm,salesInvoiceItemAux.Billing_Contract_Line_Item__r.Billing_Period_Date__c, app.Payment_Freq__c )){
                            Decimal remainValue = remainingInsuranceValue(app,InsuranceManagement);
                            if(remainValue != 0){
                                c2g__codaCreditNoteLineItem__c creditNoteItem = SalesInvoiceCreditNote.createCreditNoteItemFromSaleInvoiceItem(salesInvoiceItemAux, null);
                                creditNoteItem.c2g__UnitPrice__c = remainValue;
                                creditNoteItemToInsertList.add(creditNoteItem);
                            }
                        }else{
                            if(clientePolicyBeginningTerm < salesInvoiceItemAux.Billing_Contract_Line_Item__r.Billing_Period_Date__c){
                                c2g__codaCreditNoteLineItem__c creditNoteItem = SalesInvoiceCreditNote.createCreditNoteItemFromSaleInvoiceItem(salesInvoiceItemAux, null);
                                creditNoteItemToInsertList.add(creditNoteItem);
                            }
                        }
                    }
                }
                
                //if there is line items to create first it will insert the creditNote and next it will attribute to the itens the credit note to be inserted later
                if(!creditNoteItemToInsertList.isEmpty()){
                    insert firstCreditNote;
                    for(c2g__codaCreditNoteLineItem__c creditNoteItem : creditNoteItemToInsertList){
                        creditNoteItem.c2g__CreditNote__c = firstCreditNote.id;
                    }
                }
                
                System.debug('Second salesInvoiceList ' +salesInvoiceList);
                //For all salesinvoice create de credit note
                if(salesInvoiceList != null && salesInvoiceList.size()>0){
                    for(c2g__codaInvoice__c salesInvoiceAux :salesInvoiceList){
                        if(insuranceSINItemMap.get(salesInvoiceAux.Id) != null){
                            c2g__codaCreditNote__c creditNote = SalesInvoiceCreditNote.createCreditNoteFromSalesInvoice(salesInvoiceAux,app);
                            creditNote.c2g__CreditNoteReason__c = 'Insurance Cancellation';
                            creditNote.c2g__CreditNoteDescription__c = 'Invoice Number: ' + salesInvoiceAux.Name;
                            creditNote.Insurance_Management__c = insuranceManagement.id;
                            creditNote.c2g__DueDate__c = Date.today();
                            codaCreditNoteList.add(creditNote);
                        }
                    }
                    insert codaCreditNoteList;
                    for(c2g__codaCreditNote__c creditNoteAux: codaCreditNoteList){
                        System.debug('invoiceLineItemList: ' + invoiceLineItemList);
                        if(insuranceSINItemMap.get(creditNoteAux.c2g__Invoice__c) != null){
                            invoiceLineItemList = insuranceSINItemMap.get(creditNoteAux.c2g__Invoice__c);
                            for(c2g__codaInvoiceLineItem__c salesInvoiceItemAux :invoiceLineItemList){
                                if(creditNoteAux.Id != null && salesInvoiceItemAux != null){
                                    c2g__codaCreditNoteLineItem__c creditNoteItem = SalesInvoiceCreditNote.createCreditNoteItemFromSaleInvoiceItem(salesInvoiceItemAux, creditNoteAux.ID);     
                                    creditNoteItemToInsertList.add(creditNoteItem);
                                }
                            }
                        }
                    }
                }
                
                if(creditNoteItemToInsertList != null && creditNoteItemToInsertList.size()>0){
                    System.debug('creditNoteItemToInsertList ' +creditNoteItemToInsertList);
                    insert creditNoteItemToInsertList;
                }
                
                codaCreditNoteList.add(firstCreditNote);
            }

            Boolean isPaid = True;
            
            codaCreditNoteList = [Select Id, Name,c2g__CreditNoteTotal__c, c2g__CreditNoteCurrency__r.name,
                                  c2g__Invoice__r.name, c2g__Invoice__r.c2g__InvoiceCurrency__r.Name , c2g__Invoice__r.Invoice_Express_Number_text__c, c2g__Invoice__r.c2g__InvoiceTotal__c 
                                  From c2g__codaCreditNote__c 
                                  Where id in :codaCreditNoteList];
            
            
            List<ID> codaCreditNoteIDList = new List<ID>();
            for(c2g__codaCreditNote__c creditNote : codaCreditNoteList){
                codaCreditNoteIDList.add(creditNote.id);
            }
            
            if(codaCreditNoteList != null && codaCreditNoteList.size() > 0){
                postCreditNote(codaCreditNoteIDList);
            }
            emailInactive(app,codaCreditNoteList,isPaid,insuranceManagement);
            
        }else{
            //Set the Insurance Credit Amount
            insuranceManagement.Insurance_Credit_Amount__c = 0 ;
            emailInactive(app,new List<c2g__codaCreditNote__c>(),True,insuranceManagement);
        }
        //app.Insurance_Type__c = oldInsurance.Old_Insurance_Type__c;
        //String auxType=insuranceManagement.InsuranceType__c;
        insuranceManagement.Old_Insurance_Type__c=oldInsurance.InsuranceType__c;
        InsuranceManagement.Insurance_Status__c = 'Inactive';
        InsuranceManagement.Submitted__c = True;
        InsuranceManagement.Submitted_Date__c = Date.today();
        update app;
        update InsuranceManagement;
        
        System.debug('Cancel InsuranceManagement '+insuranceManagement);
        return '';
    }      
    
    //activation of the insurance on the billing contract
    public static String activationInsurance(ID appID, String insurancePolicyNumber, String insuranceCompany, Date clientePolicyBeginningTerm){
        System.debug('activationInsurance');
        
        Insurance_Management__c oldInsurance = [Select Id,Old_Insurance_Type__c,Insurance_Credit_Days__c,Renting_Application__c,Billing_Contract__c,InsuranceType__c
                                                From Insurance_Management__c 
                                                where Renting_Application__c = :appID 
                                                order by CreatedDate Desc 
                                                limit 1];
        
        Insurance_Management__c insuranceManagement = new Insurance_Management__c(Client_Policy_Beginning_Term__c = clientePolicyBeginningTerm, Insurance_Policy_Number__c = insurancePolicyNumber,Insurance_Company2__c = insuranceCompany,
                                                                                  Submitted__c = True,Submitted_Date__c = Date.today(),Insurance_Status__c = 'Active',Old_Insurance_Type__c=oldInsurance.InsuranceType__c,
                                                                                  Renting_Application__c = oldInsurance.Renting_Application__c, Billing_Contract__c = oldInsurance.Billing_Contract__c);
        
        insert insuranceManagement;
        
        Application__c app = [Select ID,Name,Delivery_Certificate_Signed__c,Beginning_of_Term__c,Chosen_Insurance_value__c,AccClient__r.Name,AccClient__r.BillingPostalCode,AccClient__r.c2g__CODAInvoiceEmail__c,AccClient__r.Tax_Zone__c,AccClient__r.c2g__CODABankIBANNumber__c,
                              Payment_Freq__c, Payment_Method__c,Payment_Timing__c,Client_Signer_1_First_Name__c,Client_Signer_1_Last_Name__c,Aux_Quarterly_Days__c,Insurance_Type__c
                              FROM Application__c 
                              where id = :appID];
        
        String auxType = app.Insurance_Type__c;
        app.Insurance_Type__c = oldInsurance.Old_Insurance_Type__c;
        //the update is made in the begginning to get the value of the insurance
        update app;
        
        insuranceManagement = [Select Id,Name,Renting_Application__c,Insurance_Status__c,Insurance_Policy_Number__c,Insurance_Company2__c,
                               Client_Policy_Beginning_Term__c,Insurance_Value2__c,InsuranceType__c,Old_Insurance_Type__c 
                               From Insurance_Management__c 
                               where id = :insuranceManagement.id];
        /*
insuranceManagement.Client_Policy_Beginning_Term__c = clientePolicyBeginningTerm;
insuranceManagement.Insurance_Policy_Number__c = insurancePolicyNumber; 
insuranceManagement.Insurance_Company2__c = insuranceCompany;
*/
        
        Date billingToCreateStartDate = Date.newInstance(insuranceManagement.Client_Policy_Beginning_Term__c.Year(), insuranceManagement.Client_Policy_Beginning_Term__c.Month(), 1);
        if(app.Payment_Timing__c == Bill_BillingProcess.PAYMENT_TIMING_ARREAS){
            billingToCreateStartDate = billingToCreateStartDate.addMonths(1);
        }
        
        Billing_Contract__c billCont = [Select ID, application__c, Name, Account__c, Account_Vendor__c, Contract_Start_Date__c, Billing_Date_Override__c,Aux_Due_Date__c,Aux_Invoice_Date__c
                                        FROM Billing_Contract__c 
                                        where Application__c = :app.id];
        
        //selects rent billings to create the future insurance
        List<Billing_Contract_Line_Item__c> billingLineItensList = new List<Billing_Contract_Line_Item__c>([Select Id,Billing_Contract__c,Line_Item_Start_Date__c,Product_Code__c
                                                                                                            From Billing_Contract_Line_Item__c 
                                                                                                            Where Billing_Contract__c =: billCont.id and Line_Item_Start_Date__c > :billingToCreateStartDate 
                                                                                                            and Product_Code__c IN ('PT01','PT09')]);
        
        
        BILL_ProductRegion billProductRegion = new BILL_ProductRegion('Input');
        system.debug('billingLineItensList' + billingLineItensList);
        
        //create new insurance billings
        List<Billing_Contract_Line_Item__c> billingLineItensInsert = new List<Billing_Contract_Line_Item__c>();
        String region = app.AccClient__r.Tax_Zone__c;
        ID prod = (new Bill_ProductRegion()).getProduct('PT02', region);
        ID productTaxCode = (new Bill_ProductRegion()).getTaxCode('PT02', region);
        if(insuranceManagement.Insurance_Value2__c != 0){  //Insurance Value
            decimal insurancePrice;
            if(app.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
                insurancePrice = insuranceManagement.Insurance_Value2__c;
            }else if(app.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY){
                insurancePrice = insuranceManagement.Insurance_Value2__c * 3;
            }
            
            for(Billing_Contract_Line_Item__c billing : billingLineItensList){
                System.debug('1');
                Date billingdate = billing.Line_Item_Start_Date__c;
                /*if(billingdate<Date.today()){
billingdate = Date.today();
}*/
				Date billingPeriodDate = BILL_BillingProcess.getBillingPeriodDate(billingdate,app.Payment_Freq__c,app.Payment_Timing__c,app.Payment_Freq__c);

                Billing_Contract_Line_Item__c billInsuranceToAdd = BILL_BillingProcess.createOneBillLineItem(billCont.Id, app,billingdate,billingPeriodDate, prod, insurancePrice,productTaxCode, billProductRegion);
                //if line item start date are older than today recalculate 
                if(billingdate<Date.today()){
                    billingdate = Date.today();
                    billInsuranceToAdd.Line_Item_Start_Date__c = billingdate;
                    Date dueDate;
                    if(app.Payment_Timing__c == BILL_BillingProcess.PAYMENT_TIMING_ADVANCED){
                        dueDate = BILL_BillingProcess.getLineItemEndDateAdvanced(billingdate);
                    }else if(app.Payment_Timing__c ==  BILL_BillingProcess.PAYMENT_TIMING_ARREAS){
                        dueDate = BILL_BillingProcess.getLineItemEndDateArreas(billingdate);
                    }
                    billInsuranceToAdd.Line_Item_End_Date__c = dueDate;
                }
                billingLineItensInsert.add(billInsuranceToAdd);
            }
        }
        system.debug('billingLineItensList' + billingLineItensInsert);
        
        //create the proporcional insurance billing
        ID insuranceProporcionalProduct = (new Bill_ProductRegion()).getProduct('PT11', region);
        ID insurancePropProductTaxCode = (new Bill_ProductRegion()).getTaxCode('PT02', region);
        Billing_Contract_Line_Item__c insuranceProporcionalBillingItem;
        Decimal insuranceProporcionalPrice = remainingInsuranceValue(app,InsuranceManagement);
        if(insuranceProporcionalPrice!=0){
        	
            Date billingdate = insuranceManagement.Client_Policy_Beginning_Term__c;
            Date billingPeriodDate = BILL_BillingProcess.getBillingPeriodDate(billingdate,app.Payment_Freq__c,app.Payment_Timing__c,app.Payment_Freq__c);
            
            insuranceProporcionalBillingItem = BILL_BillingProcess.createOneBillLineItem(billCont.Id, app,billingdate,billingPeriodDate, insuranceProporcionalProduct, insuranceProporcionalPrice,insurancePropProductTaxCode, billProductRegion);
            insuranceProporcionalBillingItem.Billing_Period_Date__c = BILL_BillingProcess.getBillingPeriodDate(billingdate, app.Payment_Freq__c, app.Payment_Timing__c,'One Time');
            insuranceProporcionalBillingItem.Billing_Frequency__c = 'One Time';

            if(billingdate<Date.today()){
                billingdate = Date.today();
                insuranceProporcionalBillingItem.Line_Item_Start_Date__c = billingdate;
                Date dueDate;
                if(app.Payment_Timing__c == BILL_BillingProcess.PAYMENT_TIMING_ADVANCED){
                    dueDate = BILL_BillingProcess.getLineItemEndDateAdvanced(billingdate);
                }else if(app.Payment_Timing__c ==  BILL_BillingProcess.PAYMENT_TIMING_ARREAS){
                    dueDate = BILL_BillingProcess.getLineItemEndDateArreas(billingdate);
                }
                insuranceProporcionalBillingItem.Line_Item_End_Date__c = dueDate;
            }
            
            billingLineItensInsert.add(insuranceProporcionalBillingItem);
        }
        
        //if there is something to insert it will insert
        if (billingLineItensInsert != null && billingLineItensInsert.size()>0){
            System.debug('billingLineItensInsert: ' + billingLineItensInsert);
            insert billingLineItensInsert;
        }
        
        //create the invoice
        List<Id> salesInvoiceIDList = new List<Id>();
        
        
        if(insuranceProporcionalPrice!=0){
            //salesInvoiceIDList.addAll(createInvoices(app,billCont));
            billCont.Aux_Due_Date__c = insuranceProporcionalBillingItem.Line_Item_End_Date__c;
            billCont.Aux_Invoice_Date__c = insuranceProporcionalBillingItem.Line_Item_Start_Date__c;
            update billCont;
            BillingProcess.Create_Due_Sales_invoice(billCont.Id);
        }
        
        //update object insuranceManagement
        /*insuranceManagement.Old_Insurance_Type__c=insuranceManagement.InsuranceType__c;
insuranceManagement.Insurance_Status__c = 'Active';
insuranceManagement.Submitted__c = True;
insuranceManagement.Submitted_Date__c = Date.today();
update insuranceManagement;
*/
        //activation email
        emailActive(app.ID,insuranceManagement);
        
        System.debug('Activate insuranceManagement '+insuranceManagement);
        
        return '';
    }
    
    /*****************************************************************************************************************************************************
******************************************************************* AUXILIAR METHODS    
*****************************************************************************************************************************************************/
    //inactivation email.
    //if client pays with ATM Reference and they don't have iban with will send another email to request the iban
    private static void emailInactive(Application__c app, List<c2g__codaCreditNote__c> codaCreditNoteList,Boolean isPaid, Insurance_Management__c insuranceManagement){
        /*Application__c app = [Select ID,Name,Delivery_Certificate_Signed__c,Beginning_of_Term__c,AccClient__r.Name,AccClient__r.c2g__CODAInvoiceEmail__c,AccClient__r.c2g__CODABankIBANNumber__c,Payment_Timing__c,Insurance_Type__c,
Payment_Freq__c,Payment_Method__c, Client_Signer_1_First_Name__c,Client_Signer_1_Last_Name__c,Aux_Quarterly_Days__c
FROM Application__c 
where id = :appID];


Insurance_Management__c insuranceManagement = [Select ID,Name,Insurance_Policy_Number__c,Insurance_Company__c From Insurance_Management__c where Renting_Application__c = :app.ID limit 1];
*/
        List<Contact> contactList = [Select Email 
        							From Contact 
        							where Send_Invoice__c = true and email != null and email != '' and AccountID = :app.AccClient__c];
        
        //Sending the email
        List<String> sendTo = new List<String>();
        for(Contact cont : contactList){
        	sendTo.add(cont.email);
        }
        //sendTo.add(app.AccClient__r.c2g__CODAInvoiceEmail__c);
        //sendTo.add('pcaetano@candor.pt');
        //sendTo.add('info@candor.pt');
        String sender = 'info@candor.pt';
        List<String> senderList = new List<String>();
        senderList.add(sender);
        
        EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject 
                                  From EmailTemplate 
                                  where DeveloperName = 'Insurance_Inactivation'];
        
        Id templateId = template.id;
        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;
        
        emailSubject = emailSubject.replace('--APName--', app.Name);
        emailSubject = emailSubject.replace('--ISMName--', insuranceManagement.Name);
        
        if(app.Client_Signer_1_First_Name__c!= null){
            emailbody = emailbody.replace('--ContactFirstName--', app.Client_Signer_1_First_Name__c );
            htmlBody=htmlBody.replace('--ContactFirstName--', app.Client_Signer_1_First_Name__c );
        }else{
            emailbody = emailbody.replace('--ContactFirstName--', '' );
            htmlBody=htmlBody.replace('--ContactFirstName--', '' );            
        }
        
        if(app.Client_Signer_1_Last_Name__c != null){
            emailbody = emailbody.replace('--ContactLastName--', app.Client_Signer_1_Last_Name__c );
            htmlBody=htmlBody.replace('--ContactLastName--', app.Client_Signer_1_Last_Name__c );
        }else{
            emailbody = emailbody.replace('--ContactLastName--', '' );
            htmlBody=htmlBody.replace('--ContactLastName--', '' );            
        }
        System.debug('emailbody inactivate BEFORE REPLACE'+ emailbody);
        System.debug('Policy Number inactivate '+ insuranceManagement.Insurance_Policy_Number__c);
        emailbody = emailbody.replace('%InsurancePolicyNumber%', insuranceManagement.Insurance_Policy_Number__c);
        htmlBody=htmlBody.replace('%InsurancePolicyNumber%', insuranceManagement.Insurance_Policy_Number__c );      
        System.debug('emailbody inactivate after REPLACE'+ emailbody);
        
        emailbody = emailbody.replace('--InsuranceCompany--', insuranceManagement.Insurance_Company2__c);
        htmlBody=htmlBody.replace('--InsuranceCompany--', insuranceManagement.Insurance_Company2__c );  
        
        if(!isPaid){
            emailbody = emailbody.replace('%isNotPaid%','' + 'De modo a ser possível realizar as respectivas operações solicitamos que sejam pagas as facturas que se encontrem em atraso.');
            htmlBody=htmlBody.replace('%isNotPaid%', '' + 'De modo a ser possível realizar as respectivas operações solicitamos que sejam pagas as facturas que se encontrem em atraso.');        
            
        }else{
            emailbody = emailbody.replace('%isNotPaid%','');
            htmlBody=htmlBody.replace('%isNotPaid%','');
        }
        
        
        Boolean firstCN = true;
        String tableCreditNote = '';
        for(c2g__codaCreditNote__c creditNote :codaCreditNoteList){
            System.debug('creditNote ' + creditNote);
            if(firstCN){
                tableCreditNote += 'Uma';
                firstCN = false;
            }else{
                tableCreditNote += 'Outra';
            }
            String moloniId = creditNote.c2g__Invoice__r.Invoice_Express_Number_text__c;
            if(moloniId== null){
                moloniId = '';
            }
            tableCreditNote += ' de valor ' + creditNote.c2g__CreditNoteTotal__c + ' ' +creditNote.c2g__CreditNoteCurrency__r.name + ' referente à fatura ' 
                + moloniId + ' de ' + creditNote.c2g__Invoice__r.c2g__InvoiceTotal__c+ ' '+ creditNote.c2g__Invoice__r.c2g__InvoiceCurrency__r.Name + '<br>';
        }
        
        System.debug('tableCreditNote: ' + tableCreditNote);
        emailbody = emailbody.replace('--Table--', tableCreditNote);
        htmlBody = htmlBody.replace('--Table--', tableCreditNote);
        
        htmlBody=htmlBody.replace(']]>', '');
        htmlBody=htmlBody.replace('<![CDATA[', '');
        
        //if the payment method is made by atm and the cliente doesn't have a nif notify the client to fill the field
        if(app.Payment_Method__c == 'ATM Reference' && (app.AccClient__r.c2g__CODABankIBANNumber__c == null || app.AccClient__r.c2g__CODABankIBANNumber__c == '')){
            emailbody = emailbody.replace('--IBAN--','');
            htmlBody=htmlBody.replace('--IBAN--','');
        }else{
            String ibanMsg = 'A devolução dos montantes previamente cobrados, caso se aplique, será realizada em até 3 dias úteis para o IBAN ' + app.AccClient__r.c2g__CODABankIBANNumber__c + '<br>';
            emailbody = emailbody.replace('--IBAN--',ibanMsg);
            htmlBody=htmlBody.replace('--IBAN--',ibanMsg);
        }
        
        emailSend(insuranceManagement.id, emailSubject, emailbody,htmlBody,sendTo);
        
        if(app.Payment_Method__c == 'ATM Reference' && (app.AccClient__r.c2g__CODABankIBANNumber__c == null || app.AccClient__r.c2g__CODABankIBANNumber__c == '')){
            emailIBAN(app, insuranceManagement, tableCreditNote,sendTo);
        }
    }
    
    //email missing iban
    private static void emailIBAN(Application__c app, Insurance_Management__c insuranceManagement, String tableCreditNote, List<String> sendTo){
        
        //sendTo.add(app.AccClient__r.c2g__CODAInvoiceEmail__c);
        //sendTo.add('pcaetano@candor.pt');
        //sendTo.add('info@candor.pt');
        String sender = 'info@candor.pt';
        List<String> senderList = new List<String>();
        senderList.add(sender);
        
        EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject 
                                  From EmailTemplate 
                                  where DeveloperName = 'Insurance_Inactivation_IBAN'];
        
        Id templateId = template.id;
        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;
        
        emailSubject = emailSubject.replace('--APName--', app.Name);
        emailSubject = emailSubject.replace('--ISMName--', insuranceManagement.Name);
        
        if(app.Client_Signer_1_First_Name__c!= null){
            emailbody = emailbody.replace('--ContactFirstName--', app.Client_Signer_1_First_Name__c );
            htmlBody=htmlBody.replace('--ContactFirstName--', app.Client_Signer_1_First_Name__c );
        }else{
            emailbody = emailbody.replace('--ContactFirstName--', '' );
            htmlBody=htmlBody.replace('--ContactFirstName--', '' );            
        }
        
        if(app.Client_Signer_1_Last_Name__c != null){
            emailbody = emailbody.replace('--ContactLastName--', app.Client_Signer_1_Last_Name__c );
            htmlBody=htmlBody.replace('--ContactLastName--', app.Client_Signer_1_Last_Name__c );
        }else{
            emailbody = emailbody.replace('--ContactLastName--', '' );
            htmlBody=htmlBody.replace('--ContactLastName--', '' );            
        }
        
        emailbody = emailbody.replace('--Table--', tableCreditNote);
        htmlBody=htmlBody.replace('--Table--', tableCreditNote );        
        
        htmlBody=htmlBody.replace(']]>', '');
        htmlBody=htmlBody.replace('<![CDATA[', '');
        
        emailSend(insuranceManagement.id, emailSubject, emailbody,htmlBody,sendTo);
    }
    
    //activation email
    private static void emailActive(ID appID, Insurance_Management__c insuranceManagement){
        
        Application__c app = [Select ID,Name,Delivery_Certificate_Signed__c,Beginning_of_Term__c,AccClient__r.Name,AccClient__r.c2g__CODAInvoiceEmail__c, Payment_Timing__c,Insurance_Type__c,
                              Payment_Freq__c,Payment_Method__c, Client_Signer_1_First_Name__c,Client_Signer_1_Last_Name__c,Aux_Quarterly_Days__c
                              FROM Application__c 
                              where id = :appID];
        
        List<Contact> contactList = [Select Email 
        							From Contact 
        							where Send_Invoice__c = true and email != null and email != '' and AccountID = :app.AccClient__c];
        
        //Sending the email
        List<String> sendTo = new List<String>();
        for(Contact cont : contactList){
        	sendTo.add(cont.email);
        }
        
        //sendTo.add(app.AccClient__r.c2g__CODAInvoiceEmail__c);
        //sendTo.add('pcaetano@candor.pt');
        //sendTo.add('info@candor.pt');
        
        EmailTemplate template = [SELECT Id, DeveloperName, Folder.DeveloperName, Body, HtmlValue, Subject 
                                  From EmailTemplate 
                                  where DeveloperName = 'Insurance_Activation'];
        
        Id templateId = template.id;
        String emailSubject = template.Subject;
        String emailbody = template.Body;
        String htmlBody = template.HtmlValue;
        
        emailSubject = emailSubject.replace('--APName--', app.Name);
        emailSubject = emailSubject.replace('--ISMName--', insuranceManagement.Name);
        
        if(app.Client_Signer_1_First_Name__c!= null){
            emailbody = emailbody.replace('--ContactFirstName--', app.Client_Signer_1_First_Name__c );
            htmlBody=htmlBody.replace('--ContactFirstName--', app.Client_Signer_1_First_Name__c );
        }else{
            emailbody = emailbody.replace('--ContactFirstName--', '' );
            htmlBody=htmlBody.replace('--ContactFirstName--', '' );            
        }
        
        if(app.Client_Signer_1_Last_Name__c != null){
            emailbody = emailbody.replace('--ContactLastName--', app.Client_Signer_1_Last_Name__c );
            htmlBody=htmlBody.replace('--ContactLastName--', app.Client_Signer_1_Last_Name__c );
        }else{
            emailbody = emailbody.replace('--ContactLastName--', '' );
            htmlBody=htmlBody.replace('--ContactLastName--', '' );            
        }
        
        System.debug('Policy Number activate '+ insuranceManagement.Insurance_Policy_Number__c);
        System.debug('emailbody inactivate BEFORE REPLACE'+ emailbody);
        emailbody = emailbody.replace('%InsurancePolicyNumber%', insuranceManagement.Insurance_Policy_Number__c);
        htmlBody=htmlBody.replace('%InsurancePolicyNumber%', insuranceManagement.Insurance_Policy_Number__c );      
        System.debug('emailbody inactivate after REPLACE'+ emailbody);
        
        emailbody = emailbody.replace('--InsuranceCompany--', insuranceManagement.Insurance_Company2__c);
        htmlBody=htmlBody.replace('--InsuranceCompany--', insuranceManagement.Insurance_Company2__c );  
        
        emailbody = emailbody.replace('--APName--', app.Name);
        htmlBody=htmlBody.replace('--APName--', app.Name);      
        
        emailbody = emailbody.replace('--AccountName--', app.AccClient__r.Name );
        htmlBody=htmlBody.replace('--AccountName--', app.AccClient__r.Name );    
        
        htmlBody=htmlBody.replace(']]>', '');
        htmlBody=htmlBody.replace('<![CDATA[', '');
        
        emailSend(insuranceManagement.id, emailSubject, emailbody,htmlBody,sendTo);
    }
    
    private static void emailSend(ID insuranceID, String emailSubject, String emailbody,String htmlBody, List<String> sendTo){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(emailSubject);
        /*List<String> senderList = new List<String>();
senderList.add(sender);*/
        email.setToAddresses(sendTo);
        email.setPlainTextBody(emailbody);
        email.setHtmlBody(htmlBody);
        email.setWhatId(insuranceID);
        email.setOrgWideEmailAddressId(owea.get(0).Id);
        if(!Test.isRunningTest()){
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
    
    /*
Calculate the insurance Credit Amount based on the policy Beginning Term
*/
    private static decimal insuranceCreditAmount(Application__c app, Insurance_Management__c insuranceManagement, List<c2g__codaInvoiceLineItem__c> insuranceItemList){
        Decimal insuranceAmount = 0;
        //Caso o cancelamento não seja feito antes do settle contract não existe nada a ser faturado
        //   if(insuranceManagement.Client_Policy_Beginning_Term__c>app.Beginning_of_Term__c){   
        
        //Se o numero de dias for menor que 30 é devolvido a totalidade de seguro faturado
        if(insuranceManagement.Insurance_Credit_Days__c<30){
            
            Decimal insurancePaidSum = 0;
            if(insuranceItemList.size()>0){
                for(c2g__codaInvoiceLineItem__c insurance : insuranceItemList){
                    insurancePaidSum += insurance.c2g__UnitPrice__c;
                }           
            }
            insuranceAmount = insurancePaidSum;
        }else{
            //terá que ser feito o ajustamento com o numero de dias que falta até ao fim do termo atual
            insuranceAmount = remainingInsuranceValue(app,insuranceManagement);
        }
        return insuranceAmount;
        /*}else{
return 0;
}*/
    } 
    
    /*
Calculates the remaining value of the insurance until the end of the period (montlhy or quarterly)

If the insurance is inactive, we are activating it and therefore the method is done for the creation of the proporcional insurance billing. So the calculation is made from the Today date.
On the contrary, if the insurance is active, we are inactivating it and the method is used for the credit note or to calculate the insurance Credit Amount. The remain will use the Client_Policy_Beginning_Term__c   
*/
    private static decimal remainingInsuranceValue(Application__c app, Insurance_Management__c insuranceManagement){
        Decimal insuranceDaysRatio = 1.00;
        Decimal insuranceValue;
        
        Date remainDate;
        
        remainDate = insuranceManagement.Client_Policy_Beginning_Term__c;
        
        if(app.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY){
            
            Integer policyTermDay = remainDate.day();
            Integer policyTermMonth = remainDate.Month();
            Integer policyTermYear = remainDate.year();
            
            insuranceDaysRatio =  (30 - policyTermDay + 1);
            insuranceValue = insuranceDaysRatio * insuranceManagement.Insurance_Value2__c;
            insuranceValue = insuranceValue.divide(30, 2); 
        }
        if(app.Payment_Freq__c == BILL_BillingProcess.PAYMENT_FREQ_QUARTERLY){
            Integer policyTermDay = remainDate.day();
            Integer policyTermMonth = remainDate.Month();
            if(policyTermMonth == 2 || policyTermMonth ==5 || policyTermMonth==8 || policyTermMonth == 11){
                insuranceDaysRatio = 60- policyTermDay +1;
            }else{
                if(policyTermMonth == 3 || policyTermMonth ==6 || policyTermMonth==9 || policyTermMonth == 12){
                    insuranceDaysRatio = 30- policyTermDay +1;
                }else{
                    insuranceDaysRatio = 90 - policyTermDay +1;
                }
            }
            insuranceValue = insuranceDaysRatio * insuranceManagement.Insurance_Value2__c * 3;
            insuranceValue  = insuranceValue.divide(90, 2);
            System.debug('insuranceDaysRatio ' + insuranceDaysRatio);
            System.debug('insuranceManagement.Insurance_Value2__c ' + insuranceManagement.Insurance_Value2__c);
            System.debug('insuranceValue ' + insuranceValue);
            
        }
        return insuranceValue;
    }
    
    @future
    private static void postCreditNote(List<ID> codaCreditNoteList){
        List<c2g.CODAAPICommon.Reference> referenceList = new List<c2g.CODAAPICommon.Reference>();
        for(ID creditNoteID : codaCreditNoteList){
            c2g.CODAAPICommon.Reference refinv = new c2g.CODAAPICommon.Reference();
            refinv.id = creditNoteID;
            referenceList.add(refinv);
        }
        System.debug('referenceList ' + referenceList);
        
        System.debug('4. queries '+  Limits.getQueries() + ' of ' +  Limits.getLimitQueries());
        
        //post creditNote
        c2g.CODAAPISalesCreditNote_9_0.BulkPostCreditNote(null, referenceList);
        
        System.debug('5. queries '+  Limits.getQueries() + ' of ' +  Limits.getLimitQueries());
    }
    
    
}