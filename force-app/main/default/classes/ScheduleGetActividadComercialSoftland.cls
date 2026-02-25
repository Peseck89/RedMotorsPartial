global class ScheduleGetActividadComercialSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetAseguradoraSoftland('RMBAVARIAN'));
        System.enqueueJob(new BatchGetAseguradoraSoftland('RMOTOBAI'));
    }
}