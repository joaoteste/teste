public class Bill_QUEUE_MoloniCreditNote implements Queueable, Database.AllowsCallouts {
	
	private List<ID> creditNotes;
	
	public Bill_QUEUE_MoloniCreditNote(List<ID> creditNotes){
		this.creditNotes = creditNotes;
	}
	   

	public void execute(QueueableContext context) {
		BILL_MoloniApi bill = new BILL_MoloniApi();
		
		for(ID cn : creditNotes){
			bill.createCreditNote(cn);
		}
		
	}

}