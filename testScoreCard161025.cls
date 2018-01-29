@isTest (SeeAllData=true)
public class testScoreCard161025 {


    public static testMethod void testMAGIC(){
        ScoreCardConfig.MAGIC();
    }

    public static testMethod void testMAGIC2(){
        ScoreCardConfig.MAGIC2();
    }
    
    public static testMethod void testMAGIC3(){
        ScoreCardConfig.MAGIC3();
    }

    public static testMethod void testMAGIC4(){
        ScoreCardConfig.MAGIC4();
    }
    
    /*

    public static testMethod void testBO_CustomController(){
        BO_CustomController.ReAnalyseCreditInfo( '0012400000QeLPVAA3', 'AP-000027');
    }

    public static testMethod void testGetScoreCard(){
        test.StartTest();	
        ScoreCardConfig.GetScoreCardRate( 'a012400000Lbf7KAAR', 2500);
        ScoreCardConfig.GetScoreCardRate( 'a012400000LREKZAA5', 15000);
        ScoreCardConfig.GetScoreCardRate( 'a012400000M3MR7AAN', 1500);
        test.StopTest();         
    }
    
    public static testMethod void testGetScoreCard1(){
        test.StartTest();	
        ScoreCardConfig.GetScoreCardRate( 'a012400000Q5xlMAAR', 1500);
        ScoreCardConfig.GetScoreCardRate( 'a012400000QQklyAAD', 15000);       
		ScoreCardConfig.GetScoreCardRate( 'a012400000Lbf7KAAR', 250000);
        ScoreCardConfig.GetScoreCardRate( 'a012400000LREKZAA5', -15000);
        test.StopTest();         
    }
    
    public static testMethod void testGetScoreCard2(){
        
        test.StartTest();	
        ScoreCardConfig.GetScoreCardRate( 'a012400000P25A5AAJ', 7000);
        ScoreCardConfig.GetScoreCardRate( 'a012400000QozUAAAZ', 7000);
        ScoreCardConfig.GetScoreCardRate( 'a012400000P9Uv6AAF', 7000);
        ScoreCardConfig.GetScoreCardRate( 'a012400000LddzPAAR', 7000);
        test.StopTest();	
    }
    
     public static void testGetScoreCardFromAmount(string appID, decimal amount){
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
    }

//
//    
//        Low
//            
//                    
    /////////////////a012400000Lbf7KAAR - app trimestral, Interim Fee ; Sociedade Exemplo 0012400000QeLPV low ; Parceiro Exemplo 0012400000EV33v Diluted Documentation Fee
    public static testMethod void testGetScoreCardFromAmount1(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000Lbf7KAAR', -200);
		test.StopTest();                  
    }
    public static testMethod void testGetScoreCardFromAmount2(){
		test.StartTest();
        string appID='a012400000Lbf7KAAR';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount2_2(){
		test.StartTest();
        string appID='a012400000Lbf7KAAR';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount3(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000Lbf7KAAR', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount4(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000Lbf7KAAR', 200000);
		test.StopTest(); 
    } 
    ///////////////// 000899 a012400000RPWPu app trimestral, Interim Fee ; ELECTROPLÁS/LMAR, LDA 0012400000aQQC3 low ; parceiro XISOFF, UNIPESSOAL, LDA 0012400000Z58Vv NAO diluted 
    public static testMethod void testGetScoreCardFromAmount5(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000RPWPu', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount6(){
		test.StartTest();
        string appID='a012400000RPWPu';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount6_2(){
		test.StartTest();
        string appID='a012400000RPWPu';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount7(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000RPWPu', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount8(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000RPWPu', 200000);
		test.StopTest(); 
    }    
        
    ///////////////// app 000186: a012400000NR0o9  monthly, Interim Fee ; Client PIERRE FABRE DERMO - COSMÉTIQUE PORTUGAL, LDA 0012400000WmCNk low ; parceiro 3ERGOSTEK - SOLUÇÕES INFORMÁTICAS, LDA 0012400000W4Gcv diluted
    public static testMethod void testGetScoreCardFromAmount9(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000NR0o9', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount10(){
		test.StartTest();
        string appID='a012400000NR0o9';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount10_1_1(){
		test.StartTest();
        string appID='a012400000NR0o9';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount10_1_2(){
		test.StartTest();
        string appID='a012400000NR0o9';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount10_2(){
		test.StartTest();
        string appID='a012400000NR0o9';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount11(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000NR0o9', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount12(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000NR0o9', 200000);
		test.StopTest(); 
    }    

    // AP-000126: a012400000Ma0P3  monthly, Interim Fee ; Client: ENERGIMAC - SOLUÇÕES DE CLIMATIZAÇÃO E DESENFUMAGEM, LDA 0012400000W40Na low ; parceiro GOMAVAL - SERVIÇOS E EQUIPAMENTOS DE ESCRITÓRIO, LDA 0012400000Ue6YM NAO diluted
    public static testMethod void testGetScoreCardFromAmount13(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000Ma0P3', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount14(){
		test.StartTest();
        string appID='a012400000Ma0P3';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount14_2(){
		test.StartTest();
        string appID='a012400000Ma0P3';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount15(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000Ma0P3', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount16(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000Ma0P3', 200000);
		test.StopTest(); 
    } 
    
    //
    //
    //Especiais
    //
    //
    //
    //
    //
    // ///////////////// app: a012400000RNoBF  monthly, Interim Fee CANCELED ; Client: 0012400000aQ9X6 low ; parceiro 0012400000XbiV4 diluted
    public static testMethod void testGetScoreCardFromAmountS9(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000RNoBF', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmountS10(){
		test.StartTest();
        string appID='a012400000RNoBF';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmountS10_2(){
		test.StartTest();
        string appID='a012400000RNoBF';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmountS11(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000RNoBF', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmountS12(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000RNoBF', 200000);
		test.StopTest(); 
    }    

     /////a012400000P9Uv6
    // AP-000522: a012400000P9Uv6  monthly, Interim Fee ARREAS; Client: São Bento Padelpro 0012400000YEVYA low ; parceiro CANDOR RENTING DE EQUIPAMENTOS, S.A. 0012400000YE7RL NAO diluted
    public static testMethod void testGetScoreCardFromAmountS13(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000P9Uv6', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmountS14(){
		test.StartTest();
        string appID='a012400000P9Uv6';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmountS14_2(){
		test.StartTest();
        string appID='a012400000P9Uv6';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmountS15(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000P9Uv6', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmountS16(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000P9Uv6', 200000);
		test.StopTest(); 
    } 
    
    //
        ///////////////// app: a012400000THIK9  monthly, Interim Fee ; Client: 0012400000bftqC SEM RISK TYPE ; parceiro 0012400000YE7RL NAO diluted
    public static testMethod void testGetScoreCardFromAmount17(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000THIK9', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount18(){
		test.StartTest();
        string appID='a012400000THIK9';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount18_2(){
		test.StartTest();
        string appID='a012400000THIK9';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount19(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000THIK9', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount20(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000THIK9', 200000);
		test.StopTest(); 
    }    
    
     //
     //
     //Risk middle
     //
     //
    
    ///////////////// app 001291: a012400000SezZ2  Quarterly, NO Interim Fee ; Client NACIDOL QUÍMICA : 0012400000baI9d RISK TYPE MIDDLE ; parceiro P.R.N.- INFORMÁTICA 0012400000aQYoL NAO diluted
        public static testMethod void testGetScoreCardFromAmount21(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000SezZ2', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount22(){
		test.StartTest();
        string appID='a012400000SezZ2';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount22_2(){
		test.StartTest();
        string appID='a012400000SezZ2';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount23(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000SezZ2', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount24(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000SezZ2', 200000);
		test.StopTest(); 
    } 
    //
    /////////////////// app: 000108 a012400000MFCO3  monthly, Interim Fee ; CONDE & MOTA, LDA : 0012400000VkWYq RISK TYPE MIDDLE ; ABMN.PT - BUSINESS SOLUTIONS, S.A. 0012400000UeWtm NAO diluted
        public static testMethod void testGetScoreCardFromAmount25(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000MFCO3', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount26(){
		test.StartTest();
        string appID='a012400000MFCO3';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount26_2(){
		test.StartTest();
        string appID='a012400000MFCO3';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount27(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000MFCO3', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount28(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000MFCO3', 200000);
		test.StopTest(); 
    } 
    /////////////////// app 002213 : a012400000VhovH  Quarterly, Interim Fee ; Client FACING, LDA : 0012400000WmWQU RISK TYPE MIDDLE ; 3ERGOSTEK - SOLUÇÕES INFORMÁTICAS, LDA 0012400000W4Gcv DILUTED
           public static testMethod void testGetScoreCardFromAmount29(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000VhovH', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount30(){
		test.StartTest();
        string appID='a012400000VhovH';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount30_2(){
		test.StartTest();
        string appID='a012400000VhovH';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount31(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000VhovH', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount32(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000VhovH', 200000);
		test.StopTest(); 
    }  
    /////////////////// app 000199: a012400000NSsWL  monthly, Interim Fee ; Client FREGUESIA DE SÃO SEBASTIÃO : 0012400000WmWTT RISK TYPE MIDDLE ; 3ERGOSTEK - SOLUÇÕES INFORMÁTICAS, LDA 0012400000W4Gcv DILUTED
    public static testMethod void testGetScoreCardFromAmount33(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000NSsWL', -200);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount34(){
		test.StartTest();
        string appID='a012400000NSsWL';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 12);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 24);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 36);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount34_2(){
		test.StartTest();
        string appID='a012400000NSsWL';
        decimal amount = 200;
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 48);
        ScoreCardConfig.GetScoreCardRateFromAmount(appID, amount, 60);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount35(){
		test.StartTest();
        testGetScoreCardFromAmount('a012400000NSsWL', 2000);
		test.StopTest();
    }
    public static testMethod void testGetScoreCardFromAmount36(){
        test.StartTest();
        testGetScoreCardFromAmount('a012400000NSsWL', 200000);
		test.StopTest(); 
    } 
       
    public static testMethod void testCreditDec47() {
        list<application__c> apps=CreatetestData47();
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
       
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec47_2() {
        list<application__c> apps=CreatetestData47();
        test.StartTest();	
        
      
        
         ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        test.StopTest(); 
    }
    
    
    public static testMethod void testCreditDec46() {
        list<application__c> apps=CreatetestData46();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    
    public static testMethod void testCreditDec45() {
        list<application__c> apps=CreatetestData45();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        // courtactions 0
        test.StopTest(); 
    }

    public static testMethod void testCreditDec45_2() {
        list<application__c> apps=CreatetestData45();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        // courtactions 0
        test.StopTest(); 
    }
    
    
    public static testMethod void testCreditDec44() {
        list<application__c> apps=CreatetestData44();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        // courtactions 0
        test.StopTest(); 
    }
    
        
    public static testMethod void testCreditDec44_2() {
        list<application__c> apps=CreatetestData44();
        
        test.StartTest();	
        
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id); 
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec43() {
        list<application__c> apps=CreatetestData43();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec43_2() {
        list<application__c> apps=CreatetestData43();
        
        test.StartTest();	

        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
       ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec42() {
        list<application__c> apps=CreatetestData42();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    
    
    public static testMethod void testCreditDec41() {
        list<application__c> apps=CreatetestData41();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    
    
    public static testMethod void testCreditDec40() {
        list<application__c> apps=CreatetestData40();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    
    public static testMethod void testCreditDec39() {
        list<application__c> apps=CreatetestData39();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        
        // courtactions 0
        test.StopTest(); 
    }
    
        
    public static testMethod void testCreditDec39_2() {
        list<application__c> apps=CreatetestData39();
        
        test.StartTest();	

        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
    	ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        // courtactions 0
        test.StopTest(); 
    }
    
    
    public static testMethod void testCreditDec38() {
        list<application__c> apps=CreatetestData38();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec37() {
        list<application__c> apps=CreatetestData37();
        
        test.StartTest();	
       
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        // courtactions 0
        test.StopTest(); 
    }
    
       public static testMethod void testCreditDec37_2() {
        list<application__c> apps=CreatetestData37();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
       ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  

        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec36() {
        list<application__c> apps=CreatetestData36();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
                
        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec36_2() {
        list<application__c> apps=CreatetestData36();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
                
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec35() {
        list<application__c> apps=CreatetestData35();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
    
        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec35_2() {
        list<application__c> apps=CreatetestData35();
        
        test.StartTest();	
       
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
       ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec34() {
        list<application__c> apps=CreatetestData34();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec33() {
        list<application__c> apps=CreatetestData33();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec32() {
        list<application__c> apps=CreatetestData32();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec31() {
        list<application__c> apps=CreatetestData31();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec30() {
        list<application__c> apps=CreatetestData30();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    public static testMethod void testCreditDec29() {
        list<application__c> apps=CreatetestData29();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    
        public static testMethod void testCreditDec28() {
        list<application__c> apps=CreatetestData28();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec28_2() {
        list<application__c> apps=CreatetestData28();
        
        test.StartTest();	

        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec27() {
        list<application__c> apps=CreatetestData27();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec26() {
        list<application__c> apps=CreatetestData26();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec26_2() {
        list<application__c> apps=CreatetestData26();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec25() {
        list<application__c> apps=CreatetestData25();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec24() {
        list<application__c> apps=CreatetestData24();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        // courtactions 0
        test.StopTest(); 
    }
    
        
    public static testMethod void testCreditDec24_2() {
        list<application__c> apps=CreatetestData24();
        
        test.StartTest();	

        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
   
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec23() {
        list<application__c> apps=CreatetestData23();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec22() {
        list<application__c> apps=CreatetestData22();
        
        test.StartTest();	
      
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec22_2() {
        list<application__c> apps=CreatetestData22();
        
        test.StartTest();	

        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  

        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec21() {
        list<application__c> apps=CreatetestData21();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        // courtactions 0
        test.StopTest(); 
    }
    
    
        public static testMethod void testCreditDec21_2() {
        list<application__c> apps=CreatetestData21();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
      	ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec20() {
        list<application__c> apps=CreatetestData20();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
     
        // courtactions 0
        test.StopTest(); 
    }


    public static testMethod void testCreditDec20_2() {
        list<application__c> apps=CreatetestData20();
        
        test.StartTest();	

        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec19() {
        list<application__c> apps=CreatetestData19();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec19_2() {
        list<application__c> apps=CreatetestData19();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
       
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec18() {
        list<application__c> apps=CreatetestData18();
        
        test.StartTest();	
                
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec18_2() {
        list<application__c> apps=CreatetestData18();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
     
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec17() {
        list<application__c> apps=CreatetestData17();
        
        test.StartTest();	

        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec17_2() {
        list<application__c> apps=CreatetestData17();
        
        test.StartTest();	
       
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  

        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec16() {
        list<application__c> apps=CreatetestData16();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
                
        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec16_2() {
        list<application__c> apps=CreatetestData16();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
                
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec15() {
        list<application__c> apps=CreatetestData15();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        
        
        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDec15_2() {
        list<application__c> apps=CreatetestData15();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
       
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec14() {
        list<application__c> apps=CreatetestData14();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDec13() {
        list<application__c> apps=CreatetestData13();
        
        test.StartTest();	
                
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        
        // courtactions 0
        test.StopTest(); 
    }
    public static testMethod void testCreditDecTwelve() {
        list<application__c> apps=CreatetestDataTwelve();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDecTwelve_2() {
        list<application__c> apps=CreatetestDataTwelve();
        
        test.StartTest();	
            
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        // courtactions 0
        test.StopTest(); 
    }
    
       public static testMethod void testCreditDecTwelve_3() {
        list<application__c> apps=CreatetestDataTwelve();

        test.StartTest();	
                
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDecEleven() {
        list<application__c> apps=CreatetestDataEleven();
        
        test.StartTest();	
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
     
        
        //   ScoreCardConfig.GetCreditLineStatus( apps[4].AccClient__c, apps[4].id);  
        // courtactions 0
        test.StopTest(); 
    }
    
        public static testMethod void testCreditDecEleven_2() {
        list<application__c> apps=CreatetestDataEleven();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        //   ScoreCardConfig.GetCreditLineStatus( apps[4].AccClient__c, apps[4].id);  
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDecTen() {
        list<application__c> apps=CreatetestDataTen();
        
        test.StartTest();	
                
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        // courtactions 0
        test.StopTest(); 
    }

    
        public static testMethod void testCreditDecTen_2() {
        list<application__c> apps=CreatetestDataTen();
        
        test.StartTest();	
            
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        // ScoreCardConfig.GetCreditLineStatus( apps[4].AccClient__c, apps[4].id);  
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDecNine() {
        list<application__c> apps=CreatetestDataNine();
        
        test.StartTest();	
        
        
        
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        // courtactions 0
        test.StopTest(); 
    }
    
       public static testMethod void testCreditDecNine_2() {
        list<application__c> apps=CreatetestDataNine();
        
        test.StartTest();	
        
       
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
    //    ScoreCardConfig.GetCreditLineStatus( apps[4].AccClient__c, apps[4].id);  
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDecEigth() {
        list<application__c> apps=CreatetestDataEigth();
        
        test.StartTest();	

        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        // courtactions 0
        test.StopTest(); 
    }
    
       public static testMethod void testCreditDecEigth_2() {
        list<application__c> apps=CreatetestDataEigth();
        
        test.StartTest();	

        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
       // ScoreCardConfig.GetCreditLineStatus( apps[4].AccClient__c, apps[4].id);  
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDecseven() {
        list<application__c> apps=CreatetestDataseven();
        
        test.StartTest();	
   
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        
        // courtactions 0
        test.StopTest(); 
    }
    
       public static testMethod void testCreditDecseven_2() {
        list<application__c> apps=CreatetestDataseven();
        
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
        ScoreCardConfig.GetCreditLineStatus( apps[4].AccClient__c, apps[4].id);  
        // courtactions 0
        test.StopTest(); 
    }
    
    public static testMethod void testCreditDecsix() {
        list<application__c> apps=CreatetestDatasix();
        
        test.StartTest();	
   
        // score exite - legal form aprv
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        // courtactions 0
        test.StopTest(); 
        
    }
    
        public static testMethod void testCreditDecsix_2() {
        list<application__c> apps=CreatetestDatasix();
        
        test.StartTest();	
         
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);        
        
       ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);  
        
       // ScoreCardConfig.GetCreditLineStatus( apps[4].AccClient__c, apps[4].id);  
        // courtactions 0
        test.StopTest(); 
        
    }
    
    public static testMethod void testCreditDecfifth() {
        list<application__c> apps=CreatetestDatafifth();
        
        test.StartTest();	

        // score exite - rejected - no date
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        // score exist - ok - no profit legalform unkown
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);

        
        test.StopTest(); 
        
    }
    
        public static testMethod void testCreditDecfifth_2() {
        list<application__c> apps=CreatetestDatafifth();
        
        test.StartTest();	

     
        // score exist - ok - no profit - legalform ADVOG
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);
        // score exist - ok - no profit - legalform ASS
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[4].AccClient__c, apps[4].id);
        
        test.StopTest(); 
        
    }

        public static testMethod void testCreditDecfourth() {
        list<application__c> apps1=CreatetestDatafourth();
        
        test.StartTest();	
        
        // score ok- allok
        ScoreCardConfig.GetCreditLineStatus( apps1[0].AccClient__c, apps1[0].id);
        
        // score ok - financial 2 yearsinfo missing
        ScoreCardConfig.GetCreditLineStatus( apps1[1].AccClient__c, apps1[1].id);
                
        test.StopTest(); 
        
    }
    
        public static testMethod void testCreditDecfourth_2() {
        list<application__c> apps1=CreatetestDatafourth();
        
        test.StartTest();	

        
        //noscore -- legalform ok
        ScoreCardConfig.GetCreditLineStatus( apps1[2].AccClient__c, apps1[2].id);
        
        //score -- no date - ADVOG
        ScoreCardConfig.GetCreditLineStatus( apps1[3].AccClient__c, apps1[3].id);
        
        test.StopTest();         
    }
    

        public static testMethod void testCreditDecThird() {
        
        list<application__c> apps=CreatetestDataThird();
        // score ok inativa
        test.StartTest();	
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        // score ok no date
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        // score ok com date nok
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);
        // score ok no sales
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);
        
        
        test.StopTest();
        
        
        // 
    }
    
    public static testMethod void testCreditDecsec() {
        list<application__c> apps1=CreatetestDataSec();
        
        test.StartTest();	
        
        
        // score existe -rejeted - date ok - net profit nok
        ScoreCardConfig.GetCreditLineStatus( apps1[0].AccClient__c, apps1[0].id);
        
        // noscore  -inactiva 
        ScoreCardConfig.GetCreditLineStatus( apps1[1].AccClient__c, apps1[1].id);

        
        
        test.StopTest(); 
        
    }
    
        public static testMethod void testCreditDecsec_2() {
        list<application__c> apps1=CreatetestDataSec();
        
        test.StartTest();	
                
        //noscore -- no date - eni
        ScoreCardConfig.GetCreditLineStatus( apps1[2].AccClient__c, apps1[2].id);
        
        //noscore -- no date - FUND
        ScoreCardConfig.GetCreditLineStatus( apps1[3].AccClient__c, apps1[3].id);
        
        //noscore -- date - FUND
        ScoreCardConfig.GetCreditLineStatus( apps1[4].AccClient__c, apps1[4].id);
        
        
        test.StopTest(); 
        
    }
    
    public static testMethod void testCreditDecfisrt() {
        
        list<application__c> apps=CreatetestDataFirst();
        // no report
        test.StartTest();	
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        // no score
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
        // score existe -rejeted - date nok
        ScoreCardConfig.GetCreditLineStatus( apps[2].AccClient__c, apps[2].id);
        // score existe -rejeted - date ok
        ScoreCardConfig.GetCreditLineStatus( apps[3].AccClient__c, apps[3].id);
        
        test.StopTest();
        
        
        // 
    }
    

    
    private static testMethod list<application__c> CreatetestDataFirst() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        // no report
        account acc=new account(name ='teste_noreport', nif__c='111111111c', Type='Customer - Channel' );
        accs.add(acc);
        //   score inexistente
        account acc1=new account(name ='teste_noscore', nif__c='222222222c', Type='Customer - Channel' );
        accs.add(acc1);
        // score existe	, rejected date of establishmetn notok
        account acc2=new account(name ='teste_score', nif__c='333333333c', Type='Customer - Channel' );
        accs.add(acc2);
        // score existe	, rejected date of establishmetn ok
        account acc3=new account(name ='teste_score_dt', nif__c='444444444c', Type='Customer - Channel' );
        accs.add(acc3);
        
        
        
        insert accs;
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        apps.add(app); 
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='222222222c', CAE__c='4243', activityCode__c=42, PercentilScore__c=0, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2012-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=25000,
                                        sales__c=500000, RiscoInforma__c=12, IndicadorRisco__c=3);
        
        apps.add(app1);
        reps.add(rep);
        
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='333333333c', CAE__c='4243', activityCode__c=42, PercentilScore__c=15, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2012-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=25000,
                                         sales__c=500000, RiscoInforma__c=4, IndicadorRisco__c=3);
        
        apps.add(app2);
        reps.add(rep1);
        
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='444444444c', CAE__c='4243', activityCode__c=42, PercentilScore__c=15, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=25000,
                                         sales__c=500000, RiscoInforma__c=3, IndicadorRisco__c=4);
        
        apps.add(app3);
        reps.add(rep2);
        
        
        
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestDataSec() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        // score existe	, rejected date of establishmetn ok, sales ok, net profit nok
        account acc=new account(name ='teste_score_dt_noprofit', nif__c='555555555', Type='Customer - Channel' );
        accs.add(acc);
        
        // score existe	, rejected date of establishmetn ok, sales ok, net profit nok
        account acc1=new account(name ='teste_score_nodate', nif__c='666666666', Type='Customer - Channel' );
        accs.add(acc1);
        
        // score existe	, rejected date of establishmetn ok, sales ok, net profit nok
        account acc2=new account(name ='teste_noscore_ENI', nif__c='777777777', Type='Customer - Channel' );
        accs.add(acc2);
        
        
        account acc3=new account(name ='teste_noscore_FUND_nodate', nif__c='888888888', Type='Customer - Channel' );
        accs.add(acc3);
        
        account acc4=new account(name ='teste_noscore_FUND_date', nif__c='999999999', Type='Customer - Channel' );
        accs.add(acc4);
        
        
        
        insert accs;
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=15, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                        sales__c=500000, RiscoInforma__c=4, IndicadorRisco__c=3);
        
        apps.add(app);
        reps.add(rep);
        
        // score existe	, rejected date of establishmetn ok, sales ok, net profit nok
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='6666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=55500,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, Estado__c='Inativa');
        
        apps.add(app1);
        reps.add(rep1);
        
        
        //noscore card ENI no date
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__c='ENI');
        
        apps.add(app2);
        reps.add(rep2);
        //noscore card FUND no date
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__c='FUND');
        
        apps.add(app3);
        reps.add(rep3);
        
        
        //noscore card FUND no date
        application__c app4=new application__c( accClient__c=accs[4].id, vendor__c= vendorid);
        reportdb__c rep4=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[4].id, numerocontribuinte__c='99999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__c='FUND');
        
        apps.add(app4);
        reps.add(rep4);
        
        
        
        
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestDatathird() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        // score existe	, rejected date of establishmetn ok, sales ok, net profit nok
        account acc=new account(name ='teste_score_inativa', nif__c='199999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='teste_score_no_date', nif__c='299999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='teste_score_date_nok', nif__c='399999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        
        account acc3=new account(name ='teste_score_no sales', nif__c='499999999', Type='Customer - Channel' );
        accs.add(acc3);
        
        
        
        insert accs;
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='199999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                        sales__c=1000000, RiscoInforma__c=14, IndicadorRisco__c=2, estado__c='Inativa');
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='299999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                         sales__c=1000000, RiscoInforma__c=14, IndicadorRisco__c=2);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='399999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2015-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                         sales__c=1000000, RiscoInforma__c=14, IndicadorRisco__c=2 );
        
        apps.add(app2);
        reps.add(rep2);
        
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='499999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2 );
        
        apps.add(app3);
        reps.add(rep3);
        
        
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestDatafourth() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        // score existe	, rejected date of establishmetn ok, sales ok, net profit nok
        account acc=new account(name ='teste_score_allok', nif__c='599999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='teste_score_financial_info_nok', nif__c='699999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='teste_legalformok', nif__c='799999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        
        account acc3=new account(name ='teste_score_no sales', nif__c='899999999', Type='Customer - Channel' );
        accs.add(acc3);
        
        // score existe	, rejected no date of establishmetn 
        account acc4=new account(name ='teste_score_dt', nif__c='1444444444', Type='Customer - Channel' );
        accs.add(acc4);
        insert accs;
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='599999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=50000,
                                        sales__c=1000000, RiscoInforma__c=14, IndicadorRisco__c=2, sales_n_1__c = 400000, sales_n_2__c= 400000, ResultLiquido_n_1__c=500000, ResultLiquido_n_2__c=500000);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='699999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=50000,
                                         sales__c=1000000, RiscoInforma__c=14, IndicadorRisco__c=2, sales_n_1__c = 400000,  ResultLiquido_n_1__c=500000);
        
        apps.add(app1);
        reps.add(rep1);
        
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='799999999', CAE__c='4243', activityCode__c=42,  
                                         FormaObrigarToNr__c=1, DataConstituicao__c=date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=1000000, TotEmpregados__c=15 , FormaJuridica__c='EE');
        
        apps.add(app2);
        reps.add(rep2);
        
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='899999999', CAE__c='4243', activityCode__c=42,  
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=1000000, TotEmpregados__c=5 , FormaJuridica__c='ADVOG');
        
        apps.add(app3);
        reps.add(rep3);
        
        application__c app4=new application__c( accClient__c=accs[4].id, vendor__c= vendorid);
        reportdb__c rep4=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[4].id, numerocontribuinte__c='1444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=15, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=25000,
                                         sales__c=500000, RiscoInforma__c=3, IndicadorRisco__c=4);
        
        apps.add(app4);
        reps.add(rep4);
        
        
        insert apps;
        insert reps;
        
        return apps;
    }
    
    
    private static testMethod list<application__c> CreatetestDatafifth() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        // score existe	, rejected no date of establishmetn 
        account acc=new account(name ='teste_score_dt', nif__c='1444444444', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='teste_score_noprofit', nif__c='2444444444', Type='Customer - Channel' );
        accs.add(acc1);
        
        
        account acc2=new account(name ='teste_score_noprofit_advog', nif__c='3444444444', Type='Customer - Channel' );
        accs.add(acc2);
        
        
        account acc3=new account(name ='teste_score_noprofit_advog', nif__c='4444444444', Type='Customer - Channel' );
        accs.add(acc3);
        
        account acc4=new account(name ='teste_score_noprofit_advog', nif__c='5444444444', Type='Customer - Channel' );
        accs.add(acc4);
        
        account acc5=new account(name ='teste_score_noprofit_advog', nif__c='6444444444', Type='Customer - Channel' );
        accs.add(acc5);
        insert accs;
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='1444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=15, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=25000,
                                        sales__c=500000, RiscoInforma__c=3, IndicadorRisco__c=4);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='2444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP' );
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='3444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ENI' );
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='4444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS' );
        
        apps.add(app3);
        reps.add(rep3);
        
        application__c app4=new application__c( accClient__c=accs[4].id, vendor__c= vendorid);
        reportdb__c rep4=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[4].id, numerocontribuinte__c='5444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESTR' );
        
        apps.add(app4);
        reps.add(rep4);
        
        application__c app5=new application__c( accClient__c=accs[4].id, vendor__c= vendorid);
        reportdb__c rep5=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[4].id, numerocontribuinte__c='6444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM' );
        
        apps.add(app5);
        reps.add(rep5);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestDatasix() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        
        account acc=new account(name ='66444444444', nif__c='66444444444', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='7444444444', nif__c='7444444444', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='8444444444', nif__c='8444444444', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='9444444444', nif__c='9444444444', Type='Customer - Channel' );
        accs.add(acc3);
        
     //   account acc4=new account(name ='1333333333', nif__c='1333333333', Type='Customer - Channel' );
     //   accs.add(acc4);
       insert accs;
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='66444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM' );
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='7444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', Totincidentes__c=0 );
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='8444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', Totincidentes__c=4 );
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='9444444444', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG', Totincidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        
       // application__c app4=new application__c( accClient__c=accs[4].id, vendor__c= vendorid);
      //  reportdb__c rep4=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[4].id, numerocontribuinte__c='1333333333', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
       //                                  FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
//                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', Totincidentes__c=0);
        
     //   apps.add(app4);
     //   reps.add(rep4);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    private static testMethod list<application__c> CreatetestDataseven() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        
        account acc=new account(name ='2333333333', nif__c='2333333333', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='3333333333', nif__c='3333333333', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='4333333333', nif__c='4333333333', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='5333333333', nif__c='5333333333', Type='Customer - Channel' );
        accs.add(acc3);
        
        account acc4=new account(name ='6333333333', nif__c='6333333333', Type='Customer - Channel' );
        accs.add(acc4);
        insert accs;
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='2333333333', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESTR', Totincidentes__c=0 );
        apps.add(app);
        reps.add(rep);
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='3333333333', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP', Totincidentes__c=0 );
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='4333333333', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', Totincidentes__c=4 );
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='5333333333', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG', Totincidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        
        application__c app4=new application__c( accClient__c=accs[4].id, vendor__c= vendorid);
        reportdb__c rep4=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[4].id, numerocontribuinte__c='6333333333', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', Totincidentes__c=0);
        
        apps.add(app4);
        reps.add(rep4);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestDataEigth() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        
        account acc=new account(name ='7333333333', nif__c='7333333333', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='8333333333', nif__c='8333333333', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='9333333333', nif__c='9333333333', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='1222222222', nif__c='1222222222', Type='Customer - Channel' );
        accs.add(acc3);
        
        account acc4=new account(name ='2222222222', nif__c='2222222222', Type='Customer - Channel' );
        accs.add(acc4);
        insert accs;
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='7333333333', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESTR' );
        apps.add(app);
        reps.add(rep);
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='8333333333', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS' );
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='9333333333', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG' );
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='1222222222', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP');
        
        apps.add(app3);
        reps.add(rep3);
        
        application__c app4=new application__c( accClient__c=accs[4].id, vendor__c= vendorid);
        reportdb__c rep4=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[4].id, numerocontribuinte__c='2222222222', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM');
        
        apps.add(app4);
        reps.add(rep4);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    
    private static testMethod list<application__c> CreatetestDataNine() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        
        account acc=new account(name ='3222222222', nif__c='3222222222', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='4222222222', nif__c='4222222222', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='5222222222', nif__c='5222222222', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='6222222222', nif__c='6222222222', Type='Customer - Channel' );
        accs.add(acc3);
        
    //    account acc4=new account(name ='7222222222', nif__c='7222222222', Type='Customer - Channel' );
      //  accs.add(acc4);
        insert accs;
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='3222222222', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESTR', TotIncidentes__c=0 );
        apps.add(app);
        reps.add(rep);
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='4222222222', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=0 );
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='5222222222', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG' , TotIncidentes__c=0 );
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='6222222222', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP',  TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        
    //    application__c app4=new application__c( accClient__c=accs[4].id, vendor__c= vendorid);
    ///    reportdb__c rep4=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[4].id, numerocontribuinte__c='7222222222', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
     //                                    FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
     //                                    sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', TotIncidentes__c=0);
        
      //  apps.add(app4);
      //  reps.add(rep4);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestDataTen() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        account acc=new account(name ='8222222222', nif__c='8222222222', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='9222222222', nif__c='9222222222', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='1555555555', nif__c='1555555555', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='2555555555', nif__c='2555555555', Type='Customer - Channel' );
        accs.add(acc3);
        
        
        insert accs;
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='8222222222', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESTR', TotIncidentes__c=null );
        apps.add(app);
        reps.add(rep);
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='9222222222', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=null );
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='1555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG' , TotIncidentes__c=null );
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='2555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP',  TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        
        
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestDataEleven() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        account acc=new account(name ='4555555555', nif__c='4555555555', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='5555555555', nif__c='5555555555', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='6555555555', nif__c='6555555555', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='7555555555', nif__c='7555555555', Type='Customer - Channel' );
        accs.add(acc3);
        
        
        insert accs;
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='4555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESTR', TotIncidentes__c=4 );
        apps.add(app);
        reps.add(rep);
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='5555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=0 );
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='6555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG' , TotIncidentes__c=0 );
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='7555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP',  TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        
        
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestDataTwelve() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='8555555555', nif__c='8555555555', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='3555555555', nif__c='3555555555', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='9555555555', nif__c='9555555555', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='1666666666', nif__c='1666666666', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='8555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='3555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='9555555555', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=15000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='1666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData13() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='2666666666', nif__c='2666666666', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='3666666666', nif__c='3666666666', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='4666666666', nif__c='4666666666', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='5666666666', nif__c='5666666666', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='2666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='3666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='4666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=15000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEM', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='5666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData14() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='6666666666', nif__c='6666666666', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='7666666666', nif__c='7666666666', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='8666666666', nif__c='8666666666', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='9666666666', nif__c='9666666666', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='6666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='7666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='8666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=15000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='9666666666', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData15() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='1777777777', nif__c='1777777777', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='2777777777', nif__c='2777777777', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='3777777777', nif__c='3777777777', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='4777777777', nif__c='4777777777', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='1777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='2777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='3777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='4777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData16() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='5777777777', nif__c='5777777777', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='6777777777', nif__c='6777777777', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='7777777777', nif__c='7777777777', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='8777777777', nif__c='8777777777', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='5777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='6777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=0);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='7777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEPC', TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='7777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESFL', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData17() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='9777777777', nif__c='9777777777', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='18888888888', nif__c='18888888888', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='28888888888', nif__c='28888888888', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='38888888888', nif__c='38888888888', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='9777777777', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='18888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=0);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='28888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEPC', TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='38888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESFL', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData18() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='48888888888', nif__c='48888888888', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='58888888888', nif__c='58888888888', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='68888888888', nif__c='68888888888', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='78888888888', nif__c='78888888888', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='48888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='58888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='68888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='78888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData19() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='88888888888', nif__c='88888888888', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='98888888888', nif__c='98888888888', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='1999999999', nif__c='1999999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='2999999999', nif__c='2999999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='88888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='98888888888', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='1999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='2999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    private static testMethod list<application__c> CreatetestData20() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='3999999999', nif__c='3999999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='4999999999', nif__c='4999999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='5999999999', nif__c='5999999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='6999999999', nif__c='6999999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='3999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='4999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=0);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='5999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='6999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESFL', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData21() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='7999999999', nif__c='7999999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='8999999999', nif__c='8999999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='9999999999', nif__c='9999999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='19999999999', nif__c='19999999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='7999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='8999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=0);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='9999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='19999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESFL', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData22() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='29999999999', nif__c='29999999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='39999999999', nif__c='39999999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='49999999999', nif__c='49999999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='59999999999', nif__c='59999999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='29999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='39999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='49999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='59999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    
    private static testMethod list<application__c> CreatetestData23() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        account acc=new account(name ='59999999999', nif__c='59999999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='69999999999', nif__c='69999999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='79999999999', nif__c='79999999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='89999999999', nif__c='89999999999', Type='Customer - Channel' );
        accs.add(acc3);
        
        
        insert accs;
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='59999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESTR', TotIncidentes__c=4 );
        apps.add(app);
        reps.add(rep);
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='69999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=0 );
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='79999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG' , TotIncidentes__c=0 );
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='89999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP',  TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        
        
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData24() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='99999999999', nif__c='99999999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='98999999999', nif__c='98999999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='97999999999', nif__c='97999999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='96999999999', nif__c='96999999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='99999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEM', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='98999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEM', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='97999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=15000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEM', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='96999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData25() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='95999999999', nif__c='95999999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='94999999999', nif__c='94999999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='93999999999', nif__c='93999999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='92999999999', nif__c='92999999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='95999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEM', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='94999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEM', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='93999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=15000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEM', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='92999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    
    private static testMethod list<application__c> CreatetestData26() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='91999999999', nif__c='91999999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='99199999999', nif__c='99199999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='99299999999', nif__c='99299999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='99399999999', nif__c='99399999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='91999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='99199999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='99299999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=15000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='99399999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    
    private static testMethod list<application__c> CreatetestData27() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='99499999999', nif__c='99499999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='99599999999', nif__c='99599999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='99699999999', nif__c='99699999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='99799999999', nif__c='99799999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='99499999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='99599999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='99699999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=15000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='99799999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData28() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='99899999999', nif__c='99899999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='99999999999', nif__c='99999999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='99919999999', nif__c='99919999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='99929999999', nif__c='99929999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='99899999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='99999999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='99919999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=15000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='99929999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData29() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='99939999999', nif__c='99939999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='99949999999', nif__c='99949999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='99959999999', nif__c='99959999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='99969999999', nif__c='99969999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='99939999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='99949999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='99949999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=15000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='99959999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=500000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData30() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='99969999999', nif__c='99969999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='99979999999', nif__c='99979999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='99989999999', nif__c='99989999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='99991999999', nif__c='99991999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='99969999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='99979999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='99989999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='99991999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData31() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='99995999999', nif__c='99995999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='99992999999', nif__c='99992999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='99993999999', nif__c='99993999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='99994999999', nif__c='99994999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='99995999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='99992999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999939999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999949999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ESFL', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData32() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='999969999999', nif__c='999969999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999979999999', nif__c='999979999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999989999999', nif__c='999989999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999991999999', nif__c='999991999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999969999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999979999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999989999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999991999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData33() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='999992999999', nif__c='999992999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999993999999', nif__c='999993999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999994999999', nif__c='999994999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999995999999', nif__c='999995999999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999992999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=14, IndicadorRisco__c=2,  TotIncidentes__c=8);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999993999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=Null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C=null, TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999994999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=Null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C=null, TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999995999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=Null, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C=null, TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData34() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        
        //vendas ok com net profit null com e sem courtactions
        
        
        account acc=new account(name ='999996999999', nif__c='999996999999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999997999999', nif__c='999997999999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999998999999', nif__c='999998999999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999199999', nif__c='999999199999', Type='Customer - Channel' );
        accs.add(acc3);
        insert accs;
        
        
        
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999996999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C=null, TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999997999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C=null, TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999998999999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C=null, TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999199999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=1000000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C=null, TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
        
        
    }
    
    private static testMethod list<application__c> CreatetestData35() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999299999', nif__c='999999299999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999399999', nif__c='999999399999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999499999', nif__c='999999499999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999599999', nif__c='999999599999', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999299999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C=null, TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999399999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999499999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999599999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    
    private static testMethod list<application__c> CreatetestData36() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999699999', nif__c='999999699999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999799999', nif__c='999999799999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999899999', nif__c='999999899999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999919999', nif__c='999999919999', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999699999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEPC', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999799999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='AUT', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999899999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='AUT', TotIncidentes__c=8);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999919999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestData37() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999929999', nif__c='999999929999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999939999', nif__c='999999939999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999949999', nif__c='999999949999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999959999', nif__c='999999959999', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999929999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='EEPC', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999939999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='AUT', TotIncidentes__c=0);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999949999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='PP', TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999959999', CAE__c='4243', activityCode__c=42, PercentilScore__c=87, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=500000, RiscoInforma__c=14, IndicadorRisco__c=2, FormaJuridica__C='ASS', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestData38() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999969999', nif__c='999999969999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999979999', nif__c='999999979999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999989999', nif__c='999999989999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999991999', nif__c='999999991999', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999969999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C=null, TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999979999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C=null, TotIncidentes__c=8);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999989999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C=null, TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999991999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    
    private static testMethod list<application__c> CreatetestData39() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999992999', nif__c='999999992999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999993999', nif__c='999999993999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999994999', nif__c='999999994999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999995999', nif__c='999999995999', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999992999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999979999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=0);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999989999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='AUT', TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999991999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=500000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='EEPC', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    
    private static testMethod list<application__c> CreatetestData40() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999996999', nif__c='999999996999', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999997999', nif__c='999999997999', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999998999', nif__c='999999998999', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999999199', nif__c='999999999199', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999996999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2015-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999997999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C=null, TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999998999', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='AUT', TotIncidentes__c=8);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999999199', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C=null, TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestData41() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999999299', nif__c='999999999299', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999999399', nif__c='999999999399', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999999499', nif__c='999999999499', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999999599', nif__c='999999999599', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999999299', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ACE', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999999399', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ACE', TotIncidentes__c=8);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999999499', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999999599', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestData42() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999999699', nif__c='999999999699', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999999799', nif__c='999999999799', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999999899', nif__c='999999999899', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999999919', nif__c='999999999919', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999999699', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                        sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ACE', TotIncidentes__c=0);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999999799', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=null,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='AUT', TotIncidentes__c=0);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999999899', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999999919', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestData43() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999999929', nif__c='999999999929', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999999939', nif__c='999999999939', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999999949', nif__c='999999999949', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999999959', nif__c='999999999959', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999999929', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                        sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);
        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999999939', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ACE', TotIncidentes__c=null);
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999999949', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=8);
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999999959', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestData44() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999999969', nif__c='999999999969', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999999979', nif__c='999999999979', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999999989', nif__c='999999999989', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999999991', nif__c='999999999991', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999999969', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                        sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=0);        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999999979', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ACE', TotIncidentes__c=0);    
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999999989', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='AUT', TotIncidentes__c=0);    
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999999991', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=0);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestData45() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999999992', nif__c='999999999992', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999999993', nif__c='999999999993', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999999994', nif__c='999999999994', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='999999999995', nif__c='999999999995', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999999992', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                        sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999999993', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ACE', TotIncidentes__c=null);    
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999999994', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='AUT', TotIncidentes__c=null);    
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='999999999995', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=5000000, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=null);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestData46() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='999999999996', nif__c='999999999996', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='999999999997', nif__c='999999999997', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='999999999998', nif__c='999999999998', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='9999999999991', nif__c='9999999999991', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='999999999996', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=-500,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=null);        
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='999999999997', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ACE', TotIncidentes__c=8);    
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='999999999998', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='PP', TotIncidentes__c=1);    
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='9999999999991', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C=null, TotIncidentes__c=1);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
    private static testMethod list<application__c> CreatetestData47() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='9999999999992', nif__c='9999999999992', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='9999999999993', nif__c='9999999999993', Type='Customer - Channel' );
        accs.add(acc1);
        
        account acc2=new account(name ='9999999999994', nif__c='9999999999994', Type='Customer - Channel' );
        accs.add(acc2);
        
        account acc3=new account(name ='9999999999995', nif__c='9999999999995', Type='Customer - Channel' );
        accs.add(acc3);
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid);
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='9999999999992', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ACE', TotIncidentes__c=1);     
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid);
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='9999999999993', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=1);  
        
        apps.add(app1);
        reps.add(rep1);
        
        application__c app2=new application__c( accClient__c=accs[2].id, vendor__c= vendorid);
        reportdb__c rep2=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[2].id, numerocontribuinte__c='9999999999994', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ASS', TotIncidentes__c=1);   
        
        apps.add(app2);
        reps.add(rep2);
        
        application__c app3=new application__c( accClient__c=accs[3].id, vendor__c= vendorid);
        reportdb__c rep3=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[3].id, numerocontribuinte__c='9999999999995', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=Date.valueOf('2000-01-01'), CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='AUT', TotIncidentes__c=1);
        
        apps.add(app3);
        reps.add(rep3);
        insert apps;
        insert reps;
        
        return apps;
    }
    
       
    
     public static testMethod void testCreditDec48() {
        list<application__c> apps=CreatetestData48();
        test.StartTest();	
        
        ScoreCardConfig.GetCreditLineStatus( apps[0].AccClient__c, apps[0].id);
        
        ScoreCardConfig.GetCreditLineStatus( apps[1].AccClient__c, apps[1].id);
       
        test.StopTest(); 
    }
    
        private static testMethod list<application__c> CreatetestData48() {
        
        //create test data
        string vendorid='0012400000EV33vAAD';
        list<application__c> apps=new list<application__c>();
        list<account> accs=new list<account>();
        list<reportDB__c> reps=new list<reportDB__c>();
        
        
        account acc=new account(name ='9999999999912', nif__c='9999999999912', Type='Customer - Channel' );
        accs.add(acc);
        
        account acc1=new account(name ='9999999999913', nif__c='9999999999913', Type='Customer - Channel' );
        accs.add(acc1);
        
        
        insert accs;   
        application__c app=new application__c( accClient__c=accs[0].id, vendor__c= vendorid, payment_freq__c='Quarterly');
        reportdb__c rep=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[0].id, numerocontribuinte__c='9999999999912', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                        FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                        sales__c=null, RiscoInforma__c=null, IndicadorRisco__c=null, FormaJuridica__C='ACE', TotIncidentes__c=1);     
        apps.add(app);
        reps.add(rep);
        
        application__c app1=new application__c( accClient__c=accs[1].id, vendor__c= vendorid, payment_freq__c='Monthly');
        reportdb__c rep1=new reportDB__c(recordtypeid='012240000006iFxAAI',vendor__c=accs[1].id, numerocontribuinte__c='9999999999913', CAE__c='4243', activityCode__c=42, PercentilScore__c=null, 
                                         FormaObrigarToNr__c=1, DataConstituicao__c=null, CodigoPostal__c='2620',  Ano_Ultimo_Balanco__c=2014, ResultLiqUltimoAno__c=5000000,
                                         sales__c=null, RiscoInforma__c=12, IndicadorRisco__c=null, FormaJuridica__C='ADVOG', TotIncidentes__c=1);  
        
        apps.add(app1);
        reps.add(rep1);
        
        insert apps;
        insert reps;
        
        return apps;
    }
*/
    
}