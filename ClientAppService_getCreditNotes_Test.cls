@isTest (SeeAllData = true)
public class ClientAppService_getCreditNotes_Test {
    
    private static Integer KEY_SIZE = 192;
    private static Integer NUMBER_INVOICES = 4;
    private static Integer NUMBER_CREDIT_NOTES = 4;
    private static Integer nifCounter = 100000000;
    private static Integer invoiceCounter = 9456732;
    private static String taxZone = 'Mainland';
    private static String testUsername = 'email@mail.com';
    private static String testPass = '12345';
    
    private static String typeCustomer = 'Customer - Channel';
    private static String typeVendor = 'Channel Partner / Vendor';
    private static String typeOther = 'Other';
    
    private static Contact testContact;
    
    private static Account testClient;
    private static Account testVendor;
    
    private static Login__c testLogin;
    private static Session__c testSession;
    
    private static Application__c testApp;
    private static List<Billing_Contract__c> testContracts;
    private static Collection_Case__c testCollectionCase;
    private static c2g__codaInvoice__c testInvoice;
    private static List<c2g__codaCreditNote__c> testCreditNotes;

    //implicit success test for validateSession() because it only returns info if session is valid
    static testMethod void shouldReturnCreditNotes(){
        //setup
        testClient = ClientAppService_TestUtils.createAccount(typeCustomer, ''+nifCounter++);
        testVendor = ClientAppService_TestUtils.createAccount(typeVendor, ''+nifCounter++);
        testLogin = ClientAppService_TestUtils.createLogin(testUsername, testPass, false);
        testContact = ClientAppService_TestUtils.createContact(testClient, testLogin);
        testSession = ClientAppService_TestUtils.createSession(testLogin, false);
        testApp = ClientAppService_TestUtils.createRentingApp(testClient, testVendor);
        testContracts = ClientAppService_TestUtils.createContractsForRentingApp(testApp, testClient, testVendor, 2);
        testCollectionCase = ClientAppService_TestUtils.createCollectionCase(testClient);
        
        List<Product2> InvoiceLineItems = new List<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'Pagamento por Multibanco';
        p1.ProductCode = 'PT03';
        Product2 p2 = new Product2();
        p2.Name = 'Despesas Relacionadas com Alterações ao Contrato';
        p2.ProductCode = 'PT16';
        InvoiceLineItems.add(p1);
        InvoiceLineItems.add(p2);
        insert InvoiceLineItems;
        
        testInvoice = ClientAppService_TestUtils.createInvoice(testApp, testClient, testCollectionCase, taxZone, InvoiceLineItems, testContracts.get(0));
        
        testCreditNotes = ClientAppService_TestUtils.createCreditNotes(new List<c2g__codaInvoice__c>{testInvoice}, testApp);
        
        //test
        Test.startTest();
        Map<String,Object> jsonReturn = new Map<String,Object>();
        jsonReturn = (Map<String, Object>) JSON.deserializeUntyped(ClientAppController.getCreditNotes(testSession.token__c));
        Test.stopTest();
        
        //assert
        system.assert(jsonReturn != null, 'Didnt return a json obj');
        system.assert(jsonReturn.containsKey('status'), 'returned JSON doesnt contain status');
        system.assertEquals('SUCCESS', jsonReturn.get('status'), 'returned JSON has incorrect status');
        
        Map<String, Object> dataMap = (Map<String, Object>) jsonReturn.get('data');
        
        system.assert(dataMap.containsKey('creditNotes'), 'returned JSON doesnt contain creditNotes');
        
        List<Object> creditNotes = (List<Object>) dataMap.get('creditNotes');
        system.assertEquals(testCreditNotes.size(), creditNotes.size(), 'returned JSON has incorrect number of creditNotes');
    }
}