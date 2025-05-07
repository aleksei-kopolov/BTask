public virtual class TriggerHandler {
    public static Boolean ignoreAllLogic = false;
    
    @TestVisible
    protected TriggerContext triggerContext;
    
    @TestVisible
    protected Trigger_Settings__c settings;
    
    @TestVisible
    protected TriggerHandler() {
        this.triggerContext = new TriggerContext(Trigger.new, Trigger.old);
        this.settings = Trigger_Settings__c.getOrgDefaults();
    }
    
    @TestVisible
    protected TriggerHandler(TriggerContext triggerContext) {
        this.triggerContext = triggerContext;
        this.settings = Trigger_Settings__c.getOrgDefaults();
    }
    
    private static Set<Id> alreadySeenRecordIds = new Set<Id>();
    public Set<Id> currentTriggerInitiatedRecordIds = new Set<Id>();
    
    protected virtual void beforeInsert(TriggerContext triggerContext) {}
    protected virtual void afterInsert(TriggerContext triggerContext) {}
    
    protected virtual void beforeUpdate(TriggerContext triggerContext) {}
    protected virtual void afterUpdate(TriggerContext triggerContext) {}
    
    protected virtual void beforeDelete(TriggerContext triggerContext) {}
    protected virtual void afterDelete(TriggerContext triggerContext) {}

    protected virtual void beforeUndelete(TriggerContext triggerContext) {}
    protected virtual void afterUndelete(TriggerContext triggerContext) {}
    
    public void handle() {
        if (ignoreAllLogic) { return; }
        if (settings != null & settings.User_Id__c == UserInfo.getUserId() & settings.Is_Disabled__c == true){ return; }
        
        for (TriggerRecordContext ctx : triggerContext.recordContexts) {
            if (ctx.newRecord == null || ctx.newRecord.Id == null){ continue; }
            if (!alreadySeenRecordIds.contains(ctx.newRecord.Id)) {
                alreadySeenRecordIds.add(ctx.newRecord.Id);
                currentTriggerInitiatedRecordIds.add(ctx.newRecord.Id);
            }
        }

        if(Trigger.isInsert){
            if(Trigger.isBefore){
                try {
                    beforeInsert(triggerContext);
                } catch (Exception ex) {
                    processException(ex, triggerContext);
                }
            }else if(Trigger.isAfter){
                try {
                    afterInsert(triggerContext);
                } catch (Exception ex) {
                    processException(ex, triggerContext);
                }
            }
        } else if(Trigger.isUpdate){
            if(Trigger.isBefore){
                try {
                    beforeUpdate(triggerContext);
                } catch (Exception ex) {
                    processException(ex, triggerContext);
                }
            }else if(Trigger.isAfter){
                try {
                    afterUpdate(triggerContext);
                } catch (Exception ex) {
                    processException(ex, triggerContext);
                }
            }
        } else if(Trigger.isDelete){
            if(Trigger.isBefore){
                beforeDelete(triggerContext);
            }else if(Trigger.isAfter){
                afterDelete(triggerContext);
            }
        } else if(Trigger.isUndelete){
            if(Trigger.isBefore){
                beforeUndelete(triggerContext);
            }else if(Trigger.isAfter){
                afterUndelete(triggerContext);
            }
        }
        
        for (Id recordId : currentTriggerInitiatedRecordIds) {
            alreadySeenRecordIds.remove(recordId);
        }
    }


    public static void disableAllLogic() {
        TriggerHandler.ignoreAllLogic = true;
    }
    public static void enableAllLogic() {
        TriggerHandler.ignoreAllLogic = false;
    }
    
    private void processException(Exception ex, TriggerContext triggerContext) {
        for (TriggerRecordContext ctx : triggerContext.recordContexts) {
            processException(ex, ctx);
        }
    }

    private void processException(Exception ex, TriggerRecordContext triggerRecordContext) {
        System.debug('Stack trace: ' + ex.getStackTraceString() + ' Error message: ' + ex.getMessage());
        if (ex instanceof DmlException) {
            triggerRecordContext.newRecord.addError(((DmlException) ex).getDmlMessage(0));
        } else if (ex instanceof ExpectedException) {
            triggerRecordContext.newRecord.addError((ExpectedException) ex);
        } else {
            throw ex;
        }
    }
    
    public class ExpectedException extends Exception {
    }
}