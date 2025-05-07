public virtual with sharing class ExpenseTriggerHandler extends TriggerHandler {

    @TestVisible
    protected override void afterUpdate(TriggerContext triggerContext) {
        updateRelatedExpenseItems(triggerContext);
    }

    @TestVisible
    private void updateRelatedExpenseItems(TriggerContext triggerContext){
        Map<Id, Expense__c> updatedExpenseById = getUpdatedItemsById(triggerContext.recordContexts);
        if(updatedExpenseById.isEmpty()){return;}

        Map<Boolean, List<Id>> expenseIdsByStatus = getExpenseIdsByStatusMap(updatedExpenseById);
        List<Expense_Item__c> updatedItems = getUpdatedItems(expenseIdsByStatus);

        if(!updatedItems.isEmpty()){
            update updatedItems;
        }
    }

    @TestVisible
    private Map<Id, Expense__c> getUpdatedItemsById(List<TriggerRecordContext> contexts){
        Map<Id, Expense__c> updatedExpenses = new Map<Id, Expense__c>();

        for(TriggerRecordContext recordContext : contexts){
            if(recordContext.isFieldUpdated(Expense__c.All_Approved__c)){
                updatedExpenses.put(recordContext.newRecord.Id, (Expense__c) recordContext.newRecord);
            }
        }

        return updatedExpenses;
    }

    @TestVisible
    private Map<Boolean, List<Id>> getExpenseIdsByStatusMap(Map<Id, Expense__c> expenseByRecordId){
        Map<Boolean, List<Id>> expenseIdsByStatus = new Map<Boolean, List<Id>>{
            true => new List<Id>(), false => new List<Id>()
        };

        for(Id expenseId : expenseByRecordId.keySet()){
            expenseIdsByStatus.get(expenseByRecordId.get(expenseId).All_Approved__c).add(expenseId);
        }

        return expenseIdsByStatus;
    }

    @TestVisible
    private List<Expense_Item__c> getUpdatedItems(Map<Boolean, List<Id>> expenseIdsByStatus){
        List<Expense_Item__c> updatedItems = new List<Expense_Item__c>();

        for(Expense_Item__c item : [
            SELECT Id, IsApproved__c 
            FROM Expense_Item__c 
            WHERE 
                (Expense__c IN :expenseIdsByStatus.get(false) AND IsApproved__c = true) OR 
                (Expense__c IN :expenseIdsByStatus.get(true) AND IsApproved__c = false)
                
            ]
        ){
            item.IsApproved__c = !item.IsApproved__c;
            updatedItems.add(item);
        }

        return updatedItems;
    }
}