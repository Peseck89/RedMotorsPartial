global with sharing class cT_scheduleEventClone implements Schedulable  {
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new cT_CloneEventsBatch(), 200);
     }

}