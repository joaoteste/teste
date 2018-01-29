@isTest(SeeAllData=true)
public class DownloadDocumentTest {
    
    public static testMethod  void TestgetApplicationsInvoicese(){
        
        List<ID> iDList = new List<ID>();
        iDList.add('a012400000XAyQgAAL');
        iDList.add('a012400000XBzS8AAL');
        iDList.add('a012400000Y3iGmAAJ');
        DownloadDocument.getApplicationsInvoices(iDList);
    }

}