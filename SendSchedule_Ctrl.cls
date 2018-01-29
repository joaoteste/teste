/**

Author   |Date  | Comments
Vinod    |20/09/2017 | Initial Creation

**/

public class SendSchedule_Ctrl{
    
    public Id paymentPlanId;
    public List<Payment_Schedule__c> paymentScheduleList{get;set;}
    public List<Payment_Plan__c> paymentPlanList{get;set;}
    
    public SendSchedule_Ctrl(ApexPages.StandardController controller) {
        paymentPlanId=ApexPages.currentPage().getParameters().get('id');
        paymentScheduleList = new List<Payment_Schedule__c>();
        paymentPlanList = [SELECT Id, Name, Payments_Table__c, CreatedDate, Contact__c, Collection_Case__c,Collection_Case__r.Account__r.Name, Contact__r.LastName, Contact__r.FirstName FROM Payment_Plan__c WHERE Id =: paymentPlanId];
    }

    public PageReference SendScheduleEmail(){
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
            List<Payment_Plan__c> paymentPlanList = [SELECT Id, Name, Payments_Table__c, Contact__c, Collection_Case__r.Account__r.Name, Contact__r.LastName, Contact__r.FirstName,Contact__r.Email,(SELECT Id, Name, Due_Date__c, Payment_Plan__c, ATM__c, ATM_Entity__c, ATM_Reference__c, ATM__r.Amount__c, CreatedDate FROM Payment_Schedules__r ORDER BY Name DESC) FROM Payment_Plan__c WHERE Id =: paymentPlanId];
            
            //Create email to send for payment plans
            for(Payment_Plan__c objPaymentPlan : paymentPlanList){
                htmlbody = paymentPlanTemplate[0].HtmlValue;
                plainbody = paymentPlanTemplate[0].Body;
                subject = paymentPlanTemplate[0].Subject;
                
                if(objPaymentPlan.Contact__r.Email != null){
                    toAddresses.add(objPaymentPlan.Contact__r.Email);
                    //toAddresses.add('candor@techilaservices.com');
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
                if(objPaymentPlan.Payments_Table__c != null){
                    htmlbody = htmlbody.replace('{!Payment_Plan__c.Payments_Table__c}',objPaymentPlan.Payments_Table__c);
                    plainbody = plainbody.replace('{!Payment_Plan__c.Payments_Table__c}',objPaymentPlan.Payments_Table__c);
                }else{
                    htmlbody = htmlbody.replace('{!Payment_Plan__c.Payments_Table__c}','');
                    plainbody = plainbody.replace('{!Payment_Plan__c.Payments_Table__c}','');
                }
                //Integer variable to maintain which payment schedule of plan is updated
                Integer i = objPaymentPlan.Payment_Schedules__r.size();//1;
                if(i == 0){
                    
                    //If updated populate values of email template from this payment schedule
                    htmlbody = htmlbody.replace('{PaymentScheduleNumber}',string.valueOf(i));
                    plainbody = plainbody.replace('{PaymentScheduleNumber}',string.valueOf(i));
                    
                    htmlbody = htmlbody.replace('{PaymentScheduleDueDate}','DD/MM/YYYY');
                    plainbody = plainbody.replace('{PaymentScheduleDueDate}','DD/MM/YYYY');
                    
                    htmlbody = htmlbody.replace('{!ATM_Reference__c.Entity__c}','');
                    plainbody = plainbody.replace('{!ATM_Reference__c.Entity__c}','');
                    
                    htmlbody = htmlbody.replace('{!ATM_Reference__c.ATM_Reference__c}','');
                    plainbody = plainbody.replace('{!ATM_Reference__c.ATM_Reference__c}','');
                    
                    htmlbody = htmlbody.replace('{!ATM_Reference__c.Amount__c}','');
                    plainbody = plainbody.replace('{!ATM_Reference__c.Amount__c}','');
                }
                //Iterate to check payment schedule is updated
                for(Payment_Schedule__c objPaymentSchedule : objPaymentPlan.Payment_Schedules__r){
                    //Verify if this payment schedule is updated or not
                    if(objPaymentSchedule.ATM__c != null){
                        
                        //If updated populate values of email template from this payment schedule
                        htmlbody = htmlbody.replace('{PaymentScheduleNumber}',string.valueOf(i));
                        plainbody = plainbody.replace('{PaymentScheduleNumber}',string.valueOf(i));
                        
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
                    i--;
                }
                    
                htmlbody = htmlbody.replace(']]>','');
                htmlbody = htmlbody.replace('<![CDATA[','');
                //plainbody = htmlbody.replace(']]>','');
                
                if(toAddresses.size()>0){
                    //Add emails to send
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }   
                    mail.setBccAddresses(new String[] {'info@candor.pt', 'erodrigues@candor.pt'});                    
                    mail.setToAddresses(toAddresses);
                    mail.setSubject(subject);
                    mail.setHtmlBody(htmlbody);
                    mail.setWhatId(objPaymentPlan.ID);                    
                    mail.setPlainTextBody(plainbody);
                    emails.add(mail);
                }
            }
            
            //Send email
            List<Messaging.SendEmailResult> results;
            if(emails.size()>0){
                results = Messaging.sendEmail(emails);
            }
            if(results[0].success){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Email sent successfully. '));
            }
            return null;
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            return null;
        }
    }
   
}