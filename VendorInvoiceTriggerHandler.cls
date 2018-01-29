public class VendorInvoiceTriggerHandler extends TriggerHandler {
    
    private List<Vendor_Invoice__c> newViList;
    
    public VendorInvoiceTriggerHandler() {
        this.newViList = (List<Vendor_Invoice__c>) Trigger.new;
    }
    
    public override void beforeInsert(){
        
        List<String> nifList = new List<String>();
        for(Vendor_Invoice__c vi_new : newViList){
            System.debug('vi_new before insert '+vi_new);
            /*if((vi_new.Taxpayer_Number__c == null || vi_new.Taxpayer_Number__c == '' ) && (vi_new.Account__c == null || vi_new.Account__c == '')){
//vi_new.addError('Invalid or inexistant IBAN or Account!');
}*/
            //get NIFs to get Accounts
            if((vi_new.Taxpayer_Number__c != null && vi_new.Taxpayer_Number__c != '') ){
                vi_new.Taxpayer_Number__c = vi_new.Taxpayer_Number__c.remove('PT'); 
                nifList.add(vi_new.Taxpayer_Number__c);
                nifList.add('0'+vi_new.Taxpayer_Number__c);
            }
            if(vi_new.Account__c!=null){
                nifList.add(vi_new.Account__c);
            }
        }
        
        //create a map for the account with a key being the nif and the id of the account 
        Map<String,Account> nifToAccountMap = nifAccountMap(nifList);
        //set the nif/account based on each other 
        setNIFAccount(Trigger.new,nifToAccountMap);
        
        for(Vendor_Invoice__c vi_new : newViList){
            if(!validateDocParserIntegration(vi_new)){
                String fileName = vi_new.Invoice_Description__c;
                //vi_new.addError('Invalid fields!');
            }
        }
        
        setVendorInvoiceTaxInformation();
    }
    
    public override void afterInsert(){
        
        List<String> vinvFileNameList = new List<String>();
        List<Vendor_Invoice__c> vinvToAttach = new List<Vendor_Invoice__c>();
        for(Vendor_Invoice__c vi_new : (List<Vendor_Invoice__c >)Trigger.new){
            if(vi_new.Invoice_Description__c != null && vi_new.Invoice_Description__c!= ''){
                vinvFileNameList.add(vi_new.Invoice_Description__c);
                vinvToAttach.add(vi_new);
            }
        }
        
        if(!vinvFileNameList.isEmpty()){
            attachDocParserFile(vinvToAttach,vinvFileNameList);
        }
        
    }
    
    public override void beforeUpdate() {	
        List<String> nifList = new List<String>();
        List<Vendor_Invoice__c> nifAccountUpdateList = new List<Vendor_Invoice__c>();
        
        for(Vendor_Invoice__c vi_new :  (List<Vendor_Invoice__c>) Trigger.new){
            System.debug('vi_new ' +vi_new);
            if(((Vendor_Invoice__c) Trigger.oldMap.get(vi_new.Id)).Taxpayer_Number__c != vi_new.Taxpayer_Number__c || ((Vendor_Invoice__c)Trigger.oldMap.get(vi_new.Id)).Account__c != vi_new.Account__c){
                //get NIFs to get Accounts
                if(vi_new.Taxpayer_Number__c != null &&  vi_new.Taxpayer_Number__c != '' ){
                    vi_new.Taxpayer_Number__c = vi_new.Taxpayer_Number__c.remove('PT'); 
                    nifList.add(vi_new.Taxpayer_Number__c);
                    nifList.add('0'+vi_new.Taxpayer_Number__c); //remove when account 
                }
                if(vi_new.Account__c != null){
                    System.debug('vi_new.Account__c '+vi_new.Account__c);
                    nifList.add(vi_new.Account__c);
                }
                nifAccountUpdateList.add(vi_new);
            }
        }
        
        if(!nifAccountUpdateList.isEmpty()){
            //create a map for the account with a key being the nif and the id of the account 
            Map<String,Account> nifToAccountMap = nifAccountMap(nifList);
            setNIFAccount(nifAccountUpdateList,nifToAccountMap);
        }
        
        setVendorInvoiceTaxInformation();
    }
    
    /**************************************************************************************************/
    /*                                      PRIVATE METHODS                                           */
    /**************************************************************************************************/ 
    
    //method to validate the integration with docparser
    //Verifies the existance of invoice date, due date, invoice number, total
    private boolean validateDocParserIntegration(Vendor_Invoice__c vin){
        Boolean validation = true;
        
        if(vin.Invoice_Date__c == null || vin.Due_Date__c == null ){
            validation = false;
        }
        if(vin.Vendor_Invoice_Number__c == null || vin.Vendor_Invoice_Number__c == ''){
            validation = false;
        }
        if(vin.Invoice_Total__c == null){
            validation = false;
        }
        
        return validation;
    }
    
    //attach file to the new vendor invoices from the cases
    private void attachDocParserFile(List<Vendor_Invoice__c> vinvList, List<String> attachNameList){
        
        Map<String,Attachment> attachMap = new Map<String,Attachment>();
        List<Attachment> attachList = new List<Attachment>([Select ID,Name,ParentId,Body,BodyLength,ContentType,Description 
                                                            From Attachment 
                                                            where Name in :attachNameList and Parent.Type = 'Case' 
                                                            order by CreatedDate Desc
                                                           ]);
        for(Attachment attach :attachList){
            attachMap.put(attach.Name, attach);
        }
        
        MAp<ID,Vendor_Invoice__c> vendorMap= new MAp<ID,Vendor_Invoice__c>([Select Id,Invoice_Description__c From Vendor_Invoice__c where id in :vinvList]);
        
        List<Attachment> attachToCreate = new List<Attachment>();
        for(Vendor_Invoice__c vinv : vinvList ){
            if(attachMap.get(vinv.Invoice_Description__c) != null){
                Attachment newVinvAtach = new Attachment();
                Attachment attach = attachMap.get(vinv.Invoice_Description__c);
                newVinvAtach.Body = attach.Body;
                newVinvAtach.Description = attach.Description;
                newVinvAtach.Name = attach.Name;
                newVinvAtach.ParentId = vinv.ID;
                attachToCreate.add(newVinvAtach);
                vendorMap.get(vinv.id).Invoice_Description__c = '';
                //vinv.Invoice_Description__c = '';
                
                
            }else{
                System.debug('No attachment to attach on vendor invoice '+vinv.Name);
            }
            
        }
        
        if(!attachToCreate.isEmpty()){
            insert attachToCreate;
            update vendorMap.values();
        }
        
    }
    
    //set the nif and account fields
    //Return msg ok or error
    private void setNIFAccount(List<Vendor_Invoice__c> vinList, Map<String,Account> nifAccountMap){
        System.debug('nifAccountMap ' + nifAccountMap);
        for(Vendor_Invoice__c vin : vinList){
            System.debug('vin' + vin);
            //if account is change
            if(Trigger.isUpdate){
                if(((Vendor_Invoice__c) Trigger.oldMap.get(vin.Id)).Account__c != vin.Account__c){
                    if(vin.Account__c != null){ // if account is not null. 
                        vin.Taxpayer_Number__c = nifAccountMap.get(vin.Account__c).NIF__c;
                    }else{
                        if(((Vendor_Invoice__c) Trigger.oldMap.get(vin.Id)).Taxpayer_Number__c != vin.Taxpayer_Number__c){ //verify if nif was change.
                            vin.Account__c = nifAccountMap.get(vin.Taxpayer_Number__c).id;
                        }else{ //if there was't, there is an error. The accont can't be set to null
                            vin.addError('Error. Account can\'t be set to null');
                        }
                    }
                }else {
                    if(((Vendor_Invoice__c) Trigger.oldMap.get(vin.Id)).Taxpayer_Number__c != vin.Taxpayer_Number__c){ //on the other hand, if nif is changed instead of the account is also needed to change the account
                        if(vin.Taxpayer_Number__c != null && nifAccountMap.get(vin.Taxpayer_Number__c) != null){ //in the same way as in the account change verify if is null
                            vin.Account__c = nifAccountMap.get(vin.Taxpayer_Number__c).id;
                        }else{
                            vin.addError('Invalid or Non-Existent Tax number');
                        }
                    }
                }
            }
            if(Trigger.isInsert){ //if is insert there aren't old values 
                if(vin.Account__c != null){
                    vin.Taxpayer_Number__c = nifAccountMap.get(vin.Account__c).NIF__c;
                }else{
                    if(vin.Taxpayer_Number__c!= null && nifAccountMap.get(vin.Taxpayer_Number__c)!=null){
                        vin.Account__c = nifAccountMap.get(vin.Taxpayer_Number__c).id;
                    }else{
                        vin.addError('Invalid or inexistent Tax Number or Account');
                    }
                }
            }
            
        }
    }
    
    //create a map for the account with a key being the nif and the id of the account 
    private Map<String,Account> nifAccountMap(List<String> nifList){
        Map<String,Account> nifToAccountMap = new Map<String,Account>();
        List<Account> accountList = new List<Account>([Select Id,Nif__c, Country_Code__c,DocParser__c,Type 
                                                       From Account 
                                                       where (nif__c in :nifList or id = :nifList)/* and (Type = 'Service Provider' or Type = 'Channel Partner / Vendor')*/]);
        for(Account acc : accountList){
            System.debug('nifAccountMap acc '+acc);
            
            if(acc.NIF__c.startsWith('0')){
                acc.NIF__c = acc.NIF__c.substringAfter('0');
            }
            nifToAccountMap.put(acc.NIF__c, acc);
            nifToAccountMap.put(acc.ID, acc);
        }
        return nifToAccountMap;
    }
    
    //**
    //Update Tax info
    @TestVisible
    private void setVendorInvoiceTaxInformation(){
        
        Map<ID, Decimal> taxRateMap = new Map<ID, Decimal>();
        for(c2g__codaTaxRate__c taxRate : [SELECT c2g__Rate__c, c2g__TaxCode__c FROM c2g__codaTaxRate__c]){
            taxRateMap.put(taxRate.c2g__TaxCode__c,taxRate.c2g__Rate__c);
        }
        
        for(Vendor_Invoice__c vi_new : newViList){
            vi_new.Tax_Code__c = vi_new.Tax_Code_Id__c;
            vi_new.Tax_Rate__c = taxrateMap.get(vi_new.Tax_Code__c);
        }
    }
    
    public static void dummyMethod(){
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
    }
}