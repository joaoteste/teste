@isTest(SeeAllData=true)
public class UtilitiesTest {
    
    public static testMethod void testtranslate(){
        decimal num=translateInfo.GetFormaObrigarVal('uma assinatura');
        num=translateInfo.GetFormaObrigarVal('duas assinatura');
        num =translateInfo.GetFormaObrigarVal('um único gestor');
        num =translateInfo.GetFormaObrigarVal('um unico gestor');
        num =translateInfo.GetFormaObrigarVal('um única gestora');
        num =translateInfo.GetFormaObrigarVal('um unica gestora');
        num =translateInfo.GetFormaObrigarVal('pela assinatura');
        num =translateInfo.GetFormaObrigarVal('três gestores');
        num =translateInfo.GetFormaObrigarVal('dois gestores');
        num =translateInfo.GetFormaObrigarVal('quatro gestores');
        num =translateInfo.GetFormaObrigarVal('cinco gestores');
        translateInfo.GetFormaObrigarVal('com assinatura de');
        num =translateInfo.GetFormaObrigarVal('3 gestores');
        num =translateInfo.GetFormaObrigarVal('2 gestores');
        num =translateInfo.GetFormaObrigarVal('4 gestores');
        num =translateInfo.GetFormaObrigarVal('5 gestores');
    }
    
    public static testMethod void testInsertLog(){
        utilities.LogIntegrationLongResponse( datetime.now(),datetime.now(), 'status teste','teste code', 'status response', 'teste identifier','teste xml');
        utilities.LogIntegration(  datetime.now(), datetime.now(), 'status teste','teste code' ,'status response', 'teste identifier');
    	
        Utilities.OutboundIntegration obil = new Utilities.OutboundIntegration();
        obil.code ='Code';
        obil.endReq = system.today();
        obil.startReq = system.today();
        obil.status = 'status';
        obil.response ='response';
        obil.identifierReq = 'id';
        obil.xml ='<xml></xml>';    
    }
    
    public static testMethod void testeUpdateList(){
        Contact con1 = new Contact(LastName='lastName teste1');
        Contact con2 = new Contact(LastName='lastName teste2');
        Contact con3 = new Contact(LastName='lastName teste3');
        
        List<contact> listCon = new list<contact>();
        listCon.add(con1);
        listCon.add(con2);
        listCon.add(con3);
        
        insert listCon;
        
        utilities.updateList(listCon, true);
    }
    
    public static testMethod void testSendEmail(){
        Utilities.SendEmail('teste@email.com', 'content', 'subject') ; 
        List<String> listEmails = new List<String>{'teste@email.com','teste1@email.com'};
        Utilities.SendEmail(listEmails, 'content', 'subject') ;
        //send email from template
        String[] email = new String[1];
		email[0] = 'teste@email.com';
        //Id sem correspondencia, usados apenas para correr teste
        Utilities.sendTemplatedEmail(email, 'Vendor_Email_Login_Recovery', 'a019E000000u4Ju' ,'a019E000000u4Ju' ,true);
    }
}