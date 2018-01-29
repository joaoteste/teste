global class Client_Visit_Factory {

    webservice static String createClientVisitForRentingApp(Id appId){
        Client_Visit__c visit = new Client_Visit__c();
        visit.Application_Number__c = appId;
        visit.Type__c = 'Underwriting Process';
        visit.Visit_Status__c = 'Processing';
        List<RecordType> recordType = [Select Id From RecordType WHERE Name ='Client Visit Underwriting' and SobjectType ='Client_Visit__c'  limit 1];
        visit.RecordTypeId = (recordType.size() == 1) ? recordType.get(0).Id : null;
        insert visit;
           
        String response = 'Created Client Visit Successfully\n';
        List<Client_Visit__c> visits = [SELECT Id, Name FROM Client_Visit__c WHERE Application_Number__c = :appId];
        response += 'This Renting Application now has '+visits.size()+' visits:\n';
        
        for(Client_Visit__c v : visits){
            response += 'Visit '+v.Name+'\n';
        }
        return response;
    }
    
}