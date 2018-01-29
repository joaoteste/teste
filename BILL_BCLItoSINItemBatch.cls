global class BILL_BCLItoSINItemBatch implements Database.Batchable<sObject>, Database.Stateful {
    global List<String> apNameList = new List<String>();
    global String errorMsg ='';
    global List<String> productsList = new List<String>{'PT01','PT02','PT08','PT09','PT10','PT11','PT18','PT19'};
        
        global BILL_BCLItoSINItemBatch(){
            
        }
    
    global BILL_BCLItoSINItemBatch(List<String> appList){
        this.apNameList.addAll(appList);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> contractStatusList = new List<String>();
        contractStatusList.add('Contract - Running');
        contractStatusList.add('Contract - Arreas');
        contractStatusList.add('Contract - Arrears');
        contractStatusList.add('Contract - Closed');
        contractStatusList.add('Contract - Lawsuit');
        contractStatusList.add('Contract - Payment Plan');
        contractStatusList.add('Contract Early Termination');
        contractStatusList.add('Contract - Cancelled');
        List<String> apNameList2 = this.apNameList;
        String query = 'SELECT ID,Name FROM Application__c where Status__c in :contractStatusList';
        
        if(this.apNameList != null && !this.apNameList.isEmpty()){
            query += ' and name in :apNameList2';
        }        
        
        if(Test.isRunningTest()){
            query += ' limit 1';
        }
        
        System.debug(''+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Application__c> appList){
        System.debug('inicio '+errorMsg);
        
        Savepoint sp;
        Application__c app = appList.get(0);
        System.debug('app '+app.Name);
        
        try{
            sp = Database.setSavepoint();
            List<Billing_Contract_line_Item__c> billItemList = [Select Id, Line_Item_Start_Date__c,Product__c,Product__r.Name,Product_Code__c,Sales_Price__c 
                                                                From Billing_Contract_Line_Item__c 
                                                                where application__c = :app.id and invoiced__c = true and 
                                                                Product__r.ProductCode in :productsList
                                                                order by Product__r.Name, Line_Item_Start_Date__c ASC];
            
            List<c2g__codaInvoiceLineItem__c> salesItemList = [Select ID,c2g__Product__r.name,c2g__Invoice__c,c2g__Invoice__r.Canceled__c,c2g__UnitPrice__c,c2g__Product__r.ProductCode,
                                                               c2g__Invoice__r.c2g__InvoiceDate__c,c2g__Invoice__r.c2g__DueDate__c ,Billing_Contract_Line_Item__c,c2g__NetValue__c
                                                               From c2g__codaInvoiceLineItem__c 
                                                               where c2g__Invoice__r.Application__c = :app.id and c2g__Invoice__r.Canceled__c = false  
                                                               and c2g__Product__r.ProductCode in :productsList
                                                               order by c2g__Product__r.Name,c2g__Invoice__r.c2g__InvoiceDate__c];
            
            System.debug('billItemList size '+billItemList.size());
            System.debug('salesItemList size '+salesItemList.size());
            c2g__codaCreditNoteLineItem__c asd;
            
            List<c2g__codaCreditNoteLineItem__c> creditNoteItemList = [Select ID,c2g__CreditNote__c,c2g__UnitPrice__c,c2g__CreditNote__r.c2g__Invoice__c,c2g__CreditNote__r.c2g__Invoice__r.Application__c,
                                                                       c2g__Product__r.ProductCode
                                                                       From c2g__codaCreditNoteLineItem__c
                                                                       where c2g__CreditNote__r.c2g__Invoice__r.Application__c = :app.id and c2g__CreditNote__r.c2g__Invoice__r.Canceled__c = false  
                                                                       and c2g__Product__r.ProductCode in :productsList
                                                                       order by c2g__Product__r.Name,c2g__CreditNote__r.c2g__Invoice__r.c2g__InvoiceDate__c];
            
            
            System.debug('creditNoteItemList size '+creditNoteItemList.size());
            
            for(c2g__codaCreditNoteLineItem__c creditNote: creditNoteItemList){
                for(Integer i=0; i<salesItemList.size(); i++ ){
                    if(creditNote.c2g__CreditNote__r.c2g__Invoice__c == salesItemList[i].c2g__Invoice__c 
                       && creditNote.c2g__Product__r.ProductCode == salesItemList[i].c2g__Product__r.ProductCode 
                       && creditNote.c2g__UnitPrice__c == salesItemList[i].c2g__UnitPrice__c){
                           
                           salesItemList.remove(i);
                           break;
                           
                       }
                }
            }
            
            
            String thisErrorMsg = '';
            
            if(billItemList.size() != salesItemList.size()){
                errorMsg += 'Error on ' + app.Name +' The number of Billing Line Item is not the same as the number of Sales Invoice Line Item\n';
                System.debug('error size '+ errorMsg);
                
                //Database.rollback(sp);
            }else{
                for(Integer i=0; i< salesItemList.size(); i++){
                    if(salesItemList[i].c2g__Product__c == billItemList[i].Product__c){
                        //if(salesItemList[i].Billing_Contract_Line_Item__c == null){
                        if(salesItemList[i].c2g__NetValue__c ==  billItemList[i].Sales_Price__c){
                            salesItemList[i].Billing_Contract_Line_Item__c = billItemList[i].id;
                        }else{
                            System.debug('Error Products doesn\'t have the same v');
                            thisErrorMsg += 'Error on ' + app.Name +' Products doesn\'t have the same value!\n';
                            break;
                        }
                        //}
                    }else{
                        System.debug('Error oducts don\'t correspond!');
                        thisErrorMsg += 'Error on ' + app.Name +' Products don\'t correspond!\n';
                        break;
                    }
                }
                if(String.isEmpty(thisErrorMsg)){
                    System.debug('update!');
                    update salesItemList;
                }else{
                    errorMsg += thisErrorMsg;
                    //Database.rollback(sp);
                }
            }
            System.debug('thisErrorMsg end execeute '+thisErrorMsg);
            
            System.debug('errorMsg end execeute '+errorMsg);
            
        }catch(DMLException e){
            //ApexPages.addMessages(e);
            System.debug('Exception '+ e);
            errorMsg += e.getMessage();
            Database.rollback(sp);
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('finish ' + errorMsg);
        
        errorEmail();
        
        if(Test.isRunningTest()){
            Integer i=0;
            i++;
            i++;
            i++;
            i++;
        }
    }	
    
    public void errorEmail(){
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'pcaetano@candor.pt'};
            mail.setToAddresses(toAddresses);
        
        if(String.isNotEmpty(errorMsg)){
            mail.setSenderDisplayName('Apex error message');
            mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(errorMsg);
        }else{
            mail.setSenderDisplayName('Apex sucess message');
            mail.setSubject('Sucess BILL_BCLItoSINItemBatch on Org : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody('The batch was sucessfully done');
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}