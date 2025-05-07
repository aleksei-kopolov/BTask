public with sharing class ExpenseItemTriggerHandler extends TriggerHandler{
    @TestVisible
    protected override void afterInsert(TriggerContext triggerContext) {
        updateExpenseStatus(triggerContext);
    }

    @TestVisible
    protected override void afterUpdate(TriggerContext triggerContext) {
        updateExpenseStatus(triggerContext);
    }

    @TestVisible
    protected override void afterDelete(TriggerContext triggerContext) {
        deleteExpenseStatus(triggerContext);
    }

    @TestVisible
    protected override void afterUndelete(TriggerContext triggerContext) {
        updateExpenseStatus(triggerContext);
    }

    @TestVisible
    private void deleteExpenseStatus(TriggerContext triggerContext){
        List<Expense_Item__c> updatedItems = (List<Expense_Item__c>) triggerContext.oldRecords;
        Map<Id, Boolean> newStatusByExpenseId = getStatusByExpenseId(updatedItems);
        if(newStatusByExpenseId.isEmpty()){return;}

        Map<Boolean, List<Id>> expenseIdsByOldStatus = getReversedMap(newStatusByExpenseId);
        Map<Boolean, List<Id>> itemIdsByOldStatus = getItemIdsByStatus(newStatusByExpenseId, updatedItems);

        Set<Id> notFullyApprovedExpenseIds = getNotFullyApprovedExpenseIds(expenseIdsByOldStatus.get(false), itemIdsByOldStatus.get(false));
        Set<Id> notEmptyApprovedExpenseIds = getNotEmptyApprovedExpenseIds(expenseIdsByOldStatus.get(false), itemIdsByOldStatus.get(false));
        
        List<Expense__c> updatedExpences = new List<Expense__c>();
        for(Expense__c expense : [
            SELECT Id, All_Approved__c
            FROM Expense__c
            WHERE 
                (All_Approved__c = TRUE AND Id IN :expenseIdsByOldStatus.get(true) AND Id NOT IN :notEmptyApprovedExpenseIds) OR
                (All_Approved__c = FALSE AND Id IN :expenseIdsByOldStatus.get(false) AND Id NOT IN :notFullyApprovedExpenseIds)
        ]){
            expense.All_Approved__c = !expense.All_Approved__c;
            updatedExpences.add(expense);
        }

        if(!updatedExpences.isEmpty()){
            TriggerHandler.disableAllLogic();
            update updatedExpences;
            TriggerHandler.enableAllLogic();
        }
    }

    @TestVisible
    private Map<Id, List<Id>> getfalseStatusItemsMap(List<Expense_Item__c> items){
        Map<Id, List<Id>> itemIdsByExpenseId = new Map<Id, List<Id>>();

        for(Expense_Item__c item : items){
            if(item.IsApproved__c){continue;}
            if(itemIdsByExpenseId.containsKey(item.Expense__c)){
                itemIdsByExpenseId.get(item.Expense__c).add(item.Id);
            }else{
                itemIdsByExpenseId.put(item.Expense__c, new List<Id>{item.Id});
            }
        }

        return itemIdsByExpenseId;
    }

    @TestVisible
    private void updateExpenseStatus(TriggerContext triggerContext){
        List<Expense_Item__c> updatedItems = (List<Expense_Item__c>) triggerContext.getNewRecordsWithChangedField(Expense_Item__c.IsApproved__c);
        if(updatedItems.isEmpty()){return;}

        Map<Id, Boolean> newStatusByExpenseId = getStatusByExpenseId(updatedItems);
        
        Map<Boolean, List<Id>> expenseIdsByNewStatus = getReversedMap(newStatusByExpenseId);
        Map<Boolean, List<Id>> itemIdsByNewStatus = getItemIdsByStatus(newStatusByExpenseId, updatedItems);

        Set<Id> notFullyApprovedExpenseIds = getNotFullyApprovedExpenseIds(expenseIdsByNewStatus.get(true), itemIdsByNewStatus.get(true));

        List<Expense__c> updatedExpences = new List<Expense__c>();
        for(Expense__c expense : [
            SELECT Id, All_Approved__c
            FROM Expense__c
            WHERE 
                (All_Approved__c = TRUE AND Id IN :expenseIdsByNewStatus.get(false)) OR 
                (All_Approved__c = FALSE AND Id IN :expenseIdsByNewStatus.get(true) AND Id NOT IN :notFullyApprovedExpenseIds)
        ]){
            expense.All_Approved__c = !expense.All_Approved__c;
            updatedExpences.add(expense);
        }

        if(!updatedExpences.isEmpty()){
            TriggerHandler.disableAllLogic();
            update updatedExpences;
            TriggerHandler.enableAllLogic();
        }
    }

    @TestVisible
    private Map<Id, Boolean> getStatusByExpenseId(List<Expense_Item__c> updatedItems){
        Map<Id, Boolean> statusByExpenseId = new Map<Id, Boolean>();

        for(Expense_Item__c item : updatedItems){
            if(statusByExpenseId.containsKey(item.Expense__c)){
                statusByExpenseId.put(item.Expense__c, statusByExpenseId.get(item.Expense__c) && item.IsApproved__c);
            }else{
                statusByExpenseId.put(item.Expense__c, item.IsApproved__c);
            }
        }

        return statusByExpenseId;
    }

    @TestVisible
    private Map<Boolean, List<Id>> getReversedMap(Map<Id, Boolean> statusByExpenseId){
        Map<Boolean, List<Id>> expenseIdsBystatus = new Map<Boolean, List<Id>>{
            true => new List<Id>(), false => new List<Id>()
        };

        for(Id expenseId : statusByExpenseId.keySet()){
            expenseIdsBystatus.get(statusByExpenseId.get(expenseId)).add(expenseId);
        }

        return expenseIdsBystatus;
    }

    @TestVisible
    private Map<Boolean, List<Id>> getItemIdsByStatus(Map<Id, Boolean> statusByExpenseId, List<Expense_Item__c> updatedItems){
        Map<Boolean, List<Id>> itemIdsBystatus = new Map<Boolean, List<Id>>{
            true => new List<Id>(), false => new List<Id>()
        };

        for(Expense_Item__c item : updatedItems){
            itemIdsBystatus.get(statusByExpenseId.get(item.Expense__c)).add(item.Id);
        }


        return itemIdsBystatus;
    }

    @TestVisible
    private Set<Id> getNotEmptyApprovedExpenseIds(List<Id> expenseIds, List<Id> itemIds){
        Set<Id> notFullyApprovedExpenseIds = new Set<Id>();

        for(AggregateResult aggResult : [
            SELECT Expense__c, COUNT(Id)
            FROM Expense_Item__c 
            WHERE IsApproved__c = true AND Expense__c IN :expenseIds AND Id NOT IN :itemIds
            GROUP BY Expense__c]){
            notFullyApprovedExpenseIds.add((Id) aggResult.get('Expense__c'));
        }
    
        return notFullyApprovedExpenseIds;
    }


    @TestVisible
    private Set<Id> getNotFullyApprovedExpenseIds(List<Id> expenseIds, List<Id> itemIds){
        Set<Id> notFullyApprovedExpenseIds = new Set<Id>();

        for(AggregateResult aggResult : [
            SELECT Expense__c, COUNT(Id)
            FROM Expense_Item__c 
            WHERE IsApproved__c = false AND Expense__c IN :expenseIds AND Id NOT IN :itemIds
            GROUP BY Expense__c]){
            notFullyApprovedExpenseIds.add((Id) aggResult.get('Expense__c'));
        }
    
        return notFullyApprovedExpenseIds;
    }
}