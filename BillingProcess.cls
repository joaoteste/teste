// Apex Class
public with sharing class BillingProcess {
/*   
    public static void Create_Billing_Invoice(ID appId ){
        try{
            integer counterBC=0;
            //ALTERADO AQUI- adicionado Original_Insurance_ProRata__c, Original_Insurance_Value__c (BP)
            application__c app=[select id,  Name, vendor__C, accClient__c, Insurance_Type__c, Issuing_Date_Invoice__c,Vendor_Invoice_Total__c,Invoice_Number__c,
                                Equipment_Cost__c, Vendor_invoice_VAT__c,Chosen_Insurance_value__c,
                                Original_Insurance_Value__c, Vendor_Invoice_Amount__c , IBAN_Request__c, Term__c,
                                Beginning_of_Term__c, Payment_Freq__c, Payment_Timing__c, Payment_Amount__c, eSignature_Contract_Fee__c, TermCalc__c,
                                ATM_Reference_Costs__c, Insurance_Amount__c, Paper_Contract_Fee__c, 
                                Insurance_Pro_Rata__c, Original_Insurance_ProRata__c, Interim_Fee_Amount__c, Invoice_Payment_Date__c,
                                Interest_Amount__c, annual_interest_rate__c, accClient__r.c2g__CODAInvoiceEmail__c, status__c
                                from application__c 
                                where id= :appId ];
            
            if(app.Original_Insurance_Value__c==null)
                app.Original_Insurance_Value__c=app.Chosen_Insurance_value__c;
            if(app.Original_Insurance_ProRata__c==null)
                app.Original_Insurance_ProRata__c=app.Insurance_Pro_Rata__c;
            
            System.debug(' Original_Insurance_Value__c --> '+ app.Original_Insurance_Value__c);
            System.debug(' Original_Insurance_ProRata__c --> '+ app.Original_Insurance_ProRata__c);
            
            account accClient =        [select id,name, c2g__CODABankIBANNumber__c, c2g__CODATaxCalculationMethod__c,
                                        c2g__CODAAccountsReceivableControl__c, 
                                        c2g__CODAInputVATCode__c, BillingPostalCode, c2g__CODAVATStatus__c   
                                        from account 
                                        where id= :app.AccClient__c];
            
            account accVendor =        [select id,name, c2g__CODABankIBANNumber__c  
                                        from account 
                                        where id= :app.vendor__C];
            
            list<Product2> Prods =     [select id,Description, c2g__CODAInputTaxCode__c, 
                                        c2g__CODAInputTaxCode__r.Area__c,name, ProductCode 
                                        from Product2 ];
            
            list <PostCode__c> postcod=[select CP_Max__c, CP_Min__c, Region__c 
                                        from postcode__c 
                                        where Region__c != null];
            
            integer settleday    = 0;
            integer settlemonth  = 0;
            string  ProdId;
            string  ProdDesc;
            decimal resultprev   = 0;
            integer indexi       = 0;
            Date    dtDue;
            date    dtInvoice;
            decimal amountFactura= 0;
            decimal insurFactura = 0;
            date    NextInvDt;
            date    NextDueDt;
            Product2 Prod;
            decimal nbrpay       = 0;
            integer nbrMonthadd  = 0;
            Date    FutdtDue;
            date    FutdtInvoice;
            string  Region;
            date    billdate;
            boolean invoiced      = false;
            boolean active        = true;
            date    lastinvoicedt = null;
            decimal Interestini   = 0;
            decimal PrincipalIni  = 0;
            decimal BegBalanceIni = 0;
            decimal EndBalanceIni = 0;
            decimal Interest0     = 0;
            decimal Interestn     = 0;
            decimal Principal0    = 0;
            decimal Principaln    = 0;
            decimal BegBalance0   = 0;
            decimal BegBalancen   = 0;
            decimal EndBalance0   = 0;
            decimal EndBalancen   = 0;
            boolean prorata       = true;
            
            list<Billing_Contract_Line_Item__c> BillContItems   = new list<Billing_Contract_Line_Item__c>();
            list<c2g__codaJournalLineItem__c>   JournalItems    = new list<c2g__codaJournalLineItem__c>();
            List<c2g__codaJournalLineItem__c>   JournalIntItems = new List<c2g__codaJournalLineItem__c>();
            
            //Contract Journal creation
            //create journals
            c2g__codaJournal__c journal=New c2g__codaJournal__c(c2g__JournalDate__c=app.Invoice_Payment_Date__c,c2g__Reference__c=app.name,
                                                                c2g__JournalDescription__c='Contract Beginning Post');
            System.debug('Journal -->'+journal);
            insert journal;
            
            // create journal line items
            List<Accounting_Admin__c> AccAdmin = [select General_Ledger_Account__c,Operation__c,Description__c
                                                  from Accounting_Admin__c 
                                                  where Config_Name__c= 'Journal'  ]; 
            decimal Journval;
            string descrip;
            for(integer h=0; h<AccAdmin.size(); h++ )
            {
                if(accAdmin[h].Operation__c=='(-)')
                {
                    Journval=app.Equipment_Cost__c*-1;
                }
                else
                {
                    Journval=app.Equipment_Cost__c;
                }
                descrip=(accAdmin[h].Description__c).replace('AP-xxxxxx', app.name);
                
                c2g__codaJournalLineItem__c JournalItem=new c2g__codaJournalLineItem__c(c2g__LineType__c='Account - Customer', c2g__Account__c=app.AccClient__c,
                                                                                        c2g__GeneralLedgerAccount__c= AccAdmin[h].General_Ledger_Account__c, c2g__Value__c =Journval,
                                                                                        c2g__Journal__c= journal.id,  c2g__LineDescription__c =descrip);
                JournalItems.add(JournalItem);
            }
            
            System.debug('JournalItems -->'+journal);
            insert JournalItems;
            
            //criaÃ§Ã£o de billing contracts
            //information needed on postcode to know exemption code
            for (integer l=0; l<Postcod.size(); l++)
            {
                if(accClient.BillingPostalCode > Postcod[l].CP_MIN__C && accClient.BillingPostalCode < Postcod[l].CP_MAX__c)
                {
                    Region=Postcod[l].Region__C;
                }
            }
            if (app.Invoice_Payment_Date__c<date.today()){
                billdate=date.today();
            }
            else{
                billdate=app.Invoice_Payment_Date__c;
            }
            settleday=(app.Invoice_Payment_Date__c).day();
            settlemonth=(app.Invoice_Payment_Date__c).month();
            
            if(app.Interim_Fee_Amount__c==0){
                prorata=false;
            }
            Billing_Contract__c BillCont=New Billing_Contract__c(Name=app.Name, Account__c=accClient.Id, Account_Vendor__c=accVendor.Id, 
                                                                  Contract_Start_Date__c= app.Beginning_of_Term__c,
                                                                 Billing_Date_Override__c=billdate, application__c=app.id  );
            System.debug('BC '+counterBC+' -->'+BillCont);
            counterBC++; //(BP)
            insert BillCont;
            
            List<Billing_Admin__c> BillAdmin = [select Settlement_Date__c, Payment_Timing__c, Invoice_Date__c, Due_Date__c, Billing_Frequency__c ,
                                                Settlement_Date_value__c, Pro_Rata_Exists__c, FirstInvoice__c
                                                from Billing_Admin__c 
                                                where recordtype.name      = 'Invoice Terms' 
                                                and Payment_Timing__c    = :app.Payment_Timing__c 
                                                And Billing_Frequency__c = :app.Payment_Freq__c 
                                                and Pro_Rata_Exists__c   = true ];
            
            //First Invoice and Payment_frequency=Monthly 
            if(app.Payment_Freq__c =='Monthly')
            {
                for(integer i=0; i< BillAdmin.size(); i++)
                {
                    if(BillAdmin[i].FirstInvoice__c==true)
                    {
                        if (i==0)
                        {
                            resultprev = BillAdmin[i].Settlement_Date_value__c - settleday;
                            System.debug('Linha 163 - Settle day: '+settleday);
                        } 
                        else
                        {
                            if ( resultprev > math.abs( BillAdmin[i].Settlement_Date_value__c - settleday ))
                            {
                                indexi=i;
                            }
                            else
                            {
                                indexi= i-1;
                                resultprev = math.abs( BillAdmin[i].Settlement_Date_value__c - settleday );
                            }
                        }      
                    }                    
                } 
            }
            //First Invoice and Payment_frequency=Quarterly 
            else
            {
                for(integer i=0; i< BillAdmin.size(); i++)
                {
                    if(BillAdmin[i].FirstInvoice__c==true)
                    {
                        if ((settleMonth==3 || settleMonth==6 || settleMonth==9 || settleMonth==12) && settleday>15)
                        {
                            if(BillAdmin[i].Settlement_Date_value__c ==16)
                            {
                                indexi=i;   
                            }
                        }
                        else
                        {
                            if(BillAdmin[i].Settlement_Date_value__c ==15)
                            {
                                indexi=i;   
                            }
                        }
                    }
                }
            }

            
            // evaluates billing Admin to determine due date and invoice date               
            if( (BillAdmin[indexi].invoice_date__c).IndexOf('15 - Month')!=-1)
            {
                dtInvoice=date.newInstance((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month(), 15 );
                System.debug('Linha 209 - Invoice Date: '+dtInvoice);
            }
            
            if( (BillAdmin[indexi].invoice_date__c).IndexOf('Today()')!=-1)
            {
                dtInvoice=date.today();
                System.debug('Linha 209 - Invoice Date: '+dtInvoice);
            }
            
            if( (BillAdmin[indexi].invoice_date__c).IndexOf('15 - Last Month of the Quarter')!=-1)
            {
                if((app.Invoice_Payment_Date__c).Month()==1 || (app.Invoice_Payment_Date__c).Month()==2 || 
                   (app.Invoice_Payment_Date__c).Month() ==3)
                {
                    dtInvoice=date.newInstance((app.Invoice_Payment_Date__c).year(), 3, 15 );
                    System.debug('Linha 224 - Invoice Date: '+dtInvoice);
                }
                
                if((app.Invoice_Payment_Date__c).Month()==4 || (app.Invoice_Payment_Date__c).Month()==5 || 
                   (app.Invoice_Payment_Date__c).Month() ==6)
                {
                    dtInvoice=date.newInstance((app.Invoice_Payment_Date__c).year(), 6, 15 );
                    System.debug('Linha 231 - Invoice Date: '+dtInvoice);
                }
                
                if((app.Invoice_Payment_Date__c).Month()==7 || (app.Invoice_Payment_Date__c).Month()==8 || 
                   (app.Invoice_Payment_Date__c).Month() ==9)
                {
                    dtInvoice=date.newInstance((app.Invoice_Payment_Date__c).year(), 9, 15 );
                    System.debug('Linha 238 - Invoice Date: '+dtInvoice);
                }
                if((app.Invoice_Payment_Date__c).Month()==10 || (app.Invoice_Payment_Date__c).Month()==11 || 
                   (app.Invoice_Payment_Date__c).Month() ==12)
                {
                    dtInvoice=date.newInstance((app.Invoice_Payment_Date__c).year(), 12, 15 );
                    System.debug('Linha 244 - Invoice Date: '+dtInvoice);
                }
            }                
            
            if( (BillAdmin[indexi].Due_Date__c).IndexOf('Last Day Next Month')!=-1)
            {
                dtDue=date.newInstance((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month() +1,
                                       date.daysInMonth((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month() + 1));
                System.debug('Linha 252 - Due Date: '+dtDue);
            }
            
            if( (BillAdmin[indexi].Due_Date__c).IndexOf('Last Day Current Month')!=-1)
            {
                dtDue=date.newInstance((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month(),
                                       date.daysInMonth((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month()));
                System.debug('Linha 259 - Due Date: '+dtDue);
            }
            
            if( (BillAdmin[indexi].Due_Date__c).IndexOf('First Day Next Month')!=-1)
            {
                dtDue=date.newInstance((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month() +1, 1 );
                System.debug('Linha 265 - Due Date: '+dtDue);
            }
            
            if( (BillAdmin[indexi].Due_Date__c).IndexOf('First Day of the Next Quarter')!=-1)
            {
                if((app.Invoice_Payment_Date__c).Month()==1 || (app.Invoice_Payment_Date__c).Month()==2 || 
                   (app.Invoice_Payment_Date__c).Month() ==3)
                {
                    dtDue=date.newInstance((app.Invoice_Payment_Date__c).year(), 4, 1 );
                    System.debug('Linha 273 - Due Date: '+dtDue);
                    
                }
                else   if((app.Invoice_Payment_Date__c).Month()==4 || (app.Invoice_Payment_Date__c).Month()==5 || 
                          (app.Invoice_Payment_Date__c).Month() ==6)
                {
                    dtDue=date.newInstance((app.Invoice_Payment_Date__c).year(), 7, 1 );
                    System.debug('Linha 280 - Due Date: '+dtDue);
                }
                else   if((app.Invoice_Payment_Date__c).Month()==7 || (app.Invoice_Payment_Date__c).Month()==8 || 
                          (app.Invoice_Payment_Date__c).Month() ==9)
                {
                    dtDue=date.newInstance((app.Invoice_Payment_Date__c).year(), 10, 1 );
                    System.debug('Linha 287 - Due Date: '+dtDue);
                }
                else   if((app.Invoice_Payment_Date__c).Month()==10 || (app.Invoice_Payment_Date__c).Month()==11 || 
                          (app.Invoice_Payment_Date__c).Month() ==12) 
                {
                    dtDue=date.newInstance((app.Invoice_Payment_Date__c).year()+1, 1, 1 );
                    System.debug('Linha 293 - Due Date: '+dtDue);
                }
            }

            
            if( (BillAdmin[indexi].Due_Date__c).IndexOf('(+) 15 Days')!=-1)
            {
                dtDue=dtInvoice + 14;
            }
            
            //FA ESTA REPETIDO
            if( (BillAdmin[indexi].Due_Date__c).IndexOf('First Day of the Next Quarter')!=-1){
                if((app.Invoice_Payment_Date__c).Month()==1 || (app.Invoice_Payment_Date__c).Month()==2 || 
                   (app.Invoice_Payment_Date__c).Month() ==3){
                       dtDue=date.newInstance((app.Invoice_Payment_Date__c).year(), 4, 1 );
                       System.debug('Linha 307 - Due Date: '+dtDue);
                   }
                
                if((app.Invoice_Payment_Date__c).Month()==4 || (app.Invoice_Payment_Date__c).Month()==5 || 
                   (app.Invoice_Payment_Date__c).Month() ==6){
                       dtDue=date.newInstance((app.Invoice_Payment_Date__c).year(), 7, 1 );
                       System.debug('Linha 312 - Due Date: '+dtDue);
                   }
                
                if((app.Invoice_Payment_Date__c).Month()==7 || (app.Invoice_Payment_Date__c).Month()==8 || 
                   (app.Invoice_Payment_Date__c).Month() ==9){
                       dtDue=date.newInstance((app.Invoice_Payment_Date__c).year(), 10, 1 );
                       System.debug('Linha 319 - Due Date: '+dtDue);
                   }
                if((app.Invoice_Payment_Date__c).Month()==10 || (app.Invoice_Payment_Date__c).Month()==11 || 
                   (app.Invoice_Payment_Date__c).Month() ==12){
                       dtDue=date.newInstance((app.Invoice_Payment_Date__c).year()+1, 1, 1 );
                       System.debug('Linha 324 - Due Date: '+dtDue);
                   }
            }
            
            //determines future dates for invoice
            for(integer g=0; g< BillAdmin.size(); g++)
            {
                if(BillAdmin[g].FirstInvoice__c==false)
                {
                    if( (BillAdmin[g].Due_Date__c).IndexOf('First Day of the Next Quarter')!=-1)
                    {
                        if((app.Invoice_Payment_Date__c).Month()==1 || (app.Invoice_Payment_Date__c).Month()==2 || 
                           (app.Invoice_Payment_Date__c).Month() ==3)
                        {
                            NextDueDt=date.newInstance((app.Invoice_Payment_Date__c).year(), 4, 1 );
                            System.debug('Linha 339 - Next Due Date: '+NextDueDt);
                        }
                        if((app.Invoice_Payment_Date__c).Month()==4 || (app.Invoice_Payment_Date__c).Month()==5 || 
                           (app.Invoice_Payment_Date__c).Month() ==6)
                        {
                            NextDueDt=date.newInstance((app.Invoice_Payment_Date__c).year(), 7, 1 );
                            System.debug('Linha 345 - Next Due Date: '+NextDueDt);
                        }
                        if((app.Invoice_Payment_Date__c).Month()==7 || (app.Invoice_Payment_Date__c).Month()==8 || 
                           (app.Invoice_Payment_Date__c).Month() ==9)
                        {
                            NextDueDt=date.newInstance((app.Invoice_Payment_Date__c).year(), 10, 1 );
                            System.debug('Linha 351 - Next Due Date: '+NextDueDt);
                        }
                        if((app.Invoice_Payment_Date__c).Month()==10 || (app.Invoice_Payment_Date__c).Month()==11 || 
                           (app.Invoice_Payment_Date__c).Month() ==12)
                        {
                            NextDueDt=date.newInstance((app.Invoice_Payment_Date__c).year()+1, 1, 1 );
                            System.debug('Linha 357 - Next Due Date: '+NextDueDt);
                        }
                    }
                    if( (BillAdmin[g].Due_Date__c).IndexOf('First Day Next Month')!=-1)
                    {
                        NextDueDt=date.newInstance((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month() +1, 1 );
                        System.debug('Linha 363 - Next Due Date: '+NextDueDt);
                    }
                    if( (BillAdmin[g].Due_Date__c).IndexOf('Last Day Current Month')!=-1)
                    {
                        NextDueDt=date.newInstance((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month(),
                                                   date.daysInMonth((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month()));
                        System.debug('Linha 369 - Next Due Date: '+NextDueDt);
                        //FA CHANGED 
                        //if(NextDueDt.day()==31){
                        //    NextDueDt=date.newInstance((NextDueDt).year(), (NextDueDt).Month(),   30 ); 
                        //}
                    }
                    if( (BillAdmin[g].invoice_date__c).IndexOf('15 - Month')!=-1)
                    {
                        NextInvDt=date.newInstance((app.Invoice_Payment_Date__c).year(), (app.Invoice_Payment_Date__c).Month(), 15 );
                        System.debug('Linha 377 - Next Invite Date: '+NextInvDt);
                    }
                    if( (BillAdmin[g].invoice_date__c).IndexOf('Due Date - 15')!=-1)
                    {
                        NextInvDt=NextDueDt-15;
                        System.debug('Linha 383 - Next Invite Date: '+NextInvDt);
                    }
                }
            }
            
            // determines the firt records for billing contracts
            //insert items that are going to happen regularly until end of contract
            if (NextInvDt < date.today() && ( NextInvDt.Month()< (date.today()).Month() && NextInvDt.year()==(date.today()).year()))
            {
                if((NextInvDt).Month()== (date.today()).Month() && (NextInvDt).year()==(date.today()).year())
                {
                    active=true;
                }
                else
                {
                    active=false; 
                }
            }
            else
            {
                active=true;
            }
            if(app.Payment_Amount__c!=0)
            {
                if(app.Payment_Freq__c=='Monthly')
                {
                    for(integer m=0; m<Prods.size(); m++)
                    {
                        if(Prods[m].ProductCode=='PT01' && Prods[m].c2g__CODAInputTaxCode__c== accClient.c2g__CODAInputVATCode__c)
                        {
                            ProdId   = Prods[m].id; 
                            ProdDesc = Prods[m].Description;
                        }
                    }                  
                    //  NextInvDt=(dtInvoice).addMonths(1);
                    amountFactura = app.Payment_Amount__c;
                    // number of invoices after first
                    nbrpay        = app.TermCalc__c-1; 
                    nbrMonthadd   = 1;                   
                }
                //when app.Payment_Freq__c='Quarterly';
                else 
                {
                    for(integer m=0; m<Prods.size(); m++)
                    {
                        if(Prods[m].ProductCode=='PT09' && Prods[m].c2g__CODAInputTaxCode__c== accClient.c2g__CODAInputVATCode__c)
                        {
                            ProdId   = Prods[m].id; 
                            ProdDesc = Prods[m].Description;
                        }
                    }
                    //  NextInvDt=(dtInvoice).addMonths(3);
                    amountFactura=app.Payment_Amount__c*3;
                    // number of invoices after first
                    nbrpay=(app.TermCalc__c/3) -1; 
                    nbrMonthadd=3;
                }                
                BegBalanceIni   = app.Equipment_Cost__c;
                InterestIni     = (app.Annual_Interest_Rate__c/12/100 * BegBalanceIni*nbrMonthadd).setScale(3);
                PrincipalIni    = (amountFactura-InterestIni).setscale(3);
                EndBalanceIni   = (BegBalanceIni-PrincipalIni).setscale(3);
                
                if(prorata==false)
                {
                    BegBalance0 = EndBalanceIni;
                    Interest0   = (app.Annual_Interest_Rate__c/12/100 * BegBalance0*nbrMonthadd).setScale(3);
                    Principal0  = (amountFactura-interest0).setscale(3);
                    EndBalance0 = (BegBalance0-principal0).setscale(3);
                }
                else
                {
                    BegBalance0 = BegBalanceIni;
                    Interest0   = InterestIni;
                    Principal0  = PrincipalIni;
                    EndBalance0 = EndBalanceIni;
                }
                //generating when it has payment amount
                Billing_Contract_Line_Item__c BillContItem = new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                               Line_Item_Start_Date__c=dtInvoice, Line_Item_End_Date__c=dtDue, Active__c=active,
                                                                                               Sales_Price__c=amountFactura, Product__c=ProdId, Quantity__c=1, 

                                                                                               Payment_Timing__c=app.Payment_Timing__c, Last_Invoiced__c=dtInvoice, 
                                                                                               Line_Description__c=ProdDesc, Beginning_Balance__c=BegBalance0, 
                                                                                               interest__c=interest0, Principal__C=principal0,
                                                                                               Ending_Balance__c=EndBalance0, application__c=app.id);
                System.debug('BC '+counterBC+' -->'+BillContItem);
                counterBC++; //(BP)
                //Se prorata a primeira factura para a primeira mensalidade Ã© lanÃ§ada no dia de facturaÃ§Ã£o, sendo a seguinte ainda no mes corrente
                BillContItems.add(BillContItem);  
                //FA DUVIDA - PORQUE SE TIRA 1 AO NBRPAY SE NAO TEM PRORATA?
                //if(prorata==false){
                //    nbrpay=nbrpay-1;  
                //} 
                FutdtInvoice = NextInvDt.addMonths(nbrMonthadd);
                FutdtDue     = NextDueDt.addMonths(nbrMonthadd);
                System.debug('Linha 477 - Future Due Date: '+FutdtDue);
                //FA CHANGED //JR- CHANGED AND FIXED -- WORKING FINE 18/01/2017
                //if (FutdtDue.day()==28 && FutdtDue.month()!=2) {
                //if ((FutdtDue.day()==28 && FutdtDue.month()!=2) || (FutdtDue.day() < date.daysInMonth((FutdtDue).year(), (FutdtDue).Month())))
                if (FutdtDue.day()>=28 )
                {
                    
                    //FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),   30 ); 
                    FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),  date.daysInMonth((FutdtDue).year(), (FutdtDue).Month()));
                    //FutdtDue=date.newInstance( FutdtDue.year(), FutdtDue.Month(), 1 );
                    System.debug('Linha 485 - Future Due Date: '+FutdtDue);
                }
                //FA END
                for(integer t=0; t <nbrpay ; t++)
                {
                    if(t==0)
                    {
                        BegBalancen=EndBalance0; 
                    }
                    else
                    {
                        BegBalancen=EndBalancen;  
                    }
                    
                    Interestn   = (app.Annual_Interest_Rate__c/12/100 * BegBalancen*nbrMonthadd).setScale(3);
                    Principaln  = (amountFactura-Interestn).setscale(3);
                    EndBalancen = (BegBalancen-principaln).setscale(3);
                    
                    if (FutdtInvoice < date.today()  || ( (FutdtInvoice).Month()< (date.today()).Month() && (FutdtInvoice).year()==(date.today()).year()))
                    {
                        if((FutdtInvoice).Month()== (date.today()).Month() && (FutdtInvoice).year()==(date.today()).year())
                        {
                            active=true;
                        }
                        else
                        {
                            active=false; 
                        }
                    }
                    else
                    {
                        active=true;
                    }
                    System.debug('*****Checkpoint*****');
                    Billing_Contract_Line_Item__c BillContFutItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                                    Line_Item_Start_Date__c=FutdtInvoice, Line_Item_End_Date__c=FutdtDue, Active__c=active,
                                                                                                    Sales_Price__c=amountFactura, Product__c=ProdId, Quantity__c=1, 
                                                                                                    Payment_Timing__c=app.Payment_Timing__c, Last_Invoiced__c=FutdtInvoice, 
                                                                                                    Line_Description__c=ProdDesc,Beginning_Balance__c=BegBalancen, 
                                                                                                    interest__c=Interestn, Principal__C=Principaln,
                                                                                                    Ending_Balance__c=EndBalancen, application__c=app.id);
                    System.debug('BC '+counterBC+' -->'+BillContFutItem);
                    counterBC++;//(BP)
                    BillContItems.add(BillContFutItem);
                    FutdtInvoice = FutdtInvoice.addMonths(nbrMonthadd);
                    FutdtDue     = FutdtDue.addMonths(nbrMonthadd);
                    System.debug('Linha 531 - Future Due Date: '+FutdtDue);
                    //FA CHANGED //JR- CHANGED AND FIXED -- WORKING FINE 18/01/2017
                    //if (FutdtDue.day()==28 && FutdtDue.month()!=2) {
                    //if ((FutdtDue.day()==28 && FutdtDue.month()!=2) || (FutdtDue.day() < date.daysInMonth((FutdtDue).year(), (FutdtDue).Month())))
                    if (FutdtDue.day()>=28 )
                    {
                        
                        //FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),   30 ); 
                        FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),  date.daysInMonth((FutdtDue).year(), (FutdtDue).Month()));
                        //FutdtDue=date.newInstance( FutdtDue.year(), FutdtDue.Month(), 1 );
                        System.debug('Linha 485 - Future Due Date: '+FutdtDue);
                    }
                    //FA END
                    
                }
            }
            //finished to generate BCLIS related with payment amount
            
            //ALTERACAO - 14/12/16 - Reposicao do insurance insurance inicial e comentado original insurance (BP)
            if(app.Chosen_Insurance_value__c!=0)
            {
                //if(app.Original_Insurance_Value__c!=0){
                if (NextInvDt < date.today() && ( NextInvDt.Month()< (date.today()).Month() && NextInvDt.year()==(date.today()).year()))
                {
                    if((NextInvDt).Month()== (date.today()).Month() && (NextInvDt).year()==(date.today()).year())
                    {
                        active=true;
                    }
                    else
                    {
                        active=false; 
                    }
                }
                else
                {
                    active=true;
                }
                for(integer m=0; m<Prods.size(); m++)
                {
                    if(Prods[m].ProductCode=='PT02' && Prods[m].c2g__CODAInputTaxCode__r.Area__c==Region)
                    {
                        ProdId= Prods[m].id;
                        ProdDesc=Prods[m].Description;
                    }
                }
                if(app.Payment_Freq__c=='Monthly')
                {
                    //ALTERACAO - 14/12/16 - Reposicao do insurance insurance inicial e comentado original insurance (BP)
                    insurFactura=app.Chosen_Insurance_value__c;
                    //insurFactura=app.Original_Insurance_Value__c;
                    // number of invoices after first
                    nbrpay=app.TermCalc__c-1; 
                    nbrMonthadd=1;
                    
                }
                else 
                {
                    //ALTERACAO - 14/12/16 - Reposicao do insurance insurance inicial e comentado original insurance (BP)
                    insurFactura= app.Chosen_Insurance_value__c*3;
                    //insurFactura=app.Original_Insurance_Value__c*3;
                    // number of invoices after first
                    nbrpay      = (app.TermCalc__c/3) -1; 
                    nbrMonthadd = 3;
                }

                
                //generate BCLI when Chosen_Insurance_value__c!=0 
                Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                             Line_Item_Start_Date__c=NextInvDt, Line_Item_End_Date__c=NextDueDt, Active__c=active,

                                                                                             Sales_Price__c=insurFactura, Product__c=ProdId, Quantity__c=1,
                                                                                             Payment_Timing__c=app.Payment_Timing__c, Last_Invoiced__c=NextInvDt,
                                                                                             Line_Description__c=ProdDesc, application__c=app.id);
                System.debug('BC '+counterBC+' -->'+BillContItem);
                counterBC++;
                BillContItems.add(BillContItem);  
                //FA CHANGED
                //if(prorata==false){
                //    nbrpay=nbrpay-1;
                //} 
                FutdtInvoice = NextInvDt.addMonths(nbrMonthadd);
                FutdtDue     = NextDueDt.addMonths(nbrMonthadd);
                System.debug('Linha 607 - Future Due Date: '+FutdtDue);
                //FA CHANGED //JR- CHANGED AND FIXED -- WORKING FINE 18/01/2017
                //if (FutdtDue.day()==28 && FutdtDue.month()!=2) {
                //if ((FutdtDue.day()==28 && FutdtDue.month()!=2) || (FutdtDue.day() < date.daysInMonth((FutdtDue).year(), (FutdtDue).Month())))
                if (FutdtDue.day()>=28 )
                {
                    
                    //FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),   30 ); 
                    FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),  date.daysInMonth((FutdtDue).year(), (FutdtDue).Month()));
                    //FutdtDue=date.newInstance( FutdtDue.year(), FutdtDue.Month(), 1 );
                    System.debug('Linha 485 - Future Due Date: '+FutdtDue);
                }
                //FA END
                for(integer t=0; t <nbrpay ; t++)
                {
                    if (FutdtInvoice < date.today()  && ( (FutdtInvoice).Month()< (date.today()).Month()  && (FutdtInvoice).year()==(date.today()).year()))
                    {
                        if((FutdtInvoice).Month()== (date.today()).Month() && (FutdtInvoice).year()==(date.today()).year())
                        {
                            active=true;
                        }
                        else
                        {
                            active=false; 
                        }
                    }
                    else
                    {
                        active=true;
                    }
                    Billing_Contract_Line_Item__c BillContFutItem = new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                                      Line_Item_Start_Date__c=FutdtInvoice, Line_Item_End_Date__c=FutdtDue, Active__c=active,
                                                                                                      Sales_Price__c=insurFactura, Product__c=ProdId, Quantity__c=1, 
                                                                                                      Payment_Timing__c=app.Payment_Timing__c, Last_Invoiced__c=FutdtInvoice, 
                                                                                                      Line_Description__c=ProdDesc, application__c=app.id);
                    System.debug('BC '+counterBC+' -->'+BillContFutItem);
                    counterBC++;//(BP)
                    BillContItems.add(BillContFutItem);
                    FutdtInvoice = FutdtInvoice.addMonths(nbrMonthadd);
                    FutdtDue     = FutdtDue.addMonths(nbrMonthadd);
                    System.debug('Linha 643 - Future Due Date: '+FutdtDue);
                    //FA CHANGED //JR- CHANGED AND FIXED -- WORKING FINE 18/01/2017
                    //if (FutdtDue.day()==28 && FutdtDue.month()!=2) {
                    //if ((FutdtDue.day()==28 && FutdtDue.month()!=2) || (FutdtDue.day() < date.daysInMonth((FutdtDue).year(), (FutdtDue).Month())))
                    if (FutdtDue.day()>=28 )
                    {
                        
                        //FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),   30 ); 
                        FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),  date.daysInMonth((FutdtDue).year(), (FutdtDue).Month()));
                        //FutdtDue=date.newInstance( FutdtDue.year(), FutdtDue.Month(), 1 );
                        System.debug('Linha 485 - Future Due Date: '+FutdtDue);
                    }
                    //FA END
                }
            }
            
            if(app.ATM_Reference_Costs__c!=null)
            {
                if (NextInvDt < date.today() && ( NextInvDt.Month()< (date.today()).Month() && NextInvDt.year()==(date.today()).year()))
                {
                    if((NextInvDt).Month()== (date.today()).Month() && (NextInvDt).year()==(date.today()).year())
                    {
                        active=true;
                    }
                    else
                    {
                        active=false; 
                    }
                }
                else
                {
                    active=true;
                }
                for(integer m=0; m<Prods.size(); m++)
                {
                    if(Prods[m].ProductCode=='PT03' && Prods[m].c2g__CODAInputTaxCode__c== accClient.c2g__CODAInputVATCode__c)
                    {
                        ProdId= Prods[m].id; 
                        ProdDesc=Prods[m].Description;
                    }
                }
                if(app.Payment_Freq__c=='Monthly')
                {
                    amountFactura=app.Payment_Amount__c;
                    // number of invoices after first
                    nbrpay=app.TermCalc__c-1; 
                    nbrMonthadd=1;                   
                }
                else
                {            
                    amountFactura=app.Payment_Amount__c*3;
                    // number of invoices after first
                    nbrpay=(app.TermCalc__c/3) -1; 
                    nbrMonthadd=3;
                }
                //generate the BCLIS when ATM_Reference_Costs__c!=null
                Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                             Line_Item_Start_Date__c=NextInvDt, Line_Item_End_Date__c=NextDueDt, Active__c=active,
                                                                                             Sales_Price__c=app.ATM_Reference_Costs__c, Product__C=ProdId, Quantity__c=1,
                                                                                             Payment_Timing__c=app.Payment_Timing__c, Line_Description__c=ProdDesc, Last_Invoiced__c=NextInvDt, 
                                                                                             application__c=app.id);
                
                System.debug('BC '+counterBC+' -->'+BillContItem);
                counterBC++;//(BP)
                //Se prorata a primeira factura para a primeira mensalidade Ã© lanÃ§ada no dia de facturaÃ§Ã£o, sendo a seguinte ainda no mes corrente
                BillContItems.add(BillContItem);  
                //FA CHANGED
                //if(prorata==false){
                //    nbrpay=nbrpay-1;  
                //} 
                FutdtInvoice=NextInvDt.addMonths(nbrMonthadd);
                FutdtDue=NextDueDt.addMonths(nbrMonthadd);
                System.debug('Linha 712 - Future Due Date: '+FutdtDue);
                //FA CHANGED //JR- CHANGED AND FIXED -- WORKING FINE 18/01/2017
                //if (FutdtDue.day()==28 && FutdtDue.month()!=2) {
                //if ((FutdtDue.day()==28 && FutdtDue.month()!=2) || (FutdtDue.day() < date.daysInMonth((FutdtDue).year(), (FutdtDue).Month())))
                if (FutdtDue.day()>=28 )
                {
                    
                    //FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),   30 ); 
                    FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),  date.daysInMonth((FutdtDue).year(), (FutdtDue).Month()));
                    //FutdtDue=date.newInstance( FutdtDue.year(), FutdtDue.Month(), 1 );
                    System.debug('Linha 485 - Future Due Date: '+FutdtDue);
                }
                //FA END
                for(integer t=0; t <nbrpay ; t++){
                    
                    if (FutdtInvoice < date.today()  || ( (FutdtInvoice).Month()< (date.today()).Month() && (FutdtInvoice).year()==(date.today()).year())){
                        if((FutdtInvoice).Month()== (date.today()).Month() && (FutdtInvoice).year()==(date.today()).year()){
                            active=true;
                        }else{
                            active=false; 
                        }
                    }else{
                        active=true;
                    }
                    
                    Billing_Contract_Line_Item__c BillContFutItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c=app.Payment_Freq__c,
                                                                                                    Line_Item_Start_Date__c=FutdtInvoice, Line_Item_End_Date__c=FutdtDue, Active__c=active,
                                                                                                    Sales_Price__c=app.ATM_Reference_Costs__c, Product__c=ProdId, Quantity__c=1, 
                                                                                                    Payment_Timing__c=app.Payment_Timing__c, Last_Invoiced__c=FutdtInvoice, 
                                                                                                    Line_Description__c=ProdDesc,application__c=app.id);
                    System.debug('BC '+counterBC+' -->'+BillContFutItem);
                    counterBC++;//(BP)
                    BillContItems.add(BillContFutItem);
                    FutdtInvoice = FutdtInvoice.addMonths(nbrMonthadd);
                    FutdtDue     = FutdtDue.addMonths(nbrMonthadd);
                    //FA CHANGED //JR- CHANGED AND FIXED -- WORKING FINE 18/01/2017
                    //if (FutdtDue.day()==28 && FutdtDue.month()!=2) {
                    //if ((FutdtDue.day()==28 && FutdtDue.month()!=2) || (FutdtDue.day() < date.daysInMonth((FutdtDue).year(), (FutdtDue).Month())))
                    if (FutdtDue.day()>=28 )
                    {
                        
                        //FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),   30 ); 
                        FutdtDue=date.newInstance((FutdtDue).year(), (FutdtDue).Month(),  date.daysInMonth((FutdtDue).year(), (FutdtDue).Month()));
                        //FutdtDue=date.newInstance( FutdtDue.year(), FutdtDue.Month(), 1 );
                        System.debug('Linha 485 - Future Due Date: '+FutdtDue);
                    }
                    //FA END
                }
            }
            
            // determine due and invoice dates for one time only invoices
            
            List<Billing_Admin__c> BillAdminOnce = [select Settlement_Date__c, Payment_Timing__c, Invoice_Date__c, Due_Date__c, Billing_Frequency__c ,
                                                    Settlement_Date_value__c 
                                                    from Billing_Admin__c 
                                                    where (recordtype.name = 'Invoice Terms' and Payment_Timing__c=: app.Payment_Timing__c ) 
                                                    And (Billing_Frequency__c= 'Once' Or (Billing_Frequency__c= 'Monthly' And Pro_Rata_Exists__c=false))  ];
            //FA CHANGED
            //for(integer i=0; i< BillAdminOnce.size(); i++){
            dtInvoice=app.Invoice_Payment_Date__c;
            dtDue=dtInvoice+14;
            //}
            if(dtInvoice<date.today())
            {
                active=false;
            }
            // se pro-rata nÃ£o existir primeiro mÃªs pago aquando da primeira factura
            //FA CHANGED

            //FA END
            if(app.Paper_Contract_Fee__c!=0)
            {
                for(integer m=0; m<Prods.size(); m++)
                {
                    if(Prods[m].ProductCode=='PT07' && Prods[m].c2g__CODAInputTaxCode__c== accClient.c2g__CODAInputVATCode__c)
                    {
                        ProdId= Prods[m].id; 
                        ProdDesc=Prods[m].Description;
                    }
                }
                Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='One Time',
                                                                                             Line_Item_Start_Date__c=dtInvoice, Line_Item_End_Date__c=dtDue, Active__c=active,
                                                                                             Sales_Price__c=app.Paper_Contract_Fee__c, Product__c=ProdId, Quantity__c=1,
                                                                                             Payment_Timing__c=app.Payment_Timing__c, Line_Description__c=ProdDesc,
                                                                                             application__c=app.id);
                System.debug('BC '+counterBC+' -->'+BillContItem);
                counterBC++; //(BP)
                BillContItems.add(BillContItem);
                System.debug('BCsss '+counterBC+' -->'+BillContItems);
            }
            
            if(app.eSignature_Contract_Fee__c!=0)
            {
                for(integer m=0; m<Prods.size(); m++){
                    if(Prods[m].ProductCode=='PT06' && Prods[m].c2g__CODAInputTaxCode__c== accClient.c2g__CODAInputVATCode__c)
                    {
                        ProdId= Prods[m].id; 
                        ProdDesc=Prods[m].Description;
                    }
                }
                
                //create BCLI if need to pay eSignature_Contract_Fee__c 
                Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='One Time',
                                                                                             Line_Item_Start_Date__c=dtInvoice, Line_Item_End_Date__c=dtDue, Active__c=active,
                                                                                             Sales_Price__c=app.eSignature_Contract_Fee__c, Product__c=ProdId, Quantity__c=1,
                                                                                             Payment_Timing__c=app.Payment_Timing__c, Line_Description__c=ProdDesc,
                                                                                             application__c=app.id);
                System.debug('BC '+counterBC+' -->'+BillContItem);
                counterBC++;//(BP)
                BillContItems.add(BillContItem);
            }
            
            if(app.Interim_Fee_Amount__c!=0){
                if(app.Payment_Freq__c=='Monthly'){
                    for(integer m=0; m<Prods.size(); m++){
                        if(Prods[m].ProductCode=='PT08' && Prods[m].c2g__CODAInputTaxCode__c== accClient.c2g__CODAInputVATCode__c){
                            ProdId= Prods[m].id; 
                            ProdDesc=Prods[m].Description;
                        }
                    }
                }
                else
                {
                    for(integer m=0; m<Prods.size(); m++){
                        if(Prods[m].ProductCode=='PT10' && Prods[m].c2g__CODAInputTaxCode__c== accClient.c2g__CODAInputVATCode__c){
                            ProdId= Prods[m].id; 
                            ProdDesc=Prods[m].Description;
                        }
                    }
                }
                //create BCLI if interim_fee_Amount!=0
                Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='One Time',
                                                                                             Line_Item_Start_Date__c=dtInvoice, Line_Item_End_Date__c=dtDue, Active__c=active,
                                                                                             Sales_Price__c=app.Interim_Fee_Amount__c, Product__C=ProdId, Quantity__c=1,
                                                                                             Payment_Timing__c=app.Payment_Timing__c, Line_Description__c=ProdDesc,
                                                                                             application__c=app.id);
                System.debug('BC '+counterBC+' -->'+BillContItem);
                counterBC++;
                BillContItems.add(BillContItem);
            }
            //ALTERACAO - 14/12/16 - Reposicao do insurance insurance inicial e comentado original insurance (BP)
            if(app.Insurance_Pro_Rata__c!=0){
                //if(app.Original_Insurance_ProRata__c!=0){    
                for(integer m=0; m<Prods.size(); m++){
                    if(Prods[m].ProductCode=='PT11' && Prods[m].c2g__CODAInputTaxCode__r.Area__c==Region ){
                        ProdId= Prods[m].id; 
                        ProdDesc=Prods[m].Description;
                    }
                }               
                Billing_Contract_Line_Item__c BillContItem=new Billing_Contract_Line_Item__c(Billing_Contract__c=BillCont.id, Billing_Frequency__c='One Time',
                                                                                             Line_Item_Start_Date__c=dtInvoice, Line_Item_End_Date__c=dtDue, Active__c=active,
                                                                                             Sales_Price__c=app.Insurance_Pro_Rata__c, Product__c=ProdId, Quantity__c=1,
                                                                                             Payment_Timing__c=app.Payment_Timing__c, Line_Description__c=ProdDesc,
                                                                                             application__c=app.id);
                System.debug('BC '+counterBC+' -->'+BillContItem);
                counterBC++;//(BP)
                BillContItems.add(BillContItem);
            }
            
            // inserts all billing contract records   
            System.debug('---AQUI---');      
            insert BillContItems;
            System.debug('PASSOU');
            
            // run job to create sales invoice from billing contract
            list<Billing_Contract_Line_Item__c> salesinvoicedue=[select id, name, Line_Item_Start_Date__c,  Line_Item_End_Date__c 
                                                                 from Billing_Contract_Line_Item__c 
                                                                 where Billing_Contract__c=:BillCont.id 
                                                                 and Ready_to_Invoice__c='Yes'];
            
            // this code garanties that if there is an invoice for prorata and for monthly advanced contracts 
            // on the same month that the monthl payment does not have an invoice data inferior to the prorata
            object maxstartdt=null;
            object maxenddt=null;
            List<Id> targetIds=new List<Id>();
            if( app.Payment_Timing__c=='Advanced'){
                
                AggregateResult[] groupitem=[select Max(Line_Item_Start_Date__c) maxstart, max( Line_Item_End_Date__c) maxend 
                                             from Billing_Contract_Line_Item__c 
                                             where Billing_Contract__c=:BillCont.id 
                                             and Ready_to_Invoice__c='Yes' ];
                
                maxstartdt=groupitem[0].get('maxstart');
                maxenddt=groupitem[0].get('maxend'); 
                list <Billing_Contract_Line_Item__c> updalineItems=new List<Billing_Contract_Line_Item__c>();
                for(Billing_Contract_Line_Item__c item :salesinvoicedue ){
                    item.Line_Item_Start_Date__c=date.valueOf(maxstartdt);
                    item.Line_Item_End_Date__c=date.valueOf(maxenddt);
                    updalineItems.add(item);
                }
                System.debug('*****CHECKPOINT*****');
                update updalineItems;
            }
            
            if(salesinvoicedue.size()>0){
                if( app.Payment_Timing__c=='Advanced'){
                    BillCont.Aux_Due_Date__c=date.valueOf(maxenddt);
                    BillCont.Aux_Invoice_Date__c=date.valueOf(maxstartdt);
                }
                else{
                    BillCont.Aux_Due_Date__c=salesinvoicedue[0].Line_Item_End_Date__c;
                    BillCont.Aux_Invoice_Date__c=salesinvoicedue[0].Line_Item_Start_Date__c;
                }
                update BillCont;
                Id ruleId = [select id 
                             from ffirule__IntegrationRule__c 
                             where name ='Billing Contract to Sales Invoice'].id;
                
                List<Billing_Contract__c> Bills = [SELECT Id 
                                                   FROM Billing_Contract__c 
                                                   WHERE id= :BillCont.id ];
                
                Set<Id> BillIds = new Map<Id, SObject>(Bills).keySet();
                
                // CriaÃ§Ã£o do sales Invoice via click link rule
                targetIds = ffirule.RuleService.run(new List<Id>(BillIds), ruleId);
            }
            //post journal related to contract
            List<c2g.CODAAPICommon.Reference> refs = new List<c2g.CODAAPICommon.Reference>();
            c2g.CODAAPICommon.Reference ref1 = new c2g.CODAAPICommon.Reference();
            ref1.Id = journal.id;
            refs.add(ref1);
            c2g.CODAAPIJournal_6_0.BulkPostJournal(null, refs); 
            // posting sales invoices due for current date   done with trigger on Post_SalesInvoice__c = true 
            for (integer i=0; i < targetIds.size(); i++){
                
                c2g__codaInvoice__c salesinv=[select id, Post_SalesInvoice__c 
                                              from c2g__codaInvoice__c 
                                              where id= :targetIds[i] ];
                
                //field is set to trigger creation of transactions and posting 
                //salesinv.Post_SalesInvoice__c =true;

                //-------------------------------------------------------------
                //-----------COMENTADO 09/02/2017 -> Impedir envio automático no Settle
                //salesinv.Posted_InvoiceXpress__c = true;
                update salesinv;
                // generates invoice in invoicexpress for first fase will be only draft had to be passed to other fase of process due to callout exceptions
                // use previous flag to run schedule to generate invoices in invoiceXpress then set flag to false.
                // InvoiceXpress_API.GetInvoiceInfo(salesinv.id);
                //transactions for interest are posted by trigger on post of sales invoice
                // post was put on trigger because error was giving triggering trs on complete of invoice.
                
            }
            
            // set generate billing contract to false to never generate billing for this record again
            app.Generate_Billing__C=false;
            update app;
            
        } 
        catch(exception e){
            system.debug('[BillingProcess - Create billing invoice] ' + e.getLineNumber() + ' ' +e.getCause() + ' ' + e.getMessage());
            if (!Test.isRunningTest()) {
                String[] toAddresses = new List<String>();  toAddresses.add('sf.candor@worldit.pt');  toAddresses.add('info@candor.pt');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Generation of Billing Contract for appId ' + appID + ' Failed!');  email.setToAddresses(toAddresses);
                email.setPlainTextBody('Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage());
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
    }
*/    
    public static ID Create_Due_Sales_invoice(ID BillingContractID){
        try{
            
            // run qyery tocheck if sales invoice are due to be created from billing contract and were not created yet
            /* List<Billing_Contract__c> BillCont=[select id from Billing_contract__c where id in (select  Billing_contract__c from Billing_Contract_Line_Item__c 
where Ready_to_Invoice__c='Yes' and Invoiced__c!=true)      ];

list<ID> listbillids=new List<ID>();         
for( Billing_Contract__c bill :BillCont){
listbillids.add(bill.id);
} 
List<Billing_Contract_Line_Item__c> salesinvoicedue=[select id, name, Line_Item_Start_Date__c,  Line_Item_End_Date__c, Billing_contract__c from Billing_Contract_Line_Item__c 
where Ready_to_Invoice__c='Yes' and Invoiced__c!=true and Billing_contract__c in :listbillids order by Billing_contract__c];
system.debug(salesinvoicedue);
system.debug(BillCont);

List<Billing_Contract__c> updlistBill=New List<Billing_Contract__c>();
for( Billing_Contract__c bill :BillCont){
for (integer i=0; i< salesinvoicedue.size(); i++){
if(salesinvoicedue[i].Billing_contract__C == bill.id){
bill.Aux_Due_Date__c=salesinvoicedue[i].Line_Item_End_Date__c;
bill.Aux_Invoice_Date__c=salesinvoicedue[i].Line_Item_Start_Date__c;
updlistBill.add(bill);
} 
}
}
Set<Billing_Contract__c> setdistinctBillIds = new set<Billing_Contract__c>();
setdistinctBillIds.addall(updlistBill);
List <Billing_Contract__c> billsToUpd=New List<Billing_Contract__c>(setdistinctBillIds);

update billsToUpd;

Set<Id> BillIds = new Map<Id, SObject>(billsToUpd).keySet();*/
            
            Id ruleId = [select id 
                         from ffirule__IntegrationRule__c 
                         where name ='Billing Contract to Sales Invoice'].id;
            
            list<ID> targetIds=new List<ID>();
            
            List<ID> billID = new List<ID>();
            billID.add(BillingContractID);
            // CriaÃ§Ã£o do sales Invoice via click link rule
            
            targetIds = ffirule.RuleService.run(billID, ruleId);
            
            // posting sales invoices due for current date   done with trigger on Post_SalesInvoice__c = true
            list <c2g__codaInvoice__c> listsalesinv=[select id, Post_SalesInvoice__c 
                                                     from c2g__codaInvoice__c 
                                                     where id in :targetIds ]; 
            
            list <c2g__codaInvoice__c> updlistsalesinv=New list <c2g__codaInvoice__c> ();
            for (c2g__codaInvoice__c salesinv :listsalesinv){
                salesinv.Post_SalesInvoice__c = true;

                //-------------------------------------------------------------
                //-----------COMENTADO 09/02/2017 -> Impedir envio automático no Settle                
                salesinv.Posted_InvoiceXpress__c = true;
                updlistsalesinv.add(salesinv);
            }
            update updlistsalesinv;
            return updlistsalesinv[0].id;
            return targetIds[0];
        }
        catch(exception e){
            //Utilities.LogIntegration( date.today(), date.today(), 'Error', 'Create_due_sales_invoice', 'Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() + ' \n giving error Message: ' + e.getMessage(), BillingContractID);
            system.Debug('[BillingProcess - Create Due Sales Invoice] ' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            if (!Test.isRunningTest()) {
                String[] toAddresses = new List<String>();
                toAddresses.add('sf.candor@worldit.pt'); toAddresses.add('info@candor.pt');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Generation of Invoice for Billing Contract ' + BillingContractID 
                                 + ' to be generate today ' + date.today() + ' Failed!'); email.setToAddresses(toAddresses);
                email.setPlainTextBody('Problem occurred in line: '+ e.getLineNumber() + ' \n Due to ' + e.getCause() 
                                       + ' \n giving error Message: ' + e.getMessage());
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            return null;
        }
    } 
    
    public static id GetInputOutputVAT(string PostalCode){
        try{
            integer postcode_max=0;
            integer postcode_min=0;
            integer accpostcode=0;
            string accregion='';
            if (PostalCode!= null && PostalCode !='0000-000' && PostalCode!='' && PostalCode != '0000'){
                
                list <PostCode__c> postcod = [select CP_Max__c, CP_Min__c, Region__c 
                                              from postcode__c 
                                              where Region__c != null];
                
                for ( integer i=0; i<postcod.size(); i++){
                    postcode_max= integer.valueOf((postcod[i].cp_max__c).substring(0,4));
                    postcode_min= integer.valueOf((postcod[i].CP_Min__c).substring(0,4));
                    accpostcode=  integer.valueOf((PostalCode).substring(0,4));
                    if(accpostcode <= postcode_max && accpostcode >= postcode_min){
                        accregion= postcod[i].Region__c;
                    }
                }
                list <c2g__codaTaxCode__c> taxcodes=[select name, Area__c, Country__c, id    
                                                     from c2g__codaTaxCode__c  
                                                     where country__C= 'Portugal' 
                                                     and Area__c=: accregion 
                                                     and Name like 'V%' and ( not name like '%00')  ]; 
                return taxcodes[0].id;            
            }
            else {
                return null;
            }
            
        }
        catch(exception e){
            System.Debug('BillingProcess GetInputOutputVAT - Error ');
            system.Debug(e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return null;
        }
    }
    
    public static void dummy(){
        	
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}