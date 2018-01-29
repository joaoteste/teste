/**

Author   |Date  | Comments
Vinod    |11/08/2017 | Initial Creation
**/


public class TwilioCallStatusController {    
    public void updateStatus(){
        Map<string,string> params = Apexpages.currentPage().getParameters();
        System.debug('params ' +params);
        string taskId = params.get('taskId');
        string sid = params.get('CallSid');
        Task objTask;
        
        try{
            if(params.get('CallStatus') != null && (params.get('CallStatus') == 'no-answer' || params.get('CallStatus') == 'busy' || params.get('CallStatus') == 'canceled')){
                if(taskId!=null)
                    objTask = [select Id, Call_Status__c, CallSid__c, Call_Time__c, CallDurationInSeconds, Number_Of_Tries__c from Task where Id =: taskId];
                else
                    objTask = [select Id, Call_Status__c, CallSid__c, Call_Time__c, CallDurationInSeconds, Number_Of_Tries__c from Task where CallSid__c = :sid];
                if(Integer.valueOf(objTask.Number_Of_Tries__c) >= 1){
                    objTask.Number_Of_Tries__c = String.valueOf(Integer.valueOf(objTask.Number_Of_Tries__c) - 1);
                    objTask.Is_Scheduled__c = true;
                    objTask.Call_Status__c = 'Queued';
                    //Decimal offSetHours = TwilioCallStatusController.getOffsetHours();
                    
                    DateTime currentTime;
                    if(objTask.Call_Time__c != null){
                        currentTime = objTask.Call_Time__c;
                    }
                    
                    Integer hours;
                    if(currentTime != null){
                        hours = currentTime.hour();
                    }
                    
                    DateTime scheduleDate = nextScheduleDate(hours,currentTime);
                    
                    objTask.Call_Time__c = scheduleDate;
                    objTask.Status='Open';
                }else{
                    objTask.Is_Scheduled__c = false;
                    objTask.Status='Completed';
                    objTask.Call_Status__c = params.get('CallStatus');
                }
                //objTask.AMD_Type__c = params.get('AnsweredBy');
                update objTask;
                
            }else{
                if(taskId!=null)
                    objTask = [select Id, Call_Status__c , CallSid__c,CallDurationInSeconds from Task where Id = :taskId];
                else
                    objTask = [select Id, Call_Status__c , CallSid__c,CallDurationInSeconds from Task where CallSid__c =:sid];
                objTask.Call_Status__c = params.get('CallStatus');
                objTask.CallSid__c = sid;
                objTask.Status='Completed';
                objTask.CallDurationInSeconds = ((params.get('CallDuration')!=null)?Integer.valueOf(params.get('CallDuration')):0);
                objTask.AMD_Type__c = params.get('AnsweredBy');
                update objTask;
            }
        }catch(Exception e){
            /*Error_Log__c objError1 = new Error_Log__c();
            objError1.Error_Body__c = e.getMessage()+' '+e.getStackTraceString()+' '+sid+' '+Apexpages.currentPage().getParameters();
            insert objError1;*/
            system.debug('Message >>>>>>>>>>>>>>>>>' + e.getMessage());
        }
    }
    
    //Method used to return offset hours between User timezone and location timezone
    public static DateTime nextScheduleDate(Integer hours,DateTime currentTime){
        if(hours != null && currentTime != null && hours < 11){
            DateTime dt = DateTime.newInstance(currentTime.year(), currentTime.month(), currentTime.day(), 11, 0, 0);
            return dt;
        }
        if(hours != null && currentTime != null && hours >= 11 && hours < 16){
            DateTime dt = DateTime.newInstance(currentTime.year(), currentTime.month(), currentTime.day(), 16, 0, 0);
            return dt;
        }
        if(hours != null && currentTime != null && hours >= 16){
            DateTime dt = DateTime.newInstance(currentTime.year(), currentTime.month(), currentTime.day()+1, 11, 0, 0);
            return dt;
        }
        return null;
    }
    
    //Method used to return offset hours between User timezone and location timezone
    /*public static Decimal getOffsetHours(){

        //Calculate User timezone offset from GMT time.
        DateTime now = DateTime.now();
        Long userOffset = DateTime.newInstance(now.date(), now.time()).getTime() - DateTime.newInstance(now.dateGmt(), now.timeGmt()).getTime();
        System.debug('userOffsetFromGMT (milliseconds): ' + userOffset);
        
        if(userOffset == 0.0){
            return 0.0;
        }
        Decimal userOffsetHours = 0.0;
        userOffsetHours = (userOffset / (60 * 60));
        userOffsetHours = userOffsetHours/1000;
        System.debug('userOffsetHoursFromGMT (hours): ' + userOffsetHours);

        return userOffsetHours;
    }*/
}