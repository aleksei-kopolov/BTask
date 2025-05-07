public virtual with sharing class DML {
    
    public virtual void upsertRecords(List<SObject> objects) {
        List<SObject> updateObjects = new List<SObject>();
        List<SObject> insertObjects = new List<SObject>();
        
        for(SObject obj : objects){
            if(obj.Id != null){
                updateObjects.add(obj);
            }else{
                insertObjects.add(obj);
            }
        }
        
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        results.addAll(Database.update(updateObjects, false));
        results.addAll(Database.insert(insertObjects, false));
        validateSaveResults(results);
    }
    
    public virtual void insertRecord(SObject obj){
        insertRecords(new List<SObject>{obj});
    }
    
    public virtual void insertRecords(List<SObject> objects) {
        List<Database.SaveResult> results = Database.insert(objects, false);
        validateSaveResults(results);
    }
    
    public virtual void updateRecord(SObject obj){
        upsertRecords(new List<SObject>{obj});
    }
    
    public virtual void updateRecords(List<SObject> objects) {
        List<Database.SaveResult> results = Database.update(objects, false);
        validateSaveResults(results);
    }
    
    public virtual void deleteRecord(SObject obj){
        deleteRecords(new List<SObject>{obj});
    }
    
    public virtual void deleteRecords(List<SObject> objects) {
        List<Database.DeleteResult> results = Database.delete(objects, false);
        validateDeleteResults(results);
    }
    
    public void validateSaveResults(List<Database.SaveResult> results){
        String errorMessage = '';
        for(Database.SaveResult result : results){
            if(!result.isSuccess()){
                for(Database.Error error : result.getErrors()){
                    errorMessage += error.getMessage();
                }
            }
        }
        
        if(String.isNotBlank(errorMessage)){
            throw new DmlException(errorMessage);
        }
    }
    
    public void validateDeleteResults(List<Database.DeleteResult> results){
        String errorMessage = '';
        for(Database.DeleteResult result : results){
            if(!result.isSuccess()){
                for(Database.Error error : result.getErrors()){
                    errorMessage += error.getMessage();
                }
            }
        }
        
        if(String.isNotBlank(errorMessage)){
            throw new DmlException(errorMessage);
        }
    }
}