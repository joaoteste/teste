/**

Author   |Date  | Comments
Vinod    |08/30/2017 | Initial Creation

**/
public class PaymentScheduleTriggerHandler {
    
    //To send reminder email for first payment schedule
    public static void sendReminderEmail(Set<Id> paymentPlanIds, Set<Id> paymentScheduleIds){
        
        try{
            List<String> toAddresses = new List<String>();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            //Get email template to be sent
            List<EmailTemplate> paymentPlanTemplate = new List<EmailTemplate>([Select id, Subject, Body, HtmlValue from EmailTemplate Where name ='Payment Plan']);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@candor.pt'];  
            
            String htmlbody;
            String plainbody;
            String subject;
            
            //Fetch payment plans to sent email when payment schedules are updated
            List<Payment_Plan__c> paymentPlanList = [SELECT Id, Name, Type__c, Payments_Table__c, Contact__c, Collection_Case__r.Account__r.Name, Contact__r.LastName, Contact__r.FirstName,Contact__r.Email,(SELECT Id, Name, Due_Date__c, Schedule_Number__c, Payment_Plan__c, ATM__c, ATM_Entity__c, ATM_Reference__c, ATM__r.Amount__c, CreatedDate FROM Payment_Schedules__r ORDER BY Name ASC) FROM Payment_Plan__c WHERE Id IN: paymentPlanIds];
            
            //Create email to send for payment plans
            for(Payment_Plan__c objPaymentPlan : paymentPlanList){
                htmlbody = paymentPlanTemplate[0].HtmlValue;
                plainbody = paymentPlanTemplate[0].Body;
                subject = paymentPlanTemplate[0].Subject;
                
                if(objPaymentPlan.Contact__r.Email != null){
                    toAddresses.add(objPaymentPlan.Contact__r.Email);
                }
                
                if(objPaymentPlan.Collection_Case__r.Account__r.Name != null){
                    subject = subject.replace('{!Account.Name}',objPaymentPlan.Collection_Case__r.Account__r.Name);
                }else{
                    subject = subject.replace('{!Account.Name}','');
                }
                if(objPaymentPlan.Contact__r.FirstName != null){
                    htmlbody = htmlbody.replace('{!Contact.FirstName}',objPaymentPlan.Contact__r.FirstName);
                    plainbody = plainbody.replace('{!Contact.FirstName}',objPaymentPlan.Contact__r.FirstName);
                }else{
                    htmlbody = htmlbody.replace('{!Contact.FirstName}','');
                    plainbody = plainbody.replace('{!Contact.FirstName}','');
                }
                if(objPaymentPlan.Contact__r.LastName != null){
                    htmlbody = htmlbody.replace('{!Contact.LastName}',objPaymentPlan.Contact__r.LastName);
                    plainbody = plainbody.replace('{!Contact.LastName}',objPaymentPlan.Contact__r.LastName);
                }else{
                    htmlbody = htmlbody.replace('{!Contact.LastName}','');
                    plainbody.replace('{!Contact.LastName}','');
                }
                if(objPaymentPlan.Payments_Table__c != null && objPaymentPlan.Type__c == 'Partial'){
                    htmlbody = htmlbody.replace('{!Payment_Plan__c.Payments_Table__c}',objPaymentPlan.Payments_Table__c);
                    plainbody = plainbody.replace('{!Payment_Plan__c.Payments_Table__c}',objPaymentPlan.Payments_Table__c);
                }else{
                    htmlbody = htmlbody.replace('{!Payment_Plan__c.Payments_Table__c}','');
                    plainbody = plainbody.replace('{!Payment_Plan__c.Payments_Table__c}','');
                }
                
                //Integer variable to maintain which payment schedule of plan is updated
                Integer i = 1;
                
                //Iterate to check payment schedule is updated
                for(Payment_Schedule__c objPS : objPaymentPlan.Payment_Schedules__r){
                    Payment_Schedule__c objPaymentSchedule;
                    
                    //Verify if this payment schedule is updated or not
                    if(paymentScheduleIds.contains(objPS.Id)){
                        
                        //If updated populate values of email template from this payment schedule
                        objPaymentSchedule = objPS;
                        
                        System.debug('objPaymentSchedule inside '+objPaymentSchedule);
                        htmlbody = htmlbody.replace('{PaymentScheduleNumber}',objPaymentSchedule.Schedule_Number__c);
                        plainbody = plainbody.replace('{PaymentScheduleNumber}',objPaymentSchedule.Schedule_Number__c);
                        
                        if(objPaymentSchedule.Due_Date__c != null){
                            htmlbody = htmlbody.replace('{PaymentScheduleDueDate}',string.valueOf(DateTime.newInstance(objPaymentSchedule.Due_Date__c.year(),objPaymentSchedule.Due_Date__c.month(),objPaymentSchedule.Due_Date__c.day()).format('dd/MM/YYYY')));
                            plainbody = plainbody.replace('{PaymentScheduleDueDate}',string.valueOf(DateTime.newInstance(objPaymentSchedule.Due_Date__c.year(),objPaymentSchedule.Due_Date__c.month(),objPaymentSchedule.Due_Date__c.day()).format('dd/MM/YYYY')));
                        }else{
                            htmlbody = htmlbody.replace('{PaymentScheduleDueDate}','');
                            plainbody = plainbody.replace('{PaymentScheduleDueDate}','');
                        }
                        if(objPaymentSchedule.ATM_Entity__c != null){
                            htmlbody = htmlbody.replace('{!ATM_Reference__c.Entity__c}',string.valueOf(objPaymentSchedule.ATM_Entity__c));
                            plainbody = plainbody.replace('{!ATM_Reference__c.Entity__c}',string.valueOf(objPaymentSchedule.ATM_Entity__c));
                        }else{
                            htmlbody = htmlbody.replace('{!ATM_Reference__c.Entity__c}','');
                            plainbody = plainbody.replace('{!ATM_Reference__c.Entity__c}','');
                        }
                        if(objPaymentSchedule.ATM_Reference__c != null){
                            htmlbody = htmlbody.replace('{!ATM_Reference__c.ATM_Reference__c}',objPaymentSchedule.ATM_Reference__c);
                            plainbody = plainbody.replace('{!ATM_Reference__c.ATM_Reference__c}',objPaymentSchedule.ATM_Reference__c);
                        }else{
                            htmlbody = htmlbody.replace('{!ATM_Reference__c.ATM_Reference__c}','');
                            plainbody = plainbody.replace('{!ATM_Reference__c.ATM_Reference__c}','');
                        }
                        if(objPaymentSchedule.ATM__r.Amount__c != null){
                            htmlbody = htmlbody.replace('{!ATM_Reference__c.Amount__c}',string.valueOf(objPaymentSchedule.ATM__r.Amount__c));
                            plainbody = plainbody.replace('{!ATM_Reference__c.Amount__c}',string.valueOf(objPaymentSchedule.ATM__r.Amount__c));
                        }else{
                            htmlbody = htmlbody.replace('{!ATM_Reference__c.Amount__c}','');
                            plainbody = plainbody.replace('{!ATM_Reference__c.Amount__c}','');
                        }
                        break;
                    }
                    i++;
                }
                    
                htmlbody = htmlbody.replace(']]>','');
                htmlbody = htmlbody.replace('<![CDATA[','');                
                //plainbody = htmlbody.replace(']]>','');
                if(toAddresses.size()>0){
                    //Add emails to send
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                    mail.setToAddresses(toAddresses);
                    mail.setBccAddresses(new String[] {'dev_team@candor.pt', 'erodrigues@candor.pt'});
                    mail.setWhatId(objPaymentPlan.ID);
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }                      
                    mail.setSubject(subject);
                    mail.setHtmlBody(htmlbody);
                    mail.setPlainTextBody(plainbody);
                    emails.add(mail);
                }
            }
            
            //Send email
            List<Messaging.SendEmailResult> results;
            if(emails.size()>0){
                results = Messaging.sendEmail(emails);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        
    }
    
    public static String convertToPT(String name){
        if(name == 'Not Payed' || name == 'Not Paid' || name == 'In Payment'){
            return 'A Pagar';
        }
        
        if(name == 'Payed' || name == 'Paid'){
            return 'Pago';
        }
        
        return 'ERROR';
        
    }
    
    //Populate rich text area with payment schedule table
    public static void populatePaymentScheduleTable(Set<Id> paymentPlanIds){
        
        try{
            List<Payment_Plan__c> paymentPlanList = new List<Payment_Plan__c>();
            
            //Query all payment plans to update payment table
            if(paymentPlanIds.size() > 0){
                paymentPlanList = [SELECT Id, Name, Payments_Table__c, (SELECT Id, Name, Due_Date__c, Total_Amount__c, Payment_Status__c FROM Payment_Schedules__r ORDER BY Name ASC) FROM Payment_Plan__c WHERE Id IN: paymentPlanIds];
            }
            
            //Update payment table with payments scheduled
            for(Payment_Plan__c objPlan : paymentPlanList){
                //Variable to maintain serial number of payment scheules
                Integer i=1;
                //Populate rich text field with all values of payments schedule
                /*objPlan.Payments_Table__c = '<table border="1" cellpadding="2" cellspacing="0">'+
                                                    '<tr >'+
                                                        '<th>Nº</th>'+
                                                        '<th>Vencimento </th>'+
                                                        '<th>Valor</th>'+
                                                        '<th>Estado</th>'+
                                                    '</tr>';*/
                
                objPlan.Payments_Table__c = '<table border="0" cellspacing="2" cellpadding="0" style="width:100%;" class="ProductsTable"><tr>' 
                    + '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:20%;" class="ProductsHeader">Nº</th>'
                    + '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Data de Vencimento</th>'                 
                    + '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Valor</th>'
                    +'<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:30%;" class="ProductsHeader">Estado</th>'
                    +'</tr>'; 
                
                for(Payment_Schedule__c objPS : objPlan.Payment_Schedules__r){
                    
                        objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ i +'</td>';
                        objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ String.valueOf(DateTime.newInstance(objPS.Due_Date__c.year(),objPS.Due_Date__c.month(),objPS.Due_Date__c.day()).format('dd/MM/YYYY')) + '</td>';
                        objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ objPS.Total_Amount__c  +'€</td>';
                        
                    	if(objPS.Payment_Status__c != null){
                        	objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ convertToPT(objPS.Payment_Status__c)+'</td>';
                    	}else{
                       		objPlan.Payments_Table__c += '<td style="text-align:center;" class="ProductsCell">'+ convertToPT('Not Paid') +'</td>';
                    	}
                    
                        objPlan.Payments_Table__c +='</tr>';
                        i++;
               }   
                
               objPlan.Payments_Table__c += '</table>';                     

            }
            
            //Update payment plans      
            if(paymentPlanList.size() > 0){
                update paymentPlanList;
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        
    }
    
    
}