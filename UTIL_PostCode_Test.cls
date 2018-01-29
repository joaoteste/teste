@isTest
public class UTIL_PostCode_Test {
    
    @isTest
    public static void test_Create_Interest_trs(){ 
        Postal_Code__c postalCode = new Postal_Code__c(name = 'PARA - 0147', area__c = 'ZML',Concelho__c = 'Lisboa', CP_Min__c = 1000, CP_Max__c= 1494,
                                                      Distrito__c = 'Lisboa', Region__c = 'Mainland');
        
        insert postalCode;
        
        Test.startTest();
        
        UTIL_PostCode.validationPostCode('1234-123');
        UTIL_PostCode.getRegionFromPostCode('1234-123');
        
        // negative Testes
        UTIL_PostCode.validationPostCode('1234-13');
        UTIL_PostCode.validationPostCode('12341234');
        
        Test.stopTest();

    }
}