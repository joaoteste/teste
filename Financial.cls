public class Financial {
    
    public static decimal AnnualInterestRate(double nper, double pmt, double pv, integer npaymentByYear, integer EndBegPer, boolean amortization)
    {       
        double error = 0.00000001; 
        double high =  1.00; 
        double low = 0.00;
        if(pv==0 || nper== 0){
            return 0;
        }
        
        double rate = (2.0 * (nper * pmt - pv)) / (pv * nper);
  
        while(true) {
            // check for error margin
            double calc = Math.pow(1 + rate, nper);
            if(calc - 1.0!=0){
                calc = (rate * calc) / (calc - 1.0);
            }
            else{
                return 0;
            }
            if(EndBegPer==1 && amortization==false){
                calc-=pmt * (1+rate) / pv;
            }
            else{
                calc -= pmt / pv;
            }
            
            
            if (calc > error) {
                // guess too high, lower the guess
                high = rate;
                rate = (high + low) / 2;
            } else if (calc < -error) {
                // guess too low, higher the guess
                low = rate;
                rate = (high + low) / 2;
            } else {
                // acceptable guess
                break;
            }
        }
        
        if(amortization==true){
            return (decimal.valueOf(rate*npaymentByYear*100)).setscale(4); 
        }
        else {
            return (decimal.valueOf(rate*npaymentByYear*100)).setscale(2); 
        }
    }
}