public  class UTIL_CashMatch {
    public UTIL_CashMatch() {
        
    }

    public void doInvoiceCapitalMatch( application__c app){
        try{
            //find TRS for beginning post and capital journals and doMatch with End of Contract TRS 
            List<c2g__codaTransactionLineItem__c> TRNCshEntry=[select c2g__AccountValue__c, name, c2g__Transaction__r.c2g__Journal__r.c2g__Reference__c , c2g__Transaction__r.c2g__Period__r.id from c2g__codaTransactionLineItem__c where c2g__LineType__c='Account' And c2g__MatchingStatus__c='Available' 
                                                                And c2g__Transaction__c in (select c2g__Transaction__c from c2g__codaJournal__c 
                                                    where c2g__JournalStatus__c ='Complete' and c2g__CanceledJournal__c =false and application__c =: app.id And (
                                                          c2g__Reference__c= :app.name or c2g__JournalDescription__c like 'Invoice Capital %'  ))];
    
            Map<c2g__codaTransactionLineItem__c, double> MapTrsLItems= New Map<c2g__codaTransactionLineItem__c, double>();
            c2g__codaTransactionLineItem__c begTrsLineItem = New c2g__codaTransactionLineItem__c();
            double sumVal=0.0;
            id period=null;

            for(c2g__codaTransactionLineItem__c trsLineItem :TRNCshEntry){
                if(trsLineItem.c2g__Transaction__r.c2g__Journal__r.c2g__Reference__c != app.Name){
                        MapTrsLItems.put(trsLineItem, (double) trsLineItem.c2g__AccountValue__c);
                        sumVal=sumVal + (double) trsLineItem.c2g__AccountValue__c;
                        period=trsLineItem.c2g__Transaction__r.c2g__Period__r.id;

                }
                else{
                    
                    begTrsLineItem=trsLineItem;
                }

            }
            
            id matchref=null;

            if (MapTrsLItems.size()==0){
                string[] address=new string[]{'info@candor.pt'}; // change to info@candor.pt
                Utilities.SendEmail(address, 'The Invoice Capital CashMatching was not possible for the following Contract: ' + app.name +'. No transactions were found.', 'Invoice Capital Partial CashMatch Error');
                return;
            } else {
                MapTrsLItems.put(begTrsLineItem, -1 * sumVal);
                matchref=FF_Utils.doMatchWithPartial(app.AccClient__c, period, MapTrsLItems );
            
            } 
            
            
            if (matchref==null){
                string[] address=new string[]{'info@candor.pt'}; // change to info@candor.pt
                Utilities.SendEmail(address, 'The Invoice Capital CashMatching was not possible for the following Contract: ' + app.name, 'Invoice Capital Partial CashMatch Error');
                return;
            }
    
        }
        catch(exception e){
            
            Outbound_Integration_Log__c record = new Outbound_Integration_Log__c(Start__c=system.today(), Code__c = 'CRITICAL',
            ApplicationID__c = 'UTIL_CashMatch doInvoiceCapitalMatch', message__c = e.getMessage(), printStackTrace__c = e.getStackTraceString());
            insert record;
            
        }
    }       
}