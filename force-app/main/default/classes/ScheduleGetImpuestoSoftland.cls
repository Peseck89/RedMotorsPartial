global class ScheduleGetImpuestoSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetImpuestoSoftland('RMBAVARIAN'));
        System.enqueueJob(new BatchGetImpuestoSoftland('RMPEKING'));
    }
}