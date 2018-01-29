@isTest (SeeAllDAta = True)
public class ApplicationChangePaymentMethodTest {

    @isTest
    static void changeDirectDebit_ATM(){
        try{
            Application__C app = [Select Id from Application__c where Name = 'AP-001048'];

            app.Payment_Method__c = 'ATM Reference';
            update app;
        }
        catch(Exception e){
            
            System.debug('Exception: '+e);
        }
    }
    
    @isTest
    static void changeATM_DirectDebit(){
        try{
           Application__C app = [Select Id from Application__c where Name = 'AP-000029'];

            app.Payment_Method__c = 'Direct Debit';
            update app;
        }
        catch(Exception e){
            
            System.debug('Exception: '+e);
        }
    }
    
    @isTest
    static void changeDirectDebit_ATMRenewal(){
        try{
            Application__C app = [Select Id from Application__c where Name = 'AP-002036'];
            app.Payment_Method__c = 'ATM Reference';
            update app;
        }
        catch(Exception e){
            
            System.debug('Exception: '+e);
        }
    }
    
    @isTest
    static void changeATMCosts(){
        try{
            Application__C app = [Select Id,ATM_Reference_Costs__c from Application__c where Name = 'AP-000029'];
            app.ATM_Reference_Costs__c = 20;
            update app;
        }
        catch(Exception e){
            
            System.debug('Exception: '+e);
        }
    }
    
    @isTest
    static void changeATMCosts2Zero(){
        try{
            Test.startTest();
            Application__C app = [Select Id,ATM_Reference_Costs__c from Application__c where Name = 'AP-000029'];
            app.ATM_Reference_Costs__c = 0;
            update app;
            test.stopTest();
        }
        catch(Exception e){
            
            System.debug('Exception: '+e);
        }
    }
    
    @isTest
    static void allchanges(){
        try{
            List<Application__c> appList = new List<Application__c>();
            Application__C app = [Select Id,Payment_Method__c from Application__c where Name = 'AP-001692']; //no change
            appList.add(app);
            app = [Select Id,Payment_Method__c from Application__c where Name = 'AP-001011'];  //ATM to Debit Direct
            app.Payment_Method__c = 'Direct Debit';
            appList.add(app);
            app = [Select Id,Payment_Method__c from Application__c where Name = 'AP-000386'];  //Debit Direct to ATM
            app.Payment_Method__c = 'ATM Reference';
            appList.add(app);
            app = [Select Id,Payment_Method__c from Application__c where Name = 'AP-001972'];        //next billing line item is renewal 
            app.Payment_Method__c = 'ATM Reference';
            
            appList.add(app);
            
            update appList;
        }
        catch(Exception e){
            
            System.debug('Exception: '+e);
        }
    }
    
    @isTest
    static void changesWithWS(){ //utiliza o web service para executar as alterações
		Application__C app = [Select Id,Name from Application__c where Name = 'AP-001692'];  //Direct Debit to ATM
        Billing_Contract__c billingContract = [Select Id,Application__c from Billing_Contract__c where Application__c = :app.id];
        ApplicationTriggerHandler.changePaymentMethod_WS(billingContract.Id);
    }
}