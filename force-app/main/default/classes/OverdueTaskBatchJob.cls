public with sharing class OverdueTaskBatchJob implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([
            SELECT Id, Status
            FROM Task 
            WHERE IsClosed = FALSE AND Status != 'Overdue' AND ActivityDate < TODAY
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> tasks){

        for(SObject t : tasks){
            t.put('Status', 'Overdue');
        }

        update tasks;
    }

    public void finish(Database.BatchableContext bc){}
}