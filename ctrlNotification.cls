public with sharing class ctrlNotification {
    
    @RemoteAction
    public static Notification__c getNotification(String idNotification)
    {
        Notification__c notif = [select Message__c, AppName__c, AppClientName__c, CreatedDate, Application__r.Status__c, Application__c, Read__c from Notification__c where Id=:idNotification];
        return notif;
    }
    
    @RemoteAction
    public static void changeStatusToRead( String idNotification)
    {
    	Notification__c notif = [select read__c from Notification__c where Id=:idNotification];
    	notif.read__c = true;
    	update notif;
    }
    
    @RemoteAction
    public static Login__c authenticationAuto(String username, String password, String userAgent, String IdDevice, String TypeDevice)
    {
        Login__c newlogin = new Login__c();
        
        newlogin = Authenticate.authenticationAuto(username, password, userAgent, IdDevice, TypeDevice);
        
        return newlogin;
    }
}