public class TriggerRecordContext {
    @TestVisible
    private SObject oldObject;
    
    @TestVisible
    private SObject newObject;
    
    public TriggerRecordContext(SObject newObject) {
        this.newObject = newObject;
    }
    
    public TriggerRecordContext(SObject newObject, SObject oldObject) {
        this.newObject = newObject;
        this.oldObject = oldObject;
    }
    
    public Boolean isFieldUpdated(SObjectField fieldName) {
        if (oldObject == null) {
            return true;
        }
        
        return (newObject.get(fieldName) != oldObject.get(fieldName));
    }
    
    public Boolean isFieldUpdatedZeroEqualsNull(SObjectField fieldName) {
        if (oldObject == null) {
            return true;
        }
        
        Object f1 = oldObject.get(fieldName);
        Object f2 = newObject.get(fieldName);
        if (f1 == f2)
            return false;
        
        return !(f1 == null && f2 == 0 || f2 == null && f1 == 0);
    }
    
    public Boolean isAnyFieldUpdated(List<SObjectField> fieldNames) {
        if (oldObject == null) {
            return true;
        }
        for (SObjectField f : fieldNames) {
            if (newObject.get(f) != oldObject.get(f))
                return true;
        }
        return false;
    }
    
    public Boolean isFieldUpdated(String fieldName) {
        if (oldObject == null) {
            return true;
        }
        
        return (newObject.get(fieldName) != oldObject.get(fieldName));
    }
    
    /*
     * Checks if any field (except for lastmodifieddate or systemmodstamp) was updated
     */
    public Boolean isAnyFieldUpdated() {
        String objectName = newObject.getSObjectType().getDescribe().getName();
        Set<String> allFieldNames = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet();
        allFieldNames.remove('lastmodifieddate');
        allFieldNames.remove('systemmodstamp');
        List<String> fieldNames = new List<String>(allFieldNames);
        
        for (String fieldName : fieldNames) {
            if (this.isFieldUpdated(fieldName)) {
                return true;
            }
        }
        return false;
    }
    
    public SObject oldRecord {
        get {
            return oldObject;
        }
    }
    
    public SObject newRecord {
        get {
            return newObject;
        }
    }
    
    public Object getNewRecordFieldValue(String fieldName) {
        Object fieldValue = null;
        
        if (this.newRecord != null) {
            fieldValue = this.newRecord.get(fieldName);
        }
        
        return fieldValue;
    }
    
    public Object getOldRecordFieldValue(String fieldName) {
        Object fieldValue = null;
        
        if (this.oldRecord != null) {
            fieldValue = this.oldRecord.get(fieldName);
        }
        
        return fieldValue;
    }
    
    public void addError(String errorMessage) {
        if (this.newRecord != null) {
            this.newRecord.addError(errorMessage);
        }
    }
}