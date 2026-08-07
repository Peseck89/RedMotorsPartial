global class ScheduleGetSubtipoDocumentoSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetSubtipoDocumentoSoftland('RMBAVARIAN'));
        System.enqueueJob(new BatchGetSubtipoDocumentoSoftland('RMPEKING'));
    }
}