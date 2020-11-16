global with sharing class AccountBatchSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        AccountBatch batch = new AccountBatch ();
       
        database.executebatch(batch, 100);
    }
}
