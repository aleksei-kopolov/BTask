public with sharing class OverdueTaskBatchJob implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([
            SELECT Id, Status
            FROM Task 
            WHERE 
                Status NOT IN ('Completed', 'Overdue') AND 
                ActivityDate < TODAY
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Task> tasks){

        for(Task t : tasks){
            t.Status = 'Overdue';
        }

        update tasks;
    }

    public void finish(Database.BatchableContext bc){}
}