public class Client_Visit_Handler {

    public static void handleSetCreatedDate(List<Client_Visit__c> newVis){
        for(Client_Visit__c v : newVis){
            if(v.Created_Date__c == null){
                v.Created_Date__c = Date.today();
            }
        }
    }
    
    public static void handleSetExpertCompanyData(List<Client_Visit__c> newVis){
        Client_Visits_Settings__mdt metaData = [SELECT Expert_Company__c, Expert_Company_Contact__c, Expert_Company_Country__c FROM Client_Visits_Settings__mdt];
        for(Client_Visit__c v : newVis){
            v.Expert_Company__c = metaData.Expert_Company__c;
            v.Expert_Company_Contact__c = metaData.Expert_Company_Contact__c;
        }
    }
    
    public static void handleSetClientAndVendorData(List<Client_Visit__c> newVis){
        Map<Id,Client_Visit__c> appToVis = new Map<Id,Client_Visit__c>();
        
        //populate map
        for(Client_Visit__c v : newVis){
            appToVis.put(v.Application_Number__c, v);
        }
        
        List<Application__c> apps = [SELECT Id, AccClient__c, Vendor__c FROM Application__c WHERE Id IN :appToVis.keySet()];
        
        for(Application__c app : apps){
            Client_Visit__c visit = appToVis.get(app.Id);
            visit.Account_Client__c = app.AccClient__c;
            visit.Account_Vendor__c = app.Vendor__c;
        }
    }
    
    /*
    public static void handleSetEquipmentLocationData(List<Client_Visit__c> newVis){
        Map<Id,Client_Visit__c> appToVis = new Map<Id,Client_Visit__c>();
        
        //populate map
        for(Client_Visit__c v : newVis){
            appToVis.put(v.Application_Number__c, v);
        }
        
        List<Application__c> apps = [SELECT Id, Street_Address__c, City__c, Zip_Postal_Code__c FROM Application__c WHERE Id IN :appToVis.keySet()];
        
        for(Application__c app : apps){
            Client_Visit__c visit = appToVis.get(app.Id);
            visit.Street_Address__c = app.Street_Address__c;
            visit.ZIP_Postal_Code__c = app.Zip_Postal_Code__c;
            visit.City__c = app.City__c;
        }
    }*/
    
    public static void handleSetEquipmentRelatedList(List<Client_Visit__c> newVis){
        Map<Id,Client_Visit__c> appToVis = new Map<Id,Client_Visit__c>();
        
        //populate map
        for(Client_Visit__c v : newVis){
            appToVis.put(v.Application_Number__c, v);
        }
        
        List<Equipment__c> equips = [SELECT Id, Application__c FROM Equipment__c WHERE Application__c IN :appToVis.keySet()];
        
        for(Equipment__c equip : equips){
            Client_Visit__c visit = appToVis.get(equip.Application__c);
            equip.Client_Visit__c = visit.Id;
        }
        update equips;
    }
    
    public static void handleSetContactRelatedList(List<Client_Visit__c> newVis){
        Map<Id,Client_Visit__c> accToVis = new Map<Id,Client_Visit__c>();
        
        //populate map
        for(Client_Visit__c v : newVis){
            accToVis.put(v.Account_Client__c, v);
        }
        
        //get contacts from client accounts
        List<Contact> contacts = [SELECT Id, Client_Visit__c, AccountId FROM Contact WHERE AccountId IN :accToVis.keySet()];
        //relate contacts to client visits
        for(Contact contact : contacts){
            Client_Visit__c visit = accToVis.get(contact.AccountId);
            contact.Client_Visit__c = visit.Id;
        }
        update contacts;
    }
    
    public static void handleSetAttachmentRelatedList(List<Client_Visit__c> newVis){
        Map<Id,Client_Visit__c> appToVis = new Map<Id,Client_Visit__c>();
        
        //populate map
        for(Client_Visit__c v : newVis){
            appToVis.put(v.Application_Number__c, v);
        }
        
        //get auto de aceitação from renting app (there are 2, we want the latest because it is the one which is signed)
        List<Attachment> attachments = [SELECT Id, ParentID, Name, ContentType, Description, Body
                                        FROM Attachment 
                                        WHERE Parent.Type = 'Application__c' AND Name LIKE 'Auto de aceita%' AND ParentID IN :appToVis.keySet() 
                                        ORDER BY CreatedDate DESC LIMIT 1];
        
        //populate autos de aceitacao nas visitas
        List<Attachment> toInsertAtts = new List<Attachment>();
        for(Attachment att : attachments){
            Client_Visit__c visit = appToVis.get(att.ParentID);
            Attachment a = new Attachment();
            a.Name = att.Name;
            a.Body = att.Body;
            a.ContentType = att.ContentType;
            a.Description = att.Description;
            a.ParentId = visit.Id;
            toInsertAtts.add(a);
        }
        insert toInsertAtts;
    }

    
    public static void handleSetRentingAppVisitData(List<Client_Visit__c> newVis){
        Map<Id,Client_Visit__c> appToVis = new Map<Id,Client_Visit__c>();
        
        //populate map
        for(Client_Visit__c v : newVis){
            appToVis.put(v.Application_Number__c, v);
        }
        
        List<Application__c> apps = [SELECT Id FROM Application__c WHERE Id IN :appToVis.keySet()];
        for(Application__c app : apps){
            Client_Visit__c visit = appToVis.get(app.Id);
            app.Expert_Company__c = visit.Expert_Company__c;
            app.Request_Visit_Date__c = visit.Created_Date__c;
        }
        update apps;
    }
    
    public static void handleUpdateRentingAppVisitData(Map<Id, Client_Visit__c> oldMap, Map<Id, Client_Visit__c> newMap){
        Map<Id,Client_Visit__c> toUpdateRentingApps = new Map<Id,Client_Visit__c>();
        
        for(Client_Visit__c visitAfter : newMap.values()){
            Client_Visit__c visitBefore = oldMap.get(visitAfter.Id);
            if(!visitBefore.Visit_Status__c.equals(visitAfter.Visit_Status__c)){
                toUpdateRentingApps.put(visitAfter.Application_Number__c,visitAfter);
            }
        }
        
        List<Application__c> apps = [SELECT Id FROM Application__c WHERE Id IN :toUpdateRentingApps.keySet()];
        for(Application__c app : apps){
            Client_Visit__c visit = toUpdateRentingApps.get(app.Id);
            app.Visit_Status__c = visit.Visit_Status__c;
            app.Visit_Report_Date__c = visit.Visit_Date__c;
        }
        update apps;
    }
}