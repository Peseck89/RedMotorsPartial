global class ScheduleGetCondicionPagoSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetCondicionPagoSoftland());
    }
}