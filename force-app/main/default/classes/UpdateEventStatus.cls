global with sharing class UpdateEventStatus implements Schedulable{
    // implement scheduled code here
    global void execute(SchedulableContext sc){
        System.enqueueJob(new UpdateEventStatusService());
        
    }
}