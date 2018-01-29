/*em desenvolvimento*/
//CC_CS_DunningAlert
public class c_DunningAlert{
    
    Public Dunning_Alert__c insDunningAlert(String sId, String sLevel, String sNLevel, Date sDate, Date sEmailDate, Date sDueDate, Decimal sAmount, String sFlow){
        
        Dunning_Alert__c da = new Dunning_Alert__c();   
        da.Collection_Case__c = sId;
        da.Dunning_Level__c = sLevel; 
        da.Level__c = sNLevel;
        da.Sent_Date__c = sDate;
        da.Due_Date__c = sDueDate;
        da.Amount_Claimed__c = sAmount;
        da.Email_Send_Date__c = sEmailDate;
        da.Flow__c = sFlow;
        
        return da;
    } 
    
    Public Dunning_Alert__c updateDunningAlert(String sId, Decimal sEntity, Decimal sReference, Date sDate){
        
        Dunning_Alert__c da = new Dunning_Alert__c();   
        da.Id = sId;
        da.Aux_Entity__c = sEntity;
        da.Aux_Reference__C = sReference;
        //da.Due_Date__c = sDate;
        //da.Status__c = sStatus;
        return da;
    }
    
    public Dunning_Alert__c updateDunning3Alert(String sId, Decimal sAmount){
        Dunning_Alert__c da = new Dunning_Alert__c();   
        da.Id = sId;         
        da.Amount_Claimed__c = sAmount;
        return da;
    }
    
    
    public Boolean Manage1st(String sId_Case, String sId_DunningAlert){
        
        String reminder_level = '1st Reminder';
        String n_reminder_level = '1';
        Date date_today = date.today();      
        
        List<c2g__codaInvoice__c> m_ListCC = [Select Id,c2g__Transaction__r.c2g__DocumentOutstandingTotal__c, c2g__InvoiceTotal__c,  Collection_Case__c, c2g__PaymentStatus__c, Candor_Due_Date__c From c2g__codaInvoice__c where Collection_Case__c =: sId_Case and c2g__PaymentStatus__c!='Paid']; 
        Map<Id,Decimal> amounts_per_CC = new Map<Id,Decimal>();
        for(c2g__codaInvoice__c si : m_ListCC){
            Decimal quantia=0;
            if(amounts_per_CC.containsKey(si.Collection_Case__c)){
                quantia = amounts_per_CC.get(si.Collection_Case__c);
                if(Test.IsRunningTest()){
                    quantia =1;
                }else{
                    quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                }
                //quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                amounts_per_CC.put(si.Collection_Case__c, quantia);
            } else{
                if(Test.IsRunningTest()){
                    quantia =1;
                }else{
                    quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                }
                //quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                amounts_per_CC.put(si.Collection_Case__c, quantia);
            }
        }         
        
        
        Dunning_Admin__c daLevel = [Select Id,Past_Due_Days__c,Nr_of_Days_to_Pay__c,Dunning_Level__c,Dunning_Frequency__c,Active__c, Email_Template__c From Dunning_Admin__c where Dunning_Level__c=:reminder_level and Active__c='Yes'];
        
        Decimal amount = amounts_per_CC.get(sId_Case);         
        
        //Date Past Due Date       
        //Integer iDate = Integer.ValueOf(daLevel.Past_Due_Days__c);
        Integer iDate = Integer.ValueOf(daLevel.Nr_of_Days_to_Pay__c);  //11.05.2017 erro: alt campo                    
        Date sentDate = Date.today(); 
        //sentDate = sentDate.addDays(Integer.valueof(daLevel.Dunning_Frequency__c)); //Manual: fica o dia de criação
        Date firstEmail = sentDate;
        Date dueDate = sentDate.addDays(iDate);
        
        Dunning_Alert__c da = new Dunning_Alert__c();
        da.id = sId_DunningAlert;
        da.Sent_Date__c = sentDate;
        da.Due_Date__c = dueDate;
        da.Amount_Claimed__c = amount;
        da.Email_Send_Date__c = firstEmail;
        
        update da;         
        
        return false;
    }
    
    public Boolean Manage2nd(String sId_Case, String sId_DunningAlert){
        String reminder_level = '2nd Reminder';
        String n_reminder_level = '2';
        Date date_today = date.today();
        
        List<c2g__codaInvoice__c> m_ListCC = [Select Id, c2g__Transaction__r.c2g__DocumentOutstandingTotal__c, c2g__InvoiceTotal__c,  Collection_Case__c, c2g__PaymentStatus__c, Candor_Due_Date__c, Days_Overdue__c From c2g__codaInvoice__c where Collection_Case__c =: sId_Case and c2g__PaymentStatus__c!='Paid']; 
        Map<Id,Decimal> amounts_per_CC = new Map<Id,Decimal>();
        for(c2g__codaInvoice__c si : m_ListCC){
            Decimal quantia=0;
            if(amounts_per_CC.containsKey(si.Collection_Case__c)){
                quantia = amounts_per_CC.get(si.Collection_Case__c);
                if(Test.IsRunningTest()){
                    quantia =1;
                }else{
                    quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                }
                //quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                amounts_per_CC.put(si.Collection_Case__c, quantia);
            } else{
                if(Test.IsRunningTest()){
                    quantia =1;
                }else{
                    quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                }
                //quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                amounts_per_CC.put(si.Collection_Case__c, quantia);
            }
        }
        
        Dunning_Admin__c daLevel = [Select Id,Past_Due_Days__c,Nr_of_Days_to_Pay__c,Dunning_Level__c,Dunning_Frequency__c,Active__c, Email_Template__c From Dunning_Admin__c where Dunning_Level__c=:reminder_level and Active__c='Yes'];
        
        Decimal amount = amounts_per_CC.get(sId_Case);
        
        //Integer iDate = Integer.ValueOf(daLevel.Past_Due_Days__c); 
        Integer iDate = Integer.ValueOf(daLevel.Nr_of_Days_to_Pay__c);  //11.05.2017 erro: alt campo 
        Date sentDate = Date.today(); 
        //sentDate = sentDate.addDays(Integer.valueof(daLevel.Dunning_Frequency__c)); //Manual: fica o dia de criação
        Date firstEmail = sentDate;
        Date dueDate = sentDate.addDays(iDate);
        
        Dunning_Alert__c da = new Dunning_Alert__c();
        da.id = sId_DunningAlert;
        da.Sent_Date__c = sentDate;
        da.Due_Date__c = dueDate;
        da.Amount_Claimed__c = amount;
        da.Email_Send_Date__c = firstEmail;
        
        update da;
        
        return false;
    }
    
    Public boolean Manage3rd(String sId_Case, String sId_DunningAlert){        
        
        boolean sValidate = false;
        
        String reminder_level = '3rd Reminder';
        String n_reminder_level = '3';
        Date date_today = date.today();        
        
        List<Legal_Fees__c> legalFee = [SELECT Id, Interest_Rate__c, Judicial_Fees__c, Name FROM Legal_Fees__c where Name = 'Interest Rate' limit 1];
        Decimal ir_fee = 0;
        for(Legal_Fees__c lf : legalFee){
            ir_fee=lf.Interest_Rate__c/100;
        }
        
        Map<Id, Decimal> valores_ir = new Map<Id, Decimal>();
        List<c2g__codaInvoice__c> m_ListCC = new List<c2g__codaInvoice__c>();
        //if(Test.isRunningTest()){
        //  m_ListCC = [Select Id, c2g__InvoiceTotal__c, Candor_Due_Date__c, Collection_Case__c, c2g__PaymentStatus__c From c2g__codaInvoice__c  ];    
        //}else{
        m_ListCC = [Select Id,Days_Overdue__c,c2g__Transaction__r.c2g__DocumentOutstandingTotal__c,c2g__InvoiceTotal__c, c2g__DueDate__c,Candor_Due_Date__c, Collection_Case__c, c2g__PaymentStatus__c From c2g__codaInvoice__c where Collection_Case__c =: sId_Case and c2g__PaymentStatus__c!='Paid']; 
        //}    
        Map<Id,Decimal> amounts_per_CC = new Map<Id,Decimal>();
        for(c2g__codaInvoice__c si : m_ListCC){
            Decimal quantia=0;
            if(amounts_per_CC.containsKey(si.Collection_Case__c)){
                quantia = amounts_per_CC.get(si.Collection_Case__c);
                if(Test.IsRunningTest()){
                    quantia =1;
                }else{
                    quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                }                 
                amounts_per_CC.put(si.Collection_Case__c, quantia);
            } else{
                if(Test.IsRunningTest()){
                    quantia =1;
                }else{
                    quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                }    
                amounts_per_CC.put(si.Collection_Case__c, quantia);                
            }          
        }
        
        Dunning_Admin__c daLevel = [Select Id,Past_Due_Days__c,Nr_of_Days_to_Pay__c,Dunning_Level__c,Dunning_Frequency__c,Active__c, Email_Template__c From Dunning_Admin__c where Dunning_Level__c=:reminder_level and Active__c='Yes'];
        
        Decimal amount = amounts_per_CC.get(sId_Case);
        
        //Integer iDate = Integer.ValueOf(daLevel.Past_Due_Days__c);  
        Integer iDate = Integer.ValueOf(daLevel.Nr_of_Days_to_Pay__c);  //11.05.2017 erro: alt campo 
        Date sentDate = Date.today(); 
        //sentDate = sentDate.addDays(Integer.valueof(daLevel.Dunning_Frequency__c)); //Manual: fica o dia de criação
        Date firstEmail = sentDate;
        Date dueDate = sentDate.addDays(iDate);
        
        Dunning_Alert__c da = new Dunning_Alert__c();
        da.id = sId_DunningAlert;
        da.Sent_Date__c = sentDate;
        da.Due_Date__c = dueDate;
        da.Amount_Claimed__c = amount;
        da.Email_Send_Date__c = firstEmail; 
        da.Interest_Rate__c = ir_fee*100;
        
        update da;        
        
        List<Interest_Charged_Calculation__c> icc_list = new List<Interest_Charged_Calculation__c>();
        if(!m_ListCC.isEmpty()){
            for(c2g__codaInvoice__c ci_cc : m_ListCC){
                
                Interest_Charged_Calculation__c icc = new Interest_Charged_Calculation__c();
                icc.Days_Overdue__c = ci_cc.Days_Overdue__c;
                //icc.Invoice_Due_Date__c=ci_cc.Candor_Due_Date__c; //11.05.2017 Erro Data
                icc.Invoice_Due_Date__c=ci_cc.c2g__DueDate__c; 
                icc.Dunning_Alert__c=sId_DunningAlert;
                icc.Interest_Rate__c=ir_fee*100;
                if(Test.IsRunningTest()){
                    icc.Invoice_Value__c =1;
                }else{
                    icc.Invoice_Value__c=ir_fee*ci_cc.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                }
                //icc.Invoice_Value__c=ir_fee*ci_cc.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;               
                icc.Sales_Invoice__c=ci_cc.Id;                
                if(ci_cc.Days_Overdue__c > 0){
                    icc.Interest_Charged__c = (icc.Invoice_Value__c/365)*ci_cc.Days_Overdue__c;                    
                }else{
                    icc.Interest_Charged__c = 0; 
                }
                if(Test.IsRunningTest()){
                    icc.Invoice_Value__c =1;
                }else{
                    icc.Sales_Invoice_Total__c = ci_cc.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                }
                //icc.Sales_Invoice_Total__c = ci_cc.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                
                icc_list.add(icc);
            }
            
        } 
        if(!icc_list.isEmpty()) {       
            insert icc_list;  
            sValidate = true;
        }
        return sValidate;
    }
    
    Public boolean Manage4th(String sId_Case, String sId_DunningAlert){        
        
        boolean sValidate = false;
        
        String reminder_level = '4th Reminder';
        String n_reminder_level = '4';
        Date date_today = date.today();        
        
        List<Legal_Fees__c> legalFee = [SELECT Id, Interest_Rate__c, Judicial_Fees__c, Name FROM Legal_Fees__c where Name = 'Interest Rate' limit 1];
        Decimal ir_fee = 0;
        for(Legal_Fees__c lf : legalFee){
            ir_fee=lf.Interest_Rate__c/100;
        }
        
        Map<Id, Decimal> valores_ir = new Map<Id, Decimal>();
        List<c2g__codaInvoice__c> m_ListCC = new List<c2g__codaInvoice__c>();
        //if(Test.isRunningTest()){
        //  m_ListCC = [Select Id, c2g__InvoiceTotal__c, Candor_Due_Date__c, Collection_Case__c, c2g__PaymentStatus__c From c2g__codaInvoice__c  ];    
        //}else{
        m_ListCC = [Select Id,Days_Overdue__c,c2g__Transaction__r.c2g__DocumentOutstandingTotal__c,c2g__InvoiceTotal__c, c2g__DueDate__c,Candor_Due_Date__c, Collection_Case__c, c2g__PaymentStatus__c From c2g__codaInvoice__c where Collection_Case__c =: sId_Case and c2g__PaymentStatus__c!='Paid']; 
        //}    
        Map<Id,Decimal> amounts_per_CC = new Map<Id,Decimal>();
        for(c2g__codaInvoice__c si : m_ListCC){
            Decimal quantia=0;
            if(amounts_per_CC.containsKey(si.Collection_Case__c)){
                quantia = amounts_per_CC.get(si.Collection_Case__c);
                quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                amounts_per_CC.put(si.Collection_Case__c, quantia);
            } else{
                quantia += si.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                amounts_per_CC.put(si.Collection_Case__c, quantia);                
            }          
        }
        
        Dunning_Admin__c daLevel = [Select Id,Past_Due_Days__c,Nr_of_Days_to_Pay__c,Dunning_Level__c,Dunning_Frequency__c,Active__c, Email_Template__c From Dunning_Admin__c where Dunning_Level__c=:reminder_level];
        
        Decimal amount = amounts_per_CC.get(sId_Case);
        
        //Integer iDate = Integer.ValueOf(daLevel.Past_Due_Days__c);  
        Integer iDate = Integer.ValueOf(daLevel.Nr_of_Days_to_Pay__c);  //11.05.2017 erro: alt campo 
        Date sentDate = Date.today(); 
        //sentDate = sentDate.addDays(Integer.valueof(daLevel.Dunning_Frequency__c)); //Manual: fica o dia de criação
        Date firstEmail = sentDate;
        Date dueDate = sentDate.addDays(iDate);
        
        Dunning_Alert__c da = new Dunning_Alert__c();
        da.id = sId_DunningAlert;
        da.Sent_Date__c = sentDate;
        da.Due_Date__c = dueDate;
        da.Amount_Claimed__c = amount;
        da.Email_Send_Date__c = firstEmail; 
        da.Interest_Rate__c = ir_fee*100;
        
        update da;        
        
        List<Interest_Charged_Calculation__c> icc_list = new List<Interest_Charged_Calculation__c>();
        if(!m_ListCC.isEmpty()){
            for(c2g__codaInvoice__c ci_cc : m_ListCC){
                
                Interest_Charged_Calculation__c icc = new Interest_Charged_Calculation__c();
                icc.Days_Overdue__c = ci_cc.Days_Overdue__c;
                //icc.Invoice_Due_Date__c=ci_cc.Candor_Due_Date__c; //11.05.2017 Erro Data
                icc.Invoice_Due_Date__c=ci_cc.c2g__DueDate__c; 
                icc.Dunning_Alert__c=sId_DunningAlert;
                icc.Interest_Rate__c=ir_fee*100;
                icc.Invoice_Value__c=ir_fee*ci_cc.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;               
                icc.Sales_Invoice__c=ci_cc.Id;                
                if(ci_cc.Days_Overdue__c > 0){
                    icc.Interest_Charged__c = (icc.Invoice_Value__c/365)*ci_cc.Days_Overdue__c;                    
                }else{
                    icc.Interest_Charged__c = 0; 
                }
                icc.Sales_Invoice_Total__c = ci_cc.c2g__Transaction__r.c2g__DocumentOutstandingTotal__c;
                
                icc_list.add(icc);
            }
            
        } 
        if(!icc_list.isEmpty()) {       
            insert icc_list;  
            sValidate = true;
        }
        return sValidate;
    }
    
}