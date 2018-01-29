@isTest
private class AccountWrapperTest {
	
	@isTest static void testWrapper() {
		//set test data
		Account acc_1 = SC_UTIL_Test.createAccountWithCreditReport('500697604', 'Customer - Channel', '500697604');
		Account acc_2 = SC_UTIL_Test.createAccountWithCreditReport('502812540', 'Customer - Channel', '502812540');
        Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '507688333');        
		Application__c app  = RentingApplication_Util_Test.createApplicationWithStartDate(acc_1, vendor, system.today());
		Application__c app2 = RentingApplication_Util_Test.createApplicationWithStartDate(acc_2, vendor, system.today());
       	app.Status__c  = 'Application - Approved';
       	app2.Status__c = 'Application - Approved';
       	update app;	
       	update app2;

		Test.startTest();

	 	AccountWrapper accountWrapper = new AccountWrapper(acc_1);
	 	System.debug('TEST accountWrapper: ' + accountWrapper);

		String query = 'SELECT ID, name, keywords__c, NIF__c, Date_Last_Application__c, Account_Status__c, Available_Credit_Line__c, Credit_Line_Status__c, Createddate, Type, ';
		query += ' (SELECT ID, Name, Email, Description, New_Binding_Contact__c FROM Contacts WHERE shown_in_app__c = true OR New_Binding_Contact__c=true), ';
		query += ' (SELECT lastmodifieddate, Last_Request__c, Last_Request_Status__c FROM Reports_DB__r),'; //ALTERACAO - 26/05/17 - para tirar report(BP)
		query += ' (SELECT ID, Name, Account__c, Credit_Info__c, Score__c, Grade__c, Decison_Status__c, Sub_Grade__c, Decision_Origin__c, Guidance_Limit_Min__c, Guidance_Limit_Max__c, ';        
		query += ' Override__c, Active__c, Account__r.BillingCountry FROM Decisions__r WHERE Active__c = TRUE ORDER BY CREATEDDATE DESC LIMIT 1 ),';
		query += ' (SELECT ID, NAME, Reject_Reason__c,keywords__c, Status__c,Cancelled__c, Contract_sent__c, Contract_Signed__c, Delivery_Certificate_Sent__c,Delivery_Certificate_Signed__c, Application_Date__c,eSignature_Contract__c,Paper_Contract__c, ScoreCard__c FROM Clientapplications__r  WHERE VENDOR__c=\'' + vendor.Id + '\' ';
		query += ' AND (Status__c LIKE \'Application - %\' OR Status__c = NULL) AND Cancelled__c = FALSE ORDER BY Application_Date__c DESC LIMIT 1 ), ';
		query += ' (SELECT id, name, dsfs__Parent_Status_Record__c, dsfs__Date_Delivered__c , dsfs__Date_Declined__c, '; 
		query += ' dsfs__Recipient_Status__c,dsfs__Docusign_Recipient_Email__c, dsfs__Contact__c, dsfs__Date_Sent__c, ';
		query += ' dsfs__Date_Signed__c , dsfs__docusign_recipient_id__c, dsfs__Account__c, dsfs__Parent_Status_Record__r.Docusign_Application_Status__c FROM R00N80000002vw3gEAA__r WHERE dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c NOT IN (\'Voided\', \'Deleted\') AND dsfs__Parent_Status_Record__r.Deleted_by_partner__c = false ) ';
		query += ' FROM Account WHERE ID IN (SELECT AccClient__c from APPLICATION__C WHERE VENDOR__c=\'' + vendor.Id + '\' AND Cancelled__c = FALSE AND (Status__c != \'Application - Rejected\' OR (Status__c = \'Application - Rejected\' AND Createddate = LAST_N_DAYS:8)) '; 
		query += ') ORDER BY LastModifiedDate DESC';

	 	Account [] accArray = Database.query(query);
        AccountWrapper.ListOfAccountWrapper accountWrapperList = new AccountWrapper.ListOfAccountWrapper(accArray);
        System.debug('TEST AccountWrapperList: ' + accountWrapperList);
        System.assert(accountWrapperList.account_wrapper_list.size()>0, 'Account Wrapper List should be bigger than 0');

        Test.stopTest();
	}

	@isTest static void isCreditReportValidTest(){
		//set test data
		Account client = SC_UTIL_Test.createAccountWithCreditReport('507688333', 'Customer - Channel', '507688333');
		Account vendor = SC_UTIL_Test.createAccountWithCreditReport('PARTNER COMPANY', 'Channel Partner / Vendor', '507688333');
		Application__c app = RentingApplication_Util_Test.createApplicationWithStartDate(client, vendor, system.today());
  	  	ReportDB__c report = [SELECT Id, Last_Request__c, LastModifiedDate FROM ReportDB__c WHERE Vendor__c =: client.Id Order by Last_Request__c DESC LIMIT 1];

		Test.startTest();
        
        boolean isReportValid = accountWrapper.isCreditReportValid(report, 2);
        System.assert(isReportValid, 'Report should be valid');

        boolean isReportValid_2 = accountWrapper.isCreditReportValid(report, 0);
        System.assert(!isReportValid_2, 'Report should not be valid');

        Test.stopTest();
	}		
}