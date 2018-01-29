//criacao - 20/02/17 -(BP)
//@Apex notation: 
//Trigger on Application Object
//In future just need to create  method in private methods with same signature of the others and call it 
//in respective trigger's behaviour (beforeUpdate,afterInsert,etc) 
//TEST CLASSES: ApplicationChangePaymentMethodTest && test_RetingApplication, test_settleContract
global class ApplicationTriggerHandler extends TriggerHandler
{   
    public ApplicationTriggerHandler() {}   
    public static boolean isProcessing = false;
    
    /**************************************************************************************************/
    /*                                      CONTEXT OVERRIDES                                         */
    /**************************************************************************************************/
    
    protected override void  beforeInsert(){   
        System.debug('ApplicationTrigger --> ApplicationTrigger in BEFORE INSERT case...');
        Set<Id> vendorIds = getVendorIdsFromNewApps((List<Application__c>)Trigger.new);
        List<Account> accList = [SELECT Id, Insurance_Type__c  FROM Account WHERE ID IN :vendorIds];
        if(accList.size()>0){
            Map<ID, Account> vendorMap = new Map<ID, Account>(accList);
            setApplicationInsuranceType(vendorMap); 
        }
        
        setPriceBook();
        
    }
    
    protected override void  afterInsert(){
        System.debug('ApplicationTrigger --> ApplicationTrigger in AFTER INSERT case...');
        for(SObject objectApplication: trigger.new){
            Application__c app = (Application__c) objectApplication;
            Insurance_Management__c insurance = InsuranceManagement.createActiveInsuranceManagement(app.ID, 'Candor', '',null , app.Insurance_Type__c);
        }
        
        //sendEmailDecision();
    }
    
    
    protected override void  beforeUpdate(){        
        System.debug('ApplicationTrigger --> ApplicationTrigger in BEFORE UPDATE case...');
        Set<Id> appIdsSet = Trigger.newMap.keySet();

        changedPaymentMethod(trigger.new, Trigger.oldMap);

        Set<Id> statusAppsID = new Set<Id>();
        Set<Id> clientAccIDset = new set<Id>();
        List<Application__c> appsTo_updateList = new List<Application__c>();
        
        for( Application__c newApp: (List<Application__c>)Trigger.new ){
 
            Application__c oldApp=(Application__c)Trigger.oldMap.get(newApp.ID);

            /*if(shouldUpdateAppsDecision(newApp, oldApp) == true){
                clientAccIDset.add(newApp.AccClient__c);
                appsTo_updateList.add(newApp);
            }*/

            if(oldApp.Status__c != newApp.Status__c){
                statusAppsID.add(newApp.ID); 
            }
        }

        /*if( appsTo_updateList.size() > 0 ){
            setNewDecisions(appsTo_updateList, clientAccIDset);
        }*/
 
        if(!statusAppsID.isEmpty()){
            translate(statusAppsID);            
        }
        
        //[START]if contract settlement changed from null to something, create login for signer1 (if it doesnt exist)
        Map<Id, Application__c> signerToApp = new Map<Id, Application__c>();
        for(Application__c newApp : (List<Application__c>)Trigger.new){
        	Application__c oldApp = (Application__c)Trigger.oldMap.get(newApp.Id);
        	if(oldApp.Invoice_Payment_Date__c == null && newApp.Invoice_Payment_Date__c != null){
        		signerToApp.put(newApp.Client_Signer_1__c, newApp);
        	}
        }
        
        List<Contact> noLoginContacts = [SELECT Email, Login__c FROM Contact WHERE Id IN :signerToApp.keySet() AND Login__c = null];
        
        Set<String> emails = new Set<String>();
        for(Contact c : noLoginContacts){
        	emails.add(c.Email);
        }
        
        List<Login__c> loginEmails = [SELECT Id, Email__c FROM Login__c WHERE Email__c IN :emails];
        
        Map<String, Login__c> emailToLogin = new Map<String, Login__c>();
        for(Login__c l : loginEmails){
        	emailToLogin.put(l.Email__c, l);
        }
        
        //if a contact that doesnt have login has an email which is already in use in a login associate it with that login
        List<Contact> toUpdate = new List<Contact>();
        for(Integer i = 0; i < noLoginContacts.size(); i++){
        	Contact c = noLoginContacts.get(i);
        	if(emailToLogin.containsKey(c.Email)){
        		Login__c aux = emailToLogin.get(c.Email);
        		c.Login__c = aux.Id;
        		toUpdate.add(c);
        		noLoginContacts.remove(i);//remove so later we dont try to create a new login for this email
        	}
        }
        
        update toUpdate;
        
        //[END]generate a login for signers who dont have it
        ClientAppService_TestUtils.getLoginFromContacts(noLoginContacts);
    }
    
    protected override void  afterUpdate(){    
        System.debug('ApplicationTrigger --> ApplicationTrigger in AFTER UPDATE case...');
        
        Set<Id> newids= new Set<Id>();
        Set<ID> newInsuranceAppIds = new Set<ID>();
        Set<ID> statusApps = new Set<ID>();
        Set<ID> ibanAppID = new Set<ID>();
        Set<ID> interestRateAppID = new Set<ID>();
        
        for( Application__c newApp: (List<Application__c>)Trigger.new ){
            Application__c oldApp=(Application__c)Trigger.oldMap.get(newApp.ID);
            if( oldApp.Insurance_Type__c!= 'Own Insurance' && newApp.Insurance_Type__c == 'Own Insurance' ){
                newInsuranceAppIds.add(newApp.id); 
            }
            if(newApp.Status__c== 'Contract - Lawsuit' && oldApp.Status__c != newApp.Status__c){
                //statusApps.add(newApp.ID); 
            }
            if(oldApp.Client_BBAN__c != newApp.Client_BBAN__c && newApp.Client_BBAN__c !='000000000000000000000'){
                ibanAppID.add(newApp.id);
            }
            if((oldApp.Equipment_Cost__c != newApp.Equipment_Cost__c || oldApp.Payment_Amount__c != newApp.Payment_Amount__c ||oldApp.TermCalc__c != newApp.TermCalc__c ) && 
               (newApp.Equipment_Cost__c !=0 && newApp.Payment_Amount__c !=0 && newApp.TermCalc__c !=null )
              ){
                  interestRateAppID.add(newApp.id);
              }
            
            
            newids.add(newApp.id);
        }
        
        if(newids.isEmpty()){
            return;
        }
        
        //delete insurance billings when change to own insurance
        if(!newInsuranceAppIds.isEmpty()){
            List<Billing_Contract_Line_Item__c> listBcliToDelete = new List<Billing_Contract_Line_Item__c>(deleteBillingLineItems(newInsuranceAppIds));
            if(!listBcliToDelete.isEmpty()){
                delete listBcliToDelete;
                System.debug('ApplicationTrigger.DeleteBillingLineItems --> Foram apagados'+listBcliToDelete.size()+' BCLIS...');        
            }
        }
        
        //AddInsuranceBclis();
        if(!ibanAppID.isEmpty()){
        	UpdateIBAN(ibanAppID);
        }
        UpdateCreditLine();
        
        if(!statusApps.isEmpty()){
            Trigger_APP_BC_Contract_Inactive(statusApps);
            List<Collection_Case__c> collectionsToUpdate = new List<Collection_Case__c>(collectionCaseChangeAppLawsuit(statusApps));
            if(!collectionsToUpdate.isEmpty() && collectionsToUpdate != null){
                update collectionsToUpdate;
            }
        }
        //Candor_Trigger_APP_ACC_Signer1email_to_invoiceEmail(); //Deprecated - trello: https://trello.com/c/QVJmktb6/25-o-campo-invoice-email-do-account-deve-ser-preenchido-automaticamente-com-o-email-do-signer-1-do-objecto-renting-aplications-depo
        //A mudança do email signer 1 está a a ser avaliada no método setAppClientSigners. 
        //Caso esteja nas condições certas é colocado no campo Invoice Email (c2g__CODAInvoiceEmail__c).
        if(!interestRateAppID.isEmpty()){
        	List<Application__c> appsToUpdate = new List<Application__c>(calcAnnualInterestRate(interestRateAppID));
            if(!appsToUpdate.isEmpty()){
                update appsToUpdate;
            }
        }
        //ChangeInsuranceBCLIS(); 
        
        sendEmailDecision();
        system.debug('After Update Trigger End...');
    }
    
    /*
    protected override void  beforeDelete()
    {        
        System.debug('ApplicationTrigger --> ApplicationTrigger in BEFORE DELETE case...');     
    }
    */
    
    /*
    protected override void  afterDelete()
    {        
        System.debug('ApplicationTrigger --> ApplicationTrigger in AFTER DELETE case...');  
    }
    */
    
    /*
    protected override void  afterUndelete()
    {
        System.debug('ApplicationTrigger --> ApplicationTrigger in AFTER UNDELETE case...');
    }
    */
    
    /**************************************************************************************************/
    /*                                      PRIVATE METHODS                                           */
    /**************************************************************************************************/ 

    /**************************************************************************************************/ 
    //before insert methods
    private Set<Id> getVendorIdsFromNewApps(List<Application__c> appList){
        Set<Id> vendorIds = New Set<Id> ();
        if(appList!=null){
            for( Application__c app : appList){
                vendorIds.add(app.Vendor__c);
            }
        }
        return vendorIds;
    }
    
    private void setApplicationInsuranceType(Map<Id, Account> vendorMap){
        Account vendor = new Account();
        boolean insruanceNotset = false;
        for(Application__c newApp : (List<Application__c>)Trigger.new){
            vendor = vendorMap.get(newApp.Vendor__c);
            if(vendor != null){
                System.debug(LoggingLevel.INFO, 'Vendor default Insurance_Type__c : ' + vendor.Insurance_Type__c );
                if(vendor.Insurance_Type__c != null){
                    newApp.Insurance_Type__c = vendor.Insurance_Type__c;
                }else{
                    insruanceNotset = true;
                }
            }
        }
        if(insruanceNotset){
            FundingConfig__c mc = FundingConfig__c.getInstance();
            if(mc.debug_email__c !=null) {   
                String  subject = 'WARNING - INSURANCE TYPE NOT SET: The vendor with id "'+ vendor.Id +'" does not have the default insurance type (Insurance_Type__c) selected.';
                String emailBody = 'The vendor with id "'+ vendor.Id +'" does not have the default insurance type (Insurance_Type__c) selected. \n\n';
                emailBody+='Please check if Renting Applications for this Vendor ('+vendor.Id+') have Insuarance Type (Insurance_Type__c).';
                try{
                    sendEmail( mc.debug_email__c, subject, emailBody); 
                    System.debug(LoggingLevel.INFO, 'WARNNING EMAIL SENT TO ' + mc.debug_email__c);
                }
                catch(exception e){
                    System.debug(LoggingLevel.INFO, 'FAILED TO SEND WARNNING EMAIL - SUBJECT: ' + subject +' ; BODY: ' + emailBody);
                    System.debug(LoggingLevel.INFO,'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString());
                }
            }
        }
    }//end setApplicationInsuranceType method

    private void setPriceBook(){
        
        List<Pricebook2> priceBookList = [Select id, Name From Pricebook2];
        Map<String,ID> priceBookMap = new Map<String,ID>();
        
        for(Pricebook2 priceBook : priceBookList){
            priceBookMap.put(priceBook.Name,priceBook.id);    
        }
        
        Set<ID> clientIDs = new Set<ID>();
        for(Application__c newApp :(List<Application__c>)  Trigger.new ){
            clientIDs.add(newApp.AccClient__c);
        }
        
        Map<ID, Account> accountMap = new Map<ID, Account>([Select ID, BillingCountry From Account where id in :clientIDs]);
        
        for(Application__c newApp :(List<Application__c>) Trigger.new){
            if(accountMap.get(newApp.AccClient__c).BillingCountry=='Portugal'){
                newApp.Price_Book__c =  priceBookMap.get('Standard Price Book');               
            }else if(accountMap.get(newApp.AccClient__c).BillingCountry=='Spain'){
                newApp.Price_Book__c =  priceBookMap.get('Standard Price Book');               
            }
        }
    }
    
    /**************************************************************************************************/ 
	//before update  methods
    public static void changedPaymentMethod(List<SObject> appList, Map<Id,SObject> appOldMap){
        
        System.debug('CHANGE PAYMENT METHOD: INITIAL VALIDATION');
        List<Application__c> appNewList = new List<Application__c>();
        
        //changes 21/09/17 PC: get the accounts early to verify the bban. Before, it was done after getting which apps are to update the payments method
        //Key=Application 
        Map<ID,Account> clientMap = new Map<ID,Account>([Select id,name, c2g__CODABankIBANNumber__c, c2g__CODATaxCalculationMethod__c,
                                                         c2g__CODAAccountsReceivableControl__c, BBAN__c,
                                                         c2g__CODAInputVATCode__c, BillingPostalCode, c2g__CODAVATStatus__c,Tax_Zone__c   
                                                         from account 
                                                         where id IN (Select AccClient__c From Application__c where Id IN :appList)]);
        
        for (SObject objectApplication: appList){
            Application__c appUpdated = (Application__c) objectApplication;
            Application__c oldApp = (Application__c) appOldMap.get(appUpdated.ID);
            System.debug('appUpdated '+appUpdated);
            //if it's an update
            if((appUpdated.Payment_Method__c != oldApp.Payment_Method__c) || (appUpdated.ATM_Reference__c != oldApp.ATM_Reference__c) || (appUpdated.ATM_Reference_Costs__c != oldApp.ATM_Reference_Costs__c) || (appUpdated.Price_Book__c != oldApp.Price_Book__c) ){
                //changes 21/09/17 PC: added the if else condition to only permit change from ATM to Direct Debit if client IBAN is field
                if(appUpdated.Payment_Method__c == 'Direct Debit' && oldApp.Payment_Method__c == 'ATM Reference' 
                   && (clientMap.get(appUpdated.AccClient__c).BBAN__c == '' || clientMap.get(appUpdated.AccClient__c).BBAN__c == null)){
                       appUpdated.addError('Invalid BBAN on client when changing Application Payment Method to Direct Debit');
                   }else{
                       appNewList.add(appUpdated);
                   }
            } 
        }
        
        if(appNewList == null || appNewList.size() == 0){
            return;
        }
        
        Map<String,Decimal> pricebookATMEntreyMap = new  Map<String,Decimal>();
        List<PricebookEntry> pricebookATMEntryList = new List<PricebookEntry>([Select ID,Pricebook2Id,Pricebook2.Name,Product2Id,ProductCode,Name,UnitPrice,IsActive,Product2.c2g__CODAInputTaxCode__c From PricebookEntry where ProductCode = 'PT03']);
        
        for(PricebookEntry pricebookEntryValue : pricebookATMEntryList){
            String key = ''+pricebookEntryValue.Pricebook2Id+pricebookEntryValue.Product2.c2g__CODAInputTaxCode__c;
            pricebookATMEntreyMap.put(key, pricebookEntryValue.UnitPrice);
        }
        
        System.debug('CHANGE PAYMENT METHOD: PASS THE VALIDATION');

        System.debug('appList ' + appNewList + ' and TriggerNEW '+appNewList);
        System.debug('appOldMap ' + appOldMap + ' and TriggerOLd '+trigger.oldMap);

        //Get billing Line itens to delete (PT03)
        List<Billing_Contract_Line_Item__c> billingATMList = [Select Id, Application__c, Product_Code__c, Line_Item_Start_Date__c
                                                              From Billing_Contract_Line_Item__c 
                                                              where Application__c IN :appNewList AND Product_Code__c = 'PT03' AND Invoiced__c = FALSE AND Line_Item_Start_Date__c >= :DATE.today()
                                                              ORDER BY Line_Item_Start_Date__c DESC];      
        
        system.debug('billingATMList ' + billingATMList);
        
        //Get all billing itens from today that aren't invoiced
        List<Billing_Contract_Line_Item__c> billingLineItemList = [Select Id, Application__c, Product__r.ProductCode, Line_Item_Start_Date__c,Billing_Period_Date__c
                                                                   From Billing_Contract_Line_Item__c 
                                                                   where Application__c IN :appNewList AND Product__r.ProductCode IN ('PT01','PT09','PT18','PT19') and Invoiced__c = False AND Line_Item_Start_Date__c >= :DATE.today()
                                                                   ]; 
        
        system.debug('billingLineItemList ' + billingLineItemList);
        
        //Key=ApplicationID Value-<Billing Contract Line Item's List
        Map<ID,List<Billing_Contract_Line_Item__c>> billingLineItemMap = new Map<ID,List<Billing_Contract_Line_Item__c>>();
        //rent billing line itens to create ATM itens
        for(Billing_Contract_Line_Item__c billingLineItem : billingLineItemList){
            if(billingLineItemMap.get( billingLineItem.Application__c) ==null){
                List<Billing_Contract_Line_Item__c> billingLineItemAuxList = new List<Billing_Contract_Line_Item__c>();
                billingLineItemAuxList.add(billingLineItem);
                billingLineItemMap.put(billingLineItem.Application__c, billingLineItemAuxList);
            }
            else{
                billingLineItemMap.get(billingLineItem.Application__c).add(billingLineItem);
            }
        }
        
        system.debug('billingLineItemMap ' + billingLineItemMap);
        
        Map<ID,List<Billing_Contract_Line_Item__c>> billingATMtoDeleteMap = new Map<ID,List<Billing_Contract_Line_Item__c>>();
        //billing ATM itens to delete
        for(Billing_Contract_Line_Item__c billingLineItem : billingATMList){
            if(billingATMtoDeleteMap.get( billingLineItem.Application__c) ==null){
                List<Billing_Contract_Line_Item__c> billingLineItemAuxList = new List<Billing_Contract_Line_Item__c>();
                billingLineItemAuxList.add(billingLineItem);
                billingATMtoDeleteMap.put(billingLineItem.Application__c, billingLineItemAuxList);
            }
            else{
                billingATMtoDeleteMap.get(billingLineItem.Application__c).add(billingLineItem);
            }
        }
        
        system.debug('billingATMtoDeleteMap ' + billingATMtoDeleteMap);

        ID prod;  
        ID productTaxCode;
        
        //Key=Application 
        Map<ID,Billing_Contract__c> billContractMap = new Map<ID,Billing_Contract__c>();
        List<Billing_Contract__c> billingContractList = [Select Id, application__c from Billing_Contract__c where application__c IN :appNewList];
        
        for(Billing_Contract__c billingContractAux : billingContractList){
            billContractMap.put(billingContractAux.application__c,billingContractAux);  
        }
        
        List<Billing_Contract_Line_Item__c> billingLineItensInsert = new List<Billing_Contract_Line_Item__c>();
        List<Billing_Contract_Line_Item__c> billingLineItensDelete = new List<Billing_Contract_Line_Item__c>();
        Bill_ProductRegion billProductRegion = new BILL_ProductRegion(); 
        
        for (Application__c appUpdated: appNewList){
            Application__c oldApp = (Application__c) appOldMap.get(appUpdated.ID);
            
            //if it's an update on the Payment Method
            System.debug('There was a change!');
            
            //changes to create:change payment from Direct Debit to ATM (There are 2nd conditions), changes on ATM_Refenrece or Changes on ATM_Reference_cost
            if((appUpdated.Payment_Method__c=='ATM Reference' && oldApp.Payment_Method__c == 'Direct Debit') || (appUpdated.ATM_Reference__c != oldApp.ATM_Reference__c) || (appUpdated.ATM_Reference_Costs__c != oldApp.ATM_Reference_Costs__c) || (appUpdated.Price_Book__c != oldApp.Price_Book__c)){ //create ATMs
                
                //Occurs when the payment changes from Direct Debit to ATM. the flag changes to True and the value is establish
                if(appUpdated.Payment_Method__c=='ATM Reference' && oldApp.Payment_Method__c == 'Direct Debit'){
                    appUpdated.ATM_Reference__c = True;
                    FundingConfig__c mc = FundingConfig__c.getInstance();                             
                    appUpdated.ATM_Reference_Costs__c = mc.ATM_Reference_costs__c;
                    String key = '' +appUpdated.Price_Book__c + clientMap.get(appUpdated.AccClient__c).c2g__CODAInputVATCode__c; 
                    appUpdated.ATM_Reference_Costs__c = pricebookATMEntreyMap.get(key);
                }
                
                if(appUpdated.Price_Book__c != oldApp.Price_Book__c){
                    String key = '' +appUpdated.Price_Book__c + clientMap.get(appUpdated.AccClient__c).c2g__CODAInputVATCode__c; 
                    appUpdated.ATM_Reference_Costs__c = pricebookATMEntreyMap.get(key);
                }
                
                //The app can have the Payment Method ATM Reference but if the value is 0 or the checkbox is false it won't create any ATM 
                if((appUpdated.ATM_Reference_Costs__c != 0) && (appUpdated.ATM_Reference__c)){
                    
                    //2nd validation: validate if there are ATMs already created and there aren't changes on ATM_Referemce e ATM_Reference_Costs
                    if((billingATMList.size()==0)  || (appUpdated.ATM_Reference__c != oldApp.ATM_Reference__c) || (appUpdated.ATM_Reference_Costs__c != oldApp.ATM_Reference_Costs__c)){ 
                        System.debug('Queries: '+ Limits.getQueries());
                        String region = clientMap.get(appUpdated.AccClient__c).Tax_Zone__c; 
                        prod = billProductRegion.getProduct('PT03', region);
                        productTaxCode = billProductRegion.getTaxCode('PT03', region);
                        List<Billing_Contract_Line_Item__c> billLineItemList = billingLineItemMap.get(appUpdated.Id);
                        if(billLineItemList != null && billLineItemList.size()>0){
                            for(Billing_Contract_Line_Item__c billItemAux : billLineItemList){
                                Billing_Contract_Line_Item__c billAtmToAdd = BILL_BillingProcess.createOneBillLineItem(billContractMap.get(appUpdated.Id).Id, appUpdated,billItemAux.Line_Item_Start_Date__c, billItemAux.Billing_Period_Date__c ,prod, appUpdated.ATM_Reference_Costs__c, productTaxCode, billProductRegion);
                                billingLineItensInsert.add(billAtmToAdd);
                            }
                        }
                        System.debug('Queries: '+ Limits.getQueries());
                    }
                }
            }
            
            //update to delete ATM: change method payment to direct debit, uncheck atm_reference, cost=0 or change in cost
            if((appUpdated.Payment_Method__c == 'Direct Debit') || (appUpdated.ATM_Reference__c==False) || (appUpdated.ATM_Reference_Costs__c == 0) || (appUpdated.ATM_Reference_Costs__c != oldApp.ATM_Reference_Costs__c)){ //if it was ATM Reference it will delete the ATM Item associated
                System.debug('ATM DELETE');
                
                List<Billing_Contract_Line_Item__c> atmList = billingATMtoDeleteMap.get(appUpdated.Id);
                System.debug('listBillings:' +atmList);
                if(atmList!= null && atmList.size()>0){
                    billingLineItensDelete.addAll(atmList);
                }
                if(appUpdated.Payment_Method__c == 'Direct Debit'){
                    appUpdated.ATM_Reference__c = False;
                    appUpdated.ATM_Reference_Costs__c = 0;
                }
            }

        }
               
        //if there is something to delete it will delete
        if (billingLineItensDelete != null && billingLineItensDelete.size()>0){
            System.debug('billingLineItensDelete '+billingLineItensDelete);
            delete billingLineItensDelete;
        }
               
        //if there is something to insert it will insert
        if (billingLineItensInsert != null && billingLineItensInsert.size()>0){
            System.debug('billingLineItensInsert: ' + billingLineItensInsert);
            insert billingLineItensInsert;
        }
        
    }
        
    private void translate(Set<Id> newIdSet){
        System.debug('*****ApplicationTrigger --> Entrou no Translate...');
        String code;
        /*
        for( Application__c appnewid: (List<Application__c>)Trigger.new )
        {
            newids.add(appnewid.id); 
        }
        
        if(newids.isEmpty()){
            return;
        }*/
        /*
        Map<Id, application__c> appNewMap=new Map<Id, Application__c>([Select id, status__c, Client_Country_code__c, Translated_Status__c 
                                                                    from application__c 
                                                                    where id in :newIdSet]);
        */
        List<Translation__c> translate=[select Translated_Value__c, Country_Code__c, Country_Independent_Value__c from Translation__c]; 
        System.debug('ApplicationTrigger.translate --> '+translate.size()+ ' records obtidos no translate...');
        
        for(ID newId : newIdSet){
            Application__c newApp = (Application__c) Trigger.newMap.get(newId);
            // if ( a.status__c!= appnew.get(a.id).status__c){
            for(integer g=0; g< translate.size(); g++ ){
                code=newApp.Client_Country_code__c.substring(0,2);
                System.debug('newApp.Translated_Status__c inicial:'+newApp.Translated_Status__c+'     translate[g].Translated_Value__c inicial: '+translate[g].Translated_Value__c);
                if(newApp.status__c == translate[g].Country_Independent_Value__c && code ==translate[g].Country_Code__c ){
                    newApp.Translated_Status__c= translate[g].Translated_Value__c ;
                    System.debug('a.Translated_Status__c:'+newApp.Translated_Status__c+'     translate[g].Translated_Value__c: '+translate[g].Translated_Value__c);
                }
            }
            //} 
        }
        System.debug('*****ApplicationTrigger --> Saiu do Translate...');
    }//end translate method    
    
    /**************************************************************************************************/ 
	//after update  methods
    private List<Billing_Contract_Line_Item__c> deleteBillingLineItems(Set<Id> newAppIds){   
        
        System.debug('ApplicationTrigger.DeleteBillingLineItems --> newAppIds.size():'+newAppIds.size()+'...');
        if(newAppIds.size()>0)
        {
            System.debug('[Trigger - DeleteBillingLineItems] Insurance_Type__c changed to "Own Insurance" going to delete Billing Contracts Line Items with product code PT11 or PT02');            
            List<Billing_Contract_Line_Item__c> listBcliToDelete = [SELECT ID FROM Billing_Contract_Line_Item__c 
                                                                    WHERE Application__c IN :newAppIds 
                                                                    AND Line_Item_Start_Date__c >TODAY 
                                                                    AND Invoiced__c != TRUE 
                                                                    AND Product__r.ProductCode IN ('PT11', 'PT02')];
            
                return listBcliToDelete;
        }else{
            return null;
        }
    }//end DeleteBillingLineItems method
    
    private void UpdateIBAN(Set<Id> newidSet){
        System.debug('*****ApplicationTrigger --> Entrou no UpdateIBAN...');
        List<Account>accs  = new List<Account>();
      	/*
        Map<Id, application__c> appnew=new Map<Id, application__c>([Select id, Client_BBAN__c,Client_Country_Code__c , AccCLient__c 
                                                                    from application__c 
                                                                    where id in :newidSet]);
        
        */
        //System.debug('ApplicationTrigger.UpdateIBAN --> Obteve '+appnew.size()+' Apps...');
        
        //for(Application__c a: (List<Application__c>)Trigger.old){
        for(ID newAppID : newidSet){
            Application__c oldApp = (Application__c) Trigger.oldMap.get(newAppID);
            Application__c newApp = (Application__c) Trigger.newMap.get(newAppID) ;
            
            Account accClient= [Select Id, Name 
                                From Account 
                                where id =: newApp.AccCLient__c]; //appnew.get(a.id).AccCLient__c ];
            
            if(accClient!=null){
                System.debug('ApplicationTrigger.UpdateIBAN --> Obteve Account...');
                accClient.BBAN__c = newApp.Client_BBAN__c; //appnew.get(a.id).Client_BBAN__c;
                accClient.c2g__CODABankIBANNumber__c = oldApp.Client_Country_Code__c + newApp.Client_BBAN__c; //a.Client_Country_Code__c + appnew.get(a.id).Client_BBAN__c;
                accs.add(accClient);
            }
        }
        if(!accs.isEmpty()){
            System.debug('ApplicationTrigger.UpdateIBAN --> Vai fazer update a '+ accs.size()+' Account(s)...');
            update accs;
            System.debug('ApplicationTrigger.UpdateIBAN --> Fez os updates nas accs...');
        }
        System.debug('*****ApplicationTrigger --> Saiu do UpdateIBAN...');
    }//end UpdateIBAN method
    

    /*private boolean shouldUpdateAppsDecision(Application__c newApp, Application__c oldApp){

        boolean has_decison_but_no_status = newApp.Decision__c != null && newApp.Status__c == null;
        boolean decision_has_changed = newApp.Decision__c != oldApp.Decision__c;
        boolean contract_was_sent = newApp.Contract_Sent__c != null  && newApp.Invoice_Payment_Date__c != null; //newApp.Invoice_Payment_Date__c != null para assegurar que n se alteram contratos fechados
        System.debug('beforeUpdate has_decison_but_no_status: ' + has_decison_but_no_status);
        System.debug('beforeUpdate decision_has_changed: ' + decision_has_changed);
        System.debug('beforeUpdate has_contract_settle: ' + contract_was_sent);

        return (has_decison_but_no_status || decision_has_changed ) && !contract_was_sent;
    }//end shouldUpdateAppsDecision method

    /*private void setNewDecisions(List<Application__c> appList, Set<Id> clientAccIDset){

        Map<Id, Decision__c> accountID_decision_map = new  Map<Id, Decision__c>();
        List<Decision__c> decisionsList = [SELECT ID, Guidance_Limit_Max__c, Decison_Status__c, Account__r.Credit_line__c, 
            Account__r.Available_Credit_Line__c, Account__r.Used_Credit_Line__c, Account__r.Credit_Line_Status__c, 
            Sub_Grade__c, Grade__c, Account__c,Account__r.BillingCountryCode, Account__r.Personal_Guarantee__c, 
            Credit_info__r.Last_Request_Status__c, Override__c,  
            (SELECT Id, Personal_Guarantee__c FROM Decision_Conditions_Card_History__r ORDER BY CreatedDate DESC NULLS LAST LIMIT 1)
            FROM Decision__c WHERE Account__c IN:clientAccIDset];
            
            System.debug('before Update -> decisionsList size: ' + decisionsList.size());
            System.debug('before Update -> decisionsList: ' + decisionsList);
            for(Decision__c dec : decisionsList){
                accountID_decision_map.put(dec.Account__c, dec);
            }

            Decision__c decision;
            List<Application__c> appListAux = new List<Application__c>();
            SC_RelatedApplication relatedApp = new SC_RelatedApplication();
            for(Application__c app : appList){
                decision = accountID_decision_map.get(app.AccClient__c);
                if( decision != null && app.Invoice_Payment_Date__c == null){
                    app = relatedApp.getAppWithAllInfoFromDecision(app, decision);   
                }       
            }

        System.debug('before update -> number of newApp List decisions update: ' + appList.size());
        System.debug('before update -> newApp List decisions update: ' + appList);

    }//end setNewDecisions method*/

    private void UpdateCreditLine(){        
        System.debug('*****ApplicationTrigger --> Entrou no UpdateCreditLine...');
        Application__c oldApp;
        System.debug('ApplicationTrigger.UpdateCreditLine --> '+trigger.size+' records presentes no trigger (old and new versions)...');
        for(Application__c newApp : (List<Application__c>)trigger.new){
            oldApp= (Application__c)Trigger.oldMap.get(newApp.id);
            
            if(newApp.Status__c!=oldApp.Status__c&&(newApp.Status__c == 'Contract - Running' || newApp.Status__c == 'Contract - Closed')){
                System.debug('ManagedCreditLine');
                ManagedCreditLine.updateCreditLine(newApp); 
            }            
        } 
        System.debug('*****ApplicationTrigger --> Saiu do UpdateCreditLine...');
    }//end UpdateCreditLine method
    
    private void Trigger_APP_BC_Contract_Inactive(Set<ID> statusApps)//ALTERACAO - 27/02/17 - modificacao de modo a retirar queries dos ciclos e simplificacao no codigo (BP)
    {
        System.debug('*****ApplicationTrigger --> Entrou no Trigger_APP_BC_Contract_Inactive...');
        Application__c oldApp;
        List<Billing_Contract__c> BCStoUpdate= new List<Billing_Contract__c>();
        
        List<Billing_Contract__c> BcsFiredApps = [SELECT BC_Contract_Inactive__c,Application__c FROM Billing_Contract__c WHERE Application__c in :statusApps];
        
        if(BcsFiredApps.size()>0)
        {
            System.debug('[Trigger_APP_BC_Contract_Inactive] app.Status__c changed, updating Billing_Contract:');
            for(Billing_Contract__c newBc:BcsFiredApps)
            {
                newBc.Bc_Contract_Inactive__c=true;
                BCStoUpdate.add(newBc);
            }
            update BCStoUpdate;
        }
        System.debug('ApplicationTrigger.Trigger_APP_BC_Contract_Inactive --> Update a '+BCStoUpdate.size()+' BCS');
        System.debug('*****ApplicationTrigger --> Saiu do Trigger_APP_BC_Contract_Inactive...');
    }// end Trigger_APP_BC_Contract_Inactive method
    
    private List<Collection_Case__c> collectionCaseChangeAppLawsuit(Set<ID> statusApps){
        //Application__c validaStatus = Trigger.new.get(0);
        List<Collection_Case__c> m_CollectionsCase = new List<Collection_Case__c>();
        
        for(Billing_Contract__c bc: [Select id, Collection_Case__c from Billing_Contract__c where Application__r.Id in :statusApps ]){
            System.debug('bc.Collection_Case__c ' + bc.Collection_Case__c);
            if(bc.Collection_Case__c != null){
                Collection_Case__c cc = new Collection_Case__c();
                cc.Id = bc.Collection_Case__c;
                cc.Status__c = 'Legal';
                m_CollectionsCase.add(cc);   
            }
        }
        
        if(!m_CollectionsCase.isEmpty()){
            return m_CollectionsCase; 
        }else{
            return null;
        }       
    }
    
    private List<Application__c> calcAnnualInterestRate(Set<Id> newids){
        System.debug('*****ApplicationTrigger --> Entrou no CalcAnnualInterestRate...');
        List<Application__c> appsToUpdate= new List<Application__c>();
      
        Map<Id, application__c> appnew=new Map<Id, application__c>([Select id, Equipment_Cost__c, Payment_Amount__c, TermCalc__c, Annual_Interest_Rate__c, Status__c, Payment_Freq__c, Payment_Timing__c from application__c where id in :newids]);
        for(application__c a: (List<Application__c>)Trigger.old){
            /*if((a.Equipment_Cost__c != appnew.get(a.id).Equipment_Cost__c || a.Payment_Amount__c != appnew.get(a.id).Payment_Amount__c 
                ||a.TermCalc__c != appnew.get(a.id).TermCalc__c ) && ( appnew.get(a.id).Equipment_Cost__c !=0 && appnew.get(a.id).Payment_Amount__c !=0 &&
                                                                      appnew.get(a.id).TermCalc__c !=null ) ){
                 */
                double paymnt=  appnew.get(a.id).Payment_Amount__c;
                double nrpay=  appnew.get(a.id).TermCalc__c;  
                integer npaymentByYear=12;
                integer begEndpay=0;

                if(appnew.get(a.id).Payment_Freq__c=='Quarterly'){ 
                    nrpay=nrpay/3;
                    paymnt=paymnt*3;
                    npaymentByYear=4;
                }
                if(appnew.get(a.id).Payment_Timing__c=='Advanced'){
                    begEndpay=1;
                }

                double amount=appnew.get(a.id).Equipment_Cost__c;

                appnew.get(a.id).Annual_Interest_Rate__c=Financial.AnnualInterestRate(nrpay, paymnt, amount, npaymentByYear, begEndpay, false);
                appsToUpdate.add(appnew.get(a.id)); 
            //}
        }
        System.debug('*****ApplicationTrigger --> Saiu do CalcAnnualInterestRate...');    
        return appsToUpdate;

    }//end CalcAnnualInterestRate method
   
    private void sendEmailDecision(){
       /* if(!isProcessing){
            isProcessing=true;

        }*/
        System.debug('!!!!!!!!!!!!!!!Entra no sendEmail !!!!!!!!!!!!!!!!!');
        Set<Application__c> siapp= new Set<Application__c>();
        Application__c oldapp;
        Map<Application__c,List<Contact>> mapAppConts = new Map<Application__c,List<Contact>>();
        for (Application__c newApp : (List<Application__c>)Trigger.new){
            System.debug('[ApplicationTriggerHandler].SendDecisionEmails --> newapp: '+newApp);
            oldapp = (Application__c)Trigger.oldMap.get(newApp.Id);
            if((newApp.Status__c!='' && newApp.Status__c!=null && oldapp.Status__c!=newApp.Status__c) || 
               (newApp.Translated_Status__c != null && oldapp.Client_Available_Credit_Line__c==0 && newapp.Client_Available_Credit_Line__c>0)
              )
            {
                siapp.add(newApp);
            }   
        }
        
        if(siapp.isEmpty()){
            return;
        }
        
        
        System.debug('[ApplicationTriggerHandler].SendDecisionEmails --> siapp: '+siapp);
        for(Application__c app : siapp){
            List<AggregateResult> vendors = [select Vendor_Vendor__c vendor from Login__c 
                                             where (Inactive__c!=true and Master__c=true and IdVendor__c = :app.Vendor__c) GROUP BY Vendor_Vendor__c];
            

            Set<Id> vendorId= new Set<Id>();
            for(AggregateResult l : vendors){
                vendorId.add((Id)l.get('vendor'));
            }
            //if(app.IdLoginCreate__c!=null)
            vendorId.add(app.Vendor_Primary__c);
            System.debug('[ApplicationTriggerHandler].SendDecisionEmails --> ID do criador'+app.IdLoginCreate__r.Vendor_Vendor__c+' account ID: '+app.Vendor__c);

            List<Contact> conts = [select Id, Email, Account.Id from Contact where  Account.Id = :app.Vendor__c and Id in :vendorId];
            System.debug('[ApplicationTriggerHandler].SendDecisionEmails --> vendors filter: '+conts);

            mapAppConts.put(app,conts);
            ChooseWise(app,mapAppConts);
        }
    }

    private void ChooseWise(Application__c app,  Map<Application__c,List<Contact>> mapAppConts){
        List<String> le = new List<String>();
        List<Contact> conts = mapAppConts.get(app);

        for(Contact c : conts)
        {
            le.add(c.Email);
        }

        System.debug('!!!!!!![ApplicationTriggerHandler].ChooseWise --> le: '+le);
        system.debug(' ' + app.Translated_Status__c + ' ' + app.Client_Available_Credit_Line__c + ' ' + app.Status__c );
        
        if(le.size()==0){
            System.debug('[ApplicationTriggerHandler].ChooseWise --> Lista de emails do vendor vazia -> size: '+le.size());
            return;
        }
        
        if(app.Translated_Status__c != null && app.Status__c == 'Application - Approved' && app.Client_Available_Credit_Line__c>0 && app.Cancelled__c == false )
        {
            System.debug('[ApplicationTriggerHandler].ChooseWise --> dentro do if Application_Decision_Approved le:'+le);
            Utilities.sendTemplatedEmail(le,'Application_Decision_Approved',conts[0].Id,app.Id,true);
        }
        if(app.Status__c =='Application - Pendent' && app.Cancelled__c == false)
        {
            System.debug('[ApplicationTriggerHandler].ChooseWise --> dentro do if Application_Decision_Pendent le:'+le);
            Utilities.sendTemplatedEmail(le,'Application_Decision_Pendent',conts[0].Id,app.Id,true);        
        }
        if(app.Status__c =='Application - Rejected' && app.Cancelled__c == false)
        {
            System.debug('[ApplicationTriggerHandler].ChooseWise --> dentro do if Application_Decision_Rejected le:'+le);
            Utilities.sendTemplatedEmail(le,'Application_Decision_Rejected',conts[0].Id,app.Id,true);
        }
    }

    webservice static String changePaymentMethod_WS(Id billingContractId){

        Billing_Contract__c billingContract = [Select Id, Application__c from Billing_Contract__c where id = :billingContractId];
        
        Application__c app = [Select ID, Payment_Method__c,Status__c,ATM_Reference_Costs__c,ATM_Reference__c from Application__c where id = :billingContract.Application__c];
        
       /* if(app.Status__c != 'Contract - Running'){ //todo check others status 
            return 'Failed! Application ' + app.Id + ' is in status ' + app.Status__c;
        }*/
        
        /*Map<Id,SObject> appOldMap = new Map<Id,SObject>();
        appOldMap.put(appId, app);*/
        
        if(app.Payment_Method__c == 'Direct Debit'){
            app.Payment_Method__c = 'ATM Reference';
        }
        else{
            app.Payment_Method__c = 'Direct Debit';
        }
        System.debug('Before Update');
        update app;
        System.debug('After Update');

        return 'Sucess! Payment method changed to ' + app.Payment_Method__c;
    }

    /*
    private void AddInsuranceBclis ()
    {
        System.debug('*****ApplicationTrigger --> Entrou no addInsuranceBclis...');
        if(ApplicationTriggerLockers.get_firstRun_addInsuranceBclis())
        {    
            Application__c  oldApp;
            decimal         valueOfInsurance=0;
            ID              getProdID       =null;
            string          Region          ='';
            
            List<Billing_Contract_Line_Item__c> bclisToDuplicate = new List<Billing_Contract_Line_Item__c>();
            List<Billing_Contract_Line_Item__c> insuranceBclis   = new List<Billing_Contract_Line_Item__c>();
            
            Account client;
            
            list <PostCode__c> Postcod=[SELECT CP_Max__c, CP_Min__c, Region__c //TODO PostCode__c vai deixar de ser usado
                                          FROM postcode__c 
                                         WHERE Region__c != null];
            
            List<Product2> prods_PT02 =[SELECT id,ProductCode,c2g__CODAInputTaxCode__c , c2g__CODAInputTaxCode__r.Area__c
                                          FROM Product2 
                                         WHERE ProductCode='PT02'];
            
            System.debug('ApplicationTrigger.addInsuranceBCLIS --> valores de trigger.new: '+trigger.new);
            System.debug('ApplicationTrigger.addInsuranceBCLIS --> valores de trigger.oldMap: '+trigger.oldMap);
            
            for(Application__c newApp: (List<Application__c>)trigger.new)
            {                               
                oldApp= (Application__c)trigger.oldMap.get(newApp.Id);           
                System.debug('ApplicationTrigger.addInsuranceBCLIS --> oldApp: '+oldApp);
                System.debug('ApplicationTrigger.addInsuranceBCLIS --> newApp: '+newApp);            
                System.debug('ApplicationTrigger.addInsuranceBCLIS --> old: '   +oldApp.Insurance_Type__c);
                System.debug('ApplicationTrigger.addInsuranceBCLIS --> new: '   +newApp.Insurance_Type__c);
                
                if(oldApp.Insurance_Type__c=='Own Insurance' && newApp.Insurance_Type__c!='Own Insurance')
                {
                    if(Limits.getDMLStatements()<Limits.getLimitDmlStatements()/2)
                    {
                        ApplicationTriggerLockers.setFAlSE_firstRun_addInsuranceBclis();
                        client=[SELECT id,name,BillingPostalCode 
                                  FROM Account
                                 WHERE id=:newApp.AccClient__c LIMIT 1];
                        
                        if(client!=null)
                        {
                            for (integer l=0; l<Postcod.size(); l++)
                            {
                                if(client.BillingPostalCode > Postcod[l].CP_MIN__C && client.BillingPostalCode < Postcod[l].CP_MAX__c) //TODO vai deixar de ser usado o postcode__c
                                {
                                    Region=Postcod[l].Region__C;
                                }
                            }
                        }
                        
                        bclisToDuplicate=[SELECT Name,Product__c,Sales_Price__c,Line_Item_Start_Date__c,
                                          Line_Item_End_Date__c,product__r.ProductCode,Billing_Contract__c
                                          FROM Billing_Contract_Line_Item__c
                                          WHERE product__r.ProductCode IN ('PT01','PT09')
                                          AND Application__c=:newApp.Id
                                          AND Line_Item_Start_Date__c>TODAY];
                        }
                        
                        for(Product2 prod: prods_PT02)
                        {
                            if(prod.c2g__CODAInputTaxCode__r.Area__c==Region)getProdID=prod.id; 
                        }
                        
                        if(bclisToDuplicate.size()>0)
                        {
                            for(integer i=0;i<bclisToDuplicate.size();i++){
                                if(newApp.Payment_Freq__c=='Monthly')valueOfInsurance = newApp.Chosen_Insurance_value__c;
                                else valueOfInsurance = newApp.Chosen_Insurance_value__c*3; 
                                
                                Billing_Contract_Line_Item__c newBCLI=bclisToDuplicate[i];
                                newBCLI.id                  = null; newBCLI.Sales_Price__c = valueOfInsurance;
                                newBCLI.Ending_Balance__c   = newBCLI.Beginning_Balance__c = newBCLI.Interest__c =  newBCLI.Principal__c = null;
                                newBCLI.Application__c      = newApp.id; newBCLI.Product__c= getProdID;                                         
                                insuranceBclis.add(newBCLI);
                            }
                        }
                    }
                }
                insert insuranceBclis;
        
                }
                System.debug('ApplicationTrigger.addInsuranceBCLIS --> oldMap size: '       +trigger.oldMap.size());
                System.debug('ApplicationTrigger.addInsuranceBCLIS --> trigger.new size: ' +trigger.new.size());
                System.debug('*****ApplicationTrigger --> Saiu do addInsuranceBclis...');
    }//end addInsuranceBclis method
    */
  
    /*****
    private void Candor_Trigger_APP_ACC_Signer1email_to_invoiceEmail()
    {
        System.debug(LoggingLevel.INFO,'[Candor_Trigger_APP_ACC_Signer1email_to_invoiceEmail] called.');
        
        Datetime startDatetime = Datetime.now();
        List<Account> updatedList = new List<Account>();
        
        Set<Application__c> Apps = New Set<Application__c>();
        Set<ID> Accs = New Set<ID>();
        Set<ID> signers1 = New Set<ID>();
        
        for( Application__c app : (List<Application__c>)Trigger.new){
            Apps.add(app);
            Accs.add(app.AccClient__c);
            signers1.add(app.Client_Signer_1__c);
        }
        
        Map<ID, Account> accountList = new Map<ID, Account>([SELECT Id, Name, c2g__CODAInvoiceEmail__c FROM Account WHERE ID IN :Accs]);
        
        Map<ID, Contact> ContactClientSigner1cList = new Map<ID, Contact>([SELECT Id, Email FROM Contact WHERE ID IN :signers1]);
        
        Integer countExceptions = 0;
        
        for( Application__c appName : Apps){
            
            if(accountList.get(appName.AccClient__c) == null){
                System.debug(LoggingLevel.INFO,'CR_TR_Signer1email_to_invoiceEmail app: ' + appName.Name + ' No Account Client Found!?');
                countExceptions++;if(countExceptions < 10){ // currently the logger is counting for the covernor limits of soql writes
                    Utilities.LogIntegration(startDatetime, Datetime.now(), 'Error', 'Candor_Trigger_APP_ACC_Signer1email_to_invoiceEmail', ' No Client Account in App?', appName.Id);
                }
                continue;
            }
            
            if(accountList.get(appName.AccClient__c) != null && accountList.get(appName.AccClient__c).c2g__CODAInvoiceEmail__c != null && accountList.get(appName.AccClient__c).c2g__CODAInvoiceEmail__c != ''){
                System.debug(LoggingLevel.INFO,'CR_TR_Signer1email_to_invoiceEmail app: ' + appName.Name + ' going to next App, c2g__CODAInvoiceEmail__c is already set, accountList.get(appName.AccClient__c).c2g__CODAInvoiceEmail__c: ' + accountList.get(appName.AccClient__c).c2g__CODAInvoiceEmail__c);
                continue;
            }
            
            try{
                
                if(ContactClientSigner1cList.get(appName.Client_Signer_1__c) != null && ContactClientSigner1cList.get(appName.Client_Signer_1__c).Email != null && ContactClientSigner1cList.get(appName.Client_Signer_1__c).Email != ''){
                    System.debug(LoggingLevel.INFO,'[Candor_Trigger_APP_ACC_Signer1email_to_invoiceEmail] app: ' + appName.Name + ' app.Client_Signer_1__c.Email changed and Account: ' + accountList.get(appName.AccClient__c).Name + ' Account.c2g__CODAInvoiceEmail__c not filled, updating Account with email: ' + ContactClientSigner1cList.get(appName.Client_Signer_1__c).Email);
                    accountList.get(appName.AccClient__c).c2g__CODAInvoiceEmail__c = ContactClientSigner1cList.get(appName.Client_Signer_1__c).Email;
                    updatedList.add(accountList.get(appName.AccClient__c)); 
                }
            } catch (Exception e){countExceptions++;if(countExceptions < 10){ 
                Utilities.LogIntegration(startDatetime, Datetime.now(), 'Error', 'Candor_Trigger_APP_ACC_Signer1email_to_invoiceEmail', ' Exception: ' + e.getMessage(), appName.Id);
            }// currently the logger is counting for the covernor limits of soql writes
                                 }
        }
        if(updatedList.size() > 0){
            System.debug(LoggingLevel.INFO,'CR_TR_Signer1email_to_invoiceEmail going to update accounts in updatedList.size(): ' + updatedList.size());
            update updatedList;    
        }else{
            System.debug(LoggingLevel.INFO,'CR_TR_Signer1email_to_invoiceEmail no Accounts to update.');
        }
    }//end Candor_Trigger_APP_ACC_Signer1email_to_invoiceEmail method
    
    *****/

    private void sendEmail(String emailAdress, String subject, String emailBody){
        String[] toAddresses = new List<String>(); 
        toAddresses.add(emailAdress);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);  
        email.setToAddresses(toAddresses); 
        email.setUseSignature(false);
        email.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

    //Devolve as contas em que vai ser feito um primeiro update do Application__c.status__c para "Contract-Running"
    @TestVisible
    private List<Account> getFirstContractAccounts(Map<Id, Account> vendorMap){
        List<Account> firstContractVendorAccList = new List<Account>();
         for(Application__c newApp : (List<Application__c>)Trigger.new){
            Account vendor = new Account();
            vendor = vendorMap.get(newApp.Vendor__c);
            if(newApp.Status__c == 'Contract - Running' && !vendor.First_Application__c){
                vendor.First_Application__c = true;
                firstContractVendorAccList.add(vendor);
            }
         }
         System.debug('[ApplicationTriggerHAndler] - getFirstContractAccounts() -> first Contract vendor Account list size -> firstContractVendorAccList.Size()');
         return firstContractVendorAccList; 
    }
    /*
    private void ChangeInsuranceBCLIS()
    {
        System.debug('*****ApplicationTrigger --> Entrou no ChangeInsuranceBCLIS...');
        Application__c oldApp;
        List<Billing_Contract_Line_Item__c> changeableBCLIS = new List<Billing_Contract_Line_Item__c>();
        List<Billing_Contract_Line_Item__c> BCLIStoUpdate   = new List<Billing_Contract_Line_Item__c>();
        List<Billing_Contract_Line_Item__c> firstBCLI       = new List<Billing_Contract_Line_Item__c>(); 
        //List<Application__c>              AppsToUpdate    = new List<Application__c>();
        decimal valueOfInsurance=0;
        String prepareValue='';
        String riskType='';
        Application__c newApp1;
        
        for(Application__c newApp: (List<Application__c>)Trigger.new)
        {
            oldApp=(Application__c)(Trigger.oldMap.get(newApp.Id));
            if(oldApp.Insurance_Type__c!='Own Insurance' && newApp.Insurance_Type__c!='Own Insurance' && oldApp.Insurance_Type__c!= newApp.Insurance_type__c)
            {
                if(Limits.getDMLStatements()<Limits.getLimitDmlStatements()/4)
                {
                        changeableBCLIS=[SELECT ID,Line_Item_Start_Date__c,Sales_Price__c,Application__c,Product__r.ProductCode
                                           FROM Billing_Contract_Line_Item__c 
                                          WHERE Application__c=:newApp.Id
                                            AND Product__r.ProductCode ='PT02'
                                            AND Line_Item_Start_Date__c>TODAY
                                       ORDER BY Line_Item_Start_Date__c DESC];
                    
                              firstBCLI=[SELECT ID,Line_Item_Start_Date__c,Application__c,Product__r.ProductCode,Beginning_Balance__c
                                           FROM Billing_Contract_Line_Item__c 
                                          WHERE Application__c=:newApp.Id
                                            AND Product__r.ProductCode in ('PT01','PT09')
                                            AND Line_Item_Start_Date__c>TODAY
                                       ORDER BY Line_Item_Start_Date__c ASC LIMIT 1];
                    
                           prepareValue=[SELECT ID,Discount_Factor__c FROM Account WHERE id=:newApp.Vendor__c LIMIT 1].Discount_Factor__c; 
                        
                           newApp1=[SELECT Vendor_Diluted_Doc_Fee__c,Payment_Freq__c,accClient__r.Risk_Type__c FROM Application__c WHERE id=: newApp.Id LIMIT 1]; 
                }
                System.debug('app.accClient__c:'+newapp.accClient__c +' app.accClient__r.Risk_Type__c: '+newapp.accClient__r.Risk_Type__c );
                System.debug('ApplicationTrigger.ChangeInsuranceBCLIS --> changeableBCLIS.size(): '+changeableBCLIS.size()+'        firstBCLI.size(): '+firstBCLI.size());
                System.debug('ApplicationTrigger.ChangeInsuranceBCLIS --> prepareValue: '+prepareValue);
                prepareValue= prepareValue.replace(',','.');
                Decimal auxVendorDiscFactor= Decimal.valueOf(prepareValue.substringBefore('%'));
                System.debug('ApplicationTrigger.ChangeInsuranceBCLIS --> prepareValue:'+prepareValue+' auxVendorDiscFactor:'+auxVendorDiscFactor);
                System.debug('newApp.Output_Rate_Manager__c:'+newApp.Output_Rate_Manager__c);
                
                if(firstBCLI.size()>0)
                    ScoreCardConfig.getCalc(newApp1,firstBCLI[0].Beginning_Balance__c,(integer)newApp.TermCalc__c,auxVendorDiscFactor);
                else 
                    ScoreCardConfig.getCalc(newApp1,newApp.Equipment_Cost__c,(integer)newApp.TermCalc__c,auxVendorDiscFactor);
                System.debug('newApp.Output_Rate_Manager__c after:'+newApp.Output_Rate_Manager__c);
                for(Billing_Contract_Line_Item__c newBCLI:changeableBCLIS)
                {
                    if(newApp.Payment_Freq__c=='Monthly')valueOfInsurance = newApp.Chosen_Insurance_value__c;
                    else valueOfInsurance = newApp.Chosen_Insurance_value__c*3; 
                    
                    newBCLI.Sales_Price__c=valueOfInsurance;
                    //newApp.Output_Rate_Manager__c='Pick Contract Term: 12: €' + newApp.Rent_12__c + '; 24: €' + newApp.Rent_24__c + '; 36: €' + newApp.Rent_36__c + '; 48: €' + newApp.Rent_48__c+ '; 60: €' + newApp.Rent_60__c +';'; 
                    BCLIStoUpdate.add(newBCLI);
                    //AppsToUpdate.add(newApp);
                }
            }
        }
        //update AppsToUpdate;
        update BCLIStoUpdate;  
        System.debug('ApplicationTrigger.ChangeInsuranceBCLIS --> Feitos updates a '+BCLIStoUpdate.size()+' BCLIS...');
        System.debug('*****ApplicationTrigger --> Saiu do ChangeInsuranceBCLIS...');
    }//end ChangeInsuranceBCLIS method
    */
}