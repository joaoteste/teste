/**

Author   |Date  | Comments
Vinod    |10/12/2017 | Initial Creation

**/

global with sharing class SendSMSController {
    
    //Variables to get contact
    public Contact objContact{get;set;}
    
    //Utility class To send sms 
    SMSUtil util;
    
    //List to store number to send message
    public List<String> toNumberList{get;set;}
    
    //Task list to insert send message
    public List<Task> msgList{get;set;}
            
    //Limit of charecters for each message
    public Integer charLimit{get;set;}
    
    //To store number selected from page to send message
    public String toNumber{get;set;}
    
    //To store from number or AlphaNumeric Id of twilio
    public String fromNumber{get;set;}
    
    //To store twilio settings
    public Twilio_Setting__c setting;
    
    //Text of message to share
    public String body{get;set;}
    
    //Current Record Id
    public Id recordId{get;set;}
    
    //Default constructor
    public SendSMSController(){
        init();
    }

    public void init(){
        try{
            setting = new Twilio_Setting__c();
            toNumberList = new List<String>();
            recordId = ApexPages.currentPage().getParameters().get('Id');
            
            //Dynamically formed query for fetching contact
            DescribesObjectResult describeResult = Contact.getsObjectType().getDescribe();
            List<String> fieldsList = new List<String>(describeResult.fields.getMap().keySet());

            String query = 'SELECT '+String.join(fieldsList,',') +' FROM '+describeResult.getName()+' WHERE Id = \''+recordId+'\' LIMIT 1';
            List<Contact> contactList = new List<Contact>();
            
            //If contact id exists then fetch 
            if(recordId != null){
                contactList = Database.query(query);
            }
            if(contactList.size()>0){
                objContact = contactList[0];
            }
        
            util = new SMSUtil();
            
            //Get Twillo login credentilas
            List<Twilio_Setting__c> settingList = [SELECT Id, Name, AccountId__c, Alphanumeric_Sender_Id__c, Auth_Token__c, From_Number__c,Status_Callback_URL__c FROM Twilio_Setting__c WHERE Name = 'Twilio Account' LIMIT 1];
            if(settingList.size() > 0){
                setting = settingList[0];
            }

            //Set body and word limit of body
            body='';
            charLimit = 160;
            
            if(objContact != null){
                //Fetch numbers from the contact
                if(objContact.phone != null){
                    toNumberList.add(objContact.phone);
                }
                if(objContact.MobilePhone != null){
                    toNumberList.add(objContact.MobilePhone);
                }
                if(objContact.OtherPhone != null){
                    toNumberList.add(objContact.OtherPhone);
                }
                if(objContact.HomePhone != null){
                    toNumberList.add(objContact.HomePhone);
                }
            }
            
            //Get earlier messages sent
            msgList  = getMessageListForWho();
            
        }Catch(Exception e){
            System.debug('Error '+e.getMessage());
            System.debug('Exception '+e.getStackTraceString());
        }
    }
    
    //Parameterized constructor
    public SendSMSController(ApexPages.StandardController controller) {
        init();
    }
    
    //Method to get options of contact numbers
    public List<SelectOption> getContactNames(){
        List<SelectOption> conOptions= new List<SelectOption>();
        conOptions.clear();
        for(String phNumber : toNumberList){
            if(phNumber!=null){
                conOptions.add( new SelectOption(phNumber,phNumber));
            }
        }
        return conOptions;
    }
    
    //Method to get options of contact numbers
    public List<SelectOption> getFromNumbers(){
        
        List<SelectOption> fromNoOptions= new List<SelectOption>();
        if(setting.From_Number__c != null){
            fromNoOptions.add( new SelectOption(setting.From_Number__c,setting.From_Number__c));
        }
        if(setting.Alphanumeric_Sender_Id__c != null){
            fromNoOptions.add( new SelectOption(setting.Alphanumeric_Sender_Id__c,setting.Alphanumeric_Sender_Id__c));
        }
        
        return fromNoOptions;
    }
    
    //Method to fetch previous sent message
    public List<Task> getMessageListForWho(){
        List<Task> taskDetails;
        if(objContact != null && objContact.Id != null){
            taskDetails = new List<Task>([SELECT Id, From__c, To__c, Message__c, Message_Date__c, Type__c, Message_Status__c FROM Task WHERE whoId =: objContact.Id AND (Type__c = 'Outgoing' OR Type__c = 'Incoming') ORDER BY Message_Date__c DESC]);
            System.debug('>>>>>'+taskDetails);
        }
        System.debug('After >>>>> '+taskDetails);
        return taskDetails;
    }
    
    //Method to send message on send message button click from page
    public void sendSms(){        
        SMSUtil.sendSms(toNumber, fromNumber, body, objContact.Id);
        body='';
    }
    
    //Remote action method to fetch sent messages once message is sent
    @RemoteAction
    global static List<Task> getMessages(string contactId){
        List<Task> taskDetails;
        System.debug('contactId >>>>> '+contactId);
        if(contactId != null && contactId != ''){
            taskDetails = new List<Task>([SELECT Id, From__c, To__c, Message__c, Message_Date__c, Type__c, Message_Status__c FROM Task WHERE whoId =: contactId AND (Type__c = 'Outgoing' OR Type__c = 'Incoming') ORDER BY Message_Date__c DESC]);
            System.debug('>>>>>'+taskDetails);
        }
        System.debug('After >>>>> '+taskDetails);
        return taskDetails;
    }
    
    //Redirect to contact
    public pageReference Back(){    
        PageReference returnPage = new PageReference('/' + recordId);
        return returnPage;
    }
}