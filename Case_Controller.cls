public class Case_Controller {
	private final Case cs;
    
    public Case_Controller(ApexPages.StandardController stdController) {
        this.cs = (Case)stdController.getRecord();
    }
    
    public pagereference redirectandCloseCase(){
        pagereference redirect = new PageReference('/' +this.cs.id);
        this.cs.Status = 'Closed';
        update cs;
        return redirect;
    }
    
}