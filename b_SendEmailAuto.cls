global class b_SendEmailAuto implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.AllowsCallouts{

    public b_SendEmailAuto(){
    }    
    
    global void execute(SchedulableContext SC){        
        b_SendEmailAuto b = new b_SendEmailAuto(); 
        database.executebatch(b,10);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        return Database.getQueryLocator([SELECT Id,Account__c,Invoices_Due__c, Amount_Claimed__c, Count_Dunning_Alert__c, Personal_Guarantee_Signer_1__c, Personal_Guarantee_Signer_2__c, (Select Id, Status__c, Dunning_Level__c, Sent_Date__c, Level__c, Due_Date__c, Email_Send_Date__c, Collection_Case__r.Account__c,Amount_Claimed__c From Dunning_Alerts__r where Status__c = 'Open' order by Level__c desc limit 1) FROM Collection_Case__c where Status__c = 'Open' and Dunning_Enabled__c = false and Flow__c = 'Automatic' ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Collection_Case__c> cCase){     

        List<ID> sId_Account = new List<ID>();
        List<ID> sId_SignerContacts = new List<ID>();
        
        //Dunning Admins by level
        Map<String,Dunning_Admin__c> daLevel = new Map<String,Dunning_Admin__c>();
        List<Dunning_Admin__c> DAdmin = [Select Id, Dunning_Level__c, Past_Due_Days__c,Nr_of_Days_to_Pay__c,Dunning_Frequency__c,Active__c, Email_Template__c, Personal_Guarantee_Email_Template__c From Dunning_Admin__c where Active__c='Yes'];
        
        for(Dunning_Admin__c da : DAdmin){
            daLevel.put(da.Dunning_Level__c, da);
        }
        system.debug(daLevel);
        //DA list to send emails
        //List<Dunning_Alert__c> dasToUpdate = new List<Dunning_Alert__c>();
        List<Dunning_Alert__c> sendEmailDA = new List<Dunning_Alert__c>();
        List<Dunning_Alert__c> sendEmailDA_update = new List<Dunning_Alert__c>();
        
        Date sendEmailDate = date.today();
        //Date sendEmailDate = date.newInstance(2017, 3, 25);
        if(Test.isRunningTest())
            sendEmailDate=date.today().addDays(-8);
        
        /*List<Id> idsDasUpdate = new List<Id>();
        for(Collection_Case__c ccDas : cCase){
            if(!ccDas.Dunning_Alerts__r.isEmpty()){
                Dunning_Alert__c DAlertDas = ccDas.Dunning_Alerts__r;
                idsDasUpdate.add(DAlertDas.id);
            }
        }

        List<Dunning_Alert__c> dasAfterUpdated = [Select id,Amount_Claimed__c,Due_Date__c, (Select id, name, MB_Payment_Status__c from ATM_References__r) From Dunning_Alert__c where id in : idsDasUpdate ];
        
        Map<String,ATM_Reference__c> m_da_atm = new Map<String,ATM_Reference__c>();
        
        for(Dunning_Alert__c daRow : dasAfterUpdated){
            List<ATM_Reference__c> atmList = daRow.ATM_References__r; 
            for(ATM_Reference__c atmRow : atmList){
                if(!m_da_atm.containsKey(daRow.Id))
                {
                    m_da_atm.put(daRow.Id, atmRow);
                }
            }
        }*/
        
        for(Collection_Case__c cc : cCase){
            sId_Account.add(cc.Account__c);
            if(cc.Personal_Guarantee_Signer_1__c != null){
                sId_SignerContacts.add(cc.Personal_Guarantee_Signer_1__c);
            }
            if(cc.Personal_Guarantee_Signer_2__c != null){
                sId_SignerContacts.add(cc.Personal_Guarantee_Signer_2__c);
            }
            if(!cc.Dunning_Alerts__r.isEmpty()){
                Dunning_Alert__c DAlert = cc.Dunning_Alerts__r;
                if(Test.isRunningTest()){
                    Dunning_Admin__c DAdmin_level = daLevel.get(DAlert.Dunning_Level__c);                         
                    Dunning_Alert__c DAlert_update = new Dunning_Alert__c();                        
                    sendEmailDA_update.add(validateSendEmail(DAlert, DAdmin_level.Dunning_Frequency__c));                        
                    sendEmailDA.add(DAlert);
                }
                else{
                    if(DAlert.Email_Send_Date__c == sendEmailDate){
                        Dunning_Admin__c DAdmin_level = daLevel.get(DAlert.Dunning_Level__c);                         
                        Dunning_Alert__c DAlert_update = new Dunning_Alert__c();                        
                        sendEmailDA_update.add(validateSendEmail(DAlert, DAdmin_level.Dunning_Frequency__c));                        
                        sendEmailDA.add(DAlert);
                    }
                    /*ATM_Reference__c atmDa = m_da_atm.get(DAlert.Id);
                    if(DAlert.Email_Send_Date__c == sendEmailDate && DAlert.Amount_Claimed__c == cc.Amount_Claimed__c && atmDa.Amount__c == cc.Amount_Claimed__c){
                        Dunning_Admin__c DAdmin_level = daLevel.get(DAlert.Dunning_Level__c);                         
                        Dunning_Alert__c DAlert_update = new Dunning_Alert__c();                        
                        sendEmailDA_update.add(validateSendEmail(DAlert, DAdmin_level.Dunning_Frequency__c));                        
                        sendEmailDA.add(DAlert);
                    }
                    else if((DAlert.Email_Send_Date__c == sendEmailDate && DAlert.Amount_Claimed__c != cc.Amount_Claimed__c) || (DAlert.Email_Send_Date__c == sendEmailDate && atmDa.Amount__c != cc.Amount_Claimed__c)){
                        DAlert.Amount_Claimed__c = cc.Amount_Claimed__c;
                        DAlert.Email_Send_Date__c = sendEmailDate.addDays(1);
                        dasToUpdate.add(DAlert);
                    }*/
                }
            }                
            }
        
        
        Map<String, List<Contact>> DA_contacts = new Map<String, List<Contact>>();
        Map<String, Contact> DA_contactsSigner = new Map<String, Contact>();
        List<Contact> l_contact = [Select Id,AccountId,Email From Contact where AccountID in: sId_Account and Email != 'change_me@email.com' and Email != null AND Collections_Email_Opt_Out__c = false];
        List<Contact> l_SignerContacts = [Select Id,AccountId,Email From Contact where id in: sId_SignerContacts and Email != 'change_me@email.com' and Email != null AND Collections_Email_Opt_Out__c = false];

        for(Contact c: l_contact){
            if(DA_contacts.containsKey(c.AccountId)){
                DA_contacts.get(c.AccountId).add(c);
            }
            else{
                List<Contact> lst = new List<Contact>();
                lst.add(c);
                DA_contacts.put(c.AccountId, lst);
            }          
        } 
        //contactos fiadores
        for(Contact c: l_SignerContacts){
            if(!DA_contacts.containsKey(c.id)){
                DA_contactsSigner.put(c.id, c);
            }        
        } 

        for(Dunning_Alert__c emails : sendEmailDA){
            Dunning_Admin__c DAdmin_level = daLevel.get(emails.Dunning_Level__c);
            String sTemplate = DAdmin_level.Email_Template__c;
            String sTemplate4thReminder = DAdmin_level.Personal_Guarantee_Email_Template__c;
            Date sPastDueDate = emails.Due_Date__c;
            List<Contact> email_list = DA_contacts.get(emails.Collection_Case__r.Account__c);

            CreateTableInvoice.CreateTable(emails.Id,emails.Collection_Case__c);
            
            c_SendEmail.sendEmailDunningAlert(emails.Id, /*sTemplate,*/ email_list, sPastDueDate, sTemplate);
            
            String level = DAdmin_level.Dunning_Level__c;
            if(level.equalsIgnoreCase('4Th Reminder')){
                List<Contact> email_listSigner = new List<Contact>();
                Contact signer1 = DA_contactsSigner.get(emails.Collection_Case__r.Personal_Guarantee_Signer_1__c);
                Contact signer2 = DA_contactsSigner.get(emails.Collection_Case__r.Personal_Guarantee_Signer_2__c);
                if(signer1 != null){
                    email_listSigner.add(signer1);
                }
                if(signer2 != null){
                    email_listSigner.add(signer2);
                }
                if(!email_listSigner.isEmpty()){
                    c_sendemail.sendEmailDunningAlert(emails.Id, /*sTemplate,*/ email_listSigner, sPastDueDate, sTemplate4thReminder);
                }
            }
        }
        
        /*List<ATM_Reference__c> listATM = new List<ATM_Reference__c>();
        if(dasToUpdate.isEmpty()){
            update dasToUpdate;
            
            
            for(Dunning_Alert__c daRow : dasAfterUpdated){
                List<ATM_Reference__c> atmList = daRow.ATM_References__r; 
                for(ATM_Reference__c atmRow : atmList){
                    Bill_EasyPayAPI billEasyPay = new Bill_EasyPayAPI();
                    if(!Test.isRunningTest()){
                        listATM.add(billEasyPay.getNewMBReference(String.ValueOf(daRow.Amount_Claimed__c), Date.valueOf(daRow.Due_Date__c), daRow.id, 'DunningAlert'));
                    }else{
                        ATM_Reference__c atm = new ATM_Reference__c();
                        listATM.add(atm);
                    }
                }
            }
        }
        
        if(!listATM.isEmpty()){  
            system.debug('AQUI listATM ' + listATM);
            try{
                insert listATM;
                
                PaymentCollection_Utils pcUtils = new PaymentCollection_Utils();
                pcUtils.createPaymentCollectionWithATM(listATM);
                
            }catch(Exception e){
                system.debug('Erro EasyPay');          
            }            
        }*/
        
        if(!sendEmailDA_update.isEmpty())
            update sendEmailDA_update;           
    }
    
     public Dunning_Alert__c validateSendEmail(Dunning_Alert__c DAlert, Decimal eDFrequency){        
        
        //Date nextEmailDate = DAlert.Sent_Date__c.addDays(Integer.valueof(eDFrequency));
        Date nextEmailDate = DAlert.Email_Send_Date__c.addDays(Integer.valueof(eDFrequency));
        //email date = ok
        if(nextEmailDate < DAlert.Due_Date__c){
            DAlert.Email_Send_Date__c=nextEmailDate;
        } else{
            DAlert.Status__c='Close';
        }           
        return DAlert;
    }
    
    global void finish(Database.BatchableContext BC){      
         
    }
}