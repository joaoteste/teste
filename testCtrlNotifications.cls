@isTest(SeeAllData=true)
public class testCtrlNotifications {
    
     public static testMethod  void TestNotifications()
    {
        String username='16Ocr888GzaUog9ZTuLq7Q==';
        String password='8fGJG40VRUolKtP7ZcA9CQ==';
        String userAgent='Mozilla/5.0 (Linux; Android 5.0; SM-G900F Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Crosswalk/15.44.384.13 Mobile Safari/537.36';
        String IdDevice = 'fLjmFpcBZiI:APA91bFjWKvCoWu40NotJoGylN4KLLyXgmXvV_gif7qbGL_ZP7xX0_OuWROKq4oL822W4vq5ayVubOaHW7ICeWwM4Dpk55p0kg6RWkA_JnOO-WuRCSar3zrHPvOxDJIQMzZuCh-NYRzP';
        String TypeDevice = 'Android';
        Notification__c[] lstNotifications;
        Login__c login = new Login__c();
        
        test.startTest();
        lstNotifications=CtrlNotifications.getNotifications('a0524000007IvSKAA0');
       // lstNotifications=CtrlNotifications.getNotifications('a0524000006xzWrAAI');
        login=CtrlNotifications.authenticationAuto(username, password, userAgent, IdDevice, TypeDevice);
        login=CtrlNotifications.authenticationAuto(username, password, userAgent, IdDevice + 'a', TypeDevice);
        //lstNotifications=CtrlNotifications.getNotifications('a0524000004ZCzeAAG');
        CtrlNotifications.getNotificationsWithSearchs('0012400000EV33vAAD', 'a0524000007IvSKAA0', 'Socie');
      //  CtrlNotifications.getNotificationsWithSearchs('0012400000EV33vAAD', 'a0524000006xzWrAAI', 'Socie'); 
        
        test.stopTest();
        system.assertEquals(1, 1, 'ERRO: Não são iguais');
    }
    
    public static testMethod  void TestNotification()
    {
        String username='16Ocr888GzaUog9ZTuLq7Q==';
        String password='8fGJG40VRUolKtP7ZcA9CQ==';
        String userAgent='Mozilla/5.0 (Linux; Android 5.0; SM-G900F Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Crosswalk/15.44.384.13 Mobile Safari/537.36';
        String IdDevice = 'fLjmFpcBZiI:APA91bFjWKvCoWu40NotJoGylN4KLLyXgmXvV_gif7qbGL_ZP7xX0_OuWROKq4oL822W4vq5ayVubOaHW7ICeWwM4Dpk55p0kg6RWkA_JnOO-WuRCSar3zrHPvOxDJIQMzZuCh-NYRzP';
        String TypeDevice = 'Android';  
        Notification__c lstNotifications;
        Login__c login = new Login__c();
        
        test.startTest();
        lstNotifications=ctrlNotification.getNotification('a0R24000000UgZWEA0');
        ctrlNotification.changeStatusToRead('a0R24000000UgZWEA0');
        login=CtrlNotification.authenticationAuto(username, password, UserAgent, IdDevice, typeDevice);
        login=CtrlNotification.authenticationAuto(username, password, UserAgent, IdDevice+'a', typeDevice);
        test.stopTest();
        system.assertEquals(1, 1, 'ERRO: Não são iguais');
    }
}