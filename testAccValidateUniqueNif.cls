@isTest(SeeAllData=true)
public class testAccValidateUniqueNif {
    
    public static TestMethod void teste1(){
        Account client = new Account();
        client.Name = 'Test Client ValidateNif'; 
        client.Type = 'Customer - Channel';
        client.NIF__c = '506677702';
        try{
        	insert client;
        }catch(Exception e){ 
            system.Debug('testTriger ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
        }
        
    }
}