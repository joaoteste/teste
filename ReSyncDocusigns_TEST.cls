@isTest (seeAllData =true)
private class ReSyncDocusigns_TEST
{	
	@isTest static void schedule_TEST() 
	{
		System.schedule('ReSyncDocusigns_11_08_17' , '0 0 * ? * 1,2,3,4,5,6,7', new ReSyncDocusigns());
	}
}