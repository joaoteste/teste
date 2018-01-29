global class CM_UpdPaymentCollection_Schedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		CM_UpdPaymentCollection_Batch b = new CM_UpdPaymentCollection_Batch();
		database.executebatch(b);
	}
}