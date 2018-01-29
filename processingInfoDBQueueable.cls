public class processingInfoDBQueueable implements /*Schedulable,*/Queueable, database.allowsCallouts {
    public void execute(QueueableContext ctx){
	    //public void execute(SchedulableContext ctx){
		datetime dtbegin = System.now() - 0.052;
		datetime dtend 	 = System.now() - 0.01;
        string nif='';
		system.debug(dtbegin + ' - ' + dtend);
		list <application__C> apps=[select id, name, status__c, accClient__r.nif__c, accClient__r.name, 
								reject_reason__c, accClient__r.id from application__c where createdDate > :dtbegin and 
								createdDate < :dtend and cancelled__c = false];
		system.debug('apps: '+apps);
        Try{
	    	// 5 minute		
			//ALTERACAO - 15/05/17 - aumento do periodo em que é feito o reschedule para obtenção dos reports (BP)                	
			//datetime dtbegin = System.now() - 0.052;
			//datetime dtend 	 = System.now() - 0.01; // diferença entre o inicio e o fim é de uma hora (BP)
			//Utilities.LogIntegration(datetime.now(), datetime.now(), 'dtbegin: '+ dtbegin + 'dtend: ' + dtend, 'Scheduable Reprocess infoDB', null, 'teste');
		    /*Utilities.OutboundIntegration outInt= new Utilities.OutboundIntegration();
			Utilities.OutboundIntegration outIntpdf= new Utilities.OutboundIntegration();*/

			/*system.debug(dtbegin + ' - ' + dtend);
			list <application__C> apps=[select id, name, status__c, accClient__c, accClient__r.nif__c, accClient__r.name, 
										reject_reason__c, accClient__r.id from application__c order by createddate desc limit 1];
			system.debug('apps: '+apps);*/
		            
			for ( application__c app :apps){
				if(app.accClient__r.nif__c == app.accClient__r.name  && ( app.status__c =='' || app.status__c == null )){

					//HP 21/11/2017 -> TODO:Alteração temporario para novo algoritmo esta class necessita de refactoring
					nif = app.accClient__r.nif__c;
				    //REQUEST CREDIT INFO FROM CREDIT INFO PROVIDER
				    CreditInfoContext  creditInfoctx = new CreditInfoContext(nif, 'PT', app.accClient__c, app.Id);
		        	CreditInfoProviderRequest creditReport = new CreditInfoProviderRequest(creditInfoctx);
				    CreditInfoProviderResponse response = creditReport.getCreditInfo();

    			    //LOG JOB ID
    			    response = response == null ? new CreditInfoProviderResponse() : response;
				    Outbound_Integration_Log__c log = new Outbound_Integration_Log__c(
				    	Start__c = response.startDate, 
				    	End__c = Datetime.now(), 
				    	Status__c = response.status ? 'Success':'Failure', 
				    	Code__c = 'SCHEDULABLE_CREDIT_REPORT', 
				    	Get_Sent_XML__c = response.info, 
				    	Get_Received_XML__c = response.xml,  
				    	ApplicationID__c = app.accClient__r.nif__c, 
				    	Message__c = 'Schedulable job ID: ' + ctx.getJobId()
					);
				    insert log;

				   	//HP 21/11/2017 -> TODO:Comentado para correr com novo algoritmo, esta classe precisa de ser refeita
					/*system.debug(app.name);
					system.debug(app.reject_reason__c);
					nif=app.accClient__r.nif__c;
					outInt=DBInfoXML.InformadbGetReport( app.accClient__r.nif__c , 'XMLPROSP', 'Xml', 'Client'); 
					outIntpdf=DBInfoXML.InformadbGetPdfReport(app.accClient__r.nif__c, 'XMLPROSP');
					if (outInt.xml != ''){

				    	DBProp dbprop=DBInfoXML.parseDBXML(outInt.xml );    
				  		ReportDB__c report=DBInfoXML.UpdateReport(dbprop, 'Client', app.accClient__r.id, outIntPdf.pdf); 
				  		string result=ScoreCardConfig.GetCreditLineStatus(app.accClient__r.id, app.id) ;
				  		if (result!=null){
				  			Utilities.LogIntegration(datetime.now(), datetime.now(), 'success', 'Scheduable Reprocess infoDB', null, app.accClient__r.nif__c);
				  		}
				  		else{
				  			Utilities.LogIntegration(datetime.now(), datetime.now(), 'Failure', 'Scheduable Reprocess infoDB', null, app.accClient__r.nif__c);
				  		}
				 		
					}
					outInt= null;
					outIntpdf= null;*/
				}
    		}
        }catch( exception e){
			Outbound_Integration_Log__c log = new Outbound_Integration_Log__c(Start__c = Datetime.now(), End__c = Datetime.now(), Status__c = 'Failure', Code__c = 'SCHEDULABLE_CREDIT_REPORT', Get_Sent_XML__c = '', Get_Received_XML__c = '',  ApplicationID__c = nif, Message__c = e + ' - > Scheduable Reprocess ID : '  + ctx.getJobId(),PrintStackTrace__c = e.getStackTraceString());
			insert log;
        }
    }
}