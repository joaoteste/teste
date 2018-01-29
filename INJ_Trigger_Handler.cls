public class INJ_Trigger_Handler {
    
    /*
    public static void handleInjunctionDecision(Map<Id,Injunction_Procedure__c> oldMap, Map<Id,Injunction_Procedure__c> newMap){
        //RULE::if Injunction changed decision state, create corresponding registers and update decision date
        
        List<Injunction_Procedure__c> toUpdateDecisionDates = new List<Injunction_Procedure__c>();
        List<Injunction_Procedure__c> toResetDecisionDates = new List<Injunction_Procedure__c>();
        
        
        List<Declarative_Action__c> toCreateDeclarativeActions = new List<Declarative_Action__c>();
        List<Id> billingContractsIds = new List<Id>();
        
        for(Injunction_Procedure__c injAfter : newMap.values()){
            Injunction_Procedure__c injBefore = oldMap.get(injAfter.Id);
            //changed decision
            if(!injafter.Injunction_Decision__c.equals(injBefore.Injunction_Decision__c)){
                if(injafter.Injunction_Decision__c.equals('Appended Enforcement Order')){
                    //Criar registo Executive Procedure
                }
                else if(injafter.Injunction_Decision__c.equals('Injunction Opposition')){
                    //Criar Registo Declarative Procedure
                    Declarative_Action__c declAction = new Declarative_Action__c();
                    declAction.Billing_Contract__c = injafter.Billing_Contract__c;
                    declAction.Injunction_Procedure__c = injafter.Id;
                    billingContractsIds.add(injafter.Billing_Contract__c);
                    toCreateDeclarativeActions.add(declAction);
                }
                else if(injafter.Injunction_Decision__c.equals('Frustration By Notice')){
                    //Criar Registo Client Visit
                }
                //add injunction to later update its decision date
                toUpdateDecisionDates.add(injAfter);
            }
            //from something to NONE
            if(!injBefore.Injunction_Decision__c.equals('None') && injAfter.Injunction_Decision__c.equals('None')){
                toResetDecisionDates.add(injAfter);
            }
        }
        //COMMIT CHANGES
        //create declarative actions (fetch client account from billing contract)
        
        Map<Id,Billing_Contract__c> idBillingContract = new Map<Id,Billing_Contract__c>([SELECT Id,Account__c
                                                                                        FROM Billing_Contract__c
                                                                                        WHERE Id IN :billingContractsIds]);
        
        for(Declarative_Action__c action : toCreateDeclarativeActions){
            action.Account_Client__c = idBillingContract.get(action.Billing_Contract__c).Account__c;
        }
        insert toCreateDeclarativeActions;
        
        //set Injunction Decision Date
        for(Injunction_Procedure__c inj : toUpdateDecisionDates){
            Date decisionDate = Date.today();
            inj.Injuction_Decison_Date__c = decisionDate;
        }
        //reset Injunction Decision Date
        for(Injunction_Procedure__c inj : toResetDecisionDates){
            inj.Injuction_Decison_Date__c = null;
        }
    }*/
    
    public static void handleDates(Map<Id,Injunction_Procedure__c> oldMap, Map<Id,Injunction_Procedure__c> newMap){
        List<Injunction_Procedure__c> toUpdatePaymentDates = new List<Injunction_Procedure__c>();
        List<Injunction_Procedure__c> toResetPaymentDates = new List<Injunction_Procedure__c>();
        List<Injunction_Procedure__c> toUpdateSubmDates = new List<Injunction_Procedure__c>();
        List<Injunction_Procedure__c> toResetSubmDates = new List<Injunction_Procedure__c>();
        List<Injunction_Procedure__c> toUpdateDecisionDates = new List<Injunction_Procedure__c>();
        List<Injunction_Procedure__c> toResetDecisionDates = new List<Injunction_Procedure__c>();
        
        for(Injunction_Procedure__c injAfter : newMap.values()){
            //judicial fee payment date
            if(injAfter.Judicial_Fee_Status__c != null){
                Injunction_Procedure__c injBefore = oldMap.get(injAfter.Id);
                //from NONE/UNPAID to PAID
                if((injBefore.Judicial_Fee_Status__c.equals('None') && injAfter.Judicial_Fee_Status__c.equals('Paid')) ||
                  (injBefore.Judicial_Fee_Status__c.equals('Unpaid') && injAfter.Judicial_Fee_Status__c.equals('Paid'))){
                    toUpdatePaymentDates.add(injAfter);
                 }
                //from PAID to NONE/UNPAID
                if((injBefore.Judicial_Fee_Status__c.equals('Paid') && injAfter.Judicial_Fee_Status__c.equals('Unpaid')) ||
                  (injBefore.Judicial_Fee_Status__c.equals('Paid') && injAfter.Judicial_Fee_Status__c.equals('None'))){
                    toResetPaymentDates.add(injAfter);
                }
            }
            //injunction submission date
            if(injAfter.Injuction_Procedure_Status__c != null){
                Injunction_Procedure__c injBefore = oldMap.get(injAfter.Id);
                //from CREATED to SUBMITTED
                if(injBefore.Injuction_Procedure_Status__c.equals('Created') && injAfter.Injuction_Procedure_Status__c.equals('Submitted')){
                    toUpdateSubmDates.add(injAfter);
                 }
                //from SUBMITTED to CREATED
                if(injBefore.Injuction_Procedure_Status__c.equals('Submitted') && injAfter.Injuction_Procedure_Status__c.equals('Created')){
                    toResetSubmDates.add(injAfter);
                }
            }
            //injunction decision date
            if(injAfter.Injunction_Decision__c != null){
                Injunction_Procedure__c injBefore = oldMap.get(injAfter.Id);
                //from NONE to SOMETHING ELSE
                if(injBefore.Injunction_Decision__c.equals('None') && !injAfter.Injunction_Decision__c.equals('None')){
                    toUpdateDecisionDates.add(injAfter);
                 }
                //from SOMETHING ELSE to NONE
                if(!injBefore.Injunction_Decision__c.equals('None') && injAfter.Injunction_Decision__c.equals('None')){
                    toResetDecisionDates.add(injAfter);
                }
            }
        }
        //COMMIT CHANGES
        //set Judicial Fee Payment Date
        for(Injunction_Procedure__c inj : toUpdatePaymentDates){
            Date decisionDate = Date.today();
            inj.Judicial_Fee_Payment_Date__c = decisionDate;
        }
        //reset judicial fee payment dates
        for(Injunction_Procedure__c i : toResetPaymentDates){
            i.Judicial_Fee_Payment_Date__c = null;
        }
        //set inj submission dates
        for(Injunction_Procedure__c inj : toUpdateSubmDates){
            Date decisionDate = Date.today();
            inj.Injunction_Submission_Date__c = decisionDate;
        }
        //reset inj submission dates
        for(Injunction_Procedure__c i : toResetSubmDates){
            i.Injunction_Submission_Date__c = null;
        }
        //set inj decision dates
        for(Injunction_Procedure__c inj : toUpdateDecisionDates){
            Date decisionDate = Date.today();
            inj.Injuction_Decison_Date__c = decisionDate;
        }
        //reset inj decision dates
        for(Injunction_Procedure__c i : toResetDecisionDates){
            i.Injuction_Decison_Date__c = null;
        }
    }
    
    
    //before inserting an injunction, populate injunctions' date (if it doesnt exist)
    public static void handleSetInjunctionDate(List<Injunction_Procedure__c> newInjs){
        for(Injunction_Procedure__c inj : newInjs){
            if(inj.Injunction_Date__c == null){
                inj.Injunction_Date__c = Date.today();
            }
        }
    }
    
    //before inserting an injunction, populate injunctions' client account from billing contract and set amounts
    public static void handleSetClientAccountAndClaimedAmount(List<Injunction_Procedure__c> newInjs){
        Map<Id,Injunction_Procedure__c> ccToInj = new Map<Id, Injunction_Procedure__c>();
        Injunction_Settings__mdt metaData = [SELECT Residual_Value_Prct__c, Additional_Costs__c FROM Injunction_Settings__mdt];
        for(Injunction_Procedure__c i : newInjs){
            ccToInj.put(i.Collection_Case__c, i);
            i.Residual_Value_Prct__c = metaData.Residual_Value_Prct__c;
            i.Collection_Fee_Amount__c = metaData.Additional_Costs__c;
        }
        
        //get interest charges from dunning
        List<Dunning_Alert__c> dunnings = [SELECT Id, Total_Interest_Charges__c, Collection_Case__c FROM Dunning_Alert__c WHERE Dunning_Level__c = '4th Reminder' AND Status__c = 'Open' AND Collection_Case__c IN :ccToInj.keySet()];
        for(Dunning_Alert__c dun : dunnings){
            Injunction_Procedure__c inj = ccToInj.get(dun.Collection_Case__c);
            inj.Interest_Charges__c = dun.Total_Interest_Charges__c;
        }
        
        //get client accounts from cc
        List<Collection_Case__c> ccs = [SELECT Id, Account__c, Amount_Claimed__c FROM Collection_Case__c WHERE Id IN :ccToInj.keySet()];
        List<Id> ccIds = new List<Id>();
        for(Collection_Case__c cc : ccs){
        	ccIds.add(cc.Id);
        }
        
        Map<Id, List<Billing_Contract__c>> ccToContracts = getBillingContractsByCollectionCaseIds(ccIds);
        
        
        Map<Id, Injunction_Procedure__c> accToInj = new Map<Id,Injunction_Procedure__c>();
        //populate injunctions' client account, claimed amount and payment amount to the end of contract
        for(Collection_Case__c cc : ccs){
            //client account
            Injunction_Procedure__c inj = ccToInj.get(cc.Id);
            inj.Account_Client__c = cc.Account__c;
            accToInj.put(cc.Account__c, inj);
            
            //Collection Case amount claimed with IVA
            inj.Claimed_Amount__c = cc.Amount_Claimed__c;
            
            //payment amount till end of contract
            Decimal payAmountEnd = 0;
            Decimal residualValue = 0;
            List<Billing_Contract__c> contracts = (ccToContracts.containsKey(cc.Id)) ? ccToContracts.get(cc.Id) : new List<Billing_Contract__c>();
            for(Billing_Contract__c bc : contracts){
                payAmountEnd += bc.Payment_Amount_to_The_End_Of_Contract__c;
                residualValue += bc.Residual_Value_Amount__c;
            }
            //no IVA
            inj.Payment_Amount_to_The_End_Of_Contract__c = payAmountEnd;
            inj.Residual_Value_Amount__c = residualValue;
        }
        
        List<Account> accounts = [SELECT Id, Tax_Zone__c, Name FROM Account WHERE Id IN :accToInj.keySet()];
        String productCode = 'PT01';
        
        //set tax code
        Map<Id,Account> taxCodeToAcc = new Map<Id,Account>();
        for(Account a : accounts){
            BILL_ProductRegion aux = new BILL_ProductRegion();
            Id taxCodeId = aux.getTaxCode(productCode, a.Tax_Zone__c);
            Injunction_Procedure__c inj = accToInj.get(a.Id);
            inj.Tax_Code__c = taxCodeId;
            taxCodeToAcc.put(taxCodeId, a);
        }
        
        //set tax rate
        List<c2g__codaTaxRate__c> taxRates = [SELECT Id, c2g__Rate__c, c2g__TaxCode__c FROM c2g__codaTaxRate__c WHERE c2g__TaxCode__c IN :taxCodeToAcc.keySet()];
        for(c2g__codaTaxRate__c taxRate : taxRates){
            Account a = taxCodeToAcc.get(taxRate.c2g__TaxCode__c);
            Injunction_Procedure__c inj = accToInj.get(a.Id);
            inj.Tax_Rate__c = taxRate.Id;
            //update residual amount and advanced payments to consider IVA
            Decimal noIvaResi = inj.Residual_Value_Amount__c;
            inj.Residual_Value_Amount__c = noIvaResi * (1+taxRate.c2g__Rate__c * 0.01);
            Decimal noIvaAdv = inj.Payment_Amount_to_The_End_Of_Contract__c;
            inj.Payment_Amount_to_The_End_Of_Contract__c = noIvaAdv * (1+taxRate.c2g__Rate__c * 0.01);
        }
    }    
    
    public static void handleUpdateLegalData(List<Injunction_Procedure__c> newInjs){        
        Map<Id,Injunction_Procedure__c> ccToInj = new Map<Id, Injunction_Procedure__c>();
        
        for(Injunction_Procedure__c i : newInjs){
            ccToInj.put(i.Collection_Case__c, i);
        }
        
        Map<Id, List<Billing_Contract__c>> ccToContracts = getBillingContractsByCollectionCaseIds(new List<Id>(ccToInj.keySet()));
        
        for(Id ccId : ccToInj.keySet()){
            List<Billing_Contract__c> billingContracts = (ccToContracts.containsKey(ccId)) ? ccToContracts.get(ccId) : new List<Billing_Contract__c>();
        
             //check if every contract of the collection case is in the "Contract-Arrears" status
             //deactivate contract and update contract subStatus to "Injunction"
             for(Billing_Contract__c contract : billingContracts){
                 if(!contract.Contract_Status__c.equals('Contract - Arrears')){
                     system.debug('ERRO:: BillingContract '+ contract.Name +' wasnt in status CONTRACT - ARREARS before creating Injunction');
                     Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL', ApplicationID__c = 'Legal Procedure',
                                                message__c = 'BillingContract '+ contract.Name +' wasnt in status CONTRACT - ARREARS before creating Injunction');
                     insert record;
                 }
                 contract.BC_Contract_Inactive__c = true;
                 contract.Contract_Inactive_Date__c	= Date.today();
                 contract.Contract_Sub_Status__c = 'Injunction';
                 contract.Injunction__c = ccToInj.get(contract.Collection_Case__c).Id;
             }
             
             update billingContracts;
            
            //update rentingApp (and Billing Contracts') status to 'Contract - Lawsuit'
            Map<Id,Billing_Contract__c> apToBc = new Map<Id,Billing_Contract__c>();
            
            for(Billing_Contract__c bc : billingContracts){
                apToBc.put(bc.Application__c, bc);
            }
            
            List<Application__c> apps = [SELECT Name, Status__c FROM Application__c WHERE Id IN :apToBc.keySet()];
            for(Application__c app : apps){
                app.Status__c = 'Contract - Lawsuit';
                Injunction_Procedure__c inj = ccToInj.get(ccId);
                app.Injunction__c = inj.Id;
            }
            update apps;
        }
        
        //update Collection Cases status to Legal and set Injunction Claimed Amount from Collection Case
        List<Collection_Case__c> ccs = [SELECT Id, Status__c, Amount_Claimed__c FROM Collection_Case__c WHERE Id IN :ccToInj.keySet()];
        
        for(Collection_Case__c cc : ccs){
            cc.Status__c = 'Legal';
        }
        
        update ccs;
    }
    
    public static void handleSetContactsRelatedList(List<Injunction_Procedure__c> newInjs){
        Map<Id,Injunction_Procedure__c> ccToInj = new Map<Id, Injunction_Procedure__c>();
        
        for(Injunction_Procedure__c i : newInjs){
            ccToInj.put(i.Collection_Case__c, i);
        }
        
        Map<Id,Collection_Case__c> accToCC = new Map<Id,Collection_Case__c>();
        List<Collection_Case__c> ccs = [SELECT Account__c FROM Collection_Case__c WHERE Id IN :ccToInj.keySet()];
        for(Collection_Case__c cc : ccs){
            accToCC.put(cc.Account__c, cc);
        }
        
        List<Contact> contacts = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :accToCC.keySet()];
        for(Contact c : contacts){
            Collection_Case__c cc = accToCC.get(c.AccountId);
            Injunction_Procedure__c inj = ccToInj.get(cc.Id);
            c.Injunction__c = inj.Id;
        }
        update contacts;
    }
    
    public static void handleSetEquipmentsRelatedList(List<Injunction_Procedure__c> newInjs){
        Map<Id,Injunction_Procedure__c> ccToInj = new Map<Id, Injunction_Procedure__c>();
        for(Injunction_Procedure__c i : newInjs){
            ccToInj.put(i.Collection_Case__c, i);
        }
        
        Map<Id,Id> appToCC = new Map<Id,Id>();
        List<Billing_Contract__c> bcs = [SELECT Id, Application__c, Collection_Case__c FROM Billing_Contract__c WHERE Collection_Case__c IN :ccToInj.keySet() AND Application__c != null];
        for(Billing_Contract__c bc : bcs){
            appToCC.put(bc.Application__c, bc.Collection_Case__c);
        }
        
        List<Equipment__c> equips = [SELECT Id, Application__c FROM Equipment__c WHERE Application__c IN :appToCC.keySet()];
        for(Equipment__c equip : equips){
            Id ccId = appToCC.get(equip.Application__c);
            Injunction_Procedure__c inj = ccToInj.get(ccId);
            equip.Injunction__c = inj.Id;
        }
        update equips;
    }
    
    public static void handleSetAttachmentRelatedList(List<Injunction_Procedure__c> newInjs){
        Map<Id,Injunction_Procedure__c> ccToInj = new Map<Id, Injunction_Procedure__c>();
        for(Injunction_Procedure__c i : newInjs){
            ccToInj.put(i.Collection_Case__c, i);
        }
        
        Map<Id,Id> appToCC = new Map<Id,Id>();
        List<Billing_Contract__c> bcs = [SELECT Id, Application__c, Collection_Case__c FROM Billing_Contract__c WHERE Collection_Case__c IN :ccToInj.keySet() AND Application__c != null];
        for(Billing_Contract__c bc : bcs){
            appToCC.put(bc.Application__c, bc.Collection_Case__c);
        }
        
        //get auto de aceitação from renting app (there are 2, we want the latest because it is the one which is signed)
        List<Attachment> attachments = [SELECT Id, ParentID, Name, ContentType, Description, Body
                                        FROM Attachment 
                                        WHERE Parent.Type = 'Application__c' AND Name LIKE 'Auto de aceita%' AND ParentID IN :appToCC.keySet() 
                                        ORDER BY CreatedDate DESC LIMIT 1];
        
        //populate autos de aceitacao nas injuncoes
        List<Attachment> toInsertAtts = new List<Attachment>();
        for(Attachment att : attachments){
            Id ccId = appToCC.get(att.ParentID);
            Injunction_Procedure__c inj = ccToInj.get(ccId);
            Attachment a = new Attachment();
            a.Name = att.Name;
            a.Body = att.Body;
            a.ContentType = att.ContentType;
            a.Description = att.Description;
            a.ParentId = inj.Id;
            toInsertAtts.add(a);
        }
        insert toInsertAtts;
    }
    
    public static List<Billing_Contract__c> getBillingContractsByCollectionCaseId(Id collectionCaseId){
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
    
    public static Map<Id, List<Billing_Contract__c>> getBillingContractsByCollectionCaseIds(List<Id> collectionCaseIds){
        //Get billing contracts for the collection case
        List<Collection_Case__c> collectionCaseList = [SELECT Name,
												(SELECT Name, Application__c, Collection_Case__c, Billing_Date__c, Equipment_Cost__c, Payment_Amount__c, Residual_Value_Amount__c, BC_Contract_Inactive__c, Contract_Status__c, Contract_Sub_Status__c, Payment_Amount_to_The_End_Of_Contract__c
												FROM Billing_Contracts__r) 
											FROM Collection_Case__c 
											WHERE Id IN :collectionCaseIds];
        
        //[START] checking for billing contracts
        if(collectionCaseList.size() == 0){
        	system.debug('ERRO::Lista de Collection Cases vazia');
            return new Map<Id, List<Billing_Contract__c>>();
        }
        
        Collection_Case__c collectionCase = collectionCaseList[0];
        if(collectionCase.Billing_Contracts__r == null){
        	system.debug('ERRO::Relacao CollectionCase-BillingContracts mal definida');
        	return new Map<Id, List<Billing_Contract__c>>();
        }
        
        if(collectionCase.Billing_Contracts__r.size() <= 0){
            system.debug('ERRO::No BillingContracts found');
        	return new Map<Id, List<Billing_Contract__c>>();
        }
        
        List<Billing_Contract__c> billingContracts = collectionCase.Billing_Contracts__r;
        //[END] checking for billing contracts
        
        Map<Id, List<Billing_Contract__c>> ccToBcs = new Map<Id, List<Billing_Contract__c>>();
        for(Billing_Contract__c bc : billingContracts){
        	if(ccToBcs.containsKey(bc.Collection_Case__c)){
        		List<Billing_Contract__c> aux = ccToBcs.get(bc.Collection_Case__c);
        		aux.add(bc);
        		ccToBcs.put(bc.Collection_Case__c, aux);
        	}
        	else{
        		List<Billing_Contract__c> aux = new List<Billing_Contract__c>();
        		aux.add(bc);
        		ccToBcs.put(bc.Collection_Case__c, aux);
        	}
        }
        
        return ccToBcs;
    }
}