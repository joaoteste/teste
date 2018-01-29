/**
* @date 2017
*
* @description Class to be use as initializer to CreditInfoProviderRequest
*/
public class CreditInfoContext{
    
    public String taxPayerNumber  { get; protected set;}
    public String country { get; protected set;}
    public ID accountID  { get; protected set;}
    public ID applicationID  { get; protected set;}
    public ID vendorAccountID  { get; protected set;}
    public ID vendorLoginID { get; protected set;}


    public CreditInfoContext(String taxPayerNumber, String country, ID accountID){
        this.taxPayerNumber = taxPayerNumber; 
        this.accountID = accountID;
        this.country = country; 
        System.debug('[CreditInfoProviderRequest.CreditInfoContext] -> object: ' + this);
    }

    public CreditInfoContext(String taxPayerNumber, String country, ID accountID, ID vendorAccountID, ID vendorLoginID){
        this.taxPayerNumber = taxPayerNumber;
        this.accountID = accountID;
        this.vendorAccountID = vendorAccountID;
        this.vendorLoginID = vendorLoginID;
        this.country = country;
        System.debug('[CreditInfoProviderRequest.CreditInfoContext] -> object: ' + this);
    }

    public CreditInfoContext(String taxPayerNumber, String country, ID accountID, ID applicationID){
        this.taxPayerNumber = taxPayerNumber;
        this.accountID = accountID;
        this.applicationID = applicationID;
        this.country = country;
        System.debug('[CreditInfoProviderRequest.CreditInfoContext] -> object: ' + this);
    }
}