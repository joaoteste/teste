public class ClientAppService_Utils {
    
    public static List<Map<String,Object>> groupByRentingApp(List<Map<String,Object>> toGroup){
    	List<Map<String,Object>> grouped = new List<Map<String,Object>>();
    	
    	//get possible app names
    	Set<String> appNames = new Set<String>();
    	for(Map<String,Object> invMap : toGroup){
    		appNames.add((String)invMap.get('applicationNumber'));
    	}
    	
    	//group by app name
    	for(String appName : appNames){
    		for(Map<String,Object> invMap : toGroup){
    			if(invMap.get('applicationNumber') == appName){
    				grouped.add(invMap);
    			}
    		}
    	}
    	
    	return grouped;
    }
    
    public static List<Map<String,Object>> orderByDateField(List<Map<String,Object>> toOrder, String dateField){
    	List<Map<String,Object>> ordered = new List<Map<String,Object>>();
    	
    	//cant use map<Date,invoice> because we can have the same date twice. rely on the index to get invoice from date
    	List<Date> invoicesDates = new List<Date>();
    	List<Map<String,Object>> invoicesAux = new List<Map<String,Object>>();
    	for(Map<String,Object> inv : toOrder){
    		Date dueDate = (Date)inv.get(dateField);
    		String dateStr = dueDate.format();
    		Date auxDate = setStringToDateFormat(dateStr);
    		invoicesDates.add(auxDate);
    		invoicesAux.add(inv);
    	}
    	
    	Date beginDate = setStringToDateFormat('01-01-2017');
    	while(ordered.size() != toOrder.size()){
    		Date closest = getClosestAfterDate(invoicesDates, beginDate);
    		//salesforce doesnt have remove(Object) method, so we must find the index.....
    		for(Integer i = 0; i<invoicesDates.size(); i++){
    			if(invoicesDates.get(i) == closest){
    				//get corresponding invoice from date, then remove date and invoice from auxiliar lists
    				ordered.add(invoicesAux.get(i));
    				invoicesAux.remove(i);
    				invoicesDates.remove(i);
    				break;
    			}
    		}
    	}
    	
    	return ordered;
    }
    
    private static Date setStringToDateFormat(String myDate) {
    	String[] strDate = myDate.split('-');
    	Integer myIntDate = integer.valueOf(strDate[0]);
    	Integer myIntMonth = integer.valueOf(strDate[1]);
    	Integer myIntYear = integer.valueOf(strDate[2]);
    	Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
    	return d;
    }
    
    private static Date getClosestAfterDate(List<Date> dates, Date startDate){
        Integer days = 100000000;
        Date nearest = startDate;
        Integer count = 0;
        do{
            Date d = dates.get(count);
            if(d>startDate && days>startDate.daysBetween(d)){
                days = startDate.daysBetween(d);
                nearest = d;
            }
            count++;
        }while(count < dates.size());
        return nearest;
    }
    
}