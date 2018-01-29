/**
* @date 2017
*
* @description Wrapper Class for the sObject Decision__c. Useful for using in visualforce pages (ex: Partner Portal, client Portal) to show some additional information associated with the sObject instance.
*/
public virtual class DecisionWrapper {

    public ID decisionID {get; set;}
    public String decisionName {get; set;}
    public ID accountDec {get; set;}
    public ID creditInfo {get; set;}
    public double candorScore{get; set;}
    public String grade {get; set;}
    public String decisionStatus{get; set;}
    public String subGrade {get; set;}
    public double guidanceLimitMin {get; set;}
    public Decision__c decisionOrigin {get; set;}
    public double guidanceLimitMax {get; set;}
    public boolean over_ride {get; set;}
    public boolean active {get; set;}
    public ConditionWrapper conditions {get;set;}
    public Decimal monthlyFee {get;set;}
    
    /*	Builds an Decisions Wrapper using a query to get the Decision.
     * @params - decisionID - ID of the decision that will be queried.
     * 
     * NOTE: DO NOT USE THIS IN A LOOP CONTEXT AS IT USES QUERYS
     */
    public DecisionWrapper (Id decisionID){
    
        Decision__c decision = queryDecision(decisionID);

        setConstructorValues(decision);
        System.debug('[decisionWrapper - constructor ] object: ' + this);
    }

     /*	Builds an Decisions Wrapper using a query to get the Decision.
     * @params - decision - the decision that will be put onto the wrapper.
     */
    public DecisionWrapper (Decision__c decision){
        setConstructorValues(decision);
        System.debug('[decisionWrapper - constructor ] object: ' + this);
    }

    /*******************************************************************************************************
    *
    * PUBLIC STATIC METHODS.
    *
    ********************************************************************************************************/

    /*******************************************************************************************************
    * @description Get All factor cards by type with line item per grade 
    * @return the object FactorWrapper
    */
    public static List<FactorWrapper> getAllFactorCards(){
        
        List<FactorWrapper> fwlist = new List<FactorWrapper>();
        List<Factorcard__c> fcList = [SELECT ID, Name, Type__c, 
                                     (SELECT ID, Name, Factor__c, Grade__c, Max_Instalment__c, Max_Value__c, Min_Instalment__c, Min_Value__c, Sub_grade__c, Term__c FROM Factorcard_Line_Items__r)  
                                     FROM Factorcard__c];
        if(fcList.size() == 0){     
            return null;
        }

        for(Factorcard__c fc : fcList){
            FactorWrapper fw = new FactorWrapper(fc);
            fwlist.add(fw);
        }
        
        System.debug('[decisionWrapper - getAllFactorCardsByType()) ] factor cards wrappers list: ' +  fwlist);

        return fwlist;
    }

    /*	Returns all the factor card line items
    *  @params - type - (Diluted or Standard) the decision that will be put onto the wrapper.
    */
    public static List<Factorcard_Line_Item__c> getFactorCardLineItem(string type){
        Factorcard__c fc = [SELECT ID, Name, (SELECT ID, Name, Factor__c, Grade__c, Max_Instalment__c, Max_Value__c, Min_Instalment__c, Min_Value__c, Sub_grade__c, Term__c FROM Factorcard_Line_Items__r) 
                            FROM Factorcard__c WHERE Type__c =:type];
        if(fc == null){
            return null;
        }
        
        System.debug('[decisionWrapper - getFactorCardLineItem(string type)] factor card line items: ' +  fc.Factorcard_Line_Items__r);

        return fc.Factorcard_Line_Items__r;
    }

    /* Returns all the factor card line items
    *  @params - type - (Diluted or Standard) the decision that will be put onto the wrapper.
    *  @params - grade - factor grade (A, B, C, etc..).
    *  @params - subGrade - factor subGrade (1, 2, 3, etc..).
    */
    public static List<Factorcard_Line_Item__c> getFactorCardLineItem(string type, String grade, String subGrade){
        Factorcard__c fc = [SELECT ID, Name, (SELECT ID, Name, Factor__c, Grade__c, Max_Instalment__c, Max_Value__c, Min_Instalment__c, Min_Value__c, Sub_grade__c, Term__c FROM Factorcard_Line_Items__r WHERE Grade__c =:grade AND Sub_grade__c=:subGrade) 
                            FROM Factorcard__c WHERE Type__c =:type ];
        if(fc == null){
            return null;
        }
        
        System.debug('[decisionWrapper - getFactorCardLineItem(string type, String grade, String subGrade)] factor card line items: ' +  fc.Factorcard_Line_Items__r);

        return fc.Factorcard_Line_Items__r;
    }

    /* Returns Decision__c
    *  @params - DecicionID - sObject decision__c ID.
    *  @return Decision__c sObject for the params DecisionID
    */
    public static Decision__c queryDecision(ID decisionID){

        return [SELECT ID, Name, Account__c, Account__r.BillingCountry , Credit_Info__c, Score__c, Grade__c, Decison_Status__c, Sub_Grade__c, Decision_Origin__c, Guidance_Limit_Min__c, Guidance_Limit_Max__c,
                Override__c, Active__c,
                (SELECT ID, Term_12__c, Term_24__c, Term_36__c, Term_48__c, Term_60__c, Term_72__c, Personal_Guarantee__c, Billing_Frequency__c, Advance_Payment__c, 
                Administrative_Costs__c FROM Decision_Conditions_Card_History__r ORDER BY CREATEDDATE DESC LIMIT 1)  
                FROM decision__c  WHERE ID =: decisionID];
    }

    /* Returns Map Conditions Wrapper per Account ID 
    *  @params - Account List
    *  @return Map<Id, ConditionWrapper> -> Map <Account ID, DecisionWrapper>
    */
    public static Map<Id, ConditionWrapper> getConditionHistoryForAccount(List<Account> accList){

        Set<Id> setAccId = (new Map<Id,Account>(accList)).keySet();
        System.debug('[decisionWrapper - getConditionHistoryForAccount] setAccId size() -> ' +  setAccId.size());
        Map<Id, ConditionWrapper> accountIdConditionsMap = new  Map<Id, ConditionWrapper>();

        Decision_Conditions_Card_History__c[] conditionsCardHistoryList = [SELECT ID, Term_12__c, Term_24__c, Term_36__c, Term_48__c, Term_60__c, Term_72__c, Personal_Guarantee__c, Billing_Frequency__c, Advance_Payment__c, 
                                                                Administrative_Costs__c, Decision__r.Account__c FROM Decision_Conditions_Card_History__c WHERE Decision__r.Account__c IN: setAccId];

        System.debug('[decisionWrapper - getConditionHistoryForAccount] conditionsCardHistoryList size() -> ' +  conditionsCardHistoryList.size());
        
        for(Decision_Conditions_Card_History__c conditionCardHistory : conditionsCardHistoryList){
            ConditionWrapper cw = new ConditionWrapper(conditionCardHistory);
            accountIdConditionsMap.put(conditionCardHistory.Decision__r.Account__c, cw);
        }                                                                

        System.debug('[decisionWrapper - getConditionHistoryForAccount] Map<accountID, ConditionWrapper> -> ' +  accountIdConditionsMap);
        return accountIdConditionsMap;
    }

    /*******************************************************************************************************
    *
    * PRIVATE METHODS.
    *
    ********************************************************************************************************/

    /*******************************************************************************************************
    * @description Set values to object
    */
    private void setConstructorValues(Decision__c decision){
        this.decisionID = decision.ID;
        this.decisionName = decision.Name;
        this.accountDec = decision.Account__c;
        this.creditInfo = decision.Credit_Info__c;
        this.candorScore = decision.Score__c;
        this.grade = decision.Grade__c;
        this.decisionStatus = decision.Decison_Status__c;
        this.subGrade = decision.Sub_Grade__c;
        this.guidanceLimitMax = decision.Guidance_Limit_Max__c;
        this.over_ride = decision.Override__c;
        this.active = decision.Active__c;
        this.conditions = decision.Decision_Conditions_Card_History__r.size() > 0 ? new ConditionWrapper(decision.Decision_Conditions_Card_History__r[0]) : null;        

        Credit_Decisions_Settings__mdt[] cds_mdt = [SELECT Monthly_Fee__c, Minimum_Credit_Allowed__c FROM Credit_Decisions_Settings__mdt WHERE Label =: decision.Account__r.BillingCountry LIMIT 1];
        this.monthlyFee = cds_mdt.size()>0 ? cds_mdt[0].Monthly_Fee__c : this.monthlyFee;
        this.guidanceLimitMin = cds_mdt.size()>0 ? cds_mdt[0].Minimum_Credit_Allowed__c : 500;
    }

    /*******************************************************************************************************
    *
    * INNER CLASSES.
    *
    ********************************************************************************************************/    

    /*******************************************************************************************************
    * @description Inner class to to wrapp sObject factorcard__c;
    */
    public class FactorWrapper{

        public string Type {get;set;}
        public List<Factorcard_Line_Item__c> FactorItems {get;set;}

        public FactorWrapper(Factorcard__c factorCard){
            
            this.Type = factorCard.Type__c;
            this.FactorItems = factorCard.Factorcard_Line_Items__r.size()>0 ? factorCard.Factorcard_Line_Items__r : FactorItems;
        }
    }

    /*******************************************************************************************************
    * @description Inner class to to wrapp sObject Condition_Card_Line_Item__c;
    */
    public class ConditionWrapper{

        public List<String> billing_options {get;set;}
        public List<Integer> term_options {get;set;}
        public boolean personal_guarantee {get; set;}
        public Decimal admin_costs {get; set;}

        public ConditionWrapper(Decision_Conditions_Card_History__c conditionCardLineItem){

            if(conditionCardLineItem!=null){
                this.term_options = getTermOptions(conditionCardLineItem);
                this.billing_options = conditionCardLineItem.Billing_Frequency__c != null ? conditionCardLineItem.Billing_Frequency__c.split(';') : new List<String>();
                this.personal_guarantee = conditionCardLineItem.Personal_Guarantee__c;
                this.admin_costs = conditionCardLineItem.Administrative_Costs__c;
            }

            System.debug('[ConditionWrapper - constructor] -> ' + this);
        }

        //get a list of allowed term. Assume that the boolean fields for terms are always in this form Term_XX__c 
        private List<Integer> getTermOptions(Decision_Conditions_Card_History__c conditionCardLineItem){

            SObjectType sobjectType = Schema.getGlobalDescribe().get('Condition_Card_Line_Item__c');
            List<String> fieldList = new List<string>(sobjectType.getDescribe().fields.getMap().keySet());
            List<Integer> term_options = new List<Integer>();
            List<String> s_parts = new List<String>();
            for(String s : fieldList){
                if(s.startsWithIgnoreCase('Term_')){
                    s_parts = s.split('_');
                    if(s_parts.size()>=2 && s_parts[0].toLowerCase() == 'term' && s_parts[1].toLowerCase().isNumeric() && (boolean)conditionCardLineItem.get(s)){
                        term_options.add(Integer.valueOf(s_parts[1]));
                    }
                }
            } 

            System.debug('[ConditionWrapper - getTermOptions()] terms: ' + term_options);
            return term_options;
        }
    }
}