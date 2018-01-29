public class Insolvency_Procedure_Handler {
	
	//after inserting an insolvency action, create a Case
	public static void handleCreateCase(List<Insolvency_Judicial_Procedure__c> newInsolvs){
		List<Id> accountIds = new List<Id>();
		for(Insolvency_Judicial_Procedure__c insolv : newInsolvs){
            accountIds.add(insolv.Account_Client__c);
        }
        
        List<Account> accounts = [SELECT Name FROM Account WHERE Id IN :accountIds];
        
        List<Case> toInsert = new List<Case>();
        for(Account acc : accounts){
        	Case aux = Case_Utils.newCase('High','Interno','Administração','Acção de Insolvência','Please report to the Lawyer to proceed with an Insolvency Action', acc.id);
        	aux.Subject = 'Insolvency Action Against '+acc.Name;
        	toInsert.add(aux);
        }
        
        insert toInsert;
	}


    //before inserting an isolvency action, populate its collection case from client account (if exists)
    public static void handleSetCollectionCase(List<Insolvency_Judicial_Procedure__c> newInsolvs){
        Map<Id,Insolvency_Judicial_Procedure__c> accToInsolv = new Map<Id,Insolvency_Judicial_Procedure__c>();
        
        //populate map
        for(Insolvency_Judicial_Procedure__c insolv : newInsolvs){
            accToInsolv.put(insolv.Account_Client__c, insolv);
        }
        
        //get collection cases from client accounts (if they exist)
        List<Collection_Case__c> ccs = [SELECT Id, Account__c FROM Collection_Case__c WHERE (Status__c = 'Open' OR Status__c = 'Legal') AND Account__c IN :accToInsolv.keySet()];
        
        //populate insolvency actions' collection case
        for(Collection_Case__c cc : ccs){
            Insolvency_Judicial_Procedure__c insolv = accToInsolv.get(cc.Account__c);
            insolv.Collection_Case__c = cc.Id;
        }
    }
    
    //before inserting an isolvency action, populate its credit amount from CC (if exists) OR from BC (always does)
    public static void handleSetCreditAmount(List<Insolvency_Judicial_Procedure__c> newInsolvs){
    	Map<Id,Insolvency_Judicial_Procedure__c> ccToInsolv = new Map<Id, Insolvency_Judicial_Procedure__c>();
    	Map<Id,Insolvency_Judicial_Procedure__c> accToInsolv = new Map<Id, Insolvency_Judicial_Procedure__c>();
        Injunction_Settings__mdt metaData = [SELECT Residual_Value_Prct__c FROM Injunction_Settings__mdt];
        
        for(Insolvency_Judicial_Procedure__c i : newInsolvs){
        	if(i.Collection_Case__c != null){
        		ccToInsolv.put(i.Collection_Case__c, i);
        	}
        	else{
        		accToInsolv.put(i.Account_Client__c, i);
        	}
            i.Residual_Value_Prct__c = metaData.Residual_Value_Prct__c;
        }
        
        //---------set from CC
        handleInsolvencyCreditAmountWithCollectionCase(ccToInsolv);
        
        //---------set from BC
        handleInsolvencyCreditAmountWithoutCollectionCase(accToInsolv);
    }
    
    //after inserting insolvency action, set related list of the client's renting apps
    public static void handleSetRentingAppRelatedList(List<Insolvency_Judicial_Procedure__c> newValues){
    	Map<Id,Insolvency_Judicial_Procedure__c> accToInsolv = new Map<Id,Insolvency_Judicial_Procedure__c>();
    	for(Insolvency_Judicial_Procedure__c insolv : newValues){
    		accToInsolv.put(insolv.Account_Client__c, insolv);
    	}
    	
    	List<Application__c> apps = [SELECT AccClient__c, Insolvency_Judicial_Procedure__c FROM Application__c WHERE Status__c LIKE 'Contract - %' AND AccClient__c IN :accToInsolv.keySet()];
    	for(Application__c app : apps){
    		Insolvency_Judicial_Procedure__c aux = accToInsolv.get(app.AccClient__c);
    		app.Insolvency_Judicial_Procedure__c = aux.Id;
    	}
    	
    	update apps;
    }
    
    private static void handleInsolvencyCreditAmountWithCollectionCase(Map<Id,Insolvency_Judicial_Procedure__c> ccToInsolv){
    	//get interest charges from dunning - since we dont know the dunning level the collection case may be when the insolvency is created, we check it (dunning level) in ASC order. 
        //This is better than querying the dunning alerts for each CC to find the one with highest level. E.g. if we have 30 insolvencies, we "only" perform 4 queries instead of 30
        //This is worse if we have less than 4 insolvencies, but that's just life :)
        List<Dunning_Alert__c> dunnings = new List<Dunning_Alert__c>();
        //1st reminder
        dunnings = [SELECT Id, Total_Interest_Charges__c, Collection_Case__c FROM Dunning_Alert__c WHERE Dunning_Level__c = '1st Reminder' AND Status__c = 'Open' AND Collection_Case__c IN :ccToInsolv.keySet()];
        for(Dunning_Alert__c dun : dunnings){
            Insolvency_Judicial_Procedure__c insolv = ccToInsolv.get(dun.Collection_Case__c);
            insolv.Interest_Charges__c = dun.Total_Interest_Charges__c;
        }
        
        //2nd reminder
        dunnings = [SELECT Id, Total_Interest_Charges__c, Collection_Case__c FROM Dunning_Alert__c WHERE Dunning_Level__c = '2nd Reminder' AND Status__c = 'Open' AND Collection_Case__c IN :ccToInsolv.keySet()];
        for(Dunning_Alert__c dun : dunnings){
            Insolvency_Judicial_Procedure__c insolv = ccToInsolv.get(dun.Collection_Case__c);
            insolv.Interest_Charges__c = dun.Total_Interest_Charges__c;
        }
        
        //3rd reminder
        dunnings = [SELECT Id, Total_Interest_Charges__c, Collection_Case__c FROM Dunning_Alert__c WHERE Dunning_Level__c = '3rd Reminder' AND Status__c = 'Open' AND Collection_Case__c IN :ccToInsolv.keySet()];
        for(Dunning_Alert__c dun : dunnings){
            Insolvency_Judicial_Procedure__c insolv = ccToInsolv.get(dun.Collection_Case__c);
            insolv.Interest_Charges__c = dun.Total_Interest_Charges__c;
        }
        
        //4th reminder
        dunnings = [SELECT Id, Total_Interest_Charges__c, Collection_Case__c FROM Dunning_Alert__c WHERE Dunning_Level__c = '4th Reminder' AND Status__c = 'Open' AND Collection_Case__c IN :ccToInsolv.keySet()];
        for(Dunning_Alert__c dun : dunnings){
            Insolvency_Judicial_Procedure__c insolv = ccToInsolv.get(dun.Collection_Case__c);
            insolv.Interest_Charges__c = dun.Total_Interest_Charges__c;
        }
        
        //get client accounts from cc
        List<Collection_Case__c> ccs = [SELECT Id, Account__c, Amount_Claimed__c FROM Collection_Case__c WHERE (Status__c = 'Open' OR Status__c = 'Legal') AND Id IN :ccToInsolv.keySet()];
        
        Map<Id, Insolvency_Judicial_Procedure__c> accToInsolv = new Map<Id,Insolvency_Judicial_Procedure__c>();
        //populate insolvencies' claimed amount, payment amount to the end of contract and residual amount
        for(Collection_Case__c cc : ccs){
            Insolvency_Judicial_Procedure__c insolv = ccToInsolv.get(cc.Id);
            accToInsolv.put(cc.Account__c, insolv);
            
            //Collection Case amount claimed with IVA
            insolv.Claimed_Amount__c = cc.Amount_Claimed__c;
            
            //payment amount till end of contract
            Decimal payAmountEnd = 0;
            Decimal residualValue = 0;
            //TODO perform this query outside of for loop
            for(Billing_Contract__c bc : getBillingContractsByCollectionCaseId(cc.Id)){
                payAmountEnd += bc.Payment_Amount_to_The_End_Of_Contract__c;
                residualValue += bc.Residual_Value_Amount__c;
            }
            //no IVA
            insolv.Payment_Amount_to_The_End_Of_Contract__c = payAmountEnd;
            insolv.Residual_Value_Amount__c = residualValue;
        }
        
        List<Account> accounts = [SELECT Id, Tax_Zone__c FROM Account WHERE Id IN :accToInsolv.keySet()];
        updateAmountsWithIVA(accounts,accToInsolv);
    }
    
    private static void handleInsolvencyCreditAmountWithoutCollectionCase(Map<Id,Insolvency_Judicial_Procedure__c> accToInsolv){
    	//populate insolvencies' payment amount to the end of contract + residual value amount
        for(Id accId : accToInsolv.keySet()){
            Insolvency_Judicial_Procedure__c insolv = accToInsolv.get(accId);
            
            //payment amount till end of contract
            Decimal payAmountEnd = 0;
            Decimal residualValue = 0;
            //TODO perform this query outside of for loop
            for(Billing_Contract__c bc : getBillingContractsByAccountId(accId)){
                payAmountEnd += bc.Payment_Amount_to_The_End_Of_Contract__c;
                residualValue += bc.Residual_Value_Amount__c;
            }
            //no IVA
            insolv.Payment_Amount_to_The_End_Of_Contract__c = payAmountEnd;
            insolv.Residual_Value_Amount__c = residualValue;
        }
        
        List<Account> accounts = [SELECT Id, Tax_Zone__c FROM Account WHERE Id IN :accToInsolv.keySet()];
        updateAmountsWithIVA(accounts,accToInsolv);
    }
    
    //this should be in something like LegalUtils
    private static void updateAmountsWithIVA(List<Account> accounts, Map<Id,Insolvency_Judicial_Procedure__c> accToInsolv){
    	String productCode = 'PT01';
    	//set tax code
        Map<Id,Account> taxCodeToAcc = new Map<Id,Account>();
        for(Account a : accounts){
            BILL_ProductRegion aux = new BILL_ProductRegion();
            Id taxCodeId = aux.getTaxCode(productCode, a.Tax_Zone__c);
            Insolvency_Judicial_Procedure__c insolv = accToInsolv.get(a.Id);
            insolv.Tax_Code__c = taxCodeId;
            taxCodeToAcc.put(taxCodeId, a);
        }
        
        //set tax rate
        List<c2g__codaTaxRate__c> taxRates = [SELECT Id, c2g__Rate__c, c2g__TaxCode__c FROM c2g__codaTaxRate__c WHERE c2g__TaxCode__c IN :taxCodeToAcc.keySet()];
        for(c2g__codaTaxRate__c taxRate : taxRates){
            Account a = taxCodeToAcc.get(taxRate.c2g__TaxCode__c);
            Insolvency_Judicial_Procedure__c insolv = accToInsolv.get(a.Id);
            insolv.Tax_Rate_Lookup__c = taxRate.Id;
            //update residual amount and advanced payments to consider IVA
            Decimal noIvaResi = insolv.Residual_Value_Amount__c;
            insolv.Residual_Value_Amount__c = noIvaResi * (1+taxRate.c2g__Rate__c * 0.01);
            Decimal noIvaAdv = insolv.Payment_Amount_to_The_End_Of_Contract__c;
            insolv.Payment_Amount_to_The_End_Of_Contract__c = noIvaAdv * (1+taxRate.c2g__Rate__c * 0.01);
        }
    }
    
    //this should be in something like LegalUtils
    private static List<Billing_Contract__c> getBillingContractsByCollectionCaseId(Id collectionCaseId){
        //Get billing contracts for the collection case
        List<Collection_Case__c> collectionCaseList = [SELECT Name,
												(SELECT Name, Application__c, Collection_Case__c, Billing_Date__c, Equipment_Cost__c, Payment_Amount__c, Residual_Value_Amount__c, BC_Contract_Inactive__c, Contract_Status__c, Contract_Sub_Status__c, Payment_Amount_to_The_End_Of_Contract__c
												FROM Billing_Contracts__r) 
											FROM Collection_Case__c 
											WHERE Id = :collectionCaseId];
        
        //[START] checking for billing contracts
        if(collectionCaseList.size() == 0){
        	system.debug('ERRO::Lista de Collection Cases vazia');
            return new List<Billing_Contract__c>();
        }
        
        Collection_Case__c collectionCase = collectionCaseList[0];
        if(collectionCase.Billing_Contracts__r == null){
        	system.debug('ERRO::Relacao CollectionCase-BillingContracts mal definida');
        	return new List<Billing_Contract__c>();
        }
        
        if(collectionCase.Billing_Contracts__r.size() <= 0){
            system.debug('ERRO::No BillingContracts found');
        	return new List<Billing_Contract__c>();
        }
        
        List<Billing_Contract__c> billingContracts = collectionCase.Billing_Contracts__r;
        //[END] checking for billing contracts
        return billingContracts;
    }
    
    //this should be in something like LegalUtils
    private static List<Billing_Contract__c> getBillingContractsByAccountId(Id accId){
    	List<Billing_Contract__c> toReturn = [SELECT Payment_Amount_to_The_End_Of_Contract__c, Residual_Value_Amount__c
    	FROM Billing_Contract__c
    	WHERE Account__c = :accId];
    	
    	return toReturn;
    }
}