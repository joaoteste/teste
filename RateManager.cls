global class RateManager {
    //Method created as Web Service to be called from button in Standard salesforce Layout
    //devolve mensagem que vai ser actualizada em ecran no campo
   /* webservice static string GetRateManagerConfig(string equipamount, string DateOfEstablishment, string AnnualRevenue, string FailureScore, string Inid){
        try{
            string OutMsg='';
            decimal valequip=decimal.valueOf(equipamount);
            date dateestb=null;
            if (DateOfEstablishment!=null || DateOfEstablishment!=''){
                dateestb=date.parse(DateOfEstablishment);
        	}
           else{
              return OutMsg='Data de Fundação de Empresa tem de estar preenchida!';  
            }
          system.debug('teste');  
            decimal valRev=decimal.valueOf(AnnualRevenue);
            decimal score=decimal.valueOf(FailureScore);
            date now=date.today();
            decimal valdate=dateestb.daysBetween(now)/365;
            decimal penbon;
            map<string, Admin_Config__c> AdminConfig=new    map<string, Admin_Config__c>();  
            Application__c app=[SELECT Id FROM Application__c where name=:Inid];
            // It's enough that one of the conditions is not true to stop the process
            Admin_Config__c[] GenCfg=[Select Parameter__c, Output_1__c, Output_2__c From Admin_Config__c where RecordTypeId=:[Select Id From RecordType where 
                                       Name='General'] and ( (property_1_val__c > :valRev And Parameter__c='AnnualRevenue') or ( property_1_val__c > :valdate And Parameter__c='DateOfEstablishment') )  And Active__c=TRUE];
            if (GenCfg != null && GenCfg.size()!=0){
                if(GenCfg[0].Output_1__c!=''){
                    OutMsg=GenCfg[0].Output_2__c;
                    app.Reject_Reason__c=GenCfg[0].Output_2__c;
                    app.Status__c=GenCfg[0].Output_1__c;
                    update app; 
                    return OutMsg;
               } 
            } 
            Admin_Config__c[] RateFactorcfg=[Select  Property_3__c, Property_4__c, Property_5__c, Output_3__c, Output_4__c, Output_5__c  From Admin_Config__c where 
                                             RecordTypeId=:[Select Id From RecordType where Name='TaxRate'] And Property_1_val__c<:valequip and  Property_2_val__c>=:valequip  And Active__c=TRUE];

            Admin_Config__c[] RateMngCfg=[Select  Id, Output_1__c, Output_2__c, Output_3__c , Output_4__c, Output_5__c From Admin_Config__c where 
                                          RecordTypeId=:[Select Id From RecordType where Name='Rate Manager'] and  Property_1_val__c<=:score and  Property_2_val__c>:score  And Active__c=TRUE];

           Admin_Config__c[] InsTaxCfg=[Select Output_1__c, Output_2__c From Admin_Config__c where RecordTypeId=:[Select Id From RecordType where Name='Insurance'] 
                                        And Property_1_val__c<:valequip and  Property_2_val__c>=:valequip  And Active__c=TRUE];
            if (RateMngCfg != null && RateMngCfg.size()!=0){ 
                app.Credit_Line_Status__c=RateMngCfg[0].Output_1__c;
                app.Credit_Limit__c=decimal.ValueOf(RateMngCfg[0].Output_4__c);
                penbon=decimal.ValueOf(RateMngCfg[0].Output_3__c);
                app.ScoreCard_Version__c=RateMngCfg[0].Id;
                app.Rating_Candor__c=RateMngCfg[0].Output_5__c;
                app.Status__c='Application - Approved';
                app.Insurance_Value__c=((valequip * decimal.valueOf(InsTaxCfg[0].Output_1__c)/100)/12).setscale(0);
                app.Insurance_Movement_value__c=((valequip * decimal.valueOf(InsTaxCfg[0].Output_2__c)/100)/12).setscale(0);
            }
            if (RateFactorcfg != null && RateFactorcfg.size()!=0){ 
                app.Output_Rate_Manager__c='Pick Contract Term: ' + RateFactorcfg[0].Property_3__c + ': €' + 
                    (((decimal.ValueOf(RateFactorcfg[0].Output_3__c ) * penbon) / 100) * valequip).setscale(2) +'; ' + RateFactorcfg[0].Property_4__c + ': €' + 
                    (((decimal.ValueOf(RateFactorcfg[0].Output_4__c) * penbon ) / 100 )* valequip).setscale(2) +'; ' + RateFactorcfg[0].Property_5__c + ': €' + 
                    (((decimal.ValueOf(RateFactorcfg[0].Output_5__c) * penbon) /100) * valequip).setscale(2) +'; ' ;
                app.Output_Ins_Manager__c='Pick Insurance Type: Static Risk with Rate ' + InsTaxCfg[0].Output_1__c + '%; Movement Risk with Rate ' + InsTaxCfg[0].Output_2__c + '%;' ;
            }
            update app; 
            return OutMsg;
        }
        catch(Exception e){
            System.Debug('Error in RateManager!');
           system.Debug('RateManager' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
      		return 'Error in RateManager!'; 
        }   
}
    
    Public static  Map<integer,string> GetRateManagerConfigFO(decimal valequip, date DateOfestablishment, decimal valRev,  decimal score, string Inid){
        try{
            Map<integer,string> OutMsg= new Map<integer,string>();
            date now=date.today();
            decimal valdate;
            decimal penbon;
            Application__c app=[SELECT Id FROM Application__c where Id=:Inid];
            if(DateOfestablishment !=null ){
                valdate=DateOfestablishment.daysBetween(now)/365;
            } else{
                OutMsg.put( 0, 'Rejected');
                OutMsg.put( 1, 'establishment date is null');
                app.Reject_Reason__c='Establishment date is null';
                app.Status__c='Application - Rejected';
                update app; 
                return OutMsg;
            }
           
           
           	Admin_Config__c[] GenCfg=[Select Parameter__c, Output_1__c, Output_2__c From Admin_Config__c where RecordTypeId=:[Select Id From RecordType where Name='General'] and 
                                      ( (property_1_val__c > :valRev And Parameter__c='AnnualRevenue') or ( property_1_val__c > :valdate And Parameter__c='DateOfEstablishment') ) And Active__c=TRUE];
			
            if (GenCfg != null && GenCfg.size()!=0){
                if(GenCfg[0].Output_1__c!=''){
                    OutMsg.put(  0, GenCfg[0].Output_1__c);
                    OutMsg.put(  1, GenCfg[0].Output_2__c);
                    app.Reject_Reason__c=GenCfg[0].Output_2__c;
                    app.Status__c='Application - Rejected';
                    update app; 
                    return OutMsg;
               } 
            }
            Admin_Config__c[] RateFactorcfg=[Select  Property_3__c, Property_4__c, Property_5__c, Output_3__c, Output_4__c, Output_5__c  From Admin_Config__c where 
                                             RecordTypeId=:[Select Id From RecordType where Name='TaxRate'] And Property_1_val__c<:valequip and  Property_2_val__c>=:valequip  And Active__c=TRUE];

            Admin_Config__c[] RateMngCfg=[Select  Id, Output_1__c, Output_2__c, Output_3__c , Output_4__c, Output_5__c From Admin_Config__c where 
                                          RecordTypeId=:[Select Id From RecordType where Name='Rate Manager'] and  Property_1_val__c<=:score and  Property_2_val__c>:score  And Active__c=TRUE];

           Admin_Config__c[] InsTaxCfg=[Select Output_1__c, Output_2__c From Admin_Config__c where RecordTypeId=:[Select Id From RecordType where Name='Insurance'] 
                                        And Property_1_val__c<:valequip and  Property_2_val__c>=:valequip  And Active__c=TRUE];
            if (RateMngCfg != null && RateMngCfg.size()!=0){ 
               // app.Credit_Line_Status__c=RateMngCfg[0].Output_1__c;
               // app.Credit_Limit__c=decimal.ValueOf(RateMngCfg[0].Output_4__c);
                penbon=decimal.ValueOf(RateMngCfg[0].Output_3__c);
                app.ScoreCard_Version__c=RateMngCfg[0].Id;
				app.Rating_Candor__c=RateMngCfg[0].Output_5__c;
              	app.Status__c='Application - Approved';
                app.Insurance_Value__c=((valequip * decimal.valueOf(InsTaxCfg[0].Output_1__c)/100)/12).setscale(2);
                app.Insurance_Movement_value__c=((valequip * decimal.valueOf(InsTaxCfg[0].Output_2__c)/100)/12).setscale(2);
	       }
            if (RateFactorcfg != null && RateFactorcfg.size()!=0){ 
                app.Output_Rate_Manager__c='Pick Contract Term: ' + RateFactorcfg[0].Property_3__c + ': €' + 
                    (((decimal.ValueOf(RateFactorcfg[0].Output_3__c ) * penbon) / 100) * valequip).setscale(0) +'; ' + RateFactorcfg[0].Property_4__c + ': €' + 
                    (((decimal.ValueOf(RateFactorcfg[0].Output_4__c) * penbon ) / 100 )* valequip).setscale(0) +'; ' + RateFactorcfg[0].Property_5__c + ': €' + 
                    (((decimal.ValueOf(RateFactorcfg[0].Output_5__c) * penbon) /100) * valequip).setscale(0) +'; ' ;
                app.Output_Ins_Manager__c='Pick Insurance Type: Static Risk with Rate ' + InsTaxCfg[0].Output_1__c + '%; Movement Risk with Rate ' + InsTaxCfg[0].Output_2__c + '%;' ;
                OutMsg.put(0, 'Accepted');
                OutMsg.put(integer.valueOf(RateFactorcfg[0].Property_3__c), string.valueOf((((decimal.ValueOf(RateFactorcfg[0].Output_3__c ) * penbon) / 100) * valequip).setscale(2) ));
                OutMsg.put(integer.valueOf(RateFactorcfg[0].Property_4__c),string.valueOf((((decimal.ValueOf(RateFactorcfg[0].Output_4__c) * penbon ) / 100 )* valequip).setscale(2)) );
                OutMsg.put(integer.valueOf(RateFactorcfg[0].Property_5__c),string.valueOf((((decimal.ValueOf(RateFactorcfg[0].Output_5__c) * penbon) / 100) * valequip).setscale(2) ));
                OutMsg.put(integer.valueOf(RateFactorcfg[0].Property_3__c+'1'), string.valueOf(((decimal.ValueOf(RateFactorcfg[0].Output_3__c ) * penbon)) ));
                OutMsg.put(integer.valueOf(RateFactorcfg[0].Property_4__c+'1'),string.valueOf(((decimal.ValueOf(RateFactorcfg[0].Output_4__c) * penbon )) ));
                OutMsg.put(integer.valueOf(RateFactorcfg[0].Property_5__c+'1'),string.valueOf(((decimal.ValueOf(RateFactorcfg[0].Output_5__c) * penbon) )));
                OutMsg.put(9999,string.ValueOf(app.Insurance_Value__c));
                OutMsg.put(99999,string.ValueOf(app.Insurance_Movement_value__c));
            }
            update app; 
            return OutMsg;
        }
    	catch(Exception e){
            System.Debug('Error in RateManager!');
            system.Debug('RateManager' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return null; 
        }   
    }
    
        public static string GetCreditLineStatus( string Inid){
            try{
                Account acc=[SELECT Id, Date_Of_Establishment__c, D_B_Failure_Score__C, AnnualRevenue FROM Account where Id=:Inid];            
                date dateestb=null;
                date DateOfEstablishment=acc.Date_Of_Establishment__c;
        		decimal valRev=acc.AnnualRevenue;
                decimal score=acc.D_B_Failure_Score__c;
                if (DateOfEstablishment==null ){
                  acc.Credit_Line_Status__c='Credit Line - Pendent';  
                  update acc; 
                  return acc.Credit_Line_Status__c;
                }
                if( score==null || score==0){
                   acc.Credit_Line_Status__c='Credit Line - Pendent';  
                   update acc; 
                   return acc.Credit_Line_Status__c; 
                }

                date now=date.today();
                decimal valdate=DateOfEstablishment.daysBetween(now)/365;
                // It's enough that one of the conditions is not true to stop the process
                Admin_Config__c[] GenCfg=[Select Parameter__c, Output_1__c, Output_2__c From Admin_Config__c where RecordTypeId=:[Select Id From RecordType where 
                                           Name='ScoreCard'] and ( (property_1_val__c > :valRev And Parameter__c='AnnualRevenue') or ( property_1_val__c > :valdate And Parameter__c='DateOfEstablishment') )  And Active__c=TRUE];
                if (GenCfg != null && GenCfg.size()!=0){
                    if(GenCfg[0].Output_1__c!=''){
                        acc.Credit_Line_Status__c=GenCfg[0].Output_1__c;
                        update acc; 
                        return acc.Credit_Line_Status__c;
                   } 
                } 
               
                Admin_Config__c[] RateMngCfg=[Select  Id, Output_1__c, Output_2__c, Output_3__c , Output_4__c, Output_5__c From Admin_Config__c where 
                                              RecordTypeId=:[Select Id From RecordType where Name='ScoreCard']  And Parameter__c='RiscoInforma'and  Property_1_val__c<=:score and  Property_2_val__c>:score  And Active__c=TRUE];
    			if (RateMngCfg != null && RateMngCfg.size()!=0){ 
                    acc.Credit_Line_Status__c=RateMngCfg[0].Output_1__c;
                    update acc; 
                    return acc.Credit_Line_Status__c;
                }
                return acc.Credit_Line_Status__c;
            }
        catch(Exception e){
            System.Debug('Error in RateManager!');
            system.Debug('RateManager' + e.getLineNumber() + ' ' + e.getCause() + ' ' + e.getMessage() );
            return null;
        }   

    }*/
}