global with sharing class ct_closeOldOpp_schedule  implements Schedulable{
    global void execute(SchedulableContext sc) {
        ct_closeOldOpp_batch b = new ct_closeOldOpp_batch(); 
        database.executebatch(b);
     }
}