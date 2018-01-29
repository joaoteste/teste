public class UTIL_NextPeriod {
    
    public static c2g__codaPeriod__c getNextnPeriod(id period, integer n){
        List<c2g__codaPeriod__c> lstPeriod=new List<c2g__codaPeriod__c>([Select name, id, c2g__StartDate__c, c2g__EndDate__c from c2g__codaPeriod__c where c2g__Description__c='Trading Period'] );
        c2g__codaPeriod__c nextperiod=new c2g__codaPeriod__c();
        date newPeriodStartDate=null;
        date newPeriodEndDate=null;  
        for (integer l=0; l< lstPeriod.size(); l++){
            if(period==lstPeriod[l].id){
                newPeriodStartDate=(lstPeriod[l].c2g__StartDate__c).addMonths(n);
                newPeriodEndDate=(lstPeriod[l].c2g__EndDate__c).addMonths(n) ;
                //make sure End Date is End of Month to find new period
                newPeriodEndDate=date.newInstance(newPeriodEndDate.year(),
                                                  newPeriodEndDate.month(),
                                                  date.daysInMonth(newPeriodEndDate.year(), newPeriodEndDate.month()));
            }
        }


        for (integer l=0; l< lstPeriod.size(); l++){
            if(newPeriodStartDate!=null && newPeriodEndDate!=null){
                if(lstPeriod[l].c2g__StartDate__c==newPeriodStartDate && lstPeriod[l].c2g__EndDate__c==newPeriodEndDate ){
                    nextperiod=lstPeriod[l];
                }
            }
        }

        return nextperiod;
    }
}