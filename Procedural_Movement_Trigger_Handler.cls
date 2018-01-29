public class Procedural_Movement_Trigger_Handler {
    
    //after procedural movement is created, update last procedural date and status on the corresponding legal object
    public static void handleUpdateLastProceduralDateStatus(List<Procedural_Movement__c> newProcs){
        Map<Id,Procedural_Movement__c> insolvActionToProcMap = new Map<Id,Procedural_Movement__c>();
        Map<Id,Procedural_Movement__c> crimActionToProcMap = new Map<Id,Procedural_Movement__c>();
        Map<Id,Procedural_Movement__c> execActionToProcMap = new Map<Id,Procedural_Movement__c>();
        Map<Id,Procedural_Movement__c> declActionToProcMap = new Map<Id,Procedural_Movement__c>();
        Map<Id,Procedural_Movement__c> injToProcMap = new Map<Id,Procedural_Movement__c>();
        
        //populate maps
        for(Procedural_Movement__c proc : newProcs){
            if(proc.Declarative_Action__c != null){
                declActionToProcMap.put(proc.Declarative_Action__c,proc);
            }
            else if(proc.Injunction_Procedure__c != null){
                injToProcMap.put(proc.Injunction_Procedure__c,proc);
            }
            else if(proc.Executive_Action_Procedure__c != null){
                execActionToProcMap.put(proc.Executive_Action_Procedure__c, proc);
            }
            else if(proc.Criminal_Judicial_Procedure__c != null){
                crimActionToProcMap.put(proc.Criminal_Judicial_Procedure__c, proc);
            }
            else if(proc.Insolvency_Judicial_Procedure__c != null){
                insolvActionToProcMap.put(proc.Insolvency_Judicial_Procedure__c, proc);
            }
        }
        
        //update criminal actions' last procedural date
        List<Insolvency_Judicial_Procedure__c> insolvs = [SELECT Id FROM Insolvency_Judicial_Procedure__c WHERE Id IN :insolvActionToProcMap.keySet()];
        for(Insolvency_Judicial_Procedure__c insolv : insolvs){
            Procedural_Movement__c proc = insolvActionToProcMap.get(insolv.Id);
            insolv.Last_Procedural_Movement_Date__c = proc.Movement_Date__c;
        }
        update insolvs;
        
        //update criminal actions' last procedural date
        List<Criminal_Judicial_Procedure__c> crims = [SELECT Id FROM Criminal_Judicial_Procedure__c WHERE Id IN :crimActionToProcMap.keySet()];
        for(Criminal_Judicial_Procedure__c c : crims){
            Procedural_Movement__c proc = crimActionToProcMap.get(c.Id);
            c.Last_Procedural_Movement_Date__c = proc.Movement_Date__c;
        }
        update crims;
        
        //update executive actions' last procedural date
        List<Executive_Action_Procedure__c> execs = [SELECT Id FROM Executive_Action_Procedure__c WHERE Id IN :execActionToProcMap.keySet()];
        for(Executive_Action_Procedure__c e : execs){
            Procedural_Movement__c proc = execActionToProcMap.get(e.Id);
            e.Last_Procedural_Movement_Date__c = proc.Movement_Date__c;
        }
        update execs;
        
        //update declarative actions' last procedural status and date
        List<Declarative_Action__c> actions = [SELECT Id FROM Declarative_Action__c WHERE Id IN :declActionToProcMap.keySet()];
        for(Declarative_Action__c a : actions){
            Procedural_Movement__c proc = declActionToProcMap.get(a.Id);
            a.Procedural_Movement_Status__c = proc.Movement_Status__c;
            a.Last_Procedural_Movement_Date__c = proc.Movement_Date__c;
        }
        update actions;
        
        //update injunctions' last procedural date and status
        List<Injunction_Procedure__c> injs = [SELECT Id FROM Injunction_Procedure__c WHERE Id IN :injToProcMap.keySet()];
        for(Injunction_Procedure__c i : injs){
            Procedural_Movement__c proc = injToProcMap.get(i.Id);
            i.Procedural_Movement_Status__c = proc.Movement_Status__c;
            i.Last_Procedural_Movement_Date__c = proc.Movement_Date__c;
        }
        update injs;
    }
    
    //before procedural movement is created, set movement date to today()
    public static void handleSetMovementDate(List<Procedural_Movement__c> newProcs){
        for(Procedural_Movement__c proc : newProcs){
            if(proc.Movement_Date__c == null){
                proc.Movement_Date__c = Date.today();
            }
        }
    }
}