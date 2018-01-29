public class DocuSignStatusTriggerHandler extends TriggerHandler
{
    public DocuSignStatusTriggerHandler() 
    {
    }
    protected override void  beforeInsert() 
    {  

    }

    protected override void  beforeUpdate()
    {

    }

    protected override void  beforeDelete()
    {

    }

    protected override void  afterDelete()
    {

    }

    protected override void  afterInsert() 
    {

    }

    protected override void afterUpdate()
    {
        SendEmailWhenCompleted();
    }

    private void SendEmailWhenCompleted()
    {
        System.debug('Executei');
        dsfs__DocuSign_Status__c [] docs = new List<dsfs__DocuSign_Status__c>(); 

        for( dsfs__DocuSign_Status__c newDoc :(List<dsfs__DocuSign_Status__c>)Trigger.new)
        {
            dsfs__DocuSign_Status__c oldDoc=(dsfs__DocuSign_Status__c)Trigger.oldMap.get(newDoc.ID);
            if( newDoc.Deleted_by_partner__c != oldDoc.Deleted_by_partner__c)
            {
                System.debug('Trigger do Docusign --> entrei na !=');
                if( newDoc.dsfs__Envelope_Status__c == 'Completed' && newDoc.Deleted_by_partner__c == true 
                    && newDoc.dsfs__subject__c.contains('Contrato') && newDoc.dsfs__subject__c.contains('Renting'))
                {
                    System.debug('Trigger do Docusign --> encontrou 1 elemento Completed e deleted');
                    docs.add(newDoc); 
                }
            }
        }

        if(docs.size()>0)
        {
            System.debug('Trigger do Docusign --> a lista tem mais de um elemento.');
            List<Application__c> a =    [select Client_Signer_1__c, Client_Signer_2__c, Vendor_Name__c,Client_Signer_1__r.Email,
                                        Client_Signer_2__r.Email , Vendor_Primary__c, Vendor_Primary__r.Email, Id
                                        from Application__c
                                        where Id=:docs[0].Docusign_Application_Status__c];

            if(a.size()>0)
            {
                if(a[0].Client_Signer_1__r.Email!=null)
                {
                    List<String> lc = new List<String>(); 
                    lc.add(a[0].Client_Signer_1__r.Email);
                    Utilities.sendTemplatedEmail(lc,'Signer1_Contract_Cancelation_Notification',a[0].Client_Signer_1__c,a[0].Id,true);
                    System.debug('Trigger do Docusign --> vou enviar emails para o Signer1');
                }
                if(a[0].Client_Signer_2__r.Email!=null)
                {
                    List<String> lc = new List<String>(); 
                    lc.add(a[0].Client_Signer_2__r.Email);
                    Utilities.sendTemplatedEmail(lc,'Signer2_Contract_Cancelation_Notification',a[0].Client_Signer_2__c,a[0].Id,true);
                    System.debug('Trigger do Docusign --> vou enviar emails para o Signer2');
                }
                if(a[0].Vendor_Primary__r.Email!=null)
                {
                    List<String> lc = new List<String>(); 
                    lc.add(a[0].Vendor_Primary__r.Email);
                    Utilities.sendTemplatedEmail(lc,'Vendor_Contract_Cancelation_Notification',a[0].Vendor_Primary__c,a[0].Id,true);
                    System.debug('Trigger do Docusign --> vou enviar emails para o vendor');
                }
            }
        }        

    }
        
    
}