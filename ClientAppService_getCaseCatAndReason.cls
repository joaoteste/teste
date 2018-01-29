public class ClientAppService_getCaseCatAndReason extends ClientAppService {
    
   public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){  
    	//super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }

        Map<String, List<String>> typeToCategory = Utils_DependentPicklist.getFieldDependencies('Case', 'Type', 'Category__c');
		Map<String, List<String>> categoryToReason = Utils_DependentPicklist.getFieldDependencies('Case', 'Category__c', 'Reason__c');
        Map<String, List<String>> clientCategoryAndReason = new Map<String, List<String>>();
       
        //System.debug(typeToCategory);
        //System.debug(clientCategoryAndReason);
       
        List<String> reasons = new List<String>();
        for(String category: typeToCategory.get('Cliente')){
            //System.debug(category);
            reasons = categoryToReason.get(category);
            //System.debug(reasons);
            clientCategoryAndReason.put(category, reasons);
        }

        ClientApp_Response response = new ClientApp_Response(ClientApp_Response.status.SUCCESS);
        //System.debug(clientCategoryAndReason);
        toReturn.put('categoryAndReason', clientCategoryAndReason);
        return toReturn;
        
   }
}