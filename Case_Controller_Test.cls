@isTest
public class Case_Controller_Test {
	@isTest
    static void redirectandCloseCase(){
        case newCase = Case_Utils.newCase('High', 'Teste', 'Teste', 'Teste','descricaoqqr', null);
        newCase.status='Open';
        insert newCase;
		ApexPages.StandardController sc = new ApexPages.StandardController(newCase);
        Case_Controller caseCont = new Case_Controller(sc);
        Test.startTest();
        	caseCont.redirectandCloseCase();
        Test.stopTest();
        System.assert(newCase.Status =='Closed', 'The method redirectandCloseCase did not close the case');
    }
}