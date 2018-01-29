@isTest(SeeAllData=true)
public class CreateInvoice_Sales_Test2 {
    @isTest 
    public static void testExecute(){ 
        Database.executeBatch(new CreateInvoice_Sales2(1));
    }
}