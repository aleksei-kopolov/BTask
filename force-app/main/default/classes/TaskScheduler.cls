public with sharing class TaskScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(((Database.Batchable<SObject>)Type.forName('OverdueTaskBatchJob').newInstance()));
    }
}