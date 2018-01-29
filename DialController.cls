/**

Author   |Date  | Comments
Vinod    |01/15/2018 | Initial Creation
**/

public class DialController{
       
    private TwilioCapability capability;
    public String uname {get; set;}
    public Twilio_Setting__c setting{get; set;}
    //public String uname {get; set;}
    
    //****** Initalizer - Set up Twilio Capability Token - requires ApplicationSid__c to be set
    public DialController() {
        
        //Get Twillo login credentilas
        List<Twilio_Setting__c> settingList = [SELECT Id, Name, AccountId__c, Call_From__c, Caller_Id__c, Auth_Token__c, From_Number__c,Status_Callback_URL__c,Call_Status_Url__c FROM Twilio_Setting__c WHERE Name = 'Twilio Account' LIMIT 1];
        if(settingList.size() > 0){
            setting = settingList[0];
        }
    }
        
    //******* Pass in a parameter PhoneNumber - and this will Dial the phone number
    public String getDial() {
        //String callerid = setting.Caller_Id__c;        
        //phone number will be passed as http query parameter
        String PhoneNumber = System.currentPageReference().getParameters().get('PhoneNumber');
        
        TwilioTwiML.Response res = new TwilioTwiML.Response();
        
        TwilioTwiML.Dial d = new TwilioTwiML.Dial(PhoneNumber);
        d.setCallerId(setting.Call_From__c);
                        
        res.append(d);
        //res.append(p);
        return res.toXML();
    }
}