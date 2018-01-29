@isTest
public class TestDataUtility_FOs {
	
	// 1) Recieve SOBject, Fields, & Map of fields to override during test data creation
    // 2) Load field override values
    // 3) Return SObject
    public static sObject addOvrs(sObject loadObj, list<Schema.SObjectField> soFlds, map<string,string> mapOvrs) {
        set<string> fldNames = new set<string>(mapOvrs.keySet());
        Schema.DescribeFieldResult fldDesc = null;
        // read through field list looking for field types not Reference (foreign keys, loaded in addParents method)
        for(Schema.SObjectField af : soFlds) {
            fldDesc = af.getDescribe();
            for(string fldName : fldNames) {
                //Ommitted as Label of PriceBookEntryId is matching with PriceBookEntryId__c for Sobject OpportunityLineItem
                if(fldName == fldDesc.getName()) {
                    // we have a match so load it and break out of the loop:
                    // must convert from string to appropriate data type:
                    if(fldDesc.getType() == Schema.DisplayType.BOOLEAN) loadObj.put(af, boolean.valueOf(mapOvrs.get(fldName)));
                    if(fldDesc.getType() == Schema.DisplayType.CURRENCY) loadObj.put(af, decimal.valueOf(mapOvrs.get(fldName)));
                    if(fldDesc.getType() == Schema.DisplayType.DATE) loadObj.put(af, date.valueOf(mapOvrs.get(fldName)));
                    if(fldDesc.getType() == Schema.DisplayType.DATETIME) loadObj.put(af, dateTime.valueOf(mapOvrs.get(fldName)));
                    if(fldDesc.getType() == Schema.DisplayType.DOUBLE) loadObj.put(af, double.valueOf(mapOvrs.get(fldName)));
                    if(fldDesc.getType() == Schema.DisplayType.EMAIL) loadObj.put(af, mapOvrs.get(fldName));
                    if(fldDesc.getType() == Schema.DisplayType.INTEGER) loadObj.put(af, integer.valueOf(mapOvrs.get(fldName)));
                    if(fldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) loadObj.put(af, mapOvrs.get(fldName));
                    if(fldDesc.getType() == Schema.DisplayType.PERCENT) loadObj.put(af, decimal.valueOf(mapOvrs.get(fldName)));
                    if(fldDesc.getType() == Schema.DisplayType.PHONE) loadObj.put(af, mapOvrs.get(fldName));
                    if(fldDesc.getType() == Schema.DisplayType.PICKLIST) loadObj.put(af, mapOvrs.get(fldName));
                    if(fldDesc.getType() == Schema.DisplayType.REFERENCE) loadObj.put(af, mapOvrs.get(fldName));
                    if(fldDesc.getType() == Schema.DisplayType.STRING) loadObj.put(af, mapOvrs.get(fldName));
                    if(fldDesc.getType() == Schema.DisplayType.TEXTAREA) loadObj.put(af, mapOvrs.get(fldName));
                    if(fldDesc.getType() == Schema.DisplayType.TIME) loadObj.put(af, datetime.valueOf(mapOvrs.get(fldName)));
                    if(fldDesc.getType() == Schema.DisplayType.URL) loadObj.put(af, mapOvrs.get(fldName));
                    break;
                }
            }
        }
        return loadObj;
    }
}