@isTest
public class test_Financial {
    public testMethod static void testAnnualInterestRate(){
        double  nrbpay=36.0;
        double  payAmount=167.79;
        double  equipCost=5750.0;
        integer npaymentByYear=12;
        
        Financial.AnnualInterestRate(nrbpay,payAmount,equipCost,npaymentByYear, 0, false);
        Financial.AnnualInterestRate(nrbpay,payAmount,equipCost,npaymentByYear, 1, false);
        Financial.AnnualInterestRate(nrbpay,payAmount,equipCost,npaymentByYear, 0, true);
    }
    
}