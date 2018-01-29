@isTest
public with sharing class DocuSignStatusTriggerHandlerTest 
{
	@isTest
	public static void DocuSignStatusTest() 
	{

		
		Account acc = new Account();
		acc.Type = 'Customer - Channel'; 
		List<RecordType> lrt = [select Id,Name from RecordType where Name='Account Customer - Channel' limit 1];
		acc.RecordType =lrt[0];
		acc.Name = 'Cliente xpto';
		acc.NIF__c = '123456789';
		insert acc;
		System.assertNotEquals(null,[select Id from Account where Name='Cliente xpto' and Type='Cliente xpto' and NIF__c='123456789'], 'Não insere o acc');

Account acc2 = new Account();
		acc2.Type = 'Customer - Channel'; 
		//List<RecordType> lrt = [select Id,Name from RecordType where Name='Account Customer - Channel' limit 1];
		acc2.RecordType =lrt[0];
		acc2.Name = 'Cliente xpto1';
		acc2.NIF__c = '123456709';
		insert acc2;
		System.assertNotEquals(null,[select Id from Account where Name='Cliente xpto1' and Type='Cliente xpto' and NIF__c='123456709'], 'Não insere o acc');

		Account acc1 = new Account();
		acc1.Type = 'Channel Partner / Vendor';
		List<RecordType> lrt1 = [select Id,Name from RecordType where Name='Account Channel Partner / Vendor' limit 1];
		acc.RecordType =lrt1[0];
		acc1.Name = 'Vendedor xpto';
		acc1.NIF__c = '123456799';
		insert acc1;
		System.assertNotEquals(null,[select Id from Account where Name='Vendedor xpto' and Type='Account Channel Partner / Vendor' and NIF__c='123456799'], 'Não insere o acc1');


		Contact cont = new Contact();
		cont.LastName='Vendor';
		cont.Email='Vendor@gmail.com';
		cont.Account = acc; 
		insert cont;
		System.assertNotEquals(null,[select Id from Contact where LastName='Vendor' and Email='Vendor@gmail.com'], 'Não insere o contacto');

		Contact cont1 = new Contact();
		cont1.LastName='Buyer';
		cont1.Email='Buyer@gmail.com';
		cont1.Account = acc1;
		insert cont1;
		System.assertNotEquals(null,[select Id from Contact where LastName='Buyer' and Email='Buyer@gmail.com'], 'Não insere o contacto1');

Contact cont2 = new Contact();
		cont2.LastName='Buyer1';
		cont2.Email='Buyer1@gmail.com';
		cont2.Account = acc2;
		insert cont2;
		System.assertNotEquals(null,[select Id from Contact where LastName='Buyer' and Email='Buyer@gmail.com'], 'Não insere o contacto1');

		Application__c a = new Application__c();
		a.AccClient__c = acc.Id;
		a.Vendor__c = acc1.Id;
		a.Client_Signer_1__c = cont.Id;
		a.Client_Signer_2__c = cont2.Id;
		a.Vendor_Primary__c = cont1.Id;

		insert a;

		dsfs__DocuSign_Status__c c = new dsfs__DocuSign_Status__c();
		c.dsfs__Envelope_Status__c = 'Completed';
		c.Deleted_by_partner__c = false;
		c.Docusign_Application_Status__c = a.Id;
		c.dsfs__subject__c = 'Contrato Renting';
		insert c;
		c.Deleted_by_partner__c = true;
		update c;
		delete c;
	}
}