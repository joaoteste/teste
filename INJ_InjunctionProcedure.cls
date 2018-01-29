global class INJ_InjunctionProcedure {    
    
    //set billing contracts to inactive + create an injunction for all billing contracts in this CC
    webservice static String createInjunctionProceduresForCollectionCase(Id collectionCaseId) {
        //only one Injunction per Collection Case
        List<Injunction_Procedure__c> inj = [SELECT Id, Name FROM Injunction_Procedure__c WHERE Collection_Case__c = :collectionCaseId];
        if(inj.size() > 0){
            return 'There is already an injunction for this Collection Case '+inj[0].Name;
        }else{
            Injunction_Procedure__c injProc = new Injunction_Procedure__c();
            injProc.Collection_Case__c = collectionCaseId;
            insert injProc;
            
            return 'Created Injunction Successfully';
            /*
            boolean success = generateInjunctionTextFile(injProc.Id);
            
            if(success){
                return 'Created Injunction Successfully';
            }else{
                return 'Couldnt Create Injunction';
            }*/
        }
    }
    
    
    webservice static String generateInjunctionTextFile(Id injId){
        List<Injunction_Procedure__c> injunctionList = [SELECT Name, Collection_Fee_Amount__c, Collection_Case__c, Injunction_Date__c, Interest_Charges__c, Claimed_Amount__c, 
                                                        Account_Client__r.Name, Account_Client__r.BillingStreet, Account_Client__r.BillingCity, Account_Client__r.BillingPostalCode, Account_Client__r.Phone, Account_Client__r.Fax, Account_Client__r.Email__c, Account_Client__r.NIF__c,
                                                        Injuction_Claimed_Amount_Total__c, Judicial_Fee_Amount__c, Residual_Value_Amount__c, Facts__c, 
                                                        Personal_Guarantee_Signer_1__r.Name, Personal_Guarantee_Signer_2__r.Name, Payment_Amount_to_The_End_Of_Contract__c FROM Injunction_Procedure__c WHERE Id = :injId];
        if(injunctionList.size() <= 0){
            return 'Couldnt create Injunction Text File - No ';
        }else{
            Injunction_Procedure__c injunction = injunctionList.get(0);
            
            Map<Id,Billing_Contract__c> bcs = new Map<Id,Billing_Contract__c>([SELECT Id, Name, Contract_Start_Date__c, Payment_Amount_to_The_End_Of_Contract__c, Application__c, Account_Vendor__r.Name, Account_Vendor__r.NIF__c, Account_Vendor__r.BillingStreet, Account_Vendor__r.BillingCity, Account_Vendor__r.BillingPostalCode, Contract_Term__c, Payment_Method__c FROM Billing_Contract__c WHERE Injunction__c = :injId]);
            
            Map<Id, Billing_Contract__c> appToBc = new Map<Id, Billing_Contract__c>();
            for(Billing_Contract__c bc : bcs.values()){
                appToBc.put(bc.Application__c, bc);
            }
            
            List<Application__c> apps = [SELECT Name, Delivery_Certificate_Signed__c, Invoice_Number__c, Payment_Freq__c, End_of_Term__c, Invoice_Payment_Date__c, Beginning_of_Term__c, Personal_Guarantee_Signer_1__c, Personal_Guarantee_Signer_2__c FROM Application__c WHERE Id IN :appToBc.keySet()];
            List<Equipment__c> equipmentsQuery = [SELECT Application__r.Name, Equipment_Quantity__c, Equipment_Serial_Number__c, Equipment_Description__c FROM Equipment__c WHERE Injunction__c = :injId];
            Map<String, List<Equipment__c>> appToEquips = new Map<String, List<Equipment__c>>();
            for(Equipment__c e : equipmentsQuery){
                if(appToEquips.containsKey(e.Application__r.Name)){
                    List<Equipment__c> aux = appToEquips.get(e.Application__r.Name);
                    aux.add(e);
                    appToEquips.put(e.Application__r.Name, aux);
                }else{
                    List<Equipment__c> aux = new List<Equipment__c>();
                    aux.add(e);
                    appToEquips.put(e.Application__r.Name, aux);
                }
            }
            
            Dunning_Alert__c dunning = [SELECT Sent_Date__c FROM Dunning_Alert__c WHERE Status__c = 'Open' AND Dunning_Level__c = '4th Reminder' AND Collection_Case__c IN (SELECT Collection_Case__c FROM Injunction_Procedure__c WHERE Id = :injunction.Id)];
            Date dunningDateObj = dunning.Sent_Date__c;
            String dunningDate = dunningDateObj.format();
            
            List<String> contractNames = getContractNamesList(bcs);
            List<String> equipmentInvoices = getEquipmentInvoices(apps);
            Set<String> societies = getSocietiesSet(bcs);
            Map<String,List<String>> contractGuaranteesIds = getContractGuaranteesIds(apps);
            Map<Id,Contact> guaranteeDetails = populateGuaranteeDetails(contractGuaranteesIds.values());
            Map<String,String> signedCertificateDates = getSignedCertificateDatesMap(apps, appToBc);
            Map<String,Boolean> contractFrequencies = getFrequenciesMap(apps, appToBc);
            Map<String,String> contractEndOfTerms = getEndOfTermsMap(apps,appToBc);
            Map<String,String> contractTerms = getContractTermsMap(bcs);
            Map<String,Decimal> contractRents = getContractRentsMap(bcs);
            Map<String,Decimal> contractInsurances = getContractInsurancesMap(bcs);
            Map<String,String> paymentMethods = getPaymentMethodsMap(bcs);
            Map<String,List<Date>> futureInvoiceDates = getFutureInvoiceDates(bcs,injunction.Injunction_Date__c);
            
            boolean moreThanOneBC = (bcs.size() > 1) ? true : false;
            boolean hasPersonalGuarantee = (contractGuaranteesIds.size() > 0) ? true : false;
            boolean moreThanOneSociety = (societies.size() > 1) ? true : false;
            
            String requerente = 'REQUERIMENTO DE INJUNÇÃO\n\n\n';
            requerente += 'REQUERENTE\n\n';
            requerente += 'Nome/Designação: Candor Renting de Equipamentos, S.A.\n';
            requerente += 'Morada: Rua Mar da China, 1, Escritório 2.2, Parque das Nações\n';
            requerente += 'Localidade: Lisboa\n';
            requerente += 'Código postal: 1990-137 LISBOA\n';
            requerente += 'Telefone: Fax: \n';
            requerente += 'Email: info@candor.pt\n';
            requerente += 'NIF: 513626930\n';
            requerente += 'IBAN: PT50001000005300067000166\n\n';
            
            String requerido = 'REQUERIDO (DEVEDOR PRINCIPAL)\n\n';
            requerido += 'Nome/Designação: '+injunction.Account_Client__r.Name+'\n';
            requerido += 'Morada: ';
            requerido += (injunction.Account_Client__r.BillingStreet != null) ? injunction.Account_Client__r.BillingStreet+'\n' : '\n'; 
            requerido += 'Localidade: ';
            requerido += (injunction.Account_Client__r.BillingCity != null) ? injunction.Account_Client__r.BillingCity+'\n' : '\n';
            requerido += 'Código Postal: ';
            requerido += (injunction.Account_Client__r.BillingPostalCode != null) ? injunction.Account_Client__r.BillingPostalCode+'\n' : '\n';
            requerido += 'Telefone: ';
            requerido += (injunction.Account_Client__r.Phone != null) ? injunction.Account_Client__r.Phone+'\n' : '\n';
            requerido += 'Fax: ';
            requerido += (injunction.Account_Client__r.Fax != null) ? injunction.Account_Client__r.Fax+'\n' : '\n';
            requerido += 'Email: ';
            requerido += (injunction.Account_Client__r.Email__c != null) ? injunction.Account_Client__r.Email__c+'\n' : '\n';
            requerido += 'NIF: ';
            requerido += (injunction.Account_Client__r.NIF__c != null) ? injunction.Account_Client__r.NIF__c+'\n' : '\n';
            requerido += 'Domicílio convencionado: \n\n';
            
            String fiadores = '';
            if(hasPersonalGuarantee){
                fiadores += 'REQUERIDO (FIADOR(S))\n\n';
                for(String contract : contractGuaranteesIds.keySet()){
                    List<String> guaranteeIds = contractGuaranteesIds.get(contract);
                    if(guaranteeIds.size() > 1){
                        fiadores += 'Fiadores do contracto '+contract+':\n';
                    }else if(guaranteeIds.size() == 1){
                        fiadores += 'Fiador do contracto '+contract+':\n';
                    }
                    for(String guarantee : guaranteeIds){
                        Contact contact = guaranteeDetails.get(guarantee);
                        fiadores += 'Nome/Designação: '+contact.Name+'\n';
                        fiadores += 'Morada: ';
                        fiadores += (contact.MailingStreet != null) ? contact.MailingStreet+'\n' : '\n'; 
                        fiadores += 'Localidade: ';
                        fiadores += (contact.MailingCity != null) ? contact.MailingCity+'\n' : '\n';
                        fiadores += 'Código Postal: ';
                        fiadores += (contact.MailingPostalCode != null) ? injunction.Account_Client__r.BillingPostalCode+'\n' : '\n';
                        fiadores += 'Telefone: ';
                        fiadores += (injunction.Account_Client__r.Phone != null) ? injunction.Account_Client__r.Phone+'\n' : '\n';
                        fiadores += 'Fax: ';
                        fiadores += (injunction.Account_Client__r.Fax != null) ? injunction.Account_Client__r.Fax+'\n' : '\n';
                        fiadores += 'Email: ';
                        fiadores += (injunction.Account_Client__r.Email__c != null) ? injunction.Account_Client__r.Email__c+'\n' : '\n';
                        fiadores += 'NIF: ';
                        fiadores += (injunction.Account_Client__r.NIF__c != null) ? injunction.Account_Client__r.NIF__c+'\n' : '\n';
                        fiadores += 'Domicílio convencionado: \n\n';
                    }
                }
            }
            
            Decimal quantia = injunction.Claimed_Amount__c + injunction.Payment_Amount_to_The_End_Of_Contract__c;
            Decimal juros = injunction.Interest_Charges__c;
            Decimal outras = injunction.Collection_Fee_Amount__c + injunction.Residual_Value_Amount__c;
            Decimal taxa = (injunction.Judicial_Fee_Amount__c != null) ? injunction.Judicial_Fee_Amount__c : 0;
            Decimal total = quantia + juros + outras + taxa;
            String liquidacao = 'LIQUIDAÇÃO E FACTOS:\n\n';
            liquidacao += 'O(s) requerentes solicita(m) que seja(m) notificados (o)s requeridos, no sentido de lhe(s) ser paga a quantia de:\n';
            liquidacao += '€ '+total+'\n';
            liquidacao += 'Assim discriminada:\n';
            liquidacao += 'Capital: € '+quantia+' (total à data da resolução - vencido e vincendo até final contrato)\n';
            liquidacao += 'Juros de mora: € '+juros+'\n';
            liquidacao += 'Outras quantias: € '+injunction.Collection_Fee_Amount__c+' + € '+injunction.Residual_Value_Amount__c+'\n';
            liquidacao += 'Taxa de justiça: € '+taxa+'\n';
            liquidacao += 'Contracto de: Aluguer\n';
            for(Application__c app : apps){
                liquidacao += 'Data do contrato '+app.Name+': '+(app.Invoice_Payment_Date__c).format()+'\n';
            	liquidacao += 'Período a que se refere: '+(app.Beginning_of_Term__c).format()+' (inicio contrato) a '+dunningDate+' (data da resolução)\n';
            }
            liquidacao += 'Obrigação emergente de transacção comercial (DL. 32/2003 de 17 de Fevereiro): \n';
            liquidacao += 'Apresentar à distribuição no caso de frustração de notificação do requerido: \n';
            liquidacao += 'Tribunal competente para distribuição: \n\n';
            
            
            Integer paragraphCounter = 1;
            //---1
            String t1 ='Factos: \n\n'+ (paragraphCounter++)+'º A Requerente é uma sociedade comercial cujo objeto consiste em aluguer de bens móveis'+
' nomeadamente de equipamentos de escritório, de máquinas e de equipamentos informáticos,'+
' incluindo softwares e hardwares, e de equipamentos industriais.\n\n';
        
            //---2
            String t2 =  (paragraphCounter++)+'º No âmbito da sua atividade celebrou com a Requerida '+injunction.Account_Client__r.Name+' ';
            if(moreThanOneBC){
                t2 += bcs.size()+' contratos de locação financeira – ';
            }else{
                t2 += bcs.size()+' contrato de locação financeira – ';
            }
            for(Integer i = 0; i<contractNames.size(); i++){
                String name = contractNames.get(i);
                if(i == 0){
                    t2 += 'contracto '+name;
                }
                else if(i == contractNames.size()-1){
                    t2 += ' e contracto '+name;
                }else{
                    t2 += ', contracto '+name;
                }
            }
            if(moreThanOneBC){
                t2 += ' - ao abrigo dos quais ';
            }else{
                t2 += ' - ao abrigo do qual ';
            }
			t2 += 'se comprometeu a adquirir e a proporcionar-lhe o gozo, temporário e oneroso dos seguintes bens: ';
            
            for(String app : appToEquips.keySet()){
                t2 += '\nRelativamente ao contracto '+app+': ';
                Integer count = 0;
                List<Equipment__c> appEquips = appToEquips.get(app);
                for(Equipment__c e : appEquips){
                    if(count == 0){
                        t2 += e.Equipment_Quantity__c+' '+e.Equipment_Description__c+' Nº DE SÉRIE '+e.Equipment_Serial_Number__c;
                    }else if(count == appEquips.size()-1){
                        t2 += ' e '+e.Equipment_Quantity__c+' '+e.Equipment_Description__c+' Nº DE SÉRIE '+e.Equipment_Serial_Number__c;
                    }else{
                        t2 += ', '+e.Equipment_Quantity__c+' '+e.Equipment_Description__c+' Nº DE SÉRIE '+e.Equipment_Serial_Number__c;
                    }
                    count++;
                }
            }
            
            if(moreThanOneBC){
                t2 += '.\n Todos melhor identificados nos Autos de Aceitação, de ';
            }else{
                t2 += '.\n Todos melhor identificados no Auto de Aceitação, de ';
            }
            
            for(Integer i = 0; i<signedCertificateDates.values().size(); i++){
                String signedDate = signedCertificateDates.values().get(i);
                if(i == 0){
                    t2 += signedDate;
                }
                else if(i == signedCertificateDates.size()-1){
                    t2 += ' e '+signedDate;
                }else{
                    t2 += ', '+signedDate;
                }
            }
            t2 += '\n\n';
            
            //---3
            String t3 = '';
            if(hasPersonalGuarantee){
                t3 += (paragraphCounter++)+'º ';
                 for(String contract : contractGuaranteesIds.keySet()){
                     List<String> guaranteeIds = contractGuaranteesIds.get(contract);
                     Integer count = 0;
                    for(String guarantee : guaranteeIds){
                        if(count==0){
                            t3 += guaranteeDetails.get(guarantee).Name;
                        }else if(count == guaranteeIds.size()-1){
                            t3 += ' e '+guaranteeDetails.get(guarantee).Name;
                        }else{
                            t3 += ', '+guaranteeDetails.get(guarantee).Name;
                        }
                        count++;
                    }
                     if(count > 1){
                        t3 += ', também requeridos nos autos, responsabilizaram-se, na qualidade de fiadores, ';
                     }
                     else{
                        t3 += ', também requerido/a nos autos, responsabilizou-se, na qualidade de fiador/a, ';
                     }
                     t3 += 'por todas as obrigações decorrentes do contrato '+contract+' assumidas pelo locatário '+injunction.Account_Client__r.Name;
                     t3 += ', com renuncia ao benefício da excussão prévia.\n\n';
                 }
            }
            
            //---4
            String t4 = (paragraphCounter++)+'º  Em cumprimento ';
            if(moreThanOneBC){
                t4 += 'desses contractos ';
            }else{
                t4 += 'desse contracto ';
            }
            t4 += 'por indicação e sob proposta da Requerida, a Requerente adquiriu os mencionados bens ';
            if(moreThanOneSociety){
                t4 += 'às sociedades ';
            }else{
                t4 += 'à sociedade ';
            }
            Integer count = 0;
            for(String society : societies){
                if(count == 0){
                    t4 += society;
                }else if(count == societies.size()-1){
                    t4 += ' e '+society;
                }else{
                    t4 += ', '+society;
                }
                count++;
            }
            t4 += '\n\n';
            
            //---5
            String t5 = (paragraphCounter++)+'º ';
            for(String contract : signedCertificateDates.keySet()){
                t5 += 'Relativamente ao contracto '+contract+', em '+signedCertificateDates.get(contract)+' a Requerente, por intermédio do fornecedor, entregou os bens supra identificados, pelo prazo de ';
                t5 += contractTerms.get(contract)+' meses, mediante o pagamento de prestações devidas a título de renda, mensais e sucessivas, no montante de € '+contractRents.get(contract)+' cada, ao qual acresce o IVA à respetiva taxa legal à data.\n';
            }
            t5 += '\n\n';
            
            //---6
            String t6 = '';
            if(contractInsurances.size() > 0){
                t6 += (paragraphCounter++)+'º ';
            }
            for(String contract : contractInsurances.keySet()){
                t6 += 'Relativamente ao contracto '+contract+' acresce o prémio de seguro mensal dos equipamentos no valor de € '+contractInsurances.get(contract);
                t6 += ' ao qual o locatário está obrigado nos termos da clausula 5 do contrato de locação e ao qual a requerida aderiu conforme auto de aceitação\n';
            }
            
            //---7
            String t7 = ''; 
            if(t6.length() > 0){
                t6 += '\n\n';
                t7 = (paragraphCounter++)+'º O que perfaz o valor mensal de ';
                count = 0;
                for(String contract : contractRents.keySet()){
                    Decimal totalValue = contractRents.get(contract);
                    if(contractInsurances.containsKey(contract)){
                        totalValue += contractInsurances.get(contract);
                    }
                    if(count == 0){
                        t7 += ' € '+totalValue+' para o contracto '+contract;
                    }else if(count == contractRents.size()-1){
                        t7 += ' e € '+totalValue+' para o contracto '+contract;
                    }else{
                        t7 += ', € '+totalValue+' para o contracto '+contract;
                    }
                    count++;
                }
            }
            if(t7.length() > 0){
                t7 += '\n\n';
            }
            
            //---8
            String t8 = (paragraphCounter++)+'º ';
            for(String contract : paymentMethods.keySet()){
                String method = paymentMethods.get(contract);
                if(method.equalsIgnoreCase('débito directo')){
                    t8 += 'Relativamente ao contracto '+contract+' as rendas seriam pagas por '+method+' (débito directo ou referência MB)';
                    t8 += ' na conta da Requerida '+injunction.Account_Client__r.Name;
                }else if(method.equalsIgnoreCase('referência MB')){
                    t8 += 'Relativamente ao contracto '+contract+' as rendas seriam pagas por '+method+' (débito directo ou referência MB)';
                }
                t8 += ' conforme contrato e auto de aceitação assinados pela Requerente.\n';
            }
            t8 += '\n';
            
            //---9
            Map<Id,c2g__codaInvoice__c> invoices = new Map<Id,c2g__codaInvoice__c>([SELECT Id, c2g__PaymentStatus__c, c2g__DueDate__c, c2g__InvoiceTotal__c, Invoice_Express_Number_text__c, Application__r.Name
                                                                                    FROM c2g__codaInvoice__c 
                                                                                    WHERE c2g__PaymentStatus__c = 'Unpaid' AND Collection_Case__c IN 
                                                                                    (SELECT Collection_Case__c FROM Injunction_Procedure__c WHERE Id = :injId)]);
            
            Map<String,List<c2g__codaInvoice__c>> bcToInvoices = new Map<String,List<c2g__codaInvoice__c>>();
            for(c2g__codaInvoice__c inv : invoices.values()){
                if(bcToInvoices.containsKey(inv.Application__r.Name)){
                    List<c2g__codaInvoice__c> aux = bcToInvoices.get(inv.Application__r.Name);
                    aux.add(inv);
                    bcToInvoices.put(inv.Application__r.Name, aux);
                }else{
                    List<c2g__codaInvoice__c> aux = new List<c2g__codaInvoice__c>();
                    aux.add(inv);
                    bcToInvoices.put(inv.Application__r.Name, aux);
                }
            }
            
            List<c2g__codaInvoiceLineItem__c> invLineItems = [SELECT c2g__Invoice__c, c2g__Product__r.Name, c2g__Product__r.ProductCode, Billing_Contract_Line_Item__r.Billing_Period_Date__c, Billing_Contract_Line_Item__r.Billing_Frequency__c 
                                                              FROM c2g__codaInvoiceLineItem__c 
                                                              WHERE c2g__Invoice__c IN :invoices.keySet()];
            
            Map<Id, List<c2g__codaInvoiceLineItem__c>> invoiceToLineItems = new Map<Id, List<c2g__codaInvoiceLineItem__c>>();
            for(c2g__codaInvoiceLineItem__c invLI : invLineItems){
                if(invoiceToLineItems.containsKey(invLi.c2g__Invoice__c)){
                    List<c2g__codaInvoiceLineItem__c> aux = invoiceToLineItems.get(invLi.c2g__Invoice__c);
                    aux.add(invLI);
                    invoiceToLineItems.put(invLi.c2g__Invoice__c, aux);
                }else{
                    List<c2g__codaInvoiceLineItem__c> aux = new List<c2g__codaInvoiceLineItem__c>();
                    aux.add(invLI);
                    invoiceToLineItems.put(invLi.c2g__Invoice__c, aux);
                }
            }
            
            Integer alphabetCounter = 0;
            List<String> alphabet = new List<String>{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
            String t9 = (paragraphCounter++)+'º ';
            
            for(String contract : bcToInvoices.keySet()){
                t9 += 'No âmbito do contrato '+contract+' foram emitidas e enviadas para a Requerida através do correio eletrónico pela Requerida fornecido aquando da celebração do contrato, as seguintes faturas:\n\n';
                List<c2g__codaInvoice__c> invs = bcToInvoices.get(contract);
                for(c2g__codaInvoice__c inv : invs){
                    boolean isMonthly = contractFrequencies.get(inv.Application__r.Name);
                    
                    t9 += alphabet.get(alphabetCounter++)+') factura nº '+inv.Invoice_Express_Number_text__c+', no montante de € '+inv.c2g__InvoiceTotal__c+' constituída por: ';
                    List<c2g__codaInvoiceLineItem__c> lineItems = invoiceToLineItems.get(inv.Id);
                    for(Integer i = 0; i<lineItems.size(); i++){
                        c2g__codaInvoiceLineItem__c li = lineItems.get(i);
                        
                        Date startDate = li.Billing_Contract_Line_Item__r.Billing_Period_Date__c;
                        String startDateStr = (startDate != null) ? startDate.format() : '<startDate>';
                        Date endDate;
                        if(startDate != null && isMonthly){
                            endDate = startDate.addMonths(1).toStartofMonth().addDays(-1);
                        }else if(startDate != null && !isMonthly){
                            endDate = startDate.addMonths(3).toStartofMonth().addDays(-1);
                        }
                        String endDateStr = (endDate != null) ? endDate.format() : '<endDate>';
                        
                        String description = getDescriptionByProductCode(li, startDateStr, endDateStr, dunningDateObj, isMonthly);
                        //update t9
                        if(i == 0){
                            t9 += description;
                        }else if(i == lineItems.size()-1){
                            t9 += ' e '+description;
                        }else{
                            t9 += ', '+description;
                        }
                    }
                    Date dueDate = inv.c2g__DueDate__c;
                    String dueDateStr = dueDate.format();
                    t9 += ', vencida em '+dueDateStr+'\n\n';
                }
            }
            t9 += '\n';
            
            
            //---10
            String t10 = (paragraphCounter++)+'º ';
            t10 += 'Após data de vencimento das referidas faturas, o pagamento das mesmas não foi efetuado\n';
            
            //---11
            String t11 = (paragraphCounter++)+'º Não obstante a interpelação para o pagamento das supra indicadas faturas, por comunicação escrita enviada através do endereço eletrónico fornecido pela Requerida, '+
'contacto telefónico e contacto pessoal, a Requerida nada pagou\n\n';
            
            //--12
            String t12 = (paragraphCounter++)+'º  Em face da falta de pagamento das rendas vencidas e após ter diligenciado inúmeras vezes junto da Requerida para que esta efetuasse o pagamento, diligências estas que se'+
' revelaram infrutíferas, a Requerente comunicou à Requerida, em '+dunningDate+' a resolução ';
            if(moreThanOneBC){
                t12 += 'dos contractos ';
            }else{
                t12 += 'do contracto ';
            }
            count = 0;
            for(String contract : contractNames){
                if(count == 0){
                    t12 += contract;
                }else if(count == contractNames.size()-1){
                    t12 += ' e '+contract;
                }else{
                    t12 += ', '+contract;
                }
                count++;
            }
            t12 += ', por incumprimento definitivo\n\n';
            
            //---13
            String t13 = (paragraphCounter++)+'º ';
            for(Billing_Contract__c bc : bcs.values()){
                t13 += 'Com a resolução do contracto '+bc.Name+' tornaram-se exigíveis à Requerida';
                if(hasPersonalGuarantee){
                    t13 += ' e seus fiadores que renunciaram ao benefício da excussão prévia,';
                }
                t13 += ' as rendas vincendas, nos termos da clausula 7.3 das Condições Gerais e Declaração de Fiança do contrato, no montante de € '+bc.Payment_Amount_to_The_End_Of_Contract__c;
            }
            t13 += 'O que perfaz o valor total de '+injunction.Payment_Amount_to_The_End_Of_Contract__c+'\n\n';
            
            //---14
            String t14 = (paragraphCounter++)+'º Pelo que, desde o momento da resolução ';
            if(moreThanOneBC){
                t14 += 'dos contractos ';
            }else{
                t14 += 'do contracto ';
            }
            //quantia = claimedAmount + payment till end
            t14 += 'por incumprimento definitivo, em '+dunningDate+', encontra-se em dívida a quantia global de € '+quantia;
            t14 += ', valor este reclamado à Requerida\n\n';
            
            //---15
            //juros = interestCharges
            String t15 = (paragraphCounter++)+'º A este montante acrescem juros de mora vencidos, contabilizados à taxa anual de 15,00% desde '+dunningDate+' até à presente data, no montante de € '+juros+'\n\n';
            
            //---16
            Decimal fee = injunction.Collection_Fee_Amount__c;
            String t16 = (paragraphCounter++)+'º Bem como, o valor de € '+fee+' a título de indemnização pelos custos de cobrança da dívida, nos termos do artigo 7.º do DL n.º 62/2013, de 10 de Maio.\n\n';
            
            //---17
            Decimal quantiaTotal = injunction.Injuction_Claimed_Amount_Total__c - injunction.Residual_Value_Amount__c;
            String t17 = (paragraphCounter++)+'.º Pelo que, o valor total em dívida ascende na presente data a € '+ quantiaTotal+'\n\n';
            
            //---18
            String t18 = (paragraphCounter++)+'º A Locatária ao celebrar ';
            if(moreThanOneBC){
                t18 += 'os contractos de Locação ';
            }else{
                t18 += 'o contracto de Locação ';
            }
            count = 0;
            for(String contract : contractNames){
                if(count == 0){
                    t18 += contract;
                }else if(count == contractNames.size()-1){
                    t18 += ' e '+contract;
                }else{
                    t18 +=', '+contract;
                }
                count++;
            }
            t18 += ' obrigou-se ao pagamento mínimo dos ';
            count = 0;
            for(String contract : contractNames){
                if(count == 0){
                    t18 += contractTerms.get(contract);
                }else if(count == contractNames.size()-1){
                    t18 += ' e '+contractTerms.get(contract);
                }else{
                    t18 += ', '+contractTerms.get(contract);
                }
                count++;
            }
            t18 += ' alugueres ajustados, e ainda a restituir os bens findos ';
            if(moreThanOneBC){
                t18 += 'os contractos, sendo que os contratos cessaram em ';
            }else{
                t18 += 'o contracto, sendo que o contracto cessou em ';
            }
            t18 += dunningDate+', com a comunicação da resolução.\n\n';
            
            //---19
            String t19 = (paragraphCounter++)+'.º Como a Requerida não restituiu os bens alugados até à presente data, apesar de interpelada para tal aquando da resolução do contrato, a Requerente presume que aquela '+
'pretende continuar a utilizar os mesmos na sua atividade e adquirir a sua propriedade\n\n';
            
            //---20
            String t20 = (paragraphCounter++)+'.ª A titulo de aquisição da propriedade dos bens locados, além das quantias supra descritas (valor total de € '+quantiaTotal+'), terá que proceder previamente ao pagamento do preço'; 
            t20 += ' que ora se fixa em € '+injunction.Residual_Value_Amount__c+' (IVA incluído), correspondente a 15% do valor de aquisição dos equipamentos, conforme ';
            if(moreThanOneBC){
                t20 += 'as faturas ';
            }else{
                t20 += 'a fatura ';
            }
            count = 0;
            for(String invoice : equipmentInvoices){
                if(count == 0){
                    t20 += invoice;
                }else if(count == equipmentInvoices.size()-1){
                    t20 += ' e '+invoice;
                }else{
                    t20 += ', '+invoice;
                }
                count++;
            }
            t20 += '.\n\n';
            
            //---21
            String t21 = (paragraphCounter++)+'º A venda ora proposta fica condicionada ao prévio pagamento da dívida e do preço, só se transferindo a propriedade dos bens em causa após integral pagamento da dívida e do preço.\n\n';
            
            //---22
            String t22 = (paragraphCounter++)+'º Ao montante total deverão acrescer ainda os juros de mora vincendos desde a data da instauração da presente injunção até efetivo e integral pagamento, à taxa convencionada de '+
'15,00% sobre a quantia de € '+(quantiaTotal-fee)+'\n\n';
            
            //---23
            String t23 = (paragraphCounter++)+'º Bem como o valor de € '+ injunction.Judicial_Fee_Amount__c +' a título de taxa de justiça devida pela instauração da presente injunção\n\n';
            
            //---24
            String t24 = (paragraphCounter++)+'º O que perfaz o valor total de € '+injunction.Injuction_Claimed_Amount_Total__c;
            
            //join paragraphs and update
            String content = requerido + fiadores + liquidacao + t1 + t2 + t3 + t4 + t5 + t6 + t7 + t8 + t9 + t10 + t11 + t12 + t13 + t14 + t15 + t16 + t17 + t18 + t19 + t20 + t21 + t22 + t23 + t24;
            injunction.Facts__c = content;
            update injunction;
        
            Attachment a = new Attachment();
            a.Name = injunction.Name+'.txt';
            a.Body = Blob.valueOf(content);
            a.ContentType = 'text/html';
            a.ParentId = injId;
            a.Description = 'Text File for '+injunction.Name;
            insert a;
            
        	return 'Create Injunction Text File Successfully';
        }
    }
    
    /*
     * SETUP HELPERS
     */ 
    
    
    private static List<String> getContractNamesList(Map<Id, Billing_Contract__c> bcs){
        List<String> toReturn = new List<String>();
        for(Billing_Contract__c bc : bcs.values()){
            toReturn.add(bc.Name);
        }
        return toReturn;
    }
    
    private static List<String> getPersonalGuaranteesList(Injunction_Procedure__c inj){
        List<String> toReturn = new List<String>();
        if(inj.Personal_Guarantee_Signer_1__r.Name != null){
            toReturn.add(inj.Personal_Guarantee_Signer_1__r.Name);
        }
        if(inj.Personal_Guarantee_Signer_2__r.Name != null){
            toReturn.add(inj.Personal_Guarantee_Signer_2__r.Name);
        }
        return toReturn;
    }
    
    private static List<String> getEquipmentInvoices(List<Application__c> apps){
        List<String> toReturn = new List<String>();
        for(Application__c app : apps){
            toReturn.add(app.Invoice_Number__c);
        }
        return toReturn;
    }
    
    private static Set<String> getSocietiesSet(Map<Id, Billing_Contract__c> bcs){
        Set<String> toReturn = new Set<String>();
        for(Billing_Contract__c bc : bcs.values()){
            toReturn.add('"'+bc.Account_Vendor__r.Name+'", '+'NIPC '+bc.Account_Vendor__r.NIF__c+', com sede em '+bc.Account_Vendor__r.BillingStreet+', '+ bc.Account_Vendor__r.BillingPostalCode);
        }
        return toReturn;
    }
    
    private static Map<String,String> getSignedCertificateDatesMap(List<Application__c> apps, Map<Id,Billing_Contract__c> appToBc){
        Map<String,String> toReturn = new Map<String,String>();
        for(Application__c app : apps){
            Billing_Contract__c bc = appToBc.get(app.Id);
            toReturn.put(bc.Name, (app.Delivery_Certificate_Signed__c).format());
        }
        return toReturn;
    }
    
    private static Map<String,List<String>> getContractGuaranteesIds(List<Application__c> apps){
        Map<String,List<String>> toReturn = new Map<String,List<String>>();
        for(Application__c app : apps){
            if(app.Personal_Guarantee_Signer_1__c != null){
                if(toReturn.containsKey(app.Name)){
                    List<String> aux = toReturn.get(app.Name);
                    aux.add(app.Personal_Guarantee_Signer_1__c);
                    toReturn.put(app.Name, aux);
                }else{
                    List<String> aux = new List<String>();
                    aux.add(app.Personal_Guarantee_Signer_1__c);
                    toReturn.put(app.Name, aux);
                }
            }
            if(app.Personal_Guarantee_Signer_2__c != null){
                if(toReturn.containsKey(app.Name)){
                    List<String> aux = toReturn.get(app.Name);
                    aux.add(app.Personal_Guarantee_Signer_2__c);
                    toReturn.put(app.Name, aux);
                }else{
                    List<String> aux = new List<String>();
                    aux.add(app.Personal_Guarantee_Signer_2__c);
                    toReturn.put(app.Name, aux);
                }
            }
        }
        return toReturn;
    }
    
    private static Map<Id,Contact> populateGuaranteeDetails(List<List<String>> contactIds){
        //im so sorry......
        List<String> aux = new List<String>();
        
        for(List<String> l : contactIds){
            for(String s : l){
                aux.add(s);
            }
        }
        
        return new Map<Id,Contact>([SELECT Id, Name, MailingStreet, MailingCity, MailingPostalCode, Phone, Email, Fax, Account.NIF__c
                                   FROM Contact
                                   WHERE Id IN :aux]);
    }
    
    private static Map<String,Boolean> getFrequenciesMap(List<Application__c> apps, Map<Id,Billing_Contract__c> appToBc){
        Map<String,Boolean> toReturn = new Map<String,Boolean>();
        for(Application__c app : apps){
            Billing_Contract__c bc = appToBc.get(app.Id);
            if(app.Payment_Freq__c.equals('Monthly')){
                toReturn.put(bc.Name, true);
            }else if(app.Payment_Freq__c.equals('Quarterly')){
                toReturn.put(bc.Name, false);
            }
        }
        return toReturn;
    }
    
    private static Map<String,String> getEndOfTermsMap(List<Application__c> apps, Map<Id,Billing_Contract__c> appToBc){
        Map<String,String> toReturn = new Map<String,String>();
        for(Application__c app : apps){
            Billing_Contract__c bc = appToBc.get(app.Id);
            toReturn.put(bc.Name, (app.End_of_Term__c).format());
        }
        return toReturn;
    }
    
    private static Map<String,String> getContractTermsMap(Map<Id, Billing_Contract__c> bcs){
        Map<String,String> toReturn = new Map<String,String>();
        for(Billing_Contract__c bc : bcs.values()){
            toReturn.put(bc.Name, ''+bc.Contract_Term__c);
        }
        return toReturn;
    }
    
    private static Map<String,Decimal> getContractRentsMap(Map<Id, Billing_Contract__c> bcs){
        Map<String,Decimal> bcToRent = new Map<String,Decimal>();
        List<Billing_Contract_Line_Item__c> lineItems = [SELECT Billing_Frequency__c, Contract_Line_Value__c, Billing_Contract__r.Name FROM Billing_Contract_Line_Item__c WHERE Billing_Contract__c IN :bcs.keySet() AND Product__r.Name = 'Aluguer Mensal Equipamento CANDOR RENTING S.A.'];
        for(Billing_Contract_Line_Item__c li : lineItems){
            //ignore duplicate rents for same BC
            if(!bcToRent.containsKey(li.Billing_Contract__r.Name)){
                bcToRent.put(li.Billing_Contract__r.Name, li.Contract_Line_Value__c);
            }
        }
        return bcToRent;
    }
    
    private static Map<String,Decimal> getContractInsurancesMap(Map<Id, Billing_Contract__c> bcs){
        Map<String,Decimal> bcToInsurance = new Map<String,Decimal>();
        List<Billing_Contract_Line_Item__c> lineItems = [SELECT Billing_Frequency__c, Contract_Line_Value__c, Billing_Contract__r.Name FROM Billing_Contract_Line_Item__c WHERE Billing_Contract__c IN :bcs.keySet() AND Product__r.Name = 'Prémio de Seguro'];
        for(Billing_Contract_Line_Item__c li : lineItems){
            //ignore duplicate rents for same BC
            if(!bcToInsurance.containsKey(li.Billing_Contract__r.Name)){
                bcToInsurance.put(li.Billing_Contract__r.Name, li.Contract_Line_Value__c);
            }
        }
        return bcToInsurance;
    }
    
    private static Map<String,String> getPaymentMethodsMap(Map<Id, Billing_Contract__c> bcs){
        Map<String,String> toReturn = new Map<String,String>();
        for(Billing_Contract__c bc : bcs.values()){
            String method = '';
            if(bc.Payment_Method__c.equalsIgnoreCase('direct debit')){
                method = 'débito directo';
            }else if(bc.Payment_Method__c.equalsIgnoreCase('atm reference')){
                method = 'referência MB';
            }
            toReturn.put(bc.Name, method);
        }
        return toReturn;
    }
    
    private static Map<String,List<Date>> getFutureInvoiceDates(Map<Id,Billing_Contract__c> bcs, Date injDate){
        Map<String,List<Date>> toReturn = new Map<String,List<Date>>();
        List<Billing_Contract_Line_Item__c> bcDates = [SELECT Billing_Period_Date__c, Billing_Contract__r.Name FROM Billing_Contract_Line_Item__c WHERE Billing_Contract__c IN :bcs.keySet() AND Billing_Period_Date__c > :injDate];
        for(Billing_Contract_Line_Item__c li : bcDates){
            if(toReturn.containsKey(li.Billing_Contract__r.Name)){
                List<Date> aux = toReturn.get(li.Billing_Contract__r.Name);
                aux.add(li.Billing_Period_Date__c);
                toReturn.put(li.Billing_Contract__r.Name, aux);
            }else{
                List<Date> aux = new List<Date>();
                aux.add(li.Billing_Period_Date__c);
                toReturn.put(li.Billing_Contract__r.Name, aux);
            }
        }
        return toReturn;
    }
    
    private static String getClosestAfterDate(List<Date> dates, Date injCreatedDate){
        if(dates == null || dates.size() == 0){
            return '<closestAfterDate>';
        }
        Integer days = 100000000;
        Date nearest = injCreatedDate;
        Integer count = 0;
        do{
            Date d = dates.get(count);
            if(d>injCreatedDate && days>injCreatedDate.daysBetween(d)){
                days = injCreatedDate.daysBetween(d);
                nearest = d;
            }
            count++;
        }while(count < dates.size());
        return nearest.format();
    }
    
    private static String getDescriptionByProductCode(c2g__codaInvoiceLineItem__c li, String startDateStr, String endDateStr, Date dunningDate, boolean isMonthly){
        String description = '';
        //aluguer mensal
        if(li.c2g__Product__r.ProductCode.equals('PT01') || li.c2g__Product__r.ProductCode.equals('PT18')){
            description = 'Renda mensal';
        }
        //aluguer mensal porporcional
        else if(li.c2g__Product__r.ProductCode.equals('PT08')){
            Date endProportional;
            if(isMonthly){
                endProportional = dunningDate.addMonths(1).toStartofMonth().addDays(-1);
            }else{
                endProportional = dunningDate.addMonths(3).toStartofMonth().addDays(-1);
            }
            description = 'Aluguer mensal proporcional';
        }
        //aluguer trimestral
        else if(li.c2g__Product__r.ProductCode.equals('PT09') || li.c2g__Product__r.ProductCode.equals('PT19')){
            description = 'Renda trimestral';
        }
        //aluguer trimestral porporcional
        else if(li.c2g__Product__r.ProductCode.equals('PT10')){
            description = 'Aluguer trimestral';
        }
        //juros de mora
        else if(li.c2g__Product__r.ProductCode.equals('PT15')){
            description = 'Juros de mora vencidos, à taxa legal de 15,00%, sobre o valor em divida';
        }
        //1o aviso
        else if(li.c2g__Product__r.ProductCode.equals('PT04')){
            description = 'Custos suportados pela Requerente com a falta de pagamento das rendas, conforme previsto na cláusula 6.4 do contrato';
        }
        //2o aviso
        else if(li.c2g__Product__r.ProductCode.equals('PT05')){
            description = 'Custos suportados pela Requerente com a falta de pagamento das rendas, conforme previsto na cláusula 6.4 do contrato';
        }
        //3o aviso
        else if(li.c2g__Product__r.ProductCode.equals('PT13')){
            description = 'Custos suportados pela Requerente com a falta de pagamento das rendas, conforme previsto na cláusula 6.4 do contrato';
        }
        else{
            description = li.c2g__Product__r.Name;
        }
        return description;
    }
}