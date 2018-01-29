public class ChangeBillingFrequencyController {
    
    private ApexPages.StandardController standardController;
    public boolean disabledButton {get;set;}
    public Date dateOfChange=Date.today();
    
    /**************************************************/
    /*                  CONSTRUCTOR                   */
    /**************************************************/

    public ChangeBillingFrequencyController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }
    
    /**************************************************/
    /*              BEHAVIOUR METHODS                 */
    /**************************************************/

    //-----ChangeBillingFrequencyTrue-----//

    public PageReference ChangeBillingFrequencyTrue()
    {    
        ID appID = standardController.getId();
        String result;
        disabledButton = false;     
        
        //result = ChangeBillingFrequency.Change_Billing_Invoice(appID,true,dateOfChange);
        result= new BILL_ChangeBillingFrequency().changeBillingInvoice(appID,true,dateOfChange);
        
        if (result.equals('Erro'))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, result));
            disabledButton = true;
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, result));
            disabledButton = false;
        }      
        return null;
    }//end ChangeBillingFrequencyTrue method 
    
    //-----ChangeBillingFrequencyFalse-----//

    public PageReference ChangeBillingFrequencyFalse()
    {    
        ID appID = standardController.getId();
        String result;
        disabledButton = false;     
        
        //result = ChangeBillingFrequency.Change_Billing_Invoice(appID,false,dateOfChange);
        result= new BILL_ChangeBillingFrequency().changeBillingInvoice(appID,false,dateOfChange);
        
        if (result.equals('Erro'))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, result));
            disabledButton = true;
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, result));
            disabledButton = false;
        }      
        return null;
    }//end ChangeBillingFrequencyFalse method
    
    //-----checkChangeBillingFrequency-----//

    public PageReference checkChangeBillingFrequency()
    {
        ID appID = standardController.getId();    
        // Validate existance of record in billing contracts, if exists returns an error
        List<Billing_Contract__c> billexists =[Select id from Billing_Contract__c where Application__c =: appID];
        if(billexists.size()==0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Não existe um Billing Contract associado!'));
            disabledButton = true;
        }
        return null;
    }//end checkChangeBillingFrequency method 
}//END CLASS