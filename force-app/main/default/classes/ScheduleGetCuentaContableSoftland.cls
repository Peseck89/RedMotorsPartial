global class ScheduleGetCuentaContableSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetCuentaContableSoftland());
    }
}