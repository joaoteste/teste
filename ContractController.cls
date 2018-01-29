public class ContractController {
    
    public String today {get;set;}

    public ContractController(ApexPages.StandardController stdController) {
    
	    this.today = Datetime.now().format('dd MMMMM yyyy');
    
	}

}