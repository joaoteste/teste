public class AccountTriggerHandler extends TriggerHandler{
    
    
    public static void recordTypeWorkflow(List<Account> accountList){
        
        Map<String,RecordType> recordTypeMap = new Map<String,RecordType>();
        
        List<RecordType> recordTypeList = new List<RecordType>([Select Id,Name From RecordType]);
        for(RecordType recordTypeAux : recordTypeList){
            if(recordTypeMap.get(recordTypeAux.Name)==null){
                recordTypeMap.put(recordTypeAux.Name,recordTypeAux);
            }
        }
        
        for(Account accountAux : accountList){
            if(accountAux.Type=='Channel Partner / Vendor'){
                accountAux.RecordTypeID = recordTypeMap.get('Account Channel Partner / Vendor').ID;
            }
            if(accountAux.Type=='Customer - Channel'){
                accountAux.RecordTypeID = recordTypeMap.get('Account Customer - Channel').ID;
            }
            if(accountAux.Type=='Service Provider'){
                accountAux.RecordTypeID = recordTypeMap.get('Service Provider').ID;
            }
            if(accountAux.Type=='Vendor Blocker'){
                accountAux.RecordTypeID = recordTypeMap.get('Vendor Blocker').ID;
            }
            if(accountAux.Type=='Account Master'){
                accountAux.RecordTypeID = recordTypeMap.get('Account Master').ID;         
            }
        }
    }
    
    public static void checkNIFRecordType(List<Account> accountList, Map<Id,Account> oldAccountMap){
      
        
        
        //CoMMENT
        //key:Nif+RecorTypeID -> Account)
        Map<String,Account> nifRecordTypeNewAccountMap = new Map<String,Account>();
        
        //List NIFs newAccounts
        List<String> newNIFList = new List<String>();
        
        //recordMap -> Aux Map to insert on nifRecordMap! key:RecordTypeId -> accountI
        //check if new list has duplciated (NIF;recordtypeID) values. Seprate Insert from update Account
        for(Account accountNew : accountList){  
            String nifRecordType = '' + accountNew.NIF__c + accountNew.RecordTypeId;
            //System.debug('Account: '+accountNew + ' ->nifRecordType:'+nifRecordType);
            if(accountNew.ID != null){
                if(accountNew.NIF__c != oldAccountMap.get(accountNew.Id).NIF__c || accountNew.RecordTypeID != oldAccountMap.get(accountNew.Id).RecordTypeID){
                    newNIFList.add(accountNew.NIF__c);
                    if(!nifRecordTypeNewAccountMap.containsKey(nifRecordType)){
                        nifRecordTypeNewAccountMap.put(nifRecordType,accountNew);
                    }
                    else{
                        //System.debug('Account: '+ accountNew.ID +' has duplicated values (NIF;RecordType) in the same list');
                        accountNew.addError('Duplicated values (NIF;RecordType) in the same list!');
                    }
                }
            }
            if(accountNew.ID==null){
                newNIFList.add(accountNew.NIF__c);
                if(!nifRecordTypeNewAccountMap.containsKey(nifRecordType)){
                    nifRecordTypeNewAccountMap.put(nifRecordType,accountNew);
                }
                else{
                    //System.debug('Account: '+ accountNew.ID +' has duplicated values (NIF;RecordType) in the same list');
                    accountNew.addError('Duplicated values (NIF;RecordType) in the same list!');
                }            
            }
        }
        
        if(nifRecordTypeNewAccountMap.isEmpty()){
            return;
        }
        
        //Update the MAp of oldAccounts with new nifs
        Map<Id,Account>  accountMap = new Map <Id,Account>([Select Id, Name, NIF__c,RecordTypeID From Account where NIF__c IN :newNIFList]);  
        
        System.debug('accountMapBefore ' + accountMap);
        for(String key : nifRecordTypeNewAccountMap.keySet()){
            Account newAccountElement = nifRecordTypeNewAccountMap.get(key);
            Id newAccountId = newAccountElement.Id;
            if(newAccountId!=null){
                accountMap.put(newAccountId,newAccountElement);
            }
        }
        System.debug('accountMapAfterUpdate ' + accountMap);
        
        Account accUpdated = null;
        for(Id key : accountMap.keySet()){
            accUpdated =  accountMap.get(key);
            String nifRecordTypeToCompare ='' + accUpdated.NIF__c + accUpdated.RecordTypeID;
            System.debug('nifRecordTypeToCompare ' + nifRecordTypeToCompare);
            //Verify
            Account accountNew = nifRecordTypeNewAccountMap.get(nifRecordTypeToCompare);
            if(accountNew!=null){ 
                if((accountNew.Id == null) || (accountNew.ID != accUpdated.ID)){
                    System.debug('Erro');
                    accountNew.addError('Error: Found duplicated value NIF/RecordType');
                }
            }
        } 
        
        
    }
    
    /*public static Account getMasterAccount(List<Account> accountList){
        for(Account acc : accountList){
            if(acc.Type == 'Account Master'){
                return acc;
            }
        }
        return null;
    }*/
    
   
    public static String getValue(Account masterAccount, Account otherAccount, String field){
        if(masterAccount.get(field) == Null) return (String)otherAccount.get(field);
        else return (String)masterAccount.get(field);       
    }
    
    /*public static Map<String, Account> getAccountsForNif(List<Account> accountsList){
        Map<String, Account> accountsForNIF = new Map<String, Account>();
        if(accountsList!= null && !accountsList.isEmpty()){
            for(Account acc : accountsList){
               accountsForNIF.put(acc.NIF__c, acc); 
            }
        }
        return accountsForNIF; 
        
    }*/
    
    public static Account createAccountMaster(Account acc){
        Account newAccount = new Account();
        newAccount.NIF__c = acc.NIF__c;
        newAccount.BillingStreet = acc.BillingStreet;
        newAccount.BillingCity = acc.BillingCity;
        newAccount.BillingState = acc.BillingState;
        newAccount.BillingPostalCode = acc.BillingPostalCode;
        newAccount.BillingCountry = acc.BillingCountry;
        newAccount.BillingCountryCode = acc.BillingCountryCode;
        newAccount.Website = acc.Website;
        newAccount.MasterAccountInsertAllow__c = true;
        newAccount.Phone = acc.Phone;
        newAccount.Type = 'Account Master';
        newAccount.Email__c = acc.Email__c;
        newAccount.Name = acc.Name;        
        return newAccount;        
    }
    
    /*public static String errorInFields(Account masterAccount, Account otherAccount){
        List<String> fields = new List<String>{'NIF__c','BillingStreet','BillingCity','BillingState','BillingPostalCode','Email__c','BillingCountry','BillingCountryCode','Website','Phone'};
        for(String field : fields){
            if(getValue(masterAccount,otherAccount, field) == 'ERROR'){
                return 'Error on field: ' + field;
            }
        }
        return 'Validated!';
        
    }*/
    
    public static String hasDiferentFields(Account acc, Account acc2){
        List<String> fields = new List<String>{'NIF__c','BillingStreet','BillingCity','BillingState','BillingPostalCode','Email__c','BillingCountry','BillingCountryCode','Website','Phone'};
        for(String field : fields){
            if((String)acc.get(field) != (String)acc2.get(field)){
                system.debug(field + ' ' + (String)acc.get(field) + ' ' + (String)acc2.get(field));
                return 'Error on field: ' + field;
            }
        }
        return 'Validated!';        
    }
    
    public static String hasDiferentFields(Account acc, List<Account> accList){
        for(Account acc2 : accList){
            String result = AccountTriggerHandler.hasDiferentFields(acc, acc2);
            if(result != 'Validated!'){
                system.debug(result);                
                return 'Error on Account '+acc2.Name+' - '+result;
            }
        }
        return 'Validated!';
    }
    
}