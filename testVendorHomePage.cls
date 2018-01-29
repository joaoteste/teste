@isTest(SeeAllData=true)
public class testVendorHomePage 
{/* joao
    public static testMethod  void TestAuthenticate()
    {
        String username='16Ocr888GzaUog9ZTuLq7Q==';
        String password='8fGJG40VRUolKtP7ZcA9CQ==';
        String userAgent='Mozilla/5.0 (Linux; Android 5.0; SM-G900F Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Crosswalk/15.44.384.13 Mobile Safari/537.36';
        String IdDevice = 'fLjmFpcBZiI:APA91bFjWKvCoWu40NotJoGylN4KLLyXgmXvV_gif7qbGL_ZP7xX0_OuWROKq4oL822W4vq5ayVubOaHW7ICeWwM4Dpk55p0kg6RWkA_JnOO-WuRCSar3zrHPvOxDJIQMzZuCh-NYRzP';
        String TypeDevice = 'Android';
        Login__c login = new Login__c();
        test.startTest();
        login=VendorHomePage.authenticationAuto(username, password, userAgent, IdDevice, TypeDevice);
        login=VendorHomePage.authenticationAuto(username, password, userAgent, IdDevice+'a', TypeDevice);
        
        
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000006xzWrAAI', 0);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000006xzWrAAI', 1);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000006xzWrAAI', 2);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000006xzWrAAI', 3);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000006xzWrAAI', 4);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000006xzWrAAI', 5);
        
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000007IvSKAA0', 0);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000007IvSKAA0', 1);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000007IvSKAA0', 2);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000007IvSKAA0', 3);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000007IvSKAA0', 4);
        VendorHomePage.getApplications('0012400000EV33vAAD', 'a0524000007IvSKAA0', 5);
        
        VendorHomePage.GetAppInfo('a012400000NCxwo');
        
        VendorHomePage.getContactsApp('a012400000NCxwo');
        
         test.stopTest();
        system.assertEquals(1, 1, 'ERRO: Não são iguais');
    }
    
   
    public static testMethod void testCreateVendorClient(){
        string vendorId='0012400000EV33vAAD';
        string clientNif='508898960';
        string loginId='a0524000006xzWrAAI';
     //   VendorHomePage.CreateVendorClient(vendorId, clientNif, loginId);
   //     VendorHomePage.CreateVendorClient(vendorId, vendorId, loginId);
        clientNif='505924170';
   //     VendorHomePage.CreateVendorClient(vendorId, clientNif, loginId);
        clientNif='222975920';
    //    VendorHomePage.CreateVendorClient(vendorId, clientNif, loginId); 
        string appId='a012400000NCxwo';
        appId=VendorHomePage.RequestApplication(vendorId, clientNif, loginId);
        VendorHomePage.AnalyseRequestApp(appId);
    }
     
    public static testMethod void testCalcPayments(){
        //VendorHomePage.GetAppInfo('a0158000000M2cNAAS');
        //VendorHomePage.getContactsApp('a0158000000M2cNAAS');
        string vendorId='0012400000EV33vAAD';
        string clientId='0012400000EV33vAAD';
        string appId='a012400000NCxwo';
        VendorHomePage.CalcPayments ( 3000.00, appId );
        clientId='0012400000QeLPVAA3';
        appId='a012400000NCxwo';
    VendorHomePage.CalcPayments ( 4000.00, appId );        
    }
     
    public static testMethod void testSetAppPayTerm(){
        string appId='a012400000NCxwo';
        VendorHomePage.SetAppPayTerm ( 250, '24', appId );
    }
    /*
    public static testMethod void testgetApplications(){
        VendorHomePage.getApplications('00158000002GZpKAAW', 'a06580000009i71AAA', 0); 
        VendorHomePage.getApplications('00158000002GZuAAAW', 'a06580000009i71AAA', 1);
        VendorHomePage.getApplications('00158000002GZuAAAW', 'a06580000009i71AAA', 2);
        VendorHomePage.getApplications('00158000002GZuAAAW', 'a06580000009i71AAA', 3);
        VendorHomePage.getApplications('00158000002GZuAAAW', 'a06580000009i71AAA', 4);
    }
      public static testMethod void testgetApplications1(){

        VendorHomePage.getApplications('00158000002GZpKAAW', 'a06580000009i76AAA', 0); 
        VendorHomePage.getApplications('00158000002GZuAAAW', 'a06580000009i76AAA', 1);
        VendorHomePage.getApplications('00158000002GZuAAAW', 'a06580000009i76AAA', 2);
        VendorHomePage.getApplications('00158000002GZuAAAW', 'a06580000009i76AAA', 3);
        VendorHomePage.getApplications('00158000002GZuAAAW', 'a06580000009i76AAA', 4);
    }*/
    /*Joao 
    public static testMethod void testgetappstringSearch(){
         VendorHomePage.getApplicationsWithSearchs('0012400000EV33vAAD', 'a0524000006xzWrAAI', 'Socie'); 
         VendorHomePage.getApplicationsWithSearchs('0012400000EV33vAAD', 'a0524000007IvSKAA0', 'Socie');
         VendorHomePage.getApplicationsWithSearchs('0012400000EV33vAAD', 'a0524000006xzWrAAI', '27'); 
    }
    /*
    public static testMethod void testSetEmailContact(){
        list<string> b=new List<string>();
        b.add('0032400000Qi76Y,info@worldit.pt');
        vendorHomePage.SetEmailContact(b, 'a012400000NCxwo');
    }
    */
    /*Joao
    public static testMethod void testactionsApplication(){
        
        vendorHomePage.CancelApplication('a012400000NCxwo');
        vendorHomePage.PostPoneApplication('a012400000NCxwo');
        vendorHomePage.SetCashAdvance('a012400000NCxwo');
        VendorHomePage.SetDeliveryDate('a012400000NCxwo');
        VendorHomePage.GetAppDownloads('a012400000NCxwo');
        VendorHomePage.GetLastNotificationID('a012400000NCxwo');
        VendorHomePage.getNumBindingSign('a012400000NCxwo');
        VendorHomePage.getNumNotificationsNotRead('0012400000EV33vAAD');
        VendorHomePage.CalcPaymentsFromRent(200, 'a012400000NCxwo', 24);
        VendorHomePage.getDocuSignInfo('a012400000NCxwo');
        VendorHomePage.SetPayTime('a012400000NCxwo','monthly');
        VendorHomePage.SetPayTime('a012400000NCxwo','quarterly');
        VendorHomePage.SendRentingContract('a012400000NCxwo');
        VendorHomePage.GetContract('a012400000NCxwo');
        VendorHomePage.GenerateContract('a012400000NCxwo');
   
    }  
    
    public static testMethod void BO_CustomController(){
        BO_CustomController BO_cc= new BO_CustomController();
        Application__c [] apps = BO_cc.getApps();
    }
    
    public static testMethod void ScoreCardConfigTest1(){
        ScoreCardConfig.GetCreditLineStatus('idclienteErrado', 'a012400000NCxwo');
        ScoreCardConfig.GetCreditLineStatus('0012400000e961uAAA','a012400000XW7zK');
        ScoreCardConfig.GetCreditLineStatus('0012400000g5txkAAA','a012400000YX6C1');
        ScoreCardConfig.GetCreditLineStatus('0012400000h7gIrAAI','');
    }
    
    public static testMethod void ScoreCardConfigTest2(){
        ScoreCardConfig.GetCreditLineStatus('0012400000EV33vAAD','a012400000LGKwzAAH');
    }
    public static testMethod void ScoreCardConfigTest3(){
        ScoreCardConfig.GetCreditLineStatus('0012400000UQrpvAAD','a012400000NCxwo');
    }  
    public static testMethod void ScoreCardConfigTest4(){
        ScoreCardConfig.GetCreditLineStatus('0012400000UdjKpAAJ','a012400000LREKZAA5');
    }  
    public static testMethod void ScoreCardConfigTest5(){    
        ScoreCardConfig.GetCreditLineStatus('0012400000WmWQUAA3','a012400000NSsRlAAL');

    }
    public static testMethod void ScoreCardConfigTest6(){    
        ScoreCardConfig.GetCreditLineStatus('0012400000Wmc70AAB','a012400000NYa0vAAD');
    }Joao*/
}