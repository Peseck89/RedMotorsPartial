global class ScheduleGetCentroCostoSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetCentroCostoSoftland());
    }
}