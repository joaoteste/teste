public abstract class ClientAppService {
    
    protected Map<String,Object> toReturn = new Map<String,Object>();
    
    public virtual Map<String,Object> execute(String sessionToken, Map<String,Object> args){
        SiteAuthentication auth = new SiteAuthentication();
        boolean valid = auth.validateSession(sessionToken);
        if(!valid){
            toReturn.put('errorCode', auth.getErrorMessage());
            return toReturn;
        }
        return toReturn;
    }
}