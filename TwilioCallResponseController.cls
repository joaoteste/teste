public class TwilioCallResponseController {
    public string xmlResponse {get;set;}
    public TwilioCallResponseController(){
        string trId = ApexPages.currentPage().getParameters().get('trId');
        Tape_Recording_Line_Item__c li = [select Attachment__c from Tape_Recording_Line_Item__c where id = : trId limit 1];        
        xmlResponse = '<Response>'+                        
                        '<Play>'+li.Attachment__c+'</Play>'+                        
                      '</Response>'; 
    }
}