//TODO
//This class should be refactored soon and the comented methods should be refactoredshould be changed
//
public class FF_Utils {
    
    //method used to create a match between transactions
    public static Id doMatch(Id accountId, Id periodDueDate, List<c2g__codaTransactionLineItem__c> transactionLinesToMatch ){
        system.debug(LoggingLevel.INFO, 'doMatch');
  
        // Match Invoice with Cash Entry
        c2g.CODAAPICommon_7_0.Context context = new c2g.CODAAPICommon_7_0.Context();
        c2g.CODAAPICashMatchingTypes_7_0.Configuration configuration = new c2g.CODAAPICashMatchingTypes_7_0.Configuration();
        system.debug(LoggingLevel.INFO, 'c2g.CODAAPICommon.getRef sepaRec.Debtor_Account__c: ' + accountId);
        configuration.Account = c2g.CODAAPICommon.getRef(accountId, null);
                                  
        system.debug(LoggingLevel.INFO, 'configuration.Account: ' + configuration.Account);
        configuration.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_7_0.enumMatchingCurrencyMode.Account;
        configuration.MatchingDate = System.today();

        system.debug(LoggingLevel.INFO, 'period: ' + period.Id);
        configuration.MatchingPeriod = c2g.CODAAPICommon.getRef(periodDueDate, null);
                 
        system.debug(LoggingLevel.INFO, 'configuration.MatchingPeriod: ' + configuration.MatchingPeriod);
        List<c2g.CODAAPICashMatchingTypes_7_0.Item> items = new List<c2g.CODAAPICashMatchingTypes_7_0.Item>();
        for (c2g__codaTransactionLineItem__c transactionLine : transactionLinesToMatch) {
            c2g.CODAAPICashMatchingTypes_7_0.Item item = new c2g.CODAAPICashMatchingTypes_7_0.Item();
            item.TransactionLineItem = c2g.CODAAPICommon.getRef(transactionLine.Id, null);
            item.Paid = transactionLine.c2g__AccountValue__c;
            item.Discount = 0; // No discount
            item.WriteOff = 0;  // No write off
            system.debug(LoggingLevel.INFO, 'c2g.CODAAPICashMatchingTypes_7_0.Item added: ' + item + ' transactionLine.Id:' + transactionLine.Id + ' transactionLine.c2g__AccountValue__c:' + transactionLine.c2g__AccountValue__c);
                
            items.add(item);
        }
        system.debug(LoggingLevel.INFO, 'List<c2g.CODAAPICashMatchingTypes_7_0.Item> items.size()' + items.size());
                
        c2g.CODAAPICashMatchingTypes_7_0.Analysis analisysInfo = new c2g.CODAAPICashMatchingTypes_7_0.Analysis();
                
        system.debug(LoggingLevel.INFO, 'analisysInfo: ' + analisysInfo);
                            
        c2g.CODAAPICommon.Reference matchReference = c2g.CODAAPICashMatching_7_0.Match(context, configuration, items, analisysInfo);
                
        system.debug(LoggingLevel.INFO, 'matchReference: ' + matchReference);
        
        //Retorno: matchReference: Reference:[Id=a369E0000008XiZQAU, Name=null]
        return matchReference.Id;
    }
    
 //method used to create a match between transactions
    public static Id doMatchWithPartial(Id accountId, Id periodDueDate, Map<c2g__codaTransactionLineItem__c, Double> transactionLinesToMatch ){
        system.debug(LoggingLevel.INFO, 'doMatch');
  
        // Match Invoice with Cash Entry
        c2g.CODAAPICommon_7_0.Context context = new c2g.CODAAPICommon_7_0.Context();
        c2g.CODAAPICashMatchingTypes_7_0.Configuration configuration = new c2g.CODAAPICashMatchingTypes_7_0.Configuration();
        system.debug(LoggingLevel.INFO, 'c2g.CODAAPICommon.getRef sepaRec.Debtor_Account__c: ' + accountId);
        configuration.Account = c2g.CODAAPICommon.getRef(accountId, null);
                                  
        system.debug(LoggingLevel.INFO, 'configuration.Account: ' + configuration.Account);
        configuration.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_7_0.enumMatchingCurrencyMode.Account;
        configuration.MatchingDate = System.today(); 

        system.debug(LoggingLevel.INFO, 'period: ' + period.Id);
        configuration.MatchingPeriod = c2g.CODAAPICommon.getRef(periodDueDate, null);
                
        system.debug(LoggingLevel.INFO, 'configuration.MatchingPeriod: ' + configuration.MatchingPeriod);
        List<c2g.CODAAPICashMatchingTypes_7_0.Item> items = new List<c2g.CODAAPICashMatchingTypes_7_0.Item>();
        for (c2g__codaTransactionLineItem__c trans : transactionLinesToMatch.keySet()) {
            c2g.CODAAPICashMatchingTypes_7_0.Item item = new c2g.CODAAPICashMatchingTypes_7_0.Item();
            item.TransactionLineItem = c2g.CODAAPICommon.getRef(trans.ID, null);
            item.Discount = 0; // No discount
            item.WriteOff = 0; //No Write Off
            item.Paid = transactionLinesToMatch.get(trans);  // No write off
			
            system.debug(LoggingLevel.INFO, 'c2g.CODAAPICashMatchingTypes_7_0.Item added: ' + item + ' transactionLine.Id:' + trans.Id + ' transactionLine.c2g__AccountValue__c:' + trans.c2g__AccountValue__c + ' and paid '+ transactionLinesToMatch.get(trans));
                
            items.add(item);
        }
        system.debug(LoggingLevel.INFO, 'List<c2g.CODAAPICashMatchingTypes_7_0.Item> items.size()' + items.size());
                
        c2g.CODAAPICashMatchingTypes_7_0.Analysis analisysInfo = new c2g.CODAAPICashMatchingTypes_7_0.Analysis();
                
        system.debug(LoggingLevel.INFO, 'analisysInfo: ' + analisysInfo);
        system.debug(items);                    
        c2g.CODAAPICommon.Reference matchReference = c2g.CODAAPICashMatching_7_0.Match(context, configuration, items, analisysInfo);
                
        system.debug(LoggingLevel.INFO, 'matchReference: ' + matchReference);
        
        //Retorno: matchReference: Reference:[Id=a369E0000008XiZQAU, Name=null]
        return matchReference.Id;
    }    
    
    //method to do unmatch between transactions matched
    public static Id undoMatch(Id accountId, Id matchReferenceId, c2g__codaPeriod__c periodDueDate){
        system.debug('undoMatch');
        
        system.debug(LoggingLevel.INFO, 'accountId: ' + accountId);
        system.debug(LoggingLevel.INFO, 'matchReferenceId: ' + matchReferenceId);
        system.debug(LoggingLevel.INFO, 'periodDueDate: ' + periodDueDate);
        
        //Context
        c2g.CODAAPICommon_7_0.Context context = new c2g.CODAAPICommon_7_0.Context();
        
        // Configuration
        c2g.CODAAPICashMatchingTypes_7_0.Configuration configuration = new c2g.CODAAPICashMatchingTypes_7_0.Configuration();
        system.debug(LoggingLevel.INFO, 'c2g.CODAAPICommon.getRef sepaRec.Debtor_Account__c: ' + accountId);
        configuration.Account = c2g.CODAAPICommon.getRef(accountId, null);
                                  
        system.debug(LoggingLevel.INFO, 'configuration.Account: ' + configuration.Account);
        configuration.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_7_0.enumMatchingCurrencyMode.Account;
        configuration.MatchingDate = System.today();

        // MatchingPeriod
        configuration.MatchingPeriod = c2g.CODAAPICommon.getRef(periodDueDate.id, null);     
        system.debug(LoggingLevel.INFO, 'configuration.MatchingPeriod: ' + configuration.MatchingPeriod);
     
        // matchingReference  Reference
        c2g.CODAAPICommon.Reference matchReference = c2g.CODAAPICommon.getRef(matchReferenceId, null);

        c2g.CODAAPICommon.Reference unMatchReference = c2g.CODAAPICashMatching_7_0.Unmatch(context, configuration, matchReference, c2g.CODAAPICashMatchingTypes_7_0.enumUndoReason.RemittanceAdviceIncorrect);
                
        system.debug(LoggingLevel.INFO, 'UnMatchReference: ' + unMatchReference);
        
        return unMatchReference.ID;
    }
    
    // TODO to delete. only used for tests
    /*public static void testUnMatch(){
        Id accountId = '0012400000jHCgy';
        Id matchReferenceId = 'a369E0000008XjD';
        //String invoiceNumber = sepaRecListProcessed.get(0).Invoice_Number__c;
        String invoiceNumber = 'test/6';

        //undoMatch(accountId, matchReferenceId, invoiceNumber);
    }*/
    
    
}