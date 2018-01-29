public with sharing class CtrlNotifications {
    
    @RemoteAction
    public static Notification__c[] getNotifications(String IdLogin)
    {
        Notification__c[] lstNotifications;
        Application__c[] aplicacoes;
        
        Login__c l = new Login__c();
        system.debug('Lista Notificações - Passo 1');
        try
        {
            l =[select Master__c, Vendor_NIF__c, Username__c from login__c where Id=:IdLogin];
            system.debug('Lista Notificações - Passo 2');
            system.debug(l);
            if (l.Master__c)
            {
                system.debug('Lista Notificações - Passo 2.A');
                lstNotifications=[select AppClientName__c, AppName__c, Message__c, CreatedDate, read__c
                                  from Notification__c
                                  where VendorNIF__c=:l.Vendor_NIF__c
                                  order by CreatedDate desc LIMIT 5];
                system.debug('Lista Notificações - Passo 2.A.A');
            }
            else
            {
                system.debug('Lista Notificações - Passo 2.B');
                lstNotifications=[select AppClientName__c, AppName__c, Message__c, CreatedDate, read__c
                                  from Notification__c
                                  where VendorNIF__c=:l.Vendor_NIF__c and IdLogin__c=:l.Username__c
                                  order by CreatedDate desc LIMIT 5];
                system.debug('Lista Notificações - Passo 2.B.A'); 
            }   
            
            //Marcar as mensagem lidas
            markAsRead(l);
            return lstNotifications;
                
        }
        catch (QueryException e)
        {
            return lstNotifications;
            
        }
    }
         
    private static void markAsRead(Login__c l){
       
        List<Notification__c> lstRead = new List<Notification__c>();   
        List<Notification__c> lstUnread = new List<Notification__c>(); 
        
        try{
            if (l.Master__c){
                lstUnread=[SELECT read__c
                           FROM Notification__c
                           WHERE VendorNIF__c=:l.Vendor_NIF__c AND read__c=false];
            }else{
                lstUnread=[SELECT read__c
                           FROM Notification__c
                           WHERE VendorNIF__c=:l.Vendor_NIF__c AND IdLogin__c=:l.Username__c AND read__c=false];
            }
            
            system.debug('Notifications unread: ' + lstUnread.size()); 
            
            if(lstUnread.size()>0){
                for(Notification__c notif : lstUnread){
                    notif.read__c = true;
                    lstRead.add(notif);	
                }                
                update lstRead;
            }
        }
        catch (QueryException e){
            system.Debug('CtrlNotifications' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );   
        }
    }
        
    @RemoteAction
    public static Notification__c[] getNotificationsWithSearchs(String IdVendor, String IdLogin, String search)
    {
        Notification__c[] notifications;
        search = '%'+search+'%';
        Login__c l = new Login__c();
        Account vendor = new Account();
        
        try
        {
            vendor=[select id, nif__c, name from account where id=:IdVendor];
            l = [select Master__C from login__c where id=:IdLogin];
            if(l.Master__c)
            {
                notifications = [select Id, Application__C, AppName__c, AppClientName__c, Message__c, CreatedDate
                                 from notification__c
                                 where vendorNIF__c =:vendor.nif__c and AppClientName__c like: search];
            }
            else
            {
                notifications = [select Id, Application__C, AppName__c, AppClientName__c, Message__c, CreatedDate
                                 from notification__c
                                 where vendorNIF__c =:vendor.nif__c and IdLogin__c =: IdLogin and AppClientName__c like: search];
            }
        }
        catch(QueryException e)
        {
            //se é apanhada esta exception retornamos uma lista de notificações vazias.
            return notifications; 
        }
        return notifications;
    }   
    
    @RemoteAction
    public static Login__c authenticationAuto(String username, String password, String userAgent, String IdDevice, String TypeDevice)
    {
        Login__c newlogin = new Login__c();
        
        newlogin = Authenticate.authenticationAuto(username, password, userAgent, IdDevice, TypeDevice);
        
        return newlogin;
    }
}