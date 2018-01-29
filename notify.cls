global class notify 
{

  @Future(callout=true)
  global Static void SendNotification(ID idNotification)
  {
    try
    {
      //ainda nao está certo. So manda a ultima notificação esobrepoe as outras
       // system.debug('Passo 1 - recebemos o Id Notification: '+ idNotification);
       Notification__c newNotification = [select Id, Message__c, IdLogin__c, Appclientname__c, AppName__c from Notification__c where Id =: idNotification];
       // system.debug(newNotification);
       // //ALTERACAO - 13/03/17 - validacao do login activo, anteriormente enviava mm não estando inactivo (BP)
       List<Login__c> notifyLoginList = [select Id , email__c
       from Login__c 
       where  (IdVendor__c=:[select IdVendor__c 
       from Login__c 
       where Username__c =: newNotification.IdLogin__c AND Inactive__c!=true].IdVendor__c 
       and Master__c=true) or  Username__c =: newNotification.IdLogin__c];
       // system.debug('NotifyLoginList: '+notifyLoginList);
       List<Session__c> lstSessions = [select Id, IdDevice__c, TypeDevice__c
       from Session__c
       where Login__c IN :notifyLoginList
       and IdDevice__c != null
       and TypeDevice__c != null
       ];
            //System.debug('Sessions: '+lstSessions);
            Set<Session__c> lstSessionsFINAL = New Set<Session__c>();


            Set<String> ids = New Set<String>();
            for (session__c c: lstSessions){
              if (ids.Contains(c.IdDevice__c) == FALSE){
                ids.add(c.IdDevice__c );
                lstSessionsFINAL.add(c);
              }
            }
            System.debug('lstSessionsFINAL: '+lstSessionsFINAL);

            //pedido para o token
       // system.debug('Passo - 2');
       HttpRequest reqToken = new HttpRequest();
     //   system.debug('Passo - 2.A');
     reqToken.setEndpoint('http://serviceevent.azurewebsites.net/token');
     //   system.debug('Passo - 2.B');
     reqToken.setMethod('POST');
     //   system.debug('Passo - 2.C');
     reqToken.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      //  system.debug('Passo - 2.D');
      reqToken.setBody('grant_type=password&username=CandorUser&password=Candor2015#');
     //   system.debug('Passo - 2.E');
     Http http = new Http();
   //     system.debug('Passo - 2.F');
   HTTPResponse resToken = new HTTPResponse();
   if(!test.isRunningTest())
   {
     resToken = http.send(reqToken); 
   }

//        system.debug('Passo - 2.G');
      //  system.debug(resToken);
     //   system.debug('Passo - 2.H');
     //   system.debug(resToken.getBody());

        //tratamento da string strResToken para obtermos o token
        String strResToken = '';
        if(!test.isRunningTest())
        {
         strResToken = resToken.getBody();
       }
       else
       {
        strResToken='"access_token":"Pbqo7-uqXRsy7es-uPNvgHOGVFQTWTYDUBRFixSNJryGSCaYJKXNq1gNUzwmqJdIfuWmxr_145WDnnXN5J2u6yo-L_oebv1bgMU139LcgSF4xJYk6hwezgNa05AhqxP6Wi7gSE0d6NSmsy0fx7JMmCtKXQuCda6zBixxNQYhzm13KGY-lVwi0xhJtafUstKSsf7Ja7PZ51liEYWTNtfq6ZhjDQxcKyk5F6TvNJS0mYG8NTUWQBR7UMdd9IAHWIUbeTOPWZLilbULUNKZieofsCOaRQQPYPzIgBjVPVgXcFbfKAKNpz9WVAy3I1_eryGYPveWKEM4dub7buputbrG8P2A_hCD_mHQmjRkuzB_6ulra7sBaIs0DjD71BsCA8zZP5OsiLqizhxpPRxOJ_6n3vokQ3_M74DHthXo6L5eY_A","token_type":"bearer","expires_in":7199,"userName":"CandorUser",".issued":"Thu, 19 Nov 2015 12:13:02 GMT",".expires":"Thu, 19 Nov 2015 14:13:02 GMT"';
      }

      strResToken = strResToken.replace('","', '"#"');
      List<String> lststrResToken = strResToken.split('#');
      //  system.debug(lststrResToken);
      string token = lststrResToken[0];
      token = token.replace('"', '');
      //  system.debug(token);
      List<String> lsttmp = token.split(':');
      token=lsttmp.get(1);
       // system.debug(token);

        //pedir o envio das notificações
        system.debug('Passo - 3');
        HttpRequest reqNotify = new HttpRequest();
        Integer timeout_x=20000;
        reqNotify.setTimeout(timeout_x);
        HTTPResponse resNotify = new HTTPResponse(); 
        String msg = newNotification.Message__c;
        String title = '';
        String tmp = newNotification.Appclientname__c;
        if(tmp.Length()>12)
        {
        	title = newNotification.AppClientName__c.substring(0,11) + ' - ' + newNotification.AppName__c;
        }
        else
        {
        	title = newNotification.AppClientName__c + ' - ' + newNotification.AppName__c;
        }
        title=title.replace(' ', '%20');
        system.debug(msg);
        msg=msg.replace(' ', '%20');
        system.debug(msg);
        if(!test.isRunningTest())
        {
          for (Session__c i : lstSessionsFINAL)
          {
            system.debug(i);
            reqNotify.setEndpoint('http://serviceevent.azurewebsites.net/api/Notifications/SendNotification?EventId=2044&IdDevice='+i.IdDevice__c+'&DeviceType='+i.TypeDevice__c+'&Title='+title+'&Msg='+msg+'&Production=true&idNotification='+idNotification);
            reqNotify.setBody('grant_type=password&username=CandorUser&password=Candor2015#');
            reqNotify.setMethod('POST');
            reqNotify.setHeader('Authorization', 'Bearer ' + token);
            resNotify = http.send(reqNotify);            

            system.debug(reqNotify);
            system.debug(resNotify.getBody());
          }
        }

      //SendDecisionEmails(idNotification);
      }
      catch (QueryException e)
      {

      }

    }
  }