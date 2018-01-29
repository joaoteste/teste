public class c_CreateCollectionCase{
    
    public List<c2g__codaInvoice__c> m_Invoices {get;set;}    
    public Boolean m_HaveError {get;set;}    
    public List<AggregateResult> list_Account;
    public ApexPages.StandardSetController standardsetController {get;set;}  
    
    public c_CreateCollectionCase(ApexPages.StandardSetController controller){
        this.standardsetController = controller;  
    }
    
    public PageReference validate(){
        m_Invoices = standardsetController.getSelected();   
        
        if(!validaInvoice()){ return null; }
        else{        
            List<Billing_Contract__c> upd_BillContract = new List<Billing_Contract__c>();
            List<Application__c> upd_Application = new List<Application__c>();
            
            String s_Account = '';
            List<String> sIDapp = new list<String>();
            
            List<c2g__codaInvoice__c> tempSalesInvoice = [select id,c2g__Account__c, Collection_Case__c, Application__c, Days_Overdue__c, c2g__DueDate__c, c2g__InvoiceTotal__c from c2g__codaInvoice__c where id IN : m_Invoices];
            for(c2g__codaInvoice__c ci: tempSalesInvoice){ 
                s_Account = ci.c2g__Account__c;
                if(ci.Application__c!= null){
                    //appID = ci.Application__c;
                    sIDapp.add(ci.Application__c);
                }
            } 
            
            //Reminder Update
            List<String> sid_DunningAlert = new List<String>();
            List<Dunning_Alert__c> m_DunningAlert = new List<Dunning_Alert__c>();
            Map<String, String> map_CC_DunningAlert = new Map<String, String>();
            
            List<Collection_Case__c> m_cc = [select id, Amount_Claimed__c, Count_Dunning_Alert__c, (Select id From Dunning_Alerts__r where Status__c = 'Open' limit 1) from Collection_Case__c where Account__c =: s_Account  and Status__c = 'Open' limit 1];
            
            for(Collection_Case__c c: m_cc){
                if(!c.Dunning_Alerts__r.isEmpty()){ 
                    Dunning_Alert__c da = new Dunning_Alert__c();
                    da.id =c.Dunning_Alerts__r[0].id;
                    da.Amount_Claimed__c = c.Amount_Claimed__c;                    
                    da.Updated__c =true;
                    da.Updated_Date__c = system.today();
                    da.Updated_Text__c ='Atenção! Este aviso foi actualizado pois existem novas facturas em atraso.';
                    
                    sid_DunningAlert.add(da.id);            
                    m_DunningAlert.add(da); 
                    map_CC_DunningAlert.put(c.Id, c.Dunning_Alerts__r[0].id);
                }               
            }
            if(!m_DunningAlert.isEmpty()){
                update m_DunningAlert;
            }
            /*List<ATM_Reference__c> upd_atm = new List<ATM_Reference__c>(); 
            for(ATM_Reference__c atm: [Select id From ATM_Reference__c where MB_Payment_Status__c != 'Canceled' and MB_Payment_Status__c != 'Payed' and Dunning_Alert__c IN: sId_DunningAlert]){
                //Cancelar ATM
                ATM_Reference__c atmref = new ATM_Reference__c();
                atmref.id =atm.id;
                atmref.MB_Payment_Status__c ='Canceled';
                
                upd_atm.add(atmref);               
            }
            if(!upd_atm.isEmpty())
                update upd_atm;
            */
            List<c2g__codaInvoice__c> m_codas = new List<c2g__codaInvoice__c>();             
            
            List<Interest_Charged_Calculation__c> insICC = new List<Interest_Charged_Calculation__c>(); 
            List<Legal_Fees__c> legalFee = [SELECT Id, Interest_Rate__c, Judicial_Fees__c, Name FROM Legal_Fees__c where Name = 'Interest Rate' limit 1];
            Decimal ir_fee = 0;
            for(Legal_Fees__c lf : legalFee){
                ir_fee=lf.Interest_Rate__c/100;
            }
            //***
            if(m_cc.size() > 0){                
                for(c2g__codaInvoice__c ci: tempSalesInvoice){ 
                    c2g__codaInvoice__c coda = new c2g__codaInvoice__c();
                    coda.id = ci.id;
                    coda.Collection_Case__c = m_cc[0].id;
                    m_codas.add(coda); 
                    
                    
                    if(m_cc[0].Count_Dunning_Alert__c == 3 || m_cc[0].Count_Dunning_Alert__c == 4){
                        //Se 3rd ou 4th Interest_Charged_Calculation__c
                        Interest_Charged_Calculation__c icc = new Interest_Charged_Calculation__c();
                        
                        icc.Days_Overdue__c = ci.Days_Overdue__c;
                        icc.Invoice_Due_Date__c=ci.c2g__DueDate__c;                        
                        String sId_Dunning = map_CC_DunningAlert.get(m_cc[0].id);
                        icc.Dunning_Alert__c=sId_Dunning;
                        icc.Interest_Rate__c=ir_fee*100;
                        icc.Invoice_Value__c=ir_fee*ci.c2g__InvoiceTotal__c;               
                        icc.Sales_Invoice__c=ci.Id;                
                        if(ci.Days_Overdue__c > 0){
                            icc.Interest_Charged__c = (icc.Invoice_Value__c/365)*ci.Days_Overdue__c;                    
                        }else{
                            icc.Interest_Charged__c = 0; 
                        }
                        icc.Sales_Invoice_Total__c = ci.c2g__InvoiceTotal__c;
                        
                        insICC.add(icc);
                    } 
                }
                update m_codas;   
                if(!insICC.isEmpty()) 
                    insert insICC;  
                
                // List<Application__c> l_App = [Select id, Status__c from Application__c where id =: appID limit 1];
                List<Application__c> l_App = [Select id, Status__c from Application__c where id IN: sIDapp ];
                for(Application__c app:l_App){
                    Application__c ca = new Application__c();
                    ca.id = app.Id;
                    ca.Status__c = 'Contract - Arrears';
                    upd_Application.add(ca);                
                } 
                if(!upd_Application.isEmpty()) 
                    update upd_Application;  
                
                //List<Billing_Contract__c> billexists = [Select id, Application__r.Equipment_Cost__c  from Billing_Contract__c where Application__c =: appID limit 1];
                List<Billing_Contract__c> billexists = [Select id, Application__r.Equipment_Cost__c  from Billing_Contract__c where Application__c IN: sIDapp ];
                for(Billing_Contract__c bc: billexists){
                    Billing_Contract__c billContract = new Billing_Contract__c();
                    billContract.id = bc.id; 
                    billContract.Collection_Case__c = m_cc[0].id;
                    billContract.Equipment_Cost__c = bc.Application__r.Equipment_Cost__c;
                    upd_BillContract.add(billContract); 
                } 
                if(!upd_BillContract.isEmpty()) 
                    update upd_BillContract; 
                
                
                return new PageReference ('/'+m_cc[0].id);
            }else{
                if(s_Account != ''){
                    Collection_Case__c m_collectionCase = new Collection_Case__c();
                    m_collectionCase.Account__c = s_Account;  
                    //m_collectionCase.Status__c = 'Open';              
                    
                    insert m_collectionCase;
                }
                List<Collection_Case__c> m_ccNew = [select id from Collection_Case__c where Account__c =: s_Account  and Status__c = 'Open' limit 1];
                List<c2g__codaInvoice__c> upd_Invoice = new List<c2g__codaInvoice__c>(); 
                for(c2g__codaInvoice__c ci: tempSalesInvoice){ 
                    c2g__codaInvoice__c coda = new c2g__codaInvoice__c();
                    coda.id = ci.id;
                    coda.Collection_Case__c = m_ccNew[0].id;
                    upd_Invoice.add(coda); 
                }
                update upd_Invoice; 
                
                List<Application__c> l_App = [Select id, Status__c from Application__c where id IN: sIDapp ];
                for(Application__c app:l_App){
                    Application__c ca = new Application__c();
                    ca.id = app.Id;
                    ca.Status__c = 'Contract - Arrears';
                    upd_Application.add(ca);                
                } 
                if(!upd_Application.isEmpty()) 
                    update upd_Application;             
                
                List<Billing_Contract__c> billexists = [Select id, Application__r.Equipment_Cost__c from Billing_Contract__c where Application__c IN: sIDapp ];
                for(Billing_Contract__c bc: billexists){
                    Billing_Contract__c billContract = new Billing_Contract__c();
                    billContract.id = bc.id; 
                    billContract.Collection_Case__c = m_ccNew[0].id;
                    billContract.Equipment_Cost__c = bc.Application__r.Equipment_Cost__c;
                    upd_BillContract.add(billContract); 
                } 
                if(!upd_BillContract.isEmpty()) 
                    update upd_BillContract; 
                
                if(m_ccNew.size() > 0){
                    return new PageReference ('/'+m_ccNew[0].id);
                }else{return null;}                
            }            
        }       
    }
    
    public boolean validaInvoice(){        
        String m_ErrorMsg = '<b>Information:</b>\n<br/>';
        m_HaveError = false;        
        if(validaAccount()>1){
            m_ErrorMsg += '- You can only select invoices from the same account.';
            m_HaveError = true;    
        }        
        if(m_HaveError){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, m_ErrorMsg);
            ApexPages.addMessage(myMsg);
            return false;
        } else return true; 
    }
    
    public Integer validaAccount(){
        list_Account = [select count(id), c2g__Account__c From c2g__codaInvoice__c where id =:m_Invoices Group By c2g__Account__c];
        Integer mCounter = 0;
        for(AggregateResult ar :list_Account){
            ++ mCounter; 
        }
        return mCounter;
    }
}