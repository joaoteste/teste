global class FF_SR_CleanClickLinkLogLineItems implements Schedulable {
   global void execute(SchedulableContext sc) {
      FF_BH_CleanClickLinkLogLineItems batch = new FF_BH_CleanClickLinkLogLineItems(); 
      OIL_Delete_Batch batchOIL = new OIL_Delete_Batch();
      database.executebatch(batch, 50);
      database.executebatch(batchOIL, 50);
   }
}