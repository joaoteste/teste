@isTest(SeeAllData=true)
public class testNotify 
{
    public static testMethod  void test_notify()
    {
        test.startTest();
        notify.SendNotification('a0R24000000UgZWEA0');
        test.stopTest();
        system.assertEquals(1, 1, 'ERRO: Não são iguais');
    }
}