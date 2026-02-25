global class ScheduleGetImpuestoSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetImpuestoSoftland());
    }
}