public class SC_DecisionController {
    
    private final Decision__c decision;
    public Boolean personalGuarantee {get; set;}
    
    // The extension constructor initializes the private member
    // variable decision by using the getRecord method from the standard
    // controller.
    public SC_DecisionController(ApexPages.StandardController stdController) {
        this.decision = (Decision__c)stdController.getRecord();
        List<Decision_Conditions_Card_History__c> conditionCard = [SELECT Id, Personal_Guarantee__c FROM Decision_Conditions_Card_History__c WHERE Decision__c = :this.decision.Id ORDER BY CreatedDate DESC NULLS LAST LIMIT 1]; 
        if(conditionCard.size() == 1){
        	this.personalGuarantee = conditionCard[0].Personal_Guarantee__c;
        }
    }
    
    public pagereference saveAndSubmitForApproval(){
    	
    	saveAndSubmitDecisionForApproval(this.decision);
    	
    	pagereference redirect = new PageReference('/'+ this.decision.id); 
        return redirect;
    }
    
    public static Boolean saveAndSubmitDecisionForApproval(Decision__c decision){
    	
    	update decision;
    	
    	// Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(decision.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId( UserInfo.getUserId() ); 
        
        // Submit the record to specific process and skip the criteria evaluation
//        req1.setProcessDefinitionNameOrId('PTO_Request_Process');
//        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
    	return true;
    }

//////////////////////////////////
// methods used in Lightning 
//////////////////////////////////
    @AuraEnabled
    public static Boolean getPersonalGuarantee(String decisionId) {
        List<Decision_Conditions_Card_History__c> conditionCard = [SELECT Id, Personal_Guarantee__c FROM Decision_Conditions_Card_History__c WHERE Decision__c = :decisionId ORDER BY CreatedDate DESC NULLS LAST LIMIT 1]; 
        
        system.debug('getPersonalGuarantee conditionCard:' + conditionCard);
        
        if(conditionCard.size() == 1){
        	return conditionCard[0].Personal_Guarantee__c;
        }

        return null;
    }
        
    @AuraEnabled
    public static Decision__c getDecision(String decisionId) {
    	
    	Decision__c aux = [SELECT Id, 
    	                          Name,  
    	                          Grade__c, 
    	                          Grade_Override__c, 
    	                          Guidance_Limit_Max__c, 
    	                          Guidance_Limit_Max_Override__c,
    	                          Personal_Guarantee_Override__c,
    	                          CreatedDate 
                FROM Decision__c WHERE ID = :decisionId];
        return aux;
    }
    
    @AuraEnabled
    public static Decision__c submitforapprovalinController(Decision__c decision) {
    	
    	system.debug('submitforapprovalinController decision:' + decision);
    	
        saveAndSubmitDecisionForApproval(decision);
        
        return decision;
    }

    
}