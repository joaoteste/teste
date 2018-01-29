/*******************************************

Author      |   Date        |   Description                           |   Version     
Vinod       |   01/12/2018  |   To get details of logged in user         |   1.0     

********************************************/

global class CallCenterUtil{    

    public CallCenterUtil(){
   
    }
    
    global static User getUserInfo(){
        User objUser = [select Id,UserName from User where Id = :UserInfo.getUserId()];
        return objUser;
    }
    
    global static string searchContact(string phoneNo){
        List<Contact> contactList = new List<Contact>([SELECT Id, MobilePhone, Phone FROM Contact WHERE MobilePhone =: phoneNo OR Phone =: phoneNo ORDER BY CreatedDate ASC]);
        System.debug('Contact List '+contactList);
        if(contactList.size()>0 && phoneNo != null && phoneNo != ''){
            return contactList[0].Id;
        }else{
            return '';
        }    
    }
}