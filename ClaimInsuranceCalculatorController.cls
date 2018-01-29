public class ClaimInsuranceCalculatorController {

    public Claim_Insurance__c objClaimInsurance{get;set;}
    public Id recordId{get; set;}
    public Decimal financingRate{get; set;}
    public Decimal auxPaymentAmount{get; set;}
    public Integer noOfPaymentsEndContract{get; set;}
    public Decimal damagedEquipmentCostPer{get; set;}
    public Decimal damagedEquipmentCost{get; set;}
    public Decimal damagedEquipmentPV{get; set;}
    public Decimal residualValue{get; set;}
    public Decimal insuranceCoverageAmount{get; set;}
    public Decimal damagedEquipCost{get;set;}
    //Constructor
    public ClaimInsuranceCalculatorController(ApexPages.StandardController controller){
        try{
            recordId=ApexPages.currentPage().getParameters().get('id');
            
            //Initialization of all output results
            financingRate = 0;
            auxPaymentAmount = 0;
            noOfPaymentsEndContract = 0;
            damagedEquipmentCostPer = 0;
            damagedEquipmentCost = 0;
            damagedEquipmentPV = 0;
            residualValue = 0;
            insuranceCoverageAmount = 0;
            
            //Fetch claim insurance from id 
            if(recordId!=null){
                //Dynamically formed query for fetching claim insurance and it's equipment
                DescribesObjectResult describeResult = Claim_Insurance__c.getsObjectType().getDescribe();
                List<String> claimInsuranceFields = new List<String>(describeResult.fields.getMap().keySet());
                String query = 'SELECT '+String.join(claimInsuranceFields,',');
                query += ', Billing_Contract__r.Equipment_Cost__c, Billing_Contract__r.End_of_Term__c, Billing_Contract__r.Next_Invoice_Date__c, Billing_Contract__r.Contract_Term__c, Billing_Contract__r.Payment_Amount__c FROM '+describeResult.getName()+' WHERE Id = \''+recordId+'\'';
                
                List<Claim_Insurance__c> claimInsuranceList = new List<Claim_Insurance__c>();
            
                claimInsuranceList = Database.query(query);
                
                System.debug('claimInsuranceList -->>'+claimInsuranceList);
                
                if(claimInsuranceList.size()>0){
                    objClaimInsurance = claimInsuranceList[0];
                }
                
                List<Billing_Contract_Line_Item__c> billingContractLIList = [SELECT Id, Name, Line_Item_End_Date__c, Invoiced__c, Product__c, Product__r.ProductCode FROM Billing_Contract_Line_Item__c WHERE Billing_Contract__c =: objClaimInsurance.Billing_Contract__c AND Invoiced__c = false AND Product__c != null AND (Product__r.ProductCode = 'PT01' OR Product__r.ProductCode = 'PT09') ORDER BY Line_Item_End_Date__c ASC];
                
                damagedEquipCost = 0;
                Set<Id> equipmentIds = new Set<Id>();
          
                for(Damaged_Equipment__c objDamagedEquipment : [SELECT Id, Equipment__c, Sum__c, Quantity__c, Equipment__r.Equipment_Value__c, Claim_Insurance__c FROM Damaged_Equipment__c WHERE Claim_Insurance__c =: recordId]){
                    equipmentIds.add(objDamagedEquipment.Equipment__c);
                    damagedEquipCost += objDamagedEquipment.Sum__c;
                } 
                System.debug('equipmentIds '+equipmentIds);
                System.debug('equipmentIds '+equipmentIds);
                /*for(Equipment__c objEquipment : [SELECT Id, Equipment_Description__c, Equipment_Cost__c, Total_Value__c, Equipment_Quantity__c, Equipment_Serial_Number__c FROM Equipment__c WHERE Id IN: equipmentIds ]){
                    System.debug('objEquipment '+objEquipment);
                    System.debug('objEquipment Total_Value__c '+objEquipment.Total_Value__c);
                    damagedEquipCost += objEquipment.Total_Value__c;
                }*/
                objClaimInsurance.Equipment_Cost__c = objClaimInsurance.Billing_Contract__r.Equipment_Cost__c;
                objClaimInsurance.Damaged_Equipment_Cost__c = damagedEquipCost;
                objClaimInsurance.Max_Insurance_Claim__c = 100;
                objClaimInsurance.End_of_Contract_Date__c = objClaimInsurance.Billing_Contract__r.End_of_Term__c;
                //objClaimInsurance.Next_Payment_Date__c = objClaimInsurance.Billing_Contract__r.Next_Invoice_Date__c; // Doubt
                if(objClaimInsurance.Billing_Contract__r.Contract_Term__c != null){
                    objClaimInsurance.Contract_Term__c = objClaimInsurance.Billing_Contract__r.Contract_Term__c;
                }else{
                    objClaimInsurance.Contract_Term__c = 0;
                }
                
                objClaimInsurance.Payment_Amount__c = objClaimInsurance.Billing_Contract__r.Payment_Amount__c;
                if(billingContractLIList.size() > 0){
                    objClaimInsurance.Next_Payment_Date__c = billingContractLIList[0].Line_Item_End_Date__c;
                }
                if(objClaimInsurance.Discount__c == null){
                    objClaimInsurance.Discount__c = 0;
                }
                if(objClaimInsurance.Premium__c == null){
                    objClaimInsurance.Premium__c = 0;
                }
                getCalculation();
            }
        }
        catch(Exception e){
        }
    }
    
    //Method for calculation of claim insurance
    public PageReference getCalculation(){
        
        System.debug('Inside calculate function');
        
        //Calculate Aux Payment Amount
        if(objClaimInsurance.Max_Insurance_Claim__c == null){
            objClaimInsurance.Max_Insurance_Claim__c = 0;
        }
        if(objClaimInsurance.Contract_Term__c == null){
            objClaimInsurance.Contract_Term__c = 0;
        }
        if(damagedEquipCost != null && objClaimInsurance.Max_Insurance_Claim__c != null && objClaimInsurance.Contract_Term__c != null && objClaimInsurance.Contract_Term__c != 0){
            auxPaymentAmount = (((damagedEquipCost * objClaimInsurance.Max_Insurance_Claim__c) /  100) / objClaimInsurance.Contract_Term__c ).setScale(2, RoundingMode.HALF_UP);
        }else if(damagedEquipCost != null && objClaimInsurance.Max_Insurance_Claim__c != null && objClaimInsurance.Contract_Term__c != null && objClaimInsurance.Contract_Term__c == 0){
            auxPaymentAmount = ((damagedEquipCost * objClaimInsurance.Max_Insurance_Claim__c) /  100).setScale(2, RoundingMode.HALF_UP);
        }
        
        //Calculate No of Payments to End of Contract
        if(objClaimInsurance.End_of_Contract_Date__c != null && objClaimInsurance.Next_Payment_Date__c != null){
            Integer endContractYear = objClaimInsurance.End_of_Contract_Date__c.year();
            Integer nextPaymentYear = objClaimInsurance.Next_Payment_Date__c.year();
            Integer endContractMonth = objClaimInsurance.End_of_Contract_Date__c.month();
            Integer nextPaymentMonth = objClaimInsurance.Next_Payment_Date__c.month();
            Integer noOfMonths = 0;
            if(endContractYear != null && nextPaymentYear != null){
                noOfMonths = (endContractYear - nextPaymentYear) * 12;
            }
            
            if(endContractMonth != null && nextPaymentMonth != null){
                noOfPaymentsEndContract = noOfMonths += (endContractMonth - nextPaymentMonth);
            }
            System.debug('noOfMonths -->> '+noOfMonths);
        }
        //Calculate % d of the damaged Equipment Cost
        if(objClaimInsurance.Equipment_Cost__c == null){
            objClaimInsurance.Equipment_Cost__c = 0;
        }
        if(objClaimInsurance.Equipment_Cost__c != 0 && damagedEquipCost != null){
            damagedEquipmentCostPer = ((damagedEquipCost/objClaimInsurance.Equipment_Cost__c) * 100).setScale(2, RoundingMode.HALF_UP);
        }
        //Calculate  Damaged Equipment Cost Amount Payable
        if(objClaimInsurance.Payment_Amount__c == null){
            objClaimInsurance.Payment_Amount__c = 0;
        }
        if(objClaimInsurance.Payment_Amount__c != null && noOfPaymentsEndContract != null && damagedEquipmentCostPer != null){
            damagedEquipmentCost = ((objClaimInsurance.Payment_Amount__c * noOfPaymentsEndContract * damagedEquipmentCostPer) / 100).setScale(2, RoundingMode.HALF_UP);
        }
        //Calculate Damaged Equipment PV
        if(auxPaymentAmount != null && auxPaymentAmount != 0 && residualValue != null){
            //damagedEquipmentPV = ((damagedEquipmentCostPer / 12) * noOfPaymentsEndContract * 10).setScale(2, RoundingMode.HALF_UP);
            damagedEquipmentPV = (auxPaymentAmount * noOfPaymentsEndContract).setScale(2, RoundingMode.HALF_UP);
            insuranceCoverageAmount = damagedEquipmentPV + residualValue;
        }
        
        //Calculate Residual Value
        if(objClaimInsurance.Residual_Percentage__c == null){
            objClaimInsurance.Residual_Percentage__c = 0;
        }
        if(damagedEquipCost != null && objClaimInsurance.Residual_Percentage__c != null){
            residualValue = ((damagedEquipCost * objClaimInsurance.Residual_Percentage__c) / 100).setScale(2, RoundingMode.HALF_UP);
            insuranceCoverageAmount = damagedEquipmentPV + residualValue;
        }
        //Calculate Insurance Coverage Amount
        if(objClaimInsurance.Discount__c == null){
            objClaimInsurance.Discount__c = 0;
        }
        if(objClaimInsurance.Premium__c == null){
            objClaimInsurance.Premium__c = 0;
        }
        if(residualValue != null && damagedEquipmentPV != null && objClaimInsurance.Discount__c != null && objClaimInsurance.Premium__c != null){
            insuranceCoverageAmount = (residualValue + damagedEquipmentPV - objClaimInsurance.Discount__c + objClaimInsurance.Premium__c).setScale(2, RoundingMode.HALF_UP);
        }
        
        System.debug('Discount__c -->> '+objClaimInsurance.Discount__c);
        System.debug('Premium__c -->> '+objClaimInsurance.Premium__c);
        System.debug('damagedEquipmentPV -->> '+damagedEquipmentPV );
        System.debug('residualValue -->> '+residualValue );
        //Calculate insurance coverage amount
        if(objClaimInsurance.Discount__c != null && objClaimInsurance.Premium__c != null && damagedEquipmentPV != null && residualValue != null){
            insuranceCoverageAmount = damagedEquipmentPV + residualValue - objClaimInsurance.Discount__c + objClaimInsurance.Premium__c;
        }
        return null;
    }
     
    //Method for save calculations for claimed insurance
    public PageReference saveCalculations(){
        try{
            if(objClaimInsurance != null){
                update objClaimInsurance;
            }
            PageReference objRedirectToInsurance = new PageReference('/'+objClaimInsurance.Id);
            objRedirectToInsurance.setRedirect(true);
            return objRedirectToInsurance;
            
        }catch(Exception e){
            System.debug('Error Message '+e.getMessage());
            System.debug('Error stack '+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}
