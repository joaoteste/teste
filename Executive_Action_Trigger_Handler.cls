public class Executive_Action_Trigger_Handler {

    //before inserting an executive action, populate executive actions' client account from billing contract
    public static void handleSetClientAccountAndTaxpayerNumber(List<Executive_Action_Procedure__c> newExecs){
        Map<Id,Executive_Action_Procedure__c> injToExecAction = new Map<Id,Executive_Action_Procedure__c>();
        Map<Id,Executive_Action_Procedure__c> ccToExecAction = new Map<Id,Executive_Action_Procedure__c>();
        Map<Id,Executive_Action_Procedure__c> declToExecAction = new Map<Id,Executive_Action_Procedure__c>();
        
        //populate map
        for(Executive_Action_Procedure__c exec : newExecs){
            if(exec.Injunction__c != null){
                injToExecAction.put(exec.Injunction__c, exec);
            }else if(exec.Collection_Case__c != null){
                ccToExecAction.put(exec.Collection_Case__c, exec);
            }else if(exec.Declaratory_Action__c != null){
                declToExecAction.put(exec.Declaratory_Action__c, exec);
            }
        }
        
        Map<Id,Executive_Action_Procedure__c> accountToExec = new Map<Id,Executive_Action_Procedure__c>();
        
        //get client account from injunction
        List<Injunction_Procedure__c> injs = [SELECT Id, Account_Client__c FROM Injunction_Procedure__c WHERE Id IN :injToExecAction.keySet()];
        
        for(Injunction_Procedure__c inj : injs){
            Executive_Action_Procedure__c exec = injToExecAction.get(inj.Id);
            exec.Account_Client__c = inj.Account_Client__c;
            accountToExec.put(inj.Account_Client__c, exec);
        }
        
        //get client account from collection case
        List<Collection_Case__c> ccs = [SELECT Id, Account__c FROM Collection_Case__c WHERE Id IN :ccToExecAction.keySet()];
        
        for(Collection_Case__c cc : ccs){
            Executive_Action_Procedure__c exec = ccToExecAction.get(cc.Id);
            exec.Account_Client__c = cc.Account__c;
            accountToExec.put(cc.Account__c, exec);
        }
        
        //get client account from declarative action
        List<Declarative_Action__c> decls = [SELECT Id, Account_Client__c FROM Declarative_Action__c WHERE Id IN :declToExecAction.keySet()];
        
        for(Declarative_Action__c decl : decls){
            Executive_Action_Procedure__c exec = declToExecAction.get(decl.Id);
            exec.Account_Client__c = decl.Account_Client__c;
            accountToExec.put(decl.Account_Client__c, exec);
        }
        
        //populate executive actions' taxpayer numbers
        List<Account> accounts = [SELECT Id, NIF__c FROM Account WHERE Id IN :accountToExec.keySet()];
        for(Account a : accounts){
            accountToExec.get(a.Id).Taxpayer_Number__c = a.NIF__c;
        }
    }
    
}