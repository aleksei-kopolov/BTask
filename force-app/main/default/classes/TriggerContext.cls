public class TriggerContext {
    @TestVisible
    private List<SObject> newObjects;
    
    @TestVisible
    private List<SObject> oldObjects;
    
    @TestVisible
    private List<TriggerRecordContext> contexts = new List<TriggerRecordContext>();
    
    public TriggerContext(List<SObject> newObjects, List<SObject> oldObjects) {
        if (newObjects != null){
            this.newObjects = newObjects;
        } else {
            this.newObjects = new List<SObject>();
        }
        
        this.oldObjects = oldObjects;
        
        if (newObjects != null) {
            for (Integer i = 0; i < newObjects.size(); i++) {
                this.contexts.add(new TriggerRecordContext(newObjects[i], oldObjects != null ? oldObjects[i] : null));
            }
        }
    }
    
    public List<TriggerRecordContext> recordContexts {
        get { return contexts; }
    }
    
    public List<sObject> newRecords {
        get { return newObjects; }
    }
    
    public List<sObject> oldRecords {
        get { return oldObjects; }
    }
    
    public List<SObject> getNewRecordsWithChangedField(SObjectField fieldName) {
        return getNewRecordsWithChangedField(new List<SObjectField>{ fieldName });
    }
    public List<SObject> getNewRecordsWithChangedField(String fieldName) {
        return getNewRecordsWithChangedField(new List<String>{ fieldName });
    }
    
    public List<SObject> getNewRecordsWithChangedField(List<SObjectField> fieldNames) {
        List<String> fields = new List<String>();
        for (SObjectField field : fieldNames) {
            fields.add(field.getDescribe().getName());
        }
        return getNewRecordsWithChangedField(fields);
    }
    public List<SObject> getNewRecordsWithChangedField(List<String> fieldNames) {
        List<SObject> result = new List<SObject>();
        for (TriggerRecordContext recordContext : recordContexts) {
            for (String fieldName : fieldNames) {
                if (recordContext.isFieldUpdated(fieldName)) {
                    result.add(recordContext.newRecord);
                    break;
                }
            }
        }
        return result;
    }
}