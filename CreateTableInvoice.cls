public class CreateTableInvoice
{
    public static void CreateTable(ID DunningAlertID, ID CollectionCaseID)
    {
        String m_Html = '';
        
        List<c2g__codaInvoice__c> m_coda = null;       
        
        if(Test.isRunningTest()){
            m_coda = [Select Id,c2g__Account__c, c2g__Account__r.BillingCountryCode,Invoice_Express_Number_text__c,c2g__DueDate__c,Name,c2g__InvoiceDate__c, c2g__InvoiceTotal__c, (Select Id, Invoice_Total__c,Name, Interest_Rate__c,Interest_Charged__c, Dunning_Alert__c from Interest_Charged_Calculations__r) From c2g__codaInvoice__c where Collection_Case__c =: CollectionCaseID ];
       
        }else{
          m_coda = [Select Id,c2g__Account__c, c2g__Account__r.BillingCountryCode,Invoice_Express_Number_text__c,c2g__DueDate__c,Name,c2g__InvoiceDate__c, c2g__InvoiceTotal__c/*, (select id, c2g__Product__c,  c2g__Product__r.Name From c2g__InvoiceLineItems__r)*/,
					(Select Id, Invoice_Total__c,Name, Interest_Rate__c,Interest_Charged__c, Dunning_Alert__c from Interest_Charged_Calculations__r where Dunning_Alert__c =: DunningAlertID) From c2g__codaInvoice__c where Collection_Case__c =: CollectionCaseID and c2g__PaymentStatus__c = 'Unpaid'] ;
       
        }
        
        m_Html += '<table border="0" cellspacing="2" cellpadding="0" style="width:100%;" class="ProductsTable"><tr>';
        m_Html += '<th style="height:24px; background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:1%;" class="ProductsHeader"></th>';
        m_Html += '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Fatura</th>';
        m_Html += '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Data de Vencimento</th>';
        //m_Html += '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:25%;" class="ProductsHeader">Juros de Mora</th>';
        m_Html += '<th style="background-color: #f2f3f3;border-width: 0 0 1px 1px;border-color: #e0e3e5;color: #000;font-weight: bold;padding: 5px 2px 4px 5px; text-align:center; width:24%;" class="ProductsHeader">Valor</th>';
        m_Html += '</tr>'; 
        
        Date d;
        //Decimal ir = 0;
        Decimal amount = 0;
        Dunning_Alert__c ad_cc = new Dunning_Alert__c();
        for(c2g__codaInvoice__c m_cod : m_coda)
        {
            if(!m_cod.Interest_Charged_Calculations__r.isEmpty()){ 
            system.debug('AQUI ' + m_cod.Interest_Charged_Calculations__r);
                Interest_Charged_Calculation__c icc = m_cod.Interest_Charged_Calculations__r;               
                amount = icc.Invoice_Total__c;
            } else{
                amount = m_cod.c2g__InvoiceTotal__c;
            }
            amount = amount.setScale(2);
            
            d=m_cod.c2g__DueDate__c;
            String formattedDate = d.format();

            m_Html += '<tr><td></td>'; 
            m_Html += '<td style="text-align:center;" class="ProductsCell">'+ m_cod.Invoice_Express_Number_text__c +'</td>';
            m_Html += '<td style="text-align:center;" class="ProductsCell">'+ formattedDate + '</td>';
            //m_Html += '<td style="text-align:center;" class="ProductsCell">'+ ir +' %</td>';
            m_Html += '<td style="text-align:center;" class="ProductsCell">'+ amount  +' &euro;</td>';
            m_Html +='</tr>';
        }        
        m_Html += '</table>'; 
        
        Dunning_Alert__c m_da = [SELECT id, TabInvoice__c FROM Dunning_Alert__c WHERE id =: DunningAlertID];    
        m_da.TabInvoice__c = m_Html;        
        UPDATE m_da;
                
    }
}