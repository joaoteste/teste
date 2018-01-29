global class CM_CloseCMSAndDoCashMatch_Schedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		CM_CloseCMSAndDoCashMatch_Batch b = new CM_CloseCMSAndDoCashMatch_Batch();
		database.executebatch(b);
	}
}