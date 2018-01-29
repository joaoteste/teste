global class CM_HitDateExpiration_Schedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		CM_HitDateExpiration_Batch b = new CM_HitDateExpiration_Batch();
		database.executebatch(b);
	}
}