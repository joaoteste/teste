@isTest (SeeAllData=true)
public class SEPA_SF_Return_Test {

    @isTest (SeeAllData=true)
    public static void testSEPA_SF_Return_SalesInvoices() { 
        
        CR_Sepa_File__c SepaFile = [SELECT id,
                                 Name,
                                 Return_DateTime__c,
                                 Return_Records_Count__c,
                                 Return_Total_Amount__c,
                                 SEPA_Movement_Type__c,
                                 SEPA_Our_Bank_IBAN__c,
                                 Original_Group_Status__c,
                                 Original_Payment_Status__c,
                                 Refund_XML_DateTime__c,
                                 Refund_Record_Count__c,
                                 Refund_Total_Amount__c,
                                 Request_Total_Ammount__c,
                                 SEPA_File_Name__c
                            FROM CR_Sepa_File__c
                            where
                            Request_Records_Count__c >= 2 
                            AND Return_DateTime__c = null
                            AND SEPA_Movement_Type__c = 'RCUR'
                            Order by Request_Records_Count__c ASC
                            LIMIT 1];
        
         List<CR_Sepa_Record__c> sepaRec = [SELECT ID
                             , Name
                             , Request_Amount__c
                             , IBAN__c
                             , CR_Sepa_File__r.Id
                             , CR_Sepa_File__r.Name
                             , CR_Sepa_File__r.SEPA_Collection_Date__c
                             , Invoice_Number__c
                             , CR_Sepa_File__r.SEPA_Movement_Type__c
                             FROM CR_Sepa_Record__c
                             where
                             CR_Sepa_File__c = :sepaFile.Id
                             LIMIT 2];
    
         Attachment att = new Attachment(Name='sepaFile test attachement', ParentId = sepaFile.Id
            , body = Blob.valueOf(
                '<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.002.001.03"><CstmrPmtStsRpt><GrpHdr><MsgId>'+ sepaFile.Name +'20161201180445</MsgId><CreDtTm>2016-11-29T00:00:00</CreDtTm></GrpHdr><OrgnlGrpInfAndSts><OrgnlMsgId>SEPA PT-000206</OrgnlMsgId><OrgnlMsgNmId>pain.008.001.02</OrgnlMsgNmId><OrgnlNbOfTxs>1</OrgnlNbOfTxs><OrgnlCtrlSum>'+ sepaFile.Request_Total_Ammount__c +'</OrgnlCtrlSum><StsRsnInf><Rsn><Prtry>M001</Prtry></Rsn></StsRsnInf></OrgnlGrpInfAndSts><OrgnlPmtInfAndSts><OrgnlPmtInfId>'+ sepaFile.Name +'</OrgnlPmtInfId><OrgnlNbOfTxs>1</OrgnlNbOfTxs><OrgnlCtrlSum>'+ sepaFile.Request_Total_Ammount__c +'</OrgnlCtrlSum><StsRsnInf><Rsn><Prtry>L001</Prtry></Rsn></StsRsnInf>'
                +'<TxInfAndSts><StsId>301</StsId><OrgnlEndToEndId>'+SepaRec[0].Invoice_Number__c+'</OrgnlEndToEndId><StsRsnInf><Rsn><Cd>0000</Cd></Rsn></StsRsnInf><AcctSvcrRef>BBPIPTPL00434967200000000316113001S</AcctSvcrRef><OrgnlTxRef><Amt><InstdAmt Ccy="EUR">'+SepaRec[0].Request_Amount__c+'</InstdAmt></Amt><ReqdColltnDt>2016-12-01</ReqdColltnDt><CdtrSchmeId><Id><PrvtId><Othr><Id>PT09ZZZ111901</Id></Othr></PrvtId></Id></CdtrSchmeId><PmtTpInf><SvcLvl><Cd>SEPA</Cd></SvcLvl><LclInstrm><Cd>COR</Cd></LclInstrm><SeqTp>RCUR</SeqTp><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><PmtMtd>DD</PmtMtd><MndtRltdInf><MndtId>509671497</MndtId><DtOfSgntr>2016-09-23</DtOfSgntr><AmdmntInd>false</AmdmntInd></MndtRltdInf><Dbtr><Nm>HERMINIO S.FERREIRA - VEDACOES E SERRALHARIA CIVIL, LDA</Nm></Dbtr><DbtrAcct><Id><IBAN>PT50003300004540442988305</IBAN></Id></DbtrAcct><DbtrAgt><FinInstnId><BIC>BCOMPTPL</BIC></FinInstnId></DbtrAgt><CdtrAgt><FinInstnId><BIC>BBPIPTPL</BIC></FinInstnId></CdtrAgt><Cdtr><Nm>CANDOR RENTING DE EQUIPAMENTOS SA</Nm></Cdtr><CdtrAcct><Id><IBAN>PT50001000005300067000263</IBAN></Id></CdtrAcct></OrgnlTxRef></TxInfAndSts>'
                +'<TxInfAndSts><StsId>301</StsId><OrgnlEndToEndId>'+SepaRec[1].Invoice_Number__c+'</OrgnlEndToEndId><StsRsnInf><Rsn><Cd>0000</Cd></Rsn></StsRsnInf><AcctSvcrRef>BBPIPTPL00434967200000000316113001S</AcctSvcrRef><OrgnlTxRef><Amt><InstdAmt Ccy="EUR">'+SepaRec[1].Request_Amount__c+'</InstdAmt></Amt><ReqdColltnDt>2016-12-01</ReqdColltnDt><CdtrSchmeId><Id><PrvtId><Othr><Id>PT09ZZZ111901</Id></Othr></PrvtId></Id></CdtrSchmeId><PmtTpInf><SvcLvl><Cd>SEPA</Cd></SvcLvl><LclInstrm><Cd>COR</Cd></LclInstrm><SeqTp>RCUR</SeqTp><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><PmtMtd>DD</PmtMtd><MndtRltdInf><MndtId>509671497</MndtId><DtOfSgntr>2016-09-23</DtOfSgntr><AmdmntInd>false</AmdmntInd></MndtRltdInf><Dbtr><Nm>HERMINIO S.FERREIRA - VEDACOES E SERRALHARIA CIVIL, LDA</Nm></Dbtr><DbtrAcct><Id><IBAN>PT50003300004540442988305</IBAN></Id></DbtrAcct><DbtrAgt><FinInstnId><BIC>BCOMPTPL</BIC></FinInstnId></DbtrAgt><CdtrAgt><FinInstnId><BIC>BBPIPTPL</BIC></FinInstnId></CdtrAgt><Cdtr><Nm>CANDOR RENTING DE EQUIPAMENTOS SA</Nm></Cdtr><CdtrAcct><Id><IBAN>PT50001000005300067000263</IBAN></Id></CdtrAcct></OrgnlTxRef></TxInfAndSts>'
                +'</OrgnlPmtInfAndSts></CstmrPmtStsRpt></Document>'
            )
            , Description='Test Return file');
        

        
        System.debug(LoggingLevel.INFO, 'testCR_SEPA_Debitos new Attachment Done');
        //public static void readReturnXMLforSepaFile(CR_Sepa_File__c sepaFile, Attachment att, Datetime startDatetime, Boolean HistoricUpload) {
        SEPA_SF_Return.readReturnXMLforSepaFile(sepaFile, att, Datetime.now());
        
        System.debug(LoggingLevel.INFO, 'testCR_SEPA_Debitos readReturnXMLforSepaFile Done');
    
    }
    
    @isTest (SeeAllData=true)
    public static void  testSEPA_SF_Return_Payments() { 
        
        CR_Sepa_File__c SepaFile = [SELECT id,
                                 Name,
                                 Return_DateTime__c,
                                 Return_Records_Count__c,
                                 Return_Total_Amount__c,
                                 SEPA_Movement_Type__c,
                                 SEPA_Our_Bank_IBAN__c,
                                 Original_Group_Status__c,
                                 Original_Payment_Status__c,
                                 Refund_XML_DateTime__c,
                                 Refund_Record_Count__c,
                                 Refund_Total_Amount__c,
                                 Request_Total_Ammount__c,
                                 SEPA_File_Name__c
                            FROM CR_Sepa_File__c
                            where
                            Request_Records_Count__c >= 2 
                            AND Return_DateTime__c = null
                            AND SEPA_Movement_Type__c Like 'Payments%'
                            Order by Request_Records_Count__c ASC
                            LIMIT 1];
        
         CR_Sepa_Record__c sepaRec = [SELECT ID
                             , Name
                             , Request_Amount__c
                             , IBAN__c
                             , CR_Sepa_File__r.Id
                             , CR_Sepa_File__r.Name
                             , CR_Sepa_File__r.SEPA_Collection_Date__c
                             , Invoice_Number__c
                             , CR_Sepa_File__r.SEPA_Movement_Type__c
                             FROM CR_Sepa_Record__c
                             where
                             CR_Sepa_File__c = :sepaFile.Id
                             LIMIT 1];
    
         Attachment att = new Attachment(Name='sepaFile test attachement', ParentId = sepaFile.Id
            , body = Blob.valueOf(
                '<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.002.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><CstmrPmtStsRpt><GrpHdr><MsgId>0015834032017013011040055</MsgId><CreDtTm>2017-01-26T00:00:00</CreDtTm></GrpHdr><OrgnlGrpInfAndSts><OrgnlMsgId>'
                + sepaRec.CR_Sepa_File__r.Name + '</OrgnlMsgId><OrgnlMsgNmId>pain.001.001.03</OrgnlMsgNmId><OrgnlNbOfTxs>1</OrgnlNbOfTxs><OrgnlCtrlSum>'
                + SepaFile.Request_Total_Ammount__c+ '</OrgnlCtrlSum><StsRsnInf><Rsn><Prtry>M000</Prtry></Rsn></StsRsnInf></OrgnlGrpInfAndSts><OrgnlPmtInfAndSts><OrgnlPmtInfId>'
                + sepaRec.CR_Sepa_File__r.Name + '</OrgnlPmtInfId><OrgnlNbOfTxs>1</OrgnlNbOfTxs><OrgnlCtrlSum>'
                + SepaFile.Request_Total_Ammount__c+ '</OrgnlCtrlSum><StsRsnInf><Rsn><Prtry>L000</Prtry></Rsn></StsRsnInf></OrgnlPmtInfAndSts></CstmrPmtStsRpt></Document>'
            )
            , Description='Test Return file');

        System.debug(LoggingLevel.INFO, 'testCR_SEPA_Debitos new Attachment Done');
        //public static void readReturnXMLforSepaFile(CR_Sepa_File__c sepaFile, Attachment att, Datetime startDatetime, Boolean HistoricUpload) {
        SEPA_SF_Return.readReturnXMLforSepaFile(sepaFile, att, Datetime.now());
        
        System.debug(LoggingLevel.INFO, 'testCR_SEPA_Debitos readReturnXMLforSepaFile Done');
    
    }
    
    @isTest  //TODO to remove this code
    public static void  testDummyCode() { 
        SEPA_SF_Return.testDummyCode();
    }
    
}