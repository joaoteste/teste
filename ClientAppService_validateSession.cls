public class ClientAppService_validateSession extends ClientAppService{
	
    public override Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        super.execute(sessionToken, args);
        //if has map.entry is because there was an error
        if(toReturn.size() > 0){
            return toReturn;
        }
      
        return toReturn;
    }
    
}