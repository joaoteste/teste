public class Declarative_Action_Trigger_Handler {

    //before inserting a declarative action, populate declarative actions' client account from billing contract
    public static void handleSetClientAccount(List<Declarative_Action__c> newDecs){
        Map<Id,Declarative_Action__c> injToDeclAction = new Map<Id,Declarative_Action__c>();
        
        //populate map
        for(Declarative_Action__c da : newDecs){
            injToDeclAction.put(da.Injunction_Procedure__c, da);
        }
        
        //get client account from billing contracts
        List<Injunction_Procedure__c> injs = [SELECT Id, Account_Client__c FROM Injunction_Procedure__c WHERE Id IN :injToDeclAction.keySet()];
        
        //populate declarative actions' client account
        for(Injunction_Procedure__c inj : injs){
            injToDeclAction.get(inj.Id).Account_Client__c = inj.Account_Client__c;
        }
    }
    
    //before inserting a declaratory action, populate declaratory actions' claimed amount from injunction
    /*
    public static void handleSetClaimedAmount(List<Declarative_Action__c> newDecs){
        Map<Id,Declarative_Action__c> injToDeclAction = new Map<Id,Declarative_Action__c>();
        
        //populate map
        for(Declarative_Action__c da : newDecs){
            injToDeclAction.put(da.Injunction_Procedure__c, da);
        }
        
        //get injunction claimed amount + injunction fee from injunctions
        List<Injunction_Procedure__c> injs = [SELECT Id, Injuction_Claimed_Amount__c, Judicial_Fee_Amount__c FROM Injunction_Procedure__c WHERE Id IN :injToDeclAction.keySet()];
        
        //populate declarive actions' claimed amount (= Injuction_Claimed_Amount__c - Judicial_Fee_Amount__c)
        for(Injunction_Procedure__c inj : injs){
            injToDeclAction.get(inj.Id).Declarative_Claimed_Amount__c = inj.Injuction_Claimed_Amount__c - inj.Judicial_Fee_Amount__c;
        }
    }*/
    
}