@isTest
private class CreditInfoProviderResponseTest {
    
    private static final String xml = '<testTag>test xml<testTag>';
    private static final String code = '200';
    private static final String error = 'Error test string';
    private static final String info = 'Info test string';
    private static final boolean status_ok = true;
    private static final boolean status_not_ok = false;
    private static final Datetime startDate = DateTime.now();
    private static final Datetime endDate = DateTime.now();
    private static final Blob pdfBlob = Blob.valueOf('test string to blob');
    private static final String statusForCreditInfo = 'CREDITINFO STATUS';
    
    @isTest
    static void emptyConstructorTest(){
    	
        Test.startTest();
        
        CreditInfoProviderResponse cipr = new CreditInfoProviderResponse();
        System.Assert(cipr.xml == null);
        System.Assert(cipr.code == null);
        System.Assert(cipr.status == null);
        System.Assert(cipr.startDate == null);
        System.Assert(cipr.endDate == null);
        System.Assert(cipr.endDate == null);
        System.Assert(cipr.pdfBlob == null);
        System.Assert(cipr.statusForCreditInfo == null);
        
        Test.stopTest();
        
    }
    
    @isTest 
    static void secondConstructorTest(){
        
        Test.startTest();
        
        CreditInfoProviderResponse cipr_ok = new CreditInfoProviderResponse(xml, status_ok);
        System.assertEquals(cipr_ok.xml, xml);
        System.assertEquals(cipr_ok.status, status_ok);
        System.assertEquals(cipr_ok.statusForCreditInfo, 'OK');
        
        CreditInfoProviderResponse cipr_not_ok = new CreditInfoProviderResponse(xml, status_not_ok);
        System.assertEquals(cipr_not_ok.xml, xml);
        System.assertEquals(cipr_not_ok.status, status_not_ok);
        System.assertEquals(cipr_not_ok.statusForCreditInfo, 'ERROR');
        
        Test.stopTest();
        
    }
    
    @isTest
    static void setMethodsTest(){
       
        Test.startTest();
        
        CreditInfoProviderResponse cipr = new CreditInfoProviderResponse();
        cipr.setResponseXml(xml);
        cipr.setResponseCode(code);
        cipr.setResponseError(error);
        cipr.setResponseInfo(info);
        cipr.setResponseStartDate(startDate);
        cipr.setResponseEndDate(endDate);
        cipr.setResponsePdfBlob(pdfBlob);
        cipr.setStatusForCreditInfo(statusForCreditInfo);
        cipr.setResponseStatus(status_ok);
        
        System.assertEquals(cipr.xml, xml);
        System.assertEquals(cipr.code, code);
        System.assertEquals(cipr.status, status_ok);
        System.assertEquals(cipr.startDate, startDate);
        System.assertEquals(cipr.endDate, endDate);
        System.assertEquals(cipr.pdfBlob, pdfBlob);
        System.assertEquals(cipr.statusForCreditInfo, statusForCreditInfo);
        System.assertEquals(cipr.status, status_ok);
        
        Test.stopTest();

    }
}