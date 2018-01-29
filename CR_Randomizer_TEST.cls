@isTest 
public class CR_Randomizer_TEST {
    
    @isTest 
    static void testCR_Randomizer() {
        test.startTest();
        Integer testInt = CR_Randomizer.getRandomNumber(10);
        Boolean testBool = CR_Randomizer.getRandomBoolean();
        String testgetRandomNumberString = CR_Randomizer.getRandomNumberString('',10);
        List<String> testStringList = new List<String>();
        testStringList.add('one');
        testStringList.add('two');
        testStringList.add('three');
        String testString = CR_Randomizer.getRandomString(testStringList);
        String testString2 = CR_Randomizer.getRandomPickListValue(new Account(), 'Industry', true);
        String testString3 = CR_Randomizer.getRandomPickListValue(new Account(), 'Industry', false);
        Map<String,List<String>> testMap = CR_Randomizer.getPicVals(new Account());
        test.stopTest();
        String testString4 = CR_Randomizer.getPlaceholderText(300);
    }    
}