trigger ExpenseItemTrigger on Expense_Item__c (after insert, after update, after delete, after undelete) {
    new ExpenseItemTriggerHandler().handle();
}