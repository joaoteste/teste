@isTest(SeeAllData=true)
public class PP_SendEmailProposal_Test {

    
    @isTest
    public static void testCloseUnpaid(){
		RentingApplication_Util_Test rAp = new RentingApplication_Util_Test();
        Map<String, String> infoMap = rAp.environment4();
        ID cc = infoMap.get('ccID');
		ID newAccount = infoMap.get('client');
        ID atm = infoMap.get('atm');
        
        Contact contact=new contact();
        contact.LastName = 'Doe';
        contact.Email = 'test@email.com';
        contact.Role__c='Binding Power';
        contact.AccountId= newAccount;
        insert contact;
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Account__c = infoMap.get('client');
        pp.Status__c = 'Open';
        pp.Collection_Case__c = cc;
        pp.Hit_Date__c = system.today();
		pp.Contact__c = contact.ID;
        pp.Frequency__c = 'Every 15 Days';
        pp.Number_of_Payments__c = '4';
        pp.Amount_Claimed__c = 100;
        pp.Fees_Amount__c = 10;
        pp.Payments_Table__c = 'test';
        
        insert pp;
        
        
        String result = PP_SendEmailProposal.execute(pp.ID);
        
        system.assertEquals('Email Sent With Success!', result);

        
    }
    

}