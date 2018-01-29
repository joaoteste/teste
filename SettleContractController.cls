public class SettleContractController {
    
    private ApexPages.StandardController standardController;
    public boolean disabledButton {get;set;}
    
    public SettleContractController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }
    
    public PageReference settleContract(){
        
        ID appID = standardController.getId();
        String result;
        disabledButton = false;
        
        result = settleContract.validateContract(appID);
        
        if (result.equals('Contract Settlement Successed! Contract Billing Contracts, Sales Invoices, Journals and Transactions will be created in background if due!')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, result));
            disabledButton = true;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, result));
            disabledButton = false;
        }
        
        return null;
    }
    
    public PageReference checkBillingContract(){
        ID appID = standardController.getId();
        
        if(!UserInfo.isCurrentUserLicensed('c2g') && !Test.isRunningTest()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'The user ' +  UserInfo.getName() + ' don\'t have Financial Force permissions to performe this action.'));
            disabledButton = true;
        }
        
        // Validate existance of record in billing contracts, if exists returns an error
        List<Billing_Contract__c> billexists =[Select id from Billing_Contract__c where Application__c =: appID];
        if(billexists.size()!=0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Billing Contract já existe!'));
            disabledButton = true;
        }
        return null;
    } 
}