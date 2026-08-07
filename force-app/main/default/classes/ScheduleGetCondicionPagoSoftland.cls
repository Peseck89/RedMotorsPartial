global class ScheduleGetCondicionPagoSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetCondicionPagoSoftland('RMBAVARIAN'));
        System.enqueueJob(new BatchGetCondicionPagoSoftland('RMPEKING'));
    }
}