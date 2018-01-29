public class RentingApplication {

    private ID appID;
    private Application__c application;
    private static final String CONTRACT_RENTING_NAME = 'RENTING';
    private static final String AUTO_NAME = 'AUTO'; 
    private static final String DELETE_NAME = 'DELETE';    

    public RentingApplication(ID appID){
        this.appID = appID;
        this.application = getInfo();
    }

    public Application__c getInfo(){

        Application__c app = [SELECT Id, Name, Application_Date__c, Status__c, AccClient__c, Vendor__r.c2g__CODAOutputVATCode__c, AccClient__r.c2g__CODAInputVATCode__c,Client_Forma_Obrigar_Val__c,    
                             Vendor__c, IdLoginCreate__c,IdLoginCreate__r.Master__c, IdLoginCreate__r.IdVendor__c, Equipment_Cost__c, Contract_Signed__c, Invoice_Payment_Date__c, Delivery_Certificate_Signed__c, 
                             Equipment_Delivery_Date__c, Issuing_Date_Invoice__c, Output_Rate_Manager__c, Term__c, Contract_Sent__c,
                             Payment_Amount__c, Output_Ins_Manager__c, Insurance_Value__c, Insurance_Movement_value__c, TermSetByUser__c, 
                             Paper_Contract__c, eSignature_Contract__c, Insurance_Type__c, Delivery_Certificate_Sent__c, Vendor__r.Term_12__c, Vendor__r.Term_24__c, 
                             Vendor__r.Term_36__c, Vendor__r.Term_48__c, Vendor__r.Term_60__c, Vendor__r.Term_72__c,
                             Available_Credit_Line__c, AccClient__r.Risk_Type__c, AccClient__r.Name, Vendor_Diluted_Doc_Interim_fee__c,
                             Vendor_Primary__r.Name, Vendor_Primary__r.Description, Vendor_Primary__r.email, Candor_Signer__r.email, Candor_Signer__r.Name, 
                             Candor_Signer__r.Title, Insurance_Special_Value__c, Payment_Freq__c, AccClient__r.NIF__c, AccClient__r.Available_Credit_Line__c,
                             AccClient__r.BillingStreet, AccClient__r.BillingPostalCode,AccClient__r.BillingCity,Rent_12__c, Rent_24__c, Rent_36__c, Rent_48__c,
                             Rent_60__c, Rent_72__c, Client_Signer_1__c,Client_Signer_2__c,Client_Signer_4__c,Client_Signer_5__c, Client_Signer_3__c, AccClient__r.c2g__CODABankIBANNumber__c, ATM_Reference_Costs__c,
                             Payment_Method__c, Observations__c, Client_Forma_Obriga__c, Vendor_Diluted_Doc_Fee__c, eSignature_Contract_Fee__c, Vendor__r.c2g__CODABankIBANNumber__c, 
                             Client_Signer_1_Delivery_Certificate__c, TermCalc__c, AccClient__r.Date_Of_Establishment__c , AccClient__r.Credit_line__c, Reject_Reason__c,Client_Signer_1__r.Email,
                             Client_Signer_2__r.Email, Client_Signer_3__r.Email, Client_Signer_4__r.Email, Client_Signer_5__r.Email, Client_Signer_1_Delivery_Certificate__r.Email, Cancelled__c,
	                         Client_Signer_1_Delivery_Certificate__r.Name , Client_Signer_1_Delivery_Certificate__r.Description, Credit_Suspended__c,
                             Vendor__r.Discount_Factor__c,ScoreCard__c, Personal_Guarantee__c, AccClient__r.Account_Status__c, AccClient__r.Credit_Line_Status__c
                             FROM Application__c WHERE Id =: appId  ORDER BY Application_Date__c DESC];
        //aterado AAFL 31/07/2017
        //colocar o custo vindo da custom settings se ATM_REFERENCE_COSTS__C = NULL;
        if(app.ATM_Reference_Costs__c == null || app.ATM_Reference_Costs__c == 0){
            FundingConfig__c mc = FundingConfig__c.getInstance();                             
            app.ATM_Reference_Costs__c = mc.ATM_Reference_costs__c; 
        }

        boolean isStartup = false;
        if(app.AccClient__r.Date_Of_Establishment__c!=null && app.AccClient__r.Date_Of_Establishment__c.daysBetween(date.today())/365 < ScoreCardConfig.getStartupMaxAge()){
            isStartup = true;
        }

        if (isStartup) { //Startup only goes with 12 and 24 term duration

            app.Vendor__r.Term_36__c = null;
            app.Vendor__r.Term_48__c = null;
            app.Vendor__r.Term_60__c = null;           
            app.Vendor__r.Term_72__c = null;           

        }
        
        return app;
    }

    //Criado AAFL 31/07/2017
    public Application__c getAppSObject(){
        return this.application;
    }

    public map<string, object> CalcPayments(decimal amount){

        string result = ScoreCardConfig.GetScoreCardRate(appID, amount);
        
        if(result != 'Success'){
            System.debug('[RentingApplication - CalcPayments]: ERROR, ScoreCardConfig.GetScoreCardRate returned ' + result +' for ' + appID );
        }else{
            System.debug('[RentingApplication - CalcPayments]: SUCCESS calculating rents for application with ID ' + appID);
        }

        return getRents_deprecated();
    } 

    //Metodo temporario para termos os dois algorimtos de decisão em simultaneo
    public Application__c CalcPayments(Rents.Selected selectedRent, String Type_of_Change, boolean calcOpValueFromAmount){
        
        if(application.ScoreCard__c != null ){

            if(application.TermCalc__c!= null){

                if(selectedRent.term    != null && Type_of_Change == 'term'){
                    Application__c app = new Application__c(Id = application.id, Term__c = String.valueOf(selectedRent.term),Payment_Amount__c = selectedRent.rent, TermCalc__c=selectedRent.term, TermSetByUser__c = true);
                    update app;
                }
                
                if(selectedRent.doc_fee != null && Type_of_Change == 'doc_fee'){
                    Application__c app = new Application__c(Id = application.id, Vendor_Diluted_Doc_Fee__c = selectedRent.doc_fee);
                    update app;
                }

                if(selectedRent.freq    != null && Type_of_Change == 'freq'){
                    Application__c app = new Application__c(Id = application.id, Payment_Freq__c = selectedRent.freq);
                    update app; 
                }
            }

            if(calcOpValueFromAmount == true){ 
                String res = ScoreCardConfig.GetScoreCardRateFromAmount(application.Id, selectedRent.rent, selectedRent.term);     
            }else{
                String res = ScoreCardConfig.GetScoreCardRate(application.Id, selectedRent.opValue);     
            }
        }

        return getInfo();
    
    }

    public boolean setPayments(Rents.Selected selectedRent){

        if(application.ScoreCard__c==null){
            System.debug('SetPayments selectedRent '+selectedRent);
            String factorType = selectedRent.doc_fee == true ? 'Standard': 'Diluted';
            Decision__c decision = [SELECT ID, Grade__c, Sub_Grade__c FROM Decision__c WHERE Account__c =:application.AccClient__c AND Active__c = true ORDER BY Createddate DESC LIMIT 1];    
            Decimal monthlyFee = selectedRent.freq == BILL_BillingProcess.PAYMENT_FREQ_MONTHLY ? [SELECT Monthly_Fee__c FROM Credit_Decisions_Settings__mdt WHERE DeveloperName = 'PT'].Monthly_Fee__c : 0;
			System.debug('monthlyFee ' + monthlyFee + ' selectedRent.freq->'+selectedRent.freq);
            Rents rents = new Rents(decision.Grade__c, decision.Sub_Grade__c, factorType, monthlyFee,'PT');

            boolean updateRentsResult = rents.updateApplicationRent(appId, selectedRent);

            if(updateRentsResult) 
                return updateInsuranceValues(selectedRent.opValue);

            return updateRentsResult;
        }

        return true;
    } 

    public boolean updateInsuranceValues(Decimal amount){

        Application__c app = new Application__c();
        app.Id = appID;
        app.Insurance_Value__c = SC_Insurance_Factorcard.getInsuranceValue(application.AccClient__c, 'PT', amount, 'Static');
        app.Insurance_Movement_value__c = SC_Insurance_Factorcard.getInsuranceValue(application.AccClient__c, 'PT', amount, 'Movement');
        app.Insurance_Special_Value__c = SC_Insurance_Factorcard.getInsuranceValue(application.AccClient__c, 'PT', amount, 'Special');

        if(app.Insurance_Value__c == null || app.Insurance_Movement_value__c == null || app.Insurance_Special_Value__c == null){
            System.debug('[RentingApplication - updateInsuranceValues]: Fail to calc one of the Insurance Values!');
            System.debug('[RentingApplication - updateInsuranceValues]: app.Insurance_Value__c: ' + app.Insurance_Value__c);
            System.debug('[RentingApplication - updateInsuranceValues]: app.Insurance_Movement_value__c: ' + app.Insurance_Movement_value__c);
            System.debug('[RentingApplication - updateInsuranceValues]: app.Insurance_Special_Value__c: ' + app.Insurance_Special_Value__c);
            Outbound_Integration_Log__c log = new Outbound_Integration_Log__c(Start__c = Datetime.now(), End__c = Datetime.now(), Status__c = 'FAILED', Code__c = 'PARTNER_APP', 
                Message__c = 'Failed to calc insurance values: Insurance_Value__c = ' + app.Insurance_Value__c + '; app.Insurance_Movement_value__c : ' + app.Insurance_Movement_value__c + '; app.Insurance_Special_Value__c = ' + app.Insurance_Special_Value__c,
                ApplicationID__c = appID, printStackTrace__c = 'RentingApplication.cls on method updateInsuranceVaues(Decimal amount)');
            return false;
        }

        update app;
        return true;
    }

    public boolean wasContractSent(){
        return application.Contract_Sent__c!=null;
    }

    public boolean wasAutoSent(){
        return application.Delivery_Certificate_Sent__c!=null;    
    }

    public static Boolean validateVendorClientIban(String appID, String iban){
       
        List<Application__c> app = [SELECT ID, Vendor__r.BBAN__c  
                                    FROM Application__c WHERE id =: appID];

        System.debug('app.VENDOR BBAN -> '+app[0].vendor__r.BBAN__c);
        System.debug('IBAN INSERIDO BBAN -> '+iban);
        String cuttediban = iban.removeStart('PT50');
        System.debug('IBAN COMPARADO BBAN -> '+cuttediban);
        
        if(cuttediban == app[0].vendor__r.BBAN__c){
            return true;
        }else{
            return false;
        }                          
        
    } 

    public map<string, object> getRents_deprecated(){

        Map<string, object> rents = new Map<string, object>();
        List<Integer> listRents = new List<Integer>(); 

        Application__c app = [SELECT ID, Vendor__r.Term_12__c, Vendor__r.Term_24__c, Vendor__r.Term_72__c, Rent_72__c,
                            Vendor__r.Term_36__c, Vendor__r.Term_48__c, Vendor__r.Term_60__c, Rent_12__c,
                            Rent_24__c,Rent_36__c,Rent_48__c,Rent_60__c, Payment_Freq__c,
                            Insurance_Value__c, Insurance_Special_Value__c, TermCalc__c, Insurance_Movement_value__c, Term__c
                            ,AccClient__r.Date_Of_Establishment__c, Equipment_Cost__c
                            FROM Application__c WHERE Id = :appID];

        if(app!=null){
            //Verifica que rendas o parceiro estÃ¡ autorizado oferecer.                          
            if(app.Vendor__r.Term_12__c){rents.put('Rent_12__c',app.Rent_12__c); listRents.add(12);}        
            if(app.Vendor__r.Term_24__c){rents.put('Rent_24__c',app.Rent_24__c); listRents.add(24);}
            if(app.Vendor__r.Term_36__c){rents.put('Rent_36__c',app.Rent_36__c); listRents.add(36);}
            if(app.Vendor__r.Term_48__c){rents.put('Rent_48__c',app.Rent_48__c); listRents.add(48);}
            if(app.Vendor__r.Term_60__c){rents.put('Rent_60__c',app.Rent_60__c); listRents.add(60);}            
            if(app.Vendor__r.Term_72__c){rents.put('Rent_72__c',app.Rent_72__c); listRents.add(72);}// 16/03/17 - adicionado o termo a 72 meses (BP)

            
            boolean isStartup = false;
             if(app.AccClient__r.Date_Of_Establishment__c!=null && app.AccClient__r.Date_Of_Establishment__c.daysBetween(date.today())/365 < ScoreCardConfig.getStartupMaxAge()){
                isStartup = true;
            }
            
            //outros campos relativos Ã  renda
            rents.put('Payment_freq__c', app.Payment_Freq__c);
            rents.put('Equipment_Cost__c', app.Equipment_Cost__c);
            rents.put('Insurance_Value__c', app.Insurance_Value__c);
            rents.put('Insurance_Special_Value__c', app.Insurance_Special_Value__c);
            rents.put('Insurance_Movement_value__c', app.Insurance_Movement_value__c);
            rents.put('Term__c', app.Term__c);
            rents.put('Allow_Term_12', app.Vendor__r.Term_12__c);
            rents.put('Allow_Term_24', app.Vendor__r.Term_24__c);
            rents.put('Allow_Term_36', app.Vendor__r.Term_36__c && !isStartup);
            rents.put('Allow_Term_48', app.Vendor__r.Term_48__c && !isStartup);
            rents.put('Allow_Term_60', app.Vendor__r.Term_60__c && !isStartup);            
            rents.put('Allow_Term_72', app.Vendor__r.Term_72__c && !isStartup);//ALTERACAO - 16/03/17 - adicionado o termo a 72 meses (BP)
          
            //se nÃ£o tiver nenhum termo como opÃ§Ã£o nÃ£o devolve o termCalc__c. usado como flag para mostrar as rendas
            if(listRents.size()>0){
                rents.put('TermCalc__c', app.TermCalc__c);
            }

        }

        return rents;
    }


    public Rents.Selected getRents(){

        Rents.Selected rents = new Rents.Selected();

        rents.term = Integer.valueOf(application.Term__c);
        rents.rent = application.Payment_Amount__c;
        rents.freq = application.Payment_Freq__c;
        rents.opValue = application.Equipment_Cost__c;
        rents.doc_fee = application.Vendor_Diluted_Doc_Fee__c;

        return rents;
    }    

    public boolean setPaymentFreq (String freq, boolean calcOpValueFromAmount){

        //HP - 14/02/2017: Alterado para retirar term__c = 36 como predefinido

        //HP - 27/07/2017: Amount (equipment_cost__c) deixa de ser enviado a partir do portal; 
        //                 Adicionado flag calcOpValueFromAmount para saber que tipo de calculo de renda se efectua:
        //                  - calcOpValueFromAmount = true -> Equipment_cost__c calculado a partir da renda escolhida pelo parceiro.
        //                  - calcOpValueFromAmount = false -> Renda calculada a partir do Equipment_cost__c inserido pelo parceiro.                       
        decimal amount;
        string result;
        Application__c app = new Application__c();
        app.Id = appID;
        
        
        if(freq=='Monthly'){
            app.Payment_Freq__c = 'Monthly';
        }

        if(freq=='Quarterly'){
            app.Payment_Freq__c = 'Quarterly';
        }

        update app;
        
        if(!calcOpValueFromAmount){
            amount = this.application.Equipment_Cost__c;
            result = ScoreCardConfig.GetScoreCardRate(appID, amount);
        }else{
            Integer term = Integer.ValueOf(this.application.Term__c);
            amount = (decimal) this.application.get('Rent_' + term + '__c');
            result = ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, term);
        }

        if(result != 'Success'){
            System.debug('[RentingApplication - setPaymentFreq]: ERROR, ScoreCardConfig.GetScoreCardRate returned ' + result +' for ' + appID );
            return false;
        }else{
            System.debug('[RentingApplication - setPaymentFreq]: SUCCESS calculating rents for application with ID ' + appID);
            return true;
        }
    }

    public Boolean setSignatureAmount(Integer amount){

        Application__c app = [SELECT ID, AccClient__c FROM Application__c WHERE ID = :appID];
        Account client = [SELECT ID,FormaObrigar_Val__c FROM Account WHERE ID = :app.AccClient__c];
        ReportDB__c report = [SELECT ID, FormaObrigarToNr__c, Vendor__c FROM ReportDB__c WHERE Vendor__c =: client.id Order By CreatedDate DESC LIMIT 1];

        if(amount != null){
            client.FormaObrigar_Val__c = amount;
            if(report != null){
                report.FormaObrigarToNr__c = amount;
                update report;
            }
            update client;
            return true;
        }else{
            return false;
        }
    }



    public void setTerm(String term, Decimal paymonthly){

        Application__c app = [SELECT ID, Payment_Amount__c,Factor__c,TermCalc__c,
                              Term__c,TermSetByUser__c,Equipment_Cost__c FROM Application__c WHERE ID = :appID];

        app.Term__c = term;     
        app.Payment_Amount__c=paymonthly;
        app.Factor__c=(paymonthly/app.Equipment_Cost__c)*100;
        app.TermCalc__c=Decimal.valueOf(term);
        app.TermSetByUser__c=true;

        update app;
    }

    public static String setEmailById(String contactid,String email){

            List<Contact> lcon = [SELECT Id,Email from Contact WHERE id=: contactid];
            system.debug('resultado da query: '+lcon[0]);
            if ( lcon.size() > 0 ){
                lcon[0].Email = email;
            }
            update lcon;
            return  lcon[0].Email;    
    }


    public static String setCorrectedEmailDocusign(String docusignStatusId, String contactid, String email){

        List<dsfs__docusign_Recipient_Status__C> recipientStatus = [SELECT Id,correctedEmail__c
                                                                    FROM dsfs__docusign_Recipient_Status__C 
                                                                    WHERE  dsfs__Parent_Status_Record__c =: DocuSignStatusId and dsfs__Contact__c=:contactid];
            system.debug('resultado da query: '+recipientStatus[0]);

            if ( recipientStatus.size() > 0 ){
                recipientStatus[0].correctedEmail__c = email;
            }
            update recipientStatus;
            return recipientStatus[0].correctedEmail__c;    
    }

//aqui
    public static List<Id> getDocusignCorrectedEmails(String docusignStatusId){
        System.debug('Entrei no getDocusignCorrectedEmails!!!!!');
         List<dsfs__docusign_Recipient_Status__C> recipientStatus = [SELECT dsfs__Contact__c 
                                                                    FROM dsfs__docusign_Recipient_Status__C 
                                                                    WHERE  dsfs__Parent_Status_Record__c =: DocuSignStatusId 
                                                                    AND dsfs__Recipient_Status__c IN ('Sent','AutoResponded','Delivered')];

        List<Id> result = new List<Id>();    
        for(dsfs__docusign_Recipient_Status__C rs : recipientStatus)
        {
            result.add((Id)rs.dsfs__Contact__c);
        }
        System.debug('[RentingApplication].getDocusignCorrectedEmails() --> result: '+result);
        return result;    
    }



    public map<string, object> setAppDocFee(Boolean yes_no, boolean calcOpValueFromAmount){

        //Application__c app = [SELECT ID, Vendor_Diluted_Doc_Fee__c, Equipment_Cost__c  FROM Application__c WHERE ID = :appID];
        Application__c app = this.application;/*[select Id, Vendor_Diluted_Doc_Fee__c, Name, ScoreCard__c, accClient__c, vendor__c, accClient__r.Risk_Type__c, Vendor__r.Diluted_Doc_Fee__c,
                    payment_freq__c, Vendor__r.Discount_Factor__c, Client_Available_Credit_Line__c, accClient__r.Available_Credit_Line__c,
                    AccClient__r.Date_Of_Establishment__c, TermCalc__c, Equipment_Cost__c, Term__c, Rent_12__c, Rent_24__c, Rent_36__c,Rent_48__c,Rent_60__c, Rent_72__c From Application__c where Id=: appID];
        */
        app.Vendor_Diluted_Doc_Fee__c = yes_no;
        update app;  //update da app antes do calculo  

        String result;  
        Decimal amount;
        
        if(!calcOpValueFromAmount){
            amount = app.Equipment_Cost__c;
            result = ScoreCardConfig.GetScoreCardRate(appID, amount);
        }else{
            Integer term = Integer.ValueOf(app.Term__c);
            amount = (decimal) app.get('Rent_' + term + '__c');
            result = ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, term);
        }

        /*decimal discfactor=0;
        if(app.vendor__r.Discount_Factor__c!=null && app.vendor__r.Discount_Factor__c!=''){
            discfactor=decimal.valueOf(((app.vendor__r.Discount_Factor__c).replace(',','.')).replace('%',''));
        }
        
        ScoreCardConfig.getCalc(app,app.Equipment_Cost__c, (integer) app.TermCalc__c, discfactor);*/

        if(result != 'Success'){
            System.debug('[RentingApplication - CalcPayments]: ERROR, ScoreCardConfig.GetScoreCardRate returned ' + result +' for ' + appID );
            return null;
        }else{
            System.debug('[RentingApplication - CalcPayments]: SUCCESS calculating rents for application with ID ' + appID);
            return getRents_deprecated();
        }
        
    }
    
    public map<string, object> calcOpValueFromAmount(decimal paymentAmount, Integer term){

        map<string, object> resMap = new map<string, object>();
        
        String res = ScoreCardConfig.GetScoreCardRateFromAmount(appID, paymentAmount, term);  //this method calls getcalc() after the algorithm
        
        if(res == 'CalcValue greater availCreditline'){
            resMap.put('error','ERROR_UNAVAILABLE_CREDITLINE');
            return resMap;
        }else if(res=='failure'){
            resMap.put('error','ERROR_CALC_RENT_FROM_AMOUNT');
            return resMap;
        }else{
            return getRents_deprecated();
        }
    }
    
    public List<Contact> getContactsApp (){

        List<Contact> contacts = [SELECT ID, Name, Email, Description,New_Binding_Contact__c, Role__c, Shown_in_App__c
                                  FROM Contact 
                                  WHERE AccountId IN (SELECT AccClient__c FROM Application__c WHERE Id =: appID) AND (shown_in_app__c = true OR New_Binding_Contact__c=true)];
        
        for(contact con : contacts){
            if(con.Email=='change_me@email.com'){
                con.Email = '';
            }
        }             

        return contacts;
    }


    public boolean setInsuranceType(String ChosenInsuranceType){

       /* Application__c app = [SELECT ID, Payment_Amount__c,Factor__c,TermCalc__c,
                              Term__c,TermSetByUser__c,Equipment_Cost__c FROM Application__c WHERE ID = :appID];*/
            Application__c app = new Application__c();
            app.Id = appID;                        
            app.Insurance_Type__c = ChosenInsuranceType;
            update app;
            return true;
    }

    public String setCertificateSigner(Id contact) //Andre Lourenço (10/07/2017 - escolher quem assina o auto)
    {
        String res='';
        if(contact != null ){
            Application__c app = new Application__c();
            app.Id = appID;
            app.Client_Signer_1_Delivery_Certificate__c = contact; 

            update app;
            res=app.Id;
        }
        return res;
    }


    public String setEmailContact(Contact contact){

        String vendorEmail = [SELECT ID, Vendor_Primary__r.email FROM Application__c WHERE Id=:appID].Vendor_Primary__r.email;

        if(vendorEmail == contact.Email){
            return 'SAME_EMAIL';
        }

        Contact con = new Contact();    //[SELECT ID, Email FROM Contact WHERE ID =: contactID ];
        con.Email = contact.Email;
        con.Role__c=contact.Role__c;    
        
        con.Id  =contact.Id;

        if(contact.Name!=null){

            String[] name = contact.Name.split(' ', 2);

            if(name.size() == 1){
                con.LastName = name[0]; 
            }else{
                con.FirstName = name[0];    
                con.LastName = name[1];
            }

        }else{

            con.FirstName = contact.FirstName;    
            con.LastName = contact.LastName;
        
        }



        if(contact.AccountId!=null){
            con.AccountId = contact.AccountId;
        }
        
        con.Description = contact.Description;
        con.New_Binding_Contact__c = contact.New_Binding_Contact__c;    
       

        upsert con;

        return con.Id;
    }
    
    public Application__c getAppStatus (){

        Application__c app = [SELECT Status__c, eSignature_Contract__c, Paper_Contract__c, Cancelled__c
                             FROM Application__c 
                             WHERE Id =: appId];
        return app;
    } 

    public String buildContract(String TypeOfContract){

        CandorDocuments contract = new CandorDocuments(TypeOfContract);
        String contractName = '';

        if(TypeOfContract == CONTRACT_RENTING_NAME){
            contractName = 'Contrato de Renting - ' + appId + '.pdf';
        }
        if(TypeOfContract == AUTO_NAME){
            contractName = 'Auto de Aceitação - ' + appId + '.pdf';
        }
        
        String contractId = contract.buildDocument(appID,contractName);

        return contractId;
    }

    public String setAppClientSigners(List<Id> contactsId){

        Application__c app = new Application__c();
        app.Id = appID;

        if(application.Contract_Sent__c!=null){
            return 'CONTRACT_ALREADY_SENT:' + application.Contract_Sent__c.format();
        }

        if(contactsId.size()==1){
            app.Client_Signer_1__c = contactsId[0];
            app.Client_Signer_2__c = null;
            app.Client_Signer_3__c = null;
            app.Client_Signer_4__c = null;
            app.Client_Signer_5__c = null;
        }

        if(contactsId.size()==2){
            app.Client_Signer_1__c = contactsId[0]; 
            app.Client_Signer_2__c = contactsId[1];
            app.Client_Signer_3__c = null;
            app.Client_Signer_4__c = null;
            app.Client_Signer_5__c = null;
        }
        if(contactsId.size()==3){
            app.Client_Signer_1__c = contactsId[0]; 
            app.Client_Signer_2__c = contactsId[1];
            app.Client_Signer_3__c = contactsId[2];
            app.Client_Signer_4__c = null;
            app.Client_Signer_5__c = null;
        }
        if(contactsId.size()==4){
            app.Client_Signer_1__c = contactsId[0]; 
            app.Client_Signer_2__c = contactsId[1];
            app.Client_Signer_3__c = contactsId[2];
            app.Client_Signer_4__c = contactsId[3];
            app.Client_Signer_5__c = null;
        }
        if(contactsId.size()>=5){
            app.Client_Signer_1__c = contactsId[0]; 
            app.Client_Signer_2__c = contactsId[1];
            app.Client_Signer_3__c = contactsId[2];
            app.Client_Signer_4__c = contactsId[3];
            app.Client_Signer_5__c = contactsId[4];
        }

        if(contactsId.size()>0){
            app.Client_Signer_1_Delivery_Certificate__c = contactsId[0]; 
        }

        update app;

        //if possible set invoice Email in Client Account
        if(app.Client_Signer_1__c != null){
            putSignerEmailInInvoiceEmail(app.Client_Signer_1__c);
        }  

        List<Contact> conToUpdateRoleList = new List<Contact>();
        //Set signers as Binding Contract
        for(Contact con : [SELECT Id, Role__c FROM Contact WHERE Id IN :contactsId]){
            con.Role__c = 'Binding Power';
            conToUpdateRoleList.add(con);
        }
        update conToUpdateRoleList;

        return 'OK';
    }

    public void putSignerEmailInInvoiceEmail(Id contactID){
        
        Client c = new Client(application.AccClient__c);
        String invEmail = c.getInvoiceEmail();
        Contact signer1 = [SELECT email FROM Contact WHERE Id =:contactID];
            
        if(invEmail != signer1.Email){
            try{
                boolean res = c.setInvoiceEmail(signer1.Email, false);
                System.debug(LoggingLevel.INFO, '[RentingApplication - putSignerEmailInInvoiceEmail()]Invoice Email for client with ID ' + application.AccClient__c + ' was changed? Result: ' + res);
            }catch(Exception e){
                FundingConfig__c fc = FundingConfig__c.getInstance();
                if(fc.debug_email__c !=null) {   
                    String subject = 'ALERT: problem updating Invoice Email for client ' + c.getAccount().Name +' when changed Signer 1 in ' + application.Name; 
                    String error = 'There was an error updating Invoice Email for client ' + c.getAccount().Name +' when changed Signer 1 in ' + application.Name; 
                    error += '\n\nERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString();
                    Utilities.SendEmail(fc.debug_email__c, error, subject);
                }
                System.debug(LoggingLevel.INFO, '[RentingApplication - putSignerEmailInInvoiceEmail()] - ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString() + ' || APPID: ' + appID);
                Utilities.LogIntegration( Datetime.now(), Datetime.now(), 'ERROR', 'SET_INVOICE_EMAIL', 'ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString(),  appID);
            }
        }
    }

    public boolean cancelApplication(){

        Datetime start = Datetime.now();
        boolean is_eSignatureContract = [SELECT eSignature_Contract__c FROM Application__c WHERE Id=:appID].eSignature_Contract__c;
        
        boolean deletedStatus = true;
        if(is_eSignatureContract){//Verifica se o contracto foi enviado por Docusign
            deletedStatus = deleteAndVoidDocusign('Cancel Application');
        }

        if(deletedStatus){
            Application__c app = new Application__c();
            app.Cancelled__c = true; 
            app.Id = appID;
            update app;

            DeleteAllEquipments();
        }

        return deletedStatus;
        //Map<String,Object> voidResult = new Map<String,Object>();
        //voidResult = voidDocusign('Cancel Application');
        //VOID the Docusign Envelope status -- alterado para mÃ©todo privado (24/02/2017 HP)
        /*List<DocuSignInfo> dsinfoList = getDocuSignInfo();
        Map<String,boolean> voidResult = new Map<String,boolean>();
        DocuSignAPI.VoidEnvelopeStatus voidstatus= new DocuSignAPI.VoidEnvelopeStatus();
        String stringWithEnvelopdID = '';
        for(DocuSignInfo dsinfo : dsinfoList){
           System.debug('[RentingApplication - cancelApplication()] - Void DocuSign Status with Envelope ID: ' + dsInfo.Status.dsfs__DocuSign_Envelope_ID__c);
           stringWithEnvelopdID = stringWithEnvelopdID  + dsInfo.Status.dsfs__DocuSign_Envelope_ID__c + '; ';
           voidstatus = CandorDocuments.voidDocumentDocuSign(dsInfo.Status.dsfs__DocuSign_Envelope_ID__c, 'Cancel Application');
           voidResult.put(dsInfo.Status.dsfs__DocuSign_Envelope_ID__c, voidstatus.VoidSuccess);
           if(!voidstatus.VoidSuccess){
            status = 'Partial Success';
           }
        }*/
        
        /*string resultJson = JSON.serialize(voidResult);
        String status = (String) voidResult.get('status');
        String stringWithEnvelopdID = (String) voidResult.get('EnvelopdIDs');*/
        
        /*Application__c app = new Application__c();
        app.Cancelled__c = true; */
        
        //Reset aos campos de envio de contrato e certificado. App volta ao estado inicial sem colocar checkbox de cancelada a true
        //ATENÃ‡Ã‚O: Se existirem Docusign envelopes com status COMPLETED nÃ£o Ã© possivel fazer void.
        //TODO: verificar se Ã© possivel eliminar envelopes pela DOCUSIGNAPI mesmo estando completed.
        /*app.eSignature_Contract__c = false;
        app.Paper_Contract__c = false;
        app.Contract_Sent__c = null;
        app.Delivery_Certificate_Sent__c = null;
        app.Contract_Signed__c = null;
        app.Delivery_Certificate_Signed__c = null;
        app.Payment_Amount__c = 0;
        app.Equipment_Cost__c = 0;*/
        /*app.Id = appID;
        update app;

        return true;*/
    }

    public String EditContract(List<String> contractType){

        Datetime start = Datetime.now();

        Set<String> contractTypeSet = new Set<String>();
        for(String ct : contractType){
            contractTypeSet.add(ct.toUpperCase());
        }
        System.debug('[RentingApplication] - EditContract(): set of contract types to edit: ' + contractTypeSet);
        
        List<Application__c> editedAppList=[SELECT id,name,eSignature_Contract__c,Paper_Contract__c,Contract_Sent__c,
                                         Invoice_Payment_Date__c,Contract_Signed__c,Delivery_Certificate_Sent__c,
                                         Delivery_Certificate_Signed__c , Issuing_Date_Invoice__c, vendor_Invoice_Amount__c,
                                         Invoice_Number__c, IdLoginCreate__c, Vendor__c
                                    FROM Application__c
                                   WHERE id=:appID LIMIT 1];
        
        Application__c editedApp = new Application__c();                         
        if(editedAppList.size()==0)
            return 'NOT_EXIST';
        else{
            editedApp = editedAppList[0];
        }
        List<Vendor_Invoice__c>  completeInvList =[SELECT Id, name, Submitted__c, Status__c from Vendor_Invoice__c where Application__c=:appId AND Status__c = 'Completed' limit 1];
    	if(completeInvList.size() > 0){
    		return 'INVOICE_STATUS_COMPLETED';
    	}
        //Se a lista n tiver dois registos e o Auto tiver sido enviado, não permite editar pois ainda está a aguardar sincronização com Docusign;
        //TODO: Processo irá ser melhorado quando a edição for efectuada por contacto (HP - 15/05/2017) e quando se implementar sincronização automática com DocuSign
        if(editedApp.Delivery_Certificate_Sent__c!=null){
            List<DocuSignInfo> dsinfoList = getDocuSignInfo();
            if(dsinfoList.size()<2){
                return 'NOT_SYNC'; 
            }
        }

        if(editedApp.Invoice_Payment_Date__c != null)
            return 'APP_ALREADY_SETTLE';

        Map<String,Object> voidResult = new Map<String,Object>();
        voidResult = voidDocusign(contractTypeSet, 'Edited');
        boolean deletedStatus = (voidResult.get('status') == 'Success' || voidResult.get('status') == 'Partial Success');
        
        List<Vendor_Invoice__c>  editInvList =[SELECT Id, name, Submitted__c, Status__c from Vendor_Invoice__c where Application__c=:appId AND Status__c != 'Canceled' limit 1];
        Vendor_Invoice__c editedInv = New Vendor_Invoice__c();
        if(editInvList.size()!=0)
            editedInv = editInvList[0];

        if(deletedStatus || editedApp.Paper_Contract__c){

                if(contractTypeSet.contains(CONTRACT_RENTING_NAME)){
                    editedApp.eSignature_Contract__c = false;
                    editedApp.Contract_Sent__c = null;
                    editedApp.Contract_Signed__c = null;
                    editedApp.Paper_Contract__c = false;

                    //On contract edition cancel invoice submited by vendor
                    Vendor v = new Vendor(editedApp.IdLoginCreate__c);
                    String res = v.cancelInvoice(editedInv.Id);
                    System.debug('[RentingApplication] - EditContract(): vendor.cancelInvoice() result: ' + res);
                }

                if(contractTypeSet.contains(AUTO_NAME)){
                    editedApp.Delivery_Certificate_Sent__c   = null;
                    editedApp.Delivery_Certificate_Signed__c = null;
                } 

                if(contractTypeSet.contains(DELETE_NAME)){
                    editedApp.Cancelled__c = true;
                }               
           
                //Delete all equipments from this app 
                //DeleteAllEquipments(); // CHANGED RESQUEST - HP - 06/06/2017 -> trello: https://trello.com/c/yr0fthl1/521-quando-os-parceiros-utilizam-a-funcionalidade-editar-os-equipamentos-n%C3%A3o-devem-ser-apagados

                update editedApp;
                Utilities.LogIntegrationLongResponse( start, Datetime.now(), 'Success' , 'VOID_DOCUSIGN_EDIT','',appID,'Success');
        }
        
        if(deletedStatus){
            return 'OK'; 
        }else{
            return 'NOTOK';    
        }
    }  

    @TestVisible
    private Map<String, Object> voidDocusign(Set<String>contractTypeSet, String motive){

        System.debug('[RentingApplication] - voidDocusign(): set of contract types: ' + contractTypeSet);

        //VOID the Docusign Envelope status 
        List<DocuSignInfo> dsinfoList = getDocuSignInfo();
        Map<String,Object> voidResult = new Map<String,Object>();
        DocuSignAPI.VoidEnvelopeStatus voidstatus= new DocuSignAPI.VoidEnvelopeStatus();
        String status='Success';
        String stringWithEnvelopdID = '';
        List<dsfs__docusign_Status__c> listDocuSignStatusToUpdate = new List<dsfs__docusign_Status__c>();
        for(DocuSignInfo dsinfo : dsinfoList){
            if(contractTypeSet.contains(dsinfo.type.toUpperCase())){
                System.debug('[RentingApplication - voidDocusign() - ' + motive + '] - Void DocuSign Status with Envelope ID: ' + dsInfo.Status.dsfs__DocuSign_Envelope_ID__c);
                stringWithEnvelopdID = stringWithEnvelopdID  + dsInfo.Status.dsfs__DocuSign_Envelope_ID__c + '; ';
                voidstatus = CandorDocuments.voidDocumentDocuSign(dsInfo.Status.dsfs__DocuSign_Envelope_ID__c, motive);
                voidResult.put(dsInfo.Status.dsfs__DocuSign_Envelope_ID__c, voidstatus.VoidSuccess);
                if(!voidstatus.VoidSuccess){
                    status = 'Partial Success';
                }
               
                dsfs__docusign_Status__c ds = new dsfs__docusign_Status__c();
                ds.Deleted_by_partner__c = true;
                ds.Id = dsinfo.status.Id;
                listDocuSignStatusToUpdate.add(ds);
            }
        }

        update listDocuSignStatusToUpdate;

        voidResult.put('status',status);
        voidResult.put('EnvelopdIDs',stringWithEnvelopdID);
        return voidResult;
    }  

    @TestVisible
    private boolean deleteAndVoidDocusign(String MOTIVE){
        
        List<DocuSignInfo> dsinfoList = getDocuSignInfo();
        List<String> stringListWithEnvelopdID = new List<String>();
        String stringWithEnvelopdID = '';

        for(DocuSignInfo dsinfo : dsinfoList){
            System.debug('[RentingApplication - deleteAndVoidDocusign()] - Delete and void DocuSign Status with Envelope ID: ' + dsInfo.Status.dsfs__DocuSign_Envelope_ID__c); 
            
            //Se possivel os envelopes são voided e só depois deleted
            CandorDocuments.voidDocumentDocuSign(dsInfo.Status.dsfs__DocuSign_Envelope_ID__c, MOTIVE);
                       
            stringListWithEnvelopdID.add(dsInfo.Status.dsfs__DocuSign_Envelope_ID__c);
        }

        boolean deletedStatus = CandorDocuments.deleteEnvelopeThroughDocuSign(stringListWithEnvelopdID);

        if(deletedStatus){
            List<dsfs__docusign_Status__c> listDocuSignStatus = new List<dsfs__docusign_Status__c>();
            for(DocuSignInfo dsinfo : dsinfoList){
                //Set costum DocuSign Envelope Status to check if completed documents were put on deleted folder
                dsinfo.status.Deleted_by_partner__c = true;
                listDocuSignStatus.add(dsinfo.status);
            }
            update listDocuSignStatus;
        }
        return deletedStatus;
    }   

    public DocuSignAPI.EnvelopeStatus SendRentingContract(Id contractId){

        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        Blob pdfBlob;
        String CountryCode;
        Integer MIN_ATTACH_SIZE = 67584;
        Decimal MIN_NUMBER_OF_SIGNERS = 1;
        Decimal NUMBER_OF_EXISTING_SIGNERS = 0;

        application__c app = [SELECT id, name, Client_Signer_1__r.Id, Client_Signer_2__r.Id, 
                                  Client_Signer_3__r.Id, Client_Signer_4__r.Id, Client_Signer_5__r.Id, 
                                  Candor_Signer__r.Id, 
                                  Vendor_Primary__r.Id, Client_Signer_1__r.email,
                                  Client_Signer_2__r.email, Client_Signer_3__r.email,
                                  Client_Signer_4__r.email,Client_Signer_5__r.email,  
                                  Candor_Signer__r.email, Vendor_Primary__r.email,
                                  Client_Signer_1__r.Name, Client_Signer_2__r.Name, 
                                  Client_Signer_3__r.Name,Client_Signer_4__r.Name, 
                                  Client_Signer_5__r.Name,
                                  Candor_Signer__r.Name,AccClient__c, 
                                  Vendor_Primary__r.Name, Client_Country_Code__c, 
                                  Vendor__r.Name, Contract_Sent__c, Personal_Guarantee__c, 
                                  AccClient__r.FormaObrigar_Val__c, Vendor__c, ScoreCard__c
                              FROM application__c 
                              WHERE id=:appId];

        List<Attachment> doc = [SELECT Id, name, body, createdDate, parentID, bodylength 
                                FROM attachment 
                                WHERE Id =:contractId AND parentID=:appID];

        Decision_Conditions_Card_History__c [] conditions_hist_list =  [SELECT Personal_Guarantee__c FROM Decision_Conditions_Card_History__c 
                                                                WHERE Decision__c IN (SELECT ID FROM Decision__c WHERE Account__c =:app.AccClient__c AND Active__c = TRUE)
                                                                ORDER BY CREATEDDATE DESC LIMIT 1];

        boolean personal_guarantee = conditions_hist_list.size()>0 && app.ScoreCard__c == null ? conditions_hist_list[0].Personal_Guarantee__c : app.Personal_Guarantee__c;                                

        //override this fields in case they are edited (cancel ou edit contract) (HP 2017/10/02) 
        app.Personal_Guarantee_Signer_1__c = null;
        app.Personal_Guarantee_Signer_2__c = null;                                

        if(app.AccClient__r.FormaObrigar_Val__c!=NULL || app.AccClient__r.FormaObrigar_Val__c>0){
            MIN_NUMBER_OF_SIGNERS = app.AccClient__r.FormaObrigar_Val__c;
        }

        if(doc.size()>0){
            pdfBlob = doc[0].Body;
        }else if(doc.size()==0){ 
            System.debug('[RentingApplication - SendRentingContract] - Document with Id '+contractId+' for Application '+ app.Name+' not Found.');
            DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();
            es.Status = 'Not Found';
            //Utilities.LogIntegrationLongResponse( Datetime.now(), Datetime.now(), es.Status, 'CONTRACT_AUTO','',app.Id,'');
            return es;
        }else if(doc[0].bodylength < MIN_ATTACH_SIZE){//valida se o attach está corrompido. Se o tamanho for inferior ao limite é porque tem erro
            System.debug('[RentingApplication - SendRentingContract] - Check document with Id '+contractId+' for Application '+ app.Name+' - length of file to small');
            DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();
            es.Status = 'INVALID_ATTACH';
            //Utilities.LogIntegrationLongResponse( Datetime.now(), Datetime.now(), es.Status, 'CONTRACT_AUTO','',app.Id,'');
            return es;
        }

        // Document
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
        document.Name =  'Contrato de Renting ' + app.Name + ' - ' + appID;
        document.FileExtension = 'pdf';
        envelope.Documents = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0] = document;

        List<DocuSignAPI.Recipient> recipientList = new List<DocuSignAPI.Recipient>();
            List<DocuSignAPI.Tab> tabList = new List<DocuSignAPI.Tab>();
        if(app.Client_Country_Code__c == null || app.Client_Country_Code__c == ''){
            CountryCode = 'PT';
        }else{
            CountryCode = app.Client_Country_Code__c.substring(0, 2);
        }

        if(app.Client_Signer_1__r.Id!=null){
            
            NUMBER_OF_EXISTING_SIGNERS++;
            
            DocuSignAPI.Recipient Signer1 = CandorDocuments.createDocuSignRecipient(1,'Signer',1,'Signer 1', app.Client_Signer_1__r.email, app.Client_Signer_1__r.Name, app.AccClient__c,app.Client_Signer_1__r.id);
            recipientList.add(Signer1);
            
            // Tab
            DocuSignAPI.Tab tab1 = CandorDocuments.createDocuSignTab(1, 1,'SignHere','\\s1\\');
            DocuSignAPI.Tab tab1Date = CandorDocuments.createDocuSignTab(1, 1, 'DateSigned','\\d1\\');
            tabList.add(tab1);
            tabList.add(tab1Date);
            
            if(personal_guarantee){
                app.Personal_Guarantee_Signer_1__c = app.Client_Signer_1__r.Id; //(HP 2017/10/02)
                tab1 =  CandorDocuments.createDocuSignTab(1, 1,'SignHere','\\sf1\\');
                tab1Date = CandorDocuments.createDocuSignTab(1, 1, 'DateSigned','\\df1\\');
                tabList.add(tab1);
                tabList.add(tab1Date);
            }
        }
        
        if(app.Client_Signer_2__r.Id != null){
            
            NUMBER_OF_EXISTING_SIGNERS++;
            
            DocuSignAPI.Recipient Signer2 = CandorDocuments.createDocuSignRecipient(2,'Signer',1,'Signer 2', app.Client_Signer_2__r.email, app.Client_Signer_2__r.Name, app.AccClient__c,app.Client_Signer_2__r.id);
            recipientList.add(Signer2);
            
            DocuSignAPI.Tab tab2 = CandorDocuments.createDocuSignTab(2, 1,'SignHere','\\s2\\');
            DocuSignAPI.Tab tab2Date = CandorDocuments.createDocuSignTab(2, 1, 'DateSigned','\\d2\\');
            tabList.add(tab2);
            tabList.add(tab2Date);
            
            if(personal_guarantee){
                app.Personal_Guarantee_Signer_2__c = app.Client_Signer_2__r.Id; //(HP 2017/10/02)
                tab2 = CandorDocuments.createDocuSignTab(2, 1,'SignHere','\\sf2\\');
                tab2Date = CandorDocuments.createDocuSignTab(2, 1, 'DateSigned','\\df2\\');
                tabList.add(tab2);
                tabList.add(tab2Date);
            }
        }
        
        if(app.Client_Signer_3__r.Id!=null){
           
            NUMBER_OF_EXISTING_SIGNERS++;
           
            DocuSignAPI.Recipient Signer3 = CandorDocuments.createDocuSignRecipient(3,'Signer',1,'Signer 3', app.Client_Signer_3__r.email, app.Client_Signer_3__r.Name, app.AccClient__c,app.Client_Signer_3__r.id);
            recipientList.add(Signer3);
            
            DocuSignAPI.Tab tab3 =  CandorDocuments.createDocuSignTab(3, 1,'SignHere','\\s3\\');
            DocuSignAPI.Tab tab3Date = CandorDocuments.createDocuSignTab(3, 1, 'DateSigned','\\d3\\');
            tabList.add(tab3);
            tabList.add(tab3Date);
        } 
        
        
        if(app.Client_Signer_4__r.Id!=null){
  
            NUMBER_OF_EXISTING_SIGNERS++;
  
            DocuSignAPI.Recipient Signer = CandorDocuments.createDocuSignRecipient(6,'Signer',1,'Signer 6', app.Client_Signer_4__r.email, app.Client_Signer_4__r.Name, app.AccClient__c, app.Client_Signer_4__r.id);
            recipientList.add(Signer);
            
            DocuSignAPI.Tab tab = CandorDocuments.createDocuSignTab(6, 1,'SignHere','\\s6\\');
            DocuSignAPI.Tab tabDate = CandorDocuments.createDocuSignTab(6, 1, 'DateSigned','\\d6\\');
            tabList.add(tab);
            tabList.add(tabDate);
        } 
        
        if(app.Client_Signer_5__r.Id!=null){
        
            NUMBER_OF_EXISTING_SIGNERS++;
        
            DocuSignAPI.Recipient Signer = CandorDocuments.createDocuSignRecipient(7,'Signer',1,'Signer 7', app.Client_Signer_5__r.email, app.Client_Signer_5__r.Name,app.AccClient__c,app.Client_Signer_5__r.id);
            recipientList.add(Signer);
            
            DocuSignAPI.Tab tab = CandorDocuments.createDocuSignTab(7, 1,'SignHere','\\s7\\');
            DocuSignAPI.Tab tabDate = CandorDocuments.createDocuSignTab(7, 1, 'DateSigned','\\d7\\');
            tabDate.Type_x = 'DateSigned';
            tabList.add(tab);
            tabList.add(tabDate);
        } 

            
        if(app.Vendor_Primary__r.Id!=null){
            
            Message__c subjectVendor = [Select Message_text__c, Message_code__c, Country_code__c 
                                        from Message__c 
                                        where Message_code__c='EMAIL_VENDOR_SUBJECT' and Country_code__c=:CountryCode];
            
            DocuSignAPI.RecipientEmailNotification email = new DocuSignAPI.RecipientEmailNotification();
            string subject = subjectVendor.Message_text__c+' ' + app.Name;
            email.Subject = subject.abbreviate(100);
            
            
            DocuSignAPI.Recipient Vendor = CandorDocuments.createDocuSignRecipient(5,'CarbonCopy',1,null,  app.Vendor_Primary__r.email,  app.Vendor_Primary__r.Name, app.Vendor__c, app.Vendor_Primary__r.Id);
            Vendor.EmailNotification = email;
            recipientList.add(Vendor);
        } 
        
        envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignAPI.Recipient[recipientList.size()];
        for(integer i=0; i<recipientList.size(); i++){
            envelope.Recipients.Recipient[i] = recipientList[i];
        }
        
        envelope.Tabs = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab = new DocuSignAPI.Tab[tabList.size()];
        for(integer i=0; i<tabList.size(); i++){
            envelope.Tabs.Tab[i] = tabList[i];
        }
        
        //Riminder and expirations
        DocuSignAPI.Notification notification = new DocuSignAPI.Notification();
        notification.UseAccountDefaults = true; // use account default
        envelope.Notification = notification;        

        List<DocuSignAPI.CustomField> customFieldList = new List<DocuSignAPI.CustomField>();      
        //Put external ID -- AppID
        DocuSignAPI.CustomField field = CandorDocuments.createDocuSignCostumFields('DSFSSourceObjectId', appId, true); 
        customFieldList.add(field);
        //Put external ID -- AccountVendorID
        DocuSignAPI.CustomField fieldAcc = CandorDocuments.createDocuSignCostumFields('##SFAccount', app.Vendor__c, true);
        customFieldList.add(fieldAcc);
        //Put External ID - AccountClientID
        DocuSignAPI.CustomField fieldClientAcc = CandorDocuments.createDocuSignCostumFields('Client', app.AccClient__c, true);
        customFieldList.add(fieldClientAcc);
        
        DocuSignAPI.ArrayOfCustomField arrayOfCustomField = new DocuSignAPI.ArrayOfCustomField();
        arrayOfCustomField.CustomField  = new DocuSignAPI.CustomField[customFieldList.size()];
        arrayOfCustomField.CustomField = customFieldList;
        envelope.CustomFields = arrayOfCustomField;
        
        Message__c subject = [Select Message_text__c, Message_code__c, Country_code__c 
                              from Message__c 
                              where Message_code__c='EMAIL_SUBJECT' and Country_code__c=:CountryCode];
        
        envelope.Subject = subject.Message_text__c +' '+app.Vendor__r.Name + ' - (' + app.Name +')';
        //envelope.AccountId  = accountId;
        DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();
        if(NUMBER_OF_EXISTING_SIGNERS < MIN_NUMBER_OF_SIGNERS){
            es.Status = 'MIN_NUMBER_OF_SIGNERS';
        }else{
            es = CandorDocuments.sendDocumentThroughDocuSign(envelope);
        }   
        
        if(es.status=='Sent'){
            app.Contract_Sent__c = date.today();
            app.eSignature_Contract__c = true;
            app.TermSetByUser__c = true;
            update app;
        }     

        return es;

    }

    //This method only resends the docusign envelope
    public static Map<string,boolean> resendContractDocuSign(Id DocuSignStatusId){

        system.debug('[RentingApplication - resendContractDocuSign()] - DocuSignStatusId: ' + DocuSignStatusId);

        List<dsfs__docusign_Recipient_Status__C> recipientStatus = [SELECT Id, Name, Date_Resended__c, dsfs__Docusign_Recipient_Email__c, dsfs__Contact__c, dsfs__Date_Sent__c, dsfs__Date_Signed__c , dsfs__docusign_recipient_id__c,
                                                                    dsfs__Parent_Status_Record__c, dsfs__Parent_Status_Record__r.dsfs__envelope_status__c, dsfs__Parent_Status_Record__r.dsfs__DocuSign_Envelope_ID__c,
                                                                    dsfs__DocuSign_Routing_Order__c
                                                                    FROM dsfs__docusign_Recipient_Status__C 
                                                                    WHERE  dsfs__Parent_Status_Record__c =: DocuSignStatusId 
                                                                    AND dsfs__Recipient_Status__c IN ('Sent','AutoResponded','Delivered')]; //HP 15/02/2017 - Adicionado o estado Delivered                                                          
                                                                                    
                                                                    
        system.debug('[RentingApplication - resendContractDocuSign()] - Numero de contactos a reenviar: ' + recipientStatus.size());

        DocuSignAPI.Correction corrections = new DocuSignAPI.Correction();
        corrections.EnvelopeID = recipientStatus[0].dsfs__Parent_Status_Record__r.dsfs__DocuSign_Envelope_ID__c;
        corrections.RecipientCorrections = new DocuSignAPI.ArrayOfRecipientCorrection();
        corrections.RecipientCorrections.RecipientCorrection = new DocuSignAPI.RecipientCorrection[recipientStatus.size()];
        System.debug('[RentingApplication - resendContractDocuSign()] - Envelope ID: ' + corrections.EnvelopeID);

        integer i=0;
        List<dsfs__docusign_Recipient_Status__C> rsListToUpdate = new list<dsfs__docusign_Recipient_Status__C>();
        for(dsfs__docusign_Recipient_Status__C rs:recipientStatus){ 

            system.debug('[RentingApplication - resendContractDocuSign()] - email do contacto ' + i +': ' + rs.dsfs__Docusign_Recipient_Email__c);
            DocuSignAPI.RecipientCorrection correction = new DocuSignAPI.RecipientCorrection();
            //Set values only to resend.
            correction.PreviousEmail = rs.dsfs__Docusign_Recipient_Email__c;
            correction.PreviousUserName = rs.Name;
            correction.PreviousRoutingOrder = (integer) rs.dsfs__DocuSign_Routing_Order__c;
            correction.resend = true;

            corrections.RecipientCorrections.RecipientCorrection[i] = correction;
            rs.Date_Resended__c = Datetime.now();
            rsListToUpdate.add(rs);
            i ++;
        }

        DocuSignAPI.CorrectionStatus cs = CandorDocuments.CorrectAndResendContractDocuSign(corrections);
        DocuSignAPI.ArrayOfRecipientCorrectionStatus ArrayOfRecipient = cs.RecipientCorrectionStatuses;

        Map<string,boolean> correctionResult = new Map<String, boolean>();
        for(integer n=0; n < recipientStatus.size(); n++){
            if(ArrayOfRecipient!=null){
                System.debug('[RentingApplication - resendContractDocuSign()] - Status of resend to ' + recipientStatus[n].Name+': '+ArrayOfRecipient.RecipientCorrectionStatus[n].CorrectionSucceeded);
                correctionResult.put(recipientStatus[n].dsfs__Docusign_Recipient_Email__c, ArrayOfRecipient.RecipientCorrectionStatus[n].CorrectionSucceeded);    
            }
        }
        System.debug('[RentingApplication - resendContractDocuSign()] - DocuSignAPI.CorrectionStatus: ' + cs);
        System.debug('[RentingApplication - resendContractDocuSign()] - correctionResult: '+ correctionResult);

        update rsListToUpdate;
        return correctionResult;                                    
    }

/*
        DocuSignAPI.Correction corrections = new DocuSignAPI.Correction();
        corrections.EnvelopeID = recipientStatus[0].dsfs__Parent_Status_Record__r.dsfs__DocuSign_Envelope_ID__c;
        corrections.RecipientCorrections = new DocuSignAPI.ArrayOfRecipientCorrection();
        corrections.RecipientCorrections.RecipientCorrection = new DocuSignAPI.RecipientCorrection[recipientStatus.size()];
        System.debug('[RentingApplication - resendContractDocuSignCorrection()] - Envelope ID: ' + corrections.EnvelopeID);

        integer i=0;
        List<dsfs__docusign_Recipient_Status__C> rsListToUpdate = new list<dsfs__docusign_Recipient_Status__C>();
        for(dsfs__docusign_Recipient_Status__C rs:recipientStatus){ 

            system.debug('[RentingApplication - resendContractDocuSignCorrection()] - email do contacto ' + i +': ' + newemails[i]);
            DocuSignAPI.RecipientCorrection correction = new DocuSignAPI.RecipientCorrection();
            //Set values only to resend.
            correction.PreviousEmail = rs.dsfs__Docusign_Recipient_Email__c;
            correction.PreviousUserName = rs.Name;
            correction.PreviousRoutingOrder = (integer) rs.dsfs__DocuSign_Routing_Order__c;

            for(Integer y = 0; y < contactArray.size(); y++){
                for(Integer k = 0; k < newemails.size(); k++){
                    
                    if(contactArray[y] == newemails[k]){
                        correction.CorrectedEmail = newemails[k];
                        rs.dsfs__Docusign_Recipient_Email__c = newemails[k];
                    }
                }

            }
            
            correction.resend = true;

            corrections.RecipientCorrections.RecipientCorrection[i] = correction;
            rs.Date_Resended__c = Datetime.now();
            rsListToUpdate.add(rs);
            i ++;
        }

        update rsListToUpdate;
*/

    //Envia a correção 
    public static Map<string,boolean> resendContractDocuSignCorrection(Id DocuSignStatusId,List<String> contactArray){

        system.debug('[RentingApplication - resendContractDocuSignCorrection()] - DocuSignStatusId: ' + DocuSignStatusId);

        system.debug('contactArray: '+contactArray.size());

        List<dsfs__docusign_Recipient_Status__C> recipientStatus = [SELECT Id, Name, Date_Resended__c, correctedEmail__c, dsfs__Docusign_Recipient_Email__c, dsfs__Contact__c, dsfs__Date_Sent__c, dsfs__Date_Signed__c , dsfs__docusign_recipient_id__c,
                                                                    dsfs__Parent_Status_Record__c, dsfs__Parent_Status_Record__r.Docusign_Application_Status__c ,dsfs__Parent_Status_Record__r.dsfs__envelope_status__c, dsfs__Parent_Status_Record__r.dsfs__DocuSign_Envelope_ID__c,
                                                                    dsfs__DocuSign_Routing_Order__c
                                                                    FROM dsfs__docusign_Recipient_Status__C 
                                                                    WHERE  dsfs__Parent_Status_Record__c =: DocuSignStatusId 
                                                                    AND dsfs__Recipient_Status__c IN ('Sent','AutoResponded','Delivered')]; //HP 15/02/2017 - Adicionado o estado Delivered                                                           

        List<Application__c> app = [SELECT id,Client_Signer_1__c,Client_Signer_1__r.Email,Client_Signer_2__c,Client_Signer_2__r.Email,Client_Signer_3__c,Client_Signer_3__r.Email,Client_Signer_4__c,Client_Signer_4__r.Email,Client_Signer_5__c,Client_Signer_5__r.Email
                             FROM Application__c WHERE Application__c.Id =:recipientStatus[0].dsfs__Parent_Status_Record__r.Docusign_Application_Status__c];                                                                             
                                                                    
        List<String> newemails = new List<String>();
        List<String> ids = new List<String>();
        if (app.size() > 0){

            if(app[0].Client_Signer_1__r.Email != null){
                newemails.add(app[0].Client_Signer_1__r.Email);
                ids.add(app[0].Client_Signer_1__c);
            }
            if(app[0].Client_Signer_2__r.Email != null){
                newemails.add(app[0].Client_Signer_2__r.Email);
                ids.add(app[0].Client_Signer_2__c);
            }
            if(app[0].Client_Signer_3__r.Email != null){
                newemails.add(app[0].Client_Signer_3__r.Email);
                ids.add(app[0].Client_Signer_3__c);
            }
            if(app[0].Client_Signer_4__r.Email != null){
                newemails.add(app[0].Client_Signer_4__r.Email);
                ids.add(app[0].Client_Signer_4__c);
            }
            if(app[0].Client_Signer_5__r.Email != null){
                newemails.add(app[0].Client_Signer_5__r.Email);
                ids.add(app[0].Client_Signer_5__c);
            }
        }


        system.debug('[RentingApplication - resendContractDocuSignCorrection()] - Numero de contactos a reenviar: ' + recipientStatus.size());

        
        List<dsfs__docusign_Recipient_Status__C> rsListToUpdate = updateRecipientsDS(contactArray,newemails,recipientStatus,ids);

        System.debug('[RentingApplication].resendContractDocuSignCorrection - corrections:'+corrections1);
        DocuSignAPI.CorrectionStatus cs = CandorDocuments.CorrectAndResendContractDocuSign(corrections1);
        DocuSignAPI.ArrayOfRecipientCorrectionStatus ArrayOfRecipient = cs.RecipientCorrectionStatuses;
        
        Map<string,boolean> correctionResult = new Map<String, boolean>();
        for(integer n=0; n < recipientStatus.size(); n++){
            if(ArrayOfRecipient!=null){
                System.debug('[RentingApplication - resendContractDocuSignCorrection()] - Status of resend to ' + recipientStatus[n].Name);
                System.debug(':'+ArrayOfRecipient.RecipientCorrectionStatus[n].CorrectionSucceeded);
                correctionResult.put(rsListToUpdate[n].dsfs__Docusign_Recipient_Email__c, ArrayOfRecipient.RecipientCorrectionStatus[n].CorrectionSucceeded);    
            }
        }
        System.debug('[RentingApplication - resendContractDocuSignCorrection()] - DocuSignAPI.CorrectionStatus: ' + cs);
        System.debug('[RentingApplication - resendContractDocuSignCorrection()] - correctionResult: '+ correctionResult);

        update rsListToUpdate;

        return correctionResult;                                    
    }

    private static DocuSignAPI.Correction corrections1;

    //Completa o envio da correção 
    public static List<dsfs__docusign_Recipient_Status__C> updateRecipientsDS(List<String> contactArray,List<String> newemails,List<dsfs__docusign_Recipient_Status__C> recipientStatus,List<String> ids){
        
        corrections1 = new DocuSignAPI.Correction();
        corrections1.EnvelopeID = recipientStatus[0].dsfs__Parent_Status_Record__r.dsfs__DocuSign_Envelope_ID__c;
        corrections1.RecipientCorrections = new DocuSignAPI.ArrayOfRecipientCorrection();
        corrections1.RecipientCorrections.RecipientCorrection = new DocuSignAPI.RecipientCorrection[recipientStatus.size()];
        System.debug('[RentingApplication - resendContractDocuSignCorrection()] - Envelope ID: ' + corrections1.EnvelopeID);

        List<String> listtoresend = new List<String>();
        integer i=0;
        List<dsfs__docusign_Recipient_Status__C> rsListToUpdate = new list<dsfs__docusign_Recipient_Status__C>();

        System.debug('newwmails: '+newemails);
        System.debug('recipientStatus: '+recipientStatus);

        for(dsfs__docusign_Recipient_Status__C rs : recipientStatus)
        { 
            for(integer j = 0; j<ids.size();j++){
                if(ids[j]==rs.dsfs__Contact__c)
                {
                    if(newemails[j]!=null)
                    {
                        System.debug('ids dos contactos por ordem: '+ids[j]);
                        listtoresend.add(newemails[j]);
                    }
                }
            }
        }
        //if(newemails.size()>recipientStatus.size())
        System.debug('listtoresend: '+listtoresend);

        for(dsfs__docusign_Recipient_Status__C rs:recipientStatus)
        { 
           // for(integer j = 0; j<contactArray.size();j++)
           // {
            DocuSignAPI.RecipientCorrection correction = new DocuSignAPI.RecipientCorrection();
            //Set values only to resend.

            correction.PreviousEmail = rs.dsfs__Docusign_Recipient_Email__c;
            correction.PreviousUserName = rs.Name;
            correction.PreviousRoutingOrder = (integer) rs.dsfs__DocuSign_Routing_Order__c;
            correction.CorrectedUserName = rs.Name;

            System.debug('Diferenças nos emails: antigo: '+rs.dsfs__Docusign_Recipient_Email__c+' atual: '+listtoresend[i]);


            System.debug('Email anterior: '+rs.dsfs__Docusign_Recipient_Email__c);
            System.debug('Para quem vai enviar: '+listtoresend[i]);
            correction.CorrectedEmail = listtoresend[i];
            rs.dsfs__Docusign_Recipient_Email__c = listtoresend[i];
                
            correction.resend = true;

            corrections1.RecipientCorrections.RecipientCorrection[i] = correction;
            rs.Date_Resended__c = Datetime.now();
            rs.correctedEmail__c=null;
            rsListToUpdate.add(rs);
          //  }
            i ++;
        }
         System.debug('corrections adicionados: '+i);
        //update rsListToUpdate;
        System.debug('[RentingApplication-->updateRecipients] listrecipeientStatusUpdated: '+rsListToUpdate);

        return rsListToUpdate;
    }

    public DocuSignAPI.EnvelopeStatus sendAutoContract(Id contractId){

        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        Blob pdfBlob;
        String CountryCode;

        application__c app = [SELECT id, name, Client_Signer_1__r.Id, Client_Signer_2__r.Id, 
                                  Client_Signer_3__r.Id, Candor_Signer__r.Id, 
                                  Vendor_Primary__r.Id, Client_Signer_1__r.email,
                                  Client_Signer_2__r.email, Client_Signer_3__r.email,  
                                  Candor_Signer__r.email, Vendor_Primary__r.email,
                                  Client_Signer_1__r.Name, Client_Signer_2__r.Name, 
                                  Client_Signer_3__r.Name, Candor_Signer__r.Name, 
                                  Vendor_Primary__r.Name, Client_Country_Code__c, 
                                  Vendor__r.Name, Contract_Sent__c, Personal_Guarantee__c,
                                  Payment_Method__c,AccClient__c, Client_Signer_1_Delivery_Certificate__r.email,
                                  Client_Signer_1_Delivery_Certificate__c, Client_Signer_1_Delivery_Certificate__r.Name
                              FROM application__c 
                              WHERE id=:appId];

        List<Attachment> doc = [SELECT Id, name, body, createdDate, parentID 
                                FROM attachment 
                                WHERE Id =:contractId AND parentID=:appID];

        if(doc.size()>0){
            pdfBlob = doc[0].Body;
        }else{ 
            System.debug('[RentingApplication - SendAuto] - Document with Id '+contractId+' for Application '+ app.Name+' not Found.');
            DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();
            es.Status = 'Not Found';
            //Utilities.LogIntegrationLongResponse( Datetime.now(), Datetime.now(), es.Status, 'CERTIFICATE_AUTO','',app.Id,'');
            return es;
        }   

        // Document
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
        document.Name =  'Auto de Aceitação ' + app.Name + ' - ' + appID;
        document.FileExtension = 'pdf';
        envelope.Documents = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0] = document;

        List<DocuSignAPI.Recipient> recipientList = new List<DocuSignAPI.Recipient>();
            List<DocuSignAPI.Tab> tabList = new List<DocuSignAPI.Tab>();
        if(app.Client_Country_Code__c == null || app.Client_Country_Code__c == ''){
            CountryCode = 'PT';
        }else{
            CountryCode = app.Client_Country_Code__c.substring(0, 2);
        }

        if(app.Client_Signer_1__r!=null || app.Client_Signer_1_Delivery_Certificate__c!=null){

            DocuSignAPI.Recipient Signer1 = new DocuSignAPI.Recipient();
            Signer1.ID = 1;
            Signer1.Type_x = 'Signer';
            Signer1.RoutingOrder = 1;
            Signer1.RoleName = 'Signer 1';

            //caso Certificate Signer n esteja preenchdio envia auto para o signer 1
            if(app.Client_Signer_1_Delivery_Certificate__c != null){
                Signer1 = CandorDocuments.createDocuSignRecipient(1,'Signer',1,'Signer 1', app.Client_Signer_1_Delivery_Certificate__r.email, app.Client_Signer_1_Delivery_Certificate__r.Name,app.AccClient__c,app.Client_Signer_1_Delivery_Certificate__c);
            }else{
                Signer1 = CandorDocuments.createDocuSignRecipient(1,'Signer',1,'Signer 1', app.Client_Signer_1__r.email, app.Client_Signer_1_Delivery_Certificate__r.Name,app.AccClient__c,app.Client_Signer_1_Delivery_Certificate__c);
            }

            Signer1.RequireIDLookup = false;
            recipientList.add(Signer1);

            // Tab
            DocuSignAPI.Tab tab1 = CandorDocuments.createDocuSignTab(1, 1,'SignHere','\\s1\\');
            DocuSignAPI.Tab tab1Date = CandorDocuments.createDocuSignTab(1, 1,'DateSigned','\\d1\\');

            /*if(app.Payment_Method__c==NULL){
                // Tab
                DocuSignAPI.Tab tabWB = new DocuSignAPI.Tab();
                tabWB.Type_x = 'Custom';
                tabWB.RecipientID = 1;
                tabWB.DocumentID = 1;
                tabWB.AnchorTabItem = new DocuSignAPI.AnchorTab();
                tabWB.AnchorTabItem.AnchorTabString = '\\WBIBAN\\'; 
                tabList.add(tabWB);
            }*/

            tabList.add(tab1);
            tabList.add(tab1Date);

        }else{
            System.debug('[RentingApplication - SendAuto] - Signer for Auto with Id '+contractId+' for Application '+ app.Name+' not Found.');
            DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();
            es.Status = 'Signer Not Found';
            //Utilities.LogIntegrationLongResponse( Datetime.now(), Datetime.now(), es.Status, 'CERTIFICATE_AUTO','',app.Id,'');
            return es;            
        }

        if(app.Vendor_Primary__r.Id!=null){
                
            /*Message__c subjectVendor = [Select Message_text__c, Message_code__c, Country_code__c 
                                        from Message__c 
                                        where Message_code__c='EMAIL_VENDOR_SUBJECT' and Country_code__c=:CountryCode ];*/

            
            DocuSignAPI.RecipientEmailNotification email = new DocuSignAPI.RecipientEmailNotification();
            string subject = 'Cópia do Auto de Aceitação: ' + app.Vendor__r.Name + ' - (' + app.Name + ')';
            email.Subject = subject.abbreviate(100);
            DocuSignAPI.Recipient Vendor = CandorDocuments.createDocuSignRecipient(5,'CarbonCopy',1,null,  app.Vendor_Primary__r.email,  app.Vendor_Primary__r.Name, app.vendor__c, app.Vendor_Primary__r.Id);
            Vendor.EmailNotification = email;
            recipientList.add(Vendor);
        }else{
            System.debug('[RentingApplication - SendAuto] - Vendor for Auto with Id '+contractId+' for Application '+ app.Name+' not Found.');
            DocuSignAPI.EnvelopeStatus es = new DocuSignAPI.EnvelopeStatus();
            es.Status = 'Vendor Not Found';
            //Utilities.LogIntegrationLongResponse( Datetime.now(), Datetime.now(), es.Status, 'CERTIFICATE_AUTO','',app.Id,'');
            return es;     
        } 
            
        envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignAPI.Recipient[recipientList.size()];
        for(integer i=0; i<recipientList.size(); i++){
            envelope.Recipients.Recipient[i] = recipientList[i];
        }
        
        envelope.Tabs = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab = new DocuSignAPI.Tab[tabList.size()];
        for(integer i=0; i<tabList.size(); i++){
            envelope.Tabs.Tab[i] = tabList[i];
        }
        
        //Riminder and expirations
        DocuSignAPI.Notification notification = new DocuSignAPI.Notification();
        notification.UseAccountDefaults = true; // use account default
        envelope.Notification = notification;        
        
        List<DocuSignAPI.CustomField> customFieldList = new List<DocuSignAPI.CustomField>();      
        //Put external ID -- AppID
        DocuSignAPI.CustomField field = CandorDocuments.createDocuSignCostumFields('DSFSSourceObjectId', appId, true); 
        customFieldList.add(field);
        //Put external ID -- AccountVendorID
        DocuSignAPI.CustomField fieldAcc = CandorDocuments.createDocuSignCostumFields('##SFAccount', app.Vendor__c, true);
        customFieldList.add(fieldAcc);
        //Put External ID - AccountClientID
        DocuSignAPI.CustomField fieldClientAcc = CandorDocuments.createDocuSignCostumFields('Client', app.AccClient__c, true);
        customFieldList.add(fieldClientAcc);
        
        DocuSignAPI.ArrayOfCustomField arrayOfCustomField = new DocuSignAPI.ArrayOfCustomField();
        arrayOfCustomField.CustomField  = new DocuSignAPI.CustomField[customFieldList.size()];
        arrayOfCustomField.CustomField = customFieldList;
        envelope.CustomFields = arrayOfCustomField;
        
        /*Message__c subject = [Select Message_text__c, Message_code__c, Country_code__c 
                              from Message__c 
                              where Message_code__c='EMAIL_SUBJECT' and Country_code__c=:CountryCode];*/
    
        envelope.Subject = 'Auto de Aceitação: ' + app.Vendor__r.Name + ' - (' + app.Name + ')';

        DocuSignAPI.EnvelopeStatus es = CandorDocuments.sendDocumentThroughDocuSign(envelope);
        
        if(es.status=='Sent'){
            app.Delivery_Certificate_Sent__c = date.today();
            update app;
        }

        return es;
     }


    //TODO: Obter info atravÃ©s do ID de contacto e nÃ£o pelo email.
    //NecessÃ¡rio fazer set no docusign api de forma a actualizar os contactos
    //no docusign recipient status para se poder fazer o match.
    public List<DocuSignInfo> getDocuSignInfo(){
        //Application__c app = [SELECT ID, Client_Signer_1__r.Email, Client_Signer_2__r.Email,Client_Signer_3__r.Email, Client_Signer_4__r.Email, Client_Signer_5__r.Email  FROM Application__c WHERE Id=:appID];
        Application__c app = application;
        List<String> emailList = new List<String>();
        emailList.add(app.Client_Signer_1__r.Email);
        emailList.add(app.Client_Signer_2__r.Email);
        emailList.add(app.Client_Signer_3__r.Email);
        emailList.add(app.Client_Signer_4__r.Email);
        emailList.add(app.Client_Signer_5__r.Email);
        emailList.add(app.Client_Signer_1_Delivery_Certificate__r.Email);

        List<String> contactIdList = new List<String>();  
        contactIdList.add(app.Client_Signer_1__c);
        contactIdList.add(app.Client_Signer_2__c);
        contactIdList.add(app.Client_Signer_3__c);      
        contactIdList.add(app.Client_Signer_4__c);
        contactIdList.add(app.Client_Signer_5__c);
        contactIdList.add(app.Client_Signer_1_Delivery_Certificate__c);

        List<dsfs__docusign_Status__c> docuSignStatus =[SELECT id, dsfs__subject__c, dsfs__Sent_Date_Time__c, dsfs__Completed_Date_Time__c,
                                                        dsfs__Envelope_Status__c, dsfs__DocuSign_Envelope_ID__c, dsfs__Voided_Date_Time__c,Deleted_by_partner__c,
                                                        (SELECT id, name, dsfs__Parent_Status_Record__c,dsfs__Date_Delivered__c , dsfs__Date_Declined__c, 
                                                        dsfs__Recipient_Status__c,dsfs__Docusign_Recipient_Email__c, dsfs__Contact__c, dsfs__Date_Sent__c, 
                                                        dsfs__Date_Signed__c , dsfs__docusign_recipient_id__c, dsfs__Account__c, date_Resended__c 
                                                        FROM R00NS0000000WUO2MAO__r WHERE (dsfs__Docusign_Recipient_Email__c IN :emailList OR dsfs__Contact__c IN :contactIdList))
                                                        FROM dsfs__docusign_Status__C 
                                                        WHERE docusign_application_status__c =:appID AND (dsfs__Envelope_Status__c NOT IN ('Voided', 'Deleted') AND Deleted_by_partner__c = false) ORDER BY CreatedDate DESC];

        Map<Id, dsfs__docusign_Status__c> docuSignMap = new Map<Id,dsfs__docusign_Status__c>(docuSignStatus);                                               
        Set<Id> dsSet = (docuSignMap).keySet();                                                 

        List<DocuSignInfo> dsInfoList = new List<DocuSignInfo>();

        //flag to get the last contracts created;
        boolean lastContractCreated = true;
        boolean lastAutoCreated = true;

        for(dsfs__docusign_Status__c ds : docuSignStatus){

            List<dsfs__DocuSign_Recipient_Status__c> docuSignRecipient = ds.R00NS0000000WUO2MAO__r;
            
            boolean isRentingContract = ds.dsfs__subject__c.contains('Contrato') && ds.dsfs__subject__c.contains('Renting'); 
            boolean isAuto = ds.dsfs__subject__c.contains('Auto') && ds.dsfs__subject__c.contains('Aceitação');
            
            if(isRentingContract && lastContractCreated){

                lastContractCreated = false;
                DocuSignInfo dsInfo = new DocuSignInfo();

                List<dsfs__DocuSign_Recipient_Status__c> listRecipientContract = new List<dsfs__DocuSign_Recipient_Status__c>();

                for(dsfs__DocuSign_Recipient_Status__c dsr : docuSignRecipient){
                    if(dsr.dsfs__Parent_Status_Record__c == ds.Id){
                        listRecipientContract.add(dsr);
                    }
                }

                dsInfo.type = CONTRACT_RENTING_NAME.toLowerCase().capitalize();
                dsInfo.Recipients = listRecipientContract;
                dsInfo.Status = ds;
                
                Attachment[] attchList = [SELECT ID, Name FROM Attachment WHERE ParentID =: appID AND NAME LIKE '%Contrato%Renting%' ORDER BY Createddate desc LIMIT 1];
                if(attchList.size()>0){
                    dsInfo.Attachment = attchList[0];
                }

                dsInfoList.add(dsInfo);
            }

            if(isAuto && lastAutoCreated){

                lastAutoCreated = false;
                DocuSignInfo dsInfo = new DocuSignInfo();

                List<dsfs__DocuSign_Recipient_Status__c> listRecipientContract = new List<dsfs__DocuSign_Recipient_Status__c>();

                for(dsfs__DocuSign_Recipient_Status__c dsr : docuSignRecipient){
                    if(dsr.dsfs__Parent_Status_Record__c == ds.Id){
                        listRecipientContract.add(dsr);
                    }
                }

                dsInfo.type = AUTO_NAME.toLowerCase().capitalize();
                dsInfo.Recipients = listRecipientContract;
                dsInfo.Status = ds;
                List<Attachment> attachList =[SELECT ID, Name FROM Attachment WHERE ParentID =: appID AND NAME LIKE '%Auto%Aceitação%' ORDER BY Createddate desc LIMIT 1];
                if(attachList.size()>0){
                    dsInfo.Attachment = attachList[0];
                }
                dsInfoList.add(dsInfo);
            }
        }
        return dsInfoList;
    }

    public Equipment__c addEquipment(Equipment__c equipment){

        if(equipment.Application__c==null) {equipment.Application__c = appID;}
        if(equipment.Account_Client__c==null){equipment.Account_Client__c = [SELECT AccClient__c FROM Application__c WHERE Id=:appID].AccClient__c;}
        if(equipment == null){equipment = new Equipment__c();}
        upsert equipment; 
        return equipment;
    }

    public boolean deleteEquipment(Equipment__c equipment){
        delete equipment;
        return true;
    }

   public boolean DeleteAllEquipments(){
        delete getEquipments();
        return true;
    }

    public List<Equipment__c> updateEquipments(List<Equipment__c> equipmentList){
        upsert equipmentList;
        return equipmentList;
    }

    public List<Equipment__c> getEquipments(){
        List<Equipment__c> equipmentList = [SELECT Equipment_Quantity__c, Equipment_Description__c, Equipment_Value__c, Account_Client__c,  Application__c, Equipment_Serial_Number__c
                                            FROM Equipment__c
                                            WHERE   Application__c=:appID Order by CreatedDate ASC];
        return equipmentList;
    }

    public boolean setPaymentMethod(String paymentMethod){
        Application__c app = new Application__c();
        app.Id = appID;
        app.Payment_Method__c = paymentMethod;
        update app;
        return true;
    }

    

    public appDownloads getAppAttachments(){
        
        Attachment[] attchList1 = [SELECT ID, Name /*Body, ContentType, Description*/ FROM Attachment WHERE ParentID =: appID AND NAME LIKE '%Contrato%Renting%' ORDER BY Createddate desc LIMIT 1];
        Attachment[] attchList2 = [SELECT ID, Name /*Body, ContentType, Description*/ FROM Attachment WHERE ParentID =: appID AND NAME LIKE '%Auto%Aceitação%' ORDER BY Createddate desc LIMIT 1];
        
        appDownloads appAttach = new appDownloads();

        if(attchList1.size() <= 0){

            List<dsfs__DocuSign_Status__c> envelope = [SELECT ID, dsfs__Subject__c FROM dsfs__DocuSign_Status__c WHERE Docusign_Application_Status__c =: appID AND dsfs__Subject__c LIKE '%Contrato%Renting%' ORDER BY Createddate desc LIMIT 1];
            
            if (envelope.size() > 0){
                ID envelopeID = envelope[0].id;
                Attachment[] attchList11 = [SELECT ID, Name /*Body, ContentType, Description*/  FROM Attachment WHERE ParentID =: envelopeID AND NAME LIKE '%Contrato%Renting%' ORDER BY Createddate desc LIMIT 1];
                if(attchList11.size() > 0){
                    appAttach.contratoAttchDownload = attchList11[0];
                 }
            }       
        }else{
            appAttach.contratoAttchDownload = attchList1[0];
        }

        if(attchList2.size() <= 0){
            
            List<dsfs__DocuSign_Status__c> envelope2 = [SELECT ID, dsfs__Subject__c FROM dsfs__DocuSign_Status__c WHERE Docusign_Application_Status__c =: appID AND dsfs__Subject__c LIKE '%Auto%Aceitação%' ORDER BY Createddate desc LIMIT 1];
            
            if (envelope2.size() > 0){
                ID envelopeID2 = envelope2[0].id;
                Attachment[] attchList22 = [SELECT ID, Name /*Body, ContentType, Description*/ FROM Attachment WHERE ParentID =: envelopeID2 AND NAME LIKE '%Auto%Aceitação%' ORDER BY Createddate desc LIMIT 1];
                if(attchList22.size() > 0){
                    appAttach.autoAttchDownload = attchList22[0];
                }
            }  
        }else{
            appAttach.autoAttchDownload = attchList2[0];
        }


        return appAttach;
    }


    public List<Attachment> getAttachments() {
        
        List<Attachment> attch = [SELECT ID, Name FROM Attachment WHERE ParentID =: appID];
        if ( attch.size() > 0){
            return attch;
        }
        return attch;

    }

    public static Vendor_Invoice__c getVendorInvoice(String appID){
       
        List<Vendor_Invoice__c> vendorInvoice = [SELECT ID, Submitted_Date__c, Account__c, 
                                                //Due_Date__c,  HP 16/03/2017 - removed. Due date of payable invoice is now system.today() 
                                                Invoice_Date__c, Invoice_Total__c, Status__c, 
                                                Submitted__c, Vendor_Invoice_Number__c 
                                                FROM Vendor_Invoice__c WHERE Application__c =: appID AND Status__c!='Canceled' ORDER BY CREATEDDATE DESC LIMIT 1];
        if(vendorInvoice.size()>0){
            return vendorInvoice[0];
        }else{
            return null;
        }
    } 

    public static Account getAccount(String appID){
       
        List<Account> vendorInvoice = [SELECT ID, Name, Company_Logo_Id__c 
                                                FROM Account WHERE Id =: appID ORDER BY CREATEDDATE DESC LIMIT 1];
        if(vendorInvoice.size()>0){
            return vendorInvoice[0];
        }else{
            return null;
        }
    } 


    public class DocuSignInfo{
        public String type;
        public dsfs__docusign_Status__c Status;
        public List<dsfs__DocuSign_Recipient_Status__c> Recipients;
        public Attachment Attachment;
    }


    public class appDownloads{
        public Attachment vendorInvoiceAttchDownload;
        public Attachment contratoAttchDownload;
        public Attachment autoAttchDownload;
    }

    /*public class info{ 

        public List<dsfs__DocuSign_Recipient_Status__c> Recipients;
        public dsfs__DocuSign_Status__c Status;
    }*/
   /* public DocuSignAPI.CorrectionStatus CorrectAndResendContractDocuSign(Id contractId, List<Contact> contacts){

        Set<Id> conId = (new Map<Id,SObject>(contacts)).keySet();

        Id DocuSignStatusId = [SELECT ID, ParentID FROM Attachment WHERE ID=:contractId].Id;
        ntact.Id){
                
            }
        }
        Map<Id, sObject> con = new Map<Id,sObject>(recipientStatus);  
        
        return null;                            
        dsfs__docusign_Status__C docuSignStatus = [SELECT id, docusign_application_status__r.name, dsfs__subject__c, dsfs__Sent_Date_Time__c,dsfs__Envelope_Status__c, dsfs__DocuSign_Envelope_ID__c,
                                                  (SELECT id, name, dsfs__Docusign_Recipient_Email__c, dsfs__Contact__c, dsfs__Date_Sent__c, dsfs__Date_Signed__c , dsfs__docusign_recipient_id__c
                                                  FROM R00NS0000000WUO2MAO WHERE dsfs__Contact__c IN :conId),
                                                  (SELECT ID FROM CombinedAttachments)  
                                                  FROM dsfs__docusign_Status__C 
                                                  WHERE docusign_application_status__c =:appID];

 List<dsfs__docusign_Recipient_Status__C> recipientStatus = [SELECT Id, Name, dsfs__Docusign_Recipient_Email__c, dsfs__Contact__c, dsfs__Date_Sent__c, dsfs__Date_Signed__c , dsfs__docusign_recipient_id__c,
                                                             dsfs__Parent_Status_Record__c , dsfs__Parent_Status_Record__r.dsfs__envelope_status__c 
                                                             FROM dsfs__docusign_Recipient_Status__C 
                                                             WHERE  dsfs__Parent_Status_Record__c =: DocuSignStatusId AND dsfs__Parent_Status_Record__r.docusign_application_status__c =:appId];

       //if(docuSignStatus.dsfs__DocuSign_Recipient_Status__r.size()>0){

       Map<Id, Contact> con = new Map<Id,Contact>(contacts);


        DocuSignAPI.RecipientCorrection recipientCorrection = new DocuSignAPI.RecipientCorrection();
        recipientCorrection.PreviousEmail = null;
        recipientCorrection.CorrectedEmail = 'hugo.mdsp@gmail.com';

       // }


        return null;
    }*/

    /*public void setEmailContact(string email, ID contactID){
        Contact con = [SELECT ID, Email FROM Contact WHERE ID =: contactID ];
        con.Email = email;
        update con;
    }*/

}