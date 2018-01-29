@isTest (SeeAllData=true)
public class DocParserAPITest {
    
    private static Map<String,String > data = new RentingApplication_Util_Test().environment8();
    
    @isTest
    private static void caseUtilsTest(){
        
        Case newCase = new case();
        
        Account acc = [Select id,DocParser__c 
                       From Account 
                       where id = : data.get('vendor') ];
        
        acc.DocParser__c = 'idTeste@email.com';
        update acc;
        
        newCase.AccountId =acc.id;
        insert newCase;
        
        //attach  
        Attachment newCaseAttach = createAttachCase(newCase.id);
        insert newCaseAttach;
        
        Test.startTest();
        DocParserApi.vinvDocparser(newCase.id); 
        
        Vendor_Invoice__c vinv = new Vendor_Invoice__c();
        vinv.Account__c =  acc.id;
        vinv.Invoice_Description__c = newCaseAttach.Name;
        
        insert vinv;
        
        
        Test.stopTest();
        
    }
    
    @isTest
    private static void caseUtilsNoAccountTest(){
        
        Case newCase = new case();
        
        insert newCase;
        
        
        insert createAttachCase(newCase.id);
        
        Test.startTest();
        DocParserApi.vinvDocparser(newCase.id); 
        Test.stopTest();
        
    }
    
    @isTest
    private static void createCaseDocParserTest(){
        
        Id loginName = [Select Id,Name 
                        From Login__c 
                        where id = :data.get('vendorLogin') limit 1].id;
        
        DocParserApi.verifyParserAccount(loginName);
    }
    
    @isTest
    public static void getDocInformationDocParser(){
        
        String docID = '2439dd6add270585c89b33957969f67b';
        Login__c vendorLogin =  [Select id, IdVendor__c FROM Login__c where id = :data.get('vendorLogin')];
        
        Account acc = [SELECT ID,DocParser__c
                       From Account 
                       where id = :vendorLogin.IdVendor__c];
        
        acc.DocParser__c = 'rquilgisxhmm';
        update acc;
        
        DocParserApi.getDocParserVendor(vendorLogin.id, docID);
    }
    
    @isTest
    private static void postDocParserVendorTest(){
        
        Attachment newCaseAttach = new Attachment();
        newCaseAttach.Body = Blob.toPdf('Body text attach');
        newCaseAttach.Description = 'This is a test description for the attachment';
        newCaseAttach.Name = 'attachNameTest.txt';
        newCaseAttach.parentID = [Select Id from Case limit 1].ID;
        insert newCaseAttach;
        
        Login__c vendorLogin =  [Select id, IdVendor__c FROM Login__c where id = :data.get('vendorLogin')];
        
        Account acc = [SELECT ID,DocParser__c
                       From Account 
                       where id = :vendorLogin.IdVendor__c];
        
        acc.DocParser__c = 'rquilgisxhmm';
        update acc;
        
        DocParserApi.postDocParserVendor(vendorLogin.id,newCaseAttach.id);
    }
    
    private static Attachment createAttachCase(ID caseID){
        Attachment newCaseAttach = new Attachment();
        newCaseAttach.Body = Blob.toPdf('Body text attach');
        newCaseAttach.Description = 'This is a test description for the attachment';
        newCaseAttach.Name = 'attachNameTest.txt';
        newCaseAttach.ParentId = caseID;
        return newCaseAttach;
    }
}