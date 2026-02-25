global class ScheduleGetBodegaSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetBodegaSoftland('RMBAVARIAN'));
        System.enqueueJob(new BatchGetBodegaSoftland('RMOTOBAI'));
    }
}