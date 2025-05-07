trigger ExpenseTrigger on Expense__c (after update) {
    new ExpenseTriggerHandler().handle();
}